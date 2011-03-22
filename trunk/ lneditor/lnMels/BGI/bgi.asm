.386
.model flat,stdcall
option casemap:none

include bgi.inc

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

;�ж��ļ�ͷ
Match proc uses esi edi _lpszName
	LOCAL @szMagic[1ch]
	invoke CreateFileW,_lpszName,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrMatch
	push eax
	lea esi,@szMagic
	invoke ReadFile,eax,esi,1ch,offset dwTemp,0
	call CloseHandle
	lea edi,szMagic
	mov ecx,1ch
	repe cmpsb
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
GetText proc uses edi ebx esi _lpFI,_lpRI
	LOCAL @nHdrSize
	LOCAL @pSI,@pRI
	LOCAL @pCSEnd
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	mov esi,[ebx].lpStream
	mov ecx,[esi+1ch]
	add ecx,1ch
	mov @nHdrSize,ecx
	add esi,ecx
	mov edx,[ebx].nStreamSize
	sub edx,ecx
	lea edx,[esi+edx-4]
	xor ecx,ecx
	.while esi<edx
		lodsd
		.if eax==3
			inc ecx
			mov @pCSEnd,esi
		.endif
	.endw
	lea edi,[ecx*4+4]
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	mov @pSI,eax
	je _NomemGT
	mov [ebx].lpStreamIndex,eax
	invoke VirtualAlloc,0,edi,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	mov @pRI,eax
	je _NomemGT
	mov [ebx].Reserved,eax
	
	mov [ebx].nMemoryType,MT_POINTERONLY
	mov [ebx].nStringType,ST_ENDWITHZERO
	.if [ebx].bReadOnly && ![ebx].nCharSet
		mov [ebx].nCharSet,CS_SJIS
	.endif
	
	mov esi,[ebx].lpStream
	add esi,@nHdrSize
;	mov edx,[ebx].nStreamSize
;	lea edx,[esi+edx-4]
	xor ecx,ecx
	.while esi<@pCSEnd
		lodsd
		.if eax==3
			mov edi,@pRI
			mov [edi],esi
			
			mov edi,@pSI
			lodsd
			add eax,@nHdrSize
			add eax,[ebx].lpStream
			.continue .if eax<@pCSEnd || byte ptr [eax]<81h 
			stosd
			add @pSI,4
			add @pRI,4
			inc ecx
;			.if eax<edx
;				mov edx,eax
;			.endif
		.endif
	.endw
	mov [ebx].nLine,ecx
	assume ebx:nothing
	mov ecx,_lpRI
	xor eax,eax
	mov dword ptr [ecx],RI_SUC_LINEONLY
	ret
	
_NomemGT:
	invoke Release,_lpFI
	or eax,E_ERROR
	mov ecx,_lpRI
	mov dword ptr [ecx],RI_FAIL_MEM
	ret
GetText endp

;Ԥ��һ��ű��еĿ���������֤û���쳣��ָ���ַ����IndexCS



;
ModifyLine proc uses ebx edi esi _lpFI,_nLine
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	mov ecx,[ebx].lpTextIndex
	mov eax,_nLine
	.if eax>[ebx].nLine
		mov eax,E_INVALIDPARAMETER
		jmp _ExML
	.endif
	mov edi,[ecx+eax*4]
	mov ecx,[ebx].lpStreamIndex
	mov esi,[ecx+eax*4]
	invoke lstrlenA,esi
	inc eax
	invoke WideCharToMultiByte,[ebx].nCharSet,0,edi,-1,esi,eax,0,0
	.if !eax
		invoke GetLastError
		.if eax!=ERROR_INSUFFICIENT_BUFFER
			@@:
			mov eax,E_CODEFAILED
			JMP _ExML
		.endif
		mov esi,[ebx].lpStream
		add esi,[ebx].nStreamSize
		invoke WideCharToMultiByte,[ebx].nCharSet,0,edi,-1,esi,1000,0,0
		.if !eax
			mov eax,E_CODEFAILED
			jmp _ExML
		.endif
		add [ebx].nStreamSize,eax
		mov ecx,[ebx].lpStream
		mov eax,[ecx+1ch]
		lea eax,[eax+ecx+1ch]
		sub esi,eax
		mov edx,[ebx].Reserved
		mov ecx,_nLine
		mov ecx,[edx+ecx*4]
		mov [ecx],esi
	.endif
	assume ebx:nothing
	xor eax,eax
_ExML:
	ret
ModifyLine endp

;
SaveText proc uses edi ebx esi _lpFI
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	.if [ebx].bReadOnly
		mov eax,E_ERROR
		jmp _ExST
	.endif
	invoke SetFilePointer,[ebx].hFile,0,0,FILE_BEGIN
	invoke WriteFile,[ebx].hFile,[ebx].lpStream,[ebx].nStreamSize,offset dwTemp,0
	invoke SetEndOfFile,[ebx].hFile
	xor eax,eax
_ExST:
	ret
SaveText endp

SetLine proc _lpsz,_lpRange
	cmp _lpRange,0
	je _ExSL
	mov eax,_lpsz
	.if dword ptr [eax]==67005eh
		mov ecx,_lpRange
		mov dword ptr [ecx],5
		mov dword ptr [ecx+4],-1
	.endif
	invoke _SetLine,_lpsz,_lpRange
_ExSL:
	ret
SetLine endp

Release proc uses esi edi ebx _lpFI
	mov ecx,_lpFI
	mov eax,_FileInfo.Reserved[ecx]
	.if eax
		invoke VirtualFree,eax,0,MEM_RELEASE
	.endif
	mov eax,1
	ret
Release endp

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