.486
.model flat,stdcall
option casemap:none


include lnedit.inc
include config.inc
include plugin.inc
include com.inc

include _browsefolder.asm
include _CreateDIBitmap.asm
include config.asm
include wildchar.asm
include choosemel.asm
include menufile.asm
include menuedit.asm
include menuview.asm
include menuasm.asm
include menuopt.asm
include defaultedit.asm
include record.asm


include misc.asm
include misc2.asm
include newUI.asm


.code

assume fs:nothing
start:
;
invoke GetModuleHandleW,NULL
mov hInstance,eax
invoke InitCommonControls
invoke LoadIconW,hInstance,500
mov hIcon,eax
invoke HeapCreate,0,7ff00h,0
or eax,eax
je _FinalMemErr
mov hGlobalHeap,eax
invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,TOTAL_STRINGNUM*MAX_STRINGLEN
.if !eax
	_FinalMemErr:
	invoke MessageBoxW,0,offset szMemErr,0,MB_OK OR MB_ICONERROR
	jmp _FinalExit
.endif
mov lpStrings,eax
xor ebx,ebx
.while ebx<TOTAL_STRINGNUM
	mov eax,ebx
	shl eax,8
	add eax,lpStrings
	invoke LoadStringW,hInstance,ebx,eax,MAX_STRINGLEN/2
	inc ebx
.endw

invoke GetCommandLineW
invoke CommandLineToArgvW,eax,offset dwTemp
push eax
mov ebx,[eax]
invoke lstrlenW,ebx
shl eax,1
add eax,20
invoke HeapAlloc,hGlobalHeap,0,eax
or eax,eax
je _FinalMemErr
mov lpszConfigFile,eax
invoke lstrcpyW,eax,ebx
call LocalFree
invoke _DirBackW,lpszConfigFile
invoke _DirCatW,lpszConfigFile,offset szcfFileName

invoke _LoadConfig

invoke _WinMain
_FinalExit:
invoke ExitProcess,NULL

;
_WinMain proc
	local @stWndClass:WNDCLASSEX
	local @stMsg:MSG
	LOCAL @str[MAX_STRINGLEN]:byte
	mov ecx,sizeof @stWndClass
	lea edi,@stWndClass
	xor eax,eax
	rep stosb
	
	invoke LoadCursorW,0,IDC_ARROW
	
	
	mov @stWndClass.hCursor,eax
	push hInstance
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize,sizeof WNDCLASSEX
	mov @stWndClass.style,CS_HREDRAW OR CS_VREDRAW or CS_DBLCLKS 
	mov @stWndClass.lpfnWndProc,offset _WndMainProc
	push hIcon
	pop @stWndClass.hIcon
	invoke GetStockObject,NULL_BRUSH
	mov @stWndClass.hbrBackground,eax
	mov eax,IDS_CLASSNAME
	invoke _GetConstString
	mov ebx,eax
	mov @stWndClass.lpszClassName,eax
	invoke RegisterClassExW,addr @stWndClass
	
	invoke LoadMenuW,hInstance,IDR_MMENU_CHS
	mov hMenu,eax
	mov esi,eax
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,64
	.if !eax
		mov edi,offset szNULL
		jmp @F
	.endif
	mov edi,eax
	invoke _GenWindowTitle,edi,GWT_VERSION
	@@:
	invoke CreateWindowExW,WS_EX_CLIENTEDGE or WS_EX_ACCEPTFILES,ebx,edi,\
		WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
		dbConf+_Configs.windowRect[WRI_MAIN]+RECT.left,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_MAIN]+RECT.right,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.bottom,NULL,esi,hInstance,NULL
	mov hWinMain,eax
	.if edi!=offset szNULL
		invoke HeapFree,hGlobalHeap,0,edi
	.endif
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke UpdateWindow,hWinMain
	
	.while TRUE
		invoke GetMessageW,addr @stMsg,NULL,0,0
		.break .if eax==0
		invoke TranslateMessage,addr @stMsg
		invoke DispatchMessageW,addr @stMsg
	.endw
	
	ret
_WinMain endp

;
_WndMainProc proc uses ebx edi esi,hwnd,uMsg,wParam,lParam
	local @stPs:PAINTSTRUCT
	local @stRect:RECT
	local @hdc,@hFile
	LOCAL @szStr[SHORT_STRINGLEN]:byte
;	LOCAL @dt:DRAWTEXTPARAMS

	mov eax,uMsg
	.if eax==WM_COMMAND
		mov eax,wParam
		mov ecx,eax
		movzx eax,ax
		shr ecx,16
		or ecx,lParam
		.if ZERO?
			.if eax==IDM_OPEN
				mov esi,eax
				.if bOpen
					invoke _CloseScript
					cmp eax,-1
					je _ExMain
				.endif
				mov eax,IDS_OPENTITLE1
				invoke _GetConstString
				invoke _OpenFileDlg,offset szOpenFilter,offset FileInfo1.szName,dbConf+_Configs.lpInitDir1,eax
				or eax,eax
				je _ExMain
_BeginOpenMain:
				invoke lstrcpyW,dbConf+_Configs.lpInitDir1,offset FileInfo1.szName
				invoke _DirBackW,dbConf+_Configs.lpInitDir1

				invoke _TryMatch,offset FileInfo1.szName
				mov ebx,eax
				.if ebx==-3
					mov eax,IDS_ERRMATCH
					invoke _GetConstString
					invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
					jmp _ExMain
				.ELSEif ebx==-2
					mov eax,IDS_NOMATCH
					invoke _GetConstString
					invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
					jmp _ExMain
				.elseif ebx==-1
					invoke _SelfPreProc
					invoke EnableMenuItem,hMenu,IDM_EXPORT,MF_GRAYED
					invoke EnableMenuItem,hMenu,IDM_IMPORT,MF_GRAYED
					jmp _Open2Main
				.endif 
				xor eax,eax
				mov ax,sizeof _MelInfo
				mul bx
				add eax,lpMels
				mov edi,eax
				assume edi:ptr _MelInfo
				invoke _RestoreFunc
				invoke _GetSimpFunc,[edi].hModule,offset dbSimpFunc
				.if !eax
					mov eax,IDS_ERREXDLL
					invoke _GetConstString
					invoke wsprintfW,addr @szStr,eax,edi
					invoke MessageBoxW,hWinMain,addr @szStr,0,MB_OK or MB_ICONERROR
					jmp _ExMain
				.endif
				mov nCurMel,ebx
				invoke GetProcAddress,[edi].hModule,offset szFPreProc
				assume edi:nothing
				.if eax
					push esi
					push lpPreData
					call eax
					pop esi
				.endif
_Open2Main:
				mov eax,esi
			.elseif eax==IDM_LOAD
				mov esi,eax
				mov eax,IDS_OPENTITLE2
				invoke _GetConstString
				invoke _OpenFileDlg,offset szOpenFilter,offset FileInfo2.szName,dbConf+_Configs.lpInitDir2,eax
				or eax,eax
				je _ExMain
_LoadMain:
				invoke lstrcpyW,dbConf+_Configs.lpInitDir2,offset FileInfo2.szName
				invoke _DirBackW,dbConf+_Configs.lpInitDir2
				mov eax,esi
			.endif
			sub eax,IDM_OPEN
			call [eax*4+offset dbFunc]
			jmp _ExMain
			
		.elseif eax==IDC_LIST1 || eax==IDC_LIST2
			cmp bOpen,0
			je _ExMain
			invoke SendMessageW,lParam,LB_GETCOUNT,0,0
			or eax,eax
			je _ExMain
			mov eax,wParam
			shr eax,16
			.if eax==LBN_SELCHANGE
				mov esi,lParam
				.if esi==hList1
					mov edi,hList2
				.else
					mov edi,hList1
				.endif				
				invoke SendMessageW,esi,LB_GETCURSEL,0,0
				mov ebx,eax
				invoke SendMessageW,hList1,WM_SETREDRAW,FALSE,0
				invoke SendMessageW,hList2,WM_SETREDRAW,FALSE,0
				invoke SendMessageW,edi,LB_SETCURSEL,ebx,0
				invoke SendMessageW,esi,LB_GETTOPINDEX,0,0
				invoke SendMessageW,edi,LB_SETTOPINDEX,eax,0
				invoke SendMessageW,hList1,WM_SETREDRAW,TRUE,0
				invoke SendMessageW,hList2,WM_SETREDRAW,TRUE,0
				invoke RedrawWindow,hList1,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
				invoke RedrawWindow,hList2,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
				.if ebx!=-1 && ebx<FileInfo1.nLine
					invoke _SetTextToEdit,ebx
				.endif
			.endif
		.elseif eax==IDC_EDIT2
			mov eax,wParam
			shr eax,16
			.if eax==EN_CHANGE
				invoke GetClientRect,hEdit2,addr @stRect
				invoke RedrawWindow,hEdit2,addr @stRect,0,RDW_ERASE OR RDW_INVALIDATE
			.endif
		.endif
		
	.elseif eax==WM_DRAWITEM
		mov edi,lParam
		assume edi:ptr DRAWITEMSTRUCT
		.if [edi].CtlType==ODT_LISTBOX
			invoke _DrawListItem,edi
		.endif
		assume edi:nothing
		JMP _Ex2Main
		
	.elseif eax==WM_MEASUREITEM
		mov edi,lParam
		assume edi:ptr MEASUREITEMSTRUCT
		.if [edi].CtlType==ODT_LISTBOX
			invoke _GetRealLine,[edi].itemID
			.if eax!=-1
				invoke _CalHeight,[edi].itemID
			.endif
			mov [edi].itemHeight,eax
		.endif
		assume edi:nothing
		jmp _Ex2Main
		
	.elseif eax==WM_SETFOCUS
		.if bOpen
			invoke SetFocus,hEdit2
		.endif
		
	.elseif eax==WM_ERASEBKGND
		.if !hBackDC
			invoke CreateCompatibleDC,wParam
			mov hBackDC,eax
			invoke CreateCompatibleBitmap,wParam,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.right,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.bottom
			mov hBackBmp,eax
			invoke SelectObject,hBackDC,hBackBmp
			invoke lstrlenW,lpszConfigFile
			inc eax
			shl eax,1
			invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
			or eax,eax
			je @F
			mov ebx,eax
			invoke lstrcpyW,ebx,lpszConfigFile
			invoke _DirBackW,ebx
			invoke SetCurrentDirectoryW,ebx
			invoke HeapFree,hGlobalHeap,0,ebx
			@@:
			invoke _ShowPic,hBackDC,dbConf+_Configs.lpBackName
			or eax,eax
			je _PaintMain
			invoke SendMessageW,hList1,WM_LBUPDATE,0,0
			invoke SendMessageW,hList2,WM_LBUPDATE,0,0
		.endif
		invoke BitBlt,wParam,0,0,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.right,dbConf+_Configs.windowRect[WRI_MAIN]+RECT.bottom,hBackDC,0,0,SRCCOPY
		mov eax,1
		ret
_PaintMain:
		invoke GetClientRect,hwnd,addr @stRect
		invoke GetStockObject,WHITE_BRUSH
		invoke FillRect,hBackDC,addr @stRect,eax
	.elseif eax==WM_PAINT
		invoke BeginPaint,hwnd,addr @stPs
		mov @hdc,eax
		invoke EndPaint,hwnd,addr @stPs
		
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke GetStockObject,NULL_BRUSH
		ret
	.elseif eax==WM_CTLCOLOREDIT
		invoke SetTextColor,wParam,dbConf+_Configs.TextColorEdit
		invoke SetBkMode,wParam,TRANSPARENT
		invoke GetStockObject,NULL_BRUSH
		ret
		
	.elseif eax==WM_TIMER
		.if wParam==IDC_TIMER
			invoke _SaveScript
		.endif
		
	.elseif eax==WM_DROPFILES
		.if bOpen
			invoke _CloseScript
			cmp eax,-1
			je _ExMain
		.endif
		.if dbConf+_Configs.nEditMode==EM_SINGLE
			@@:
			invoke DragQueryFileW,wParam,0,offset FileInfo1.szName,MAX_STRINGLEN/2
			mov esi,IDM_OPEN
			jmp _BeginOpenMain
		.elseif dbConf+_Configs.nEditMode==EM_DOUBLE
			sub esp,sizeof POINT
			invoke DragQueryPoint,wParam,esp
			push hwnd
			call ChildWindowFromPoint
			cmp eax,hList1
			je @B
			.if eax==hList2 && word ptr [FileInfo1.szName]
				invoke DragQueryFileW,wParam,0,offset FileInfo2.szName,MAX_STRINGLEN/2
				mov esi,IDM_LOAD
				jmp _LoadMain
			.endif
		.endif
	
	.elseif eax==WM_CREATE
		mov eax,hwnd
		mov hWinMain,eax
		invoke _InitWindow,hwnd
		invoke VirtualAlloc,0,BF_UNDO_SIZE,MEM_COMMIT,PAGE_READWRITE
		.if !eax
			@@:
			mov eax,IDS_NOMEM
			invoke _GetConstString
			invoke MessageBoxW,hwnd,EAX,0,MB_OK or MB_ICONERROR
			invoke ExitProcess,0
		.endif
		mov lpUndo,eax
		invoke CreateThread,0,0,offset _LoadMel,0,0,0
		mov @hFile,eax
		invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,sizeof _PreData
		or eax,eax
		je @B
		mov lpPreData,eax
		assume eax:ptr _PreData
		push hGlobalHeap
		pop [eax].hGlobalHeap
		push lpszConfigFile
		pop [eax].lpszConfigFile
		mov [eax].lpConfigs,offset dbConf
		mov [eax].lpFileInfo1,offset FileInfo1
		mov [eax].lpFileInfo2,offset FileInfo2
		mov [eax].lpMenuFuncs,offset dbFunc
		mov [eax].lpSimpFuncs,offset dbSimpFunc
		mov [eax].lpTxtFuncs,offset dbTxtFunc
		mov [eax].lpHandles,offset hWinMain
		assume eax:nothing
		
		invoke HeapAlloc,hGlobalHeap,0,sizeof _Functions+sizeof _SimpFunc+sizeof _TxtFunc
		or eax,eax
		je @B
		mov lpOriFuncTable,eax
		mov edi,eax
		lea esi,dbFunc
		mov ecx,sizeof _Functions
		invoke _memcpy
		lea esi,dbSimpFunc
		mov ecx,sizeof _SimpFunc
		invoke _memcpy
		lea esi,dbTxtFunc
		mov ecx,sizeof _TxtFunc
		invoke _memcpy
		
		mov nCurMel,-1
		.if dbConf+_Configs.nEditMode==EM_SINGLE && dbConf+_Configs.bAutoOpen
			mov eax,dbConf+_Configs.lpPrevFile
			.if word ptr [eax]
				invoke lstrcpyW,offset FileInfo1.szName,eax
				invoke WaitForSingleObject,@hFile,INFINITE
				invoke CloseHandle,@hFile
				mov esi,IDM_OPEN
				jmp _BeginOpenMain
			.endif
		.endif
		
	.elseif eax==WM_CLOSE
		invoke _CloseScript
		cmp eax,-1
		je _ExMain
		invoke _SaveConfig
		invoke DestroyWindow,hwnd
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProcW,hwnd,uMsg,wParam,lParam
		ret
	.endif
	
_ExMain:
	xor eax,eax
	ret
_Ex2Main:
	mov eax,TRUE
	ret
_WndMainProc endp

;创建子窗口
_InitWindow proc hwnd
	invoke _CreateMyList,hInstance
	.if !eax
		invoke ExitProcess,0
	.endif
	invoke _CreateMyEdit,hInstance
	.if !eax
		invoke ExitProcess,0
	.endif
	invoke CreateWindowExW,WS_EX_LEFT,offset szCNewList,0,\
		WS_CHILD OR WS_VISIBLE OR WS_VSCROLL or LBS_NOTIFY OR LBS_NODATA or LBS_OWNERDRAWVARIABLE,\
		dbConf+_Configs.windowRect[WRI_LIST1]+RECT.left,dbConf+_Configs.windowRect[WRI_LIST1]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_LIST1]+RECT.right,dbConf+_Configs.windowRect[WRI_LIST1]+RECT.bottom,hwnd,IDC_LIST1,hInstance,NULL
	mov hList1,eax
	invoke CreateWindowExW,WS_EX_LEFT,offset szCNewList,0,\
		WS_CHILD OR WS_VISIBLE OR WS_VSCROLL or LBS_NOTIFY OR LBS_NODATA or LBS_OWNERDRAWVARIABLE,\
		dbConf+_Configs.windowRect[WRI_LIST2]+RECT.left,dbConf+_Configs.windowRect[WRI_LIST2]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_LIST2]+RECT.right,dbConf+_Configs.windowRect[WRI_LIST2]+RECT.bottom,hwnd,IDC_LIST2,hInstance,NULL
	mov hList2,eax
	invoke CreateWindowExW,WS_EX_LEFT,offset szCNewEdit,0,\
		WS_CHILD OR WS_VISIBLE or WS_VSCROLL OR ES_AUTOVSCROLL or ES_MULTILINE or ES_NOHIDESEL ,\
		dbConf+_Configs.windowRect[WRI_EDIT1]+RECT.left,dbConf+_Configs.windowRect[WRI_EDIT1]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_EDIT1]+RECT.right,dbConf+_Configs.windowRect[WRI_EDIT1]+RECT.bottom,hwnd,IDC_EDIT1,hInstance,NULL
	mov hEdit1,eax
	invoke CreateWindowExW,WS_EX_LEFT,offset szCNewEdit,0,\
		WS_CHILD OR WS_VISIBLE or WS_VSCROLL  or ES_MULTILINE or ES_NOHIDESEL ,\
		dbConf+_Configs.windowRect[WRI_EDIT2]+RECT.left,dbConf+_Configs.windowRect[WRI_EDIT2]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_EDIT2]+RECT.right,dbConf+_Configs.windowRect[WRI_EDIT2]+RECT.bottom,hwnd,IDC_EDIT2,hInstance,NULL
	mov hEdit2,eax
	invoke CreateWindowExW,WS_EX_LEFT,offset szCStatic,0,WS_CHILD,\; OR WS_VISIBLE ,\
		dbConf+_Configs.windowRect[WRI_STATUS]+RECT.left,dbConf+_Configs.windowRect[WRI_STATUS]+RECT.top,\
		dbConf+_Configs.windowRect[WRI_STATUS]+RECT.right,dbConf+_Configs.windowRect[WRI_STATUS]+RECT.bottom,hwnd,IDC_STATUS,hInstance,NULL
	mov hStatus,eax
;	invoke CreateWindowExW,WS_EX_LEFT,offset szCCombobox,0,CBS_DROPDOWN or WS_CHILD or WS_VISIBLE,\
;		dbConf+_Configs.windowRect[WRI_CODE1O]+RECT.left,dbConf+_Configs.windowRect[WRI_CODE1O]+RECT.top,\
;		dbConf+_Configs.windowRect[WRI_CODE1O]+RECT.right,dbConf+_Configs.windowRect[WRI_CODE1O]+RECT.bottom,hwnd,IDC_CODE1O,hInstance,NULL
;	mov hCode1O,eax
;	invoke CreateWindowExW,WS_EX_LEFT,offset szCCombobox,0,CBS_DROPDOWN or WS_CHILD,\; | WS_VISIBLE,\
;		dbConf+_Configs.windowRect[WRI_CODE1N]+RECT.left,dbConf+_Configs.windowRect[WRI_CODE1N]+RECT.top,\
;		dbConf+_Configs.windowRect[WRI_CODE1N]+RECT.right,dbConf+_Configs.windowRect[WRI_CODE1N]+RECT.bottom,hwnd,IDC_CODE1N,hInstance,NULL
;	mov hCode1N,eax
;	invoke CreateWindowExW,WS_EX_LEFT,offset szCCombobox,0,CBS_DROPDOWN or WS_CHILD or WS_VISIBLE,\
;		dbConf+_Configs.windowRect[WRI_CODE2O]+RECT.left,dbConf+_Configs.windowRect[WRI_CODE2O]+RECT.top,\
;		dbConf+_Configs.windowRect[WRI_CODE2O]+RECT.right,dbConf+_Configs.windowRect[WRI_CODE2O]+RECT.bottom,hwnd,IDC_CODE2O,hInstance,NULL
;	mov hCode2O,eax
;	invoke CreateWindowExW,WS_EX_LEFT,offset szCCombobox,0,CBS_DROPDOWN or WS_CHILD or WS_VISIBLE,\
;		dbConf+_Configs.windowRect[WRI_CODE2N]+RECT.left,dbConf+_Configs.windowRect[WRI_CODE2N]+RECT.top,\
;		dbConf+_Configs.windowRect[WRI_CODE2N]+RECT.right,dbConf+_Configs.windowRect[WRI_CODE2N]+RECT.bottom,hwnd,IDC_CODE2N,hInstance,NULL
;	mov hCode2N,eax

	invoke CreateFontIndirectW,offset dbConf+_Configs.listFont
	mov hFontList,eax
	invoke CreateFontIndirectW,offset dbConf+_Configs.editFont
	mov hFontEdit,eax
	.if eax
		invoke SendMessageW,hEdit1,WM_SETFONT,hFontEdit,TRUE
		invoke SendMessageW,hEdit2,WM_SETFONT,hFontEdit,TRUE
	.endif
	ret
_InitWindow endp

;载入所有插件，每个插件使用一个MelInfo结构，依次储存在lpMels里面
_LoadMel proc uses edi esi ebx _lParam
	LOCAL @szStr[MAX_STRINGLEN]:byte
	LOCAL @stFindData:WIN32_FIND_DATA
	LOCAL @hFind
	
	invoke GetModuleFileNameW,0,addr @szStr,MAX_STRINGLEN/2
	invoke _DirBackW,addr @szStr
	invoke _DirCatW,addr @szStr,offset szDLLDir
	invoke SetCurrentDirectoryW,addr @szStr
	mov lpMels,0
	.if eax
		invoke FindFirstFileW,offset szMelFile,addr @stFindData
		.if eax!=INVALID_HANDLE_VALUE
			mov @hFind,eax
			invoke VirtualAlloc,0,MAX_MELCOUNT*sizeof _MelInfo,MEM_COMMIT,PAGE_READWRITE
			.if !eax
				mov eax,IDS_FAILLOADMEL
				invoke _GetConstString
				invoke MessageBoxW,hWinMain,eax,0,MB_OK or MB_ICONERROR
				jmp _Ex2LM
			.endif
			mov lpMels,eax
			mov esi,eax
			xor ebx,ebx
			assume esi:ptr _MelInfo
			.repeat
				lea edi,@stFindData.cFileName
				invoke LoadLibraryW,edi
				.if eax
					mov [esi].hModule,eax
					invoke lstrcpyW,esi,edi
					invoke GetProcAddress,[esi].hModule,offset szFMatch
					.if !eax
						invoke FreeLibrary,[esi].hModule
						jmp _CtnLM
					.endif
					mov [esi].pMatch,eax
				.endif
				add esi,sizeof _MelInfo
				inc ebx
_CtnLM:
				invoke FindNextFileW,@hFind,addr @stFindData
			.until eax==FALSE || ebx>=MAX_MELCOUNT-1
_Ex2LM:
			invoke FindClose,@hFind
			assume esi:nothing
		.endif
	.endif
_ExLM:
	
	xor eax,eax
	ret
_LoadMel endp

;对每个插件进行匹配，返回值：
;大于等于0即为匹配成功的插件的索引值，-1为内置匹配成功，-2为匹配失败，-3为匹配过程中发生错误
_TryMatch proc uses edi esi ebx _lpszName
	LOCAL @pFunc[MAX_MELCOUNT]:dword
	LOCAL @pstr
	push _HandlerTM
	push fs:[0]
	mov fs:[0],esp
	cmp lpMels,0
	je _SelfMatchTM
	mov edi,dbConf+_Configs.lpDefaultMel
	.if edi && word ptr [edi]
		mov esi,lpMels
		xor ebx,ebx
		.repeat
			invoke lstrcmpW,esi,edi
			.if !eax
				assume esi:ptr _MelInfo
				push _lpszName
				call [esi].pMatch
				.if eax==MR_NO
					invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,MAX_STRINGLEN
					mov @pstr,eax
					mov eax,IDS_NOTDEFMEL
					invoke _GetConstString
					invoke wsprintfW,@pstr,eax,edi
					mov eax,IDS_WINDOWTITLE
					invoke _GetConstString
					invoke MessageBoxW,hWinMain,@pstr,eax,MB_YESNO or MB_DEFBUTTON2
					mov esi,eax
					invoke HeapFree,hGlobalHeap,0,@pstr
					.break .if esi==IDNO
				.endif
				assume esi:nothing
				mov eax,ebx
				jmp _ExTM
			.endif
			inc ebx
			add esi,sizeof _MelInfo
		.until !word ptr [esi]
	.endif
	
	lea esi,@pFunc
	mov edi,esi
	or eax,-1
	mov ecx,MAX_MELCOUNT
	rep stosd
	xor ebx,ebx
	mov edi,lpMels
	assume edi:ptr _MelInfo
	.while word ptr [edi]
		push _lpszName
		call [edi].pMatch
		.if eax==MR_YES
			mov eax,ebx
			jmp _ExTM
		.elseif eax==MR_MAYBE
			mov [esi],ebx
			add esi,4
		.endif
		inc ebx
		add edi,sizeof _MelInfo
	.endw
	assume edi:nothing
	lea esi,@pFunc
	cmp dword ptr [esi],-1
	je _SelfMatchTM
		.if dword ptr [esi+4]==-1
			mov eax,[esi]
			jmp _ExTM
		.endif
		invoke DialogBoxParamW,hInstance,IDD_CHOOSEMEL,hWinMain,offset _WndCMProc,esi
		cmp eax,-2
		jne _ExTM
	;else
_SelfMatchTM:
		invoke _SelfMatch,_lpszName
		.if eax==MR_YES
			or eax,-1
		.else
			mov eax,-2
		.endif
_ExTM:
	pop fs:[0]
	pop ecx
	ret
_HandlerTM:
	mov eax,[esp+0ch]
	mov [eax+0b8h],offset _ExTM
	mov dword ptr [eax+0b0h],-3
	xor eax,eax
	ret
_TryMatch endp

;内置匹配函数
_SelfMatch proc uses esi edi ebx _lpszName
	LOCAL @hFile,@lpBuff
	LOCAL @buff[8]:byte
	invoke CreateFileW,_lpszName,GENERIC_READ,FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax==-1
		ret
	.endif
	mov @hFile,eax
	invoke ReadFile,@hFile,addr @buff,4,offset dwTemp,0
	or eax,eax
	je _ErrSM
	cmp word ptr [@buff],0feffh
	je _OKSM
	mov eax,dword ptr [@buff]
	and eax,0ffffffh
	cmp eax,0bfbbefh
	je _OKSM
	invoke GetFileSizeEx,@hFile,addr @buff
	invoke SetFilePointer,@hFile,0,0,FILE_BEGIN
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,512
	or eax,eax
	je _ErrSM
	mov @lpBuff,eax
	mov eax,dword ptr @buff
	.if eax>512
		mov eax,512
	.endif
	invoke ReadFile,@hFile,@lpBuff,eax,offset dwTemp,0
	.if !eax
		invoke HeapFree,hGlobalHeap,0,@lpBuff
		jmp _ErrSM
	.endif
	mov edi,@lpBuff
	mov ecx,511
	xor ebx,ebx
	@@:
	.if word ptr [edi]==0a0dh
		inc ebx
		jmp @F
	.endif
	inc edi
	loop @B
	@@:
	invoke HeapFree,hGlobalHeap,0,@lpBuff
	or ebx,ebx
	je _NOSM
_OKSM:
	invoke CloseHandle,@hFile
	mov eax,MR_YES
	jmp _ExSM
_NOSM:
	invoke CloseHandle,@hFile
	mov eax,MR_NO
	jmp _ExSM
_ErrSM:
	invoke CloseHandle,@hFile
	mov eax,MR_ERR
_ExSM:
	ret
_SelfMatch endp

;内置预处理函数，把所有可重载函数恢复为默认
_SelfPreProc proc
	invoke _RestoreFunc
	mov nCurMel,-1
	ret
_SelfPreProc endp

;所有可重载函数恢复为默认
_RestoreFunc proc uses esi edi
	.if lpOriFuncTable
		mov esi,lpOriFuncTable
		lea edi,dbFunc
		mov ecx,sizeof _Functions
		invoke _memcpy
		lea edi,dbSimpFunc
		mov ecx,sizeof _SimpFunc
		invoke _memcpy
		lea edi,dbTxtFunc
		mov ecx,sizeof _TxtFunc
		invoke _memcpy
	.endif
	ret
_RestoreFunc endp

;重载SimpFunc的几个函数
_GetSimpFunc proc uses edi ebx _hModule,_pSF
	mov edi,_pSF
	assume edi:ptr _SimpFunc
	invoke GetProcAddress,_hModule,offset szFGetText
	or eax,eax
	je _FailGSF
	mov [edi].GetText,eax
	invoke GetProcAddress,_hModule,offset szFModifyLine
	or eax,eax
	je _FailGSF
	mov [edi].ModifyLine,eax
	invoke GetProcAddress,_hModule,offset szFSaveText
	mov [edi].SaveText,eax
	invoke GetProcAddress,_hModule,offset szFSetLine
	.if eax
		mov [edi].SetLine,eax
	.endif
	invoke GetProcAddress,_hModule,offset szFRetLine
	mov [edi].RetLine,eax
	invoke GetProcAddress,_hModule,offset szFRelease
	mov [edi].Release,eax
	invoke GetProcAddress,_hModule,offset szFGetStr
	.if eax
		mov [edi].GetStr,eax
	.endif
	assume edi:nothing
	mov eax,1
	ret
_FailGSF:
	xor eax,eax
	ret
_GetSimpFunc endp

;将列表框中的文本显示在编辑框中
_SetTextToEdit proc uses esi edi ebx _nIdx
	LOCAL @ps1,@ps2
	LOCAL @range[2]:dword
	invoke _GetStringInList,offset FileInfo1,_nIdx
	mov esi,eax
	invoke lstrlenW,esi
	inc eax
	mov ebx,eax
	shl eax,2
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	or eax,eax
	je _ExSTTE
	mov @ps1,eax
	mov edi,eax
	mov ecx,ebx
	rep movsw
	
_Dis2STTE:
	invoke _GetStringInList,offset FileInfo2,_nIdx
	or eax,eax
	je _ExSTTE2
	mov esi,eax
	invoke lstrlenW,esi
	inc eax
	mov ebx,eax
	shl eax,2
	invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,eax
	or eax,eax
	je _ExSTTE2
	mov @ps2,eax
	mov edi,eax
	mov ecx,ebx
	rep movsw
	
	mov dword ptr @range,0
	mov dword ptr [@range+4],-1
	mov ebx,dbSimpFunc+_SimpFunc.SetLine
	.if ebx
		push 0
		push @ps1
		call ebx
		lea eax,@range
		push eax
		push @ps2
		call ebx
	.endif
	invoke SendMessageW,hEdit1,WM_SETTEXT,0,@ps1
	invoke SendMessageW,hEdit2,WM_SETTEXT,0,@ps2
	invoke SetFocus,hEdit2
	.if dbConf+_Configs.bAutoSelText==TRUE
		invoke SendMessageW,hEdit2,EM_SETSEL,@range,[@range+4]
	.ENDIF

	invoke HeapFree,hGlobalHeap,0,@ps2
_ExSTTE2:
	invoke HeapFree,hGlobalHeap,0,@ps1
_ExSTTE:
	xor eax,eax
	ret
_SetTextToEdit endp


end start