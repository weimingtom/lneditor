.386
.model flat,stdcall
option casemap:none

include krkr.inc

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
Match proc uses edi _lpszName
	invoke _SelfMatch,_lpszName
	.if eax==MR_NO || eax==MR_ERR
		RET
	.endif
	cld
	mov edi,_lpszName
	xor ax,ax
	mov ecx,MAX_STRINGLEN/2
	repne scasw
	sub edi,8
	.if word ptr [edi]=='.'
		mov eax,[edi+2]
		and eax,0ffdfffdfh
		.if eax==53004bh
			mov eax,MR_YES
			ret
		.endif
	.endif
	
	mov eax,MR_NO
	ret
Match endp

;
PreProc proc uses edi _lpPreData
	mov edi,_lpPreData
	assume edi:ptr _PreData
	mov eax,[edi].lpHandles
	mov lpHandles,eax
	mov ecx,[edi].lpFileInfo1
	mov lpFileInfo1,ecx
	mov eax,[edi].lpFileInfo2
	mov lpFileInfo2,eax
	mov edi,[edi].lpMenuFuncs
	assume edi:nothing
	
	assume edi:ptr _Functions
	mov [edi].PrevLine,offset PrevLine
	mov [edi].NextLine,offset NextLine
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

IDC_LIST1			EQU		1001
IDC_LIST2			EQU		1002

;
PrevLine proc
	mov edi,lpHandles
	assume edi:ptr _Handles
	invoke SendMessageW,[edi].hList2,LB_GETCURSEL,0,0
	mov ebx,eax
	.while ebx
		dec ebx
		invoke _GetStringInList,lpFileInfo1,ebx
		mov ax,[eax]
		.if ah
			invoke SendMessageW,[edi].hList1,WM_SETREDRAW,FALSE,0
			invoke SendMessageW,[edi].hList2,WM_SETREDRAW,FALSE,0
			invoke SendMessageW,[edi].hList1,LB_SETCURSEL,ebx,0
			invoke SendMessageW,[edi].hList2,LB_SETCURSEL,ebx,0
			invoke SendMessageW,[edi].hWinMain,WM_COMMAND,LBN_SELCHANGE*65536+IDC_LIST2,[edi].hList2
			ret
		.endif
	.endw
	assume edi:nothing
	ret
PrevLine endp

;
NextLine proc
	mov edi,lpHandles
	assume edi:ptr _Handles
	invoke SendMessageW,[edi].hList2,LB_GETCURSEL,0,0
	mov ebx,eax
	mov eax,lpFileInfo1
	mov esi,[eax+_FileInfo.nLine]
	dec esi
	.while ebx<esi
		inc ebx
		invoke _GetStringInList,lpFileInfo1,ebx
		mov ax,[eax]
		.if ah
			invoke SendMessageW,[edi].hList1,WM_SETREDRAW,FALSE,0
			invoke SendMessageW,[edi].hList2,WM_SETREDRAW,FALSE,0
			invoke SendMessageW,[edi].hList1,LB_SETCURSEL,ebx,0
			invoke SendMessageW,[edi].hList2,LB_SETCURSEL,ebx,0
			invoke SendMessageW,[edi].hWinMain,WM_COMMAND,LBN_SELCHANGE*65536+IDC_LIST2,[edi].hList2
			ret
		.endif
	.endw
	assume edi:nothing
	ret
NextLine endp

end DllMain