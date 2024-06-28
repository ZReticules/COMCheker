format pe64 GUI

entry main

stack 0x40000

include "TOOLS\TOOLS.INC"
include_once "TOOLS\WINUSER\Winuser.inc"
include_once "TOOLS\COMPort\COMInfo.inc"
include_once "COMIFace.inc"
include "customControls.inc"
include "dForm2.asm"
include "dForm1.asm"

	importlib kernel32,\
		CreateFileA,\
		CloseHandle,\
		GetLastError,\
		CreateThread,\
		TerminateThread,\
		SetCommMask,\
		CreateEventA,\
		SetThreadPriority,\
		WaitForSingleObject,\
		VirtualAlloc,\
		VirtualFree


section ".code" readable writeable executable
	
	form myForm dForm1
	
	proc_noprologue

	proc main
		@call myForm->startNM(NULL)
		.msgLoop:
			@call myForm->dispatchMessages()
		test eax, eax
		jnz .msgLoop
		ret
	endp

	data resource
		directory 	RT_MANIFEST, manifests

		resource 	manifests,\ 
	           1, LANG_ENGLISH or SUBLANG_DEFAULT, manifest

		resdata manifest
			db 	'<assembly xmlns="urn:schemas-microsoft-com:asm.v3" manifestVersion="1.0">'
			db 		'<dependency>'
			db 			'<dependentAssembly>'
			db 				'<assemblyIdentity '
			db 					'type="win32" ' 
			db 					'name="Microsoft.Windows.Common-Controls" '
			db 					'version="6.0.0.0" '
			db 					'processorArchitecture="*" '
			db 					'publicKeyToken="6595b64144ccf1df" '
			db 					'language="*" ' 
			db 				'/>'
			db 			'</dependentAssembly>'
			db 		'</dependency>'
			db 	'</assembly>'
		endres
	end data