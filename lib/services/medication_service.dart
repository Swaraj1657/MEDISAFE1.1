import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/medication_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicationService extends ChangeNotifier {
  // Singleton instance
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  List<Medicine> _medications = [];
  final String _storageKey = 'medications';
  bool _isInitialized = false;

  // Initialize the service and load saved medications
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadMedications();
    _isInitialized = true;
  }

  // Load medications from storage
  Future<void> _loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getStringList(_storageKey) ?? [];
      _medications =
          medicationsJson.map((json) => _medicineFromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading medications: $e');
      _medications = [];
    }
  }

  // Save medications to storage
  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson =
          _medications.map((med) => _medicineToJson(med)).toList();
      await prefs.setStringList(_storageKey, medicationsJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving medications: $e');
    }
  }

  // Convert Medicine to JSON string
  String _medicineToJson(Medicine medicine) {
    return jsonEncode({
      'name': medicine.name,
      'timeSlotIndex': medicine.timeSlotIndex,
      'startDate': medicine.startDate.toIso8601String(),
      'endDate': medicine.endDate?.toIso8601String(),
      'doseHistory': medicine.doseHistory,
      'frequency': medicine.frequency,
      'timesPerDay': medicine.timesPerDay,
      'time':
          medicine.time != null
              ? {'hour': medicine.time!.hour, 'minute': medicine.time!.minute}
              : null,
      'dosage': medicine.dosage,
    });
  }

  // Convert JSON string to Medicine
  Medicine _medicineFromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Medicine(
      name: json['name'],
      timeSlotIndex: json['timeSlotIndex'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      doseHistory: Map<String, bool>.from(json['doseHistory'] ?? {}),
      frequency: json['frequency'],
      timesPerDay: json['timesPerDay'],
      time:
          json['time'] != null
              ? TimeOfDay(
                hour: json['time']['hour'],
                minute: json['time']['minute'],
              )
              : null,
      dosage: json['dosage'],
    );
  }

  // Add medication with persistence
  Future<void> addMedication(Medicine medicine) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if the medicine has already ended
    if (medicine.endDate != null && medicine.endDate!.isBefore(today)) {
      throw MedicationError(
        MedicationError.INVALID_DATE,
        'Cannot add medicine that has already ended',
      );
    }

    // Check for duplicate medicine in the same time slot and date range
    final duplicates = _medications.where(
      (m) =>
          m.name.toLowerCase() == medicine.name.toLowerCase() &&
          m.timeSlotIndex == medicine.timeSlotIndex &&
          _hasDateOverlap(medicine, m),
    );

    if (duplicates.isNotEmpty) {
      throw MedicationError(
        MedicationError.DUPLICATE_MEDICINE,
        'A medicine with the same name already exists in this time slot with overlapping dates',
      );
    }

    _medications.add(medicine);
    await _saveMedications();
  }

  // Helper method to check if two medicines have overlapping dates
  bool _hasDateOverlap(Medicine med1, Medicine med2) {
    final med1End = med1.endDate ?? DateTime(2101);
    final med2End = med2.endDate ?? DateTime(2101);

    return (med1.startDate.isBefore(med2End) ||
            med1.startDate.isAtSameMomentAs(med2End)) &&
        (med1End.isAfter(med2.startDate) ||
            med1End.isAtSameMomentAs(med2.startDate));
  }

  // Remove medication with persistence
  Future<void> removeMedication(int timeSlotIndex, int medicineIndex) async {
    final medications = getMedicationsForTimeSlot(timeSlotIndex);
    if (medicineIndex < 0 || medicineIndex >= medications.length) {
      throw MedicationError(
        MedicationError.MEDICINE_NOT_FOUND,
        'Medicine not found at the specified index',
      );
    }
    _medications.remove(medications[medicineIndex]);
    await _saveMedications();
  }

  List<Medicine> getMedicationsForTimeSlot(
    int timeSlotIndex, [
    DateTime? date,
  ]) {
    if (timeSlotIndex < 0 || timeSlotIndex > 3) {
      throw MedicationError(
        MedicationError.INVALID_TIME_SLOT,
        'Invalid time slot index',
      );
    }

    final targetDate = date ?? DateTime.now();
    // Strip time component for consistent comparison
    final targetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    return _medications.where((medicine) {
      // Only include medicines for this time slot
      if (medicine.timeSlotIndex != timeSlotIndex) return false;

      // Convert dates to start of day for comparison
      final startDay = DateTime(
        medicine.startDate.year,
        medicine.startDate.month,
        medicine.startDate.day,
      );

      // If medicine has an end date, strictly check the range
      if (medicine.endDate != null) {
        final endDay = DateTime(
          medicine.endDate!.year,
          medicine.endDate!.month,
          medicine.endDate!.day,
        );

        // Only show medicine if target date is:
        // 1. Equal to or after start date AND
        // 2. Equal to or before end date
        return !targetDay.isBefore(startDay) && !targetDay.isAfter(endDay);
      }

      // For medicines without end date, only show if target date is equal to or after start date
      return !targetDay.isBefore(startDay);
    }).toList();
  }

  // Toggle medicine taken status with persistence
  Future<void> toggleMedicineTaken(
    int timeSlotIndex,
    int medicineIndex, [
    DateTime? date,
  ]) async {
    final targetDate = date ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(targetDate.year, targetDate.month, targetDate.day);

    // Get medications visible for the target date
    final medications = getMedicationsForTimeSlot(timeSlotIndex, targetDate);

    if (medicineIndex < 0 || medicineIndex >= medications.length) {
      throw MedicationError(
        MedicationError.MEDICINE_NOT_FOUND,
        'Medicine not found at the specified index',
      );
    }

    final medicine = medications[medicineIndex];

    // Check if the target date is in the future
    if (targetDate.isAfter(
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    )) {
      throw MedicationError(
        MedicationError.FUTURE_DATE,
        'Cannot mark medicine as taken for future dates',
      );
    }

    // Check if the target date is too far in the past (e.g., more than 7 days)
    if (targetDate.isBefore(DateTime(now.year, now.month, now.day - 7))) {
      throw MedicationError(
        MedicationError.PAST_DATE,
        'Cannot modify medicine status for dates more than 7 days in the past',
      );
    }

    // Check if the target date is within the medicine's schedule
    if (!_isDateInSchedule(medicine, today)) {
      throw MedicationError(
        MedicationError.INVALID_DATE,
        'Cannot modify medicine status for dates outside its schedule',
      );
    }

    final currentStatus = medicine.isTakenOnDate(targetDate);
    medicine.setTakenStatus(targetDate, !currentStatus);
    await _saveMedications();
  }

  // Helper method to check if a date is within a medicine's schedule
  bool _isDateInSchedule(Medicine medicine, DateTime date) {
    // Strip time component for consistent comparison
    final targetDay = DateTime(date.year, date.month, date.day);
    final startDay = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
    );

    if (medicine.endDate != null) {
      final endDay = DateTime(
        medicine.endDate!.year,
        medicine.endDate!.month,
        medicine.endDate!.day,
      );
      // Only return true if date is within range (inclusive)
      return !targetDay.isBefore(startDay) && !targetDay.isAfter(endDay);
    }

    // For medicines without end date, only check start date
    return !targetDay.isBefore(startDay);
  }

  bool canTakeMedicine(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      throw MedicationError(
        MedicationError.FUTURE_DATE,
        'Cannot take medicine for future dates',
      );
    }
    if (date.isBefore(DateTime(now.year, now.month, now.day - 7))) {
      throw MedicationError(
        MedicationError.PAST_DATE,
        'Cannot modify medicine status for dates more than 7 days in the past',
      );
    }
    return DateUtils.isSameDay(date, now);
  }

  // Check if all medications in a time slot are taken for a specific date
  bool areAllMedicationsTaken(int timeSlotIndex, [DateTime? targetDate]) {
    final date = targetDate ?? DateTime.now();
    final medications = getMedicationsForTimeSlot(timeSlotIndex, date);
    if (medications.isEmpty) return false;
    return medications.every((medicine) => medicine.isTakenOnDate(date));
  }

  // Helper method to validate time slot index
  void _validateTimeSlotIndex(int timeSlotIndex) {
    if (timeSlotIndex < 0 || timeSlotIndex > 3) {
      throw MedicationError(
        MedicationError.INVALID_TIME_SLOT,
        'Invalid time slot index',
      );
    }
  }
}
