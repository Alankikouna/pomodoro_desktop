# ⏰ Pomodoro Desktop

**Pomodoro Desktop** est une application de productivité multiplateforme (principalement Windows) développée avec **Flutter Desktop**. Elle applique la méthode Pomodoro pour améliorer la concentration et propose de nombreuses fonctionnalités modernes : blocage d'applications, authentification Supabase, effets visuels et raccourcis clavier.

---

## Sommaire
1. [Fonctionnalités détaillées](#fonctions)
2. [Raccourcis clavier](#raccourcis-clavier)
3. [Structure du projet](#structure-du-projet)
4. [Installation locale](#installation-locale)
5. [Génération de l'exécutable](#génération-de-lexécutable)
6. [Création d'un installateur](#création-dun-installateur)
7. [Supabase – Structure BDD](#supabase--structure-bdd)
8. [Roadmap](#roadmap)
9. [Auteur](#auteur)

---

## 🚀 Fonctionnalités détaillées

### 🎯 Gestion des sessions Pomodoro
- 3 types de sessions : `Focus`, `Pause Courte`, `Pause Longue`.
- Enchaînement automatique (par exemple : 4 Focus ➜ Pause longue).
- Minuteur personnalisable pour chaque utilisateur.

### 👤 Authentification via Supabase
- Inscription et connexion par email.
- Paramètres et historique attachés à l'utilisateur.

### 🔒 Blocage d'applications `.exe`
- Liste des processus actifs filtrés.
- Ajout automatique ou manuel d'applications à bloquer.
- Surveillance continue durant les périodes de focus.
- Liste des applications bannies modifiable.

### ⚙️ Paramètres sauvegardés
- Durées de Focus/Pause entièrement modifiables.
- Définition de la fréquence des pauses longues.
- Synchronisation des réglages dans Supabase.

### 📚 Historique des sessions
- Sauvegarde du début et de la fin de chaque session.
- Visualisation et export CSV de l'historique.
- Suppression par plage ou complète.

### ✨ Expérience utilisateur
- Confettis et sons à la fin d'un Pomodoro.
- Apparition aléatoire de Pokémon (gifs).
- Thème clair ou sombre mémorisé localement.
- Animations modernes.

---

## ⌨️ Raccourcis clavier

| Raccourci | Action                          |
|----------|----------------------------------|
| `Espace` | Démarrer / Pause                 |
| `R`      | Réinitialiser le timer           |
| `1`      | Session de Focus                 |
| `2`      | Pause courte                     |
| `3`      | Pause longue                     |
| `S`      | Ouvrir les Paramètres            |
| `?`      | Afficher la fiche d'aide         |

---

## 🧱 Structure du projet

```bash
lib/
├── main.dart
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
│   ├── app_blocker_service.dart
│   ├── notification_service.dart
│   └── timer_service.dart
├── widgets/
│   ├── exe_tile.dart
│   ├── header_theme_menu.dart
│   ├── help_dialog.dart
│   ├── home_sidebar.dart
│   ├── session_tile.dart
│   ├── settings_dialog.dart
│   ├── shiny_overlay.dart
│   └── timer_area.dart
```

---

## ⚙️ Installation locale

### Prérequis
- Flutter SDK (version stable)
- Windows 10/11
- Dart \>= 3.0
- Compte Supabase avec les tables `pomodoro_settings` et `pomodoro_sessions`

### Étapes

```bash
git clone https://github.com/ton-user/pomodoro_desktop.git
cd pomodoro_desktop
flutter pub get
flutter run -d windows
```

---

## 🛠️ Génération de l'exécutable `.exe`

```bash
flutter build windows
```

L'exécutable se trouvera dans : `build/windows/runner/Release/pomodoro_desktop.exe`

---

## 📦 Création d'un installateur Windows

### 🧰 Option 1 : NSIS (recommandé)

1. Installer [NSIS](https://nsis.sourceforge.io/Download).
2. Compiler un script `.nsi` tel que :

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

3. Lancer la compilation avec l'outil **Compile NSI script**.

### 📦 Option 2 : Inno Setup

1. Télécharger [Inno Setup](https://jrsoftware.org/isdl.php).
2. Utiliser ce script `.iss` :

```iss
[Setup]
AppName=Pomodoro Desktop
AppVersion=1.0
DefaultDirName={pf}\Pomodoro Desktop
DefaultGroupName=Pomodoro Desktop
OutputDir=dist
OutputBaseFilename=PomodoroInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Pomodoro Desktop"; Filename: "{app}\pomodoro_desktop.exe"
```

3. Compiler avec l'éditeur Inno Setup.

---

## 🧮 Supabase – Structure BDD

### `pomodoro_settings`

| Colonne              | Type    | Description                           |
|----------------------|---------|---------------------------------------|
| `user_id`            | UUID    | Clé primaire (utilisateur)            |
| `focus_duration`     | Integer | Durée Focus en minutes                |
| `short_break_duration` | Integer | Durée de la pause courte              |
| `long_break_duration`  | Integer | Durée de la pause longue              |
| `long_break_every_x` | Integer | Nombre de Focus avant une longue pause |

### `pomodoro_sessions`

| Colonne     | Type      | Description                          |
|-------------|-----------|--------------------------------------|
| `user_id`   | UUID      | Référence à l'utilisateur            |
| `type`      | text      | `focus` / `shortBreak` / `longBreak` |
| `started_at`| timestamp | Début de la session                  |
| `ended_at`  | timestamp | Fin de la session                    |

---

## 📈 Roadmap

- [ ] Statistiques visuelles (heatmaps, graphiques)
- [ ] Mode hors ligne avec persistance locale
- [ ] Blocage d'applications macOS / Linux
- [ ] Thèmes et gifs personnalisables
- [ ] Gestion multicomptes

---

## 👨‍💻 Auteur

Développé par **Alan Riehl**

Licence : MIT
