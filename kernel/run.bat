@echo off
call build.bat
copy ..\files\bootloader.sna .
python ..\scripts\mzc.py test.mz
..\bin\CSpect.exe -zxnext -cur -brk -exit -w3 bootloader.sna 