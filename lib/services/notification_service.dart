
// Service pour afficher des notifications toast sur Windows via PowerShell
import 'dart:io';


/// Service de notification pour afficher des toasts Windows
class NotificationService {
  /// Initialisation du service (rien à faire ici pour l'instant)
  static Future<void> init() async {
    // Rien à initialiser ici
  }


  /// Affiche immédiatement une notification toast Windows avec le titre et le message donnés
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    // Script PowerShell pour afficher une notification toast
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

    // Exécute le script PowerShell
    await Process.run('powershell', ['-NoProfile', '-Command', script]);
  }

  /// Planifie une notification à afficher après un délai donné
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
