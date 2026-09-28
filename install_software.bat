@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title Автоматическая установка ПО для компьютерного класса

echo ============================================================
echo       АВТОМАТИЧЕСКАЯ УСТАНОВКА ПРОГРАММ
echo ============================================================
echo.

:: Проверка запуска от имени администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ОШИБКА] Запустите скрипт от имени Администратора!
    echo.
    pause
    exit /b 1
)

set "OK_COUNT=0"
set "FAIL_COUNT=0"

echo [1/4] Проверка и установка Chocolatey
echo.

:: Проверяем наличие Chocolatey
where choco >nul 2>&1

if %errorLevel% neq 0 (
    echo Chocolatey не найден. Начинаем установку...
    echo.

    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

    set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

    where choco >nul 2>&1

    if !errorLevel! neq 0 (
        echo [ОШИБКА] Не удалось установить Chocolatey.
        echo Проверьте подключение к Интернету.
        echo.
        pause
        exit /b 2
    )

    echo Chocolatey успешно установлен.
) else (
    echo Chocolatey уже установлен:
    choco --version
)

echo.
echo ============================================================
echo [2/4] Установка средств разработки
echo ============================================================
echo.

call :install "Visual Studio Code" "vscode"
call :install "Docker Desktop" "docker-desktop"
call :install "PyCharm Community Edition" "pycharm-community"
call :install "GitHub Desktop" "github-desktop"

echo.
echo ============================================================
echo [3/4] Установка учебного и научного ПО
echo ============================================================
echo.

call :install "Maxima" "maxima"
call :install "GIMP" "gimp"
call :install "Zettlr" "zettlr"
call :install "Anaconda" "anaconda3"

echo.
echo ============================================================
echo [4/4] Установка служебных программ
echo ============================================================
echo.

call :install "Far Manager" "far"
call :install "7-Zip" "7zip"
call :install "Mozilla Firefox" "firefox"

echo.
echo ============================================================
echo                 УСТАНОВКА ЗАВЕРШЕНА
echo ============================================================
echo.

echo Успешно обработано: !OK_COUNT!
echo Ошибок:             !FAIL_COUNT!
echo.

if !FAIL_COUNT! EQU 0 (
    echo Все программы успешно установлены.
) else (
    echo ВНИМАНИЕ!
    echo Некоторые программы не удалось установить.
    echo Проверьте сообщения выше.
)

echo.
echo Для просмотра установленных пакетов Chocolatey:
echo choco list --local-only
echo.

pause
exit /b 0


:: ============================================================
:: Процедура установки программы
:: ============================================================

:install

echo ------------------------------------------------------------
echo Установка: %~1
echo Пакет Chocolatey: %~2
echo ------------------------------------------------------------

choco install %~2 -y --no-progress

if !errorLevel! EQU 0 (
    echo [OK] %~1
    set /a OK_COUNT+=1
) else (
    echo [ОШИБКА] %~1
    set /a FAIL_COUNT+=1
)

echo.
exit /b 0