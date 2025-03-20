import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late SharedPreferences _prefs;
  final _formKey = GlobalKey<FormState>();

  // Health Data
  String? _name;
  int? _age;
  String? _gender;
  String? _phoneNumber;
  String? _emergencyContact;
  String? _address;
  String? _allergies;
  String? _currentMedications;
  String? _bloodGroup;
  double? _height; // in cm
  double? _weight; // in kg
  double? _bmi;
  String _bmiStatus = '';
  String _bmiMessage = '';

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _addressController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Options
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
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
      _name = _prefs.getString('name');
      _age = _prefs.getInt('age');
      _gender = _prefs.getString('gender') ?? _genders[0];
      _phoneNumber = _prefs.getString('phoneNumber');
      _emergencyContact = _prefs.getString('emergencyContact');
      _address = _prefs.getString('address');
      _allergies = _prefs.getString('allergies');
      _currentMedications = _prefs.getString('currentMedications');
      _bloodGroup = _prefs.getString('bloodGroup') ?? _bloodGroups[0];
      _height = _prefs.getDouble('height');
      _weight = _prefs.getDouble('weight');

      // Update controllers with saved values
      if (_name != null) _nameController.text = _name!;
      if (_age != null) _ageController.text = _age.toString();
      if (_phoneNumber != null) _phoneController.text = _phoneNumber!;
      if (_emergencyContact != null)
        _emergencyController.text = _emergencyContact!;
      if (_address != null) _addressController.text = _address!;
      if (_allergies != null) _allergiesController.text = _allergies!;
      if (_currentMedications != null)
        _medicationsController.text = _currentMedications!;
      if (_height != null) _heightController.text = _height.toString();
      if (_weight != null) _weightController.text = _weight.toString();

      calculateBMI();
    });
  }

  Future<void> _saveHealthData({bool showMessage = false}) async {
    await _prefs.setString('name', _name ?? '');
    await _prefs.setInt('age', _age ?? 0);
    await _prefs.setString('gender', _gender ?? _genders[0]);
    await _prefs.setString('phoneNumber', _phoneNumber ?? '');
    await _prefs.setString('emergencyContact', _emergencyContact ?? '');
    await _prefs.setString('address', _address ?? '');
    await _prefs.setString('allergies', _allergies ?? '');
    await _prefs.setString('currentMedications', _currentMedications ?? '');
    await _prefs.setString('bloodGroup', _bloodGroup ?? _bloodGroups[0]);
    await _prefs.setDouble('height', _height ?? 0.0);
    await _prefs.setDouble('weight', _weight ?? 0.0);

    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Health information saved successfully!'),
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
    if (_height != null && _weight != null) {
      // BMI = weight(kg) / (height(m))²
      double heightInMeters = _height! / 100;
      _bmi = _weight! / (heightInMeters * heightInMeters);

      // Determine BMI Status
      if (_bmi! < 18.5) {
        _bmiStatus = 'Underweight';
        _bmiMessage =
            'Consider consulting a healthcare provider about healthy weight gain.';
      } else if (_bmi! < 25) {
        _bmiStatus = 'Normal';
        _bmiMessage = 'Your BMI is within the healthy range!';
      } else if (_bmi! < 30) {
        _bmiStatus = 'Overweight';
        _bmiMessage = 'Consider lifestyle changes for a healthier BMI range.';
      } else {
        _bmiStatus = 'Obese';
        _bmiMessage =
            'Please consult a healthcare provider about weight management.';
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
                          Icons.person_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Personal Health Information',
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

                  // Personal Information Card
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
                                Icon(Icons.person, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _name = value;
                                _saveHealthData(showMessage: false);
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Age',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    onChanged: (value) {
                                      _age = int.tryParse(value);
                                      _saveHealthData(showMessage: false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _gender,
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(Icons.people),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    items:
                                        _genders.map((String gender) {
                                          return DropdownMenuItem<String>(
                                            value: gender,
                                            child: Text(gender),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _gender = newValue;
                                        _saveHealthData(showMessage: false);
                                      });
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

                  // Physical Measurements Card
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
                                  'Physical Measurements',
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
                                      _height = double.tryParse(value);
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
                                      _weight = double.tryParse(value);
                                      calculateBMI();
                                      _saveHealthData(showMessage: false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _bloodGroup,
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
                                  _bloodGroups.map((String group) {
                                    return DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(group),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _bloodGroup = newValue;
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

                  // BMI Results Card
                  if (_bmi != null)
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                'BMI: ${_bmi!.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _bmiStatus,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _bmiMessage,
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

                  // Contact Information Card
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
                                  Icons.contact_phone,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _phoneNumber = value;
                                _saveHealthData(showMessage: false);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emergencyController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Emergency Contact',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.emergency),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _emergencyContact = value;
                                _saveHealthData(showMessage: false);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _address = value;
                                _saveHealthData(showMessage: false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical Information Card
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
                                  'Medical Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _allergiesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Allergies',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.warning),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _allergies = value;
                                _saveHealthData(showMessage: false);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _medicationsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Current Medications',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.medication),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                _currentMedications = value;
                                _saveHealthData(showMessage: false);
                              },
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
    switch (_bmiStatus) {
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
    switch (_bmiStatus) {
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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
