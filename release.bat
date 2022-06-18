call variables.cmd
call bundle.bat
call encode-csv-strings.bat

rmdir "%modpath%\release" /s /q
mkdir "%modpath%\release"

mkdir "%modpath%\release\mods\%modname%\content\scripts\local\
mkdir "%modpath%\release\mods\%modname%\content\scripts\game\"
XCOPY "%modpath%\src\game\" "%modpath%\release\mods\%modname%\content\scripts\game\" /e /s /y
> "%modpath%\release\mods\%modname%\content\scripts\local\combatskills_scripts.min.ws" (for /r "%modpath%\src\local" %%F in (*.ws) do @type "%%F")
XCOPY "%modpath%\strings\" "%modpath%\release\mods\%modname%\content\" /e /s /y

:: DLC content
@REM XCOPY "%modpath%\wk-project\packed\" "%modpath%\release\dlc\dlc%modname%\" /e /s /y
XCOPY "%modpath%\light-dlc\" "%modpath%\release\dlc\" /e /s /y

mkdir "%modpath%\release\bin\config\r4game\user_config_matrix\pc\"
copy "%modPath%\mod-menu.xml" "%modpath%\release\bin\config\r4game\user_config_matrix\pc\%modname%.xml" /y
