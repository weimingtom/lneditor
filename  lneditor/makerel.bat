@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist lnrc.rc goto over1
\MASM32\BIN\Rc.exe /v lnrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 lnrc.res
:over1

if exist lnedit.obj del lnedit.obj
if exist lnedit.exe del lnedit.exe
if exist lnedit.pdb del lnedit.pdb
if exist lnedit.ilk del lnedit.ilk

: -----------------------------------------
: assemble lnedit.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff lnedit.asm
if errorlevel 1 goto errasm

if not exist lnrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /DEF:export.def lnedit.obj lnrc.obj
if errorlevel 1 goto errlink
dir lnedit.*
incver
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS lnedit.obj
if errorlevel 1 goto errlink
dir lnedit.*
incver.exe
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
