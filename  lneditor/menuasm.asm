.data
	TW0			'*',		szAllFiles

.code

;
_ExportAll proc
	invoke DialogBoxParamW,hInstance,IDD_EXPALL,hWinMain,offset _WndExpAllProc,0
	ret
_ExportAll endp

;
_ImportAll proc
	invoke _Dev
	ret
_ImportAll endp

;
_SummaryFindAll proc
	invoke _Dev
	ret
_SummaryFindAll endp

;
_WndExpAllProc proc uses edi esi ebx hwnd,uMsg,wParam,lParam
	LOCAL @str[SHORT_STRINGLEN]:byte
	LOCAL @plstr,@plstr2
	mov eax,uMsg
	.if eax==WM_COMMAND
		mov eax,wParam
		.if ax==IDC_EA_CHGMEL
			invoke DialogBoxParamW,hInstance,IDD_CHOOSEMEL,hwnd,offset _WndCMProc,0
			cmp eax,-10
			ja _ExWEAP
			mov esi,eax
			cmp eax,-1
			je @F
			mov edx,sizeof _MelInfo
			mul dx
			add eax,lpMels
			mov ebx,eax
			mov ecx,_MelInfo.lpMelInfo2[ebx]
			.if _MelInfo2.nCharacteristic[ecx]&MIC_NOBATCHEXP
				mov eax,IDS_NOTSUPPORTBATCHEXP
				invoke _GetConstString
				invoke MessageBoxW,hwnd,eax,offset szDisplayName,MB_ICONINFORMATION
				jmp _ExWEAP
			.endif
			invoke SetDlgItemInt,hwnd,IDC_EA_MELIDX,esi,FALSE
			@@:
			invoke _GetMelInfo,ebx,addr @str,VT_PRODUCTNAME
			invoke SetDlgItemTextW,hwnd,IDC_EA_NAME,addr @str
			invoke _GetMelInfo,ebx,addr @str,VT_FORMAT
			invoke SetDlgItemTextW,hwnd,IDC_EA_FORMAT,addr @str
		.elseif ax==IDC_EA_BROWSEO
			mov esi,IDC_EA_DIRO
			@@:
			invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN
			or eax,eax
			je _ExWEAP
			mov @plstr,eax
			invoke _BrowseFolder,hwnd,@plstr
			.if eax
				invoke SetDlgItemTextW,hwnd,esi,@plstr
			.endif
			invoke HeapFree,hGlobalHeap,0,@plstr
		.elseif ax==IDC_EA_BROWSEN
			mov esi,IDC_EA_DIRN
			jmp @B
;		.elseif ax==IDC_EA_CODE
;			shr eax,16
;			.if ax==CBN_SELENDOK
;				invoke SendDlgItemMessageW,hwnd,IDC_EA_CODE,CB_GETCURSEL,0,0
;				.if eax==0
;					mov ecx,0
;				.elseif eax==1
;					mov ecx,936
;				.elseif eax==2
;					mov ecx,932
;				.elseif eax==3
;					mov ecx,-1
;				.endif
;				invoke wsprintfW,addr @str,offset szToStr,ecx
;				invoke SendDlgItemMessageW,hwnd,IDC_EA_CODE,WM_SETTEXT,0,addr @str
;			.endif
		.elseif ax==IDC_EA_OK
			invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN*2
			or eax,eax
			je _ExWEAP
			mov @plstr,eax
			add eax,MAX_STRINGLEN
			mov @plstr2,eax
			invoke GetDlgItemTextW,hwnd,IDC_EA_DIRO,@plstr,MAX_STRINGLEN/2
			invoke GetDlgItemTextW,hwnd,IDC_EA_DIRN,@plstr2,MAX_STRINGLEN/2
			invoke SetCurrentDirectoryW,@plstr
			mov ebx,eax
			invoke SetCurrentDirectoryW,@plstr2
			and eax,ebx
			.if ZERO?
				invoke HeapFree,hGlobalHeap,0,@plstr
				mov eax,IDS_INVALIDDIR
				invoke _GetConstString
				invoke MessageBoxW,hwnd,eax,0,MB_OK or MB_ICONERROR
				jmp _ExWEAP
			.endif
			invoke IsDlgButtonChecked,hwnd,IDC_EA_FORCEMEL
			mov esi,eax
			invoke IsDlgButtonChecked,hwnd,IDC_EA_FILTERON
			mov edi,eax
			invoke SendDlgItemMessageW,hwnd,IDC_EA_CODE,CB_GETCURSEL,0,0
			mov ebx,eax			
			invoke GetDlgItemInt,hwnd,IDC_EA_MELIDX,0,FALSE
			.if eax!=-1
				push eax
				mov dx,sizeof _MelInfo
				mul dx
				add eax,lpMels
				mov ecx,_MelInfo.lpMelInfo2[eax]
				.if _MelInfo2.nCharacteristic[ecx]&MIC_NOBATCHEXP
					add esp,4
					invoke HeapFree,hGlobalHeap,0,@plstr
					mov eax,IDS_NOTSUPPORTBATCHEXP
					invoke _GetConstString
					invoke MessageBoxW,hwnd,eax,offset szDisplayName,MB_ICONINFORMATION
					jmp _ExWEAP
				.endif
				pop eax
			.endif
			mov ecx,dword ptr [ebx*4+dbCodeTable]
			invoke _ExportAllToTxt,@plstr,@plstr2,eax,ecx,esi,edi
			mov ebx,eax
			invoke HeapFree,hGlobalHeap,0,@plstr
			.if !ebx
				mov eax,IDS_SUCEXPORT
				invoke _GetConstString
				mov ecx,eax
				mov eax,IDS_WINDOWTITLE
				invoke _GetConstString
				invoke MessageBoxW,hwnd,ecx,eax,MB_OK or MB_ICONINFORMATION
			.else
				mov eax,IDS_FAILEXPORT
				invoke _GetConstString
				invoke MessageBoxW,hwnd,ecx,0,MB_OK or MB_ICONERROR
			.endif
		.elseif ax==IDCANCEL
			invoke EndDialog,hwnd,0
		.endif
	.elseif eax==WM_INITDIALOG
		invoke SetDlgItemInt,hwnd,IDC_EA_MELIDX,nCurMel,FALSE
		.if nCurMel==-1
			mov ebx,-1
			jmp @F
		.endif
		mov eax,nCurMel
		mov edx,sizeof _MelInfo
		mul dx
		add eax,lpMels
		mov ebx,eax
		@@:
		invoke _GetMelInfo,ebx,addr @str,VT_PRODUCTNAME
		invoke SetDlgItemTextW,hwnd,IDC_EA_NAME,addr @str
		invoke _GetMelInfo,ebx,addr @str,VT_FORMAT
		invoke SetDlgItemTextW,hwnd,IDC_EA_FORMAT,addr @str
		invoke GetDlgItem,hwnd,IDC_EA_CODE
		invoke _AddCodeCombo,eax
		invoke SendDlgItemMessageW,hwnd,IDC_EA_CODE,CB_SETCURSEL,0,0
		invoke CheckDlgButton,hwnd,IDC_EA_FILTERON,dbConf+_Configs.bAlwaysFilter
	.elseif eax==WM_CLOSE
		invoke EndDialog,hwnd,0
	.endif
_ExWEAP:
	xor eax,eax
	ret
_WndExpAllProc endp

;
_ExportAllToTxt proc uses esi edi ebx _lpszScr,_lpszTxt,_nMelIdx,_nCharSet,_bForceMel,_bFilterOn
	LOCAL @stFindData:WIN32_FIND_DATA
	LOCAL @hFindFile,@hFileT
	LOCAL @stFileInfo:_FileInfo
	LOCAL @err,@ri
	LOCAL @lpFuncs,@lpOldMT
	or nUIStatus,UIS_BUSY
	invoke HeapAlloc,hGlobalHeap,0,sizeof _Functions+sizeof _SimpFunc+sizeof _TxtFunc
	mov @lpFuncs,eax
	.if !eax
		mov @err,E_NOMEM
		jmp _ExEATT
	.endif
	invoke _BackupFunc,@lpFuncs
	invoke _RestoreFunc,lpOriFuncTable
	mov ecx,lpMarkTable
	mov @lpOldMT,ecx
	mov eax,_nMelIdx
	.if eax!=-1
		mov edx,sizeof _MelInfo
		mul dx
		add eax,lpMels
		mov ebx,eax
		assume ebx:ptr _MelInfo
		invoke _GetSimpFunc,[ebx].hModule,offset dbSimpFunc
		invoke GetProcAddress,[ebx].hModule,offset szFPreProc
		.if eax
			push lpPreData
			call eax
		.endif
	.endif
	invoke SetCurrentDirectoryW,_lpszScr
	invoke FindFirstFileW,offset szAllFiles,addr @stFindData
	.if eax!=INVALID_HANDLE_VALUE
		mov @hFindFile,eax
		invoke RtlZeroMemory,addr @stFileInfo,sizeof _FileInfo
		mov @err,0
		.repeat
			lea edi,@stFindData.cFileName
			.if dword ptr [edi]=='.' || dword ptr [edi]==2e002eh && word ptr [edi+4]==0
				jmp _Next4EATT
			.endif
			.if !_bForceMel
				.if _nMelIdx!=-1
					push edi
					call [ebx].pMatch
				.else
					invoke _SelfMatch,edi
				.endif
				cmp eax,MR_NO
				je _Next2EATT
				cmp eax,MR_ERR
				je _Next2EATT
			.endif
			invoke lstrcpyW,addr @stFileInfo.szName,edi
			.if _nMelIdx!=-1
				mov ecx,[ebx].lpMelInfo2
			.else
				lea ecx,offset dbMelInfo2
			.endif
			invoke _LoadFile,addr @stFileInfo,LM_NONE,ecx
			or eax,eax
			je _Next2EATT
			
			invoke _DirModifyExtendName,edi,offset szTxt
			invoke SetCurrentDirectoryW,_lpszTxt
			mov ecx,_nCharSet
			mov @stFileInfo.nCharSet,ecx
			lea edi,@stFindData.cFileName
			invoke CreateFileW,edi,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
			cmp eax,-1
			je _Next2EATT
			mov @hFileT,eax
			lea ecx,@ri
			push ecx
			lea eax,@stFileInfo
			push eax
			call dbSimpFunc+_SimpFunc.GetText
			.if eax
				mov @err,1
				jmp _Next3EATT
			.endif
			.if @stFileInfo.nMemoryType==MT_POINTERONLY
				invoke _MakeStringListFromStream,addr @stFileInfo
				.if eax
					mov @err,1
					jmp _Next3EATT
				.endif
			.endif
			.if _bFilterOn
				invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,@stFileInfo.nLine
				or eax,eax
				je _FilterNext
				mov lpMarkTable,eax
				invoke _UpdateHideTable,addr @stFileInfo
				invoke _ExportSingleTxt,addr @stFileInfo,@hFileT
				.if eax
					mov @err,1
				.endif
				invoke HeapFree,hGlobalHeap,0,lpMarkTable
			.else
				_FilterNext:
				invoke _ExportSingleTxt,addr @stFileInfo,@hFileT
				.if eax
					mov @err,1
				.endif
			.endif
_Next3EATT:
			invoke CloseHandle,@hFileT
_Next2EATT:
			invoke _ClearAll,addr @stFileInfo
			invoke SetCurrentDirectoryW,_lpszScr
_Next4EATT:
			invoke FindNextFileW,@hFindFile,addr @stFindData
		.until eax==FALSE
		invoke FindClose,@hFindFile
	.endif
	assume ebx:nothing
	mov ecx,@lpOldMT
	mov lpMarkTable,ecx
	invoke _RestoreFunc,@lpFuncs
	invoke HeapFree,hGlobalHeap,0,@lpFuncs
_ExEATT:
	and nUIStatus,not UIS_BUSY
	mov eax,@err
	ret
_ExportAllToTxt endp

;
_About proc
	invoke DialogBoxParamW,hInstance,IDD_ABOUT,hWinMain,offset _WndAboutProc,0
	ret
_About endp

_WndAboutProc proc uses edi esi ebx hwnd,uMsg,wParam,lParam
	mov eax,uMsg
	.if eax==WM_COMMAND
		mov eax,wParam
		.if ax==IDC_AB_OK || AX==IDC_AB_CANCEL
			invoke EndDialog,hwnd,0
		.endif
	.elseif eax==WM_INITDIALOG
		invoke SetDlgItemTextW,hwnd,IDC_AB_VER,offset szFullVer
	.elseif eax==WM_CLOSE
		invoke EndDialog,hwnd,0
	.endif
	xor eax,eax
	ret
_WndAboutProc endp
