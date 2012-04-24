INTERFACE_VER			EQU		00030000h

MAX_STRINGLEN			equ		1024
;�������
E_ERROR					EQU		-1
E_NOMEM				EQU		1
E_OVERMEM				EQU		2
E_NOTENOUGHBUFF		EQU		3
E_FILEACCESSERROR		EQU		4
E_FATALERROR			EQU		5
E_WRONGFORMAT			EQU		6
E_FILECREATEERROR		EQU		7
E_FILEREADERROR			EQU		8
E_FILEWRITEERROR			EQU		9
E_INVALIDPARAMETER		EQU		0aH
E_PLUGINERROR			EQU		0bH
E_ANALYSISFAILED			EQU		0CH

E_LINENOTEXIST			EQU		100h
E_LINETOOLONG			EQU		101h
E_CODEFAILED				EQU		102H
E_LINENOTMATCH			EQU		103H
E_LINEDENIED				EQU		104H

WLT_CUSTOM				EQU		10000H
WLT_LOADMELERR			EQU		10001h
WLT_BATCHEXPERR		EQU		10002H
WLT_BATCHIMPERR		EQU		10003H

;Return Information of GetText
RI_SUC_LINEONLY			EQU		1	;�ı�����ȡ���ڴ��У���Ҫ�����������ӵ��б�����
;RI_SUC_LISTADDED			EQU		2	;�ı������ӵ��б�����
;RI_SUC_THLINE			EQU		3	;�Ѵ����̸߳����ı���ȡ���ڴ��У������������д�����Ӧ��Ϣ�������ӵ��б���
;RI_SUC_THLIST			EQU		4	;�Ѵ����̸߳����ı����ӵ��б����У������������д���������Ϣ

RI_FAIL_FORMAT			EQU		100h	;�ű���ʽ����
RI_FAIL_MEM				EQU		101h	;�ڴ����
RI_FAIL_ERRORCS			EQU		102h	;�޷������û����õı���
RI_FAIL_UNK				EQU		0ffffh	;δ֪����

;Match Result
MR_YES					EQU		5
MR_MAYBE				EQU		3
MR_NO					EQU		0
MR_ERR					EQU		-1

;Memory type for strings
MT_EVERYSTRING			EQU		3
MT_POINTERONLY			EQU		4

;nCharSet��
CS_UNKNOWN			EQU		0
CS_GBK					EQU		936
CS_SJIS					EQU		932
CS_BIG5					EQU		950
CS_UTF8					EQU		65001
CS_UNICODE				EQU		-1

;nStringType��
ST_CUSTOM				EQU		0
ST_ENDWITHZERO			EQU		1
ST_PASCAL2				EQU		2
ST_PASCAL4				EQU		3
ST_TXTENDA				EQU		10h
ST_TXTENDW				EQU		11h

;�ļ���Ϣ
_FileInfo struct
	;������������������
	szName				db		MAX_STRINGLEN	dup(?)	;�ļ���(��·��)
	hFile				dd		?						;�ļ����
	
	lpStream				dd		?						;�ļ�ֱ�Ӷ����ڴ���ָ��
	;�������ɲ��������д
	nMemoryType			dd		?						
	;�洢������ϸ������ĵ���
	lpTextIndex			dd		?						;���ı��ַ���������ָ�롣
	lpStreamIndex			dd		?						;��ѡ��ԭʼ�ű��ַ���������ָ�롣��ΪPOINTERONLY�洢���ͣ�������롣
	nStringType			dd		?						;�ַ������͡���C�ַ�����PASCAL�ַ����ȡ�
	nStreamSize			dd		?						;�ļ����ȡ�����ű��༭��ʱ���¡�
	nLine				dd		?						;�ı�������
;	nLineLen				dd		?						;��ѡ����ʹ�ö����ַ����洢��������ָʾ�ַ������ȡ������ڴ��ַ������ʹ�á�
	
	bReadOnly			dd		?						;ָ�����ļ��Ƿ�Ϊֻ�����Ƿ����б�����ࣩ
	nCharSet				dd		?						;ָʾ�����ļ����ַ�������Ϊ�����ַ������û������趨����������������д��
	
	lpCustom				dd		?						;�������ʹ�á�
	Reserved				dd		2		dup(?)
_FileInfo ends

;�������
MIC_CUSTOMEDIT			EQU		00000001H	;�Ǳ�׼�����������_Functions�еĺ���
MIC_CUSTOMTXTPROC		EQU		00000002H	;���ı�ר�ò����������TXT���˺�����
MIC_NOPREREAD			EQU		00000004H	;����ҪԤ�Ƚ��ļ������ڴ�
MIC_CUSTOMGUI			EQU		00000008H	;�����˽���
MIC_CUSTOMCONFIG		EQU		00000010H	;�Զ���ѡ��

MIC_NOBATCHEXP			EQU		00010000H	;��֧����������
MIC_NOBATCHIMP			EQU		00020000H	;��֧����������
MIC_NOHALFANGLE		EQU		00040000H	;��֧�ְ���ַ�

_MelInfo2 struct
	nInterfaceVer			dd		?			;�ӿڰ汾
	nCharacteristic		dd		?			;���������Ϣ
_MelInfo2 ends

;�˵���Ĵ�������������OpenScript֮ǰ������һЩ�����������Ϊֱ�ӵ��á����ɱ�������ء�
_Functions struct
	OpenScript			dd		?	;10001
	LoadScript			dd		?
	SaveScript			dd		?
	SaveAs				dd		?
	CloseScipt			dd		?
	SetCode				dd		?
	ExportTxt				dd		?
	ImportTxt			dd		?
	Exit					dd		?
	dd	?
	Undo				dd		?
	Redo				dd		?
	Modify				dd		?
	PrevLine				dd		?
	NextLine				dd		?
	MarkLine				dd		?
	PrevMark			dd		?
	NextMark			dd		?
	Find					dd		?
	Replace				dd		?
	SummaryFind			dd		?
	GotoLine				dd		?
	dd	?
	SetFont				dd		?
	SetBackground		dd		?
	CustomUI			dd		?
	RecoverUI			dd		?
	dd	?
	ExportAll				dd		?
	ImportAll				dd		?
	SummaryFindAll		dd		?
	dd	?
	Config				dd		?
	dd	?
	About				dd		?
	dd	?
	ToFull				dd		?
	ToHalf				dd		?
	UnmarkAll			dd		?
	Progress				dd		?		;10040
	TxtFilter				dd		?
	Reserved				dd		10		dup(?)
_Functions ends

;�ɲ��ʵ�ּ��׹��ܵĺ���
_SimpFunc struct
	GetText		dd		?	;���ű��еĴ��ı���FileInfo�ṹҪ��д��
	SaveText		dd		?	;��ѡ�������ļ��������ʵ����ͨ��lpStream��nStreamSizeĬ�ϱ���
	ModifyLine	dd		?	;���޸ĵ���д��ű�
	SetLine		dd		?	;��ѡ���ڴ��е�һ���ı����ú�������֮������ʾ���༭����
	RetLine		dd		?	;��ѡ���༭���е�һ���ı����ú�������֮����д���ڴ���
	Release		dd		?	;��ѡ���ͷ����з�����ڴ棨ֻ�����˹��ܣ�
	GetStr		dd		?	;��Streamָ��λ�û�ȡ�ַ���
_SimpFunc ends

;���ı��ű���ר�ô������������ɲ������
_TxtFunc	struct
	IsLineAdding	dd		?	;��Ĭ��GetText�����е���
	TrimLineHead	dd		?	;��Ĭ��GetText�����е���
_TxtFunc ends

_Handles struct
	hWinMain	dd		?
	hList1		dd		?
	hList2		dd		?
	hEdit1		dd		?
	hEdit2		dd		?
	hStatus		dd		?
_Handles ends

;�����е�Ԥ�����������ݵĽṹ
_PreData struct
	hGlobalHeap		dd		?	;ȫ�ֶ�
	
	lpszConfigFile		dd		?	;�����ļ���������ȫ·��
	lpConfigs			dd		?	;����
	
	lpMenuFuncs		dd		?	;�˵�������ָ�룬ָ��_Functions�ṹ
	lpSimpFuncs		dd		?	;���״���������ָ�룬ָ��_SimpFunc�ṹ
	lpTxtFuncs		dd		?	;���ı�����������ָ�룬ָ��_TxtFunc�ṹ
	
	lpHandles		dd		?	;���ھ���б�ָ�룬ָ��_Handles�ṹ
_PreData ends

_TextFilter struct
	bInclude			db		?
	bExclude			db		?
	bTrimHead		db		?
	bTrimTail			db		?
	lpszInclude		dd		?
	lpszExclude		dd		?
	lpszTrimHead		dd		?
	lpszTrimTail		dd		?
_TextFilter ends
