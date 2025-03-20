import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_medicine_page.dart';
import '../models/medicine.dart';
import '../models/medication_error.dart';
import '../services/medication_service.dart';
import 'dart:async';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late DateTime _selectedDate;
  final MedicationService _medicationService = MedicationService();
  late List<DateTime> _dates;
  late ScrollController _scrollController;
  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening', 'Night'];
  final List<Color> _timeSlotColors = [
    const Color(0xFFFFA726), // Orange for Morning
    const Color(0xFF4FC3F7), // Light Blue for Afternoon
    const Color(0xFF7E57C2), // Purple for Evening
    const Color(0xFF5C6BC0), // Indigo for Night
  ];

  // Map to track undo timers for each medication
  final Map<String, Timer> _undoTimers = {};
  // Map to track if medication can be untaken
  final Map<String, bool> _canUntake = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _scrollController = ScrollController();
    _generateDates();
    // Initialize medication service
    _medicationService.initialize();
    // Listen to medication changes
    _medicationService.addListener(_onMedicationServiceChanged);
    // Wait for the widget to be built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Remove the listener when disposing
    _medicationService.removeListener(_onMedicationServiceChanged);
    // Cancel all active timers
    for (var timer in _undoTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  // Called when medication service notifies of changes
  void _onMedicationServiceChanged() {
    if (mounted) {
      setState(() {
        // This will rebuild the UI with updated medication statuses
      });
    }
  }

  void _generateDates() {
    final now = DateTime.now();
    _dates = List.generate(30, (index) => now.add(Duration(days: index - 15)));
  }

  void _scrollToCurrentDate() {
    // Calculate the offset to center the current date
    // Each date card is 68 pixels wide (60 width + 8 margin)
    const itemWidth = 68.0;
    // Find the index of today's date
    final currentIndex = _dates.indexWhere(
      (date) => DateUtils.isSameDay(date, DateTime.now()),
    );
    // Calculate the offset to center the current date
    final offset =
        currentIndex * itemWidth -
        (MediaQuery.of(context).size.width - itemWidth) / 2;
    // Animate to the calculated offset
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleMedicineTaken(
    int timeSlotIndex,
    int medicineIndex,
    Medicine medicine,
  ) {
    try {
      if (!_medicationService.canTakeMedicine(_selectedDate)) {
        // This will throw an appropriate error if the date is invalid
        return;
      }

      // Generate a unique key for this medication
      final medicineKey = '${timeSlotIndex}_${medicineIndex}_${medicine.name}';

      setState(() {
        _medicationService.toggleMedicineTaken(
          timeSlotIndex,
          medicineIndex,
          _selectedDate,
        );
        _canUntake[medicineKey] = true;
      });

      // Show success snackbar
      _showSnackBar(
        'Medicine ${medicine.name} taken!',
        backgroundColor: const Color(0xFF4CAF50),
      );

      // Start a timer for 3 seconds
      _undoTimers[medicineKey]?.cancel();
      _undoTimers[medicineKey] = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _canUntake[medicineKey] = false;
          });
        }
      });
    } on MedicationError catch (e) {
      _showSnackBar(e.message, backgroundColor: const Color(0xFFE57373));
    } catch (e) {
      _showSnackBar(
        'An unexpected error occurred',
        backgroundColor: const Color(0xFFE57373),
      );
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? Colors.black87,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMedicationsList(int timeSlotIndex) {
    final medications = _medicationService.getMedicationsForTimeSlot(
      timeSlotIndex,
      _selectedDate,
    );
    final isCurrentDate = DateUtils.isSameDay(_selectedDate, DateTime.now());

    if (medications.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medications.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, i) {
        final medicine = medications[i];
        final medicineKey = '${timeSlotIndex}_${i}_${medicine.name}';
        final canUndo = _canUntake[medicineKey] ?? false;
        final isTaken = medicine.isTakenOnDate(_selectedDate);
        final canTake = isCurrentDate;

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isTaken,
                    onChanged:
                        !canTake
                            ? null
                            : (isTaken && !canUndo)
                            ? null
                            : (value) {
                              if (value == true) {
                                _handleMedicineTaken(
                                  timeSlotIndex,
                                  i,
                                  medicine,
                                );
                              } else if (canUndo) {
                                setState(() {
                                  _medicationService.toggleMedicineTaken(
                                    timeSlotIndex,
                                    i,
                                    _selectedDate,
                                  );
                                });
                                _undoTimers[medicineKey]?.cancel();
                                _canUntake[medicineKey] = false;
                              }
                            },
                    activeColor: const Color(0xFF4CAF50),
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color:
                          canTake ? Colors.grey : Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.medication,
                  color: isTaken ? const Color(0xFF4CAF50) : Colors.white,
                  size: 24,
                ),
              ],
            ),
            title: Text(
              medicine.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                decoration: isTaken ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFFE57373),
                decorationThickness: 2,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take 1 Pill(s)',
                  style: TextStyle(
                    color: isTaken ? Colors.grey[600] : Colors.grey[400],
                    fontSize: 14,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFFE57373),
                    decorationThickness: 2,
                  ),
                ),
                if (!isCurrentDate)
                  Text(
                    isTaken ? 'Taken' : 'Not taken',
                    style: TextStyle(
                      color:
                          isTaken
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE57373),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing:
                isCurrentDate && isTaken
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canUndo)
                          TextButton.icon(
                            onPressed: () {
                              try {
                                setState(() {
                                  _medicationService.toggleMedicineTaken(
                                    timeSlotIndex,
                                    i,
                                    _selectedDate,
                                  );
                                });
                                _undoTimers[medicineKey]?.cancel();
                                _canUntake[medicineKey] = false;
                              } on MedicationError catch (e) {
                                _showSnackBar(
                                  e.message,
                                  backgroundColor: const Color(0xFFE57373),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.undo,
                              color: Color(0xFF90CAF9),
                              size: 20,
                            ),
                            label: const Text(
                              'Undo',
                              style: TextStyle(
                                color: Color(0xFF90CAF9),
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                      ],
                    )
                    : isCurrentDate
                    ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF7043),
                      ),
                      onPressed: () {
                        try {
                          setState(() {
                            _medicationService.removeMedication(
                              timeSlotIndex,
                              i,
                            );
                          });
                          _showSnackBar(
                            'Medicine removed successfully',
                            backgroundColor: const Color(0xFF4CAF50),
                          );
                        } on MedicationError catch (e) {
                          _showSnackBar(
                            e.message,
                            backgroundColor: const Color(0xFFE57373),
                          );
                        }
                      },
                    )
                    : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Date Selector
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final date = _dates[index];
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF00BCD4)
                              : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isToday
                              ? Border.all(
                                color: const Color(0xFF00BCD4),
                                width: 2,
                              )
                              : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Time Slots with Medications
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Slot Header
                      GestureDetector(
                        onTap: () => _navigateToAddMedicine(index),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _timeSlotColors[index],
                                _timeSlotColors[index].withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _timeSlotColors[index].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                index == 0
                                    ? Icons.wb_sunny
                                    : index == 1
                                    ? Icons.wb_cloudy
                                    : index == 2
                                    ? Icons.cloud
                                    : Icons.nightlight_round,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _timeSlots[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_medicationService.getMedicationsForTimeSlot(index, _selectedDate).length} Meds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Medications List
                      _buildMedicationsList(index),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMedicine(0),
        backgroundColor: const Color(0xFFFF7043),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _navigateToAddMedicine(int timeSlotIndex) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AddMedicinePage(
                timeSlotIndex: timeSlotIndex,
                timeSlotName: _timeSlots[timeSlotIndex],
                date: _selectedDate,
              ),
        ),
      );

      if (result != null && result is Medicine) {
        setState(() {
          _medicationService.addMedication(result);
        });
        _showSnackBar(
          'Medicine ${result.name} added successfully',
          backgroundColor: const Color(0xFF4CAF50),
        );
      }
    } on MedicationError catch (e) {
      _showSnackBar(e.message, backgroundColor: const Color(0xFFE57373));
    } catch (e) {
      _showSnackBar(
        'An unexpected error occurred while adding the medicine',
        backgroundColor: const Color(0xFFE57373),
      );
    }
  }
}
