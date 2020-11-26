@echo off

call variables.cmd

XCOPY "mods\modCombatSkill\" "%gamePath%\mods\modCombatSkill\" /e /s /y
XCOPY "bin\" "%gamePath%\bin\" /e /s /y