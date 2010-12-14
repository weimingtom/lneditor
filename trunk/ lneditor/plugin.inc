;Return Information of GetText
RI_SUC_LINEONLY			EQU		1	;�ı�����ȡ���ڴ��У���Ҫ�����������ӵ��б�����
RI_SUC_LISTADDED			EQU		2	;�ı������ӵ��б�����
RI_SUC_THLINE			EQU		3	;�Ѵ����̸߳����ı���ȡ���ڴ��У������������д�����Ӧ��Ϣ�������ӵ��б���
RI_SUC_THLIST			EQU		4	;�Ѵ����̸߳����ı����ӵ��б����У������������д���������Ϣ

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
MT_FIXEDSTRING			EQU		1
MT_VARIABLESTRING		EQU		2
MT_EVERYSTRING			EQU		3
MT_POINTERONLY			EQU		4

;nCharSet��
CS_UNKNOWN			EQU		0
CS_UNICODE				EQU		-1
CS_GBK					EQU		936
CS_SJIS					EQU		932
CS_BIG5					EQU		950

;nStringType��
ST_CUSTOM				EQU		0
ST_ENDWITHZERO			EQU		1
ST_PASCAL2				EQU		2
ST_PASCAL4				EQU		3
ST_TXTENDA				EQU		10h
ST_TXTENDW				EQU		11h

;�˵���Ĵ�������������OpenScript֮ǰ������һЩ�����������Ϊֱ�ӵ��á����ɱ�������ء�
_Functions struct
	OpenScript			dd		?	;10001
	LoadScript			dd		?
	SaveScript			dd		?
	SaveAs				dd		?
	CloseScipt			dd		?
	SetSaveDir			dd		?
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
	hGlobalHeap		dd		?	;ȫ�ֶѣ����Ƽ�����������ڴ�
	
	lpszConfigFile		dd		?	;�����ļ���������ȫ·��
	lpConfigs		dd		?	;����
	
	lpFileInfo1		dd		?
	lpFileInfo2		dd		?
	
	lpMenuFuncs		dd		?	;�˵�������ָ�룬ָ��_Functions�ṹ
	lpSimpFuncs		dd		?	;���״���������ָ�룬ָ��_SimpFunc�ṹ
	lpTxtFuncs		dd		?	;���ı�����������ָ�룬ָ��_TxtFunc�ṹ
	
	lpHandles		dd		?	;���ھ���б�ָ�룬ָ��_Handles�ṹ
_PreData ends

ifndef FILEINFOSTRUCT
FILEINFOSTRUCT EQU 1
;���򿪵Ľű���������Ϣ
;�����ɲ����д����ΪnMemoryType,nLine
_FileInfo struct
	;������������������
	szName				db		MAX_STRINGLEN	dup(?)	;�ļ���(��·��)
	hFile				dd		?						;�ļ����
	lpStream				dd		?						;�ļ�ֱ�Ӷ����ڴ���ָ��
	
	;�������ɲ��������д
	nMemoryType			dd		?						
	;�洢������ϸ������ĵ���
	lpText				dd		?						;���ļ�����ȡ���Ĵ��ı����ڴ�ָ�롣������MT_EVERYSTRING�洢�������ѡ��
	lpTextIndex			dd		?						;���ı��ַ���������ָ�롣
	lpStreamIndex		dd		?						;��ѡ��ԭʼ�ű��ַ���������ָ�롣��ΪPOINTERONLY�洢���ͣ�������롣
	nStringType			dd		?						;�ַ����洢���͡�
	nStreamSize			dd		?						;�ļ����ȡ�����ű��༭��ʱ���¡�
	nLine				dd		?						;�ı�������
	nLineLen				dd		?						;��ѡ����ʹ�ö����ַ����洢��������ָʾ�ַ������ȡ������ڴ��ַ������ʹ�á�
	
	;����3��������������д
	bReadOnly			dw		?						;ָ�����ļ��Ƿ�Ϊֻ�����Ƿ����б�����ࣩ
	nCharSet				dd		?						;ָʾ�����ļ����ַ�������Ϊ�����ַ������û������趨�������ɸ����Լ����ж���д��
	
	Reserved				dd		2		dup(?)
_FileInfo ends
ENDIF

;�Ӵ��ھ��
;_Handles struct
;	hWinMain		dd		?
;	hList1			dd		?
;	hList2			dd		?
;	hEdit1			dd		?
;	hEdit2			dd		?
;	hStatus			dd		?
;_Handles ends