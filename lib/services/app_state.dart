import 'package:flutter/material.dart';

class AppTask {
  final String id;
  String title;
  String description;
  String deadline;
  bool isCompleted;
  bool isAiGenerated;
  List<Map<String, dynamic>> subTasks;

  AppTask({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
    this.isAiGenerated = false,
    required this.subTasks,
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  List<AppTask> tasks = [
    AppTask(
      id: "1",
      title: "Proyecto integrador",
      description: "Ajustar la arquitectura limpia y matrices de privilegios",
      deadline: "Viernes 18:00",
      isCompleted: false,
      isAiGenerated: false,
      subTasks: [],
    ),
  ];

  String currentMood = "Neutral";
  String aiRefugioPhrase = "Respira hondo, todo va a salir bien.";
  List<String> moodHistory = [];

  final ValueNotifier<int> updater = ValueNotifier<int>(0);
}