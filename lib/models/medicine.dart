import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final int timeSlotIndex;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, bool> doseHistory; // Format: "yyyy-MM-dd" -> taken status

  // Schedule information
  final String? frequency;
  final String? timesPerDay;
  final TimeOfDay? time;
  final int? dosage;

  Medicine({
    required this.name,
    required this.timeSlotIndex,
    required this.startDate,
    this.endDate,
    Map<String, bool>? doseHistory,
    this.frequency,
    this.timesPerDay,
    this.time,
    this.dosage,
  }) : doseHistory = doseHistory ?? {};

  bool get isTaken {
    final today = DateTime.now();
    final dateKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return doseHistory[dateKey] ?? false;
  }

  bool isScheduledForDate(DateTime date) {
    if (endDate == null) return !date.isBefore(startDate);
    return !date.isBefore(startDate) && !date.isAfter(endDate!);
  }

  bool isTakenOnDate(DateTime date) {
    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return doseHistory[dateKey] ?? false;
  }

  void setTakenStatus(DateTime date, bool taken) {
    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    doseHistory[dateKey] = taken;
  }

  // Check if the medicine needs to be reset for a new day
  bool needsReset(DateTime currentDate) {
    return !DateUtils.isSameDay(DateTime.now(), currentDate);
  }

  // Reset the medicine for a new day
  void resetForNewDay(DateTime currentDate) {
    if (needsReset(currentDate)) {
      setTakenStatus(currentDate, false);
    }
  }
}
