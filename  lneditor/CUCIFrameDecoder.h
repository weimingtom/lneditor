#pragma once
#include "stdafx.h"

class CUCIFrameDecoder:public IWICBitmapFrameDecode,
						public IWICMetadataBlockReader
{
protected:
	int m_nRefCount;
	IWICImagingFactory* m_piImagingFactory;
	IWICComponentFactory* m_piComponentFactory;
public:
	CUCIFrameDecoder();
	virtual ~CUCIFrameDecoder();

	//From IWICBitmapFrameDecode
	STDMETHODIMP GetThumbnail (IWICBitmapSource **ppIThumbnail);
	STDMETHODIMP GetColorContexts (UINT cCount, 
		IWICColorContext **ppIColorContexts,  
		UINT *pcActualCount );
	STDMETHODIMP GetMetadataQueryReader ( IWICMetadataQueryReader
		**ppIMetadataQueryReader );

	// Methods inherited from IWICBitmapSource
	STDMETHODIMP GetSize ( UINT *puiWidth, 
		UINT *puiHeight );
	STDMETHODIMP GetPixelFormat ( WICPixelFormatGUID *pPixelFormat );
	STDMETHODIMP GetResolution ( double *pDpiX, 
		double *pDpiY );
	STDMETHODIMP CopyPixels ( const WICRect *prc, 
		UINT cbStride,
		UINT cbBufferSize, 
		BYTE *pbBuffer );

	//From IWICMetadataBlockReader
	STDMETHODIMP GetContainerFormat ( GUID *pguidContainerFormat );
	STDMETHODIMP GetCount ( UINT *pcCount );
	STDMETHODIMP GetEnumerator ( IEnumUnknown **ppIEnumMetadata );
	STDMETHODIMP GetReaderByIndex ( UINT nIndex,
		IWICMetadataReader **ppIMetadataReader );
};