.386
.model flat,stdcall
option casemap:none

include lios.inc

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

;判断文件头
Match proc _lpszName
	LOCAL @hFile,@buff[8]:byte
	invoke CreateFileW,_lpszName,GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,INVALID_HANDLE_VALUE
	je _ErrMatch
	mov @hFile,eax
	invoke ReadFile,@hFile,addr @buff,8,offset dwTemp,0
	cmp dword ptr [@buff+4],24h
	jne _NotMatch
	
	mov eax,MR_YES
	ret
_NotMatch:
	mov eax,MR_NO
	ret
_ErrMatch:
	mov eax,MR_ERR
	ret
Match endp

;
PreProc proc _lpPreData
	mov eax,_lpPreData
	mov ecx,[eax+_PreData.hGlobalHeap]
	mov hHeap,ecx
	ret
PreProc endp

;
GetText proc uses edi ebx esi _lpFI,_lpRI
	LOCAL @pStream,@pTIdx,@pSIdx,@dwTemp
	invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof(_GscInfo)
	or eax,eax
	je _NomemGT
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	mov [ebx].Reserved,eax
	mov esi,[ebx].lpStream
	mov @pStream,esi
	mov edi,eax
	mov ecx,sizeof _GscHeader
	invoke _memcpy
	mov edi,[ebx].Reserved
	assume edi:ptr _GscInfo
	mov esi,[ebx].nStreamSize
	sub esi,24h
	add @pStream,24h
	
	sub esi,[edi].sHeader.nControlStreamSize
	invoke _MakeFromStream,[edi].sHeader.nControlStreamSize,addr @pStream
	or eax,eax
	je _NomemGT
	mov [edi].lpControlStream,eax
	
	sub esi,[edi].sHeader.nIndexSize
	invoke _MakeFromStream,[edi].sHeader.nIndexSize,addr @pStream
	or eax,eax
	je _NomemGT
	mov [edi].lpIndex,eax
	
	sub esi,[edi].sHeader.nTextSize
	invoke _MakeFromStream,[edi].sHeader.nTextSize,addr @pStream
	or eax,eax
	je _NomemGT
	mov [edi].lpText,eax
	
	invoke _MakeFromStream,esi,addr @pStream
	or eax,eax
	je _NomemGT
	mov [edi].lpExtraData,eax
	
	invoke VirtualAlloc,0,[edi].sHeader.nControlStreamSize,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [edi].lpIndexCS,eax
	
	invoke _ProcControlStream,edi
	or eax,eax
	je _ErrScriptGT

	mov [ebx].nMemoryType,MT_EVERYSTRING
	
	mov eax,[edi].nTotalInst
	mov [ebx].nLine,eax
	shl eax,2
	mov esi,eax
	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [ebx].lpTextIndex,eax
	mov @pTIdx,eax

	invoke VirtualAlloc,0,esi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [ebx].lpStreamIndex,eax
	mov @pSIdx,eax
	assume ebx:nothing
	
	xor ebx,ebx
	.while ebx<[edi].nTotalInst
		mov edx,[edi].lpIndexCS
		mov esi,[edx+ebx*4]
		add esi,[edi].lpControlStream
		lodsw
		.if ax==51h
			add esi,14h
_i51GT:
			invoke _GetTextByIdx,[esi],edi
			lea ecx,@pTIdx
			invoke _AddString,eax,ecx
			or eax,eax
			je _Nomem2GT
			mov ecx,@pSIdx
			mov [ecx],ebx
			add @pSIdx,4
		.elseif ax==52h
			add esi,10h
			jmp _i51GT
		.elseif ax==0eh
			lodsw
			push ebx
			movzx ebx,ax
			mov @dwTemp,ebx
			invoke _GetTextByIdx,[esi],edi
			lea ecx,@pTIdx
			invoke _AddString,eax,ecx
			or eax,eax
			je _Nomem2GT
			add esi,18h
			.while ebx
				lodsd
				.break .if !eax
				invoke _GetTextByIdx,eax,edi
				lea ecx,@pTIdx
				invoke _AddString,eax,ecx
				or eax,eax
				je _Nomem2GT
				dec ebx
			.endw
			pop ebx
			push edi
			mov ecx,@dwTemp
			inc ecx
			mov edx,ecx
			mov edi,@pSIdx
			mov eax,ebx
			rep stosd
			shl edx,2
			add @pSIdx,edx
			pop edi
		.endif
		inc ebx
	.endw
	assume edi:nothing
	
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	mov eax,@pTIdx
	sub eax,[ebx].lpTextIndex
	shr eax,2
	mov [ebx].nLine,eax
	mov [ebx].nLineLen,MAX_STRINGLEN
	assume ebx:nothing
	
	mov eax,1
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_SUC_LINEONLY
	ret
_ErrScriptGT:
	invoke Release,_lpFI
	xor eax,eax
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_FAIL_CODE
	ret
_NomemGT:
	invoke Release,_lpFI
	xor eax,eax
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_FAIL_MEM
	ret
_Nomem2GT:
	invoke _ReleaseHeap,_lpFI
	jmp _NomemGT
GetText endp

;预读一遍脚本中的控制流，保证没有异常，指令地址记入IndexCS
_ProcControlStream proc uses esi edi ebx _lpGscInfo
	LOCAL @pIdx,@nCSSize
	mov edx,_lpGscInfo
	mov eax,[edx+_GscInfo.lpIndexCS]
	mov @pIdx,eax
	mov esi,[edx+_GscInfo.lpControlStream]
	mov eax,[edx+_GscInfo.sHeader.nControlStreamSize]
	mov @nCSSize,eax
	xor ebx,ebx
	xor edx,edx
	.while edx<@nCSSize
		mov ax,[esi+edx]
		add edx,2
		mov cx,ax
		and ax,0f000h
		.if !ZERO?
			shr ax,12
			and eax,0fh
			lea edi,dtParamSize1
			movsx eax,byte ptr [edi+eax]
			.if eax==-1
				inc eax
				ret
			.endif
			mov ecx,@pIdx
			mov [ecx],edx
			sub dword ptr [ecx],2
			add @pIdx,4
			add edx,eax
		.else
			lea edi,dtParamSize2
			movzx ecx,cl
			movsx eax,byte ptr [edi+ecx]
			.if eax==-1
				inc eax
				ret
			.endif
			push eax
			mov eax,@pIdx
			mov [eax],edx
			sub dword ptr [eax],2
			add @pIdx,4
			pop eax
			add edx,eax
			
;			.if (cl>=03 && cl<=05)
;				lea eax,[edx-4]
;				mov edi,sGscInfo.lpRelocTable
;				mov [edi+ebx],eax
;				add ebx,4
;				.continue
;			.elseif cl==0eh
;				lea eax,[edx-52]
;				mov edi,sGscInfo.lpRelocTable
;				mov ecx,5
;				@@:
;					mov [edi+ebx],eax
;					add eax,4
;					add ebx,4
;					.continue .if !dword ptr [esi+eax]
;				loop @B
;			.endif
		.endif
	.endw
	mov edx,_lpGscInfo
	mov ecx,[edx+_GscInfo.lpIndexCS]
	mov eax,@pIdx
	sub eax,ecx
	shr eax,2
	mov [edx+_GscInfo.nTotalInst],eax
	mov eax,1
	ret
_ProcControlStream endp

;
ModifyLine proc uses ebx edi esi _lpFI,_nLine
	mov eax,1
	ret
ModifyLine endp

;
SaveText proc uses edi ebx esi _lpFI
	ret
SaveText endp

Release proc uses esi edi ebx _lpFI
	mov eax,_lpFI
	mov edi,[eax+_FileInfo.Reserved]
	.if !edi
		ret
	.endif
	mov esi,edi
	add esi,_GscInfo.lpControlStream
	mov ebx,6
	.while ebx
		lodsd
		.if eax
			invoke VirtualFree,eax,0,MEM_RELEASE
		.endif
		dec ebx
	.endw
	invoke HeapFree,hHeap,0,edi
	mov eax,_lpFI
	mov dword ptr [eax+_FileInfo.Reserved],0
	mov eax,1
	ret
Release endp

;
SetLine proc _lpsz,_lpRange
	ret
SetLine endp

_MakeFromStream proc uses esi edi _nSize,_lppStream
	mov eax,_nSize
	shl eax,1
	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _ErrMFS
	push eax
	mov edi,eax
	mov edx,_lppStream
	mov esi,[edx]
	mov ecx,_nSize
	mov eax,ecx
	shr ecx,2
	REP MOVSd
	mov ecx,eax
	and ecx,3
	REP MOVSb
	mov [edx],esi
	pop eax
	ret
_ErrMFS:
	xor eax,eax
	ret
_MakeFromStream endp

_ReleaseHeap proc uses esi ebx _lpFI
	mov eax,_lpFI
	mov esi,[eax+_FileInfo.lpTextIndex]
	mov ebx,[eax+_FileInfo.nLine]
	.while ebx
		lodsd
		.break .if !eax
		invoke HeapFree,hHeap,0,eax
		dec ebx
	.endw
	ret
_ReleaseHeap endp

;
_GetTextByIdx proc _idx,_lpGscInfo
	mov edx,_lpGscInfo
	mov ecx,[edx+_GscInfo.lpIndex]
	mov eax,_idx
	mov eax,[ecx+eax*4]
	mov ecx,[edx+_GscInfo.lpText]
	add eax,ecx
	ret
_GetTextByIdx endp

_AddString proc _lpStr,_lppTIdx
	invoke lstrlenA,_lpStr
	.if eax<MAX_STRINGLEN
		mov eax,MAX_STRINGLEN
	.endif
	invoke HeapAlloc,hHeap,0,eax
	or eax,eax
	je _NomemAS
	mov ecx,_lppTIdx
	mov edx,[ecx]
	mov [edx],eax
	add dword ptr [ecx],4
	invoke lstrcpyA,eax,_lpStr
	mov eax,1
	ret
_NomemAS:
	xor eax,eax
	ret
_AddString endp

;
_memcpy proc
	mov eax,ecx
	shr ecx,2
	REP MOVSd
	mov ecx,eax
	and ecx,3
	REP MOVSb
	ret
_memcpy endp


end DllMain