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
import 'zero_lines.dart';

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

/// The reminder in Zero's words (lines.js notify_* pools). Reminders are re-planned whenever the app goes
/// to the background, so the one [daysAhead] days out only fires if you haven't opened the app since: she
/// gets lonelier. Today's sounds like her temperament that day.
Future<(String, String)> _zeroSays(int daysAhead, DateTime when, int n) async =>
    await zeroLine(switch (daysAhead) {
      0 => 'notify_${zeroTemper(when)}',
      1 || 2 => 'notify_$daysAhead',
      3 || 4 => 'notify_3',
      _ => 'notify_5',
    }, {'due': n}) ??
    ('……', '…');

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
      final (zh, en) = await _zeroSays(day, when, w.due + w.fresh);
      await _plugin.zonedSchedule(
        id: day,
        scheduledDate: tz.TZDateTime.from(when, tz.UTC),
        title: 'Zero: $zh',
        body: '$en · ${[
          if (w.due > 0) '${w.due} due',
          if (w.fresh > 0) '${w.fresh} new',
        ].join(' · ')}',
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
