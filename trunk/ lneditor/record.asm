RECORD_VER			EQU		1

.code 

_ReadRec proc uses ebx _nType
	LOCAL @str[MAX_STRINGLEN]:byte
	LOCAL @hFile
	LOCAL @dbHdr[sizeof _FileRec]:byte
;	mov dword ptr [@dbHdr+_FileRec.nCharSet1],0
;	mov dword ptr [@dbHdr+_FileRec.nCharSet2],0
	lea ebx,@str
	invoke lstrcpyW,ebx,lpszConfigFile
	invoke _DirBackW,ebx
	invoke _DirCatW,ebx,offset szRecDir
	invoke SetCurrentDirectoryW,ebx
	or eax,eax
	je _ErrRR
	invoke lstrcpyW,ebx,offset FileInfo1.szName
	invoke lstrcatW,ebx,offset szRecExt
	invoke _DirFileNameW,ebx
	or eax,eax
	je _ErrRR
	invoke CreateFileW,eax,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrRR
	mov @hFile,eax
	lea edi,@dbHdr
	invoke ReadFile,@hFile,edi,sizeof _FileRec,offset dwTemp,0
	assume edi:ptr _FileRec
	
	cmp [edi].szMagic,'CERM'
	jne _ErrRR
	cmp [edi].nVer,RECORD_VER
	jB _ErrRR
	
	.if _nType==REC_MARKTABLE
		mov eax,[edi].nLenMT
		.if lpMarkTable && eax==FileInfo1.nLine
			invoke SetFilePointer,@hFile,[edi].nOffsetMT,0,FILE_BEGIN
			invoke ReadFile,@hFile,lpMarkTable,[edi].nLenMT,offset dwTemp,0
		.endif
		invoke CloseHandle,@hFile
	.elseif _nType==REC_CHARSET
		mov eax,[edi].nCharSet1
		mov ecx,[edi].nCharSet2
		mov FileInfo1.nCharSet,eax
		mov FileInfo2.nCharSet,ecx
		invoke CloseHandle,@hFile
	.elseif _nType==REC_LINEPOS
		invoke CloseHandle,@hFile
		mov eax,[edi].nPos
	.endif
	assume edi:ptr _nothing
_ErrRR:
	ret
_ReadRec endp

_WriteRec proc uses ebx edi
	LOCAL @str[MAX_STRINGLEN]:byte
	LOCAL @hFile
	LOCAL @dbHdr[sizeof _FileRec]:byte
	lea ebx,@str
	invoke lstrcpyW,ebx,lpszConfigFile
	invoke _DirBackW,ebx
	invoke SetCurrentDirectoryW,ebx
	or eax,eax
	je _ErrWR
	invoke _DirCatW,ebx,offset szRecDir
	invoke SetCurrentDirectoryW,ebx
	.if !eax
		invoke CreateDirectoryW,offset szRecDir,0
		invoke SetCurrentDirectoryW,ebx
		or eax,eax
		je _ErrWR
	.endif
	invoke lstrcpyW,ebx,offset FileInfo1.szName
	invoke lstrcatW,ebx,offset szRecExt
	invoke _DirFileNameW,ebx
	or eax,eax
	je _ErrWR
	invoke CreateFileW,eax,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je _ErrWR
	mov @hFile,eax
	lea edi,@dbHdr
	mov ecx,sizeof _FileRec/4
	xor eax,eax
	rep stosd
	lea edi,@dbHdr
	assume edi:ptr _FileRec
	mov [edi].nPos,0
	invoke SendMessageW,hList1,LB_GETCURSEL,0,1
	.if eax!=-1
		mov [edi].nPos,eax
	.endif
	mov [edi].szMagic,'CERM'
	mov [edi].nVer,RECORD_VER
	.if lpMarkTable
		mov [edi].nOffsetMT,sizeof _FileRec
	.else
		mov [edi].nOffsetMT,0
	.endif
	mov eax,FileInfo1.nLine
	mov ecx,FileInfo1.nCharSet
	mov [edi].nLenMT,eax
	mov [edi].nCharSet1,ecx
	mov eax,FileInfo2.nCharSet
	mov [edi].nCharSet2,eax
	invoke WriteFile,@hFile,edi,sizeof _FileRec,offset dwTemp,0
	.if lpMarkTable
		invoke WriteFile,@hFile,lpMarkTable,FileInfo1.nLine,offset dwTemp,0
		invoke SetEndOfFile,@hFile
	.endif
	invoke CloseHandle,@hFile
	mov eax,1
	ret
_ErrWR:
	xor eax,eax
	ret
_WriteRec endp
