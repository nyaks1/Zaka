@echo off
REM Run the Windows Flutter SDK against this project.
REM Use this from a Windows terminal (PowerShell, cmd, or Git Bash) so builds
REM happen on the Windows side, where Flutter and Visual Studio live.
cd /d "%~dp0.."
flutter %*
