WLT_LOADMELERR			EQU		1

.data
TW0		'log.txt',		szLogFileName
dbUBOM		db		0ffh,0feh
TW0		"[%s]\t%d/%d/%d %02d:%02d:%02d\t",	szWltTime
TW0		'Can\-t load %s. %s\n',	szWltLoadMelErr

TW0		'Not enough memory.',szWltEMem1

TW0		'This is not an available MEL.',szWltEMel1
TW0		'Version too low.',szWltEMel2

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

_WriteLog proc uses ebx _nType,_lpszName,_lpsz1,_lpsz2
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
		.if EAX==WLT_LOADMELERR
			invoke wsprintfW,ebx,offset szWltLoadMelErr,_lpsz1,_lpsz2
			lea ebx,[ebx+eax*2]
			lea ecx,@szLog
			sub ebx,ecx
		.endif
		invoke WriteFile,hLogFile,addr @szLog,ebx,offset dwTemp,0
	.endif
	ret
_WriteLog endp