import 'package:flutter/material.dart';
import '../models/group_message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
    final GroupMessage message;
    final bool isMe;

    const MessageBubble({
        super.key, 
        required this.message, 
        required this.isMe
    });

    @override
    Widget build(BuildContext context) {
        final bg = isMe ? AppTheme.field : Colors.white;
        final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

        final radius = BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: isMe ? const Radius.circular(10) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(10),
        );

        return Column(
            crossAxisAlignment: align,
            children: [
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        message.senderName,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFB9B9B9)),
                    ),
                    child: Text(message.text),
                ),
            ],
        );
    }
}
