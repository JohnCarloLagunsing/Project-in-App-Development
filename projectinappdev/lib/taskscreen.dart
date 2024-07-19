import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'task.dart';
import 'taskprovider.dart';
import 'taskdetailscreen.dart';
import 'addtaskscreen.dart';
import 'EditTaskScreen.dart'; // Import EditTaskScreen

class TaskScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  TaskScreen({required this.onToggleTheme});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String appBarTitle = 'Crampanion'; // Initial app bar title

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Sort tasks based on the nearest submission date
    taskProvider.tasks.sort((a, b) {
      DateTime? aNearestDate = a.submissionDateTimes.isNotEmpty
          ? a.submissionDateTimes.reduce((a, b) => a.isBefore(b) ? a : b)
          : null;
      DateTime? bNearestDate = b.submissionDateTimes.isNotEmpty
          ? b.submissionDateTimes.reduce((a, b) => a.isBefore(b) ? a : b)
          : null;

      if (aNearestDate == null) return 1;
      if (bNearestDate == null) return -1;
      return aNearestDate.compareTo(bNearestDate);
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center align the title
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(5.0, 5.0),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              DateTime? nearestDate = task.submissionDateTimes.isNotEmpty
                  ? task.submissionDateTimes.reduce((a, b) => a.isBefore(b) ? a : b)
                  : null;
              return TaskListItem(
                title: task.Subject,
                date: nearestDate,
                onDelete: () {
                  _showDeleteDialog(context, taskProvider, task);
                },
                onEdit: () {
                  _navigateToEditTaskScreen(context, taskProvider, task);
                },
                onEditTitle: (newTitle) {
                  setState(() {
                    task.Subject = newTitle; // Update the title locally in the list item
                  });
                },
                onTap: () async {
                  // Navigate to TaskDetailsScreen and handle updates
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        task: task,
                        onToggleTheme: widget.onToggleTheme,
                      ),
                    ),
                  ).then((updatedTask) {
                    if (updatedTask != null) {
                      // Handle updated task, if needed
                      taskProvider.updateTask(updatedTask);
                    }
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddTaskScreen(context, taskProvider);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddTaskScreen(BuildContext context, TaskProvider taskProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          onAddTask: (title, details, submissionDateTime) {
            taskProvider.addTask(title, details, submissionDateTime);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TaskProvider taskProvider, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
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
                taskProvider.deleteTask(task.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditTaskScreen(BuildContext context, TaskProvider taskProvider, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          task: task,
          onEditTask: (updatedTask) {
            // Handle edited task here
            taskProvider.updateTask(updatedTask);
          },
        ),
      ),
    );
  }
}

class TaskListItem extends StatefulWidget {
  final String title;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Function(String) onEditTitle; // Callback to edit title

  TaskListItem({
    required this.title,
    required this.date,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onEditTitle,
  });

  @override
  _TaskListItemState createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  late Timer _timer;
  bool _showRed = true;

  @override
  void initState() {
    super.initState();
    // Start the timer to toggle the red color
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _showRed = !_showRed;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate if the date is today or tomorrow
    bool isDueToday = widget.date != null && _isSameDay(widget.date!, DateTime.now());
    bool isDueTomorrow = widget.date != null && _isSameDay(widget.date!, DateTime.now().add(Duration(days: 1)));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: widget.date != null
            ? Text(
                'Date: ${DateFormat.yMd().add_jm().format(widget.date!)}',
                style: TextStyle(
                  color: (isDueToday || isDueTomorrow) ? (_showRed ? Colors.red : Colors.transparent) : null,
                  fontWeight: (isDueToday || isDueTomorrow) ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Call the edit title callback
                widget.onEditTitle(widget.title);
                widget.onEdit();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          ],
        ),
        onTap: widget.onTap,
      ),
    );
  }
}

