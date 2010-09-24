.code

;
_GetText proc uses edi esi ebx _pFI,_lpRI
	LOCAL @pEndO,@pEndN,@nTextSize
	mov ebx,_pFI
	assume ebx:ptr _FileInfo
	mov edi,[ebx].lpStream
	mov eax,edi
	add eax,[ebx].nStreamSize
	mov @pEndO,eax
	
	;计算行数
	.if word ptr [edi]==0feffh
		add edi,2
		xor ecx,ecx
		.repeat
			.if word ptr [edi]==0dh
				inc ecx
			.endif
			add edi,2
		.until edi>=@pEndO || !word ptr [edi]
		.if word ptr [edi-4]!=0dh
			inc ecx
		.endif
	.else
		xor ecx,ecx
		.repeat
			.if word ptr [edi]==0a0dh
				inc ecx
			.endif
			inc edi
		.until edi>=@pEndO || !byte ptr [edi]
		.if byte ptr [edi-2]!=0dh
			inc ecx
		.endif
	.endif
	mov [ebx].nLine,ecx
	inc ecx
	shl ecx,2
	mov edi,ecx
	
	;分配两组索引空间
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	.if !eax
_NomemGT:
		mov eax,_lpRI
		mov dword ptr [eax],RI_FAIL_MEM
		jmp _ErrGT
	.endif
	mov [ebx].lpStreamIndex,eax
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [ebx].lpTextIndex,eax
	mov eax,[ebx].nStreamSize
	mov ecx,eax
	shr ecx,1
	add eax,ecx
	mov edi,eax
	
	;采用变长字符串数组存储，分配其空间
	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [ebx].lpText,eax
	mov eax,[ebx].lpStream
	.if word ptr [eax]==0feffh
		mov edi,[ebx].lpText
		mov esi,[ebx].lpStream
		mov ecx,[ebx].nStreamSize
		mov @nTextSize,ecx
		invoke _memcpy
	.else
		;变长字符串数组，直接从原始文件拷贝，之前先转码
		invoke MultiByteToWideChar,936,MB_PRECOMPOSED,[ebx].lpStream,-1,0,0
		shl eax,1
		.if eax>edi
			mov edi,eax
			mov ecx,eax
			shr ecx,1
			add edi,ecx
			invoke VirtualFree,[ebx].lpText,0,MEM_RELEASE
			invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
			or eax,eax
			je _NomemGT
			mov [ebx].lpText,eax
		.endif
		invoke MultiByteToWideChar,936,MB_PRECOMPOSED,[ebx].lpStream,-1,[ebx].lpText,edi
		.if !eax
			mov eax,_lpRI
			mov dword ptr [eax],RI_FAIL_CODE
			jmp _ErrGT
		.endif
		shl eax,1
		mov @nTextSize,eax
	.endif
	mov esi,[ebx].lpTextIndex
	mov edi,[ebx].lpText
	mov eax,edi
	add eax,@nTextSize
	mov @pEndN,eax
	.if word ptr [edi]==0feffh
		add edi,2
	.endif
	mov eax,edi
	
	;字符串数组处理
	.repeat
		.if word ptr [edi]==0dh
			mov word ptr [edi],0
			mov [esi],eax
			add esi,4
			lea eax,[edi+4]
		.endif
		add edi,2
	.until edi>=@pEndN || !word ptr [edi]
	.if word ptr [edi-2]!=0ah
		mov [esi],eax
	.endif
	
	;原始文件索引生成
	mov eax,[ebx].lpStream
	.if word ptr [eax]==0feffh
		mov edi,[ebx].lpStreamIndex
		mov esi,[ebx].lpTextIndex
		mov ecx,[ebx].nLine
		shl ecx,2
		invoke _memcpy
		mov edx,[ebx].lpStream
		sub edx,[ebx].lpText
		xor ecx,ecx
		mov edi,[ebx].lpStreamIndex
		.while ecx<[ebx].nLine
			add dword ptr [edi+ecx*4],edx
			inc ecx
		.endw
	.else
		mov esi,[ebx].lpStreamIndex
		mov edi,[ebx].lpStream
		mov eax,edi
		.repeat
			.if word ptr [edi]==0a0dh
				mov [esi],eax
				add esi,4
				lea eax,[edi+2]
			.endif
			inc edi
		.until edi>=@pEndO || !byte ptr [edi]
		.if byte ptr [edi-2]!=0dh
			mov [esi],eax
		.endif
	.endif
	assume ebx:nothing
	mov eax,_lpRI
	mov dword ptr [eax],RI_SUC_LINEONLY
	mov eax,1
	ret
_ErrGT:
	xor eax,eax
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
	ret
_ErrST:
	xor eax,eax
	ret
_SaveText endp

;
_ModifyLine proc uses esi edi ebx _pFI,_nLine
	LOCAL @pTemp,@pNewStr,@pNewLen,@pOldLen
	mov edi,_pFI
	assume edi:ptr _FileInfo
	invoke _GetStringInList,_pFI,_nLine
	or eax,eax
	je _ErrML
	mov ebx,eax
	invoke lstrlenW,ebx
	shl eax,1
	mov @pNewLen,eax
	shl eax,1
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	or eax,eax
	je _ErrML
	mov @pNewStr,eax	
	mov esi,[edi].lpStreamIndex
	mov eax,_nLine
	mov esi,[esi+eax*4]
	mov eax,[edi].lpStream
	.if word ptr [eax]==0feffh
		invoke lstrcpyW,@pNewStr,ebx
		mov edx,esi
		.while word ptr [esi]!=0dh
			add esi,2
			.break .if !word ptr [esi]
		.endw
	.else
		invoke WideCharToMultiByte,936,0,ebx,-1,@pNewStr,100000,0,0
		.if !eax
			invoke HeapFree,hGlobalHeap,0,@pNewStr
			jmp _ErrML
		.endif
		dec eax
		mov @pNewLen,eax
		mov edx,esi
		.while word ptr [esi]!=0a0dh
			inc esi
			.break .if !byte ptr [esi]
		.endw
	.endif
	mov eax,esi
	sub eax,edx
	mov @pOldLen,eax
	
	mov ecx,[edi].nStreamSize
	add ecx,[edi].lpStream
	assume edi:nothing
	sub ecx,esi
	mov ebx,ecx
	.if !ebx
		inc ebx
	.endif
	pushad
	invoke VirtualAlloc,0,ebx,MEM_COMMIT,PAGE_READWRITE
	.if !eax
		popad
		invoke HeapFree,hGlobalHeap,0,@pNewStr
		jmp _ErrML 
	.endif
	mov @pTemp,eax
	popad
	mov edi,@pTemp
	invoke _memcpy
	mov edi,edx
	mov esi,@pNewStr
	mov ecx,@pNewLen
	rep movsb
	mov esi,@pTemp
	mov ecx,ebx
	invoke _memcpy
	invoke HeapFree,hGlobalHeap,0,@pNewStr
	invoke VirtualFree,@pTemp,0,MEM_RELEASE
	
	mov edi,_pFI
	assume edi:ptr _FileInfo
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
	assume edi:nothing
	
	mov eax,1
	ret
_ErrML:
	xor eax,eax
	ret
_ModifyLine endp

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
	.endif
_ExSL:
	ret
_SetLine endp

