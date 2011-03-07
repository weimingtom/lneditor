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
	.elseif ecx==CS_UTF8
		mov eax,3
	.elseif ecx==CS_UNICODE
		mov eax,4
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
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdUTF8
	invoke SendMessageW,_hCombo,CB_ADDSTRING,0,offset szcdUnicode
	ret
_AddCodeCombo endp

;
_GetDispLine proc _nRealLine
	.if lpDisp2Real
_BeginGDL:
		mov eax,_nRealLine
		cmp eax,FileInfo1.nLine
		ja _ErrGDL
		mov ecx,lpMarkTable
		test byte ptr [ecx+eax],2
		jne _ErrGDL
		mov ecx,lpDisp2Real
		xor edx,edx
		.while edx<FileInfo1.nLine
			.if eax==dword ptr [ecx+edx*4]
				mov eax,edx
				ret
			.endif
			inc edx
		.endw
		jmp _ErrGDL
	.endif
	push esi
	push edi
	mov esi,lpMarkTable
	.if esi
		mov eax,FileInfo1.nLine
		shl eax,2
		invoke HeapAlloc,hGlobalHeap,0,eax
		or eax,eax
		je _ErrGDL
		mov lpDisp2Real,eax
		mov edi,eax
		or eax,-1
		mov ecx,FileInfo1.nLine
		rep stosb
		mov edi,lpDisp2Real
		xor eax,eax
		mov edx,FileInfo1.nLine
		.while eax<edx
			.if !(byte ptr [esi+eax]&2)
				stosd
			.endif
			inc eax
		.endw
	.else
		pop edi
		mov eax,_nRealLine
		pop esi
		ret
	.endif
	pop edi
	pop esi
	jmp _BeginGDL
	ret
_ErrGDL:
	or eax,-1
	ret
_GetDispLine endp

;
_GetRealLine proc _nDispLine
	.if lpDisp2Real
_BeginGRL:
		mov eax,_nDispLine
		mov ecx,lpDisp2Real
		mov eax,[ecx+eax*4]
		ret
	.endif
	push esi
	push edi
	mov esi,lpMarkTable
	.if esi
		mov eax,FileInfo1.nLine
		shl eax,2
		invoke HeapAlloc,hGlobalHeap,0,eax
		or eax,eax
		je _ErrGRL
		mov lpDisp2Real,eax
		mov edi,eax
		or eax,-1
		mov ecx,FileInfo1.nLine
		rep stosb
		mov edi,lpDisp2Real
		xor eax,eax
		mov edx,FileInfo1.nLine
		.while eax<edx
			.if !(byte ptr [esi+eax]&2)
				stosd
			.endif
			inc eax
		.endw
	.else
		pop edi
		mov eax,_nDispLine
		pop esi
		ret
	.endif
	pop edi
	pop esi
	jmp _BeginGRL
;	mov esi,lpMarkTable
;	mov eax,_nDispLine
;	.if esi
;		mov ebx,FileInfo1.nLine
;		xor ecx,ecx
;		xor edx,edx
;		.while ecx!=eax
;			.if !(byte ptr [esi+edx] & 2)
;				inc ecx
;			.endif
;			inc edx
;			.break .if edx>=ebx
;		.endw
;		mov eax,edx
;	.endif
;	ret
_ErrGRL:
	or eax,-1
	ret
_GetRealLine endp

;
_IsDisplay proc _nRealLine
	mov ecx,lpMarkTable
	.if ecx
		mov edx,_nRealLine
		xor eax,eax
		test byte ptr [ecx+edx],2
		sete al
		ret
	.else
		mov eax,1
		ret
	.endif
_IsDisplay endp

_MatchFilter proc uses esi edi ebx _lpStr,_lpFilter
	LOCAL @szStr[MAX_STRINGLEN]:byte
	mov esi,_lpFilter
	assume esi:ptr _TextFilter
	.if [esi].bInclude
		mov edi,[esi].lpszInclude
	assume esi:nothing
		.if word ptr [edi]
			mov eax,edi
			.repeat
				loop1:
				.while word ptr [edi]!='\'
					.if !word ptr [edi]
				loop2:
						invoke lstrcpyW,addr @szStr,eax
						jmp loop3
					.endif
					add edi,2
				.endw
				cmp word ptr [edi+2],0
				je loop2
				.if word ptr [edi+2]!='n'
					add edi,4
					jmp loop1
				.endif
				mov ecx,edi
				sub ecx,eax
				shr ecx,1
				mov esi,eax
				mov edx,edi
				lea edi,@szStr
				rep movsw
				mov word ptr [edi],0
				lea edi,[edx+4]
				loop3:
				invoke _WildcharMatchW,addr @szStr,_lpStr
				or eax,eax
				jne _NextMatch
			.until !word ptr [edi]
			jmp _NotMatch
		.endif
	.endif
_NextMatch:
	mov esi,_lpFilter
	assume esi:ptr _TextFilter
	.if [esi].bExclude
		mov edi,[esi].lpszExclude
	assume esi:nothing
		.if word ptr [edi]
			.repeat
				mov eax,edi
				loop4:
				.while word ptr [edi]!='\'
					.if !word ptr [edi]
				loop5:
						invoke lstrcpyW,addr @szStr,eax
						jmp loop6
					.endif
					add edi,2
				.endw
				cmp word ptr [edi+2],0
				je loop5
				.if word ptr [edi+2]!='n'
					add edi,4
					jmp loop4
				.endif
				mov ecx,edi
				sub ecx,eax
				shr ecx,1
				mov esi,eax
				mov edx,edi
				lea edi,@szStr
				rep movsw
				mov word ptr [edi],0
				lea edi,[edx+4]
				loop6:
				invoke _WildcharMatchW,addr @szStr,_lpStr
				or eax,eax
				jne _NotMatch
			.until !word ptr [edi]
		.endif
	.endif
	mov eax,1
	ret
_NotMatch:
	xor eax,eax
	ret
_MatchFilter endp

_UpdateHideTable proc uses esi ebx
	xor ebx,ebx
	mov esi,lpMarkTable
	.while ebx<FileInfo1.nLine
		invoke _GetStringInList,offset FileInfo1,ebx
		.if eax
			invoke _MatchFilter,eax,offset dbConf+_Configs.TxtFilter
			not al
			and al,1
			shl al,1
			or byte ptr [esi+ebx],al
		.endif
		inc ebx
	.endw
	ret
_UpdateHideTable endp

_ResetHideTable proc
	mov eax,lpMarkTable
	xor ecx,ecx
	.if eax
		.while ecx<FileInfo1.nLine
			and byte ptr [eax+ecx],not 2
			inc ecx
		.endw
	.endif
	.if lpDisp2Real
		invoke HeapFree,hGlobalHeap,0,lpDisp2Real
		mov lpDisp2Real,0
	.endif
	ret
_ResetHideTable endp
