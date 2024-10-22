struct DCB
	DCBlength 	dd ?
	BaudRate 		dd ?
	flags 			dd ?
	; DWORD fBinary:1; // binary mode, no EOF check
	; DWORD fParity:1; // enable parity checking
	; DWORD fOutxCtsFlow:1; // CTS output flow control
	; DWORD fOutxDsrFlow:1; // DSR output flow control
	; DWORD fDtrControl:2; // DTR flow control type
	; DWORD fDsrSensitivity:1; // DSR sensitivity
	; DWORD fTXContinueOnXoff:1; // XOFF continues Tx
	; DWORD fOutX:1; // XON/XOFF out flow control
	; DWORD fInX:1; // XON/XOFF in flow control
	; DWORD fErrorChar:1; // enable error replacement
	; DWORD fNull:1; // enable null stripping
	; DWORD fRtsControl:2; // RTS flow control
	; DWORD fAbortOnError:1; // abort reads/writes on error
	; DWORD fDummy2:17; // reserved
	wReserved		dw ?
	XonLim			dw ?
	XoffLim			dw ?
	ByteSize		db ?
	Parity			db ?
	StopBits		db ?
	XonChar			db ?
	XoffChar		db ?
	ErrorChar		db ?
	EofChar			db ?
	EvtChar			db ?
	wReserved1	dw ?
ends

struct COMSTAT
  ; DWORD fCtsHold : 1;
  ; DWORD fDsrHold : 1;
  ; DWORD fRlsdHold : 1;
  ; DWORD fXoffHold : 1;
  ; DWORD fXoffSent : 1;
  ; DWORD fEof : 1;
  ; DWORD fTxim : 1;
  ; DWORD fReserved : 25;
  	flags 		dd ?
	cbInQue		dd ?
	cbOutQue	dd ?
ends

struct COMMTIMEOUTS 
	ReadIntervalTimeout			dd ?
	ReadTotalTimeoutMultiplier	dd ?
	ReadTotalTimeoutConstant	dd ?
	WriteTotalTimeoutMultiplier	dd ?
	WriteTotalTimeoutConstant	dd ?
ends

struct OVERLAPPED
	Internal			dq 0
	InternalHigh		dq 0
	union 
		struct
			Offset		dd 0
			OffsetHigh	dd 0
		ends
		Pointer 		dq ?
	ends
	hEvent 				dq 0
ends

struct COMIface
	portNum 	dd ?
	handle 		dq ?
	dcb 		DCB
	comstat		COMSTAT
	timeouts 	COMMTIMEOUTS
	; open 		dm this
	; openN		dm this
	openA 		dm this
	close 		dm this:inline
	updStat 	dm this:inline
	reset 		dm this:inline
	read 		dm this
	getParams	dm this:inline
	setParams 	dm this:inline
	setTimeouts dm this:inline
	setup 		dm this:inline
	write 		dm this
ends

macro COMIface.close this{
	@call [CloseHandle]([this#.handle])
}

macro COMIface.updStat this{
	local _this
	inlineObj _this, this, rcx
	@call [ClearCommError]([_this+COMIface.handle], NULL, addr _this+COMIface.comstat)
}

macro COMIface.reset this{
	local _this
	inlineObj _this, this, rcx
	@call [PurgeComm]([_this+COMIface.handle], PURGE_RXCLEAR or PURGE_TXCLEAR)
}

macro COMIface.getParams this{
	local _this
	inlineObj _this, this, rcx
	@call [GetCommState]([_this+COMIface.handle], addr this+COMIface.dcb)
}

macro COMIface.setParams this{
	local _this
	inlineObj _this, this, rcx
	@call [SetCommState]([_this+COMIface.handle], addr this+COMIface.dcb)
}

macro COMIface.setTimeouts this{
	local _this
	inlineObj _this, this, rcx
	@call [SetCommTimeouts]([_this+COMIface.handle], [this+COMIface.timeouts])
}

macro COMIface.setup this, dwInQueue, dwOutQueue{
	local _this
	inlineObj _this, this, rcx
	@call [SetupComm]([_this+COMIface.handle], dwInQueue, dwOutQueue)
}

include "COMIFace.asm"