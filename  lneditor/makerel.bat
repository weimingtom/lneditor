@echo off
"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\rc.exe" /v lnrc.rc
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\cvtres.exe" /machine:ix86 lnrc.res

if exist lnedit.obj del lnedit.obj
if exist lnedit.exe del lnedit.exe
if exist lnedit.pdb del lnedit.pdb
if exist lnedit.ilk del lnedit.ilk

: -----------------------------------------
: assemble lnedit.asm into an OBJ file
: -----------------------------------------
:path of assembler of VS2010
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\Ml.exe" /c /coff lnedit.asm
if errorlevel 1 goto errasm

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
:set path of VS2010 common tools
set path=C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
:path of linker of VS2010
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\Link.exe" /ltcg /SUBSYSTEM:WINDOWS /DEF:export.def lnedit.obj lnrc.obj lnedit2.lib
if errorlevel 1 goto errlink
dir lnedit.*
copy lnedit.exe bin\lnedit.exe
goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this lnedit.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this lnedit.
echo.
goto TheEnd

:TheEnd

pause
