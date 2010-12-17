.code

_MakeStringListFromStream proc uses edi esi ebx _lpFI
	local @nStringType,@nLine,@nCharSet
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov esi,[edi].lpStreamIndex
	xor ebx,ebx
	mov ecx,[edi].nStringType
	mov eax,[edi].nLine
	mov edx,[edi].nCharSet
	mov @nStringType,ecx
	mov @nCharSet,edx
	mov @nLine,eax	
	shl eax,2
	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
	.if !eax
		mov eax,E_NOMEM
		jmp _ExMSL
	.endif
	mov [edi].lpTextIndex,eax
	assume edi:nothing
	mov edi,eax
	.while ebx<@nLine
		lodsd
		push eax
		push edi
		push _lpFI
		call dbSimpFunc+_SimpFunc.GetStr
;		invoke _GetStringFromStmPtr,_lpFI,edi,eax
		or eax,eax
		jnz _ExMSL
		add edi,4
		inc ebx
	.endw
	xor eax,eax
_ExMSL:
	ret
_MakeStringListFromStream endp

_GetStringFromStmPtr proc uses esi edi _lpFI,_lppString,_lpBuff
	LOCAL @nStrLen,@bIsEnd
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov eax,[edi].nStringType
	MOV edx,[edi].nCharSet
	assume edi:nothing
	.if eax==ST_ENDWITHZERO
		.if edx==CS_UNICODE
			invoke lstrlenW,_lpBuff
			lea ecx,[eax+1]
		.else
			invoke lstrlenA,_lpBuff
			lea ecx,[eax+1]
		.endif
		mov esi,_lpBuff
	.elseif eax==ST_PASCAL2
		mov esi,_lpBuff
		lodsw
		movzx ecx,ax
		.if edx==CS_UNICODE
			SHL ecx,1
		.endif
	.elseif eax==ST_PASCAL4
		mov esi,_lpBuff
		lodsd
		mov ecx,eax
		.if edx==CS_UNICODE
			SHL ecx,1
		.endif
	.elseif eax==ST_TXTENDW
		xor ecx,ecx
		mov edi,_lpBuff
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
			mov eax,E_NOMEM
			jmp _ExGSFS
		.endif
		mov edx,_lppString
		mov [edx],eax
		mov ecx,@nStrLen
		shr ecx,1
		mov edi,eax
		mov esi,_lpBuff
		rep movsw
		mov word ptr [edi],0
		xor eax,eax
		jmp _ExGSFS
	.elseif eax==ST_TXTENDA
		.if edx==CS_UNICODE
			mov eax,E_INVALIDPARAMETER
			jmp _ExGSFS
		.endif
		mov edi,_lpBuff
		mov @bIsEnd,0
		xor ecx,ecx
		.while word ptr [edi]!=0a0dh
			.break .if !byte ptr [edi]
			inc edi
			inc ecx
		.endw
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
			jmp _ExGSFS
		.endif
		mov edx,_lppString
		push ecx
		mov [edx],eax
		push eax
		push @nStrLen
		push _lpBuff
		push 0
		mov ebx,_lpFI
		mov eax,[ebx+_FileInfo.nCharSet]
		push eax
		call MultiByteToWideChar
		.if !eax
			mov eax,E_NOTENOUGHBUFF
			jmp _ExGSFS
		.endif
		mov ecx,_lpBuff
		mov word ptr [ecx+eax*2],0
		xor eax,eax
		jmp _ExGSFS
	.else
		mov eax,E_INVALIDPARAMETER
		jmp _ExGSFS
	.endif
	assume edi:ptr _FileInfo
	mov @nStrLen,ecx
	.if edx==CS_UNICODE
;		mov eax,MAX_STRINGLEN
;		.if ecx>eax
;			mov eax,ecx
;		.endif
		shl ecx,1
		invoke HeapAlloc,hGlobalHeap,0,ecx
		.if !eax
			mov eax,E_NOMEM
			jmp _ExGSFS
		.endif
		mov ecx,_lppString
		mov [ecx],eax
		mov ecx,@nStrLen
		mov edi,eax
		rep movsw
	.else
		shl ecx,1
		push ebx
		mov ebx,ecx
		invoke HeapAlloc,hGlobalHeap,0,ecx
		.if !eax
			add esp,4
			mov eax,E_NOMEM
			jmp _ExGSFS
		.endif
		mov ecx,_lppString
		mov [ecx],eax
		invoke MultiByteToWideChar,[edi].nCharSet,0,esi,@nStrLen,eax,ebx
		pop ebx
		.if !eax
			mov ecx,_lppString
			invoke HeapFree,hGlobalHeap,0,[ecx]
			mov eax,E_NOTENOUGHBUFF
			jmp _ExGSFS
		.endif
	.endif
	assume edi:nothing
	xor eax,eax
_ExGSFS:
	ret
_GetStringFromStmPtr endp

_RecodeFile proc uses esi ebx edi _lpFI
	LOCAL @ret
	mov esi,_lpFI
	assume esi:ptr _FileInfo
	.if [esi].nMemoryType==MT_POINTERONLY
		mov ebx,[esi].lpTextIndex
		invoke _MakeStringListFromStream,_lpFI
		.if eax
			mov [esi].lpTextIndex,ebx
			jmp _ExRF
		.endif
		mov edi,ebx
		xor ebx,ebx
		.while ebx<[esi].nLine
			invoke HeapFree,hGlobalHeap,0,[edi+ebx*4]
			inc ebx
		.endw
		invoke VirtualFree,edi,0,MEM_RELEASE
	.else
		mov eax,dbSimpFunc+_SimpFunc.Release
		.if eax
			push esi
			call eax
		.endif
		.if [esi].nMemoryType==MT_EVERYSTRING
			mov edi,[esi].lpTextIndex
			xor ebx,ebx
			.while ebx<[esi].nLine
				invoke HeapFree,hGlobalHeap,0,[edi+ebx*4]
				inc ebx
			.endw
		.endif
		invoke VirtualFree,[esi].lpText,0,MEM_RELEASE
		invoke VirtualFree,[esi].lpTextIndex,0,MEM_RELEASE
		invoke VirtualFree,[esi].lpStreamIndex,0,MEM_RELEASE
		lea eax,@ret
		push eax
		push _lpFI
		call dword ptr [dbSimpFunc+_SimpFunc.GetText]
		.if eax
			mov eax,E_FATALERROR
			jmp _ExRF
		.endif
	.endif
	assume esi:nothing
	xor eax,eax
_ExRF:
	ret
_RecodeFile endp

;
_GetCodeIndex proc _code
	mov ecx,_code
	.if ecx==CS_GBK
		mov eax,1
	.elseif ecx==CS_SJIS
		mov eax,2
	.elseif ecx==CS_UNICODE
		mov eax,3
	.else
		xor eax,eax
	.endif
	ret
_GetCodeIndex endp

;
_AddCodeCombo proc _hCombo
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdDefault
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdGBK
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdSJIS
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdUnicode
	ret
_AddCodeCombo endp
