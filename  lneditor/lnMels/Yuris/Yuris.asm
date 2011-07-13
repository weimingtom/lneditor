.386
.model flat,stdcall
option casemap:none

include Yuris.inc

.code

assume fs:nothing
;
DllMain proc _hInstance,_dwReason,_dwReserved
	.if _dwReason==DLL_PROCESS_ATTACH
		push _hInstance
		pop hInstance
	.ENDIF
	mov eax,TRUE
	ret
DllMain endp

;
InitInfo proc _lpMelInfo2
	mov ecx,_lpMelInfo2
	mov _MelInfo2.nInterfaceVer[ecx],00020000h
	mov _MelInfo2.nCharacteristic[ecx],0
	ret
InitInfo endp

;
PreProc proc _lpPreData
	mov ecx,_lpPreData
	assume ecx:ptr _PreData
	mov eax,[ecx].hGlobalHeap
	mov hHeap,eax
	assume ecx:nothing
	ret
PreProc endp

;ÅÐ¶ÏÎÄ¼þÍ·
Match proc uses esi _lpszName
	LOCAL @szMagic[5]:dword
	LOCAL @sExtend[2]:dword
	invoke lstrlenW,_lpszName
	mov ecx,_lpszName
	lea ecx,[ecx+eax*2-8]
	lea edx,@sExtend
	mov eax,[ecx]
	mov [edx],eax
	mov eax,[ecx+4]
	mov [edx+4],eax
	and dword ptr [edx],0ffdfffffh
	and dword ptr [edx+4],0ffdfffdfh
	.if dword ptr [edx]==59002eh && dword ptr [edx+4]==04E0042h
		invoke CreateFileW,_lpszName,GENERIC_READ,FILE_SHARE_READ OR FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		cmp eax,-1
		je _ErrMatch
		push eax
		lea esi,@szMagic
		invoke ReadFile,eax,esi,8,offset dwTemp,0
		call CloseHandle
		cmp dword ptr [esi],'BTSY'
		jne _NotMatch
		cmp dword ptr [esi+4],1c2h
		je _Match
		mov eax,MR_MAYBE
		ret
		_Match:
		mov eax,MR_YES
		ret
	.endif
_NotMatch:
	mov eax,MR_NO
	ret
_ErrMatch:
	mov eax,MR_ERR
	ret
Match endp

;
YurisGetLine proc _lpStr,_nLen,_nCS
	LOCAL @pStr
	
	mov ecx,_nLen
	inc eax
	shl ecx,1
	invoke HeapAlloc,hHeap,0,ecx
	or eax,eax
	je _Ex
	push eax
	
	mov ecx,_nLen
	inc ecx
;	.if _bTrimQuote
;		mov edx,_lpStr
;		.if byte ptr [edx]=='"' || byte ptr [edx]=="'"
;			inc _lpStr
;			dec _nLen
;		.endif
;		add edx,_nLen
;		.if byte ptr [edx]=='"' || byte ptr [edx]=="'"
;			dec _nLen
;		.endif
;	.endif
	invoke MultiByteToWideChar,_nCS,0,_lpStr,_nLen,eax,ecx
	mov ecx,eax
	pop eax
	mov word ptr [eax+ecx*2],0
_Ex:
	ret
YurisGetLine endp

;
GetText proc uses esi ebx edi _lpFI,_lpRI
	LOCAL @nTemp
	LOCAL @pCode,@pArg,@lpRes
	LOCAL @nInst
	LOCAL @nLine
	LOCAL @hdr:YurisHdr
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov esi,[edi].lpStream
	lea edi,@hdr
	mov ecx,sizeof YurisHdr/4
	rep movsd
	mov edi,_lpFI
	
	mov eax,@hdr.nArgSize
	shr eax,1
	mov ebx,eax
	invoke VirtualAlloc,0,ebx,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _Nomem
	mov [edi].lpStreamIndex,eax
	invoke VirtualAlloc,0,ebx,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _Nomem
	mov [edi].lpTextIndex,eax
	
	mov @pCode,esi
	mov eax,esi
	add eax,@hdr.nCodeSize
	mov @pArg,eax
	add eax,@hdr.nArgSize
	mov @lpRes,eax
	
	xor ebx,ebx
	mov @nLine,ebx
	.while ebx<@hdr.nCount
		lodsd
		.if ax==015bh
			mov edx,@pArg
			assume edx:ptr YurisArg
			cmp [edx].len1,0
			je _Ctn
			mov eax,[edx].offset1
			add eax,@lpRes
			.if [edx].type1!=0
				int 3
			.endif
			invoke YurisGetLine,eax,[edx].len1,[edi].nCharSet
			or eax,eax
			je _Nomem
			assume edx:nothing
			mov ecx,@nLine
			mov edx,[edi].lpTextIndex
			mov [edx+ecx*4],eax
			mov edx,[edi].lpStreamIndex
			mov eax,@pArg
			mov [edx+ecx*4],eax
			inc @nLine
			add @pArg,12
		.elseif al==1dh && ah!=0
			mov edx,@pArg
			mov ecx,YurisArg.offset1[edx]
			add ecx,@lpRes
			push esi
			push edi
			mov esi,ecx
			lea edi,dbSel
			mov ecx,15
			repe cmpsb
			pop edi
			pop esi
			jne _Default
			.if ah!=11
				int 3
			.endif
			mov @nTemp,10
			add @pArg,12
			.repeat
				assume edx:ptr YurisArg
				mov edx,@pArg
				cmp [edx].len1,0
				je _Ctn2
				mov eax,[edx].offset1
				add eax,@lpRes
				.if [edx].type1==3
					movzx ecx,word ptr [eax+1]
					or ecx,ecx
					je _Ctn2
					.if byte ptr [eax]!=4dh
						int 3
					.endif
					add eax,3
					cmp word ptr [eax],"''"
					je _Ctn2
					invoke YurisGetLine,eax,ecx,[edi].nCharSet
				.else
					int 3
				.endif
				or eax,eax
				je _Nomem
				assume edx:nothing
				mov ecx,@nLine
				mov edx,[edi].lpTextIndex
				mov [edx+ecx*4],eax
				mov edx,[edi].lpStreamIndex
				mov eax,@pArg
				mov [edx+ecx*4],eax
				inc @nLine
			_Ctn2:
				dec @nTemp
				add @pArg,12
			.until @nTemp==0
		.else
	_Default:
			movzx eax,ah
			shl eax,2
			lea ecx,[eax+eax*2]
			add @pArg,ecx
		.endif
	_Ctn:
		inc ebx
	.endw
	mov eax,@nLine
	mov [edi].nLine,eax
	mov [edi].nMemoryType,MT_EVERYSTRING
	
	assume edi:nothing
	mov ecx,_lpRI
	xor eax,eax
	mov dword ptr [ecx],RI_SUC_LINEONLY
_Ex:
	ret
_Nomem:
	mov eax,E_NOMEM
	ret
GetText endp

;
YurisSetLine proc uses esi edi _lpStr,_nType,_nCS
	LOCAL @nChar,@pStr2,@pStr
	invoke lstrlenW,_lpStr
	mov @nChar,eax
	cmp eax,0ffffh/2
	ja _Err
	.if _nType==3
		add eax,2
	.elseif _nType!=0
		jmp _Err
	.endif
	inc eax
	shl eax,1
	invoke HeapAlloc,hHeap,0,eax
	or eax,eax
	je _Err
	mov @pStr,eax
	.if _nType==3
		mov byte ptr [eax],4dh
		add eax,3
	.endif
	mov ecx,@nChar
	inc ecx
	shl ecx,1
	invoke WideCharToMultiByte,_nCS,0,_lpStr,-1,eax,ecx,0,0
	.if !eax
		int 3
	.endif
	lea ecx,[eax-1]
	.if _nType==3
		mov edx,@pStr
		mov word ptr [edx+1],cx
		add ecx,3
	.endif
	mov eax,@pStr
	ret
_Err:
	xor eax,eax
	ret
YurisSetLine endp

YurisCheckLine proc _lpBuff
	mov edx,_lpBuff
	movzx eax,word ptr [edx+1]
	mov cl,[edx+3]
	.if cl!='"' && cl!="'"
		xor eax,eax
		ret
	.endif
	lea edx,[edx+eax+2]
	mov cl,[edx]
	.if cl!='"' && cl!="'"
		xor eax,eax
		ret
	.endif
	mov eax,1
	ret
YurisCheckLine endp

;
ModifyLine proc uses ebx edi esi _lpFI,_nLine
	LOCAL @pNewStr,@nNewLen,@nOldLen
	LOCAL @hdr:YurisHdr
	LOCAL @lpRes
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov esi,[edi].lpStream
	lea edi,@hdr
	mov ecx,sizeof YurisHdr/4
	rep movsd
	mov edi,_lpFI
	add esi,@hdr.nCodeSize
	add esi,@hdr.nArgSize
	mov @lpRes,esi
	
	mov ecx,[edi].lpStreamIndex
	mov eax,_nLine
	mov esi,[ecx+eax*4]
	assume esi:ptr YurisArg
	
	invoke _GetStringInList,edi,_nLine
	mov ebx,eax
	movzx eax,[esi].type1
	invoke YurisSetLine,ebx,eax,[edi].nCharSet
	.if !eax
		mov eax,E_NOMEM
		jmp _Ex
	.endif
	mov @pNewStr,eax
	mov @nNewLen,ecx
	.if [esi].type1==3
		invoke YurisCheckLine,@pNewStr
		.if !eax
			mov eax,E_LINEDENIED
			jmp _Ex
		.endif
	.endif
	
	mov eax,[esi].len1
	.if eax>=@nNewLen
		mov edi,[esi].offset1
		add edi,@lpRes
		mov ecx,@nNewLen
		mov [esi].len1,ecx
		mov esi,@pNewStr
		rep movsb
	.else
;		mov ecx,[edi].nStreamSize
;		add ecx,[edi].lpStream
		mov eax,@lpRes
		add eax,@hdr.nResSize
;		sub ecx,eax
		invoke _ReplaceInMem,@pNewStr,@nNewLen,eax,0,@hdr.nOffSize
		.if eax
			mov ebx,eax
			invoke HeapFree,hHeap,0,@pNewStr
			mov eax,ebx
			jmp _Ex
		.endif
		
		mov eax,@nNewLen
		mov [esi].len1,eax
		mov ecx,@hdr.nResSize
		mov [esi].offset1,ecx
		
		add [edi].nStreamSize,eax
		mov ebx,[edi].lpStream
		assume ebx:ptr YurisHdr
		add [ebx].nResSize,eax
		assume ebx:nothing
		
	.endif
	
	assume edi:nothing
_Success:
	invoke HeapFree,hHeap,0,@pNewStr
	xor eax,eax
_Ex:
	ret
ModifyLine endp

;
SaveText proc
	jmp _SaveText
SaveText endp

;
SetLine proc
	jmp _SetLine
SetLine endp

end DllMain