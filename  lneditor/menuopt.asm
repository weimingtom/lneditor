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
		invoke SendMessageW,ebx,CB_ADDSTRING,0,offset szcdUTF8
		invoke _GetCodeIndex,dbConf+_Configs.nAutoCode
		invoke SendDlgItemMessageW,hwnd,IDC_CF_SAVEWITHCODE,CB_SETCURSEL,eax,0
	.elseif eax==WM_CLOSE
		invoke EndDialog,hwnd,0
	.endif
	xor eax,eax
	ret
_WndConfigProc endp

_TxtFilter proc
	invoke DialogBoxParamW,hInstance,IDD_TXTFILTER,hWinMain,offset _WndFilterProc,0
	ret
_TxtFilter endp

_WndFilterProc proc uses ebx edi esi,hwnd,uMsg,wParam,lParam
	LOCAL @szStr[MAX_STRINGLEN]:byte
	mov eax,uMsg
	.if eax==WM_COMMAND
		mov ecx,wParam
		.if cx==IDC_TF_OK
			invoke IsDlgButtonChecked,hwnd,IDC_TF_ALWAYSAPPLY
			mov dbConf+_Configs.bAlwaysFilter,eax
			invoke IsDlgButtonChecked,hwnd,IDC_TF_INON
			mov byte ptr _Configs.TxtFilter.bInclude[dbConf],al
			invoke IsDlgButtonChecked,hwnd,IDC_TF_EXON
			mov byte ptr dbConf+_Configs.TxtFilter.bExclude,al
			invoke IsDlgButtonChecked,hwnd,IDC_TF_HEADON
			mov byte ptr dbConf+_Configs.TxtFilter.bTrimHead,al
			invoke IsDlgButtonChecked,hwnd,IDC_TF_TAILON
			mov byte ptr dbConf+_Configs.TxtFilter.bTrimTail,al
			invoke GetDlgItemTextW,hwnd,IDC_TF_INPTN,dbConf+_Configs.TxtFilter.lpszInclude,MAX_STRINGLEN/2
			invoke GetDlgItemTextW,hwnd,IDC_TF_EXPTN,dbConf+_Configs.TxtFilter.lpszExclude,MAX_STRINGLEN/2
			invoke GetDlgItemTextW,hwnd,IDC_TF_HEADPTN,dbConf+_Configs.TxtFilter.lpszTrimHead,MAX_STRINGLEN/2
			invoke GetDlgItemTextW,hwnd,IDC_TF_TAILPTN,dbConf+_Configs.TxtFilter.lpszTrimTail,MAX_STRINGLEN/2
			
			invoke SendMessageW,hList1,LB_GETCURSEL,0,1
			mov nCurIdx,eax
			
			invoke _ResetHideTable
			invoke _UpdateHideTable
			
			invoke SendMessageW,hList1,LB_RESETCONTENT,0,0
			invoke SendMessageW,hList2,LB_RESETCONTENT,0,0
			invoke _AddLinesToList,offset FileInfo1,hList1
			invoke _AddLinesToList,offset FileInfo2,hList2
			jmp @F
		.endif
		cmp cx,IDC_TF_CANCEL
		je @F
	.elseif eax==WM_INITDIALOG
		invoke CheckDlgButton,hwnd,IDC_TF_ALWAYSAPPLY,dbConf+_Configs.bAlwaysFilter
		movzx eax,byte ptr dbConf+_Configs.TxtFilter.bInclude
		invoke CheckDlgButton,hwnd,IDC_TF_INON,eax
		movzx eax,byte ptr dbConf+_Configs.TxtFilter.bExclude
		invoke CheckDlgButton,hwnd,IDC_TF_EXON,eax
		movzx eax,byte ptr dbConf+_Configs.TxtFilter.bTrimHead
		invoke CheckDlgButton,hwnd,IDC_TF_HEADON,eax
		movzx eax,byte ptr dbConf+_Configs.TxtFilter.bTrimTail
		invoke CheckDlgButton,hwnd,IDC_TF_TAILON,eax
		invoke SetDlgItemTextW,hwnd,IDC_TF_INPTN,dbConf+_Configs.TxtFilter.lpszInclude
		invoke SetDlgItemTextW,hwnd,IDC_TF_EXPTN,dbConf+_Configs.TxtFilter.lpszExclude
		invoke SetDlgItemTextW,hwnd,IDC_TF_HEADPTN,dbConf+_Configs.TxtFilter.lpszTrimHead
		invoke SetDlgItemTextW,hwnd,IDC_TF_TAILPTN,dbConf+_Configs.TxtFilter.lpszTrimTail
	.elseif eax==WM_CLOSE
	@@:
		invoke EndDialog,hwnd,0
	.endif
	xor eax,eax
	ret
_WndFilterProc endp

