;Error Codes
E_ERROR					EQU		-1
E_NOMEM				EQU		1
E_OVERMEM				EQU		2
E_NOTENOUGHBUFF		EQU		3
E_FILEACCESSERROR		EQU		4
E_FATALERROR			EQU		5
E_INVALIDPARAMETER		EQU		10H
E_PLUGINERROR			EQU		11H
E_LINENOTEXIST			EQU		100h
E_LINETOOLONG			EQU		101h
E_CODEFAILED				EQU		102H


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

;
_ReplaceInMem		proto :dword,:dword,:dword,:dword,:dword
