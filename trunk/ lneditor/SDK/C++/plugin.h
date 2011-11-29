#ifndef _MEL_PLUGIN_H
#define _MEL_PLUGIN_H

//Interface version
#define INTERFACE_VERSION		0x00030000
#define TXTINTERFACE_VERSION	0x00010000

//MRESULT
#define E_ERROR				-1
#define E_SUCCESS			0
#define E_NOMEM				1
#define E_MEMACCESSFAIL			2
#define E_NOTENOUGHBUFF		3
#define E_FILEACCESSERROR	4
#define E_FATALERROR		5
#define E_WRONGFORMAT		6
#define E_FILECREATEERROR	7
#define E_FILEREADERROR		8
#define E_FILEWRITEERROR	9
#define E_INVALIDPARAMETER	10
#define E_PLUGINERROR		11
#define E_ANALYSISFAILED	12

#define E_LINENOTEXIST		0x100
#define E_LINETOOLONG		0x101
#define E_CODEFAILED		0x102
#define E_LINENOTMATCH		0x103
#define E_LINEDENIED		0x104

typedef unsigned long MRESULT;

//Error message types
#define WLT_CUSTOM			0x10000
#define WLT_LOADMELERR		0x10001
#define WLT_BATCHEXPERR		0x10002
#define WLT_BATCHIMPERR		0x10003

//Return information of GetText
#define RI_SUC_LINEONLY		1

//Return value of Match
#define MR_YES				5
#define MR_MAYBE			3
#define MR_NO				0
#define MR_ERR				-1

//Store type for strings table
#define MT_EVERYSTRING		3
#define MT_POINTERONLY		4

//CharSet of strings
#define CS_UNKNOWN			0
#define CS_GBK				936
#define CS_SJIS				932
#define CS_BIG5				950
#define CS_UTF8				65001
#define CS_UNICODE			-1

//End type of strings
#define ST_CUSTOM			0
#define ST_ENDWITHZERO		1
#define ST_PASCAL2			2
#define ST_PASCAL4			3
#define ST_SPECLEN			4
#define ST_TXTENDA			0x10
#define ST_TXTENDW			0x11

#include<windows.h>

#pragma pack(1)
typedef struct _STREAM_ENTRY {
	LPVOID	lpStart;
	DWORD	nStringLen;
	LPVOID	lpInformation;
} STREAM_ENTRY, *LPSTREAM_ENTRY;


typedef struct _FILE_INFO {
	LPWSTR			lpszName;
	HANDLE			hFile;
	
	LPVOID			lpStream;

	DWORD			dwMemoryType;

	LPWSTR*			lpTextIndex;
	STREAM_ENTRY*	lpStreamIndex;

	DWORD			dwStringType;
	DWORD			nStreamSize;
	DWORD			nLine;

	BOOL			bReadOnly;
	DWORD			dwCharSet;

	LPVOID			lpCustom;
	DWORD			dwReserved1;
	DWORD			dwReserved2;
} FILE_INFO, *LPFILE_INFO;


//Characteristics of Mel
#define MIC_CUSTOMEDIT			0x00000001
//#define MIC_CUSTOMTXTPROC		0x00000002
#define MIC_NOPREREAD			0x00000004
#define MIC_CUSTOMGUI			0x00000008
#define MIC_CUSTOMCONFIG		0x00000010

#define MIC_NOBATCHEXP			0x00010000
#define MIC_NOBATCHIMP			0x00020000
#define MIC_NOHALFANGLE			0x00040000

typedef struct _MEL_INFO {
	DWORD	dwInterfaceVersion;
	DWORD	dwCharacteristic;
} MEL_INFO, *LPMEL_INFO;

typedef struct _MEF_INFO {
	DWORD	dwInterfaceVersion;
	DWORD	dwCharacteristic;
} MEF_INFO, *LPMEF_INFO;

//Select range for edit control
typedef struct _SEL_RANGE {
	DWORD nLeft;
	DWORD nRight;
} SEL_RANGE, *LPSEL_RANGE;

typedef MRESULT (__stdcall *PFGET_TEXT)(LPFILE_INFO, LPDWORD);
typedef MRESULT (__stdcall *PFSAVE_TEXT)(LPFILE_INFO);
typedef MRESULT (__stdcall *PFMODIFY_LINE)(LPFILE_INFO, DWORD);
typedef MRESULT (__stdcall *PFSET_LINE)(LPCWSTR, LPSEL_RANGE);
typedef MRESULT (__stdcall *PFRET_LINE)(LPCWSTR);
typedef MRESULT (__stdcall *PFRELEASE)(LPFILE_INFO);

typedef MRESULT (__stdcall *PFGET_STR)(LPFILE_INFO, LPWSTR*, LPSTREAM_ENTRY);

//Simple function table
typedef struct _SIMPFUNC_TABLE {
	PFGET_TEXT		lpGetText;
	PFSAVE_TEXT		lpSaveText;
	PFMODIFY_LINE	lpModifyLine;
	PFSET_LINE		lpSetLine;
	PFRET_LINE		lpRetLine;
	PFRELEASE		lpRelease;
	PFGET_TEXT		lpGetStr;
} SIMPFUNC_TABLE, *LPSIMPFUNC_TABLE;

//Handles of the main window
typedef struct _WINDOW_HANDLES {
	HANDLE		hWinMain;
	HANDLE		hList1;
	HANDLE		hList2;
	HANDLE		hEdit1;
	HANDLE		hEdit2;
	HANDLE		hStatus;
} WINDOW_HANDLES, *LPWINDOW_HANDLES;

//Basic data used with PreProc callback function
typedef struct _PRE_DATA {
	HANDLE				hGlobalHeap;
	LPCWSTR				lpszConfigFileName;
	LPVOID				lpConfigs;	//���ýṹ

	LPVOID				lpMenuFuncs;
	LPSIMPFUNC_TABLE	lpSimpFunc;
	LPVOID				lpTxtFuncs;

	LPWINDOW_HANDLES	lpHandles;
} PRE_DATA, *LPPRE_DATA;

#pragma pack(1)
//Text filter settings by user
typedef struct _TEXT_FILTER {
	BYTE		bInclude;
	BYTE		bExclude;
	BYTE		bTrimHead;
	BYTE		bTrimTail;
	LPCWSTR		lpszInclude;
	LPCWSTR		lpszExclude;
	LPCWSTR		lpszTrimHead;
	LPCWSTR		lpszTrimTail;
} TEXT_FILTER, *LPTEXT_FILTER;


extern "C" {
//Exported Functions of lnedit
	MRESULT __stdcall _GetText(LPFILE_INFO lpFileInfo, LPDWORD dwReturnInfo);
	MRESULT __stdcall _SaveText(LPFILE_INFO lpFileInfo);
	MRESULT __stdcall _ModifyLine(LPFILE_INFO lpFileInfo, DWORD nLine);
	MRESULT __stdcall _SetLine(LPCWSTR lpszStr, LPSEL_RANGE lpRange);
	MRESULT __stdcall _RetLine(LPCWSTR lpszStr);

	LPWSTR	__stdcall _GetStringInList(LPFILE_INFO lpFileInfo, int nLine);
	MRESULT __stdcall _ReplaceInMem(LPVOID lpNew, DWORD nNewLen, LPVOID lpOld, DWORD nOldLen, DWORD nLeftLen);
	MRESULT __stdcall _WildCharMatchW(LPCWSTR lpszPattern, LPCWSTR lpszStr);
	LPWSTR	__stdcall _ReplaceCharsW(LPCWSTR lpszOri, DWORD dwOptions, DWORD dwReserved);

	MRESULT __stdcall _OutputMessage(DWORD dwType, LPCWSTR lpszPluginName, LPVOID lpParam1, LPVOID lpParam2);

	int		__stdcall _ZlibUncompress(LPVOID lpDest, DWORD* nDestLen, LPVOID lpSrc, DWORD nSrcLen);
	int		__stdcall _ZlibCompress(LPVOID lpDest, DWORD* nDestLen, LPVOID lpSrc, DWORD nSrcLen);
}

#ifdef OVERLOAD_NEW

void* operator new(size_t size)
{
	return (void*)HeapAlloc(g_hHeap,0,size);
}

void operator delete(void* p)
{
	HeapFree(g_hHeap,0,(LPVOID)p);
}

#endif

#endif // _MEL_PLUGIN_H
