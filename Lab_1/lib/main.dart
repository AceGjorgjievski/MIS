import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true
      ),
      home: const Courses()
    );
  }
}


class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {

  List<String> courses = [
    "Тимски проект",
    "Веројатност и статистика",
    "Мобилни платформи и програмирање",
    "Мобилни информациски системи",
    "Веб-базирани системи"
  ];

  void addCourse() {
    showDialog(context: context, builder: (BuildContext context) {
      String newCourse = "";
      return AlertDialog(
        title: const Text('Add new course'),
        content: TextField(
          onChanged: (value){
            newCourse = value;
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if(newCourse.isNotEmpty) {
                setState(() {
                  courses.add(newCourse);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add')
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('201183'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Card (
            child: ListTile(
              title: Text(
                courses[index],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              trailing: Row (
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton (
                      onPressed: () {
                        setState(() {
                          courses.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline_rounded)
                  )
                ],
              ),
            ),
          );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: addCourse,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }
}




