import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exam_schedule_calendar.dart';
import 'login_screen.dart';

enum ExamType { midTerm, examSession }

class ExamSchedule extends StatefulWidget {
  ExamSchedule({
    Key? key,
    required this.subjectName,
    this.examType = ExamType.midTerm,
    required DateTime? dateTime,
  })  : date = dateTime!,
        time = TimeOfDay.fromDateTime(dateTime),
        super(key: key);

  final String? subjectName;
  final ExamType? examType;
  final DateTime date;
  final TimeOfDay time;

  String get formattedDateTime {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String formattedTime = '${time.hour}:${time.minute}';

    return '$formattedDate - $formattedTime';
  }


  @override
  State<ExamSchedule> createState() => _ExamScheduleState();

}


class _ExamScheduleState extends State<ExamSchedule> {
  List<ExamSchedule> examSchedules = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isLoggedIn = false;

  List<ExamSchedule> get getExamSchedules => examSchedules;


  @override
  void initState() {
    super.initState();
    _updateAuthState();
    examSchedules = _initializeSubjects();

  }

  List<ExamSchedule> _initializeSubjects() {
    DateTime now = DateTime.now();

    // Calculate exam times based on the current date and time
    DateTime mathExamTime = now.add(Duration(minutes: 1));
    DateTime scienceExamTime = now.add(Duration(minutes: 2));
    DateTime englishExamTime = now.add(Duration(minutes: 3));
    return [
      ExamSchedule(
        subjectName: "Calculus 1",
        examType: ExamType.midTerm,
        dateTime: mathExamTime,
      ),
      ExamSchedule(
        subjectName: "Probability and Statistics",
        examType: ExamType.examSession,
        dateTime: scienceExamTime,
      ),
      ExamSchedule(
        subjectName: "Algorithms and Data Structures",
        examType: ExamType.midTerm,
        dateTime: englishExamTime,
      ),
    ];
  }

  void _updateAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
  }

  Future<void> addExamSchedule() async {
    Completer<void> completer = Completer<void>();
    TextEditingController subjectController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    ExamType? examType;
    DateTime? date;
    TimeOfDay? timeOfDate;

    String subjectError = '';
    String dateError = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Add New Exam Schedule:',
                style: TextStyle(fontSize: 18),
              ),
              content: SizedBox(
                height: 250,
                width: 250,
                child: Column(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Name Of The Exam',
                        ),
                        onChanged: (value) {
                          setState(() {
                            subjectError = '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the name of the exam';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (subjectError.isNotEmpty)
                      Center(
                        child: Text(
                          subjectError,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(
                      height: 2,
                    ),
                    Expanded(
                      child: DropdownButtonFormField<ExamType>(
                        value: ExamType.midTerm,
                        onChanged: (ExamType? value) {
                          setState(() {
                            examType = value;
                          });
                        },
                        items: ExamType.values.map((ExamType value) {
                          return DropdownMenuItem<ExamType>(
                            value: value,
                            child: Text(value == ExamType.midTerm
                                ? "Mid-term"
                                : "Exam Session"),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Exam Type',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedDate != null && selectedTime != null) {
                          setState(() {
                            date = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            timeOfDate = TimeOfDay.fromDateTime(date!);
                            dateController.text =
                                DateFormat('yyyy-MM-dd HH:mm').format(date!);
                            dateError = '';
                          });
                        }
                      },
                      child: const Text('Select Date and Time'),
                    ),
                    if (dateError.isNotEmpty)
                      Center(
                        child: Text(
                          dateError,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      dateController.text.isNotEmpty
                          ? 'Selected Date and Time: ${dateController.text}'
                          : '',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (subjectController.text.isNotEmpty) {
                      setState(() {
                        subjectError = '';
                      });
                      if (date != null) {
                        setState(() {
                          dateError = '';
                          examSchedules = List.from(examSchedules)
                            ..add(
                              ExamSchedule(
                                subjectName: subjectController.text,
                                dateTime: date,
                                examType: examType,
                              ),
                            );
                        });
                        Navigator.of(context).pop();
                        completer.complete();
                      } else {
                        setState(() {
                          dateError = 'Please select a date and time';
                        });
                      }
                    } else {
                      setState(() {
                        subjectError = 'Subject field cannot be empty';
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text('Exam Schedule'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                if (isLoggedIn) {
                  await addExamSchedule();

                  setState(() {});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(Icons.add_box_sharp),
            )
          ],
          backgroundColor: Colors.cyan[300],
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLoggedIn
                      ? 'Logged In With: ${_firebaseAuth.currentUser?.email}'
                      : 'No user logged in',
                ),
                if (isLoggedIn)
                  TextButton(
                    onPressed: () {
                      _firebaseAuth.signOut();
                      print("logged out");
                      setState(() {
                        isLoggedIn = false;
                      });
                    },
                    child: const Text('Logout'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.cyan[300]!,
                      ),
                    ),
                  ),
                if (!isLoggedIn)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.cyan[300]!,
                      ),
                    ),
                  ),
              ],
            ),
            if (!isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Show exam schedule'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.cyan[300]!,
                )),
              ),
            if (isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExamScheduleCalendar(
                          examSchedules: examSchedules,
                        )),
                  );
                },
                child: const Text('Show exam schedule'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.cyan[300]!,
                )),
              ),
            Expanded(
              child: GridView.builder(
                itemCount: examSchedules.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  ExamSchedule examSchedule = examSchedules[index];
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              examSchedule.subjectName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Date: ${examSchedule.date.day} - ${examSchedule.date.month} - ${examSchedule.date.year}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Time: ${examSchedule.time.format(context)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            const Text(
                              'Exam Type: ',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              softWrap: true,
                            ),
                            Text(
                              examSchedule.examType == ExamType.midTerm
                                  ? 'Mid-term'
                                  : 'Exam Session',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                              softWrap: true,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
