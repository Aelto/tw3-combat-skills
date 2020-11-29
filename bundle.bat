@echo off

call variables.cmd

cd %modkitpath%

rmdir "%modpath%\wk-project\packed\content\" /s /q
mkdir "%modpath%\wk-project\packed\content\"

call wcc_lite.exe pack -dir=%modpath%\wk-project\files\mod\cooked\ -outdir=%modpath%\wk-project\packed\content\
call wcc_lite.exe metadatastore -path=%modpath%\wk-project\packed\content\

cd %modpath%