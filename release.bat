call variables.cmd
call bundle.bat
call encode-csv-strings.bat

rmdir "%modpath%\release" /s /q
mkdir "%modpath%\release"
mkdir "%modpath%\release\mods"

:: mod content
:: copy the mods from /src to /release/mods
XCOPY "%modpath%\src\" "%modpath%\release\mods" /e /s /y

:: mod strings
XCOPY "%modpath%\strings\" "%modpath%\release\mods\%modname%\content\" /e /s /y

:: DLC content
@REM XCOPY "%modpath%\wk-project\packed\" "%modpath%\release\dlc\dlc%modname%\" /e /s /y
XCOPY "%modpath%\light-dlc\" "%modpath%\release\dlc\" /e /s /y

:: mod menu
mkdir "%modpath%\release\bin\config\r4game\user_config_matrix\pc\"
copy "%modPath%\mod-menu.xml" "%modpath%\release\bin\config\r4game\user_config_matrix\pc\%modname%.xml" /y

:: generate merges using cahirp
tw3-cahirp build --game "%gamePath%" --recipes "%modpath%/release/mods/%modname%/cahirp" --out "%modpath%/release/mods/%modname%/content/scripts"

tree %modpath%/release /F