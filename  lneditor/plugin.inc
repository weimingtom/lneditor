;Return Information of GetText
RI_SUC_LINEONLY			EQU		1	;�ı�����ȡ���ڴ��У���Ҫ�����������ӵ��б�����
RI_SUC_LISTADDED		EQU		2	;�ı������ӵ��б�����
RI_SUC_THLINE			EQU		3	;�Ѵ����̸߳����ı���ȡ���ڴ��У������������д�����Ӧ��Ϣ�������ӵ��б���
RI_SUC_THLIST			EQU		4	;�Ѵ����̸߳����ı����ӵ��б����У������������д���������Ϣ

RI_FAIL_FORMAT			EQU		10	;��ʽ����
RI_FAIL_MEM				EQU		11	;�ڴ����
RI_FAIL_CODE				EQU		12	;���봦������
RI_FAIL_UNK				EQU		13	;δ֪����

;Match Result
MR_YES					EQU		5
MR_MAYBE				EQU		3
MR_NO					EQU		0
MR_ERR					EQU		-1

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
	;�ӽű�����ȡ�����ı������ִ洢��ʽ��һ����ʹ�ö����ַ��������ţ�һ����ʹ�������ڴ�ռ�䳤�ַ������飬����Ƕ����ڴ�ռ��ַ�����
	lpText				dd		?						;���ļ�����ȡ���Ĵ��ı����ڴ�ָ�롣������MT_EVERYSTRING�洢�������ѡ��
	lpTextIndex			dd		?						;���ı��ַ���������ָ�롣
	lpStreamIndex		dd		?						;��ѡ��ԭʼ�ű��ַ���������ָ�롣
	nStreamSize			dd		?						;�ļ����ȡ������ű��༭��ʱ���¡�
	nLine				dd		?						;�ı�������
	nLineLen				dd		?						;��ѡ����ʹ�ö����ַ����洢��������ָʾ�ַ������ȡ������ڴ��ַ������ʹ�á�
	
	;����3��������������д
	bReadOnly			dw		?						;ָ�����ļ��Ƿ�Ϊֻ�����Ƿ����б�����ࣩ
	bFirstCreate			dw		?						;ָʾ���ļ��Ƿ�Ϊ��һ�δ���
	nCharSet				dd		?						;ָʾ���ڲ�ʹ�õĺ����ַ�����-1Ϊ�ɲ�����������ǲ����������д
	
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