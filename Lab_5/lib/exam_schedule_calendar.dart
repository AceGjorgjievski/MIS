import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'exam_schedule.dart';
import 'notification_service.dart';

// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class ExamScheduleCalendar extends StatefulWidget {
  final List<ExamSchedule> examSchedules;

  ExamScheduleCalendar({Key? key, required this.examSchedules})
      : super(key: key);

  List<ExamSchedule> get getExamSchedules => examSchedules;

  @override
  State<ExamScheduleCalendar> createState() => _ExamScheduleCalendarState();
}

class _ExamScheduleCalendarState extends State<ExamScheduleCalendar> {
  Map<DateTime, List<ExamSchedule>>? selectedExams;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();

  Map<int, bool> buttonClickedMap = {};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    selectedExams = {};
    List<ExamSchedule> manualExams = widget.getExamSchedules;
    for (ExamSchedule exam in manualExams) {
      DateTime dateKey =
          DateTime(exam.date.year, exam.date.month, exam.date.day);
      if (selectedExams![dateKey] != null) {
        selectedExams![dateKey]!.add(exam);
      } else {
        selectedExams![dateKey] = [exam];
      }
    }
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
          if (!isAllowed)
            {AwesomeNotifications().requestPermissionToSendNotifications()}
        });
    await NotificationServices.initializeNotification();
  }

  List<ExamSchedule> _getExamsFromDay(DateTime date) {
    DateTime dateKey = DateTime(date.year, date.month, date.day);
    return selectedExams?[dateKey] ?? [];
  }

  void _scheduleNotification(ExamSchedule exam) {
    // final int notificationId = widget.getExamSchedules.indexOf(exam);
    //
    // // tz.initializeTimeZones();
    //
    // final scheduledDateTime = tz.TZDateTime.from(
    //   exam.date,
    //   tz.local, // Use the local time zone
    // );
    //
    //
    // AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: notificationId,
    //     channelKey: "basic_channel",
    //     title: exam.subjectName,
    //     body: "You have an exam tomorrow!",
    //   ),
    //   schedule: NotificationCalendar(
    //     day: scheduledDateTime.day,
    //     month: scheduledDateTime.month,
    //     year: scheduledDateTime.year,
    //     hour: scheduledDateTime.hour,
    //     minute: scheduledDateTime.minute,
    //     timeZone: scheduledDateTime.timeZoneName,
    //   ),
    // );

    NotificationServices.scheduleNotification(schedule: exam);
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Calendar & Notification"),
        centerTitle: true,
        backgroundColor: Colors.cyan[300],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
              print(focusedDay);
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
            eventLoader: _getExamsFromDay,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          ..._getExamsFromDay(selectedDay).asMap().entries.map(
                (MapEntry<int, ExamSchedule> entry) {
              int index = entry.key;
              ExamSchedule examSchedule = entry.value;
              bool isButtonClicked = buttonClickedMap[index] ?? false;

              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        examSchedule.subjectName! +
                            '\n${examSchedule.formattedDateTime}',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _scheduleNotification(examSchedule);
                        setState(() {
                          buttonClickedMap[index] = !isButtonClicked;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isButtonClicked
                              ? Colors.red[300]!
                              : Colors.cyan[300]!,
                        ),
                      ),
                      child: const Text('Schedule notification'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Text(
              'If you are using virtual device \nthere is a delay in seconds when \nyou schedule multiple exams.')
        ],
      ),
    );
  }
}
