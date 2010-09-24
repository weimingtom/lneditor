.code

;
_SetFont proc
	invoke _Dev
	ret
_SetFont endp

;
_SetBackground proc
	LOCAL @str[MAX_STRINGLEN]:byte
	mov eax,IDS_SELECTBKGND
	invoke _GetConstString
	invoke _OpenFileDlg,offset szImageFilter,addr @str,offset szNULL,eax
	or eax,eax
	je _ExSBG
	invoke lstrcpyW,dbConf+_Configs.lpBackName,addr @str
	invoke DeleteDC,hBackDC
	invoke DeleteObject,hBackBmp
	mov hBackDC,0
	invoke RedrawWindow,hWinMain,0,0,RDW_ERASE or RDW_INVALIDATE
_ExSBG:
	ret
_SetBackground endp

;
_CustomUI proc
	invoke _Dev
	ret
_CustomUI endp

;
_RecoverUI proc
	invoke _Dev
	ret
_RecoverUI endp
