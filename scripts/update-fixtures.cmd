@echo off
setlocal enabledelayedexpansion

REM Daily check of cfa.com.cy for newly announced fixtures.
REM Fills exact dates/kickoff times into APOEL_calendar.ics, then commits and pushes.
REM Run by Windows Task Scheduler; see scripts\README.md.

set "REPO=C:\APOEL_calendar"
set "PROMPT=%REPO%\scripts\update-fixtures-prompt.md"
set "LOGDIR=%REPO%\scripts\logs"

if not exist "%LOGDIR%" mkdir "%LOGDIR%"
for /f "tokens=1-3 delims=/-. " %%a in ("%DATE%") do set "STAMP=%%c%%b%%a"
set "LOG=%LOGDIR%\run-%STAMP%.log"

REM Locate the Claude CLI bundled with the VS Code extension (newest install wins).
set "CLAUDE="
for /f "delims=" %%D in ('dir /b /ad /o-d "%USERPROFILE%\.vscode\extensions\anthropic.claude-code-*win32-x64" 2^>nul') do (
    if not defined CLAUDE set "CLAUDE=%USERPROFILE%\.vscode\extensions\%%D\resources\native-binary\claude.exe"
)

if not defined CLAUDE (
    echo [%DATE% %TIME%] ERROR: Claude CLI not found. Is the VS Code extension installed? >> "%LOG%"
    exit /b 1
)
if not exist "%CLAUDE%" (
    echo [%DATE% %TIME%] ERROR: Claude CLI missing at "%CLAUDE%" >> "%LOG%"
    exit /b 1
)

cd /d "%REPO%" || exit /b 1

echo. >> "%LOG%"
echo ======================================== >> "%LOG%"
echo [%DATE% %TIME%] Starting fixture check >> "%LOG%"
echo Using: %CLAUDE% >> "%LOG%"

REM Start from the remote state so we never push onto a stale checkout.
git pull --rebase --quiet origin main >> "%LOG%" 2>&1
if errorlevel 1 (
    echo [%DATE% %TIME%] ERROR: git pull failed - aborting so nothing is overwritten. >> "%LOG%"
    exit /b 1
)

type "%PROMPT%" | "%CLAUDE%" -p ^
    --model claude-sonnet-5 ^
    --allowedTools "Read" "Edit" "WebFetch(domain:www.cfa.com.cy)" "Bash(git diff:*)" "Bash(git status:*)" "Bash(git add:*)" "Bash(git commit:*)" "Bash(git push:*)" "Bash(git log:*)" ^
    >> "%LOG%" 2>&1

echo [%DATE% %TIME%] Finished with exit code %ERRORLEVEL% >> "%LOG%"
endlocal
