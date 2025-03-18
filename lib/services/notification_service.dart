import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

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
  static void scheduleDailyMedicationReminder(int hour, int minute) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'medication_channel',
        title: '💊 Time to Take Your Medicine!',
        body: 'Stay healthy! Please take your medication now.',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
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
          key: 'STOP',
          label: 'Stop',
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
          key: 'STOP',
          label: 'Stop',
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

  /// Handle notification action button pressed (SNOOZE / STOP / MISSED)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    int hour = DateTime.now().add(Duration(minutes: 10)).hour;
    int minute = DateTime.now().add(Duration(minutes: 10)).minute;

    switch (receivedAction.buttonKeyPressed) {
      case 'SNOOZE':
        // Schedule after 10 minutes
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'medication_channel',
            title: '💊 Snoozed Reminder!',
            body: 'Reminder after 10 minutes!',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            hour: hour,
            minute: minute,
            second: 0,
            millisecond: 0,
            repeats: false,
            allowWhileIdle: true,
          ),
        );
        break;
      case 'STOP':
        // Cancel notification
        AwesomeNotifications().cancel(receivedAction.id!);
        break;
      default:
        debugPrint('Other action pressed: ${receivedAction.buttonKeyPressed}');
        break;
    }
  }
}
