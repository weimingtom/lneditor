@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist %1.obj del krkr.obj
if exist %1.dll del krkr.dll

: -----------------------------------------
: assemble krkr.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff krkr.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:krkr.def /section:.bss,S /out:krkr.mel krkr.obj rsrc.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\krkr.mel goto ohehe
del \masm32\lneditor\mel\krkr.mel
:ohehe
copy krkr.mel \masm32\lneditor\mel
dir krkr.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:krkr.def /section:.bss,S /out:krkr.mel krkr.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\krkr.mel goto ohehe2
del \masm32\lneditor\mel\krkr.mel
:ohehe2
copy krkr.mel \masm32\lneditor\mel
dir krkr.*
goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this krkr.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this krkr.
echo.
goto TheEnd

:TheEnd

pause
