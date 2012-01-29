// UciDecoder.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "CUCIContainerDecoder.h"
#include "ucidecoder_i.c"

// {DDAC4D04-8E0C-40ee-8D22-93F7A5D41A0B}
const GUID GUID_UCI_FORMAT = 
{ 0xddac4d04, 0x8e0c, 0x40ee, { 0x8d, 0x22, 0x93, 0xf7, 0xa5, 0xd4, 0x1a, 0xb } };

CUCIContainerDecoder::CUCIContainerDecoder()
{
	m_nRefCount=0;
	m_piImagingFactory=0;
	HRESULT hr=CoCreateInstance(CLSID_WICImagingFactory,0,CLSCTX_INPROC_SERVER,
		IID_IWICImagingFactory,(LPVOID*)&m_piImagingFactory);
	if(FAILED(hr))
		;
}

CUCIContainerDecoder::~CUCIContainerDecoder()
{
	if(m_piImagingFactory)
		m_piImagingFactory->Release();
}

STDMETHODIMP CUCIContainerDecoder::QueryCapability(
	IStream *pIStream, DWORD *pdwCapability)
{
	ULARGE_INTEGER curPos;
	ULARGE_INTEGER curPos2;
	LARGE_INTEGER offset;
	offset.QuadPart=0;

	//保存当前流位置
	HRESULT hr;
	hr=pIStream->Seek(offset,STREAM_SEEK_CUR,&curPos);
	if(FAILED(hr))
		return hr;

	if(curPos.QuadPart!=0)
	{
		hr=pIStream->Seek(offset,STREAM_SEEK_SET,&curPos2);
		if(FAILED(hr))
			return hr;
	}

	DWORD magic;
	DWORD nBytes;
	hr=pIStream->Read(&magic,4,&nBytes);
	if(FAILED(hr))
		return hr;
	if((magic&0xffffff)!=0x494355)
		*pdwCapability=0;
	else
	{
		BYTE magic2=magic>>24;
		if(magic2=='3' ||
			magic2=='4' ||
			magic2=='T' ||
			magic2=='Q' ||
			magic2=='\x20' ||
			magic2=='\x21' ||
			magic2=='\x40' ||
			magic2=='\x41')
		{
			*pdwCapability=WICBitmapDecoderCapabilitySameEncoder |
							WICBitmapDecoderCapabilityCanDecodeAllImages |
							WICBitmapDecoderCapabilityCanEnumerateMetadata |
							WICBitmapDecoderCapabilityCanDecodeThumbnail;
		}
		else
		{
			*pdwCapability=0;
		}
	}

	//恢复流位置
	offset.QuadPart=curPos.QuadPart;
	hr=pIStream->Seek(offset,STREAM_SEEK_SET,&curPos2);
	if(FAILED(hr))
		return hr;

	return S_OK;
}

STDMETHODIMP CUCIContainerDecoder::Initialize(
	IStream *pIStream, WICDecodeOptions cacheOptions)
{
	return S_OK;
}

STDMETHODIMP CUCIContainerDecoder::GetContainerFormat(
	GUID *pguidContainerFormat)
{
	*pguidContainerFormat=GUID_UCI_FORMAT;
	return S_OK;
}

STDMETHODIMP CUCIContainerDecoder::GetDecoderInfo(
	IWICBitmapDecoderInfo **ppIDecoderInfo)
{
	IWICComponentInfo* pici=0;
	HRESULT hr=m_piImagingFactory->CreateComponentInfo(CLSID_UCIContainterDecoder,&pici);
	if(SUCCEEDED(hr))
	{
		hr=pici->QueryInterface(IID_IWICBitmapDecoderInfo,(LPVOID*)ppIDecoderInfo);
		if(SUCCEEDED(hr))
			hr=S_OK;
		pici->Release();
	}
	return hr;
}

STDMETHODIMP CUCIContainerDecoder::GetFrameCount(UINT *pCount)
{
	*pCount=1;
	return S_OK;
}

STDMETHODIMP CUCIContainerDecoder::GetFrame(
	UINT index, IWICBitmapFrameDecode **ppIBitmapFrame)
{
	return E_FAIL;
}
