#include<Windows.h>
#include<vector>
#include<algorithm>

HANDLE g_hHeap;
#define OVERLOAD_NEW
#include "\masm32\lneditor\SDK\C++\plugin.h"

#include"Psb.h"

HINSTANCE g_hInstance;

void WINAPI InitInfo(LPMEL_INFO lpMelInfo)
{
	lpMelInfo->dwInterfaceVersion=INTERFACE_VERSION;
	lpMelInfo->dwCharacteristic=0;
}

void WINAPI PreProc(LPPRE_DATA lpPreData)
{
	g_hHeap=lpPreData->hGlobalHeap;
}

int WINAPI Match(LPCWSTR lpszName)
{
	int len=lstrlenW(lpszName);

	HANDLE hFile=CreateFile(lpszName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
	if(hFile==INVALID_HANDLE_VALUE)
		return MR_ERR;
	DWORD nRead;
	DWORD sHdr[2];
	BOOL bRet=ReadFile(hFile,&sHdr,8,&nRead,0);
	CloseHandle(hFile);
	if(!bRet)
		return MR_ERR;
	if(sHdr[0]=='\0BSP' && sHdr[1]==2)
		return MR_YES;
	return MR_NO;
}

DWORD GetInt(BYTE* &p, char t)
{
	switch(t)
	{
	case 0xd:
		return *p++;
	case 0xe:
		{
			WORD val=*(WORD*)p;
			p+=2;
			return val;
		}
	case 0xf:
		{
			DWORD val=*(WORD*)p;
			p+=2;
			val+=(*p++)*0x10000;
			return val;
		}
	case 0x10:
		{
			DWORD val=*(DWORD*)p;
			p+=4;
			return val;
		}
	default:
		__asm int 3
	}
	return 0;
}

DWORD GetInt(BYTE* &p)
{
	return GetInt(p,*p++);
}

char* M2GetStr(BYTE* p, char t, PsbInfo* pInfo)
{
	int idx=GetInt(p,t-(0x15-0xd));
	return pInfo->lpStrRes+pInfo->lpStrOffList[idx];
}
char* M2GetStr(BYTE* p, PsbInfo* pInfo)
{
	char t=*p++;
	return M2GetStr(p,t,pInfo);
}

DWORD* CopyArray(BYTE* pOri, DWORD count, int type)
{
	DWORD* pArray=new DWORD[count];
	switch(type)
	{
	case 0xd:
		{
			for(int i=0;i<count;i++)
				pArray[i]=pOri[i];
		}
		break;
	case 0xe:
		{
			WORD* p=(WORD*)pOri;
			for(int i=0;i<count;i++)
				pArray[i]=p[i];
		}
		break;
	case 0xf:
		{
			DWORD temp;
			for(int i=0;i<count;i++)
			{
				temp=*(WORD*)pOri;
				pOri+=2;
				temp+=*pOri++ * 0x10000;
				pArray[i]=temp;
			}
		}
		break;
	case 0x10:
		memcpy(pArray,pOri,count*4);
		break;
	default:
		__asm int 3
	}
	return pArray;
}

DWORD* CopyArray(BYTE* p)
{
	DWORD count=GetInt(p);
	char type=*p++;
	return CopyArray(p,count,type);
}

TreeNode* MakeBranchTable(BYTE* pOri, DWORD count, int type)
{
	TreeNode* pTable=new TreeNode[count];
	for(int i=0;i<count;i++)
	{
		pTable[i].nBranch=0;
	}

	DWORD val;
	int size=type-12;
	BYTE* p=pOri;
	for(int i=0;i<count;i++)
	{
		val=GetInt(p,type);
		pTable[val].pSub.push_back(i);
		pTable[val].nBranch++;
	}
	return pTable;
}

char** tNames;
char* tName;
DWORD* tTree;
TreeNode* tBranches;
int tMaxId;
void TraverseTree(int depth,int node)
{
	if(node==0 && depth!=0)
		return;
	for(int i=0;i<tBranches[node].nBranch;i++)
	{
		tName[depth]=tBranches[node].pSub[i]-tTree[node];
		if(tName[depth]!=0)
			TraverseTree(depth+1,tBranches[node].pSub[i]);
		else if(tTree[node]<=tMaxId)
		{
			tNames[tTree[node]]=new char[depth+1];
			strncpy(tNames[tTree[node]],tName,depth);
		}
	}
}

int GetIDFromTree(DWORD* tree, int count, char* name)
{
	int node=0;
	int len=lstrlenA(name)+1;
	for(int i=0;i<len;i++)
		node=tree[node]+name[i];
	return tree[node];
}

BYTE* FindInDict(char* name, BYTE* dict, PsbInfo* pInfo)
{
	BYTE* p=dict;
	DWORD count=GetInt(p);
	char type=*p++;
	DWORD* pCases=CopyArray(p,count,type);
	int id=GetIDFromTree(pInfo->lpTree,pInfo->nTreeSize,name);
	DWORD* rslt=(DWORD*)bsearch(&id,pCases,count,4,(int (*)(const void*, const void*))compare4);
	if(rslt==NULL)
		__asm int 3
	id=rslt-pCases;
	delete[] pCases;

	p+=count*(type-12);
	count=GetInt(p);
	type=*p++;
	
	BYTE* p2=p+id*(type-12);
	return p+count*(type-12)+GetInt(p2,type);
}

BYTE* FindTag(char* tagname,BYTE* restree,PsbInfo* pInfo)
{
	//未实现根据tagname查找，而是直接查找scenes[texts[*]]
	BYTE* p=restree;
	if(*p++!=0x21)
		__asm int 3
	p=FindInDict("scenes",p,pInfo);
	if(*p++!=0x20)
		__asm int 3
	DWORD count=GetInt(p);
	if(count==0)
		__asm int 3
	char type=*p++;
	DWORD off=GetInt(p,type);
	p+=(count-1)*(type-12)+off;
	if(*p++!=0x21)
		__asm int 3
	p=FindInDict("texts",p,pInfo);
	return p;
}

int AddStr(BYTE* pC,LPFILE_INFO lpFileInfo,int nLine)
{
	char type=*pC++;
	if(type!=1)
	{
		PsbInfo* pInfo=(PsbInfo*)lpFileInfo->lpCustom;
		DWORD idx=GetInt(pC,type-0x15+0xd);
		if(idx<pInfo->nStrs)
		{
			char* pFinalStr=pInfo->lpStrRes+pInfo->lpStrOffList[idx];
			if(*pFinalStr!=0)
			{
				lpFileInfo->lpStreamIndex[nLine].lpStart=(LPVOID)idx;
				lpFileInfo->lpStreamIndex[nLine].lpInformation=(LPVOID)lstrlenA(pFinalStr);
				return 1;
			}
		}
	}
	return 0;
}

MRESULT WINAPI GetText(LPFILE_INFO lpFileInfo, LPDWORD lpdwRInfo)
{
	PsbInfo* pInfo=new PsbInfo;
	memset(pInfo,0,sizeof(PsbInfo));
	lpFileInfo->lpCustom=pInfo;

	PsbHeader* pHeader=(PsbHeader*)lpFileInfo->lpStream;
	if(pHeader->dwMagic!='\0BSP')
		return E_WRONGFORMAT;
	if(lpFileInfo->dwCharSet==CS_UNKNOWN)
		lpFileInfo->dwCharSet=CS_UTF8;
	else if(lpFileInfo->dwCharSet!=CS_UTF8)
		return E_CODEFAILED;
	
	BYTE* p=(BYTE*)lpFileInfo->lpStream + pHeader->nNameTree;
	DWORD count=GetInt(p);
	char type=*p++;
	tTree=CopyArray(p,count,type);
	pInfo->lpTree=tTree;
	pInfo->nTreeSize=count;
	p+=count*(type-12);
	count=GetInt(p);
	type=*p++;
	tBranches=MakeBranchTable(p,count,type);
	p+=count*(type-12);
	count=GetInt(p);
	type=*p++;
	DWORD* pIDTable=CopyArray(p,count,type);
	for(int i=0;i<count;i++)
		if(pIDTable[i]>tMaxId)
			tMaxId=pIDTable[i];
	tNames=new char*[tMaxId+1];
	memset(tNames,0,(tMaxId+1)*4);
	//pInfo->lpNamesTable=tNames;
	pInfo->nNames=tMaxId+1;
	tName=new char[512];

	TraverseTree(0,0);

	delete[] tName;
	delete[] tBranches;
	for(int i=0;i<pInfo->nNames;i++)
		if(tNames[i])
			delete[] tNames[i];
	delete[] tNames;

	p=(BYTE*)lpFileInfo->lpStream + pHeader->nStrOffList;
	count=GetInt(p);
	type=*p++;
	DWORD* pOff=CopyArray(p,count,type);
	pInfo->lpStrOffList=pOff;
	pInfo->nStrs=count;
	
	int max=0;
	for(int i=0;i<count;i++)
		if(pOff[i]>max)
			max=pOff[i];
	p=(BYTE*)lpFileInfo->lpStream + pHeader->nStrRes;
	int size=lstrlenA((char*)&p[max])+1+max;
	pInfo->lpStrRes=new char[size*3];
	pInfo->nTotalStrLen=size;
	pInfo->nOriTotalStrLen=size;
	memcpy(pInfo->lpStrRes,p,size);

	//p=FindTag("scenes[texts[*]]",(BYTE*)lpFileInfo->lpStream+pHeader->nResIndexTree,pInfo);
	//if(*p++!=0x20)
	//	__asm int 3
	//count=GetInt(p);
	//type=*p++;
	//DWORD* textsOffTable=CopyArray(p,count,type);
	//BYTE* pStart=p+count*(type-12);

	lpFileInfo->lpStreamIndex=(STREAM_ENTRY*)VirtualAlloc(0,
		pInfo->nStrs*2*sizeof(STREAM_ENTRY),MEM_COMMIT,PAGE_READWRITE);

	p=(BYTE*)lpFileInfo->lpStream + pHeader->nResIndexTree;
	if(*p++!=0x21)
		__asm int 3
	p=FindInDict("scenes",p,pInfo);
	if(*p++!=0x20)
		__asm int 3
	DWORD scCount=GetInt(p);
	type=*p++;
	DWORD* pScOff=CopyArray(p,count,type);
	BYTE* pScStart=p+scCount*(type-12);

	int nLine=0;

	for(int k=0;k<scCount;k++)
	{
		p=pScStart+pScOff[k];
		if(*p++!=0x21)
			__asm int 3
		p=FindInDict("texts",p,pInfo);
		if(*p++!=0x20)
			__asm int 3
		count=GetInt(p);
		type=*p++;
		DWORD* textsOffTable=CopyArray(p,count,type);
		BYTE* pStart=p+count*(type-12);
		for(int i=0;i<count;i++)
		{
			p=pStart+textsOffTable[i];
			if(*p++!=0x20)
				__asm int 3
			DWORD cnt=GetInt(p);
			if(cnt<3)
				__asm int 3
			type=*p++;
			DWORD* offsets=CopyArray(p,cnt,type);
			p+=cnt*(type-12);

			int nToAdd=AddStr(p+offsets[1],lpFileInfo,nLine);
			nLine+=nToAdd;
			if(!nToAdd)
				nLine+=AddStr(p+offsets[0],lpFileInfo,nLine);
			nLine+=AddStr(p+offsets[2],lpFileInfo,nLine);
			//DWORD idx;
			//char* pFinalStr;
			//BYTE* p2=p+offsets[1];
			//type=*p2++;
			//if(type!=1)
			//{
			//	idx=GetInt(p2,type-(0x15-0xd));
			//	pFinalStr=pInfo->lpStrRes+pInfo->lpStrOffList[idx];
			//	if(*pFinalStr!=0)
			//	{
			//		lpFileInfo->lpStreamIndex[nLine].lpStart=pFinalStr;
			//		lpFileInfo->lpStreamIndex[nLine++].lpInformation=(LPVOID)idx;
			//	}
			//}
			//p2=p+offsets[2];
			//type=*p2++;
			//idx=GetInt(p2,type-(0x15-0xd));
			//pFinalStr=pInfo->lpStrRes+pInfo->lpStrOffList[idx];
			//if(*pFinalStr!=0)
			//{
			//	lpFileInfo->lpStreamIndex[nLine].lpStart=pFinalStr;
			//	lpFileInfo->lpStreamIndex[nLine++].lpInformation=(LPVOID)idx;
			//}
			delete[] offsets;
		}
		delete[] textsOffTable;
	}
	delete[] pScOff;

	lpFileInfo->dwMemoryType=MT_POINTERONLY;
	lpFileInfo->dwStringType=ST_ENDWITHZERO;
	lpFileInfo->nLine=nLine;
	*lpdwRInfo=RI_SUC_LINEONLY;

	return E_SUCCESS;
}

MRESULT WINAPI GetStr(LPFILE_INFO lpFileInfo,LPWSTR* pPos,LPSTREAM_ENTRY lpStreamEntry)
{
	PsbInfo* pInfo=(PsbInfo*)lpFileInfo->lpCustom;
	char* pStr=pInfo->lpStrRes+pInfo->lpStrOffList[(DWORD)lpStreamEntry->lpStart];
	int nLen=lstrlenA(pStr);
	wchar_t* pTemp=new wchar_t[(nLen+2)*2];
	if(pTemp==0)
	{
		delete[] *pPos;
		return E_NOMEM;
	}
	int nSize=MultiByteToWideChar(CP_UTF8,0,pStr,-1,pTemp,nLen+2);
	if(!nSize)
	{
		delete[] pTemp;
		return E_NOTENOUGHBUFF;
	}
	*pPos=_ReplaceCharsW(pTemp,0x00010001,0);
	delete[] pTemp;
	if(*pPos==0)
		return E_NOMEM;
	//for(int i=0,j=0;i<nSize;i++)
	//{
	//	if(pTemp[i]!=L'\n')
	//		(*pPos)[j++]=pTemp[i];
	//	else
	//	{
	//		(*pPos)[j++]=L'\\';
	//		(*pPos)[j++]=L'n';
	//	}
	//	if(j>=nLen+6)
	//		break;
	//}
	//delete[] pTemp;
	return E_SUCCESS;
}

MRESULT WINAPI ModifyLine(LPFILE_INFO lpFileInfo, DWORD nLine)
{
	PsbInfo* pInfo=(PsbInfo*)lpFileInfo->lpCustom;

	wchar_t* pWideStr=_GetStringInList(lpFileInfo,nLine);
	pWideStr=_ReplaceCharsW(pWideStr,0x00000001,0);
	if(pWideStr==0)
		return E_NOMEM;
	int nNewLen=lstrlenW(pWideStr);
	char* pNewStr=new char[nNewLen*4];
	nNewLen=WideCharToMultiByte(CP_UTF8,0,pWideStr,-1,pNewStr,nNewLen*4,0,0);

	DWORD nStrIdx=(DWORD)lpFileInfo->lpStreamIndex[nLine].lpStart;
	DWORD nStrOff=pInfo->lpStrOffList[nStrIdx];
	char* pOldStr=pInfo->lpStrRes+nStrOff;
	int nOldLen=lstrlenA(pOldStr)+1;

	if(nNewLen<=(DWORD)lpFileInfo->lpStreamIndex[nLine].lpInformation)
	{
		memcpy(pOldStr,pNewStr,nNewLen);
	}
	else
	{
		memcpy(pInfo->lpStrRes+pInfo->nTotalStrLen,pNewStr,nNewLen);
		pInfo->lpStrOffList[nStrIdx]=pInfo->nTotalStrLen;
		pInfo->nTotalStrLen+=nNewLen;
	}
	delete[] pNewStr;
	delete[] pWideStr;

	return E_SUCCESS;
}

void CorrectHeader(PsbHeader* pHeader, DWORD off, int nDiff)
{
	DWORD* p=(DWORD*)pHeader+4;
	for(int i=0;i<sizeof(PsbHeader)/4-4;i++)
		if(p[i]>off)
			p[i]+=nDiff;
}

MRESULT WINAPI SaveText(LPFILE_INFO lpFileInfo)
{
	PsbInfo* pInfo=(PsbInfo*)lpFileInfo->lpCustom;
	BYTE* lpTemp=(BYTE*)VirtualAlloc(0,lpFileInfo->nStreamSize*2,MEM_COMMIT,PAGE_READWRITE);
	memcpy(lpTemp,lpFileInfo->lpStream,lpFileInfo->nStreamSize);
	PsbHeader* pHeader=(PsbHeader*)lpTemp;
	MRESULT ret=_ReplaceInMem(pInfo->lpStrRes,pInfo->nTotalStrLen,
		lpTemp+pHeader->nStrRes,pInfo->nOriTotalStrLen,
		lpFileInfo->nStreamSize - pHeader->nStrRes - pInfo->nOriTotalStrLen);
	if(ret!=E_SUCCESS)
	{
		VirtualFree(lpTemp,0,MEM_RELEASE);
		return ret;
	}

	int nDiff=pInfo->nTotalStrLen-pInfo->nOriTotalStrLen;
	CorrectHeader(pHeader,pHeader->nStrRes,nDiff);
	int nNewStreamSize=lpFileInfo->nStreamSize+nDiff;
	
	BYTE* p=lpTemp+pHeader->nStrOffList;
	DWORD count=GetInt(p);
	DWORD nOriOffSize=(*p-12)*count;
	*p++ = 4+12;
	ret=_ReplaceInMem(pInfo->lpStrOffList,pInfo->nStrs*4,p,nOriOffSize,
		lpTemp+nNewStreamSize-p-nOriOffSize);
	if(ret!=E_SUCCESS)
	{
		VirtualFree(lpTemp,0,MEM_RELEASE);
		return ret;
	}
	nDiff=pInfo->nStrs*4-nOriOffSize;
	CorrectHeader(pHeader,pHeader->nStrOffList,nDiff);
	nNewStreamSize+=nDiff;

	SetFilePointer(lpFileInfo->hFile,0,0,FILE_BEGIN);
	DWORD BytesRead;
	WriteFile(lpFileInfo->hFile,lpTemp,nNewStreamSize,&BytesRead,0);
	VirtualFree(lpTemp,0,MEM_RELEASE);
	if(BytesRead!=nNewStreamSize)
		return E_FILEACCESSERROR;
	SetEndOfFile(lpFileInfo->hFile);
	return E_SUCCESS;
}

MRESULT WINAPI Release(LPFILE_INFO lpFileInfo)
{
	if(lpFileInfo->lpCustom)
	{
		PsbInfo* p=(PsbInfo*)lpFileInfo->lpCustom;
		//if(p->lpNamesTable)
		//{
		//	for(int i=0;i<p->nNames;i++)
		//		if(p->lpNamesTable[i])
		//			delete[] p->lpNamesTable[i];
		//	delete[] p->lpNamesTable;
		//}
		if(p->lpStrOffList)
			delete[] p->lpStrOffList;
		if(p->lpStrRes)
			delete[] p->lpStrRes;

		delete lpFileInfo->lpCustom;
	}
	return E_SUCCESS;
}

MRESULT WINAPI SetLine(LPCWSTR lpStr,LPSEL_RANGE lpRange)
{
	return _SetLine(lpStr,lpRange);
}

int compare1(BYTE* arg1, BYTE* arg2)
{
	return *arg1-*arg2;
}
int compare2(WORD* arg1, WORD* arg2)
{
	return *arg1-*arg2;
}
int compare3(BYTE* arg1, BYTE* arg2)
{
	return GetInt(arg1,0xf)-GetInt(arg2,0xf);
}
int compare4(DWORD* arg1, DWORD* arg2)
{
	return *arg1-*arg2;
}