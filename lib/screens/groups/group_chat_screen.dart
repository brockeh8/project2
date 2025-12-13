import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/group_service.dart';
import '../../services/chat_service.dart';
import '../../services/session_service.dart';
import '../../models/study_group.dart';
import '../../widgets/message_bubble.dart';
import '../sessions/timer_screen.dart';

class GroupChatScreen extends StatefulWidget {
    final String groupId;
    const GroupChatScreen({super.key, required this.groupId});

    @override
    State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
    final _groupService = GroupService();
    final _chatService = ChatService();
    final _sessionService = SessionService();
    final _msg = TextEditingController();

    @override
    void dispose() {
        _msg.dispose();
        _scroll.dispose();
        super.dispose();
    }

    Future<void> _send() async {
        final t = _msg.text.trim();
        if (t.isEmpty) return;
        _msg.clear();
        await _chatService.sendMessage(widget.groupId, text);
    
        //scroll to bottom
        if (_scroll.hasClients) {
            await Future.delayed(const Duration(milliseconds: 100));
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
    }

    Future<void> _startSession(StudyGroup group) async {
        final session = await _sessionService.startSession(group.id, 25);
        if (!mounted) return;

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isMember = group.memberUids.contains(uid);

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
                child: Text(isMember ? "Leave" : "Join"),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.courseCode.isEmpty ? "Group Chat" : group.courseCode,
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
                child: StreamBuilder(
                  stream: _chatService.streamMessages(group.id),
                  builder: (context, mSnap) {
                    final messages = mSnap.data ?? [];
                    if (messages.isEmpty) {
                      return const Center(child: Text("No messages yet."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        return Align(
                          alignment: m.senderUid == uid
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: MessageBubble(
                            message: m,
                            isMe: m.senderUid == uid,
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
                        decoration: const InputDecoration(hintText: "Message"),
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
