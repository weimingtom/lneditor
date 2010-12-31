.code

_Config proc
	invoke DialogBoxParamW,hInstance,IDD_CONFIG,hWinMain,offset _WndConfigProc,0
	ret
_Config endp

;
_WndConfigProc proc uses ebx edi esi,hwnd,uMsg,wParam,lParam
	mov eax,uMsg
	.if eax==WM_COMMAND
		mov eax,wParam
		.if eax==IDC_CF_OK
			invoke IsDlgButtonChecked,hwnd,IDC_CF_MODE_DOUBLE
			inc eax
			mov dbConf+_Configs.nEditMode,eax
			invoke GetDlgItemInt,hwnd,IDC_CF_AUTOTIME,offset dwTemp,FALSE
			.if !dwTemp
				mov eax,60
			.endif
			mov dbConf+_Configs.nAutoSaveTime,eax
			invoke IsDlgButtonChecked,hwnd,IDC_CF_LOC_EXE
			inc eax
			mov dbConf+_Configs.nNewLoc,eax
			invoke IsDlgButtonChecked,hwnd,IDC_CF_AC_NOT
			.if eax
				mov dbConf+_Configs.nAutoConvert,0
			.else
				invoke IsDlgButtonChecked,hwnd,IDC_CF_AC_HALF
				inc eax
				mov dbConf+_Configs.nAutoConvert,eax
			.endif
			invoke IsDlgButtonChecked,hwnd,IDC_CF_AUTOOPEN
			mov dbConf+_Configs.bAutoOpen,eax
			invoke IsDlgButtonChecked,hwnd,IDC_CF_AUTOSELECT
			mov dbConf+_Configs.bAutoSelText,eax
			invoke SendDlgItemMessageW,hwnd,IDC_CF_SAVEWITHCODE,CB_GETCURSEL,0,0
			mov ecx,dword ptr [eax*4+dbCodeTable]
			mov dbConf+_Configs.nAutoCode,ecx
			invoke _SaveConfig
			jmp @F
		.elseif eax==IDCANCEL
		@@:
			invoke EndDialog,hwnd,0
		.endif
	.elseif eax==WM_INITDIALOG
		mov eax,dbConf+_Configs.nEditMode
		add eax,IDC_CF_MODE_SINGLE-EM_SINGLE
		invoke CheckRadioButton,hwnd,IDC_CF_MODE_SINGLE,IDC_CF_MODE_DOUBLE,eax
		invoke SetDlgItemInt,hwnd,IDC_CF_AUTOTIME,dbConf+_Configs.nAutoSaveTime,FALSE
		mov eax,dbConf+_Configs.nNewLoc
		add eax,IDC_CF_LOC_CURRENT-NL_CURRENT
		invoke CheckRadioButton,hwnd,IDC_CF_LOC_CURRENT,IDC_CF_LOC_EXE,eax
		mov eax,dbConf+_Configs.nAutoConvert
		add eax,IDC_CF_AC_NOT-AC_NOT
		invoke CheckRadioButton,hwnd,IDC_CF_AC_NOT,IDC_CF_AC_HALF,eax
		invoke CheckDlgButton,hwnd,IDC_CF_AUTOOPEN,dbConf+_Configs.bAutoOpen
		invoke CheckDlgButton,hwnd,IDC_CF_AUTOSELECT,dbConf+_Configs.bAutoSelText
		invoke GetDlgItem,hwnd,IDC_CF_SAVEWITHCODE
		mov ebx,eax
		invoke SendMessageW,ebx,CB_ADDSTRING,0,offset szcdNotConvert
		invoke SendMessageW,ebx,CB_ADDSTRING,0,offset szcdGBK
		invoke SendMessageW,ebx,CB_ADDSTRING,0,offset szcdSJIS
		invoke _GetCodeIndex,dbConf+_Configs.nAutoCode
		invoke SendDlgItemMessageW,hwnd,IDC_CF_SAVEWITHCODE,CB_SETCURSEL,eax,0
	.elseif eax==WM_CLOSE
		invoke EndDialog,hwnd,0
	.endif
	xor eax,eax
	ret
_WndConfigProc endp