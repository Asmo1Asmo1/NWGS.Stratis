@echo off
set CUR_PATH=%cd%
set FOLDER_PATH="%CUR_PATH%\@NWGS"
set FINAL_PATH="%CUR_PATH%\@NWGS\addons\nwgs"

echo "####     Servermod     ####"
echo "CUR_PATH: %CUR_PATH%"
echo "FOLDER_PATH: %FOLDER_PATH%"
echo ""

if not exist %FOLDER_PATH% (
	echo "####     BUILDING     ####"
	:: Build destination folders
	mkdir %FOLDER_PATH%
	mkdir %FOLDER_PATH%\addons
	mkdir %FOLDER_PATH%\addons\nwgs
	:: Copy config files
	copy "%CUR_PATH%\DATASETS\Server\Servermod\mod.cpp.tmp" %FOLDER_PATH%\mod.cpp
	copy "%CUR_PATH%\DATASETS\Server\Servermod\config.cpp.tmp" %FINAL_PATH%\config.cpp
	:: Move servermode folders to new location
	move /y "%CUR_PATH%\DATASETS" %FINAL_PATH%
	move /y "%CUR_PATH%\SCRIPTS" %FINAL_PATH%
	move /y "%CUR_PATH%\initScriptsCompilation.sqf" %FINAL_PATH%
) else (
	echo "####     UNBUILDING     ####"
	:: Move servermode folders back to an old location
	move /y "%CUR_PATH%\@NWGS\addons\nwgs\DATASETS" "%CUR_PATH%"
	move /y "%CUR_PATH%\@NWGS\addons\nwgs\SCRIPTS" "%CUR_PATH%"
	move /y "%CUR_PATH%\@NWGS\addons\nwgs\initScriptsCompilation.sqf" "%CUR_PATH%"

	@RD /S /Q %FOLDER_PATH%
)

pause
exit /b %ERRORLEVEL%