@echo off

call variables.cmd

rmdir "%gamepath%\mods\%modname%\content\scripts" /s /q
XCOPY "%modpath%\src\" "%gamePath%\mods\%modname%\content\scripts\" /e /s /y
XCOPY "%modpath%\strings\" "%gamePath%\mods\%modname%\content\" /e /s /y
copy "%modpath%\mod-menu.xml" "%gamePath%\bin\config\r4game\user_config_matrix\pc\%modname%.xml" /y

if "%1"=="-dlc" (
  echo copying DLC
  rmdir "%gamePath%\dlc\dlc%modName%" /s /q
  xcopy "%modPath%\release\dlc" "%gamepath%\dlc" /e /s /y
)