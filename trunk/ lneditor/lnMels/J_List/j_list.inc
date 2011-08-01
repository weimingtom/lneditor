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
      
	include \masm32\lneditor\plugin.inc
	include \masm32\lneditor\export.inc
	include \masm32\lneditor\rsrc.inc
	include \masm32\lneditor\config.inc
	includelib \masm32\lneditor\lnedit.lib
	
JlistIndexData struc
	lpDist		dd		?
	nDist		dd		?
	lpOffset		dd		?
	nOffset		dd		?
JlistIndexData ends

.data?
	hInstance		dd		?
	hHeap		dd		?

	dwTemp		dd		?
.const
	ddTable\
		dd		0fch,0fdh,0fdh,7,0,1,0fdh,0ffh,2,0ffh,1,2,3,0fch,0fch,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,0ff04h,4,0ff07h,1,0ff09h,2,0ff02h,5,4,0fch,0fch,0fch,0fch,0fch,0fch
		dd		4,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch	;3
		dd		0fch,0fe03h,0fefe04h,0ff06h,4,4,0ff09h,2,0ff0ah,3,4,0ch,2,5,4,4
		dd		0ffh,5,2,0ff05h,0ffh,1,1,9,8,0ffh,0fch,0fch,0fch,0fch,0fch,0fch
		dd		1,0ff01h,1,3,6,5,0bh,2,7,2,0fch,0fch,0fch,0fch,0fch,0fch		;6
		dd		2,0ff01h,2,0ff09h,2,9,9,9,8,1,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,2,3,1,1,2,2,3,3,1,1,1,3,1,1,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch		;9
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,5,0ff02h,2,0ch,2,0ff02h,0ff05h,3,0fch,0ff04h,1,4,2,1,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch		;c
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0ffh,0fch,1,1,2,1,2,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0h		;f
		
	ddTable2\
		dd		0fch,0fdh,0fdh,7,0,1,0fdh,0ffh,2,0ffh,1,2,3,0fch,0fch,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,0ff04h,4,0ff07h,1,0ff09h,2,0ff02h,5,4,0fch,0fch,0fch,0fch,0fch,0fch
		dd		4,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch	;3
		dd		0fch,0fe03h,0fefe04h,0ff06h,4,4,0ff09h,2,0ff0ah,3,4,0ch,2,5,4,4
		dd		0ffh,5,2,0ff05h,0ffh,1,1,0fch,8,0ffh,0fch,0fch,0fch,0fch,0fch,0fch
		dd		1,0ff01h,1,3,6,5,0fch,2,7,2,0fch,0fch,0fch,0fch,0fch,0fch		;6
		dd		2,0ff01h,2,0ff09h,2,9,0fch,0fch,0fch,1,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,2,3,1,1,2,2,3,3,1,1,1,3,1,1,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch		;9
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,5,0ff02h,2,0fch,2,0ff02h,0ff05h,3,0fch,0ff04h,1,4,2,1,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch		;c
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0ffh,0fch,1,1,2,1,2,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
		dd		0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0h		;f
