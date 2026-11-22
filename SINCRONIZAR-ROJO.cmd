@echo off
setlocal
cd /d "%~dp0"
set "ROJO=%LOCALAPPDATA%\Programs\Rojo\rojo.exe"
if not exist "%ROJO%" (
  echo Rojo nao encontrado. Consulte README.md.
  pause
  exit /b 1
)
echo Iniciando sincronizacao com Roblox Studio...
echo No Studio, abra a aba Plugins, encontre Rojo e clique em Connect.
echo Para encerrar o servidor, pressione Ctrl+C.
"%ROJO%" serve default.project.json
pause
