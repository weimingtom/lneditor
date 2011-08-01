@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist %1.obj del j_list.obj
if exist %1.dll del j_list.dll

: -----------------------------------------
: assemble j_list.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff j_list.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:j_list.def /section:.bss,S /out:j_list.mel j_list.obj rsrc.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\j_list.mel goto ohehe
del \masm32\lneditor\mel\j_list.mel
:ohehe
copy j_list.mel \masm32\lneditor\mel
dir j_list.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS /Dll /Def:j_list.def /section:.bss,S /out:j_list.mel j_list.obj
if errorlevel 1 goto errlink
if not exist \masm32\lneditor\mel\j_list.mel goto ohehe2
del \masm32\lneditor\mel\j_list.mel
:ohehe2
copy j_list.mel \masm32\lneditor\mel
dir j_list.*
goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this j_list.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this j_list.
echo.
goto TheEnd

:TheEnd

pause
