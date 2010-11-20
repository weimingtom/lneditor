@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist %1.obj del musica.obj
if exist %1.dll del musica.dll

: -----------------------------------------
: assemble musica.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff musica.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:musica.def /section:.bss,S /out:musica.mel musica.obj rsrc.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\musica.mel goto ohehe
del \masm32\lneditor\mel\musica.mel
:ohehe
copy musica.mel \masm32\lneditor\mel
dir musica.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:musica.def /section:.bss,S /out:musica.mel musica.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\musica.mel goto ohehe2
del \masm32\lneditor\mel\musica.mel
:ohehe2
copy musica.mel \masm32\lneditor\mel
dir musica.*
goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this musica.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this musica.
echo.
goto TheEnd

:TheEnd

pause
