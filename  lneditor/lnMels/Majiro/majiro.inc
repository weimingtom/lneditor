      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc      
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\include\shlwapi.inc
      include \masm32\macros\macros.asm
      include \masm32\macros\strings.mac

      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\shlwapi.lib
      includelib \masm32\lib\msvcrt.lib
      
	include \masm32\lneditor\export.inc
	include \masm32\lneditor\rsrc.inc
	include \masm32\lneditor\plugin.inc
	include \masm32\lneditor\config.inc
	includelib \masm32\lneditor\lnedit.lib
	

DEFAULT_STRINGLEN	equ		1024
	
_MjoInfo struct
	nDefaultEntry		dd		?
	unk1				dd		?
	nEntryCount		dd		?
	lpEntries			dd		?
	nDataSize			dd		?
	lpData			dd		?
	lpJumpTable		dd		?
_MjoInfo ends

ModifyLine proto :dword,:dword
SaveText proto :dword
Release proto :dword
_memcpy2 proto

.data?
	hInstance		dd		?
	hHeap		dd		?

	dwTemp		dd		?
	
	lpTable1		dd		?
.data
	;-1为普通bf，-2为需要输出的字符串，-3为错误，-4为跳转地址
	OpTable		db
;				0,	1,	2,	3,	4,	5,	6,	7,	8,	9,	A,	B,	C,	D,	E,	F
				4,	-1,	8,	4,	11 dup (-3)									10
				10,	15 dup(-3)
				7 dup (-3)								-1,	-3,	0,	-4,	-4,	-4,	0
				-4,	-4,	-4,	-4,	6,	6,	-1,	8,	-4,	-4,	2,	-4,	-4,	-4,	0,	0
				-2,	0,	-1,	-4,	0,	-4,	0,	-4,	8 dup (-3)
	
	
	
		