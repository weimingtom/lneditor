.386
.model flat,stdcall
option casemap:none

include yuka.inc

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

;ÅÐ¶ÏÎÄ¼þÍ·
Match proc _lpszName
	LOCAL @hFile,@dwTemp
	LOCAL @buff[8]:byte
	invoke CreateFileW,_lpszName,GENERIC_READ,FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrMatch
	mov @hFile,eax
	invoke ReadFile,@hFile,addr @buff,8,addr @dwTemp,0
	or eax,eax
	je _ErrMatch
	invoke CloseHandle,@hFile
	lea eax,@buff
	.if dword ptr [eax]==30534b59h && word ptr [eax+6]<=1
		mov eax,MR_YES
		ret
	.endif
	mov eax,MR_NO
	ret
_ErrMatch:
	mov eax,MR_ERR
	ret
Match endp

;
PreProc proc _lpPreData
	mov ecx,_lpPreData
	assume ecx:ptr _PreData
	mov eax,[ecx].hGlobalHeap
	mov hGlobalHeap,eax
	assume ecx:nothing
	ret
PreProc endp

;
GetText proc uses edi ebx esi _lpFI,_lpRI
	LOCAL @ddn,@pEnd,@bInLeft,@bFirstCreate
	LOCAL @pStreamList,@pTextList,@pStrInList
	LOCAL @nLine
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,24
	or eax,eax
	je _NoMemGT
	mov [edi].Reserved,eax
	mov ebx,eax
	mov esi,[edi].lpStream
	mov eax,[esi+14h]
	shl eax,2
	mov [ebx+4],eax
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	or eax,eax
	je _GotorelGT
	mov [ebx],eax
	
	mov eax,[esi+1ch]
	shl eax,4
	mov [ebx+0ch],eax
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	.if !eax
_GotorelGT:
		invoke Release,_lpFI
		jmp _NoMemGT
	.endif
	mov [ebx+8],eax
	
	mov eax,[esi+24h]
	mov [ebx+14h],eax
	.if ![edi].bReadOnly
		shl eax,1
		mov @bInLeft,0
	.else
		mov @bInLeft,1
	.endif
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	or eax,eax
	je _GotorelGT
	mov [ebx+10h],eax
	
	invoke VirtualAlloc,0,[ebx+4],MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _GotorelGT
	mov [edi].lpStreamIndex,eax
	mov @pStreamList,eax
	invoke VirtualAlloc,0,[ebx+4],MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _GotorelGT
	mov [edi].lpTextIndex,eax
	mov @pTextList,eax
	invoke VirtualAlloc,0,[ebx+14h],MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _GotorelGT
	mov [edi].lpText,eax
	mov @pStrInList,eax

	mov @ddn,0
	mov edx,edi
	.while @ddn<3
		mov edi,edx
		mov esi,[edi].lpStream
		mov eax,@ddn
		add esi,dword ptr [esi+eax*8+10h]
		mov edi,[ebx+eax*8]
		mov ecx,[ebx+eax*8+4]
		invoke _memcpy		
		inc @ddn
	.endw
	mov edi,edx
	
	xor eax,eax
	mov ax,[edi].bFirstCreate
	mov @bFirstCreate,eax
	
	invoke _IsEncode,ebx
	.if eax
		invoke _Encode,[ebx+10h],[ebx+14h]
		mov [edi].Reserved[4],1
	.else
		mov [edi].Reserved[4],0
	.endif
	
	assume edi:nothing
	
	
	mov @nLine,0
	mov esi,[ebx]
	mov eax,esi
	add eax,dword ptr [ebx+4]
	mov @pEnd,eax
	.while esi<@pEnd
		lodsd
		mov ecx,eax
		lodsd
		shl ecx,4
		mov edi,[ebx+8]
		add edi,ecx
		.if dword ptr [edi]
			sub esi,4
			.continue
		.endif
		.if eax>=10h
			int 3
		.endif
		mov ecx,[edi+4]
		mov edi,[ebx+10h]
		add edi,ecx
		push eax
		invoke _CmpStrOut,edi
		.if eax==-1
			pop eax
			lea esi,[esi+eax*4]
			.continue
		.elseif !eax
			int 3
		.elseif eax==2
			add esi,4
		.endif
		pop eax
_GetStringGT:
		mov edi,[ebx+8]
		lodsd
		shl eax,4
		add edi,eax
		.if dword ptr [edi]!=5
			int 3
		.endif
		mov eax,@pStreamList
		mov [eax],edi
		add @pStreamList,4
		mov ecx,[edi+8]
		mov edi,[ebx+10h]
		add edi,ecx
		mov eax,@pTextList
		mov ecx,@pStrInList
		mov [eax],ecx
		add @pTextList,4
;		invoke MultiByteToWideChar,932,MB_PRECOMPOSED,edi,-1,@pStrInList,10000
		push 10000
		push @pStrInList
		push -1
		push edi
		push MB_PRECOMPOSED
		.if @bInLeft || @bFirstCreate
			push 932
		.elseif
			push 936
		.endif
		call MultiByteToWideChar
		.if !eax
			mov eax,@pStrInList
			mov word ptr [eax],0
			add @pStrInList,2
			inc @nLine
			.continue
		.endif
		shl eax,1
		add @pStrInList,eax
		inc @nLine
	.endw
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov eax,@nLine
	mov [edi].nLine,eax
	.if !@bInLeft && @bFirstCreate
		xor ebx,ebx
		.while ebx<[edi].nLine
			invoke ModifyLine,edi,ebx
			inc ebx
		.endw
		invoke SaveText,edi
	.endif
	mov [edi].nMemoryType,MT_VARIABLESTRING
	assume edi:nothing
	mov eax,_lpRI
	mov dword ptr [eax],RI_SUC_LINEONLY
	mov eax,1
	ret
_NoMemGT:
	mov eax,_lpRI
	mov dword ptr [eax],RI_FAIL_MEM
	xor eax,eax
	ret
GetText endp

;
ModifyLine proc uses ebx edi esi _lpFI,_nLine
	LOCAL @pStr,@pToNewStr,@nNewLen,@bNeedExpand
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov ebx,[edi].Reserved
	or ebx,ebx
	je _ErrML
	mov eax,[edi].lpTextIndex
	mov ecx,_nLine
	mov eax,[eax+ecx*4]
	mov @pStr,eax
	mov eax,[edi].lpStreamIndex
	mov esi,[eax+ecx*4]
	cmp dword ptr [esi],5
	jne _ErrML
	mov eax,[ebx+10h]
	add eax,dword ptr [ebx+14h]
	mov @pToNewStr,eax
	invoke WideCharToMultiByte,936,0,@pStr,-1,eax,0,0,0
	mov @nNewLen,eax
	mov eax,[esi+8]
	add eax,dword ptr [ebx+10h]
	invoke lstrlen,eax
	inc eax
	.if eax<@nNewLen
		mov ecx,[edi].lpStream
		mov ecx,[ecx+24h]
		shl ecx,1
		sub ecx,dword ptr [ebx+14h]
		mov @bNeedExpand,TRUE
	.else
		mov ecx,[esi+8]
		add ecx,dword ptr [ebx+10h]
		mov @pToNewStr,ecx
		mov ecx,eax
		mov @bNeedExpand,FALSE
	.endif
	invoke WideCharToMultiByte,936,0,@pStr,-1,@pToNewStr,ecx,0,0
	or eax,eax
	je _ErrML
	.if @bNeedExpand
		add [ebx+14h],eax
		add [edi].nStreamSize,eax
		mov ecx,@pToNewStr
		sub ecx,[ebx+10h]
		mov [esi+8],ecx
	.endif
	assume edi:nothing
	mov eax,1
	ret
_ErrML:
	xor eax,eax
	ret
ModifyLine endp

;
SaveText proc uses edi ebx esi _lpFI
	LOCAL @dbHdr[30h]:byte,@dwTemp
	mov edi,_lpFI
	assume edi:ptr _FileInfo
	mov esi,[edi].lpStream
	mov edx,edi
	lea edi,@dbHdr
	mov ecx,30h
	invoke _memcpy
	mov edi,edx
	mov ebx,[edi].Reserved
	mov ecx,[ebx+14h]
	mov dword ptr [@dbHdr+24h],ecx
	invoke SetFilePointer,[edi].hFile,0,0,FILE_BEGIN
	invoke WriteFile,[edi].hFile,addr @dbHdr,30h,addr @dwTemp,0
	mov esi,eax
	invoke WriteFile,[edi].hFile,[ebx],[ebx+4],addr @dwTemp,0
	and esi,eax
	invoke WriteFile,[edi].hFile,[ebx+8],[ebx+0ch],addr @dwTemp,0
	and esi,eax
	invoke WriteFile,[edi].hFile,[ebx+10h],[ebx+14h],addr @dwTemp,0
	and eax,esi
	je _ErrST
	invoke SetEndOfFile,[edi].hFile
	assume edi:nothing
	mov eax,1
	ret
_ErrST:
	xor eax,eax
	ret
SaveText endp

SetLine proc _para1,_para2
	invoke _SetLine,_para1,_para2
	ret
SetLine endp

;
Release proc uses ebx _lpFI
	mov eax,_lpFI
	assume eax:ptr _FileInfo
	mov ebx,[eax].Reserved
	mov [eax].Reserved,0
	assume eax:nothing
	.if ebx
		mov ecx,3
		@@:
		mov eax,[ebx]
		.if eax
			push ecx
			invoke HeapFree,hGlobalHeap,0,eax
			pop ecx
		.endif
		add ebx,8
		loop @B
		invoke HeapFree,hGlobalHeap,0,ebx 
	.endif
	ret
Release endp

_memcpy proc
	mov eax,ecx
	shr ecx,2
	REP MOVSd
	mov ecx,eax
	and ecx,3
	REP MOVSb
	ret
_memcpy endp

_IsEncode proc uses esi ebx _pTB
	mov ebx,_pTB
	mov esi,[ebx+8h]
	mov ecx,[ebx+0ch]
	@@:
	.if !dword ptr [esi]
		mov ecx,[esi+4]
		add ecx,[ebx+10h]
		xor eax,eax
		mov al,[ecx]
		shr al,7
		ret
	.endif
	add esi,10h
	loop @B
	xor eax,eax
	ret
_IsEncode endp

_Encode proc uses edi _lpBuf,_nSize
	mov edi,_lpBuf
	mov ecx,_nSize
	@@:
	xor byte ptr [edi],0aah
	inc edi
	loop @B
	ret
_Encode endp

_CmpStrOut proc uses esi edi _lpsz
	
	invoke lstrcmp,_lpsz,offset szStrOut
	.if !eax
		mov eax,1
		ret
	.endif
	invoke lstrcmp,_lpsz,offset szStrOutNWC
	.if !eax
		mov eax,2
		ret
	.endif
	mov edi,_lpsz
	mov esi,offset szStrOut
	mov ecx,7
	repe cmpsb
	.if ecx
		or eax,-1
		ret
	.endif
	mov eax,ecx
	ret
_CmpStrOut endp


end DllMain