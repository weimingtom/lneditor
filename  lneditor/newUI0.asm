
_MyListData struct
	DrawState	dd		?
	IsDcStored	dd		?
	StoredDC	dd		?
	IsInside		dd		?
	nCurIdx		dd		?
_MyListData ends

DST_MOVEIN EQU 1
DST_BUTTONDOWN EQU 2
DST_NOTHING EQU 3

.data?
	lpOldListProc			dd		?
	lpOldEditProc			dd		?

.code
;创建新的列表框类
_CreateMyList proc _hInstance
;使用lpOldListProc与_NewListProc两个全局变量
	local @wce:WNDCLASSEX

	invoke GetClassInfoExW,NULL,offset szCList,addr @wce
	push @wce.lpfnWndProc
	pop lpOldListProc
	push offset _NewListProc
	pop @wce.lpfnWndProc
	push _hInstance
	pop @wce.hInstance
	mov @wce.lpszClassName,offset szCNewList
	mov @wce.cbSize,sizeof @wce
	or @wce.style,CS_GLOBALCLASS or CS_DBLCLKS
	mov @wce.cbWndExtra,8
	
	invoke RegisterClassExW,addr @wce

	ret
_CreateMyList endp

;
_CreateMyEdit proc _hInstance
;使用lpOldListProc与_NewListProc两个全局变量
	local @wce:WNDCLASSEX

	invoke GetClassInfoExW,NULL,offset szCEdit,addr @wce
	push @wce.lpfnWndProc
	pop lpOldEditProc
	push offset _NewEditProc
	pop @wce.lpfnWndProc
	push _hInstance
	pop @wce.hInstance
	mov @wce.lpszClassName,offset szCNewEdit
	mov @wce.cbSize,sizeof @wce
	or @wce.style,CS_GLOBALCLASS
	mov @wce.cbWndExtra,8
	
	invoke RegisterClassExW,addr @wce

	ret
_CreateMyEdit endp

_NewListProc proc uses ebx esi edi,hwnd,uMsg,wParam,lParam
	local @hbmp,@hcdc,@rect:RECT,@cx,@cy,@hmdc
	mov eax,uMsg
	.if eax==WM_MOUSEMOVE
		invoke GetWindowLongW,hwnd,4
		mov ebx,eax
		invoke SendMessageW,hwnd,LB_ITEMFROMPOINT,0,lParam
		assume ebx:ptr _MyListData
		cmp eax,[ebx].nCurIdx
		je _ExNLP
		mov edi,eax
		mov eax,[ebx].nCurIdx
		mov @cx,eax
		invoke SendMessageW,hwnd,LB_GETITEMRECT,[ebx].nCurIdx,addr @rect
		mov [ebx].nCurIdx,edi
		invoke InvalidateRect,hwnd,addr @rect,TRUE
		invoke SendMessageW,hwnd,LB_GETITEMRECT,edi,addr @rect
		invoke InvalidateRect,hwnd,addr @rect,TRUE
		
		mov esi,hwnd
		.if esi==hList1
			mov esi,hList2
		.else
			mov esi,hList1
		.endif
		invoke GetWindowLongW,esi,4
		mov ecx,[ebx].nCurIdx
		mov ebx,eax
		mov [ebx].nCurIdx,ecx
		invoke SendMessageW,esi,LB_GETITEMRECT,@cx,addr @rect
		mov [ebx].nCurIdx,edi
		invoke InvalidateRect,esi,addr @rect,TRUE
		invoke SendMessageW,esi,LB_GETITEMRECT,edi,addr @rect
		invoke InvalidateRect,esi,addr @rect,TRUE
		
		
		.if ![ebx].IsInside
			mov [ebx].IsInside,1
			sub esp,sizeof TRACKMOUSEEVENT
			mov esi,esp
			assume esi:ptr TRACKMOUSEEVENT
			mov [esi].cbSize,sizeof TRACKMOUSEEVENT
			mov [esi].dwFlags,TME_LEAVE
			mov eax,hwnd
			mov [esi].hwndTrack,eax
			mov [esi].dwHoverTime,0			
			invoke TrackMouseEvent,esi
			assume esi:nothing
			add esp,sizeof TRACKMOUSEEVENT
		.endif
		assume ebx:nothing
		
	.elseif eax==WM_ERASEBKGND
		invoke GetWindowLongW,hwnd,4
		mov ebx,eax
		assume ebx:ptr _MyListData
		.if ![ebx].IsDcStored
			invoke GetClientRect,hwnd,addr @rect
			mov eax,@rect.bottom
			sub eax,@rect.top
			mov @cy,eax
			mov eax,@rect.right
			sub eax,@rect.left
			mov @cx,eax
;			invoke ClientToScreen,hwnd,addr @rect
;			invoke ScreenToClient,hWinMain,addr @rect
;			invoke GetDC,hWinMain
;			mov @hmdc,eax
			
			invoke CreateCompatibleDC,wParam
			mov @hcdc,eax
			invoke CreateCompatibleBitmap,wParam,@cx,@cy
			mov @hbmp,eax
			invoke SelectObject,@hcdc,@hbmp
			mov esi,eax
			invoke BitBlt,@hcdc,0,0,@cx,@cy,wParam,0,0,SRCCOPY
;			invoke SelectObject,@hcdc,esi
;			invoke ReleaseDC,hWinMain,@hmdc
			mov [ebx].IsDcStored,1
			mov eax,@hcdc
			mov [ebx].StoredDC,eax
		.endif
		assume ebx:nothing
		mov eax,TRUE
		ret
	.elseif eax==WM_MOUSEWHEEL
		invoke SendMessageW,hList2,LB_GETTOPINDEX,0,0
		mov ebx,eax
		mov eax,wParam
		test eax,080000000h
		.if ZERO?
			or ebx,ebx
			je _ExNLP
			.if ebx<3
				mov ebx,3
			.endif
			sub ebx,3
		.else
			add ebx,3
		.endif
		invoke SendMessageW,hList1,WM_SETREDRAW,FALSE,0
		invoke SendMessageW,hList2,WM_SETREDRAW,FALSE,0
		invoke SendMessageW,hList1,LB_SETTOPINDEX,ebx,0
		invoke SendMessageW,hList2,LB_SETTOPINDEX,ebx,0
		invoke SendMessageW,hList1,WM_SETREDRAW,TRUE,0
		invoke SendMessageW,hList2,WM_SETREDRAW,TRUE,0
		invoke RedrawWindow,hList1,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
		invoke RedrawWindow,hList2,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
		xor eax,eax
		ret
	.elseif eax==WM_VSCROLL
			invoke SendMessageW,hList1,WM_SETREDRAW,FALSE,0
			invoke CallWindowProcW,lpOldListProc,hList1,uMsg,wParam,lParam
			invoke SendMessageW,hList1,WM_SETREDRAW,TRUE,0
			invoke RedrawWindow,hList1,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
			
			invoke SendMessageW,hList2,WM_SETREDRAW,FALSE,0
			invoke CallWindowProcW,lpOldListProc,hList2,uMsg,wParam,lParam
			invoke SendMessageW,hList2,WM_SETREDRAW,TRUE,0
			invoke RedrawWindow,hList2,0,0,RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW
;			mov bScrolling,FALSE
;		.endif
	.elseif eax==WM_MOUSELEAVE
		invoke GetWindowLongW,hwnd,4
		mov ebx,eax
		assume ebx:ptr _MyListData
		mov [ebx].IsInside,0
		mov eax,[ebx].nCurIdx
		mov @cx,eax
		invoke SendMessageW,hwnd,LB_GETITEMRECT,[ebx].nCurIdx,addr @rect		
		mov [ebx].nCurIdx,-2
		invoke InvalidateRect,hwnd,addr @rect,TRUE
		
		mov esi,hwnd
		.if esi==hList1
			mov esi,hList2
		.else
			mov esi,hList1
		.endif
		invoke SendMessageW,esi,LB_GETITEMRECT,@cx,addr @rect		
		invoke GetWindowLongW,esi,4
		mov ebx,eax
		mov [ebx].nCurIdx,-2
		invoke InvalidateRect,esi,addr @rect,TRUE
		
		assume ebx:nothing
	.elseif eax==WM_LBUTTONDBLCLK
		invoke SendMessageW,hwnd,LB_ITEMFROMPOINT,0,lParam
		.if ax!=-1
			movzx eax,ax
			mov esi,lpMarkTable
			.if esi
				xor byte ptr [esi+eax],1
			.endif
		.endif
	.elseif eax==WM_RBUTTONUP
		invoke SendMessageW,hwnd,LB_ITEMFROMPOINT,0,lParam
		.if ax!=-1
			invoke SendMessageW,hWinMain,WM_COMMAND,IDM_MODIFY,0
		.endif
	.elseif eax==WM_CREATE
		invoke HeapAlloc,hGlobalHeap,HEAP_ZERO_MEMORY,sizeof _MyListData
		.if !eax
			invoke SendMessageW,hwnd,WM_DESTROY,0,0
			ret
		.endif
		assume eax:ptr _MyListData
		mov [eax].nCurIdx,-2
		assume eax:nothing
		invoke SetWindowLongW,hwnd,4,eax
	.elseif eax==WM_DESTROY
		invoke GetWindowLongW,hwnd,4
		invoke HeapFree,hGlobalHeap,0,eax
	.endif
_Ex2NLP:
	invoke CallWindowProcW,lpOldListProc,hwnd,uMsg,wParam,lParam
	ret
_ExNLP:
	xor eax,eax
	ret
_NewListProc endp

;画列表框
_DrawListItem proc uses edi ebx _lpDIS
	LOCAL @cx,@cy
	LOCAL @rect:RECT
	LOCAL @bf:BLENDFUNCTION
	LOCAL @hmdc,@hBmp,@hOldBmp
	LOCAL @hmdc2,@hBmp2,@hOldBmp2
	mov dword ptr @bf,0
	
	mov edi,_lpDIS
	assume edi:ptr DRAWITEMSTRUCT
	cmp [edi].itemID,-1
	je _ExDLI
	cmp [edi].itemAction,ODA_FOCUS
	je _ExDLI
	invoke GetWindowLongW,[edi].hwndItem,4
	mov ebx,eax
	assume ebx:ptr _MyListData
	mov eax,[edi].rcItem.right
	sub eax,[edi].rcItem.left
	mov @cx,eax
	mov eax,[edi].rcItem.bottom
	sub eax,[edi].rcItem.top
	mov @cy,eax
	invoke CreateCompatibleDC,[edi].hdc
	mov @hmdc,eax
	invoke CreateCompatibleBitmap,[edi].hdc,@cx,@cy
	mov @hBmp,eax
	invoke CreateCompatibleDC,[edi].hdc
	mov @hmdc2,eax
	invoke CreateCompatibleBitmap,[edi].hdc,@cx,@cy
	mov @hBmp2,eax
	invoke SelectObject,@hmdc,@hBmp
	mov @hOldBmp,eax
	invoke SelectObject,@hmdc2,@hBmp2
	mov @hOldBmp2,eax
	mov @rect.left,0
	mov @rect.right,0
	mov eax,@cx
	mov @rect.right,eax
	mov eax,@cy
	mov @rect.bottom,eax
	invoke BitBlt,@hmdc,[edi].rcItem.left,[edi].rcItem.top,@cx,@cy,[ebx].StoredDC,[edi].rcItem.left,[edi].rcItem.top,SRCCOPY
	mov eax,[ebx].nCurIdx
	.if eax==[edi].itemID
		invoke GetSysColor,COLOR_HIGHLIGHT
		mov ecx,[edi].itemState
		and ecx,ODS_SELECTED
		.if ZERO?
			invoke _LightenColor,eax,0
		.else
			invoke _LightenColor,eax,1
		.endif
		invoke CreateSolidBrush,eax
		push eax
		invoke FillRect,[edi].hdc,addr [edi].rcItem,eax
		call DeleteObject
	.else
		mov ecx,[edi].itemState
		and ecx,ODS_SELECTED
		.if !ZERO?
			invoke GetSysColor,COLOR_HIGHLIGHT
			invoke _LightenColor,eax,1
			invoke CreateSolidBrush,eax
			push eax
			invoke FillRect,[edi].hdc,addr [edi].rcItem,eax
			call DeleteObject
		.endif
	.endif
	assume ebx:nothing
	invoke GetStockObject,WHITE_BRUSH
	invoke FillRect,@hmdc,addr @rect,eax
	mov @bf.SourceConstantAlpha,128
	invoke AlphaBlend,[edi].hdc,[edi].rcItem.left,[edi].rcItem.top,@cx,@cy,@hmdc,0,0,@cx,@cy,dword ptr @bf
	invoke SelectObject,@hmdc,@hOldBmp
	invoke DeleteObject,@hBmp
	invoke DeleteDC,@hmdc

	invoke SelectObject,[edi].hdc,hFontList
	invoke SetBkMode,[edi].hdc,TRANSPARENT
	mov eax,[edi].itemState
	and eax,ODS_SELECTED
	.if ZERO?
		invoke SetTextColor,[edi].hdc,dbConf+_Configs.TextColorDefault
	.else					
		invoke SetTextColor,[edi].hdc,dbConf+_Configs.TextColorSelected
	.endif
	.if [edi].CtlID==IDC_LIST1
		invoke _GetStringInList,offset FileInfo1,[edi].itemID
	.else
		invoke _GetStringInList,offset FileInfo2,[edi].itemID
	.endif
	.if eax
		mov ebx,eax
		invoke _ZoomRect,addr [edi].rcItem,LI_MARGIN_WIDTH
		invoke DrawTextW,[edi].hdc,ebx,-1,addr [edi].rcItem,DT_HIDEPREFIX or DT_LEFT or DT_WORDBREAK
		invoke _ZoomRect,addr [edi].rcItem,LI_MARGIN_WIDTH*-1
	.endif
	mov eax,[edi].itemState
	and eax,ODS_SELECTED
	.if !ZERO?
		invoke CreatePen,PS_SOLID,LI_FRAME_WIDTH,dbConf+_Configs.LineColor
		mov ebx,eax
		invoke SelectObject,[edi].hdc,ebx
		invoke _ZoomRect,addr [edi].rcItem,LI_FRAME_WIDTH/2
		invoke MoveToEx,[edi].hdc,[edi].rcItem.left,[edi].rcItem.top,NULL
		invoke LineTo,[edi].hdc,[edi].rcItem.right,[edi].rcItem.top
		invoke LineTo,[edi].hdc,[edi].rcItem.right,[edi].rcItem.bottom
		invoke LineTo,[edi].hdc,[edi].rcItem.left,[edi].rcItem.bottom
		sub [edi].rcItem.top,LI_FRAME_WIDTH/2
		invoke LineTo,[edi].hdc,[edi].rcItem.left,[edi].rcItem.top
		
		invoke DeleteObject,ebx
	.endif
	and eax,ODS_FOCUS
	assume edi:nothing
_ExDLI:
	ret
_DrawListItem endp

_ZoomRect proc uses edi _lpRect,_nPix
	mov edi,_lpRect
	assume edi:ptr RECT
	mov eax,_nPix
	add [edi].left,eax
	add [edi].top,eax
	sub [edi].right,eax
	sub [edi].bottom,eax
	assume edi:nothing
	ret
_ZoomRect endp

;
_LightenColor proc _color,_bDark
	mov ecx,_color
	mov eax,ecx
	not cl
	shr cl,1
	.if _bDark
		shr cl,1
	.endif
	add al,cl
	shr ecx,8
	not cl
	shr cl,1
	.if _bDark
		shr cl,1
	.endif
	add ah,cl
	shr ecx,8
	not cl
	shr cl,1
	.if _bDark
		shr cl,1
	.endif
	shl ecx,16
	add eax,ecx
	and eax,0ffffffh
	ret
_LightenColor endp

;
_NewEditProc proc uses ebx esi edi,hwnd,uMsg,wParam,lParam
	.if bOpen
	mov eax,uMsg
	.if eax==WM_KEYDOWN
		mov eax,wParam
		.if eax==VK_RETURN
			mov eax,hwnd
			.if eax==hEdit2
				invoke SendMessageW,hWinMain,WM_COMMAND,IDM_MODIFY,0
			.endif
		.elseif eax==VK_NEXT
			invoke SendMessageW,hWinMain,WM_COMMAND,IDM_NEXTTEXT,0
			RET
		.elseif eax==VK_PRIOR
			invoke SendMessageW,hWinMain,WM_COMMAND,IDM_PREVTEXT,0
			RET
		.endif
;	.elseif eax==WM_LBUTTONDOWN
;		invoke _UpdateWindow,hwnd
	.elseif eax==WM_ERASEBKGND
		.if hBackDC
			mov eax,hwnd
			.if eax==hEdit1
				mov ecx,WRI_EDIT1
			.elseif eax==hEdit2
				mov ecx,WRI_EDIT2
			.endif
			invoke BitBlt,wParam,0,0,dbConf+_Configs.windowRect[ecx]+RECT.right,dbConf+_Configs.windowRect[ecx]+RECT.bottom,hBackDC,\
				dbConf+_Configs.windowRect[ecx]+RECT.left,dbConf+_Configs.windowRect[ecx]+RECT.top,SRCCOPY
			mov eax,1
			ret
		.endif
	.elseif eax==WM_MOUSEWHEEL
		invoke SendMessageW,hList2,WM_MOUSEWHEEL,wParam,lParam
	.elseif eax==WM_CHAR
		cmp wParam,VK_RETURN
		je _ExNEP
		mov eax,hwnd
		cmp eax,hEdit1
		je _ExNEP
	.endif
	.endif
	invoke CallWindowProcW,lpOldEditProc,hwnd,uMsg,wParam,lParam
	ret
_ExNEP:
	xor eax,eax
	ret
_NewEditProc endp
