;Error Codes
E_NOMEM				EQU		1
E_OVERMEM				EQU		2
E_NOTENOUGHBUFF		EQU		3
E_INVALIDPARAMETER		EQU		10H

;String type with character set Used in _GetStringInTxt
STC_UNKNOWN			EQU		0
STC_SJIS					EQU		80H
STC_GBK					EQU		86H
STC_UNICODE				EQU		0FFFFH

;Memory type for strings
MT_FIXEDSTRING			EQU		1
MT_VARIABLESTRING		EQU		2
MT_EVERYSTRING			EQU		3


;Internal String Len
MAX_STRINGLEN		EQU		512
SHORT_STRINGLEN		EQU		64

;Export Functions
_GetConstString 		proto
_Int2Str				proto :dword,:dword,:dword
_DisplayStatus			proto :dword,:dword
_GetStringInList		proto :dword,:dword

_SelfMatch			proto :dword

_GetText				proto :dword,:dword
_SaveText			proto :dword
_ModifyLine			proto :dword,:dword
_SetLine				proto :dword,:dword

;Help Match String 
_GetStringInTxt		proto :dword,:dword,:dword,:dword
_WildcharMatchW		proto :dword,:dword
