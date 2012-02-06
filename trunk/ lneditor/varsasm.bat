@echo off
rem Set asm env vars.
set "WINDDKDIR=E:\WinDDK\7600.16385.1"
set "MASMPATH=\masm32"
set "COMPILERPATH=F:\Software\VC6\VC10" rem Need ml.exe and link.exe in VC++10
set "ADDITIONALDLLPATH=%COMPILERPATH%" rem Need mspdb100.dll and so on
set "RESCOMPILERPATH=F:\Software\VC6\Common\MSDev98\Bin" rem Need rc.exe

set "LNEDITDIR=%CD%"

if not exist "%WINDDKDIR%" goto ErrPath
if not exist "%MASMPATH%"  goto ErrPath
if not exist "%COMPILERPATH%"  goto ErrPath
if not exist "%RESCOMPILERPATH%"  goto ErrPath

set "LIB=%WINDDKDIR%\lib\wxp\i386;%WINDDKDIR%\lib\crt\i386;%MASMPATH%\lib"

set "LIBPATH=%LIB%"

set "INCLUDE=%MASMPATH%\include;%MASMPATH%\macros;%MASMPATH%\include\w2k"

set "PATH=%COMPILERPATH%;%ADDITIONALDLLPATH%;%RESCOMPILERPATH%;%PATH%"

set PATH_ERROR=0
goto :eof

:ErrPath
set PATH_ERROR=1
goto :eof