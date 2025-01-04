@echo off
set CUR_PATH=%cd%
set "address_to=C:\Games\Steam\steamapps\common\Arma 3\MPMissions\NWGS.Stratis"

echo Copy started...
xcopy /E /Y "%CUR_PATH%" "%address_to%"

echo Copy finished...