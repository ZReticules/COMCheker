WM_COMM = WM_USER+5

struct dForm2 DIALOGFORM
	WM_INITDIALOG 		event dForm2_Init
	WM_COMM				event dForm2_ComIn
	WM_TIMER 			event dform2_Timer
	hIcon				dq ?
	comInfo 			COMInfo
	comIface			COMIface
	baudRates			dd 75, 110, 134, 150, 300, 600, 1200, 1800, 2400, 4800, 7200, 9600, 14400, 19200, 38400, 57600, 115200, 128000
	thread				dq ?
	event				dq ?
	oldClose 			dq ?
	outStatus			db 0
	o 					OVERLAPPED
	timer 				dq ?
	control gpStngs		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", 5, 5, dForm2.btSvParams._rx-dForm2.gpStngs._x+5, dForm2.btSvParams._ry-dForm2.gpStngs._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpStngs	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpStngs._rx-dForm2.stGpStngs._cx-5, dForm2.gpStngs._y-4, 38, 10, WS_VISIBLE or ES_RIGHT
	control stBaud		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpStngs._x+5, dForm2.gpStngs._x+5, 50, 8, WS_VISIBLE
	control cbBaud 		comboBox, <NONE, NONE>,\
	 	"", dForm2.stBaud._x, dForm2.stBaud._ry, 55, 12, CBS_DROPDOWNLIST or WS_VISIBLE or WS_TABSTOP
	control stByteSize	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.cbBaud._rx+5, dForm2.stBaud._y, 55, 8, WS_VISIBLE
	control cbByteSize 	comboBox, <NONE, NONE, dform2_cbBaud_changed>,\
	 	"", dForm2.stByteSize._x, dForm2.stByteSize._ry, 55, 12, CBS_DROPDOWNLIST or WS_VISIBLE or WS_TABSTOP
	control stParity	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.cbByteSize._rx+5, dForm2.stBaud._y, 55, 8, WS_VISIBLE
	control cbParity 	comboBox, <NONE, NONE>,\
	 	"", dForm2.stParity._x, dForm2.stParity._ry, 55, 12, CBS_DROPDOWNLIST or WS_VISIBLE or WS_TABSTOP
	control stStopBits	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.cbParity._rx+5, dForm2.stBaud._y, 55, 8, WS_VISIBLE
	control cbStopBits 	comboBox, <NONE, NONE>,\
	 	"", dForm2.stStopBits._x, dForm2.stStopBits._ry, 55, 12, CBS_DROPDOWNLIST or WS_VISIBLE or WS_TABSTOP
 	control btSvParams	button, <NONE, NONE, dform2_btSvParams_clicked>,\
 		"", dForm2.cbStopBits._x, dForm2.cbStopBits._ry+5, 55, 12, WS_VISIBLE
	control gpIn		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpStngs._x, dForm2.gpStngs._ry+5, dForm2.gpStngs._cx, dForm2.btClearIn._ry-dForm2.gpIn._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpIn	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpIn._rx-dForm2.stGpIn._cx-5, dForm2.gpIn._y-4, 23, 10, WS_VISIBLE or ES_RIGHT
	control edIn		editRo, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpIn._x+5, dForm2.gpIn._y+5, dForm2.gpIn._cx-10, 60, WS_VISIBLE or ES_READONLY or ES_MULTILINE or WS_VSCROLL, WS_EX_STATICEDGE
 	control btPauseIn	button, <NONE, NONE, dform2_btPauseIn_clicked>,\
 		"", dForm2.gpIn._x+5, dForm2.edIn._ry+5, 55, 12, WS_VISIBLE
 	control btClearIn	button, <NONE, NONE, dform2_btClearIn_clicked>,\
 		"", dForm2.edIn._rx-dForm2.btClearIn._cx, dForm2.edIn._ry+5, 55, 12, WS_VISIBLE
	control gpOut		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpIn._x, dForm2.gpIn._ry+5, dForm2.btOutData._rx-dForm2.edOut._x+10, dForm2.edOut._cy+10, WS_VISIBLE or BS_GROUPBOX
	control stGpOut	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpOut._rx-dForm2.stGpOut._cx-5, dForm2.gpOut._y-4, 18, 10, WS_VISIBLE or ES_RIGHT
	control edOut		EDIT, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm2.gpOut._x+5, dForm2.gpOut._y+5, dForm2.cbParity._rx-dForm2.edOut._x, 29, WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or ES_WANTRETURN, WS_EX_STATICEDGE
 	control btOutData	button, <NONE, NONE, dform2_btOutData_clicked>,\
 		"", dForm2.edOut._rx+5, dForm2.gpOut._y+5, 55, 12, WS_VISIBLE
ends

proc_noprologue
proc dform2_Timer, formLp, paramsLp
	virtObj .form:arg dForm2
	local cxBuf:QWORD
	mov [cxBuf], rcx
	@call .form.comIface->updStat()
	mov rcx, [cxBuf]
	test rax, rax
	jnz .noErr
		add rsp, 28h
		jmp dForm2.Table.close
	.noErr:
	ret
endp

proc dform2_cbBaud_changed, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	local cxBuf:QWORD
	mov [cxBuf], rcx
	@call .form.cbBaud->getSelected()
	mov rcx, [cxBuf]
	mov eax, [.form.baudRates+rax*4]
	mov [.form.comIface.dcb.BaudRate], eax
	ret
endp

proc dform2_cbParity_changed, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	local cxBuf:QWORD
	mov [cxBuf], rcx
	@call .form.cbParity->getSelected()
	mov rcx, [cxBuf]
	mov [.form.comIface.dcb.Parity], al
	ret
endp

proc dform2_cbByteSize_changed, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	local cxBuf:QWORD
	mov [cxBuf], rcx
	@call .form.cbByteSize->getSelected()
	mov rcx, [cxBuf]
	add al, 4
	mov [.form.comIface.dcb.ByteSize], al
	ret
endp

proc dform2_cbStopBits_changed, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	local cxBuf:QWORD
	mov [cxBuf], rcx
	@call .form.cbStopBits->getSelected()
	mov rcx, [cxBuf]
	mov [.form.comIface.dcb.StopBits], al
	ret
endp

proc dform2_btSvParams_clicked uses rbx, formLp, paramsLp
	virtObj .form:arg dForm2 at rbx
	mov rbx, rcx
	@call .form.comIface->setParams()
	ret
endp

proc dform2_btOutData_clicked uses rbx r12, formLp, paramsLp
	virtObj .form:arg dForm2 at rbx
	.dynMem equ r12
	local textLen:QWORD
	@call .form.edOut->getTextLen()
	mov [textLen], rax
	inc [textLen]
	@call [VirtualAlloc](NULL, addr eax+6, MEM_COMMIT, PAGE_READWRITE)
	mov .dynMem, rax
	@call .form.edOut->getText(.dynMem, [textLen])
	dec [textLen]
	@call .form.comIface->write(.dynMem, [textLen], addr .form.o)
	mov rcx, .dynMem
	xor rdx, rdx
	mov r8, MEM_RELEASE
	add rsp, 28h
	pop r12 rbx
	jmp [VirtualFree]
endp

proc dform2_btPauseIn_clicked, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	virtObj .button:arg button at r8
	xor [.form.outStatus], 1
	movzx rax, [.form.outStatus]
	@call .button->setText(addr .textButton+rax*8)
	ret
	.textButton:
		db "Стоп"
		dd 0
		db "Продолжить", 0
endp

proc dform2_btClearIn_clicked, formLp, paramsLp, controlLp
	virtObj .form:arg dForm2
	@call .form.edIn->setText("")
	ret
endp

proc dForm2_close uses rbx r12, this, paramsLp
	virtObj .form:arg dForm2 at rbx
	.params equ r12
	mov rbx, rcx
	mov .params, rdx
	@call [TerminateThread]([.form.thread], 0)
	@call [CloseHandle]([.form.event])
	@call .form.comIface->close()
	@call [SetCommMask]([.form.comIface.handle], 0)
	virtObj .formJump:arg dForm2
	lea rcx, [.form]
	mov rdx, .params
	add rsp, 28h
	pop r12 rbx
	jmp [.formJump.oldClose]
	restore .params
endp

proc dForm2_ComIn uses rbx r12, formLp, paramsLp
	virtObj .form:arg dForm2 at rbx
	virtObj .params:arg params at r12
	mov rbx, rcx
	mov r12, rdx
	cmp [.params.lparam], 0
	jne .noError
		@call .form->close()
	.noError:
	test [.form.outStatus], 1
	jnz .noAdd
		@call .form.edIn->addText([.params.wparam])
	.noAdd:
	mov rcx, [.params.wparam]
	xor rdx, rdx
	mov r8, MEM_RELEASE
	add rsp, 28h
	pop r12 rbx
	jmp [VirtualFree]
endp

proc ThreadProc, lpParam
	locals
		 comIface 	COMIface
		 lenMem 	dd ?
		 o OVERLAPPED
		 flags dq 0
	endl
	.hWnd equ rbx
	mov [lpParam], rcx
	mov .hWnd, [rcx]
	mov rax, [rcx+8]
	mov [comIface.handle], rax
	mov rax, [rcx+16]
	mov [o.hEvent], rax
	@call [SetCommMask]([comIface.handle], EV_RXCHAR)
	@@:
		@call [WaitCommEvent]([comIface.handle], addr flags, addr o)
		@call [WaitForSingleObject]([o.hEvent], -1)
		@call comIface->updStat()
		test rax, rax
		jnz .noErr
			@call [SendMessageA](.hWnd, WM_COMM, 0, 0)
			jmp $
		.noErr:
		cmp [comIface.comstat.cbInQue], 0
		je .noPrint
			.mem equ r12
			mov eax, [comIface.comstat.cbInQue]
			mov [lenMem], eax
			@call [VirtualAlloc](NULL, addr eax+6, MEM_COMMIT, PAGE_READWRITE)
			mov .mem, rax
			@call comIface->read(addr .mem, [lenMem], addr o)
			@call [WaitForSingleObject]([o.hEvent], -1)
			@call [SendMessageA](.hWnd, WM_COMM, .mem, 1)
			restore .mem
		.noPrint:
	jmp @b
	restore .hWnd
endp
proc_resprologue

proc dForm2_Init uses rbx, formLp, paramsLp
	virtObj .form:arg dForm2 at rbx
	locals
		conPref		dd "\\.\"
		strBuf 		db 1024 dup(?)
		._bszNums 	dd ?
	endl
	mov rbx, rcx
	frame
	@call .form.comInfo->getPortName(addr strBuf, 1024)
	@call .form.comIface->openA(addr conPref)
	test rax, rax
	jnz .noErr
		@call WND:msgBox([.form.hWnd],"Ошибка открытия порта", NULL, NULL)
		@call .form->close()
		jmp .return
	.noErr:
	@call .form.comIface->getParams()
	mov [.form.comIface.dcb.BaudRate], 9600
	@call .form.comIface->setParams()
	; mov [.form.comIface.timeouts.ReadIntervalTimeout], 0
	; mov [.form.comIface.timeouts.ReadTotalTimeoutMultiplier], 0
	; mov [.form.comIface.timeouts.ReadTotalTimeoutConstant], 0
	; mov [.form.comIface.timeouts.WriteTotalTimeoutMultiplier], 0
	; mov [.form.comIface.timeouts.WriteTotalTimeoutConstant], 0
	; @call .form.comIface->setTimeouts()
	@call .form.comIface->reset()
	mov rax, [.form.WM_CLOSE]
	mov [.form.oldClose], rax
	mov [.form.WM_CLOSE], dForm2_close
	@call .form->setText(addr strBuf)
	@call .form->setCornerType(DWMWCP.DONOTROUND)
	@call .form->setBgColor(WND.darkThemeColor)
	@call .form->setCaptionColor(WND.darkThemeColor)
	@call .form->setIcon([.form.hIcon])
	@call .form.stGpStngs->setText("Параметры")
	@call .form.stGpStngs->setBgColor(WND.darkThemeColor)
	@call .form.stBaud->setText("Бит в секунду")
	@call .form.stBaud->setBgColor(WND.darkThemeColor)
	@call .form.cbBaud->initSubControl()
	@call .form.cbBaud->setTheme(addr WND.darkThemeCFD)
	@call .form.cbBaud.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbBaud.cListBox.txColor], 0xFFFFFF
	@call .form.cbBaud->addItem("75")
	@call .form.cbBaud->addItem("110")
	@call .form.cbBaud->addItem("134")
	@call .form.cbBaud->addItem("150")
	@call .form.cbBaud->addItem("300")
	@call .form.cbBaud->addItem("600")
	@call .form.cbBaud->addItem("1200")
	@call .form.cbBaud->addItem("1800")
	@call .form.cbBaud->addItem("2400")
	@call .form.cbBaud->addItem("4800")
	@call .form.cbBaud->addItem("7200")
	@call .form.cbBaud->addItem("9600")
	@call .form.cbBaud->addItem("14400")
	@call .form.cbBaud->addItem("19200")
	@call .form.cbBaud->addItem("38400")
	@call .form.cbBaud->addItem("57600")
	@call .form.cbBaud->addItem("115200")
	@call .form.cbBaud->addItem("128000")
	@call .form.cbBaud->setSelected(11)
	mov [.form.cbBaud.CBN_SELCHANGE], dform2_cbBaud_changed
	@call .form.stByteSize->setText("Биты данных")
	@call .form.stByteSize->setBgColor(WND.darkThemeColor)
	@call .form.cbByteSize->initSubControl()
	@call .form.cbByteSize->setTheme(addr WND.darkThemeCFD)
	@call .form.cbByteSize.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbByteSize.cListBox.txColor], 0xFFFFFF
	mov [._bszNums], "4"
	.fillcbByteSize:
		@call .form.cbByteSize->addItem(addr ._bszNums)
		inc [._bszNums]
	cmp [._bszNums], "8"
	jle .fillcbByteSize
	movzx rax, [.form.comIface.dcb.ByteSize]
	@call .form.cbByteSize->setSelected(addr rax-4)
	mov [.form.cbByteSize.CBN_SELCHANGE], dform2_cbByteSize_changed
	@call .form.stParity->setText("Чётность")
	@call .form.stParity->setBgColor(WND.darkThemeColor)
	@call .form.cbParity->initSubControl()
	@call .form.cbParity->setTheme(addr WND.darkThemeCFD)
	@call .form.cbParity.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbParity.cListBox.txColor], 0xFFFFFF
	@call .form.cbParity->addItem("Нет")
	@call .form.cbParity->addItem("Нечет")
	@call .form.cbParity->addItem("Чёт")
	@call .form.cbParity->addItem("Маркер")
	@call .form.cbParity->addItem("Пробел")
	movzx rax, [.form.comIface.dcb.Parity]
	@call .form.cbParity->setSelected(rax)
	mov [.form.cbParity.CBN_SELCHANGE], dform2_cbParity_changed
	@call .form.stStopBits->setText("Стоповые биты")
	@call .form.stStopBits->setBgColor(WND.darkThemeColor)
	@call .form.cbStopBits->initSubControl()
	@call .form.cbStopBits->setTheme(addr WND.darkThemeCFD)
	@call .form.cbStopBits.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbStopBits.cListBox.txColor], 0xFFFFFF
	@call .form.cbStopBits->addItem("1")
	@call .form.cbStopBits->addItem("1.5")
	@call .form.cbStopBits->addItem("2")
	movzx rax, [.form.comIface.dcb.StopBits]
	@call .form.cbStopBits->setSelected(rax)
	mov [.form.cbStopBits.CBN_SELCHANGE], dform2_cbStopBits_changed
	@call .form.btSvParams->setText("Применить")
	@call .form.btSvParams->setTheme(addr WND.darkThemeExplorer)
	@call .form.stGpIn->setText("Вывод")
	@call .form.stGpIn->setBgColor(WND.darkThemeColor)
	@call .form.edIn->setTheme(addr WND.darkThemeExplorer)
	@call .form.edIn->setBgColor(WND.darkThemeColor)
	@call .form.btPauseIn->setText(dform2_btPauseIn_clicked.textButton)
	@call .form.btPauseIn->setTheme(addr WND.darkThemeExplorer)
	@call .form.btClearIn->setText("Очистить")
	@call .form.btClearIn->setTheme(addr WND.darkThemeExplorer)
	@call .form.edOut->setTheme(addr WND.darkThemeExplorer)
	@call .form.edOut->setBgColor(WND.darkThemeColor)
	@call .form.stGpOut->setText("Ввод")
	@call .form.stGpOut->setBgColor(WND.darkThemeColor)
	@call .form.btOutData->setText("Отправить")
	@call .form.btOutData->setTheme(addr WND.darkThemeExplorer)
	mov rax, [.form.hWnd]
	mov [.hWnd], rax
	mov rax, [.form.comIface.handle]
	mov [.cHandle], rax
	@call [CreateEventA](NULL, 1, 0, NULL)
	mov [.form.event], rax
	mov [.event], rax
	mov [.form.o], rax
	@call [CreateThread](NULL, NULL, ThreadProc, .threadParams, 0, 0)
	mov [.form.thread], rax
	@call [SetThreadPriority](rax, THREAD_PRIORITY_TIME_CRITICAL)
	@call WND:setTimer([.form.hWnd], 1, 100, NULL)
	mov [.form.timer], rax
	.return:
	endf
	ret

	.threadParams:
		.hWnd 		dq ?
		.cHandle 	dq ?
		.event  	dq ?
endp

ShblDialog dForm2, 0, 0, 255, 200, NONE, WS_VISIBLE or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or DS_CENTER