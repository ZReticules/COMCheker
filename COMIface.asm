importlib kernel32,\
	CreateFileA,\
	CloseHandle,\
	ClearCommError,\
	PurgeComm,\
	ReadFile,\
	GetCommState,\
	SetCommState,\
	SetCommTimeouts,\
	WaitCommEvent,\
	SetupComm,\
	WriteFile

importlib msvcrt,\
	atoi

define PURGE_RXCLEAR 	8
define PURGE_TXCLEAR 	4
define EV_BREAK			0x0040
define EV_CTS			0x0008
define EV_DSR			0x0010
define EV_ERR			0x0080
define EV_RING			0x0100
define EV_RLSD			0x0020
define EV_RXCHAR		0x0001
define EV_RXFLAG		0x0002
define EV_TXEMPTY		0x0004
; endp

proc COMIface.openA uses rbx r12, this, portStrLp
	.portStrLp equ r12
	virtObj .this:arg COMIface at rbx
	mov rbx, rcx
	mov rcx, rdx
	mov .portStrLp, rdx
	@call [CreateFileA](rcx, GENERIC_READ or GENERIC_WRITE, NULL, NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL)
	cmp rax, INVALID_HANDLE_VALUE
	jne @f
		mov rax, 0
		mov [.this.handle], 0
		jmp .return
	@@:
	mov [.this.handle], rax
	@call [atoi](addr .portStrLp+7)
	mov [.this.portNum], eax
	.return: ret
endp

if used COMIface.close
	COMIface.close:;, this
		virtObj .this:arg COMIface
		mov rcx, [.this.handle]
		jmp [CloseHandle]
end if

if used COMIface.updStat
	COMIface.updStat:;, this
		virtObj .this:arg COMIface
		lea r8, [.this.comstat]
		xor rdx, rdx
		mov rcx, [.this.handle]
		jmp [ClearCommError];([.this.handle], NULL, r8)
end if

if used COMIface.updStat
	COMIface.reset:;, this
		virtObj .this:arg COMIface
		mov edx, PURGE_RXCLEAR or PURGE_TXCLEAR
		mov rcx, [.this.handle]
		jmp [PurgeComm];([.this.handle], PURGE_RXCLEAR or PURGE_TXCLEAR)
end if

proc COMIface.read, this, bufLp, cBytes, overlappedLp
	virtObj .this:arg COMIface
	local readLen:QWORD
	mov [readLen], r9
	@call [ReadFile]([.this.handle], rdx, r8, addr readLen, [readLen])
	mov rax, [readLen]
	ret
endp

proc COMIface.write, this, bufLp, cBytes, overlappedLp
	virtObj .this:arg COMIface
	local writeLen:QWORD
	mov [writeLen], r9
	@call [WriteFile]([.this.handle], rdx, r8, addr writeLen, [writeLen])
	mov rax, [writeLen]
	ret
endp

if used COMIface.getParams
	COMIface.getParams:;, this
		virtObj .this:arg COMIface
		lea rdx, [.this.dcb]
		mov rcx, [.this.handle]
		jmp [GetCommState];([.this.handle], [.this.dcb])
end if

if used COMIface.setParams
	COMIface.setParams:;, this
		virtObj .this:arg COMIface
		lea rdx, [.this.dcb]
		mov rcx, [.this.handle]
		jmp [SetCommState];([.this.handle], [.this.dcb])
end if

if used COMIface.setTimeouts
	COMIface.setTimeouts:;, this
		virtObj .this:arg COMIface
		lea rdx, [.this.timeouts]
		mov rcx, [.this.handle]
		jmp [SetCommTimeouts];([.this.handle], [.this.timeouts])
end if

if used COMIface.setup
	COMIface.setup:;, InQueue, OutQueue
		virtObj .this:arg COMIface
		mov rcx, [.this.handle]
		jmp [SetupComm];([.this.handle], rdx, r8)
end if

; importlib Advapi32,\
; 	RegOpenKeyExA,\
; 	RegCloseKey,\
; 	RegQueryInfoKeyA,\
; 	RegEnumValueA

; proc getEnabledPorts uses rbx r12 r13 r14 r15 rsi rdi, arrayLp
; 	locals 
; 		hKey dq ?
; 		countValues dq ?
; 		maxValueNameLen dq 0
; 		maxValueLen dq 0
; 		stackFrame dq ?
; 		typeParam dq ?
; 	endl
; 	mov rbx, rcx
; 	label .arr byte at rbx
; 	@call [RegOpenKeyExA](HKEY_LOCAL_MACHINE, "HARDWARE\DEVICEMAP\SERIALCOMM\", 0, KEY_READ, addr hKey)
; 	test rax, rax
; 	jz .noOpenErr
; 		@call [puts]("Open error!")
; 		mov eax, 0
; 		jmp .return
; 	.noOpenErr:
; 	@call [RegQueryInfoKeyA]([hKey], NULL, NULL, NULL, NULL, NULL, NULL, addr countValues, addr maxValueNameLen, addr maxValueLen, NULL, NULL)
; 	test rax, rax
; 	jz .noInfoErr
; 		@call [puts]("Get info error!")
; 	.noInfoErr:
; 	inc [maxValueNameLen]
; 	inc [maxValueLen]
; 	stackAlloc r12, [maxValueNameLen], [stackFrame]
; 	stackAlloc r13, [maxValueLen]
; 	and rsp, -16
; 	mov rsi, [maxValueLen]
; 	mov rdi, [maxValueNameLen]
; 	mov r14, [countValues]
; 	.getValues:
; 		mov [maxValueLen], rsi
; 		mov [maxValueNameLen], rdi;hkey, i, bufferName, &NameLen, NULL, &type, (LPBYTE)bufferData, &DataLen
; 		@call [RegEnumValueA]([hKey], addr r14 - 1, r12, addr maxValueNameLen, NULL, addr typeParam, r13, addr maxValueLen)
; 		test rax, rax
; 		jz .noEnumErr
; 			@call [printf]("Get Enum value error - %d", rax)
; 			jmp .continue
; 		.noEnumErr:
; 		cmp [typeParam], REG_SZ
; 			jne .continue
; 		@call [printf](<"%s - %s", 0Ah>, r12, r13)
; 		.continue:
; 	dec r14
; 	jne .getValues
; 	@call [RegCloseKey]([hKey])
; 	mov rsp, [stackFrame]
; 	.return:ret
; endp