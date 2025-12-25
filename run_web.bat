@echo off
echo Menjalankan Aplikasi di Browser Default...
start "" "http://localhost:5555"
flutter run -d web-server --web-hostname localhost --web-port 5555

