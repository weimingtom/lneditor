// dllmain.cpp : ���� DLL Ӧ�ó������ڵ㡣
#include "stdafx.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

HRESULT WINAPI DllGetClassObject(__in REFCLSID rclsid, __in REFIID riid, __deref_out LPVOID FAR* ppv)
{
	return E_FAIL;
}

HRESULT WINAPI DllUnregisterServer()
{
	return E_FAIL;
}

HRESULT WINAPI DllRegisterServer()
{
	return E_FAIL;
}

HRESULT WINAPI DllCanUnloadNow(BOOL fLock)
{
	return NOERROR;
}