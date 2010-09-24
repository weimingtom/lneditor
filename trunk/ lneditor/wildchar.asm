
COMMON_SETTING equ 530043h
CJK_WORD EQU 570043h
JAPANESE_KANA equ 4b004ah
FULL_ANGLE EQU 410046h
HALF_ANGLE EQU 410048h
GENERAL_SYMBOL EQU 530047h
DIGITS_HA EQU 480044h


.code

;
_WildcharMatchW proc uses esi edi ebx _lpszPattern,_lpszStr
	mov edi,_lpszPattern
	mov esi,_lpszStr
	.if !word ptr [esi]
		xor eax,eax
		ret
	.endif
	.while word ptr [edi]
		mov ax,[edi]
		.if ax=='*'
			add edi,2
			mov ax,[edi]
			.if ax=='*' || ax=='?' || ax=='%'
				jmp singleComp
			.endif
			.break .if !word ptr [edi]
			mov ebx,edi
			.repeat
				add edi,2
				mov ax,[edi]
			.until ax=='*' || ax=='?' || ax=='%' || !ax
			sub edi,ebx
			shr edi,1
			inc edi
			mov ecx,edi
			mov edi,ebx
			mov eax,ecx
			.repeat
				push esi
				push edi
				mov ecx,eax
				repe cmpsw
				.if !ecx
					add esp,8
					sub edi,2
					sub esi,2
					jmp nextMatch
				.endif
				pop edi
				pop esi
				add esi,2
			.until !word ptr [esi]
			jmp matchFail
		.elseif ax=='?'
			add esi,2
			add edi,2
		.elseif ax=='%'
			mov eax,[edi+2]
			mov cx,[esi]
			invoke _CharMatchW
			or eax,eax
			je matchFail
			add edi,6
			add esi,2
		.else
singleComp:
			cmpsw
			jne matchFail
		.endif
nextMatch:
	.endw
matchSuccess:
	mov eax,1
	ret
matchFail:
	xor eax,eax
	ret
_WildcharMatchW endp

;
_CharMatchW proc
	.if eax==COMMON_SETTING
		cmp cx,2000h
		jb charNo
		cmp cx,22ffh
		jbe charYes
		cmp cx,3000h
		jb charNo
		cmp cx,303fh
		jbe charYes
		cmp cx,4e00h
		jb charNo
		cmp cx,9fbfh
		jbe charYes
		cmp cx,0ff00h
		jb charNo
		cmp cx,0ff65h
		jbe charYes
		jmp charNo
	.elseif eax==JAPANESE_KANA
		cmp cx,3040h
		jb charNo
		cmp cx,30ffh
		ja charNo
	.elseif eax==CJK_WORD
		cmp cx,4e00h
		jb charNo
		cmp cx,9fbfh
		ja charNo
	.elseif eax==FULL_ANGLE
		or ch,ch
		je charNo
		jne charYes
	.elseif eax==HALF_ANGLE
		or ch,ch
		je charYes
		jne charNo
	.elseif eax==GENERAL_SYMBOL
		cmp cx,2000h
		jb charNo
		cmp cx,22ffh
		jbe charYes
		cmp cx,3000h
		jb charNo
		cmp cx,303fh
		jbe charYes
		cmp cx,0ff00h
		jb charNo
		cmp cx,0ff65h
		jbe charYes
		jmp charNo
	.elseif eax==DIGITS_HA
		cmp cx,30h
		jb charNo
		cmp cx,39h
		ja charNo
	.endif
charYes:
	mov eax,1
	ret
charNo:
	xor eax,eax
	ret
_CharMatchW endp
