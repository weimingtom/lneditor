#include "stdafx.h"

class CUCIContainerDecoder:public IWICBitmapDecoder
{
protected:
	int m_nRefCount;
	IWICImagingFactory* m_piImagingFactory;
public:
	CUCIContainerDecoder();
	virtual ~CUCIContainerDecoder();

	//IWICBitmapDecoder
	STDMETHODIMP QueryCapability(IStream *pIStream, DWORD *pdwCapability);
	STDMETHODIMP Initialize(IStream *pIStream, WICDecodeOptions cacheOptions);
	STDMETHODIMP GetContainerFormat(GUID *pguidContainerFormat);
	STDMETHODIMP GetDecoderInfo(IWICBitmapDecoderInfo **ppIDecoderInfo);
	STDMETHODIMP GetFrameCount(UINT *pCount);
	STDMETHODIMP GetFrame(UINT index, IWICBitmapFrameDecode **ppIBitmapFrame);
	
};