.code
assume fs:nothing

;
_OpenScript proc
	LOCAL @nReturnInfo
	
	xor eax,eax
	mov FileInfo2.bReadOnly,ax
	mov FileInfo1.bFirstCreate,ax
	mov FileInfo2.bFirstCreate,ax
	inc eax
	mov FileInfo1.bReadOnly,ax
	.if dbConf+_Configs.nEditMode==EM_SINGLE
		invoke _GenName2,offset FileInfo1.szName,offset FileInfo2.szName
		or eax,eax
		je _ExOS
	.endif
	
	invoke _LoadFile,offset FileInfo1,LM_NONE
	.if !eax
		invoke _ClearAll,offset FileInfo1
		jmp _ErrLoadOS
	.endif
	.if dbConf+_Configs.nEditMode==EM_SINGLE
		invoke _LoadFile,offset FileInfo2,LM_HALF
		.if !eax
			invoke GetLastError
			.if eax==ERROR_FILE_NOT_FOUND
				invoke CopyFileW,offset FileInfo1.szName,offset FileInfo2.szName,FALSE
				mov FileInfo2.bFirstCreate,TRUE
				invoke _LoadFile,offset FileInfo2,LM_HALF
				or eax,eax
				jne @F
			.endif
			invoke _ClearAll,offset FileInfo1
			invoke _ClearAll,offset FileInfo2
			jmp _ErrLoadOS
		.endif
	.endif
	
	@@:
	push offset _HandlerOS
	push fs:[0]
	mov fs:[0],esp
	lea eax,@nReturnInfo
	push eax
	push offset FileInfo1
	call dword ptr [dbSimpFunc+_SimpFunc.GetText]
	.if eax
		.if @nReturnInfo==RI_SUC_LINEONLY
			invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,FileInfo1.nLine
			mov lpMarkTable,eax
			mov nCurIdx,-1
			invoke _AddLinesToList,offset FileInfo1,hList1
		.endif
	.else
		invoke _ClearAll,offset FileInfo1
		mov eax,IDS_DLLERR
		invoke _GetConstString
		invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
		jmp _Ex2OS
	.endif
	.if dbConf+_Configs.nEditMode==EM_SINGLE
		lea eax,@nReturnInfo
		push eax
		push offset FileInfo2
		call dword ptr [dbSimpFunc+_SimpFunc.GetText]
		.if eax
			.if @nReturnInfo==RI_SUC_LINEONLY
				mov nCurIdx,-1
				invoke _AddLinesToList,offset FileInfo2,hList2
				invoke _SetOpen,1
			.endif
		.else
			invoke _ClearAll,offset FileInfo1
			invoke _ClearAll,offset FileInfo2
			jmp _Ex2OS
		.endif
		
		invoke EnableMenuItem,hMenu,IDM_LOAD,MF_GRAYED
		
		invoke _ReadRec
		mov nCurIdx,eax
		
		invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN+SHORT_STRINGLEN
		or eax,eax
		je _Ex2OS
		mov ebx,eax
		invoke _GenWindowTitle,ebx,GWT_FILENAME1
		invoke SetWindowTextW,hWinMain,ebx
		invoke HeapFree,hGlobalHeap,0,ebx
	.else
		invoke EnableMenuItem,hMenu,IDM_LOAD,MF_ENABLED
	.endif
_Ex2OS:
	pop fs:[0]
	pop ecx
_ExOS:
	xor eax,eax
	ret
_ErrLoadOS:
	mov eax,IDS_ERRLOADFILE
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	xor eax,eax
	ret
_ErrDllOS:
	pop fs:[0]
	pop eax
	mov eax,IDS_DLLERR
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	invoke _ClearAll,offset FileInfo1
	invoke _ClearAll,offset FileInfo2
	xor eax,eax
	ret
_HandlerOS:
	mov eax,[esp+0ch]
	mov [eax+0b8h],offset _ErrDllOS
	xor eax,eax
	ret
_OpenScript endp

;
_LoadScript proc
	LOCAL @nReturnInfo
	
	invoke _LoadFile,offset FileInfo2,LM_HALF
	.if !eax
		invoke _ClearAll,offset FileInfo2
		jmp _ErrLoadLS
	.endif
	
	push offset _HandlerLS
	push fs:[0]
	mov fs:[0],esp
	lea eax,@nReturnInfo
	push eax
	push offset FileInfo2
	call dword ptr [dbSimpFunc+_SimpFunc.GetText]
	.if eax
		.if @nReturnInfo==RI_SUC_LINEONLY
			mov nCurIdx,-1
			invoke _AddLinesToList,offset FileInfo2,hList2
			invoke _SetOpen,1
		.endif
	.else
		invoke _ClearAll,offset FileInfo2
		jmp _Ex2LS
	.endif
_Ex2LS:
	pop fs:[0]
	pop ecx
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN+SHORT_STRINGLEN
	or eax,eax
	je _ExLS
	mov ebx,eax
	invoke _GenWindowTitle,ebx,GWT_FILENAME2
	invoke SetWindowTextW,hWinMain,ebx
	invoke HeapFree,hGlobalHeap,0,ebx

_ExLS:
	xor eax,eax
	ret
_ErrLoadLS:
	mov eax,IDS_ERRLOADFILE
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	xor eax,eax
	ret
_ErrDllLS:
	pop fs:[0]
	pop eax
	mov eax,IDS_DLLERR
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	invoke _ClearAll,offset FileInfo2
	xor eax,eax
	ret
_HandlerLS:
	mov eax,[esp+0ch]
	mov [eax+0b8h],offset _ErrDllLS
	xor eax,eax
	ret
_LoadScript endp

;
_SaveScript proc
	.if bModified
		invoke _SaveFile,offset FileInfo2
		or eax,eax
		je _ErrSS
		mov eax,IDS_SUCSAVE
		INVOKE _GetConstString
		invoke _DisplayStatus,eax,2000
		invoke _SetModified,0
	.endif
	xor eax,eax
	ret
_ErrSS:
	mov eax,IDS_ERRSAVE
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	xor eax,eax
	ret
_SaveScript endp

;
_SaveAs proc
	LOCAL @fi:_FileInfo
	LOCAL @szStr[MAX_STRINGLEN]:byte
	lea eax,@szStr
	mov word ptr [eax],0
	mov eax,IDS_OPENTITLE3
	invoke _GetConstString	
	invoke _SaveFileDlg,offset szOpenFilter,addr @szStr,dbConf+_Configs.lpInitDir2,eax
	.if eax
		lea edi,@fi
		lea esi,FileInfo2
		mov ecx,sizeof _FileInfo
		rep movsb
		invoke lstrcpyW,addr @fi.szName,addr @szStr
		invoke CreateFileW,addr @fi.szName,GENERIC_WRITE or GENERIC_READ,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax==-1
			mov eax,IDS_CANTOPENFILE
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
			jmp _ExSA
		.endif
		mov @fi.hFile,eax
		
		invoke _SaveFile,addr @fi
		or eax,eax
		je _ErrSA
		mov eax,IDS_SUCSAVE
		INVOKE _GetConstString
		invoke _DisplayStatus,eax,2000
	.endif
_ExSA:
	xor eax,eax
	ret
_ErrSA:
	mov eax,IDS_ERRSAVE
	invoke _GetConstString
	invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
	jmp _ExSA
_SaveAs endp

;
_CloseScript proc
	.if bModified
		invoke _SaveOrNot
		.if eax==IDYES
			invoke _SaveFile,offset FileInfo2
			or eax,eax
			jne @F
			mov eax,IDS_ERRSAVE
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
			jmp _Ex2CSC
		.endif
		cmp eax,IDCANCEL
		je _Ex2CSC
	.endif
	invoke lstrcpyW,dbConf+_Configs.lpPrevFile,offset FileInfo1.szName
	invoke _WriteRec
	@@:
	.if lpMarkTable
		invoke HeapFree,hGlobalHeap,0,lpMarkTable
		mov lpMarkTable,0
	.endif
	invoke SendMessageW,hList1,LB_RESETCONTENT,0,0
	invoke SendMessageW,hList2,LB_RESETCONTENT,0,0
	invoke _ClearAll,offset FileInfo1
	invoke _ClearAll,offset FileInfo2
	invoke SendMessageW,hEdit1,WM_SETTEXT,0,offset szNULL
	invoke SendMessageW,hEdit2,WM_SETTEXT,0,offset szNULL
	invoke SetFocus,hList1
	invoke _SetModified,0
	invoke _SetOpen,0
	mov nCurIdx,-1
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,64
	or eax,eax
	je _ExCSC
	push eax
	invoke _GenWindowTitle,eax,GWT_VERSION
	invoke SetWindowTextW,hWinMain,[esp]
	push 0
	push hGlobalHeap
	call HeapFree
_ExCSC:
	xor eax,eax
	ret
_Ex2CSC:
	or eax,-1
	ret
_CloseScript endp

;
_SetSaveDir proc
	invoke _Dev
	xor eax,eax
	ret
_SetSaveDir endp

;
_ExportTxt proc
	LOCAL @szStr[MAX_STRINGLEN]:byte
	LOCAL @hTxtFile
	
	invoke lstrcpyW,addr @szStr,offset FileInfo2.szName
	invoke _DirModifyExtendName,addr @szStr,offset szTxt
	
	mov eax,IDS_EXPORTTXT
	invoke _GetConstString
	invoke _SaveFileDlg,offset szTxtFilter,addr @szStr,dbConf+_Configs.lpInitDir2,eax
	.if eax
		invoke CreateFileW,addr @szStr,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax==-1
			mov eax,IDS_CANTOPENFILE
_ErrET:
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
			jmp _ExET
		.endif
		mov @hTxtFile,eax
		invoke _ExportSingleTxt,offset FileInfo2,@hTxtFile
		mov ebx,eax
		invoke CloseHandle,@hTxtFile
		.if !ebx
			mov eax,IDS_FAILEXPORT
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
			
			jmp _ExET
		.endif
		
		mov eax,IDS_SUCEXPORT
		invoke _GetConstString
		invoke _DisplayStatus,eax,2000
	.endif
_ExET:
	xor eax,eax
	ret
_ExportTxt endp

;
_ExportSingleTxt proc uses esi edi ebx _lpFI,_hTxt
	LOCAL @lpBuff,@nLine
	mov ecx,_lpFI
	assume ecx:ptr _FileInfo
	invoke VirtualAlloc,0,[ecx].nStreamSize,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _ErrEST
	mov @lpBuff,eax
	
	mov edi,@lpBuff
	mov ax,0feffh
	stosw
	xor ebx,ebx
	mov ecx,_lpFI
	mov eax,[ecx].nLine
	mov @nLine,eax
	.if [ecx].lpTextIndex
		mov esi,[ecx].lpTextIndex
		.while ebx<@nLine
			invoke lstrcpyW,edi,[esi]
			invoke lstrlenW,[esi]
			shl eax,1
			add edi,eax
			mov eax,0a000dh
			stosd
			add esi,4
			inc ebx
		.endw
	.else
		mov esi,[ecx].lpText
		.while ebx<@nLine
			invoke lstrcpyW,edi,esi
			invoke lstrlenW,esi
			shl eax,1
			add edi,eax
			mov eax,0a000dh
			stosd
			mov ecx,_lpFI
			add esi,[ecx].nLineLen
			inc ebx
		.endw
	.endif
	sub edi,@lpBuff
	invoke SetFilePointer,_hTxt,0,0,FILE_BEGIN
	invoke WriteFile,_hTxt,@lpBuff,edi,offset dwTemp,0
	mov ebx,eax
	invoke VirtualFree,@lpBuff,0,MEM_RELEASE
	invoke SetEndOfFile,_hTxt
	or ebx,ebx
	je _ErrEST
	assume ecx:nothing
	mov eax,1
	ret
_ErrEST:
	xor eax,eax
	ret
_ExportSingleTxt endp

;
_ImportTxt proc
	LOCAL @szStr[MAX_STRINGLEN]:byte
	LOCAL @hTxtFile,@lpBuff,@pEnd,@nFlag
	local @nFZ:LARGE_INTEGER

	lea eax,@szStr
	mov word ptr [eax],0	
	mov eax,IDS_IMPORTTXT
	invoke _GetConstString
	invoke _OpenFileDlg,offset szTxtFilter,addr @szStr,dbConf+_Configs.lpInitDir2,eax
	.if eax
		invoke CreateFileW,addr @szStr,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax==-1
			mov eax,IDS_CANTOPENFILE
_ErrIT:
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
			jmp _ExIT
		.endif
		mov @hTxtFile,eax
		invoke GetFileSizeEx,@hTxtFile,addr @nFZ
		invoke VirtualAlloc,0,dword ptr @nFZ,MEM_COMMIT,PAGE_READWRITE
		.if !eax
_NomemIT:
			invoke CloseHandle,@hTxtFile
			mov eax,IDS_NOMEM
			jmp _ErrIT 
		.endif
		mov @lpBuff,eax
		invoke ReadFile,@hTxtFile,@lpBuff,dword ptr @nFZ,offset dwTemp,0
		
		mov edi,@lpBuff
		.if word ptr [edi]!=0feffh
			invoke CloseHandle,@hTxtFile
			invoke VirtualFree,@lpBuff,0,MEM_RELEASE
			mov eax,IDS_TXTUNICODE
			jmp _ErrIT
		.endif
		mov eax,edi
		add edi,2
		add eax,dword ptr @nFZ
		mov @pEnd,eax
		
		xor ecx,ecx
		.repeat
			.if word ptr [edi]==0dh
				inc ecx
			.endif
			add edi,2
		.until edi>=@pEnd || !word ptr [edi]
		.if word ptr [edi-4]!=0dh
			inc ecx
		.endif
		.if ecx!=FileInfo2.nLine
			mov eax,IDS_LINENOTMATCH
			invoke _GetConstString
			mov ecx,eax
			mov eax,IDS_WINDOWTITLE
			invoke _GetConstString
			invoke MessageBoxW,hWinMain,ecx,eax,MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING
			.if eax==IDNO
				invoke CloseHandle,@hTxtFile
				invoke VirtualFree,@lpBuff,0,MEM_RELEASE
				jmp _ExIT
			.endif
		.endif
		
		mov edi,@lpBuff
		add edi,2
		.if FileInfo2.lpTextIndex
			mov ebx,FileInfo2.lpTextIndex
			xor esi,esi
			.repeat
				mov eax,edi
				.while dword ptr [edi]!=0a000dh					
					add edi,2
					.break .if !word ptr [edi] || edi>=@pEnd
				.endw
				mov dword ptr [edi],0
				add edi,2
				mov [ebx],eax
				add ebx,4
				inc esi
			.until edi>=@pEnd || esi>=FileInfo2.nLine
			invoke VirtualFree,FileInfo2.lpText,0,MEM_RELEASE
			mov eax,@lpBuff
			mov FileInfo2.lpText,eax
			jmp _SucIT
		.else
			mov @nFlag,0
			mov ebx,FileInfo2.lpText
			xor esi,esi
			.repeat
				mov eax,edi
				.while word ptr [edi]!=0dh
					add edi,2
					.break .if !word ptr [edi] || edi>=@pEnd
				.endw
				mov word ptr [edi],0
				add edi,2
				lea ecx,[edi-2]
				sub ecx,eax
				.if ecx<FileInfo2.nLineLen
					invoke lstrcpyW,ebx,eax
				.else
					mov word ptr [ebx],0
					mov @nFlag,1
				.endif
				add ebx,FileInfo2.nLineLen
				inc esi
			.until edi>=@pEnd || esi>=FileInfo2.nLine
			invoke VirtualFree,@lpBuff,0,MEM_RELEASE
			.if @nFlag
				mov eax,IDS_IMPORTPART
				invoke _GetConstString
				mov ecx,eax
				mov eax,IDS_WINDOWTITLE
				invoke _GetConstString
				invoke MessageBoxW,hWinMain,ecx,eax,MB_OK or MB_ICONINFORMATION
			.else
_SucIT:
				xor ebx,ebx
				.while ebx<FileInfo2.nLine
					push ebx
					push offset FileInfo2
					call dbSimpFunc+_SimpFunc.ModifyLine
					.if !eax
						mov eax,IDS_FAILIMPORT
						invoke _GetConstString
						invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
						jmp _ExIT
					.endif
				.endw
				
				mov eax,IDS_SUCIMPORT
				invoke _GetConstString
				invoke _DisplayStatus,eax,2000
			.endif
		.endif
		
		invoke CloseHandle,@hTxtFile
		invoke _SetModified,1
	.endif
_ExIT:
	xor eax,eax
	ret
_ImportTxt endp

;
_Exit proc
	invoke SendMessageW,hWinMain,WM_CLOSE,0,0
	ret
_Exit endp
