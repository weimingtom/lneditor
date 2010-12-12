.386
.model flat,stdcall
option casemap:none

include majiro.inc
include mjdec.asm

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
Match proc uses esi edi _lpszName
	LOCAL @szMagic[10h]:byte
	invoke CreateFileW,_lpszName,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrMatch
	push eax
	lea ecx,@szMagic
	invoke ReadFile,eax,ecx,10h,offset dwTemp,0
	call CloseHandle
	lea esi,@szMagic
	mov edi,$CTA0("MajiroObjX1.000")
	mov ecx,10h
	repe cmpsb
	.if ZERO?
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
	mov hHeap,eax
	assume ecx:nothing
	invoke HeapAlloc,hHeap,0,256*4
	mov lpTable1,eax
	.if eax
		invoke _InitHashTable
	.endif
	ret
PreProc endp

;
GetText proc uses edi ebx esi _lpFI,_lpRI
	LOCAL @pEnd,@nLine
	LOCAL @pCurJumpTable
	LOCAL @pLastString
	LOCAL @nTemp
	.if !lpTable1
		invoke HeapAlloc,hHeap,0,1024
		or eax,eax
		je _NomemGT
		invoke _InitHashTable
	.endif
	mov ebx,_lpFI
	assume ebx:ptr _FileInfo
	invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof _MjoInfo
	or eax,eax
	je _NomemGT
	mov [ebx].Reserved,eax
	mov edi,eax
	mov esi,[ebx].lpStream
	assume edi:ptr _MjoInfo
	add esi,10h
	lodsd
	mov [edi].nDefaultEntry,eax
	lodsd
	mov [edi].unk1,eax
	lodsd
	mov [edi].nEntryCount,eax
	shl eax,3
	invoke HeapAlloc,hHeap,0,eax
	or eax,eax
	je _NomemGT
	mov [edi].lpEntries,eax
	mov ecx,[edi].nEntryCount
	shl ecx,3
	invoke _memcpy2,eax,esi,ecx
	mov esi,eax
	lodsd
	mov ecx,eax
	mov [edi].nDataSize,eax
	invoke HeapAlloc,hHeap,0,ecx
	or eax,eax
	je _NomemGT
	mov [edi].lpData,eax
	invoke _memcpy2,eax,esi,[edi].nDataSize
	invoke HeapAlloc,hHeap,0,[edi].nDataSize
	or eax,eax
	je _NomemGT
	mov [edi].lpJumpTable,eax
	
	;生成跳转表并计算行数
	mov edx,[edi].lpJumpTable
	mov esi,[edi].lpData
	mov ecx,esi
	add ecx,[edi].nDataSize
	mov @pEnd,ecx
	mov @pLastString,esi
	mov @nLine,0
	push edi
	assume edi:nothing
	mov edi,edx
	.while esi<@pEnd
		lodsw
		.continue .if ax<=1a9h
		.if ax<=320h
			add esi,8
			.continue
		.elseif ax>=800h && ax<=847h
			xor ecx,ecx
			mov cx,ax
;			sub ecx,800h
			xor eax,eax
			mov al,byte ptr [ecx+(Offset OpTable-800h)]
			test eax,eax
			jl _SpecialGT
				add esi,eax
				.continue
			_SpecialGT:
				.if eax==-1
					lodsw
					add esi,eax
					.continue
				.elseif eax==-2
					lodsw
					add esi,eax
					mov @pLastString,esi
					inc @nLine
					.continue
				.elseif eax==-3
					pop edi
					jmp _OpErrGT
				.elseif eax==-4
					lodsd
					test eax,eax
					jl _Back
						stosd
						.continue
					_Back:
						lea ecx,[esi+eax]
						.if ecx<@pLastString
							stosd
						.endif
						.continue
				.endif
		.elseif ax==850h
			lodsw
			movzx ecx,ax
			rep movsd
		.else
			pop edi
			jmp _OpErrGT
		.endif
	.endw
	pop edi
	
	;分配FileInfo中的内存
	mov eax,@nLine
	mov [ebx].nLine,eax
;	shl eax,2
;	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
;	or eax,eax
;	je _NomemGT
;	mov [ebx].lpTextIndex,eax
;	mov ecx,[ebx].nLine
	shl eax,2
	invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
	or eax,eax
	je _NomemGT
	mov [ebx].lpStreamIndex,eax
	
	;开始处理字节码
	assume edi:ptr _MjoInfo
	mov [ebx].nMemoryType,MT_POINTERONLY
	mov [ebx].nStringType,ST_PASCAL2
	.if [ebx].bReadOnly && ![ebx].nCharSet
		mov [ebx].nCharSet,CS_SJIS
	.endif
	.if [ebx].nCharSet==CS_UNICODE
		invoke Release,_lpFI
		mov ecx,_lpRI
		xor eax,eax
		mov dword ptr [ecx],RI_FAIL_ERRORCS
		ret
	.endif
	mov esi,[edi].lpData
	mov @nLine,0
	.while esi<@pEnd
		lodsw
		.continue .if ax<=1a9h
		.if ax<=320h
			add esi,8
			.continue
		.elseif ax>=800h && ax<=847h
			xor ecx,ecx
			mov cx,ax
;			sub ecx,800h
			xor eax,eax
			mov al,byte ptr [ecx+(Offset OpTable-800h)]
			test eax,eax
			jl _SpecialGT2
				add esi,eax
				.continue
			_SpecialGT2:
				.if eax==-1
					lodsw
					add esi,eax
					.continue
				.elseif eax==-2
					lodsw
					movzx ecx,ax
					mov eax,@nLine
					mov edx,[ebx].lpStreamIndex
					mov [edx+eax*4],esi
					sub dword ptr [edx+eax*4],2
					inc @nLine
					add esi,ecx
					.continue
				.elseif eax==-3
					jmp _OpErrGT
				.elseif eax==-4
					add esi,4
					.continue
				.endif
		.elseif ax==850h
			lodsw
			movzx ecx,ax
			shl ecx,2
			add esi,ecx
			.continue
		.else
			jmp _OpErrGT
		.endif
	.endw
	assume edi:nothing
	assume ebx:nothing
	mov ecx,_lpRI
	mov eax,1
	mov dword ptr [ecx],RI_SUC_LINEONLY
	ret
_OpErrGT:
	invoke Release,_lpFI
	mov ecx,_lpRI
	xor eax,eax
	mov dword ptr [ecx],RI_FAIL_FORMAT
	ret
_NomemGT:
	invoke Release,_lpFI
	mov ecx,_lpRI
	xor eax,eax
	mov dword ptr [ecx],RI_FAIL_MEM
	ret
GetText endp

;
ModifyLine proc uses ebx edi esi _lpFI,_nLine
	ret
ModifyLine endp

;
SaveText proc uses edi ebx esi _lpFI
	ret
SaveText endp

Release proc uses ebx _lpFI
	mov eax,_lpFI
	mov ebx,dword ptr [eax+_FileInfo.Reserved]
	assume ebx:ptr _MjoInfo
	.if ebx
		mov eax,[ebx].lpEntries
		.if eax
			invoke HeapFree,hHeap,0,eax
		.endif
		mov ecx,[ebx].lpData
		.if ecx
			invoke HeapFree,hHeap,0,ecx
		.endif
		mov eax,[ebx].lpJumpTable
		.if eax
			invoke HeapFree,hHeap,0,eax
		.endif
		invoke HeapFree,hHeap,0,ebx
		mov dword ptr [eax+_FileInfo.Reserved],0
	.endif
	assume ebx:nothing
	ret
Release endp

;
SetLine proc _lpsz,_lpRange
	ret
SetLine endp

_memcpy2 proc _dest,_src,_len
	push esi
	mov esi,_src
	mov ecx,_len
	mov eax,ecx
	shr ecx,2
	push edi
	mov edi,_dest
	rep movsd
	mov ecx,eax
	and ecx,3
	rep movsb
	mov eax,esi
	pop edi
	pop esi
	ret
_memcpy2 endp

end DllMain