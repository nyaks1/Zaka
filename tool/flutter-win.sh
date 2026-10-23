#!/usr/bin/env bash
# Run the Windows Flutter SDK from inside WSL.
#
# Windows Flutter cannot build a project that lives on the WSL filesystem
# (plugin symlinks fail), so the project is kept on the Windows drive and this
# wrapper runs the Windows `flutter.bat` against it.
#
# Examples:
#   tool/flutter-win.sh pub get
#   tool/flutter-win.sh test
#   tool/flutter-win.sh analyze
#   tool/flutter-win.sh run -d chrome
#   tool/flutter-win.sh build web --release
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_win="$(wslpath -w "$project_dir")"

# The project path has no spaces (C:\src\projects\Zaka), so it can be passed
# to cmd.exe without nested quotes, which WSL interop handles poorly.
cmd.exe /c "cd /d ${project_win} && flutter $*"
