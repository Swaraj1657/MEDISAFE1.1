import 'package:flutter/material.dart';
import 'package:med_app/Pages/fileupload.dart';
import 'package:med_app/Pages/health_tracker_page.dart';
import 'package:med_app/Pages/prescrptions.dart';
import 'package:med_app/Pages/doctor_appointments.dart';
import 'package:med_app/Pages/healthNotes.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.monitor_heart,
      'title': 'Health Trackers & Measurements',
      'subtitle': 'Track vital signs, weight, blood pressure, etc.',
      'color': Colors.blue,
    },
    {
      'icon': Icons.folder_outlined,
      'title': 'Health Documents',
      'subtitle': 'Store and manage medical records',
      'color': Colors.orange,
    },
    {
      'icon': Icons.local_hospital,
      'title': 'Doctor Appointments',
      'subtitle': 'Schedule and manage doctor visits',
      'color': Colors.green,
    },
    {
      'icon': Icons.note_alt_outlined,
      'title': 'Health Notes',
      'subtitle': 'Keep track of symptoms and health diary',
      'color': Colors.purple,
    },
    {
      'icon': Icons.medication_outlined,
      'title': 'Prescriptions',
      'subtitle': 'View and manage prescriptions',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: feature['color'] as Color,
                  size: 28,
                ),
              ),
              title: Text(
                feature['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  feature['subtitle'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
              onTap: () {
                if (feature['title'] == 'Health Documents') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Fileupload()),
                  );
                }
                if (feature['title'] == 'Health Trackers & Measurements') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthTrackerPage(),
                    ),
                  );
                }
                if (feature['title'] == 'Prescriptions') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Prescrptions(),
                    ),
                  );
                }
                if (feature['title'] == 'Doctor Appointments') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorAppointmentsPage(),
                    ),
                  );
                }
                if (feature['title'] == 'Health Notes') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthNotes(),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}