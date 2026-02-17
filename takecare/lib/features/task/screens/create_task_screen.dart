import 'package:flutter/material.dart';
import 'package:takecare/features/task/screens/frequency_setting.dart';
import 'package:takecare/features/task/screens/task_icon_picker.dart';

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
  String dropdownValue = freqList.first;
  List<int> selectedDay = [];
  int selectIcon = 0;

  void _onSelectedDay(int index) {
    setState(() {
      if (selectedDay.contains(index)) {
        selectedDay.remove(index);
      } else {
        selectedDay.add(index);
      }
    });
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
                  selectedIcon: selectIcon,
                  onTapIcon: (int index) {
                    setState(() {
                      selectIcon = index;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _labelForm('ชื่อรายการ', context),
                const SizedBox(height: 6),
                TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
                const SizedBox(height: 16),
                FrequencySetting(
                    currentValue: dropdownValue,
                    frequencyOptions: freqList,
                    onChanged: (String? newValue) {
                      if(newValue != null) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      }
                    },
                  selectedDays: selectedDay,
                  onDayTapped: _onSelectedDay,
                ),

                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save action here
                    }
                  },
                  child: const Text('สร้างรายการ'),
                ),
              ],
            ),
          ),
        ),
      ), // ✅ Perfectly closed all brackets and added final semicolon
    );
  }
}

Widget _labelForm(String label, BuildContext context) {
  return Text(
    label,
    style: Theme.of(context).textTheme.titleMedium,
  );
}