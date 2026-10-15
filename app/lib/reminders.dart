/// Daily study reminder (Android). Scheduled notifications carry fixed text, so the next 7 days
/// are scheduled ahead with each day's workload and re-planned whenever the app goes to the
/// background (after you study, the counts change).
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'db.dart';
import 'profile.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _ready = false;
AppLifecycleListener? _life;

bool get remindersSupported => Platform.isAndroid;

Future<void> _init() async {
  if (_ready) return;
  await _plugin.initialize(
    settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
  );
  _ready = true;
}

void startReminders() {
  if (!remindersSupported) return;
  _life ??= AppLifecycleListener(onHide: scheduleReminders);
  Future.delayed(const Duration(seconds: 3), scheduleReminders); // once prefs have loaded
}

/// Asks Android 13+ for permission to post notifications. True if allowed.
Future<bool> askNotificationPermission() async {
  await _init();
  return await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;
}

/// [at] is 'HH:MM' or '' for off; defaults to the saved `reminder` pref.
Future<void> scheduleReminders([String? at]) async {
  if (!remindersSupported) return;
  try {
    await _init();
    await _plugin.cancelAll();
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(at ?? pref('reminder'));
    if (m == null) return;
    final now = DateTime.now();
    for (var day = 0; day < 7; day++) {
      final when = DateTime(now.year, now.month, now.day + day, int.parse(m[1]!), int.parse(m[2]!));
      if (!when.isAfter(now)) continue;
      final w = await db.workAt(when);
      if (w.due + w.fresh == 0) continue;
      await _plugin.zonedSchedule(
        id: day,
        scheduledDate: tz.TZDateTime.from(when, tz.UTC),
        title: w.due > 0 ? '${w.due} ${w.due == 1 ? 'card' : 'cards'} to review' : 'New cards are ready',
        body: [
          if (w.due > 0) '${w.due} due',
          if (w.fresh > 0) '${w.fresh} new',
        ].join(' · '),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('reminder', 'Daily reminder', channelDescription: 'Your daily study reminder'),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  } catch (e) {
    debugPrint('reminder scheduling failed: $e');
  }
}
