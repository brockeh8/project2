import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/group_service.dart';
import '../../services/chat_service.dart';
import '../../services/session_service.dart';
import '../../models/study_group.dart';
import '../../models/group_message.dart';
import '../../models/study_session.dart';
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

  Future<void> _startSessionNow(StudyGroup group) async {
    final session = await _sessionService.startSessionNow(
      groupId: group.id,
      title: group.name,
      durationMinutes: 25,
    );

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

  Future<void> _scheduleSessionDialog(StudyGroup group) async {
    final titleController =
        TextEditingController(text: '${group.name} Study Session');
    final startInController = TextEditingController(text: '30'); 
    final durationController = TextEditingController(text: '50'); 

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: startInController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starts in (minutes)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final startIn =
                    int.tryParse(startInController.text.trim()) ?? 30;
                final duration =
                    int.tryParse(durationController.text.trim()) ?? 50;

                final startTime =
                    DateTime.now().add(Duration(minutes: startIn));

                await _sessionService.scheduleSession(
                  groupId: group.id,
                  title: title.isEmpty ? group.name : title,
                  startTime: startTime,
                  durationMinutes: duration,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final amPm = local.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.courseCode.isEmpty
                                ? "Group Chat"
                                : group.courseCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              isMember ? () => _startSessionNow(group) : null,
                          child: const Text("Start Focus Now"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          StreamBuilder<StudySession?>(
                            stream: _sessionService
                                .streamActiveSession(group.id),
                            builder: (context, sSnap) {
                              final active = sSnap.data;
                              if (active == null) {
                                return const Text(
                                  "No active session.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Active: ${active.title}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Started at ${_formatTime(active.startTime)} • ${active.durationMinutes} min",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TimerScreen(
                                              args: TimerArgs(
                                                groupId: group.id,
                                                groupName: group.name,
                                                sessionId: active.id,
                                                durationMinutes:
                                                    active.durationMinutes,
                                                startTime:
                                                    active.startTime,
                                                ownerUid: group.ownerUid,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Join Timer"),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // Upcoming sessions
                          StreamBuilder<List<StudySession>>(
                            stream: _sessionService
                                .streamUpcomingSessions(group.id),
                            builder: (context, upSnap) {
                              final upcoming = upSnap.data ?? [];
                              if (upcoming.isEmpty) {
                                return const Text(
                                  "No scheduled sessions.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Upcoming sessions:",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...upcoming.take(3).map((s) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(top: 2),
                                      child: Text(
                                        "- ${s.title} • ${_formatTime(s.startTime)} (${s.durationMinutes} min)",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: isMember
                                  ? () => _scheduleSessionDialog(group)
                                  : null,
                              icon: const Icon(Icons.event_note, size: 16),
                              label: const Text(
                                "Schedule Session",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Chat messages
              Expanded(
                child: StreamBuilder<List<GroupMessage>>(
                  stream: _chatService.streamMessages(group.id),
                  builder: (context, snap) {
                    if (snap.connectionState ==
                        ConnectionState.waiting) {
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
                        return MessageBubble(
                          message: m,
                          isMe: isMe,
                        );
                      },
                    );
                  },
                ),
              ),
              // Input bar
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
