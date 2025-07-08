# ⏱️ Pomodoro Desktop App (Flutter)

Application de gestion du temps basée sur la méthode **Pomodoro**, développée en **Flutter Desktop** pour Windows.  
Elle combine minuteur, blocage d’applications, notifications, détection d’inactivité et statistiques synchronisées dans Supabase.

---

## Sommaire
1. [Fonctionnalités](#fonctionnalités)
2. [Structure du projet](#structure-du-projet)
3. [Installation et exécution](#installation-et-exécution)
4. [Supabase et données](#supabase-et-données)
5. [Contribuer](#contribuer)
6. [Auteur](#auteur)

---

## Fonctionnalités

- **Minuteur complet** (Focus, pause courte, pause longue) avec enchaînement automatique.
- **Personnalisation des durées** via une fenêtre de réglages (stockées dans Supabase).
- **Notifications toast** et **son** à la fin d’une session (`flutter_local_notifications`, `audioplayers`).
- **Blocage d’applications** distrayantes (liste d’exécutables surveillés et fermés toutes les 10 s).
- **Détection d’inactivité** : rappel après 5 minutes sans interaction.
- **Statistiques détaillées** (historique, graphiques avec `fl_chart`, export CSV).
- **Onboarding et authentification** (Supabase).
- **Thème clair/sombre/système** mémorisé dans `shared_preferences`.
- **Raccourcis clavier** : Espace pour démarrer/stopper, `R` pour réinitialiser.
- **Animations confettis** et **Pokémon aléatoire** à la fin d’une session réussie.
- **Script NSIS** pour générer un installeur Windows.

---

## Structure du projet
```
lib/
├── main.dart # Démarrage de l’app et initialisation Supabase
├── router.dart # Navigation avec GoRouter
├── screens/ # Interfaces (auth, onboarding, home, stats…)
│ ├── splash_screen.dart
│ ├── onboarding_screen.dart
│ ├── auth_screen.dart
│ ├── signup_screen.dart
│ ├── home_screen.dart
│ ├── statistics_screen.dart
│ └── app_blocker_settings_dialog.dart
├── services/ # Logique métier
│ ├── timer_service.dart
│ ├── notification_service.dart
│ ├── app_blocker_service.dart
│ ├── activity_service.dart
│ └── theme_service.dart
├── models/
│ └── pomodoro_settings.dart # Paramètres utilisateur
├── widgets/
│ ├── circular_timer_display.dart
│ └── timer_display.dart
└── assets/
├── sounds/success.mp3
└── gif/ (animations Pokémon)

test/ # Exemple de test Flutter
pomodoro_installer.nsi # Script d’installation Windows (NSIS)
analysis_options.yaml # Règles de lint
```


---

## Installation et exécution

1. **Prérequis** : Flutter SDK (canal stable) avec support Windows activé.
2. Clonez le dépôt puis installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancement en mode développement (Windows) :
    ```bash
    flutter run -d windows
    ```
4. Génération de l’exécutable :
    ```bash
    flutter build windows
    ```
5. Création de l’installeur (nécessite NSIS) :
    ```bash
    makensis pomodoro_installer.nsi
    ```
## Supabase et données
L’application utilise Supabase pour l’authentification et la sauvegarde des réglages et sessions.
Les identifiants sont actuellement déclarés dans lib/main.dart; pour un déploiement réel, il est recommandé de les stocker dans des variables d’environnement ou un fichier non suivi par Git.

Les statistiques sont récupérées via TimerService.fetchSessionHistory() et affichées dans StatisticsScreen.
Un bouton permet d’exporter l’historique des sessions au format CSV.

## Contribuer
1. Forkez ce dépôt et créez votre branche de travail.

2. Assurez-vous de respecter les règles de lint (flutter analyze).

3. Proposez un Pull Request clair décrivant vos modifications.

## Auteur
Alan 


