import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTrackerPage extends StatefulWidget {
  const HealthTrackerPage({super.key});

  @override
  State<HealthTrackerPage> createState() => _HealthTrackerPageState();
}

class _HealthTrackerPageState extends State<HealthTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences _prefs;

  // Health Data
  double? height; // in cm
  double? weight; // in kg
  int? heartRate;
  String bloodGroup = 'A+';
  List<String> medicalConditions = [];
  double? bmi;
  String bmiStatus = '';

  // Controllers
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _conditionController = TextEditingController();

  // Blood Group Options
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      height = _prefs.getDouble('height');
      weight = _prefs.getDouble('weight');
      heartRate = _prefs.getInt('heartRate');
      bloodGroup = _prefs.getString('bloodGroup') ?? 'A+';
      medicalConditions = _prefs.getStringList('medicalConditions') ?? [];

      // Update controllers with saved values
      if (height != null) _heightController.text = height.toString();
      if (weight != null) _weightController.text = weight.toString();
      if (heartRate != null) _heartRateController.text = heartRate.toString();

      // Calculate BMI if height and weight are available
      if (height != null && weight != null) {
        calculateBMI();
      }
    });
  }

  Future<void> _saveHealthData({bool showMessage = false}) async {
    await _prefs.setDouble('height', height ?? 0.0);
    await _prefs.setDouble('weight', weight ?? 0.0);
    await _prefs.setInt('heartRate', heartRate ?? 0);
    await _prefs.setString('bloodGroup', bloodGroup);
    await _prefs.setStringList('medicalConditions', medicalConditions);

    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Health data saved successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void calculateBMI() {
    if (height != null && weight != null) {
      // BMI = weight(kg) / (height(m))²
      double heightInMeters = height! / 100;
      bmi = weight! / (heightInMeters * heightInMeters);

      // Determine BMI Status
      if (bmi! < 18.5) {
        bmiStatus = 'Underweight';
      } else if (bmi! < 25) {
        bmiStatus = 'Normal';
      } else if (bmi! < 30) {
        bmiStatus = 'Overweight';
      } else {
        bmiStatus = 'Obese';
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade500],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Health Trackers',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Measurements Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.blue.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Basic Measurements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Height (cm)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(Icons.height),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      height = double.tryParse(value);
                                      calculateBMI();
                                      _saveHealthData(showMessage: false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Weight (kg)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(Icons.line_weight),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      weight = double.tryParse(value);
                                      calculateBMI();
                                      _saveHealthData(showMessage: false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BMI Results Card
                  if (bmi != null)
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getBMIGradientColors(),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getBMIIcon(),
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'BMI Results',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'BMI: ${bmi!.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                bmiStatus,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getBMIMessage(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Vital Signs Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.blue.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Vital Signs',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _heartRateController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Heart Rate (bpm)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(
                                  Icons.favorite,
                                  color: Colors.red.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                heartRate = int.tryParse(value);
                                setState(() {});
                                _saveHealthData(showMessage: false);
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: bloodGroup,
                              decoration: InputDecoration(
                                labelText: 'Blood Group',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(
                                  Icons.bloodtype,
                                  color: Colors.red.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items:
                                  bloodGroups.map((String group) {
                                    return DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(group),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  bloodGroup = newValue!;
                                  _saveHealthData(showMessage: false);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical Conditions Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.blue.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Medical Conditions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _conditionController,
                                    decoration: InputDecoration(
                                      labelText: 'Add Medical Condition',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.medical_services,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_conditionController
                                          .text
                                          .isNotEmpty) {
                                        setState(() {
                                          medicalConditions.add(
                                            _conditionController.text,
                                          );
                                          _conditionController.clear();
                                          _saveHealthData(showMessage: false);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  medicalConditions.map((condition) {
                                    return Chip(
                                      label: Text(condition),
                                      backgroundColor: Colors.blue.shade100,
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          medicalConditions.remove(condition);
                                          _saveHealthData(showMessage: false);
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveHealthData(showMessage: true);
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  List<Color> _getBMIGradientColors() {
    switch (bmiStatus) {
      case 'Normal':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'Underweight':
        return [Colors.orange.shade400, Colors.orange.shade600];
      case 'Overweight':
        return [Colors.orange.shade400, Colors.orange.shade600];
      default:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  IconData _getBMIIcon() {
    switch (bmiStatus) {
      case 'Normal':
        return Icons.check_circle;
      case 'Underweight':
        return Icons.warning;
      case 'Overweight':
        return Icons.warning;
      default:
        return Icons.error;
    }
  }

  String _getBMIMessage() {
    switch (bmiStatus) {
      case 'Normal':
        return 'Your BMI is within the healthy range!';
      case 'Underweight':
        return 'Consider consulting a healthcare provider about healthy weight gain.';
      case 'Overweight':
        return 'Consider lifestyle changes for a healthier BMI range.';
      default:
        return 'Please consult a healthcare provider about weight management.';
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    _conditionController.dispose();
    super.dispose();
  }
}
