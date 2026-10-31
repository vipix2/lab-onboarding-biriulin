@echo off
chcp 1251 >nul
setlocal

REM ============================================================
REM Практическая работа: Диагностика клиентского компьютера
REM Автор: Бирюлин
REM Дата: 31.10.2026
REM wmic в новых Windows удалён, поэтому данные берутся через
REM Get-CimInstance (тот же WMI, вызывается из PowerShell).
REM ============================================================

REM --- Файл отчёта лежит рядом с pc_info.bat ---
set "REPORT=%~dp0pc_report.txt"
type nul > "%REPORT%"

REM --- Заголовок ---
call :out "============================================"
call :out "         Диагностика компьютера"
call :out "============================================"
call :out ""

REM --- Сведения об операционной системе ---
call :out "Операционная система"
call :out "--------------------------------------------"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do call :out "Название: %%a"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version"`) do call :out "Версия:   %%a"
call :out ""

REM --- Сведения о процессоре ---
call :out "Процессор"
call :out "--------------------------------------------"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"`) do call :out "%%a"
call :out ""

REM --- Сведения об оперативной памяти (КБ -> ГБ, с округлением) ---
call :out "Оперативная память"
call :out "--------------------------------------------"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize"`) do set "RAM_TOTAL_KB=%%a"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory"`) do set "RAM_FREE_KB=%%a"
set /a RAM_TOTAL=(%RAM_TOTAL_KB% + 524288) / 1048576
set /a RAM_FREE=(%RAM_FREE_KB% + 524288) / 1048576
call :out "Всего памяти: %RAM_TOTAL% ГБ"
call :out "Свободно памяти: %RAM_FREE% ГБ"
call :out ""

REM --- Свободное место на диске C (байты -> ГБ) ---
REM set /a работает только с 32-битными числами, поэтому у значения
REM отбрасываются последние 6 цифр (получаются миллионы байт),
REM а затем делением на 1073,74 получаем гигабайты.
call :out "Диск C"
call :out "--------------------------------------------"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-Volume -DriveLetter C).Size"`) do set "DISK_SIZE=%%a"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-Volume -DriveLetter C).SizeRemaining"`) do set "DISK_FREE_B=%%a"
set "SIZE_M=%DISK_SIZE:~0,-6%"
set "FREE_M=%DISK_FREE_B:~0,-6%"
set /a DISK_TOTAL=SIZE_M * 100 / 107374
set /a DISK_FREE=FREE_M * 100 / 107374
call :out "Общий размер: %DISK_TOTAL% ГБ"
call :out "Свободно: %DISK_FREE% ГБ"
call :out ""

REM --- Список установленных программ (через реестр) ---
call :out "Установленные программы"
call :out "--------------------------------------------"
for %%K in ("HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall") do (
    for /f "tokens=2,*" %%a in ('reg query %%K /s 2^>nul ^| findstr /R /C:"^ *DisplayName  *REG_SZ"') do (
        echo %%b
        >>"%REPORT%" echo %%b
    )
)
call :out ""

REM --- Сообщение о сохранении отчёта ---
call :out "============================================"
echo Отчёт сохранён: %REPORT%
>>"%REPORT%" echo Отчёт сохранён
echo.

REM --- Пауза, чтобы окно не закрылось сразу ---
pause
exit /b

REM --- Подпрограмма: вывод строки в окно и в файл отчёта ---
:out
echo(%~1
>>"%REPORT%" echo(%~1
goto :eof
