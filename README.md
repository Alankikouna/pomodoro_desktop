# ⏰ Pomodoro Desktop

**Pomodoro Desktop** est une application multiplateforme (Windows) de gestion du temps basée sur la technique Pomodoro. Elle est développée avec **Flutter Desktop**, avec une intégration Supabase complète (authentification, sauvegarde des paramètres et sessions), blocage d'applications, animations visuelles et raccourcis clavier.

---

## 🚀 Fonctionnalités détaillées

### 🎯 Gestion des sessions Pomodoro
- Trois types de sessions :
  - **Focus** : période de concentration.
  - **Pause courte** : 5 min (modifiable).
  - **Pause longue** : après X focus (modifiable).
- Enchaînement automatique.
- Minuteur personnalisable.

### 👤 Authentification Supabase
- Connexion et inscription via e-mail/mot de passe.
- Chaque utilisateur a ses propres paramètres et historique.

### 🔒 Blocage intelligent d’applications (Windows)
- Surveillance des processus en cours.
- Blocage de fichiers `.exe` définis par l’utilisateur.
- Interface de gestion des applications bloquées (ajout manuel ou depuis la liste active).

### ⚙️ Paramètres utilisateur
- Fenêtre dédiée avec TextField + Slider.
- Paramètres enregistrés dans Supabase.
- Rechargement automatique à la connexion.

### 📚 Historique des sessions
- Sauvegarde des sessions dans la base de données.
- Vue dédiée avec filtre et suppression de sessions/plage.
- CSV export possible.

### 🎨 UX enrichie
- Gifs Pokémon à la fin d’un focus.
- Confettis de récompense.
- Thème clair/sombre (automatique ou manuel).
- Animations fluides et design moderne.

### ⌨️ Raccourcis clavier

| Raccourci | Action                         |
|----------:|--------------------------------|
| Espace    | Démarrer / Mettre en pause     |
| R         | Réinitialiser le timer         |
| 1         | Passer en mode Focus           |
| 2         | Pause courte                   |
| 3         | Pause longue                   |
| S         | Ouvrir la fenêtre de réglages  |

---

## 🧱 Structure du projet

```bash
lib/
├── assets/
│   ├── gif/
│   └── sounds/
├── models/
│   └── pomodoro_settings.dart
├── screens/
│   ├── app_blocker_screen.dart
│   ├── auth_screen.dart
│   ├── history_screen.dart
│   ├── home_screen.dart
│   ├── onboarding_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
├── services/
│   ├── activity_service.dart
│   ├── app_blocker_service.dart
│   ├── notification_service.dart
│   ├── theme_service.dart
│   └── timer_service.dart
├── widgets/
│   ├── circular_timer_display.dart
│   ├── exe_tile.dart
│   ├── header_theme_menu.dart
│   ├── home_sidebar.dart
│   ├── settings_dialog.dart
│   ├── shiny_overlay.dart
│   ├── timer_area.dart
│   └── timer_display.dart
├── main.dart
└── router.dart
```

---

## 🛠️ Installation locale

### Prérequis
- Flutter (stable) avec support Windows.
- Dart ≥ 3.0.
- Supabase avec les tables configurées.
- Windows 10 ou 11.

### Lancer en local

```bash
git clone https://github.com/ton-user/pomodoro_desktop.git
cd pomodoro_desktop
flutter pub get
flutter run -d windows
```

---

## 🔧 Génération de l’exécutable `.exe`

```bash
flutter build windows
```

L'exécutable sera dans :
`build/windows/runner/Release/pomodoro_desktop.exe`

---

## 📦 Création d’un installateur (NSIS)

### Étapes :

1. Installer NSIS : https://nsis.sourceforge.io/Download
2. Créer un fichier `pomodoro_installer.nsi` :

```nsi
Outfile "PomodoroInstaller.exe"
InstallDir "$PROGRAMFILES\Pomodoro Desktop"
RequestExecutionLevel admin

Section
  SetOutPath $INSTDIR
  File /r "build\windows\runner\Release\*.*"
  CreateShortCut "$DESKTOP\Pomodoro.lnk" "$INSTDIR\pomodoro_desktop.exe"
SectionEnd
```

3. Ouvrir NSIS → **Compiler Script**.

---

## 🧮 Supabase – Structure des données

### Table `pomodoro_settings`

| Champ                 | Type     | Description                             |
|----------------------|----------|-----------------------------------------|
| user_id              | UUID     | Clé primaire (utilisateur)              |
| focus_duration       | Integer  | Durée de concentration                  |
| short_break_duration | Integer  | Durée pause courte                      |
| long_break_duration  | Integer  | Durée pause longue                      |
| long_break_every_x   | Integer  | Pause longue toutes les X sessions      |

### Table `pomodoro_sessions`

| Champ       | Type      | Description                          |
|-------------|-----------|--------------------------------------|
| user_id     | UUID      | Référence à l’utilisateur            |
| type        | text      | `focus`, `shortBreak`, `longBreak`   |
| started_at  | timestamp | Date/heure de début                  |
| ended_at    | timestamp | Date/heure de fin                    |

---

## 📈 Roadmap (à venir)

- [ ] Statistiques visuelles (graphes, heatmaps)
- [ ] Mode hors-ligne
- [ ] Blocage cross-platform (macOS, Linux)
- [ ] Multi-profils
- [ ] Thèmes/gifs personnalisables

---

## 👨‍💻 Auteur

Développé par **Alan Riehl**  
Projet Flutter Desktop – 2025  
Licence : MIT