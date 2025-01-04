@echo off
setlocal enabledelayedexpansion

set CUR_PATH=%cd%
set FOLDER_PATH="%CUR_PATH%\@NWGS"
set FINAL_PATH="%CUR_PATH%\@NWGS\addons\nwgs"
set SECRETS_FILE="%CUR_PATH%\SCRIPTS\secrets.h"

echo "####     Servermod     ####"
echo "CUR_PATH: %CUR_PATH%"
echo "FOLDER_PATH: %FOLDER_PATH%"
echo ""

if not exist %FOLDER_PATH% (
    echo "####     BUILDING     ####"

    rem Check secrets.h password
    if exist %SECRETS_FILE% (
        set /p first_line=<%SECRETS_FILE%
        set "default_password=#define SERVER_COMMAND_PASSWORD "YourPasswordHere""

        if "!first_line!"=="!default_password!" (
            echo.
            rem Display warning in separate cmd window and wait for it
            start /wait cmd /c "color 0e && echo ************************************************** && echo *                   WARNING                      * && echo * STOP! You forgot to change server password    * && echo * to actual value. Update secrets.h      * && echo ************************************************** && pause"
            exit /b 1
        )
    )

    rem Build destination folders
    mkdir %FOLDER_PATH%
    mkdir %FOLDER_PATH%\addons
    mkdir %FOLDER_PATH%\addons\nwgs
    rem Copy config files
    copy "%CUR_PATH%\DATASETS\Server\Servermod\mod.cpp.tmp" %FOLDER_PATH%\mod.cpp
    copy "%CUR_PATH%\DATASETS\Server\Servermod\config.cpp.tmp" %FINAL_PATH%\config.cpp
    rem Move servermode folders to new location
    move /y "%CUR_PATH%\DATASETS" %FINAL_PATH%
    move /y "%CUR_PATH%\SCRIPTS" %FINAL_PATH%
    move /y "%CUR_PATH%\initScriptsCompilation.sqf" %FINAL_PATH%
) else (
    echo "####     UNBUILDING     ####"
    rem Move servermode folders back to an old location
    move /y "%CUR_PATH%\@NWGS\addons\nwgs\DATASETS" "%CUR_PATH%"
    move /y "%CUR_PATH%\@NWGS\addons\nwgs\SCRIPTS" "%CUR_PATH%"
    move /y "%CUR_PATH%\@NWGS\addons\nwgs\initScriptsCompilation.sqf" "%CUR_PATH%"

    @RD /S /Q %FOLDER_PATH%
)

pause
exit /b %ERRORLEVEL%