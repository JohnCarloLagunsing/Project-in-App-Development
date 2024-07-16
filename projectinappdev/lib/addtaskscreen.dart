import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AddTaskScreen extends StatefulWidget {
  final Function(String, String, DateTime) onAddTask;

  AddTaskScreen({required this.onAddTask});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  DateTime? _selectedDateTime; // Use DateTime? to allow null

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Task'),
              maxLines: null,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedDateTime != null
                        ? TimeOfDay.fromDateTime(_selectedDateTime!)
                        : TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
              child: _selectedDateTime != null
                  ? Text('Selected Date and Time: ${DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDateTime!)}')
                  : Text('Select Date and Time of the Submission'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Check if title and task are not empty before adding task
                if (_titleController.text.isNotEmpty &&
                    _detailsController.text.isNotEmpty &&
                    _selectedDateTime != null) {
                  widget.onAddTask(
                    _titleController.text,
                    _detailsController.text,
                    _selectedDateTime!,
                  );
                }
              },
              child: Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}
