@echo off
echo ==========================================
echo Starting farmer ai assistant
echo ==========================================
echo.
echo [1/2] Launching Local Backend Server in new window...
powershell -Command "Get-CimInstance Win32_Process -Filter \"name = 'powershell.exe'\" | Where-Object { $_.CommandLine -like '*server.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
start "farmer ai assistant Dev Server" cmd /k "powershell -ExecutionPolicy Bypass -File bin\server.ps1"

echo.
echo [2/2] Setting up ADB reverse port forwarding...
"%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe" reverse tcp:4040 tcp:4040
echo.
echo [3/3] Launching Flutter App...
flutter run -d chrome
