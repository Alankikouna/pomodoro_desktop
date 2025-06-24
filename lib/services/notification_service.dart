import 'dart:io';

class NotificationService {
  static Future<void> init() async {
    // Rien à initialiser ici
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    final script = '''
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > \$null
    \$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
    \$textNodes = \$template.GetElementsByTagName("text")
    \$textNodes.Item(0).AppendChild(\$template.CreateTextNode("$title")) > \$null
    \$textNodes.Item(1).AppendChild(\$template.CreateTextNode("$body")) > \$null
    \$toast = [Windows.UI.Notifications.ToastNotification]::new(\$template)
    \$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Pomodoro Desktop")
    \$notifier.Show(\$toast)
    ''';

    await Process.run('powershell', ['-NoProfile', '-Command', script]);
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
  }) async {
    Future.delayed(delay, () {
      showImmediateNotification(title: title, body: body);
    });
  }
}
