@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "BROWSER="
for %%P in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%LocalAppData%\Google\Chrome\Application\chrome.exe") do (
    if not defined BROWSER if exist %%P set "BROWSER=%%~P"
)

if not defined BROWSER (
    echo Could not find Microsoft Edge or Google Chrome.
    pause
    exit /b 1
)

if not exist "%~dp0pdfs" mkdir "%~dp0pdfs"

set "PROFILE=%TEMP%\html2pdf_profile"
set /a OK=0
set /a FAIL=0

echo Converting HTML files in: %~dp0
echo.

for %%F in (*.htm*) do (
    set "EXT=%%~xF"
    if /i "!EXT!"==".html" call :convert "%%F"
    if /i "!EXT!"==".htm" call :convert "%%F"
)

if exist "%PROFILE%" rmdir /s /q "%PROFILE%" >nul 2>&1

echo.
echo Done. !OK! converted, !FAIL! failed.
echo PDFs are in: %~dp0pdfs
echo.
pause
exit /b 0

:convert
echo Converting: %~1
set "URL=%~f1"
set "URL=!URL:\=/!"
set "URL=!URL: =%%20!"
set "BASE=%~n1"
call :unique
start "" /wait "!BROWSER!" --headless --disable-gpu --no-pdf-header-footer --user-data-dir="!PROFILE!" --print-to-pdf="!OUT!" "file:///!URL!" >nul 2>&1
if exist "!OUT!" (
    set /a OK+=1
) else (
    echo    FAILED: %~1
    set /a FAIL+=1
)
exit /b 0

:unique
set "OUT=%~dp0pdfs\!BASE!.pdf"
set /a N=0
:unique_loop
if exist "!OUT!" (
    set /a N+=1
    set "OUT=%~dp0pdfs\!BASE! (!N!).pdf"
    goto unique_loop
)
exit /b 0
