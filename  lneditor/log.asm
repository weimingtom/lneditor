WLT_CUSTOM				EQU		10000H
WLT_LOADMELERR			EQU		10001h

.data
TW0		'log.txt',		szLogFileName
dbUBOM		db		0ffh,0feh
TW0		'[%s] %s',	szWltMB
TW0		"[%s]\t%d/%d/%d %02d:%02d:%02d\t",	szWltTime
TW0		'Can\-t load %s. %s\n',	szWltLoadMelErr
TW0		'This is not an available MEL.',szWltEMel1
TW0		'Version too low.',szWltEMel2

TW0		'Not enough memory.',szWltEMem1
TW0		'Mem access error.',	szWltEMem2
TW0		'There is not enough buff.',	szWltEMem3
TW0		'File access error.',		szWltEFileAccess
TW0		'Fatal Error.',	szWltEFatal
TW0		'Wrong format.',	szWltEFormat
TW0		'Can\-t create/open file.',	szWltEFileCreate
TW0		'Can\-t read file.',	szWltEFileRead
TW0		'Can\-t write file.',	szWltEFileWrite

TW0		'Invalid Parameter.',	szWltEPara
TW0		'An error occured in the plugin.',	szWltEPlugin

TW0		'The line is not exist.',	szWltELineExist
TW0		'The line is too long',	szWltELineLong
TW0		'The CP(Code Page) operation failed',	szWltECode
TW0		'Lines in left and right is not match.',	szWltELineMatch


.data
align 4
pWltError1	dd	0,offset szWltEMem1,offset szWltEMem2,offset szWltEMem3,offset szWltEFileAccess,offset szWltEFatal,offset szWltEFormat
			dd	offset szWltEFileCreate,offset szWltEFileRead,offset szWltEFileWrite,offset szWltEPara,offset szWltEPlugin
pWltError2	dd	offset szWltELineExist,offset szWltELineLong,offset szWltECode,offset szWltELineMatch

.code

_OpenLog proc
	invoke CreateFileW,offset szLogFileName,GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	mov hLogFile,eax
	.if eax==-1
		invoke CreateFileW,offset szLogFileName,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax==-1
			mov eax,IDS_LOGFILEOPENNOT
			invoke _GetConstString
			invoke MessageBoxW,0,eax,0,MB_OK or MB_ICONERROR
			ret
		.endif
		mov hLogFile,eax
		invoke WriteFile,eax,offset dbUBOM,2,offset dwTemp,0
	.endif
	invoke SetFilePointer,hLogFile,0,0,FILE_END
	ret
_OpenLog endp

_GetGeneralErrorString proc _nType
	mov ecx,_nType
	.if ecx<100h
		lea edx,pWltError1
		mov eax,[edx+ecx*4]
	.else
		lea edx,pWltError2
		sub ecx,100h
		mov eax,[edx+ecx*4]
	.endif
	ret
_GetGeneralErrorString endp

_OutputMessage proc _nType,_lpszName,para1,para2
	.if nUIStatus & UIS_CONSOLE
		
	.else
		.if nUIStatus & UIS_BUSY
			invoke _WriteLog,_nType,_lpszName,para1,para2
		.else
			mov eax,_nType
			.if eax<10000h
				invoke _GetGeneralErrorString,_nType
				invoke MessageBoxW,hWinMain,eax,_lpszName,MB_OK or MB_ICONINFORMATION
			.elseif eax==WLT_CUSTOM
			.elseif eax==WLT_LOADMELERR
			.endif
		.endif
	.endif
	ret
_OutputMessage endp

_WriteLog proc uses ebx _nType,_lpszName,para1,para2
	LOCAL @nowtime:SYSTEMTIME
	LOCAL @szLog[MAX_STRINGLEN]:byte
	.if hLogFile!=-1 && hLogFile
		invoke GetLocalTime,addr @nowtime
		xor eax,eax
		xor ecx,ecx
		mov cx,@nowtime.wSecond
		push ecx
		mov ax,@nowtime.wMinute
		push eax
		mov cx,@nowtime.wHour
		push ecx
		mov ax,@nowtime.wYear
		push eax
		mov cx,@nowtime.wDay
		push ecx
		mov ax,@nowtime.wMonth
		push eax
		push _lpszName
		push offset szWltTime
		lea ecx,@szLog
		push ecx
		call wsprintfW
		add esp,36
		lea ecx,@szLog
		lea ebx,[ecx+eax*2]
		mov eax,_nType
		.if eax<10000h
			invoke _GetGeneralErrorString,_nType
			mov para1,eax
			invoke lstrcpyW,ebx,eax
			invoke lstrlenW,para1
			lea ebx,[ebx+eax*2]
		.elseif eax==WLT_CUSTOM
			invoke lstrcpyW,ebx,para1
			invoke lstrlenW,para1
			lea ebx,[ebx+eax*2]
		.elseif EAX==WLT_LOADMELERR
			invoke wsprintfW,ebx,offset szWltLoadMelErr,para1,para2
			lea ebx,[ebx+eax*2]
		.endif
		lea ecx,@szLog
		sub ebx,ecx
		invoke WriteFile,hLogFile,addr @szLog,ebx,offset dwTemp,0
	.endif
	ret
_WriteLog endp