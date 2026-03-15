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

class TaskFormScreen extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormScreen({super.key, this.taskToEdit});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<int> selectedDay = [];
  int selectedIcon = 0;
  String selectedDate = '';
  TimeOfDay? selectedTime;
  bool requirePhoto = false;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _initializeFormData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }


  void _initializeFormData() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _noteController.text = task.note ?? '';
    selectedDay = List<int>.from(task.repeatDays ?? []);
    selectedDate = task.date ?? '';
    selectedTime = task.time;
    requirePhoto = task.requirePhoto ?? false;

    int iconIndex = icons.indexOf(task.icon);
    selectedIcon = iconIndex != -1 ? iconIndex : 0;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleDaySelection(int index) {
    setState(() {
      if (selectedDay.contains(index)) {
        selectedDay.remove(index);
      } else {
        selectedDay.add(index);
        selectedDate = '';
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isEditing && selectedDate.isNotEmpty
          ? DateTime.parse(selectedDate)
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        selectedDay.clear();
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedTime == null) return _showMessage('กรุณาเลือกเวลา (Please select a time)');

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return _showMessage('ไม่พบข้อมูลผู้ใช้ (User not found)');

    try {
      final taskData = Task(
        taskId: isEditing ? widget.taskToEdit!.taskId : '',
        createdBy: isEditing ? widget.taskToEdit!.createdBy : user.uid,
        familyId: isEditing ? widget.taskToEdit!.familyId : (user.familyId ?? ''),
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        time: selectedTime!,
        date: selectedDate.isNotEmpty ? selectedDate : null,
        repeatDays: selectedDay,
        requirePhoto: requirePhoto,
        icon: icons[selectedIcon],
        createdAt: isEditing ? widget.taskToEdit!.createdAt : DateTime.now(),
      );

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (isEditing) {
        await taskProvider.updateTask(taskData);
      } else {
        await taskProvider.createTask(taskData);
      }

      if (mounted) Navigator.pop(context);

    } catch (e) {
      _showMessage('เกิดข้อผิดพลาด: $e');
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
        title: Text(isEditing ? 'แก้ไขรายการ' : 'สร้างรายการใหม่'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('ไอคอน'),
                _buildIconPicker(),
                const SizedBox(height: 20),

                _buildSectionLabel('ชื่อรายการ'),
                _buildTextField(_titleController, 'ชื่อรายการ', isRequired: true),
                const SizedBox(height: 20),

                _buildFrequencySettings(),
                const SizedBox(height: 20),

                _buildPhotoRequirementToggle(),
                const SizedBox(height: 20),

                _buildSectionLabel('หมายเหตุ'),
                _buildTextField(_noteController, 'หมายเหตุ', maxLines: 3),
                const SizedBox(height: 32),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildIconPicker() {
    return TaskIconPicker(
      icons: icons,
      selectedIcon: selectedIcon,
      onTapIcon: (int index) => setState(() => selectedIcon = index),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isRequired = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
        if (isRequired && (value == null || value.isEmpty)) {
          return 'กรุณากรอก$hint'; // "Please enter [hint]"
        }
        return null;
      },
    );
  }

  Widget _buildFrequencySettings() {
    return FrequencySetting(
      selectedDays: selectedDay,
      onDayTapped: _toggleDaySelection,
      selectedDate: selectedDate,
      onSelectDate: _pickDate,
      selectedTime: selectedTime,
      onSelectTime: _pickTime,
    );
  }

  Widget _buildPhotoRequirementToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รูปภาพ'),
                Text('ถ่ายรูปเพื่อบันทึกรายการ'),
              ],
            ),
          ),
          Switch(
            value: requirePhoto,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (bool value) => setState(() => requirePhoto = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: _saveTask,
      child: Text(
          isEditing ? 'อัปเดตรายการ' : 'สร้างรายการ',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 18),
      ),
    );
  }
}