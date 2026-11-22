@echo off
setlocal
cd /d "%~dp0"
set "ROJO=%LOCALAPPDATA%\Programs\Rojo\rojo.exe"
if not exist "%ROJO%" (
  echo Rojo nao encontrado. Consulte README.md.
  pause
  exit /b 1
)
if not exist "build" mkdir "build"
"%ROJO%" build "default.project.json" -o "build\Alnair.rbxl"
if errorlevel 1 (
  echo Erro ao compilar Alnair.
  pause
  exit /b 1
)
start "" "%CD%\build\Alnair.rbxl"
echo Alnair aberto no Roblox Studio.
