import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'task.dart';
import 'taskprovider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleTheme;

  TaskDetailsScreen({required this.task, required this.onToggleTheme});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TextEditingController _detailsController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.task.details.join('\n'));
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddDetailsAndDateDialog(context);
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing Details and Dates:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            _buildExistingDetailsAndDates(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveChanges(taskProvider);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingDetailsAndDates() {
    Provider.of<TaskProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.task.details.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail: ${widget.task.details[i]} - Date: ${DateFormat.yMd().add_jm().format(widget.task.submissionDateTimes[i])}',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDetailsAndDateDialog(context, i);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDetailsAndDateDialog(context, i);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showAddDetailsAndDateDialog(BuildContext context) async {
    TextEditingController detailsController = TextEditingController();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Details and Date'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: detailsController,
                    decoration: InputDecoration(labelText: 'Details'),
                    maxLines: null,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateTime != null
                                ? DateFormat.yMd().add_jm().format(_selectedDateTime!)
                                : 'Select Date and Time',
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (detailsController.text.isNotEmpty && _selectedDateTime != null) {
                      taskProvider.addTaskDetails(
                        widget.task.id,
                        detailsController.text,
                        _selectedDateTime!,
                      );

                      // Pass updated task back to TaskScreen
                      Task updatedTask = Task(
                        id: widget.task.id,
                        Subject: widget.task.Subject,
                        details: widget.task.details,
                        submissionDateTimes: widget.task.submissionDateTimes + [_selectedDateTime!], // Append new date
                      );

                      Navigator.of(context).pop(updatedTask); // Pass updated task back
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDetailsAndDateDialog(BuildContext context, int index) async {
    TextEditingController detailsController = TextEditingController(text: widget.task.details[index]);
    _selectedDateTime = widget.task.submissionDateTimes[index];

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Details and Date'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: detailsController,
                    decoration: InputDecoration(labelText: 'Details'),
                    maxLines: null,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateTime != null
                                ? DateFormat.yMd().add_jm().format(_selectedDateTime!)
                                : 'Select Date and Time',
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (detailsController.text.isNotEmpty && _selectedDateTime != null) {
                      taskProvider.editTaskDetails(
                        widget.task.id,
                        index,
                        detailsController.text,
                        _selectedDateTime!,
                      );

                      Navigator.of(context).pop(); // Close dialog
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDetailsAndDateDialog(BuildContext context, int index) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Details and Date'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                taskProvider.deleteTaskDetails(widget.task.id, index);
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _saveChanges(TaskProvider taskProvider) {
    taskProvider.editTask(
      widget.task.id,
      widget.task.Subject,
      widget.task.details,
      widget.task.submissionDateTimes,
    );
    Navigator.of(context).pop();
  }
}