# ⏱️ Pomodoro Desktop App (Flutter)

Une application de gestion du temps basée sur la méthode **Pomodoro**, développée en **Flutter Desktop** pour Windows. Ce projet inclut des animations, des sons, la personnalisation des durées, ainsi qu'une fonctionnalité de blocage d'applications distrayantes.

---

## 📖 Objectif

Permettre à un utilisateur de se concentrer par sessions de travail alternées avec des pauses, tout en bloquant automatiquement les applications qui pourraient l'interrompre.

---

## 🚀 Etapes du développement (pas à pas)

### ✅ 1. Mise en place du projet Flutter Desktop

* Création du projet : `flutter create pomodoro_desktop`
* Activation du support Windows : `flutter config --enable-windows-desktop`
* Nettoyage du code de base et mise en place de la structure MVC.

### ⚡ 2. Logique Pomodoro de base

* Création du fichier `timer_service.dart` pour la gestion du timer
* Enum `PomodoroSessionType` pour distinguer les types de session (focus, short break, long break)
* Fonction de démarrage, arrêt, réinitialisation et changement de session

### 📅 3. Interface utilisateur minimaliste

* Écran principal dans `home_screen.dart`
* Affichage circulaire du temps (widget `CircularTimerDisplay`)
* Barre latérale (sidebar) avec boutons de navigation vers les différents types de session
* Ajout d'un système de dialogue modale pour modifier les durées

### 📊 4. Animations

* **SlideTransition** pour la sidebar à l'ouverture
* **SlideTransition verticale** pour le label de session (Focus, Pause...)
* **AnimatedScale** pour un effet "pulse" sur les boutons Start / Reset
* **Confettis** à la fin d'une session avec `confetti` package

### 🔔 5. Notifications et sons

* Utilisation de `flutter_local_notifications` pour afficher des notifications Windows
* Notification à la fin de chaque session avec un message personnalisé
* Intégration de `audioplayers` pour jouer un **son à la fin de session**

### ⛔️ 6. Blocage d'applications

* Fichier `app_blocker_service.dart` avec un singleton
* Liste dynamique des applications à bloquer (ex: Discord.exe)
* Surveillance toutes les 10 secondes avec `process_run` ou `Process.run()`
* Fermeture automatique avec `taskkill`
* Interface modale pour afficher, ajouter et supprimer les apps bloquées

---

## 📂 Structure des fichiers

```
lib/
├── main.dart
├── screens/
│   └── home_screen.dart         # Écran principal avec animations et boutons
├── services/
│   ├── timer_service.dart       # Logique Pomodoro (timer)
│   ├── notification_service.dart# Notifications Windows
│   └── app_blocker_service.dart # Fermeture des apps interdites
├── models/
│   └── pomodoro_settings.dart   # Modèle pour les durées
├── widgets/
│   └── circular_timer_display.dart # Widget circulaire du minuteur
assets/
└── sounds/
    └── success.mp3              # Son à la fin de session
```

---

## 😎 Expérience utilisateur

* L'utilisateur voit un cercle animé avec le temps restant
* Il peut modifier les durées via une popup
* Il reçoit une **notification** et un **son** à la fin de chaque session
* Les apps interdites sont automatiquement fermées
* Le label de session change de manière fluide (glissement + animation)

---

## 🛏þ⃣ Lancer le projet (Windows Desktop)

```bash
flutter pub get
flutter run -d windows
```

---

## 📄 pubspec.yaml – dépendances clés

```yaml
dependencies:
  provider: ^6.1.1
  flutter_local_notifications: ^17.1.2
  audioplayers: ^6.5.0
  confetti: ^0.8.0
  win_toast: ^0.1.1
  process_run: ^0.12.3+2
  shared_preferences: ^2.2.2
```

---

## 🌟 Améliorations futures possibles

* Statistiques de temps passé par type de session
* Mode "plein écran"
* Export CSV
* Intégration cloud (Firebase ou autre)

---

## 👤 Auteur

**Alan Riehl**
Etudiant développeur passionné par la productivité, Flutter et les projets utiles !
