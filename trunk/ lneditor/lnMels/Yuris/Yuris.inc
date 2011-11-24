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
	
YurisHdr struct
	sMagic		dd		?
	nVersion		dd		?
	nCount		dd		?
	nCodeSize		dd		?
	nArgSize		dd		?
	nResSize		dd		?
	nOffSize		dd		?
	dwResvd		dd		?
YurisHdr ends

YurisArg struct
	value		dw		?
	type1		dw		?
	len1			dd		?
	offset1		dd		?
YurisArg ends

YurisVerInfo struct
	nVerMin		dd		?
	nVerMax		dd		?
	opMsg		dw		?
	opCall		dw		?
YurisVerInfo ends

FUNC_SEL		EQU		1
FUNC_MARKSET	EQU		2
FUNC_CHARNAME	EQU		3
FUNC_INPUTSTR	EQU		4

.data?
	hInstance		dd		?
	hHeap		dd		?

	dwTemp		dd		?
.const
	dbFSel			db		4Dh,0Ch,0,'"ES.SEL.SET"'
align 4
	dbFMarkSet		db		4dh,17h,0,'"es.CHAR.NAME.MARK.SET"'
align 4
	dbFCharName	db		4dh,0eh,0,'"es.CHAR.NAME"'
align 4
	dbFInputStr		db		4dh,12h,0,'"es.INPUT.STR.SET"'
	
	
	VerTable\
				YurisVerInfo		<12ch,199h,015ah,1dh>
				YurisVerInfo		<1f4h,1f4h,015ah,1dh>
				YurisVerInfo		<1c2h,226h,015bh,1dh>
	nVerInfos	dd		(offset nVerInfos-offset VerTable)/sizeof(YurisVerInfo)
		