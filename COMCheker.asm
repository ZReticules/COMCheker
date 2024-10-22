format pe64 GUI

entry main

stack 0x40000

section ".code" readable writeable executable

include "TOOLS\x64\TOOLS.INC"
include_once "TOOLS\x64\WINUSER\Winuser.inc"
include_once "TOOLS\x64\WINUSER\DialogForm\DialogForm.inc"
include_once "TOOLS\x64\COMPort\COMInfo.inc"
; include_once "TOOLS\x64\cstdio.inc"
include_once "COMIFace.inc"
include_once "encoding\Win1251.inc"
include "RingList.inc"
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
	WaitForSingleObject

proc_noprologue

myForm form dForm1

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