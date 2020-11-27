@echo off

call variables.cmd

rmdir "%gamepath%\mods\%modname%\content\scripts"
XCOPY "%modpath%\src\local\" "%gamePath%\mods\%modname%\content\scripts\%modname%_local\" /e /s /y
XCOPY "%modpath%\strings\" "%gamePath%\mods\%modname%\content\" /e /s /y
copy "%modpath%\mod-menu.xml" "%gamePath%\bin\config\r4game\user_config_matrix\pc\%modname%.xml" /y