import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_app/services/notification_service.dart';
import '../models/medicine.dart';
// import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

class NotificationService {}

class MedicineSchedulePage extends StatefulWidget {
  final String medicationName;
  final int timeSlotIndex;
  final DateTime date;

  const MedicineSchedulePage({
    super.key,
    required this.medicationName,
    required this.timeSlotIndex,
    required this.date,
  });

  @override
  State<MedicineSchedulePage> createState() => _MedicineSchedulePageState();
}

class _MedicineSchedulePageState extends State<MedicineSchedulePage> {
  // Frequency options
  final List<String> _frequencyOptions = [
    'As Needed',
    'Every Day',
    'Specific Days',
    'Days Interval',
  ];
  String _selectedFrequency = 'Every Day';

  // Times per day options
  final List<String> _timesPerDayOptions = [
    'Once a Day',
    'Twice a Day',
    'Three Times a Day',
    'Four Times a Day',
  ];
  String _selectedTimesPerDay = 'Once a Day';

  // Time selection
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  late int clockHr;
  late int clockMin;

  final int _dosage = 1;

  // Start and end dates
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.date;
    clockHr = _selectedTime.hour;
    clockMin = _selectedTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSchedule,
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
      body: ListView(
        children: [
          // Frequency section
          _buildSectionHeader('Frequency'),
          _buildSelectionItem(
            'Every Day',
            onTap: () => _showFrequencyPicker(),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),

          // How many times a day section
          _buildSectionHeader('HOW MANY TIMES A DAY?'),
          _buildSelectionItem(
            _selectedTimesPerDay,
            onTap: () => _showTimesPerDayPicker(),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),

          // What time section
          _buildSectionHeader('WHAT TIME?'),
          _buildSelectionItem(
            '${_formatTime(_selectedTime)}\nTake $_dosage',
            onTap: () => _selectTime(),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),

          // Start date section
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildSelectionItem(
              'Starts ${DateFormat('MMM d, yyyy').format(_startDate)}',
              isHeader: false,
              onTap: () => _selectStartDate(),
            ),
          ),

          // End date section
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildSelectionItem(
              _endDate != null
                  ? 'Ends ${DateFormat('MMM d, yyyy').format(_endDate!)}'
                  : 'Set End Date (Optional)',
              isHeader: false,
              onTap: () => _selectEndDate(),
              trailing:
                  _endDate != null
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _endDate = null),
                      )
                      : const Icon(Icons.calendar_month, color: Colors.blue),
            ),
          ),

          if (_endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Medicine will be hidden from schedule after end date',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.grey[200],
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectionItem(
    String title, {
    required Function() onTap,
    Widget? trailing,
    bool isHeader = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isHeader ? 14 : 16,
                fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showFrequencyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _frequencyOptions.length,
                  itemBuilder: (context, index) {
                    final option = _frequencyOptions[index];
                    return ListTile(
                      title: Center(
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      selected: option == _selectedFrequency,
                      onTap: () {
                        setState(() {
                          _selectedFrequency = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // void setCustomAlarm() {
  //   FlutterAlarmClock.createAlarm(
  //     hour: clockHr,
  //     minutes: clockMin,
  //     title: 'take a medicine',
  //   );
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text("Alarm set for $clockHr:$clockMin")));
  // }

  Future<void> scheduleNotification() async {
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      clockHr,
      clockMin,
      0,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
  }

  void _showTimesPerDayPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const Text(
                      'Times Per Day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _timesPerDayOptions.length,
                  itemBuilder: (context, index) {
                    final option = _timesPerDayOptions[index];
                    return ListTile(
                      title: Center(
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      selected: option == _selectedTimesPerDay,
                      onTap: () {
                        setState(() {
                          _selectedTimesPerDay = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        clockHr = picked.hour;
        clockMin = picked.minute;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: today, // Can't set start date in the past
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _startDate) {
      if (_endDate != null && picked.isAfter(_endDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start date cannot be after end date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: today, // Can't set end date in the past
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      if (picked.isBefore(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date cannot be before start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveSchedule() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Validate dates before saving
    if (_startDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot schedule medicine to start in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate != null && _endDate!.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot schedule medicine to end in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a medicine object with schedule information
    final medicine = Medicine(
      name: widget.medicationName,
      timeSlotIndex: widget.timeSlotIndex,
      startDate: _startDate,
      endDate: _endDate,
      frequency: _selectedFrequency,
      timesPerDay: _selectedTimesPerDay,
      time: _selectedTime,
      dosage: _dosage,
    );

    // setCustomAlarm();
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationHelper.initializeNotifications();
    // NotificationHelper.sendInstantNotification();
    NotificationHelper.scheduleDailyMedicationReminder(clockHr, clockMin);
    // Return to previous screen with the medicine
    Navigator.pop(context, medicine);
  }
}
