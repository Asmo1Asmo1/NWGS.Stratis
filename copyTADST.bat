@echo off
set "address_from=D:\Documents\Arma 3 - Other Profiles\Asmo\mpmissions\NWGS.Stratis"
set "address_to=D:\BigGames\Steam\steamapps\common\Arma 3\MPMissions\NWGS.Stratis"

echo Copy started...
xcopy /E /Y "%address_from%" "%address_to%"

echo Copy finished...