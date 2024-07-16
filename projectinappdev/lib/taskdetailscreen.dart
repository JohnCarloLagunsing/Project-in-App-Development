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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail: ${widget.task.details[i]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(widget.task.submissionDateTimes[i])}',
                        style: TextStyle(
                          color: _isDueTodayOrTomorrow(widget.task.submissionDateTimes[i]) ? Colors.red : null,
                          fontWeight: _isDueTodayOrTomorrow(widget.task.submissionDateTimes[i]) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
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

  bool _isDueTodayOrTomorrow(DateTime dateTime) {
    DateTime now = DateTime.now();
    return _isSameDay(dateTime, now) || _isSameDay(dateTime, now.add(Duration(days: 1)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void _showAddDetailsAndDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Details and Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _detailsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Details'),
              ),
              SizedBox(height: 10),
              TextButton(
                child: Text(_selectedDateTime == null
                    ? 'Select Submission Date and Time'
                    : 'Change Submission Date and Time: ${DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDateTime!)}'),
                onPressed: () {
                  _pickDateAndTime(context);
                },
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
                _saveDetailsAndDate(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _pickDateAndTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (timePicked != null) {
        setState(() {
          _selectedDateTime = DateTime(picked.year, picked.month, picked.day, timePicked.hour, timePicked.minute);
        });
      }
    }
  }

  void _saveDetailsAndDate(BuildContext context) {
    if (_detailsController.text.isNotEmpty && _selectedDateTime != null) {
      setState(() {
        widget.task.details.add(_detailsController.text);
        widget.task.submissionDateTimes.add(_selectedDateTime!);
      });
      Navigator.of(context).pop();
    }
  }

  void _showEditDetailsAndDateDialog(BuildContext context, int index) {
    _detailsController.text = widget.task.details[index];
    _selectedDateTime = widget.task.submissionDateTimes[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Details and Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _detailsController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Details'),
              ),
              SizedBox(height: 10),
              TextButton(
                child: Text(_selectedDateTime == null
                    ? 'Select Submission Date and Time'
                    : 'Change Submission Date and Time: ${DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDateTime!)}'),
                onPressed: () {
                  _pickDateAndTime(context);
                },
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
                _editDetailsAndDate(context, index);
              },
            ),
          ],
        );
      },
    );
  }

  void _editDetailsAndDate(BuildContext context, int index) {
    if (_detailsController.text.isNotEmpty && _selectedDateTime != null) {
      setState(() {
        widget.task.details[index] = _detailsController.text;
        widget.task.submissionDateTimes[index] = _selectedDateTime!;
      });
      Navigator.of(context).pop();
    }
  }

  void _showDeleteDetailsAndDateDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Detail and Date'),
          content: Text('Are you sure you want to delete this detail and date?'),
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
                _deleteDetailsAndDate(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDetailsAndDate(int index) {
    setState(() {
      widget.task.details.removeAt(index);
      widget.task.submissionDateTimes.removeAt(index);
    });
  }

  void _saveChanges(TaskProvider taskProvider) {
    taskProvider.updateTask(widget.task);
    Navigator.of(context).pop(widget.task);
  }
}
