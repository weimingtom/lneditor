.code

;����Դ�л�ȡ�ַ���
_GetConstString proc
	shl eax,8
	add eax,lpStrings
	ret
_GetConstString endp


;
_OpenFileDlg proc uses edi ebx _lpszFilter,_lpszFN,_lpszInit,_lpszTitle
	LOCAL @opFileName:OPENFILENAME
	LOCAL @szErrMsg[128]:byte
	
	lea edi,@opFileName
	xor eax,eax
	mov ecx,sizeof @opFileName
	rep stosb
	mov @opFileName.lStructSize,sizeof @opFileName
	push hWinMain
	pop @opFileName.hwndOwner
	push _lpszFilter
	pop @opFileName.lpstrFilter
	mov eax,_lpszFN
	mov word ptr [eax],0
	mov @opFileName.lpstrFile,eax
	mov @opFileName.nMaxFile,MAX_STRINGLEN/2
	push _lpszInit
	pop @opFileName.lpstrInitialDir
	push _lpszTitle
	pop @opFileName.lpstrTitle
	mov @opFileName.Flags,OFN_FILEMUSTEXIST OR OFN_PATHMUSTEXIST or OFN_EXPLORER or OFN_HIDEREADONLY
	lea eax,@opFileName
	invoke GetOpenFileNameW,eax
	.if !eax
		invoke CommDlgExtendedError
		.if !eax
			ret
		.endif
		mov ebx,eax
		mov eax,IDS_ERROPENDLG
		invoke _GetConstString
		invoke wsprintfW,addr @szErrMsg,eax,ebx
		invoke MessageBoxW,hWinMain,addr @szErrMsg,0,MB_OK or MB_ICONERROR
		xor eax,eax
		ret
	.endif
	mov eax,1
	ret
_OpenFileDlg endp

;
_SaveFileDlg proc _lpszFilter,_lpszPath,_lpszInit,_lpszTitle
	LOCAL @opFileName:OPENFILENAME
	LOCAL @szErrMsg[128]:byte
	
	lea edi,@opFileName
	xor eax,eax
	mov ecx,sizeof @opFileName
	rep stosb
	mov @opFileName.lStructSize,sizeof @opFileName
	push hWinMain
	pop @opFileName.hwndOwner
	push _lpszFilter
	pop @opFileName.lpstrFilter
	push _lpszPath
	pop @opFileName.lpstrFile
	mov @opFileName.nMaxFile,MAX_STRINGLEN/2
	push _lpszInit
	pop @opFileName.lpstrInitialDir
	push _lpszTitle
	pop @opFileName.lpstrTitle
	mov @opFileName.Flags,OFN_EXPLORER or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT
	lea eax,@opFileName
	invoke GetSaveFileNameW,eax
	.if !eax
		invoke CommDlgExtendedError
		.if !eax
			ret
		.endif
		mov ebx,eax
		mov eax,IDS_ERROPENDLG
		invoke _GetConstString
		invoke wsprintfW,addr @szErrMsg,eax,ebx
		invoke MessageBoxW,hWinMain,addr @szErrMsg,0,MB_OK or MB_ICONERROR
		xor eax,eax
		ret
	.endif
	mov eax,1
	ret
_SaveFileDlg endp

;Ŀ¼��ַ��������
_DirBackW proc uses edi _lpszPath
	mov edi,_lpszPath
	xor ax,ax
	mov ecx,MAX_STRINGLEN/2
	repne scasw
	.if word ptr [edi-4]=='\'
		sub edi,6
	.endif
	sub ecx,MAX_STRINGLEN/2
	neg ecx
	mov ax,'\'
	std
	repne scasw
	cld
	.if ecx
		mov word ptr [edi+4],0
		mov eax,1
		ret
	.endif
	mov eax,ecx
	ret
_DirBackW endp

_DirFileNameW proc uses edi _lpszPath
	mov edi,_lpszPath	
	xor ax,ax
	mov ecx,MAX_STRINGLEN/2
	repne scasw
	.if word ptr [edi-4]=='\'
		xor eax,eax
		ret
	.endif
	sub ecx,MAX_STRINGLEN/2
	neg ecx
	mov ax,'\'
	std
	repne scasw
	cld
	.if ecx
		lea eax,[edi+4]
		ret
	.endif
	xor eax,eax
	ret
_DirFileNameW endp

_DirCatW proc uses edi _lpszPath,_lpszName
	mov edi,_lpszName
	.if dword ptr [edi]==5c002eh;".\"
		add _lpszName,4
	.endif
	mov edi,_lpszPath
	xor ax,ax
	mov ecx,MAX_STRINGLEN/2
	repne scasw
	.if word ptr [edi-4]!='\'
		mov word ptr [edi-2],'\'
		mov word ptr [edi],0
	.endif
	invoke lstrcatW,_lpszPath,_lpszName
	ret
_DirCatW endp

_DirCmpW proc uses edi ebx _lpszPath,_lpszName
	
	mov edi,_lpszName
	.if dword ptr [edi]==5c002eh;".\"
		add _lpszName,4
	.endif
	mov edi,_lpszPath
	xor ax,ax
	mov ecx,MAX_STRINGLEN/2
	repne scasw
	xor ebx,ebx
	.if word ptr [edi-4]=='\'
		lea ebx,[edi-4]
		mov word ptr [ebx],0
		sub edi,4
	.endif
	sub ecx,MAX_STRINGLEN/2
	neg ecx
	mov ax,'\'
	std
	repne scasw
	cld
	add edi,4
	invoke lstrcmpW,edi,_lpszName
	.if ebx
		mov word ptr [ebx],'\'
	.endif
	ret
_DirCmpW endp

_DirModifyExtendName proc uses edi _lpOri,_lpExtendName
	mov _lpOri,edi
	xor ax,ax
	or ecx,-1
	repne scasw
	sub edi,2
	not ecx
	mov eax,edi
	.while word ptr [edi]!='.'
		sub edi,2
		dec ecx
		.if !ecx || word ptr [edi]=='\'
			mov edi,eax
			.break
		.endif
	.endw
	mov word ptr [edi],0
	invoke lstrcatW,_lpOri,_lpExtendName
	ret
_DirModifyExtendName endp

;��FileInfo�е�String��ӵ��б������
_AddLines proc uses esi edi ebx _pdb
	LOCAL @hList
	mov eax,_pdb
	mov edi,[eax]
	mov ecx,[eax+4]
	mov @hList,ecx
	assume edi:ptr _FileInfo
	xor ebx,ebx
	.if [edi].lpTextIndex
		mov esi,[edi].lpTextIndex
		.while ebx<[edi].nLine
			invoke SendMessageW,@hList,LB_ADDSTRING,0,[esi]
			add esi,4
			inc ebx
		.endw
	.else
		mov esi,[edi].lpText
		.while ebx<[edi].nLine
			invoke SendMessageW,@hList,LB_ADDSTRING,0,esi
			add esi,[edi].nLineLen
			inc ebx
		.endw
	.endif
	assume edi:nothing
	invoke HeapFree,hGlobalHeap,0,_pdb
	.if nCurIdx!=-1
		@@:
		invoke _SetLineInListbox,nCurIdx
	.else
		invoke _ReadRec
		mov nCurIdx,eax
		jmp @b
	.endif
	ret
_AddLines endp

_AddLinesToList proc uses esi edi ebx _pFI,_hList
	LOCAL @pdb
	invoke HeapAlloc,hGlobalHeap,0,8
	or eax,eax
	je _ExALT
	mov @pdb,eax
	mov ecx,_pFI
	mov [eax],ecx
	mov ecx,_hList
	mov [eax+4],ecx
	invoke CreateThread,0,0,offset _AddLines,@pdb,0,0
_ExALT:
	ret
_AddLinesToList endp

;��Name1����Name2
_GenName2 proc uses ebx _lpszName1,_lpszName2
	LOCAL @szStr[MAX_STRINGLEN]:byte
	LOCAL @szTemp[SHORT_STRINGLEN]:byte
	
	invoke lstrcpyW,addr @szStr,_lpszName1
	invoke _DirBackW,addr @szStr
	invoke _DirFileNameW,_lpszName1
	mov ebx,eax
	invoke _DirCmpW,addr @szStr,dbConf+_Configs.lpNewScDir
	.if !eax
		invoke lstrcpyW,addr @szStr, _lpszName1
		invoke _DirBackW,addr @szStr
		invoke _DirBackW,addr @szStr
		invoke _DirFileNameW,_lpszName1
		invoke _DirCatW,addr @szStr,eax
		invoke CreateFileW,addr @szStr,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=-1
			invoke CloseHandle,eax
			mov eax,IDS_WRONGPOS
			invoke _GetConstString
			mov ecx,eax
			mov eax,IDS_WINDOWTITLE
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,ecx,eax,MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONQUESTION
			.if eax==IDYES
				.if dbConf+_Configs.nNewLoc==NL_CURRENT
					invoke lstrcpyW,_lpszName2,_lpszName1
					invoke lstrcpyW,_lpszName1,addr @szStr
					jmp _ExGN
				.else
					invoke lstrcpyW,_lpszName1,addr @szStr
					jmp _MakeFN2GN
				.endif
			.endif
			cmp eax,IDCANCEL
			jne _MakeFN2GN
			xor eax,eax
			ret
		.endif
	.endif
_MakeFN2GN:
	.if dbConf+_Configs.nNewLoc==NL_CURRENT
		invoke lstrcpyW,addr @szStr,_lpszName1
	.else
		invoke GetModuleFileNameW,0,addr @szStr,MAX_STRINGLEN/2
	.endif
	invoke _DirBackW,addr @szStr
	invoke _DirCatW,addr @szStr,dbConf+_Configs.lpNewScDir
	invoke SetCurrentDirectoryW,addr @szStr
	.if !eax
		invoke CreateDirectoryW,addr @szStr,0
		invoke SetCurrentDirectoryW,addr @szStr
		.if !eax
			mov eax,_lpszName2
			mov word ptr [eax],0
			jmp _ExGN
		.endif
	.endif
	invoke _DirFileNameW,_lpszName1
	invoke _DirCatW,addr @szStr,eax
	invoke lstrcpyW,_lpszName2,addr @szStr
_ExGN:
	mov eax,1
	ret
_GenName2 endp

;ͨ��FileInfo�ṹ�е��ļ��������ļ�����������ڴ�
_LoadFile proc uses edi _pFI,_LargeMem
	LOCAL @nFileSize:LARGE_INTEGER
	mov edi,_pFI
	assume edi:ptr _FileInfo
	invoke CreateFileW,edi,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _FailLF
	mov [edi].hFile,eax
	
	invoke GetFileSizeEx,[edi].hFile,addr @nFileSize
	.if _LargeMem==LM_HALF
		mov eax,dword ptr @nFileSize
		mov ecx,eax
		shr ecx,1
		add eax,ecx
		mov dword ptr @nFileSize,eax
	.elseif _LargeMem==LM_ONE
		mov eax,dword ptr @nFileSize
		shl eax,1
		mov dword ptr @nFileSize,eax
	.endif
	invoke VirtualAlloc,0,dword ptr @nFileSize,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _FailLF
	mov [edi].lpStream,eax
	invoke ReadFile,[edi].hFile,[edi].lpStream,dword ptr @nFileSize,offset dwTemp,0
	or eax,eax
	je _FailLF
	mov eax,dwTemp
	mov [edi].nStreamSize,eax
	assume edi:nothing
_SucLF:
	mov eax,1
	ret
_FailLF:
	xor eax,eax
	ret
_LoadFile endp

;��ʾ�Ƿ񱣴�Ի���
_SaveOrNot proc
	mov eax,IDS_SAVEORNOT
	invoke _GetConstString
	mov ecx,eax
	mov eax,IDS_WINDOWTITLE
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,ecx,eax,MB_YESNOCANCEL or MB_DEFBUTTON1 or MB_ICONINFORMATION
	
	ret
_SaveOrNot endp

;�ͷ�FileInfo�ṹ�е��ڴ沢����
_ClearAll proc uses edi _pFI
	mov edi,_pFI
	assume edi:ptr _FileInfo
	mov eax,dbSimpFunc+_SimpFunc.Release
	.if eax
		push edi
		call eax
	.endif
	invoke CloseHandle,[edi].hFile
	invoke VirtualFree,[edi].lpStream,0,MEM_RELEASE
	invoke VirtualFree,[edi].lpText,0,MEM_RELEASE
	invoke VirtualFree,[edi].lpTextIndex,0,MEM_RELEASE
	invoke VirtualFree,[edi].lpStreamIndex,0,MEM_RELEASE
	assume edi:nothing
	xor al,al
	mov ecx,sizeof _FileInfo
	rep stosb
	ret
_ClearAll endp

;״̬���ı���ʾ
_Display proc uses edi _sztime
	mov edi,_sztime
	invoke SetWindowTextW,hStatus,[edi]
	invoke Sleep,[edi+4]
	invoke SetWindowTextW,hStatus,NULL
	invoke HeapFree,hGlobalHeap,0,edi
	xor eax,eax
	ret
_Display endp
_DisplayStatus proc _lpsz,_time
	invoke HeapAlloc,hGlobalHeap,0,8
	or eax,eax
	je @F
	mov ecx,_lpsz
	mov [eax],ecx
	mov ecx,_time
	mov [eax+4],ecx
	invoke CreateThread,0,0,offset _Display,eax,0,0
	invoke CloseHandle,eax
	@@:
	ret
_DisplayStatus endp

;����FileInfo�ṹ�����ļ������ò����SaveText����ֱ�ӱ��棩
_SaveFile proc uses edi ebx _pFI
	mov edi,_pFI
	assume edi:ptr _FileInfo
	.if dbSimpFunc+_SimpFunc.SaveText
		push _pFI
		call [dbSimpFunc+_SimpFunc.SaveText]
		or eax,eax
		je _ErrSF
	.else
		invoke SetFilePointer,[edi].hFile,0,0,FILE_BEGIN
		invoke WriteFile,[edi].hFile,[edi].lpStream,[edi].nStreamSize,offset dwTemp,0
		or eax,eax
		je _ErrSF
		invoke SetEndOfFile,[edi].hFile
		or eax,eax
		je _ErrSF
	.endif
	invoke _WriteRec
	mov eax,1
	ret
_ErrSF:
	xor eax,eax
	ret
_SaveFile endp

;�����޸ı�־�����ò˵��
_SetModified proc uses ebx _bFlag
	.if _bFlag && !bModified
		invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED
		mov bModified,1
		
		mov eax,dbConf+_Configs.nAutoSaveTime
		.if eax
			mov edx,1000
			mul edx
			invoke SetTimer,hWinMain,IDC_TIMER,eax,NULL
		.endif
		
		invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN
		or eax,eax
		je @F
		mov ebx,eax
		invoke _GenWindowTitle,ebx,GWT_MODIFIED
		invoke SetWindowTextW,hWinMain,ebx
		invoke HeapFree,hGlobalHeap,0,ebx
	.elseif !_bFlag && bModified
		invoke EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED
		mov bModified,0
		
		.if dbConf+_Configs.nAutoSaveTime
			invoke KillTimer,hWinMain,IDC_TIMER
		.endif
		
		invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN
		or eax,eax
		je @F
		mov ebx,eax
		.if dbConf+_Configs.nEditMode==EM_SINGLE
			mov eax,GWT_FILENAME1
		.else
			mov eax,GWT_FILENAME2
		.endif
		invoke _GenWindowTitle,ebx,eax
		invoke SetWindowTextW,hWinMain,ebx
		invoke HeapFree,hGlobalHeap,0,ebx
	.endif
	@@:
	ret
_SetModified endp

;
_SetOpen proc uses esi edi _bFlag
	.if _bFlag
		mov bOpen,1
		mov esi,MF_ENABLED
		mov edi,MF_GRAYED
	.else
		mov bOpen,0
		mov edi,MF_ENABLED
		mov esi,MF_GRAYED
	.endif
	invoke EnableMenuItem,hMenu,IDM_SAVEAS,esi
	invoke EnableMenuItem,hMenu,IDM_CLOSE,esi
	invoke EnableMenuItem,hMenu,IDM_EXPORT,esi
	invoke EnableMenuItem,hMenu,IDM_IMPORT,esi
	invoke EnableMenuItem,hMenu,IDM_MODIFY,esi
	invoke EnableMenuItem,hMenu,IDM_PREVTEXT,esi
	invoke EnableMenuItem,hMenu,IDM_NEXTTEXT,esi
	ret
_SetOpen endp

;��ȡStringList�е�ָ���е��ı�
_GetStringInList proc uses edi _pFI,_nLine
	mov edi,_pFI
	assume edi:ptr _FileInfo
	mov eax,_nLine
	.if eax>=[edi].nLine
		xor eax,eax
		ret
	.endif
	.if [edi].lpTextIndex
		mov edi,[edi].lpTextIndex
		mov eax,dword ptr [edi+eax*4]
	.else
		mov ecx,[edi].nLineLen
		mul ecx
		add eax,[edi].lpText
	.endif
	assume edi:nothing
	ret
_GetStringInList endp

_ConvertFA proc uses esi edi _lpsz,_nType
	mov edi,_lpsz
	mov esi,edi
	.if _nType==AC_FULLANGLE
		lodsw
		.while ax
			.if ax==20h
				mov ax,3000h
				jmp @F
			.elseif ax<=7eh && ax>=21h
				add ax,0fee0h
				jmp @F
			.endif
			@@:
			stosw
			lodsw
		.endw
	.elseif _nType==AC_HALFANGLE
		lodsw
		.while ax
			.if ax==3000h
				mov ax,20h
				jmp @F
			.elseif ax>=0ff01h && ax<=0ff5eh
				sub ax,0fee0h
				jmp @F
			.endif
			@@:
			stosw
			lodsw
		.endw
	.endif
	ret
_ConvertFA endp

;�����б�����еĸ߶�
_CalHeight proc uses edi _nPos
	LOCAL @hdc,@pStr
	LOCAL @sz:POINT
	LOCAL @s[4]:byte
	LOCAL @tm:TEXTMETRIC
;��ȡ������ϼ�࣬��֮ǰ�ȼӵ�@sz.y���档
	invoke GetDC,hList1
	mov @hdc,eax
	invoke SelectObject,@hdc,hFontList
	mov dword ptr @s,3001h
	invoke _GetStringInList,offset FileInfo1,_nPos
	.if !eax || !word ptr [eax]
		lea eax,@s
	.endif
	mov @pStr,eax
	invoke lstrlenW,@pStr
	mov ecx,eax
	invoke GetTextExtentPoint32W,@hdc,@pStr,ecx,addr @sz
	mov eax,@sz.x
	xor edx,edx
	div dbConf+_Configs.windowRect[WRI_LIST1]+RECT.right
	.if edx
		inc eax
	.endif
	add @sz.y,LI_MARGIN_WIDTH*2
	mul @sz.y
	push eax
	
	invoke _GetStringInList,offset FileInfo2,_nPos
	.if !eax || !word ptr [eax]
		lea eax,@s
	.endif
	mov @pStr,eax
	invoke lstrlenW,@pStr
	mov ecx,eax
	invoke GetTextExtentPoint32W,@hdc,@pStr,ecx,addr @sz
	invoke ReleaseDC,hList1,@hdc
	mov eax,@sz.x
	xor edx,edx
	div dbConf+_Configs.windowRect[WRI_LIST2]+RECT.right
	.if edx
		inc eax
	.endif
	add @sz.y,LI_MARGIN_WIDTH*2
	mul @sz.y
	pop ecx
	.if ecx>eax
		mov eax,ecx
	.endif
	ret
_CalHeight endp

;
_ShowPic proc uses ebx _hdc,_lpszName
	LOCAL @pStm:LPSTREAM
	LOCAL @pPic:LPPICTURE
	LOCAL @nSize[2],@hFilePic,@hGlobal
	LOCAL @hmWidth,@hmHeight
	LOCAL @hmdc,@hBmp,@hOldBmp,@bf:BLENDFUNCTION
	LOCAL @rect:RECT
;	invoke SHCreateStreamOnFileW,_lpszName,STGM_READ or STGM_SHARE_DENY_WRITE,addr @pStm
;	cmp eax,S_OK
;	jne _ErrSP
	invoke CreateFileW,_lpszName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrSP
	mov @hFilePic,eax
	invoke GetFileSizeEx,@hFilePic,addr @nSize
	invoke GlobalAlloc,GMEM_MOVEABLE,dword ptr @nSize
	.if !eax
		_Ex1SJ:
		invoke CloseHandle,@hFilePic
		jmp _ErrSP
	.endif
	mov @hGlobal,eax
	invoke GlobalLock,@hGlobal
	.if !eax
		_Ex2SJ:
		invoke GlobalFree,@hGlobal
		jmp _Ex1SJ
	.endif
	invoke ReadFile,@hFilePic,eax,dword ptr @nSize,offset dwTemp,0
	invoke GlobalUnlock,@hGlobal
	invoke CreateStreamOnHGlobal,@hGlobal,TRUE,addr @pStm
	or eax,eax
	jne _Ex2SJ
	invoke OleLoadPicture,@pStm,dword ptr @nSize,TRUE,offset IID_IPicture,addr @pPic
	.if eax
		mov eax,@pStm
		mov eax,[eax]
		invoke (IStream ptr [eax]).Release,@pStm
		jmp _Ex1SJ
	.endif
	mov ebx,@pPic
	assume ebx:nothing
	mov ebx,[ebx]
	invoke (IPicture ptr [ebx]).get_Width,@pPic,addr @hmWidth
	invoke (IPicture ptr [ebx]).get_Height,@pPic,addr @hmHeight
	mov ecx,@hmHeight
	neg ecx
	invoke (IPicture ptr [ebx]).Render,@pPic,_hdc,0,0,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.right,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.bottom,\
		0,@hmHeight,@hmWidth,ecx,0
	invoke (IPicture ptr [ebx]).Release,@pPic
	mov eax,@pStm
	mov eax,[eax]
	invoke (IStream ptr [eax]).Release,@pStm
	invoke CloseHandle,@hFilePic
	mov eax,1
	ret
_ErrSP:
	xor eax,eax
	ret
_ShowPic endp

_GenWindowTitle proc _lpsz,_nType
	mov eax,_nType
	.if EAX==GWT_FILENAME1
		invoke lstrcpyW,_lpsz,offset FileInfo1.szName
		@@:
		invoke lstrcatW,_lpsz,offset szGang
		mov eax,IDS_WINDOWTITLE
		invoke _GetConstString
		invoke lstrcatW,_lpsz,eax
	.elseif eax==GWT_FILENAME2
		invoke lstrcpyW,_lpsz,offset FileInfo2.szName
		jmp @B
	.elseif eax==GWT_VERSION
		mov eax,IDS_WINDOWTITLE
		invoke _GetConstString
		invoke lstrcpyW,_lpsz,eax
		invoke lstrcatW,_lpsz,offset szDisplayVer
	.elseif eax==GWT_MODIFIED
		invoke lstrcpyW,_lpsz,offset szXing
		add _lpsz,4
		invoke GetWindowTextW,hWinMain,_lpsz,(MAX_STRINGLEN+SHORT_STRINGLEN-4)/2
	.endif
	ret
_GenWindowTitle endp

_ReadRec proc uses ebx
	LOCAL @str[MAX_STRINGLEN]:byte
	LOCAL @hFile
	LOCAL @dbHdr[sizeof _FileRec]:byte
	lea ebx,@str
	invoke lstrcpyW,ebx,lpszConfigFile
	invoke _DirBackW,ebx
	invoke _DirCatW,ebx,offset szRecDir
	invoke SetCurrentDirectoryW,ebx
	or eax,eax
	je _ErrRR
	invoke lstrcpyW,ebx,offset FileInfo1.szName
	invoke lstrcatW,ebx,offset szRecExt
	invoke _DirFileNameW,ebx
	or eax,eax
	je _ErrRR
	invoke CreateFileW,eax,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrRR
	mov @hFile,eax
	lea edi,@dbHdr
	invoke ReadFile,@hFile,edi,sizeof _FileRec,offset dwTemp,0
	assume edi:ptr _FileRec
	mov eax,[edi].nLenMT
	.if lpMarkTable && eax==FileInfo1.nLine
		invoke SetFilePointer,@hFile,[edi].nOffsetMT,0,FILE_BEGIN
		invoke ReadFile,@hFile,lpMarkTable,[edi].nLenMT,offset dwTemp,0
	.endif
	invoke CloseHandle,@hFile
	mov eax,[edi].nPos
	ret
	assume edi:ptr _nothing
_ErrRR:
	xor eax,eax
	ret
_ReadRec endp

_WriteRec proc uses ebx edi
	LOCAL @str[MAX_STRINGLEN]:byte
	LOCAL @hFile
	LOCAL @dbHdr[sizeof _FileRec]:byte
	lea ebx,@str
	invoke lstrcpyW,ebx,lpszConfigFile
	invoke _DirBackW,ebx
	invoke SetCurrentDirectoryW,ebx
	or eax,eax
	je _ErrWR
	invoke _DirCatW,ebx,offset szRecDir
	invoke SetCurrentDirectoryW,ebx
	.if !eax
		invoke CreateDirectoryW,offset szRecDir,0
		invoke SetCurrentDirectoryW,ebx
		or eax,eax
		je _ErrWR
	.endif
	invoke lstrcpyW,ebx,offset FileInfo1.szName
	invoke lstrcatW,ebx,offset szRecExt
	invoke _DirFileNameW,ebx
	or eax,eax
	je _ErrWR
	invoke CreateFileW,eax,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrWR
	mov @hFile,eax
	lea edi,@dbHdr
	assume edi:ptr _FileRec
	mov [edi].nPos,0
	invoke SendMessageW,hList1,LB_GETCURSEL,0,0
	.if eax!=-1
		mov [edi].nPos,eax
	.endif
	mov [edi].nOffsetMT,sizeof _FileRec
	mov eax,FileInfo1.nLine
	mov [edi].nLenMT,eax
	invoke WriteFile,@hFile,edi,sizeof _FileRec,offset dwTemp,0
	.if lpMarkTable
		invoke WriteFile,@hFile,lpMarkTable,FileInfo1.nLine,offset dwTemp,0
	.endif
	invoke CloseHandle,@hFile
	mov eax,1
	ret
_ErrWR:
	xor eax,eax
	ret
_WriteRec endp

_Dev proc
	mov eax,IDS_DEVELOP
	invoke _GetConstString
	mov ecx,eax
	mov eax,IDS_SHUAI
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,ecx,MB_OK or MB_ICONEXCLAMATION
	ret
_Dev endp

;
_memcpy proc
;	mov eax,edi
;	and eax,3
;	mov edx,ecx
;	mov ecx,4
;	sub ecx,eax
;	rep movsb
;	mov ecx,edx
;	
	
	mov eax,ecx
	shr ecx,2
	REP MOVSd
	mov ecx,eax
	and ecx,3
	REP MOVSb
	ret
_memcpy endp
