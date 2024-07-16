import 'package:flutter/material.dart';
import 'task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title, String details, DateTime submissionDateTime) {
    final task = Task(
      id: DateTime.now().toString(),
      Subject: title,
      details: [details],
      submissionDateTimes: [submissionDateTime],
    );
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void addTaskDetails(String id, String newDetails, DateTime newSubmissionDateTime) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.details.add(newDetails);
    task.submissionDateTimes.add(newSubmissionDateTime);
    notifyListeners();
  }

  void editTask(String id, String newTitle, List<String> newDetails, List<DateTime> newSubmissionDateTimes) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.Subject = newTitle;
    task.details = newDetails;
    task.submissionDateTimes = newSubmissionDateTimes;
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void editTaskDetails(String id, int index, String text, DateTime dateTime) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.details[index] = text;
    task.submissionDateTimes[index] = dateTime;
    notifyListeners();
  }

  void deleteTaskDetails(String id, int index) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.details.removeAt(index);
    task.submissionDateTimes.removeAt(index);
    notifyListeners();
  }

  void updatedTask(String id, List<String> split) {}
}
