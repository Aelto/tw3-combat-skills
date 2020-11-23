@echo off

call variables.cmd

XCOPY "modCombatSkill\" "%gamePath%\mods\modCombatSkill\" /e /s /y
