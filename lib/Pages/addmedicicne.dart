import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Medicine Model
class Medicine {
  final String name;
  final int quantity;
  final String dosage;
  final int dosesPerDay;
  final DateTime startDate;
  final DateTime expiryDate;

  Medicine({
    required this.name,
    required this.quantity,
    required this.dosage,
    required this.dosesPerDay,
    required this.startDate,
    required this.expiryDate,
  });

  int get daysRemaining {
    return quantity ~/ dosesPerDay;
  }
}

class MedicineTrackerScreen extends StatefulWidget {
  const MedicineTrackerScreen({super.key});

  @override
  State<MedicineTrackerScreen> createState() => _MedicineTrackerScreenState();
}

class _MedicineTrackerScreenState extends State<MedicineTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dosageController = TextEditingController();
  final _dosesPerDayController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  List<Medicine> medicines = [];

  int _calculateDaysRemaining() {
    if (_quantityController.text.isEmpty ||
        _dosesPerDayController.text.isEmpty) {
      return 0;
    }
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final dosesPerDay = int.tryParse(_dosesPerDayController.text) ?? 1;
    return quantity ~/ dosesPerDay;
  }

  void _updateExpiryDate() {
    final daysRemaining = _calculateDaysRemaining();
    setState(() {
      _expiryDate = _startDate.add(Duration(days: daysRemaining));
    });
  }

  void _addMedicine() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        medicines.add(
          Medicine(
            name: _nameController.text,
            quantity: int.parse(_quantityController.text),
            dosage: _dosageController.text,
            dosesPerDay: int.parse(_dosesPerDayController.text),
            startDate: _startDate,
            expiryDate: _expiryDate,
          ),
        );
      });
      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _quantityController.clear();
    _dosageController.clear();
    _dosesPerDayController.clear();
    setState(() {
      _startDate = DateTime.now();
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _dosageController.dispose();
    _dosesPerDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Medicine Tracker',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFBBDEFB).withOpacity(0.3), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Medicine',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Medicine Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.medication),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medicine name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Quantity (pills)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.numbers),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter quantity';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) => _updateExpiryDate(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _dosageController,
                                decoration: InputDecoration(
                                  labelText: 'Dosage (mg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.scale),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter dosage';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dosesPerDayController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Doses per Day',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter doses per day';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          onChanged: (value) => _updateExpiryDate(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _startDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _startDate = picked;
                                          _updateExpiryDate();
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expiry Date (Calculated)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.event),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addMedicine,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Medicine',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Medicines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        medicine.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Dosage: ${medicine.dosage}'),
                          Text('Quantity: ${medicine.quantity} pills'),
                          Text('Doses per day: ${medicine.dosesPerDay}'),
                          Text('Days remaining: ${medicine.daysRemaining}'),
                          Text(
                            'Expires on: ${medicine.expiryDate.day}/${medicine.expiryDate.month}/${medicine.expiryDate.year}',
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            medicines.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const MedicineTrackerScreen(),
    );
  }
}
