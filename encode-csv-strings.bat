:: encode the strings from the csv file in /strings and creates all the
:: w3strings files

call variables.cmd

@echo off
cd mods\modCombatSkill\content

del *.w3strings
%modkitpath%\w3strings --encode en.w3strings.csv --id-space 5312

del *.ws
rename en.w3strings.csv.w3strings en.w3strings

cd ../../../