import 'package:flutter/material.dart';
import '../../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _course = TextEditingController();
  final _desc = TextEditingController();
  final _service = GroupService();

  bool _loading = false;

  Future<void> _create() async {
    setState(() => _loading = true);
    await _service.createGroup(
      name: _name.text,
      courseCode: _course.text,
      description: _desc.text,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _course.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: "Group Name")),
              const SizedBox(height: 12),
              TextField(controller: _course, decoration: const InputDecoration(labelText: "Course Code")),
              const SizedBox(height: 12),
              TextField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _loading ? null : _create,
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
