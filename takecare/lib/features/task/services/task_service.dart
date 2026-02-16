import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:takecare/features/task/models/task_model.dart';

class TaskService {
  final String url = "http://10.0.2.2:3000/api";

  Future<List<Task>> getTasks(String familyId) async {
    try {
      final response = await http.get(
        Uri.parse('$url/tasks/family/$familyId')
      );

      if (response.statusCode == 200) {
        log('load tasks success: ${response.body}');
        final List<dynamic> data = jsonDecode(response.body);
        final List<Task> tasks = data.map((json) => Task.fromJson(json)).toList();
        return tasks;
      } else {
        log('Server Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to fetch tasks from server");
      }
    } catch (err) {
      throw Exception('Failed to call API: $err');
    }
  }


}