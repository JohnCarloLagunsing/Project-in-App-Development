class Task {
  final String id;
  String Subject;
  List<String> details;
  List<DateTime> submissionDateTimes;
  bool isDone;

  Task({
    required this.id,
    required this.Subject,
    required this.details,
    required this.submissionDateTimes,
    this.isDone = false,
  });
}
