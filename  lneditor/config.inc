;Pre-Defined CONST

;Edit Mode
EM_SINGLE			EQU 	1
EM_DOUBLE			EQU 	2

;New Script Save Location
NL_CURRENT			EQU		1
NL_EXE				EQU		2

;Auto Convert
AC_NOT				EQU		0
AC_FULLANGLE		EQU		1
AC_HALFANGLE		EQU		2

;windowRect Index
WRI_MAIN			EQU		0
WRI_LIST1			EQU		16
WRI_LIST2			EQU		32
WRI_EDIT1			EQU		48
WRI_EDIT2			EQU		64
WRI_STATUS			EQU		80


;Config Struct
_Configs struct
	nEditMode			dd			?
	nAutoSaveTime		dd			?
	nNewLoc				dd			?
	nAutoConvert			dd			?
	bAutoOpen			dd			?
	bSaveInChLine		dd			?;
	bAutoSelText			dd			?
	lpDefaultMel			dd			?
	lpInitDir1				dd			?;
	lpInitDir2				dd			?;
	lpNewScDir			dd			?
	lpPrevFile			dd			?
	
	lpBackName			dd			?;
	TextColorSelected		dd			?
	TextColorDefault		dd			?;
	TextColorEdit			dd			?
	LineColor			dd			?
	HiColorDefault		dd			?
	HiColorMarked		dd			?	
	listFont				LOGFONT	<?>
	db	32	dup(?)
	editFont				LOGFONT	<?>
	db	32	dup(?)
		
	windowRect			RECT		6					dup(<?>)
_Configs ends


