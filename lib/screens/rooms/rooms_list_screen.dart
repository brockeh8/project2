import 'package:flutter/material.dart';
import '../../services/room_service.dart';
import '../../models/study_room.dart';
import '../../widgets/room_card.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  final _service = RoomService();
  final _searchCtrl = TextEditingController();
  bool _availableOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Rooms")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: "Search rooms/buildings",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Available"),
                  selected: _availableOnly,
                  onSelected: (v) => setState(() => _availableOnly = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StudyRoom>>(
              stream: _service.streamRooms(
                search: _searchCtrl.text,
                availableOnly: _availableOnly,
              ),
              builder: (context, snap) {
                final rooms = snap.data ?? [];

                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (rooms.isEmpty) {
                  return const Center(child: Text("No matching rooms."));
                }

                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 620),
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        for (final r in rooms)
                          RoomCard(
                            room: r,
                            onTap: () => _service.toggleAvailability(
                              r.id,
                              !r.isAvailable,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _seedRooms,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Seed Rooms'),
      ),
    );
  }
}
