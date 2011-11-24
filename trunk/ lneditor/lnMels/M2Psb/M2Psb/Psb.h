#include<Windows.h>
#include<vector>

int compare1(char* arg1, char* arg2);
int compare2(WORD* arg1, WORD* arg2);
int compare3(char* arg1, char* arg2);
int compare4(DWORD* arg1, DWORD* arg2);

struct PsbHeader {
	DWORD	dwMagic;
	DWORD	nVersion;
	DWORD	unk;
	DWORD	nNameTree;
	DWORD	nStrOffList;
	DWORD	nStrRes;
	DWORD	nDibOffList;
	DWORD	nDibSizeList;
	DWORD	nDibRes;
	DWORD	nResIndexTree;
};

struct TreeNode
{
	int nBranch;
	std::vector<int> pSub;
};

struct PsbInfo
{
	DWORD*	lpStrOffList;
	int		nStrs;
	char*	lpStrRes;
	int		nTotalStrLen;
	int		nOriTotalStrLen;
	DWORD*	lpTree;
	int		nTreeSize;
	//char**	lpNamesTable;
	int		nNames;
};