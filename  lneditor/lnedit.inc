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
      include \masm32\include\version.inc
      include \masm32\include\shlwapi.inc
      include \masm32\macros\macros.asm
      include \masm32\macros\strings.mac
	include \masm32\include\ole32.inc
	include \masm32\include\msimg32.inc

      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\msvcrt.lib
      includelib \masm32\lib\version.lib
      includelib \masm32\lib\shlwapi.lib
	includelib \masm32\lib\ole32.lib
	includelib \masm32\lib\msimg32.lib
	

	include rsrc.inc

TOTAL_STRINGNUM	EQU		100
SHORT_STRINGLEN	EQU		64
MAX_MELCOUNT		EQU		50
BF_UNDO_SIZE		EQU		1000000

UNICODE			EQU		1

IDC_LIST1			EQU		1001
IDC_LIST2			EQU		1002
IDC_EDIT1			EQU		1003
IDC_EDIT2			EQU		1004
IDC_STATUS			EQU		1005
IDC_TIMER			EQU		1

LI_MARGIN_WIDTH	EQU		2
LI_FRAME_WIDTH		EQU		2

REC_MARKTABLE			EQU		1
REC_CHARSET				EQU		2
REC_LINEPOS				EQU		3

UIS_GUI					EQU		00000000H
UIS_CONSOLE				EQU		00000001H
UIS_IDLE					EQU		00000000H
UIS_BUSY					EQU		00000002H


WM_LBUPDATE		EQU		WM_USER+2

;Extend larger memory
LM_NONE			EQU		0
LM_HALF				EQU		1
LM_ONE				EQU		2

;Type of GenWindowTitle
GWT_FILENAME1		EQU		1
GWT_FILENAME2		EQU		2
GWT_VERSION			EQU		3
GWT_MODIFIED		EQU		4

;main file
_WinMain 			proto
_WndMainProc 		proto :dword,:dword,:dword,:dword
_InitWindow 			proto :dword
_LoadMel			proto :dword
_TryMatch			proto :dword
_SelfMatch			proto :dword
_SelfPreProc			proto
_RestoreFunc			proto :dword
_BackupFunc			proto :dword
_GetSimpFunc			proto :dword,:dword

;choosemel dialogbox
_WndCMProc			proto :dword,:dword,:dword,:dword
_GetMelInfo			proto :dword,:dword,:dword

;wildchar support
_WildcharMatchW		proto :dword,:dword
_CharMatchW			proto

;Misc
_GetConstString 		proto
_LoadConfig			proto
_SaveConfig			proto
_Int2Str				proto :dword,:dword,:dword
_OpenFileDlg			proto :dword,:dword,:dword,:dword
_SaveFileDlg			proto :dword,:dword,:dword,:dword
_memcpy				proto
_DirBackW			proto :dword
_DirFileNameW		proto :dword
_DirCatW				proto :dword,:dword
_DirCmpW			proto :dword,:dword
_DirModifyExtendName proto :dword,:dword
_ClearAll				proto :dword
_LoadFile				proto :dword,:dword,:dword
_SaveOrNot			proto
_AddLinesToList		proto :dword,:dword
_SetTextToEdit		proto :dword
_GenName2			proto :dword,:dword
_DisplayStatus		proto :dword,:dword
_SaveFile				proto :dword
_SetModified			proto :dword
_SetOpen			proto :dword
_ShowPic				proto :dword,:dword
_GetStringInList		proto :dword,:dword
_GenWindowTitle		proto :dword,:dword
_ConvertFA			proto :dword,:dword
_CalHeight			proto :dword
_Dev	proto

;Misc2
_MakeStringListFromStream	proto :dword
_GetStringFromStmPtr	proto :dword,:dword,:dword
_GetCodeIndex		proto :dword
_AddCodeCombo		proto :dword
_GetDispLine			proto :dword
_GetRealLine			proto :dword
_IsDisplay				proto :dword
_MatchFilter			proto :dword,:dword
_ResetHideTable		proto :dword
_UpdateHideTable		proto :dword

;Record
_ReadRec				proto :dword
_WriteRec			proto


;Menu Function
_OpenScript			proto
_LoadScript			proto
_SaveScript			proto
_SaveAs				proto
_CloseScript			proto
_SetCode				proto
_RecodeFile			proto :dword
_WndCodeProc		proto :dword,:dword,:dword,:dword
_ExportTxt			proto
_ExportSingleTxt		proto :dword,:dword
_ImportTxt			proto
_Exit					proto

;edit menu
_Undo				proto
_Redo				proto
_Modify				proto
_ModifyStringInList	proto :dword,:dword,:dword
_PrevLine				proto
_NextLine			proto
_MarkLine			proto
_ToFull				proto
_ToHalf				proto
_UnmarkAll			proto
_PrevMark			proto
_NextMark			proto
_Find				proto
_CreateFindWindow	proto :dword
_WndFindProc		proto :dword,:dword,:dword,:dword
_Replace				proto
_CreateReplaceWindow	proto :dword
_WndReplaceProc		proto :dword,:dword,:dword,:dword
_SummarySearch		proto :dword,:dword,:dword,:dword,:dword
_SummaryFind		proto
_WndSSProc			proto :dword,:dword,:dword,:dword
_Gotoline			proto
_WndGTProc		proto :dword,:dword,:dword,:dword
_SetLineInListbox		proto :dword,:dword
_Progress				proto

;UI menu
_SetFont				proto
_WndFontProc		proto :dword,:dword,:dword,:dword
_SetBackground		proto
_CustomUI			proto
_RecoverUI			proto

;assemble menu
_ExportAll			proto
_ExportAllToTxt		proto :dword,:dword,:dword,:dword,:dword,:dword
_WndExpAllProc		proto :dword,:dword,:dword,:dword
_ImportAll			proto
_ImportAllToTxt		proto :dword,:dword,:dword,:dword,:dword,:dword
_WndImpAllProc		proto :dword,:dword,:dword,:dword
_SummaryFindAll		proto
_Config				proto
_WndConfigProc		proto :dword,:dword,:dword,:dword
_TxtFilter				proto
_WndFilterProc			proto :dword,:dword,:dword,:dword
_About				proto
_WndAboutProc		proto :dword,:dword,:dword,:dword

;log
_WriteLog			proto :dword,:dword,:dword,:dword
_OutputMessage		proto :dword,:dword,:dword,:dword
_OpenLog			proto

;default edit
_GetText				proto :dword,:dword
_SaveText			proto :dword
_ModifyLine			proto :dword,:dword
_GetStringInTxt		proto :dword,:dword,:dword
_SetLine				proto :dword,:dword
_ReplaceInMem		proto :dword,:dword,:dword,:dword,:dword

;UI Maker
_ZoomRect			proto :dword,:dword
_LightenColor			proto :dword
_DarkenColor			proto :dword

;²éÕÒÌæ»»ÐÅÏ¢
_FindInfo struct
	szFind				db		SHORT_STRINGLEN	dup(?)
	szReplace			db		SHORT_STRINGLEN	dup(?)
	hFindWindow			dd		?
_FindInfo ends

;²å¼þÐÅÏ¢
_MelInfo struct
	szName				db		SHORT_STRINGLEN	dup(?)	;²å¼þÎÄ¼þÃû
	hModule				dd		?							;²å¼þ¾ä±ú
	pMatch				dd		?							;²å¼þµÄÆ¥Åäº¯ÊýÖ¸Õë
	lpMelInfo2			dd		?							;²å¼þÏêÏ¸ÐÅÏ¢Ö¸Õë
_MelInfo ends

;´ò¿ª¹ýµÄ½Å±¾µÄ¼ÇÂ¼ÎÄ¼þµÄÎÄ¼þÍ·
_FileRec struct
	szMagic			dd		?	;"MREC"
	nVer				dd		?	;°æ±¾
	nPos				dd		?	;ÉÏ´ÎÍË³öÊ±ËùÔÚÐÐ
	nCharSet1		dd		?	;×óÁÐÊ¹ÓÃµÄ×Ö·û¼¯
	nCharSet2		dd		?	;ÓÒÁÐÊ¹ÓÃµÄ×Ö·û¼¯
	Reserverd		dd		?
	nOffsetMT		dd		?	;MarkTableµÄÎÄ¼þÆ«ÒÆ
	nLenMT			dd		?	;MarkTable´óÐ¡£¬µÈÍ¬ÓÚÐÐÊý
	nOffsetResv		dd		6	dup(?)
_FileRec ends

.data?
	hInstance		dd		?
	hIcon			dd		?
	hMenu			dd		?
	hGlobalHeap		dd		?
	
	hBackDC			dd		?	;´°¿ÚµÄ±³¾°dc
	hBackBmp		dd		?	;´°¿ÚµÄ±³¾°Í¼Æ¬¾ä±ú
	
	lpszConfigFile		dd		?	;ÅäÖÃÎÄ¼þµÄÈ«Â·¾¶
	lpStrings			dd		?	;È«¾Ö³£Á¿×Ö·û´®±íÖ¸Õë
	lpMels			dd		?	;²å¼þÐÅÏ¢±íÖ¸Õë
	lpUndo			dd		?	;³·ÏúÁÐ±íÖ¸Õë
	lpPreData		dd		?	;´«µÝ¸øPreProcº¯ÊýµÄ_PreData½á¹¹Ö¸Õë
	lpOriFuncTable	dd		?	;Ô­Ê¼µÄ²Ëµ¥º¯ÊýµØÖ·±í£¬°üÀ¨_FunctionsºÍ_SimpFunc
	
	lpMarkTable		dd		?	;¶ÔÃ¿ÐÐµÄ±ê¼Ç±í£¬´æ´¢ÔÚrecordÎÄ¼þÖÐ
	lpModifyTable		dd		?	;±¾´Î±à¼­ÐÞ¸Ä¹ýµÄÐÐµÄ±ê¼Ç±í
	lpDisp2Real		dd		?	;ÏÔÊ¾³öÀ´µÄÐÐÓëÊµ¼ÊÐÐÊýµÄ¶ÔÓ¦±í
	
	nMels			dd		?	;¹²ÔØÈëÁË¶àÉÙ¸ö²å¼þ
	nCurMel			dd		?	;µ±Ç°Ê¹ÓÃµÄ²å¼þ±àºÅ£¨ÔÚlpMelsÖÐµÄÎ»ÖÃ£©
	nCurIdx			dd		?	;µ±Ç°±à¼­ÐÐ
	
	bModified		dd		?	;ÎÄ¼þ±¾´Î´ò¿ªÊÇ·ñ±»ÐÞ¸Ä¹ý
	bOpen			dd		?	;±à¼­Æ÷ÊÇ·ñ´ò¿ªÁËÎÄ¼þ
	nUIStatus			dd		?	;UI×´Ì¬,UIS_XXX

	hLogFile			dd		?	;ÈÕÖ¾ÎÄ¼þ¾ä±ú
	
;µ±Ç°ÎÄ¼þÐÅÏ¢
	FileInfo1			_FileInfo	<>
	FileInfo2			_FileInfo	<>
;
	FindInfo			_FindInfo	<>
	
;´°¿Ú¾ä±ú
	hWinMain		dd		?
	hList1			dd		?
	hList2			dd		?
	hEdit1			dd		?
	hEdit2			dd		?
	hStatus			dd		?
;	hCode1O			dd		?
;	hCode1N			dd		?
;	hCode2O			dd		?
;	hCode2N			dd		?

;×ÖÌå¾ä±ú
	hFontList			dd		?
	hFontEdit		dd		?
	
;Å¶ºÇºÇ
	dwTemp			dd		?
	
.data
	szNULL			dd		0
	TW0			'Multiline Editor',	szDisplayName
	TW0			'lnedit',			szInnerName
	TW0			' v1.0',			szDisplayVer
	TW0			' v1.0.0.400',		szFullVer
	szMemErr		dw		'N','o','t',' ','e','n','o','u','g','h',' ','m','e','m','o','r','y','!',0
	szOpenFilter		dw		'A','l','l',' ','F','i','l','e','s','(','*','.','*',')',0,'*','.','*',0,0
	szTxtFilter		dw		'T','X','T',' ','F','i','l','e','(','*','.','t','x','t',')',0,'*','.','t','x','t',0,0
	TW			'Image File\{*.bmp;*.jpg,*.',		szImageFilter
	TW0			'gif\}\0*.bmp;*.jpg;*.gif\0',	
	szDLLDir			dw		'm','e','l',0
	szMelFile			dw		'*','.','m','e','l',0
	szTxt			dw		'.','t','x','t',0
	TW0			'Rec',			szRecDir
	TW0			'.rec',			szRecExt
	
	TW0			'.\\NewSC',		szNewScDir
	TW0			'rsltln.txt',		szSearchResult
	TW0			'%s\t\t%d\t%s\r\n',	szSearchFormat
	TW0			'open',			szSearchOpen
	
	szCList			dw		'l','i','s','t','b','o','x',0
	szCEdit			dw		'e','d','i','t',0
	szCStatic			dw		's','t','a','t','i','c',0
	TW0			'combobox',		szCCombobox
	szCNewEdit		dw		'e','d','i','t','A','m','a','f',0
	szCNewList		dw		'l','i','s','t','A','m','a','f',0
	
	szFInitInfo		db		'InitInfo',0
	szFMatch			db		'Match',0
	szFPreProc		db		'PreProc',0
	szFGetText		db		'GetText',0
	szFSaveText		db		'SaveText',0
	szFModifyLine		db		'ModifyLine',0
	szFSetLine		db		'SetLine',0
	szFRetLine		db		'RetLine',0
	szFRelease		db		'Release',0
	szFGetStr			db		'GetStr',0

.data
	TW0		'%d',		szToStr
	TW0		'0x%08X',		szToStrH
	TW0		' - ',			szGang
	TW0		'* ',			szXing
	TW0		'%d/%d',		szLinesFormat


.data
;Function Table
	dbFunc		dd	offset _OpenScript
				dd	offset _LoadScript
				dd	offset _SaveScript
				dd	offset _SaveAs
				dd	offset _CloseScript
				dd	offset _SetCode
				dd	offset _ExportTxt
				dd	offset _ImportTxt
				dd	offset _Exit
				dd	0
				dd	offset _Undo
				dd	offset _Redo
				dd	offset _Modify
				dd	offset _PrevLine
				dd	offset _NextLine
				dd	offset _MarkLine
				dd	offset _PrevMark
				dd	offset _NextMark
				dd	offset _Find
				dd	offset _Replace
				dd	offset _SummaryFind
				dd	offset _Gotoline
				dd	0
				dd	offset _SetFont
				dd	offset _SetBackground
				dd	offset _CustomUI
				dd	offset _RecoverUI
				dd	0
				dd	offset _ExportAll
				dd	offset _ImportAll
				dd	offset _SummaryFindAll
				dd	0
				dd	offset _Config
				dd	0
				dd	offset _About
				dd	0
				dd	offset _ToFull
				dd	offset _ToHalf
				dd	offset _UnmarkAll
				dd	offset _Progress			;10040
				dd	offset _TxtFilter
				dd	10	dup(0)
	
	dbSimpFunc	dd	offset _GetText
				dd	offset _SaveText
				dd	offset _ModifyLine
				dd	offset _SetLine
				dd	0
				dd	0
				dd	offset _GetStringFromStmPtr
				
	dbTxtFunc	dd	0
				dd	0
				
	dbMelInfo2	_MelInfo2		<INTERFACE_VER,0>


.data
;Global Configs
	dbConf			dd			EM_SINGLE
					dd			120
					dd			NL_CURRENT
					DD			AC_NOT
					dd			CS_GBK
					
					dd			TRUE
					dd			FALSE
					dd			TRUE
					dd			NULL
					dd			NULL
					dd			NULL
					dd			NULL
					dd			NULL
					
					dd			FALSE
					_TextFilter	<>
					
					dd			NULL
					dd			000040ffh
					dd			00000000h
					dd			00000000h
					dd			00ff0000h
					dd			00ffcc99h
					dd			0000ff12h
					LOGFONT	<-14,0,0,0,190h,0,0,0,86h,3,2,1,22h,'®_oÅ–Ñž'>
					db	32	dup(0)
					LOGFONT	<-14,0,0,0,190h,0,0,0,86h,3,2,1,22h,'®_oÅ–Ñž'>
					db	32	dup(0)
;					LOGFONT	<-12,0,0,0,190h,0,0,0,86h,3,2,1,22h,'‹[SO'>
;					LOGFONT	<-12,0,0,0,190h,0,0,0,86h,3,2,1,22h,'‹[SO'>
					
					RECT		<CW_USEDEFAULT,CW_USEDEFAULT,800,600>
					RECT		<10,15,370,400>
					RECT		<410,15,370,400>
					RECT		<20,440,700,40>
					RECT		<20,500,700,40>
					RECT		<20,420,700,15>
;					;ÒÔÏÂÊÇËÄ¸ö±àÂë¿ò
;					RECT		<30,10,140,12>
;					RECT		<0,0,0,0>
;					RECT		<430,10,140,12>
;					RECT		<620,10,140,12>
	
.data
	TW0		'lnedit.ini',		szcfFileName
	
	TW0		'Settings',		szcfSett
	TW0		'TXTFilter',		szcfTxtFlt
	TW0		'UserInterface',	szcfUI
	
	TW0		'EditMode',		szcfEM
	TW0		'AutoSaveTime',	szcfAST
	TW0		'AutoCode',		szcfACD
	TW0		'NewScSaveLoc',	szcfNSSL
	TW0		'SaveInChangingLine',	szcfSCL
	TW0		'AutoSelectText',	szcfASL
	TW0		'AutoConvert',	szcfAC
	TW0		'AutoOpenOldFile',	szcfAO
	TW0		'DefaultMel',		szcfDM
	TW0		'InitDir1',			szcfID1
	TW0		'InitDir2',			szcfID2
	TW0		'NewScDir',		szcfNSD
	TW0		'OldFileName',	szcfPF
	
	TW0		'TextColorS',		szcfTCS
	TW0		'TextColorD',		szcfTCD
	TW0		'TextColorE',		szcfTCE
	TW0		'LineColor',		szcfLC
	TW0		'ListboxFont',		szcfLF
	TW0		'HighlightColorDefault',	szcfHCD
	TW0		'HighlightColorMarked',	szcfHCM
	TW0		'EditFont',		szcfEF
	TW0		'BackPicture',		szcfBP
	TW0		'WindowsLoc',	szcfWL
	
	TW0		'AlwaysFilter',		szcfAlwaysFlt
	TW0		'IncludeOn',		szcfInOn
	TW0		'IncludePattern',	szcfInPtn
	TW0		'ExcludeOn',		szcfExOn
	TW0		'ExcludePattern',	szcfExPtn
	TW0		'TrimHeadOn',		szcfHeadOn
	TW0		'TrimHeadPattern',	szcfHeadPtn
	TW0		'TrimTailOn',		szcfTailOn
	TW0		'TrimTailPattern',	szcfTailPtn
	
	dbConfigsOfTxtFilter	dd	offset szcfInOn,offset szcfInPtn
						dd	offset szcfExOn,offset szcfExPtn
						dd	offset szcfHeadOn,offset szcfHeadPtn
						dd	offset szcfTailOn,offset szcfTailPtn

.data
	TW0		'Not Convert',		szcdNotConvert
	
	TW0		'UNKNOWN(0)',	szcdDefault
	TW0		'GBK(936)',		szcdGBK
	TW0		'Shift-JIS(932)',		szcdSJIS
	TW0		'BIG5(950)',		szcdBig5
	TW0		'UTF-8(65001)',		szcdUTF8
	TW0		'UNICODE(-1)',		szcdUnicode
	
	dbCodeTable		dd		0,936,932,950,65001,-1