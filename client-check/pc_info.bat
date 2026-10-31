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

REM — Файл отчёта лежит рядом с pc_info.bat —
set «REPORT=%~dp0pc_report.txt»
type nul > «%REPORT%»

REM — Заголовок —
call :out «============================================«
call :out «         Диагностика компьютера»
call :out «============================================«
call :out «»

REM — Сведения об операционной системе —
call :out «Операционная система»
call :out «———————————————«
for /f «usebackq delims=« %%a in (`powershell -NoProfile -Command «(Get-CimInstance Win32_OperatingSystem).Caption»`) do call :out «Название: %%a»
for /f «usebackq delims=« %%a in (`powershell -NoProfile -Command «(Get-CimInstance Win32_OperatingSystem).Version»`) do call :out «Версия:   %%a»
call :out «»

REM — Сведения о процессоре —
call :out «Процессор»
call :out «———————————————«
for /f «usebackq delims=« %%a in (`powershell -NoProfile -Command «(Get-CimInstance Win32_Processor).Name»`) do call :out «%%a»
call :out «»

REM — Сведения об оперативной памяти (КБ -> ГБ, с округлением) —
call :out «Оперативная память»
call :out «———————————————«
for /f «usebackq delims=« %%a in (`powershell -NoProfile -Command «(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize»`) do set «RAM_TOTAL_KB=
