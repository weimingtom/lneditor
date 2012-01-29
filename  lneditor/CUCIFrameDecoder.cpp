#include "stdafx.h"
#include "CUCIFrameDecoder.h"

extern const GUID GUID_UCI_FORMAT;

CUCIFrameDecoder::CUCIFrameDecoder()
{
	m_nRefCount=0;
	m_piImagingFactory=0;
	HRESULT hr=CoCreateInstance(CLSID_WICImagingFactory,0,CLSCTX_INPROC_SERVER,
		IID_IWICImagingFactory,(LPVOID*)&m_piImagingFactory);
	if(SUCCEEDED(hr))
	{
		hr=((IUnknown*)m_piImagingFactory)->QueryInterface(
		IID_IWICComponentFactory,(LPVOID*)&m_piComponentFactory);
		if(SUCCEEDED(hr))
			return;
	}
	//Ê§°Ü´¦Àí£¿
}

CUCIFrameDecoder::~CUCIFrameDecoder()
{
	if(m_piImagingFactory)
		m_piImagingFactory->Release();
}

STDMETHODIMP CUCIFrameDecoder::GetThumbnail(IWICBitmapSource **ppIThumbnail)
{
	return E_NOTIMPL;
}

STDMETHODIMP CUCIFrameDecoder::GetColorContexts(
	UINT cCount, IWICColorContext **ppIColorContexts, UINT *pcActualCount)
{
	return E_NOTIMPL;
}

STDMETHODIMP CUCIFrameDecoder::GetMetadataQueryReader(
	IWICMetadataQueryReader **ppIMetadataQueryReader)
{
	return E_NOTIMPL;
}

STDMETHODIMP CUCIFrameDecoder::GetSize(UINT *puiWidth, UINT *puiHeight)
{

}