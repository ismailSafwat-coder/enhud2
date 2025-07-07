import 'package:enhud/widget/studytabletextform.dart';
import 'package:flutter/material.dart';

class Taskdilog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String type;
  final String? priority;
  final TextEditingController taskController;
  final TextEditingController Descriptioncontroller;
  final Function(String?) onPriorityChanged;
  const Taskdilog(
      {super.key,
      required this.priority,
      required this.formKey,
      required this.taskController,
      required this.Descriptioncontroller,
      required this.onPriorityChanged,
      required this.type});

  @override
  State<Taskdilog> createState() => _TaskdilogState();
}

class _TaskdilogState extends State<Taskdilog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${widget.type} Title'),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Studytabletextform(
                        controller: widget.taskController,
                        hintText: 'Enter ${widget.type} Title')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Description'),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Studytabletextform(
                        controller: widget.Descriptioncontroller,
                        hintText: 'Enter Description')),
              ],
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            const Text('Priority'),
            Row(
              children: [
                Radio<String>(
                  value: 'Low',
                  groupValue: widget.priority,
                  onChanged: (value) {
                    widget.onPriorityChanged(value!);
                  },
                ),
                const Text('Low'),
                Radio<String>(
                  value: 'Medium',
                  groupValue: widget.priority,
                  onChanged: (value) {
                    widget.onPriorityChanged(value!);
                  },
                ),
                const Text('Medium'),
                Radio<String>(
                  value: 'High',
                  groupValue: widget.priority,
                  onChanged: (value) {
                    widget.onPriorityChanged(value!);
                  },
                ),
                const Text('High'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
