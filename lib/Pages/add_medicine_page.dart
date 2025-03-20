import 'package:flutter/material.dart';
import 'package:med_app/config.dart';
import 'package:med_app/models/medicine.dart';
import 'package:med_app/widgets/llm_button.dart';
import 'medicine_schedule_page.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../models/medicine.dart';
// import 'medicine_schedule_page.dart';

class AddMedicinePage extends StatefulWidget {
  final int timeSlotIndex;
  final String timeSlotName;
  final DateTime date;

  const AddMedicinePage({
    super.key,
    required this.timeSlotIndex,
    required this.timeSlotName,
    required this.date,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _medicationNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Add Medicine for ${widget.timeSlotName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: () {
              // Validate and proceed to schedule page
              _proceedToSchedule();
            },
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time slot indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              children: [
                Icon(_getIconForTimeSlot(), color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  widget.timeSlotName,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // MED INFO header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            width: double.infinity,
            child: const Text(
              'MED INFO',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Divider
          const Divider(height: 1, color: Colors.grey),

          // Medication Name Input
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _medicationNameController,
                    decoration: const InputDecoration(
                      hintText: 'Medication Name',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _proceedToSchedule(),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Colors.grey),

          // Add the Groq LLM Button here
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy, // AI icon
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 15),

                Expanded(
                  child: GroqLLMButton(
                    apiKey:
                        Config.groqApiKey, // Replace with your actual API key
                  ),
                ),
              ],
            ),
          ),

          // Remaining form would go here
          Expanded(child: Container(color: const Color(0xFFF5F5F5))),
        ],
      ),
      // Bottom navigation bar implementation omitted for brevity
    );
  }

  void _proceedToSchedule() async {
    // Validate medication name
    if (_medicationNameController.text.trim().isEmpty) {
      // Show error message if medication name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medication name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to the schedule page and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicineSchedulePage(
              medicationName: _medicationNameController.text.trim(),
              timeSlotIndex: widget.timeSlotIndex,
              date: widget.date,
            ),
      ),
    );

    // If we got a result back (medicine object), pass it back to the schedule page
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  IconData _getIconForTimeSlot() {
    switch (widget.timeSlotIndex) {
      case 0:
        return Icons.wb_sunny_outlined; // Morning
      case 1:
        return Icons.wb_sunny; // Afternoon
      case 2:
        return Icons.cloud_outlined; // Evening
      case 3:
        return Icons.nightlight_outlined; // Night
      default:
        return Icons.medical_services_outlined; // General
    }
  }
}
