import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_theme.dart';

class RoomCard extends StatelessWidget {
  final StudyRoom room;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    if (room.isOccupied) {
      statusText = 'In use';
      statusColor = Colors.red.shade400;
    } else {
      statusText = 'Available';
      statusColor = Colors.green.shade600;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.building} • Floor ${room.floor} • ${room.capacity} seats',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
