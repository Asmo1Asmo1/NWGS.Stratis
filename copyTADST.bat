@echo off
setlocal enabledelayedexpansion

set CUR_PATH=%cd%
set "address_to=C:\Games\Steam\steamapps\common\Arma 3\MPMissions\NWGS.Stratis"

echo Cleaning target directory...
if exist "%address_to%" (
    pushd "%address_to%"
    for /d %%d in (*) do rd /s /q "%%d"
    del /q *
    popd
) else (
    mkdir "%address_to%"
)

echo Copy started...

rem Copy folders (excluding those starting with . or @)
for /d %%d in ("%CUR_PATH%\*") do (
    set "foldername=%%~nxd"
    echo !foldername! | findstr /b /i "[.@]" > nul
    if errorlevel 1 (
        xcopy /E /I /Y "%%d" "%address_to%\%%~nxd"
    )
)

rem Copy files in root (excluding specified extensions and . files)
for %%f in ("%CUR_PATH%\*.*") do (
    set "filename=%%~nxf"
    set "ext=%%~xf"
    set "skip="

    rem Skip files starting with .
    echo !filename! | findstr /b "\." > nul
    if not errorlevel 1 (
        set "skip=1"
    ) else (
        rem Skip files with specific extensions
        if /i "!ext!"==".bat" set "skip=1"
        if /i "!ext!"==".py" set "skip=1"
        if /i "!ext!"==".txt" set "skip=1"
        if /i "!ext!"==".md" set "skip=1"
        if /i "!filename:~-14!"=="code-workspace" set "skip=1"
    )

    if not defined skip (
        xcopy /Y "%%f" "%address_to%"
    )
)

echo Copy finished...