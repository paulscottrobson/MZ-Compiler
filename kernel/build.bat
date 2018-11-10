@echo off
pushd ..\bootloader
call build.bat
popd
rem
rem	Tidy up
rem
del /Q __words.asm 
del /Q boot.img 
del /Q ..\files\boot.img
rem
rem	Assemble the kernel file.
rem
python ..\scripts\buildwords.py 48k
..\bin\snasm -next -vice kernel.asm boot.img
rem
rem	Create the core dictionary.
rem
if exist boot.img	python ..\scripts\makedictionary.py
rem
rem Copy to files area.
rem
if exist boot.img 	copy boot.img ..\files\boot.img
