.386
.model flat,stdcall
option casemap:none

include musica.inc

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
	LOCAL @buff
	invoke CreateFileW,_lpszName,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,INVALID_HANDLE_VALUE
	je _ErrMatch
	push eax
	mov ecx,eax
	invoke ReadFile,ecx,addr @buff,1,offset dwTemp,0
	call CloseHandle
	.if byte ptr @buff!=';'
		mov eax,MR_NO
		ret
	.endif
	mov eax,MR_YES
	ret
_ErrMatch:
	mov eax,MR_ERR
	ret
Match endp

;
PreProc proc uses edi _lpPreData
	mov edi,_lpPreData
	assume edi:ptr _PreData
	mov edi,[edi].lpTxtFuncs
	assume edi:nothing
	
	assume edi:ptr _TxtFunc
	mov [edi].IsLineAdding,offset IsLineAdd
	mov [edi].TrimLineHead,offset TrimLineHead
	assume edi:nothing
	ret
PreProc endp

;
GetText proc
	jmp _GetText
GetText endp

;
ModifyLine proc
	jmp _ModifyLine
ModifyLine endp

;
SaveText proc
	jmp _SaveText
SaveText endp
;
SetLine proc
	jmp _SetLine
SetLine endp

IsLineAdd proc _lpstr
	invoke _WildcharMatchW,$CTW0(".message*"),_lpstr
	ret
IsLineAdd endp

TrimLineHead proc uses esi _lpstr
	mov esi,_lpstr
	add esi,16
	lodsw
	cmp ax,9
	jne _ErrTLH
	.repeat
		lodsw
		or ax,ax
		je _ErrTLH
	.until ax==9
	lodsw
	.if ax!=9
		.repeat
			lodsw
			or ax,ax
			je _ErrTLH
		.until ax==9
	.elseif word ptr [esi]==9
		add esi,2
	.endif
	invoke lstrcpyW,_lpstr,esi
	mov eax,esi
	sub eax,_lpstr
	shr eax,1
	ret
_ErrTLH:
	xor eax,eax
	ret
TrimLineHead endp


end DllMain