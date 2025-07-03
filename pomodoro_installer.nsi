; NSIS script for Pomodoro Desktop

Name "Pomodoro Desktop"
OutFile "PomodoroDesktopInstaller.exe"
InstallDir "$PROGRAMFILES\PomodoroDesktop"
RequestExecutionLevel admin

Page directory
Page instfiles

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "build\windows\x64\runner\Release\*.*"
  CreateShortCut "$DESKTOP\Pomodoro Desktop.lnk" "$INSTDIR\pomodoro_desktop.exe"
SectionEnd