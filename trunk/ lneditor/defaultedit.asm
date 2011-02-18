.code


;
_GetText proc uses esi edi ebx _pFI,_lpRI
	LOCAL @pEndO,@pEndN,@lpCur,@bIsUnicode
	LOCAL @nCurLine
	mov ebx,_pFI
	assume ebx:ptr _FileInfo
	mov edi,[ebx].lpStream
	mov @lpCur,edi
	mov eax,edi
	add eax,[ebx].nStreamSize
	mov @pEndO,eax

	;计算行数
	.if word ptr [edi]==0feffh
		mov @bIsUnicode,1
		mov [ebx].nCharSet,CS_UNICODE
		add edi,2
_ForceUniGT:
		xor ecx,ecx
		.repeat
			.if word ptr [edi]==0dh
				inc ecx
			.endif
			add edi,2
		.until edi>=@pEndO || !word ptr [edi]
;		.if word ptr [edi-4]!=0dh
			inc ecx
;		.endif
	.elseif word ptr [edi]==0bbefh && byte ptr [edi+2]==0bfh
		mov [ebx].nCharSet,CS_UTF8
		add edi,3
		jmp _ForceMBCS
	.else
		.if [ebx].nCharSet==CS_UNICODE
			mov @bIsUnicode,1
			jmp _ForceUniGT		
		.endif
		mov @bIsUnicode,0
_ForceMBCS:
		xor ecx,ecx
		.repeat
			.if word ptr [edi]==0a0dh
				inc ecx
			.endif
			inc edi
		.until edi>=@pEndO || !byte ptr [edi]
;		.if byte ptr [edi-2]!=0dh
			inc ecx
;		.endif
	.endif
	mov [ebx].nLine,ecx
	inc ecx
	shl ecx,2
	mov edi,ecx
	
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT2
	mov [ebx].lpStreamIndex,eax
	mov esi,eax
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT2
	mov [ebx].lpTextIndex,eax
	mov edi,eax
	mov [ebx].lpTextIndex,eax
	mov [ebx].lpText,0
	
	mov eax,@lpCur
	.if @bIsUnicode && word ptr [eax]==0feffh
		add eax,2
		mov @lpCur,eax
	.endif
	xor eax,eax
	mov @nCurLine,eax
	.while eax<[ebx].nLine
		mov ecx,@lpCur
		mov [esi],ecx
		add esi,4
		invoke _GetStringInTxt,edi,addr @lpCur,[ebx].nCharSet
		or eax,eax
		jne _NomemGT2
		add edi,4
		.if dbTxtFunc+_TxtFunc.IsLineAdding
			push [edi-4]
			call dbTxtFunc+_TxtFunc.IsLineAdding
			.if !eax
				sub edi,4
				sub esi,4
				jmp @F
			.endif
		.endif
		.if dbTxtFunc+_TxtFunc.TrimLineHead
			push [edi-4]
			call dbTxtFunc+_TxtFunc.TrimLineHead
			add [esi-4],eax
		.endif
		@@:
		inc @nCurLine
		mov eax,@nCurLine
	.endw
	sub edi,[ebx].lpTextIndex
	shr edi,2
	mov [ebx].nLine,edi
	mov [ebx].nLineLen,0
	mov [ebx].nMemoryType,MT_EVERYSTRING
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_SUC_LINEONLY
	xor eax,eax
	ret
_NomemGT2:
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_FAIL_MEM
	or eax,E_ERROR
	ret
_GetText endp

;
_SaveText proc uses edi _pFI
	mov edi,_pFI
	assume edi:ptr _FileInfo
	invoke SetFilePointer,[edi].hFile,0,0,FILE_BEGIN
	invoke WriteFile,[edi].hFile,[edi].lpStream,[edi].nStreamSize,offset dwTemp,0
	or eax,eax
	je _ErrST
	invoke SetEndOfFile,[edi].hFile
	or eax,eax
	je _ErrST
	assume edi:nothing
	xor eax,eax
	ret
_ErrST:
	mov eax,E_FILEACCESSERROR
	ret
_SaveText endp

;
_ModifyLineA proc uses esi edi ebx _pFI,_nLine
	LOCAL @pTemp,@pNewStr,@pNewLen,@pOldLen
	mov edi,_pFI
	assume edi:ptr _FileInfo
	invoke _GetStringInList,_pFI,_nLine
	.if !eax
		mov eax,E_LINENOTEXIST
		jmp _ExMLA
	.endif
	mov ebx,eax
	invoke lstrlenW,ebx
	shl eax,2
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	.if !eax
		mov eax,E_NOMEM
		jmp _ExMLA
	.endif
	mov @pNewStr,eax
	mov esi,[edi].lpStreamIndex
	mov eax,_nLine
	mov esi,[esi+eax*4]
	
	invoke WideCharToMultiByte,[edi].nCharSet,0,ebx,-1,@pNewStr,100000,0,0
	.if !eax
		invoke HeapFree,hGlobalHeap,0,@pNewStr
		mov eax,E_NOTENOUGHBUFF
		jmp _ExMLA
	.endif
	dec eax
	mov @pNewLen,eax
	mov edx,esi
	.while word ptr [esi]!=0a0dh
		.break .if !byte ptr [esi]
		inc esi
	.endw
	
	mov ecx,[edi].nStreamSize
	add ecx,[edi].lpStream
	sub ecx,esi
	sub esi,edx
	mov @pOldLen,esi
	invoke _ReplaceInMem,@pNewStr,@pNewLen,edx,esi,ecx
	or eax,eax
	jne _ExMLA
	invoke HeapFree,hGlobalHeap,0,@pNewStr
	
	mov esi,[edi].lpStreamIndex
	mov eax,_nLine
	lea esi,[esi+eax*4+4]
	mov eax,@pNewLen
	sub eax,@pOldLen
	.while dword ptr [esi]
		add [esi],eax
		add esi,4
	.endw
	add [edi].nStreamSize,eax
	mov eax,[edi].lpStream
	add eax,[edi].nStreamSize
	mov word ptr [eax],0
	assume edi:nothing
	
	xor eax,eax
_ExMLA:
	ret
_ModifyLineA endp

_ModifyLineW proc uses esi edi ebx _pFI,_nLine
	LOCAL @pTemp,@pNewStr,@pNewLen,@pOldLen
	mov edi,_pFI
	assume edi:ptr _FileInfo
	invoke _GetStringInList,_pFI,_nLine
	.if !eax
		mov eax,E_LINENOTEXIST
		jmp _ExMLW
	.endif
	mov ebx,eax
	invoke lstrlenW,ebx
	shl eax,1
	mov @pNewLen,eax
	mov esi,[edi].lpStreamIndex
	mov eax,_nLine
	mov esi,[esi+eax*4]
	mov edx,esi
	.while word ptr [esi]!=0dh
		.break .if !word ptr [esi]
		add esi,2
	.endw
	
	mov ecx,[edi].nStreamSize
	add ecx,[edi].lpStream
	sub ecx,esi
	sub esi,edx
	mov @pOldLen,esi
	invoke _ReplaceInMem,ebx,@pNewLen,edx,esi,ecx
	or eax,eax
	jne _ExMLW
	
	mov esi,[edi].lpStreamIndex
	mov eax,_nLine
	lea esi,[esi+eax*4+4]
	mov eax,@pNewLen
	sub eax,@pOldLen
	.while dword ptr [esi]
		add [esi],eax
		add esi,4
	.endw
	add [edi].nStreamSize,eax
	mov eax,[edi].lpStream
	add eax,[edi].nStreamSize
	mov word ptr [eax],0
	assume edi:nothing
	
	xor eax,eax
_ExMLW:
	ret
_ModifyLineW endp

_ModifyLine proc uses esi edi ebx _pFI,_nLine
	mov eax,_pFI
	.if dword ptr [eax+_FileInfo.nCharSet]==CS_UNICODE
		invoke _ModifyLineW,_pFI,_nLine
	.else
		invoke _ModifyLineA,_pFI,_nLine
	.endif
	ret
_ModifyLine endp


;
_GetStringInTxt proc uses esi edi _lppString,_lppBuff,_nCharSet
	LOCAL @nStrLen,@lpTmpBuff
	mov eax,_lppBuff
	mov eax,[eax]
	mov ecx,_nCharSet
	.if ecx==CS_UNICODE
		cmp word ptr [eax],0dh
		jne @F
		mov ecx,_lppBuff
		add dword ptr [ecx],4
	.else
		.if word ptr [eax]==0a0dh
			mov ecx,_lppBuff
			add dword ptr [ecx],2
			jmp _NullStrGSFM
		.endif
		cmp byte ptr [eax],0
		jne @F
	.endif
	_NullStrGSFM:
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,4
	mov ecx,_lppString
	mov [ecx],eax
	xor eax,eax
	jmp _ExGSFM
	@@:
	push offset _HandlerGSFM	;防止lpbuff内存越界访问
	push fs:[0]
	mov fs:[0],esp
	mov edx,_nCharSet
	mov eax,_lppBuff
	mov edi,[eax]
	.if edx==CS_UNICODE
		xor ecx,ecx
		.while word ptr [edi]!=0dh
			.break .if !word ptr [edi]
			add edi,2
			add ecx,2
		.endw
		mov @nStrLen,ecx
		add ecx,2
;		mov eax,MAX_STRINGLEN
;		.if ecx>eax
;			mov eax,ecx
;		.endif
		invoke HeapAlloc,hGlobalHeap,0,ecx
		.if !eax
			pop fs:[0]
			add esp,4
			mov eax,E_NOMEM
			jmp _ExGSFM
		.endif
		mov edx,_lppString
		mov [edx],eax
		mov ecx,@nStrLen
		shr ecx,1
		mov edi,eax
		mov eax,_lppBuff
		mov esi,[eax]
		rep movsw
		mov word ptr [edi],0
		add esi,4
		mov ecx,_lppBuff
		mov [ecx],esi
		pop fs:[0]
		add esp,4
	.else
		xor ecx,ecx
		.while word ptr [edi]!=0a0dh
			.break .if !byte ptr [edi]
			inc edi
			inc ecx
		.endw
		lea eax,[edi+2]
		mov @lpTmpBuff,eax
		pop fs:[0]
		add esp,4
		mov @nStrLen,ecx
		inc ecx
		shl ecx,1
		mov eax,ecx
;		mov eax,MAX_STRINGLEN
;		.if ecx>eax
;			mov eax,ecx
;		.endif
;		mov ecx,eax
		shr ecx,1
		push ecx
		invoke HeapAlloc,hGlobalHeap,0,eax
		.if !eax
			add esp,4
			mov eax,E_NOMEM
			jmp _ExGSFM
		.endif
		mov ecx,_lppString
		mov [ecx],eax
		push eax
		push @nStrLen
		mov eax,_lppBuff
		push [eax]
		push 0
		push _nCharSet
		call MultiByteToWideChar
		.if !eax
			mov eax,E_NOTENOUGHBUFF
			jmp _ExGSFM
		.endif
		mov ecx,_lppString
		mov edx,[ecx]
		mov word ptr [edx+eax*2],0
		mov ecx,_lppBuff
		mov eax,@lpTmpBuff
		mov [ecx],eax
	.endif
	
	xor eax,eax
_ExGSFM:
	ret
_ErrOverMemGSFM:
	pop fs:[0]
	pop ecx
	mov eax,E_OVERMEM
	jmp _ExGSFM
_HandlerGSFM:
	mov eax,[esp+0ch]
	mov [eax+0b8h],offset _ErrOverMemGSFM
	xor eax,eax
	ret
_GetStringInTxt endp

;
_ReplaceInMem proc uses esi edi _lpNew,_nNewLen,_lpOriPos,_nOriLen,_nLeftLen
	mov eax,_nNewLen
	.if eax==_nOriLen || !_nLeftLen
		mov esi,_lpNew
		mov edi,_lpOriPos
		mov ecx,eax
		rep movsb
		xor eax,eax
	.elseif eax>_nOriLen
	@@:
		invoke HeapAlloc,hGlobalHeap,0,_nLeftLen
		.if !eax
			mov eax,E_NOMEM
			jmp _ExRIM
		.endif
		push eax
		mov ecx,_nLeftLen
		mov esi,_lpOriPos
		add esi,_nOriLen
		mov edi,eax
		invoke _memcpy
		mov esi,_lpNew
		mov ecx,_nNewLen
		mov edi,_lpOriPos
		rep movsb
		mov esi,[esp]
		mov ecx,_nLeftLen
		invoke _memcpy
		push 0
		push hGlobalHeap
		call HeapFree
		xor eax,eax
	.else
		mov ecx,_nOriLen
		sub ecx,eax
		cmp ecx,4
		jb @B
		mov esi,_lpNew
		mov ecx,_nNewLen
		mov edi,_lpOriPos
		rep movsb
		mov esi,_lpOriPos
		add esi,_nOriLen
		mov ecx,_nLeftLen
		invoke _memcpy
		xor eax,eax
	.endif
_ExRIM:
	ret
_ReplaceInMem endp

;
_SetLine proc uses edi ebx _lpsz,_lpRange
	cmp _lpRange,0
	je _ExSL
	mov edi,_lpsz
	invoke lstrlenW,edi
	mov ebx,eax
	mov ax,[edi]
	.if ax==300ch || ax==300eh
		lea edi,[edi+ebx*2]
		std
		mov edx,edi
		mov ecx,ebx
		mov ax,300dh
		repne scasw
		.if ecx>1
			cld
		@@:
			mov eax,_lpRange
			mov dword ptr [eax],1
			sub edi,_lpsz
			shr edi,1
			inc edi
			mov [eax+4],edi
			jmp _ExSL
		.endif
		
		mov edi,edx
		mov ax,300fh
		mov ecx,ebx
		repne scasw
		cld
		cmp ecx,1
		ja @B
		mov eax,_lpRange
		mov dword ptr [eax],1
		jmp _ExSL
	.endif
	
	.if word ptr [edi]==3000h
		mov eax,_lpRange
		mov dword ptr [eax],1
	.endif
	
	lea edi,[edi+ebx*2-2]
	mov ax,[edi]
	.if ax==300dh || ax==300fh
		cld
		mov edi,_lpsz
		mov ax,300ch
		mov ecx,ebx
		repne scasw
		.if ecx>1
			@@:
			mov eax,_lpRange
			dec ebx
			mov [eax+4],ebx
			sub edi,_lpsz
			shr edi,1
			mov [eax],edi
			jmp _ExSL
		.endif
		
		mov edi,_lpsz
		mov ax,300eh
		mov ecx,ebx
		repne scasw
		cmp ecx,1
		ja @B
		
		mov eax,_lpRange
		dec ebx
		mov [eax+4],ebx
	.endif
_ExSL:
	ret
_SetLine endp


