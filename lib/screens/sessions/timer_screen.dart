import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';

class TimerArgs {
  final String groupId;
  final String groupName;
  final String sessionId;
  final int durationMinutes;
  final DateTime startTime;
  final String ownerUid;

  TimerArgs({
    required this.groupId,
    required this.groupName,
    required this.sessionId,
    required this.durationMinutes,
    required this.startTime,
    required this.ownerUid,
  });
}

class TimerScreen extends StatefulWidget {
  final TimerArgs args;

  const TimerScreen({
    super.key,
    required this.args,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _service = SessionService();
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    final total = Duration(minutes: widget.args.durationMinutes);
    final end = widget.args.startTime.add(total);
    final diff = end.difference(DateTime.now());

    setState(
      () => _remaining = diff.isNegative ? Duration.zero : diff,
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _end() async {
    await _service.endSession(widget.args.sessionId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isOwner = uid == widget.args.ownerUid;

    return Scaffold(
      appBar: AppBar(title: const Text("Timer")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: const Center(
                  child: Text("Timer"),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.args.groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _fmt(_remaining),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isOwner ? _end : null,
                  child: const Text("End Session"),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                  ),
                  child: const Text("Leave Session"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
