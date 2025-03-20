import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../services/medication_service.dart';
import 'package:telephony_sms/telephony_sms.dart';

class NotificationHelper {
  /// Initialize Awesome Notifications with channel & permissions
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'medication_channel',
        channelName: 'Medication Reminders',
        channelDescription: 'Reminders to take your medication on time',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        soundSource: 'resource://raw/coolsms', // Ensure file exists!
        enableVibration: true,
        vibrationPattern: highVibrationPattern,
        enableLights: true,
      ),
    ], debug: true);

    // Request permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Set notification action listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationHelper.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationHelper.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationHelper.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationHelper.onDismissActionReceivedMethod,
    );
  }

  /// Schedule daily medication reminder
  static void scheduleDailyMedicationReminder(
    int hour,
    int minute,
    String medicine,
    String scheduleId,
  ) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'medication_channel',
        title: '💊 Time to Take Your Medicine! ($medicine)',
        body: 'Stay healthy! Please take your medication now.',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
        payload: {
          'medicine': medicine,
          'scheduleId': scheduleId,
          'hour': hour.toString(),
          'minute': minute.toString(),
        },
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'TAKEN',
          label: 'TAKEN',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Snooze',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'MISSED',
          label: 'Missed',
          autoDismissible: true,
        ),
      ],
    );
  }

  /// Send instant notification
  static void sendInstantNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'medication_channel',
        title: '💊 Immediate Reminder',
        body: 'Please take your medicine now!',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'TAKEN',
          label: 'TAKEN',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Snooze',
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'MISSED',
          label: 'Missed',
          autoDismissible: true,
        ),
      ],
    );
  }

  /// Cancel all notifications
  static void cancelAllReminders() {
    AwesomeNotifications().cancelAll();
  }

  /// Cancel specific notification by ID
  static void cancelNotificationById(int id) {
    AwesomeNotifications().cancel(id);
  }

  /// List all scheduled notifications
  static Future<void> listScheduledNotifications() async {
    List<NotificationModel> scheduled =
        await AwesomeNotifications().listScheduledNotifications();
    debugPrint('Scheduled Notifications: ${scheduled.length}');
    for (var notification in scheduled) {
      debugPrint('Notification ID: ${notification.content?.id}');
    }
  }

  /// Check if notification permission is granted
  static Future<bool> checkPermission() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Reset Badge Counter (Optional)
  static void resetBadge() {
    AwesomeNotifications().resetGlobalBadge();
  }

  /// Handle notification creation
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification Created: ${receivedNotification.title}');
  }

  /// Handle notification display
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification Displayed: ${receivedNotification.title}');
  }

  /// Handle notification dismissal
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('Notification Dismissed: ${receivedAction.buttonKeyPressed}');
  }

  /// Handle notification action button pressed (SNOOZE / TAKEN / MISSED)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    int hour = DateTime.now().add(Duration(minutes: 2)).hour;
    int minute = DateTime.now().add(Duration(minutes: 2)).minute;
    String? medicine = receivedAction.payload?['medicine'];
    String? scheduleId = receivedAction.payload?['scheduleId'];
    medicine ??= "";

    switch (receivedAction.buttonKeyPressed) {
      case 'SNOOZE':
        debugPrint('snooze pressed');
        scheduleDailyMedicationReminder(hour, minute, medicine!, scheduleId!);
        break;
      case 'TAKEN':
        // Cancel notification
        AwesomeNotifications().cancel(receivedAction.id!);

        // Mark medicine as taken
        if (scheduleId != null) {
          await markMedicineAsTaken(scheduleId);
        }
        break;
      case 'MISSED':
        // Cancel the current notification
        AwesomeNotifications().cancel(receivedAction.id!);

        // Send SMS alert
        final _telephonySMS = TelephonySMS();
        await _telephonySMS.sendSMS(
          phone: "9029022260", // You might want to make this configurable
          message:
              "Alert: Patient missed their medication - $medicine at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
        );

        // Mark medicine as missed in the service
        if (scheduleId != null) {
          await markMedicineMissed(scheduleId);
        }
        break;
      default:
        debugPrint('Other action pressed: ${receivedAction.buttonKeyPressed}');
        break;
    }
  }

  /// Mark medicine as taken in the schedule
  static Future<void> markMedicineAsTaken(String scheduleId) async {
    try {
      // Get the MedicationService instance
      final medicationService = MedicationService();

      // Initialize the service to ensure data is loaded
      await medicationService.initialize();

      // Find the medicine with this ID and mark it as taken
      await medicationService.markMedicineAsTakenById(scheduleId);
    } catch (e) {
      debugPrint('Error marking medicine as taken: $e');
    }
  }

  /// Mark medicine as missed in the schedule
  static Future<void> markMedicineMissed(String scheduleId) async {
    try {
      // Get the MedicationService instance
      final medicationService = MedicationService();

      // Initialize the service to ensure data is loaded
      await medicationService.initialize();

      // Find the medicine with this ID and mark it as missed
      await medicationService.markMedicineMissedById(scheduleId);
    } catch (e) {
      debugPrint('Error marking medicine as missed: $e');
    }
  }
}
