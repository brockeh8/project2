import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../models/study_group.dart';
import '../../widgets/group_card.dart';
import 'create_group_screen.dart';
import 'group_chat_screen.dart';

class GroupsListScreen extends StatelessWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GroupService();

    return Scaffold(
      appBar: AppBar(title: const Text("Study Groups")),
      body: StreamBuilder<List<StudyGroup>>(
        stream: service.streamGroups(),
        builder: (context, snap) {
          final groups = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (groups.isEmpty) {
            return const Center(child: Text("No groups yet. Create one!"));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  for (final g in groups)
                    GroupCard(
                      group: g,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatScreen(groupId: g.id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
