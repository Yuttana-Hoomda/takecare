import 'package:flutter/material.dart';
import 'package:takecare/components/task_type_card.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded)),
        title: const Text('สร้างรายการใหม่'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelForm('ประเภทรายการ', context),
                  Row(
                    children: [
                      Expanded(child: TaskTypeCard(icon: Icons.medical_services, type: 'ยา', onTap: (){})),
                      Expanded(child: TaskTypeCard(icon: Icons.medical_services, type: 'ยา', onTap: (){})),
                      Expanded(child: TaskTypeCard(icon: Icons.medical_services, type: 'ยา', onTap: (){})),
                    ],
                  ),
                  _labelForm('ชื่อรายการ', context),
                  const SizedBox(height: 6,),
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
                          width: 1
                        )
                      )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16,),
                  _labelForm('วันเวลา', context),
                  const SizedBox(height: 16,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50)
                      ),
                      onPressed: () {},
                      child: Text('สร้างรายการ')
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _labelForm(String label, BuildContext context) {
  return Text(
    label,
    style: Theme.of(context).textTheme.titleMedium,
  );
}
