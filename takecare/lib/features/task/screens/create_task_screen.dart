import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/task/screens/frequency_setting.dart';
import 'package:takecare/features/task/screens/task_icon_picker.dart';

import '../../../constants/app_theme.dart';
import '../providers/task_provider.dart';

const List<String> freqList = ['สัปดาห์', 'วัน'];
const List<String> icons = [
  'assets/medicine.svg',
  'assets/doctor.svg',
  'assets/task.svg',
];

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<int> selectedDay = [];
  int selectedIcon = 0;
  String selectedDate = '';
  TimeOfDay? selectedTime;
  bool isRequiredPhoto = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSelectedDay(int index) {
    setState(() {
      if (selectedDay.contains(index)) {
        selectedDay.remove(index);
      } else {
        selectedDay.add(index);
        selectedDate = '';
      }
    });
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        String year = pickedDate.year.toString();
        String month = pickedDate.month.toString().padLeft(2, '0');
        String day = pickedDate.day.toString().padLeft(2, '0');
        selectedDate = "$year-$month-$day";
        selectedDay.clear();

        debugPrint(selectedDate);
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกเวลา (Please select a time)')),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ (User not found)')),
      );
      return;
    }

    try {
      final newTask = Task(
        taskId: '',
        createdBy: user.uid,
        familyId: user.familyId ?? '',
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        time: selectedTime!,
        date: selectedDate.isNotEmpty ? selectedDate : null,
        repeatDays: selectedDay,
        isRequiredPhoto: isRequiredPhoto,
        icon: icons[selectedIcon],
        createdAt: DateTime.now(),
      );

      await Provider.of<TaskProvider>(context, listen: false).createTask(newTask);
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('สร้างรายการใหม่'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelForm('ไอคอน', context),
                TaskIconPicker(
                  icons: icons,
                  selectedIcon: selectedIcon,
                  onTapIcon: (int index) {
                    setState(() {
                      selectedIcon = index;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _labelForm('ชื่อรายการ', context),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FrequencySetting(
                  selectedDays: selectedDay,
                  onDayTapped: _onSelectedDay,
                  selectedDate: selectedDate,
                  onSelectDate: _pickDate,
                  selectedTime: selectedTime,
                  onSelectTime: _pickTime,
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondary,
                        ),
                        child: const Icon(Icons.photo_camera_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('รูปภาพ'),
                            const Text('ถ่ายรูปเพื่อบันทึกรายการ'),
                          ],
                        ),
                      ),
                      Switch(
                        value: isRequiredPhoto,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            isRequiredPhoto = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _labelForm('หมายเหตุ', context),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide.none, // <-- This makes it invisible
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                  validator: (value) => null,
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _createTask,
                  child: const Text('สร้างรายการ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _labelForm(String label, BuildContext context) {
  return Text(label, style: Theme.of(context).textTheme.titleMedium);
}
