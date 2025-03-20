import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final int timeSlotIndex;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, bool> doseHistory; // Format: "yyyy-MM-dd" -> taken status
  final Map<String, bool>
  missedHistory; // Format: "yyyy-MM-dd" -> missed status
  final String id; // Unique identifier for the medicine

  // Schedule information
  final String? frequency;
  final String? timesPerDay;
  final TimeOfDay? time;
  final int? dosage;

  Medicine({
    required this.name,
    required this.timeSlotIndex,
    required this.startDate,
    required this.id,
    this.endDate,
    Map<String, bool>? doseHistory,
    Map<String, bool>? missedHistory,
    this.frequency,
    this.timesPerDay,
    this.time,
    this.dosage,
  }) : doseHistory = doseHistory ?? {},
       missedHistory = missedHistory ?? {};

  bool get isTaken {
    final today = DateTime.now();
    final dateKey = _formatDateKey(today);
    return doseHistory[dateKey] ?? false;
  }

  bool get isMissed {
    final today = DateTime.now();
    final dateKey = _formatDateKey(today);
    return missedHistory[dateKey] ?? false;
  }

  bool isScheduledForDate(DateTime date) {
    if (endDate == null) return !date.isBefore(startDate);
    return !date.isBefore(startDate) && !date.isAfter(endDate!);
  }

  bool isTakenOnDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    return doseHistory[dateKey] ?? false;
  }

  bool isMissedOnDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    return missedHistory[dateKey] ?? false;
  }

  void setTakenStatus(DateTime date, bool taken) {
    final dateKey = _formatDateKey(date);
    doseHistory[dateKey] = taken;
    // If marked as taken, remove from missed
    if (taken) {
      missedHistory.remove(dateKey);
    }
  }

  void setMissedStatus(DateTime date, bool missed) {
    final dateKey = _formatDateKey(date);
    missedHistory[dateKey] = missed;
    // If marked as missed, remove from taken
    if (missed) {
      doseHistory.remove(dateKey);
    }
  }

  // Helper method to format date key
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Check if the medicine needs to be reset for a new day
  bool needsReset(DateTime currentDate) {
    return !DateUtils.isSameDay(DateTime.now(), currentDate);
  }

  // Reset the medicine for a new day
  void resetForNewDay(DateTime currentDate) {
    if (needsReset(currentDate)) {
      setTakenStatus(currentDate, false);
      setMissedStatus(currentDate, false);
    }
  }
}
