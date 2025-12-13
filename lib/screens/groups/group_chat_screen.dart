import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/group_service.dart';
import '../../services/chat_service.dart';
import '../../services/session_service.dart';
import '../../models/study_group.dart';
import '../../models/group_message.dart';
import '../../widgets/message_bubble.dart';
import '../sessions/timer_screen.dart';
import '../../theme/app_theme.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupService _groupService = GroupService();
  final ChatService _chatService = ChatService();
  final SessionService _sessionService = SessionService();

  final TextEditingController _msg = TextEditingController();

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msg.text.trim();
    if (text.isEmpty) return;

    _msg.clear();
    await _chatService.sendMessage(widget.groupId, text);
  }

  Future<void> _startSession(StudyGroup group) async {
    final session = await _sessionService.startSessionNow(
        groupId: group.id,
        title: group.name,
        durationMinutes: 25,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          args: TimerArgs(
            groupId: group.id,
            groupName: group.name,
            sessionId: session.id,
            durationMinutes: session.durationMinutes,
            startTime: session.startTime,
            ownerUid: group.ownerUid,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<StudyGroup>(
      stream: _groupService.streamGroup(widget.groupId),
      builder: (context, gSnap) {
        final group = gSnap.data;
        if (group == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isMember = group.memberUids.contains(uid);

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              TextButton(
                onPressed: () async {
                  if (isMember) {
                    await _groupService.leaveGroup(group.id);
                  } else {
                    await _groupService.joinGroup(group.id);
                  }
                },
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.gsuRed, 
                ),
                child: Text(isMember ? "Leave" : "Join"),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.courseCode.isEmpty
                            ? "Group Chat"
                            : group.courseCode,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isMember ? () => _startSession(group) : null,
                      child: const Text("Start Session"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<GroupMessage>>(
                  stream: _chatService.streamMessages(group.id),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messages = snap.data ?? [];

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text("No messages yet."),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        final bool isMe = m.senderUid == uid;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: MessageBubble(
                            message: m,
                            isMe: isMe,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msg,
                        decoration: const InputDecoration(
                          hintText: "Message",
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed: isMember ? _send : null,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
