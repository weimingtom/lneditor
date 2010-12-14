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

UNICODE			EQU		1

IDC_LIST1			EQU		1001
IDC_LIST2			EQU		1002
IDC_EDIT1			EQU		1003
IDC_EDIT2			EQU		1004
IDC_STATUS			EQU		1005
;IDC_CODE1O			EQU		1006
;IDC_CODE1N			EQU		1007
;IDC_CODE2O			EQU		1008
;IDC_CODE2N			EQU		1009
IDC_TIMER			EQU		1

MAX_STRINGLEN		EQU		512
TOTAL_STRINGNUM	EQU		50
SHORT_STRINGLEN	EQU		64
MAX_MELCOUNT		EQU		50
BF_UNDO_SIZE		EQU		1000000

LI_MARGIN_WIDTH	EQU		2
LI_FRAME_WIDTH		EQU		2

;Memory type for strings
MT_FIXEDSTRING			EQU		1
MT_VARIABLESTRING		EQU		2
MT_EVERYSTRING			EQU		3
MT_POINTERONLY			EQU		4

E_ERROR					EQU		-1
E_NOMEM				EQU		1
E_OVERMEM				EQU		2
E_NOTENOUGHBUFF		EQU		3
E_FILEACCESSERROR		EQU		4
E_INVALIDPARAMETER		EQU		10H
E_LINENOTEXIST			EQU		100h
E_LINETOOLONG			EQU		101h
E_CODEFAILED				EQU		102H

WM_LBUPDATE		EQU		WM_USER+2

;Extend larger memory
LM_NONE			EQU		0
LM_HALF				EQU		1
LM_ONE				EQU		2

;Type of GenWindowTitle
GWT_FILENAME1		EQU		1
GWT_FILENAME2		EQU		2
GWT_VERSION		EQU		3
GWT_MODIFIED		EQU		4

;main file
_WinMain 			proto
_WndMainProc 		proto :dword,:dword,:dword,:dword
_InitWindow 			proto :dword
_LoadMel			proto :dword
_TryMatch			proto :dword
_SelfMatch			proto :dword
_SelfPreProc			proto
_RestoreFunc			proto
_SetTextToEdit		proto :dword
_GetSimpFunc			proto :dword,:dword

;choosemel dialogbox
_WndCMProc			proto :dword,:dword,:dword,:dword
_GetMelInfo			proto :dword,:dword,:dword

;wildchar support
_WildcharMatchW		proto :dword,:dword
_CharMatchW			proto

;Misc
_GetConstString 		proto
_LoadConfig 			proto
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
_LoadFile				proto :dword,:dword
_SaveOrNot			proto
_AddLinesToList		proto :dword,:dword
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

;Record
_ReadRec			proto
_WriteRec			proto


;Menu Function
_OpenScript			proto
_LoadScript			proto
_SaveScript			proto
_SaveAs				proto
_CloseScript			proto
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
_SetLineInListbox		proto :dword

;UI menu
_SetFont				proto
_WndFontProc		proto :dword,:dword,:dword,:dword
_SetBackground		proto
_CustomUI			proto
_RecoverUI			proto

;assemble menu
_ExportAll			proto
_ExportAllToTxt		proto :dword,:dword,:dword,:dword

_WndExpAllProc		proto :dword,:dword,:dword,:dword
_ImportAll			proto
_SummaryFindAll		proto
_About				proto
_Config				proto
_WndConfigProc		proto :dword,:dword,:dword,:dword

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

ifndef FILEINFOSTRUCT
FILEINFOSTRUCT EQU 1
_FileInfo struct
	;������������������
	szName				db		MAX_STRINGLEN	dup(?)	;�ļ���(��·��)
	hFile				dd		?						;�ļ����
	lpStream				dd		?						;�ļ�ֱ�Ӷ����ڴ���ָ��
	
	;�������ɲ��������д
	nMemoryType			dd		?						
	;�洢������ϸ������ĵ���
	lpText				dd		?						;���ļ�����ȡ���Ĵ��ı����ڴ�ָ�롣������MT_EVERYSTRING�洢�������ѡ��
	lpTextIndex			dd		?						;���ı��ַ���������ָ�롣
	lpStreamIndex		dd		?						;��ѡ��ԭʼ�ű��ַ���������ָ�롣��ΪPOINTERONLY�洢���ͣ�������롣
	nStringType			dd		?						;�ַ����洢���͡�
	nStreamSize			dd		?						;�ļ����ȡ������ű��༭��ʱ���¡�
	nLine				dd		?						;�ı�������
	nLineLen				dd		?						;��ѡ����ʹ�ö����ַ����洢��������ָʾ�ַ������ȡ������ڴ��ַ������ʹ�á�
	
	;����3��������������д
	bReadOnly			dw		?						;ָ�����ļ��Ƿ�Ϊֻ�����Ƿ����б�����ࣩ
	nCharSet				dd		?						;ָʾ�����ļ����ַ�������Ϊ�����ַ������û������趨�������ɸ����Լ����ж���д��
	
	Reserved				dd		2		dup(?)
_FileInfo ends
ENDIF

;�����滻��Ϣ
_FindInfo struct
	szFind				db		SHORT_STRINGLEN	dup(?)
	szReplace			db		SHORT_STRINGLEN	dup(?)
	hFindWindow			dd		?
_FindInfo ends

;�����Ϣ
_MelInfo struct
	szName				db		SHORT_STRINGLEN	dup(?)	;����ļ���
	hModule				dd		?							;������
	pMatch				dd		?							;�����ƥ�亯��ָ��
_MelInfo ends

;ÿ���ļ��ĵ�ǰ��������Ϣ
_FileRec struct
	nPos			dd		?
	nCharSet1		dd		?
	nCharSet2		dd		?
	Reserverd		dd		?
	nOffsetMT		dd		?
	nLenMT			dd		?
	nOffsetResv		dd		6	dup(?)
_FileRec ends

.data?
	hInstance		dd		?
	hIcon			dd		?
	hMenu			dd		?
	hGlobalHeap		dd		?
	hBackDC			dd		?
	hBackBmp		dd		?
	
	lpszConfigFile		dd		?
	lpStrings			dd		?	;�����ַ�����ָ��
	lpMels			dd		?	;�����Ϣ��ָ��
	lpUndo			dd		?	;�����б�ָ��
	lpPreData		dd		?	;���ݸ������PreProc������ָ��
	lpOriFuncTable	dd		?	;ԭʼ�Ĳ˵�������ַ��
	lpMarkTable		dd		?
	
	nCurMel			dd		?	;��ǰ�����ţ���lpMels�е�λ�ã�
	nCurIdx			dd		?	;
	
	bModified		dd		?
	bOpen			dd		?

	
;��ǰ�ļ���Ϣ
	FileInfo1			_FileInfo	<>
	FileInfo2			_FileInfo	<>
;
	FindInfo			_FindInfo	<>
	
;���ھ��
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

;������
	hFontList			dd		?
	hFontEdit		dd		?
	
;Ŷ�Ǻ�
	dwTemp			dd		?
	
.data
	szNULL			dd		0
	TW0			' v0.4',			szDisplayVer
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
				dd	offset _SetSaveDir
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


.data
;Global Configs
	dbConf			dd			EM_SINGLE
					dd			120
					dd			NL_CURRENT
					DD			AC_NOT
					dd			TRUE
					dd			FALSE
					dd			TRUE
					dd			NULL
					dd			NULL
					dd			NULL
					dd			NULL
					dd			NULL
					
					dd			NULL
					dd			000040ffh
					dd			00000000h
					dd			00000000h
					dd			00ff0000h
					dd			00ffcc99h
					dd			0000ff12h
					LOGFONT	<-14,0,0,0,190h,0,0,0,86h,3,2,1,22h,'�_o�Ŗў'>
					db	32	dup(0)
					LOGFONT	<-14,0,0,0,190h,0,0,0,86h,3,2,1,22h,'�_o�Ŗў'>
					db	32	dup(0)
;					LOGFONT	<-12,0,0,0,190h,0,0,0,86h,3,2,1,22h,'�[SO'>
;					LOGFONT	<-12,0,0,0,190h,0,0,0,86h,3,2,1,22h,'�[SO'>
					
					RECT		<CW_USEDEFAULT,CW_USEDEFAULT,800,600>
					RECT		<10,15,370,400>
					RECT		<410,15,370,400>
					RECT		<20,440,700,40>
					RECT		<20,500,700,40>
					RECT		<20,420,700,15>
;					;�������ĸ������
;					RECT		<30,10,140,12>
;					RECT		<0,0,0,0>
;					RECT		<430,10,140,12>
;					RECT		<620,10,140,12>
	
.data
	TW0		'lnedit.ini',		szcfFileName
	
	TW0		'Settings',		szcfSett
	TW0		'UserInterface',	szcfUI
	
	TW0		'EditMode',		szcfEM
	TW0		'AutoSaveTime',	szcfAST
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

.data
	TW0		'DEFAULT(0)',		szcdDefault
	TW0		'GBK(936)',		szcdGBK
	TW0		'Shift-JIS(932)',		szcdSJIS
	TW0		'UNICODE(-1)',		szcdUnicode
	
	dbCodeTable		dd		0,936,932,-1