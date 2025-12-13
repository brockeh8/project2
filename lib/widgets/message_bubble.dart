import 'package:flutter/material.dart';
import '../models/group_message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
    final GroupMessage message;
    final bool isMe;

    const MessageBubble({
        super.key,
        required this.message,
        required this.isMe,
    });

    String _formatTime(DateTime dt) {
        final local = dt.toLocal();
        final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
        final m = local.minute.toString().padLeft(2, '0');
        final amPm = local.hour >= 12 ? 'PM' : 'AM';
        return '$h:$m $amPm';
    }

    @override
    Widget build(BuildContext context) {
        final bg = isMe ? AppTheme.primary : Colors.white;
        final textColor = isMe ? Colors.white : Colors.black87;
        final align =
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        final bubbleAlign =
            isMe ? Alignment.centerRight : Alignment.centerLeft;

        final radius = BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
        );

    return Align(
      alignment: bubbleAlign,
      child: Column(
        crossAxisAlignment: align,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: Text(
              isMe ? 'You' : message.senderName,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              border: isMe
                  ? null
                  : Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : Colors.black45,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
