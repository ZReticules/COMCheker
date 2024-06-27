struct dForm1 DIALOGFORM
	WM_INITDIALOG 		event dForm1_Init
	WM_TIMER 			event dForm1_Timer
	control gpPort		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", 5, 5, 115, dForm1.btShowPort._ry-dForm1.gpPort._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpPort	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpPort._rx-dForm1.stGpPort._cx-5, dForm1.gpPort._y-4, 18, 10, WS_VISIBLE or ES_RIGHT
	control cbPort 		comboBox, <NONE, NONE, comboChanged>,\
		"", dForm1.gpPort._x+5, dForm1.gpPort._y+5, 50, 12, CBS_DROPDOWNLIST or WS_VISIBLE or CBS_SORT or WS_TABSTOP or BS_DEFPUSHBUTTON
	control btShowPort	button, <NONE, NONE, btPort_clicked>,\
		"", dForm1.cbPort._rx+5, dForm1.gpPort._y+5, 50, 12, WS_VISIBLE or WS_GROUP or WS_TABSTOP
	control gpDesc		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpPort._x, dForm1.gpPort._ry+5, 115, dForm1.edService._ry-dForm1.gpDesc._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpDesc	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._rx-dForm1.stGpDesc._cx-5, dForm1.gpDesc._y-4, 34, 10, WS_VISIBLE or ES_RIGHT
	control stDesc		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.gpDesc._y+5, 100, 8, WS_VISIBLE
	control edDesc 		editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stDesc._ry, 105, 28, WS_VISIBLE or ES_READONLY or ES_MULTILINE or WS_VSCROLL, WS_EX_STATICEDGE
	control stCreator	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.edDesc._ry, 100, 8, WS_VISIBLE
	control edCreator 	editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stCreator._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	control stPhysName	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.edCreator._ry, 100, 8, WS_VISIBLE
	control edPhysName 	editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stPhysName._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	control stService	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.edPhysName._ry, 100, 8, WS_VISIBLE
	control edService 	editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stService._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	form subForm 		dForm2
	timer 				dq ?
	oldClose 			dq ?
ends

proc_noprologue

proc btPort_clicked uses rbx, formLp, paramsLp, controlLp
	virtObj .form dForm1 at rbx
	mov rbx, rcx
	cmp [.form.subForm.hWnd], NULL
	je .noActiveForm
		@call .form.subForm->close()
	.noActiveForm:
	@call .form.cbPort->getTextLen()
	test rax, rax
	jnz .issetPort
		@call WND:msgBox([.form.hWnd], "COM-порт не выбран!", NULL, NULL)
		ret
	.issetPort:
	lea rcx, [.form.subForm]
	xor rdx, rdx
	sub rsp, 20h
	pop rbx
	jmp dForm1.Table.startNM
endp

proc comboChanged uses rbx, formLp, paramsLp, controlLp
	virtObj .form:arg dForm1 at rbx
	locals 
		strBuf 	db 1024 dup(?)
	endl
	mov rbx, rcx
	@call .form.cbPort->getText(addr strBuf, 1024)
	test rax, rax
	jnz .hasText
		@call .form.edDesc->setText(NULL)
		@call .form.edPhysName->setText(NULL)
		@call .form.edCreator->setText(NULL)
		@call .form.edService->setText(NULL)
	jmp .noText
	.hasText:
		@call .form.cbPort->getSelected()
		@call .form.cbPort->getItemData(rax)
		@call .form.subForm.comInfo->choseId(rax)
		@call .form.subForm.comInfo->getPortInfo(COMInfo.desc, addr strBuf, 1024)
		@call .form.edDesc->setText(addr strBuf)
		@call .form.subForm.comInfo->getPortInfo(COMInfo.MFG, addr strBuf, 1024)
		@call .form.edCreator->setText(addr strBuf)
		@call .form.subForm.comInfo->getPortInfo(COMInfo.physName, addr strBuf, 1024)
		@call .form.edPhysName->setText(addr strBuf)
		@call .form.subForm.comInfo->getPortInfo(COMInfo.service, addr strBuf, 1024)
		@call .form.edService->setText(addr strBuf)
	.noText:
	ret
endp

proc dForm1_close, this, paramsLp
	virtObj .form:arg dForm1
	cmp [.form.subForm.hWnd], NULL
	je .noActiveForm
		mov [this], rcx
		mov [paramsLp], rdx
		@call .form.subForm->close()
		mov rcx, [this]
		mov rdx, [paramsLp]
	.noActiveForm:
	add rsp, 28h
	jmp [.form.oldClose]
endp

proc dForm1_Init uses rbx rsi, formLp, paramsLp
	virtObj .form:arg dForm1 at rbx
	locals 
		stackFrame dq ?
		comStr db 1024 dup(?)
		brush dq ?
		winRect RECT
		winHDC dq ?
	endl
	mov rbx, rcx
	@call .form->setText("COMCheker")
	@call WND:getStockIcon(SIID.DRIVERAM)
	mov [.form.subForm.hIcon], rax
	@call .form->setIcon(rax)
	@call .form->setCornerType(DWMWCP.DONOTROUND)
	@call .form->setBgColor(WND.darkThemeColor)
	@call .form->setCaptionColor(WND.darkThemeColor)
	mov rax, [.form.WM_CLOSE]
	mov [.form.oldClose], rax
	mov [.form.WM_CLOSE], dForm1_close
	@call .form.stGpPort->setText("Порт")
	@call .form.stGpPort->setBgColor(WND.darkThemeColor)
	@call .form.cbPort->initSubControl()
	@call .form.cbPort->setTheme(addr WND.darkThemeCFD)
	@call .form.cbPort.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbPort.cListBox.txColor], 0xFFFFFF
	@call .form.btShowPort->setText("Открыть")
	@call .form.btShowPort->setTheme(addr WND.darkThemeExplorer)
	@call .form.stGpDesc->setText("Сведения")
	@call .form.stGpDesc->setBgColor(WND.darkThemeColor)
	@call .form.stDesc->setText("Описание")
	@call .form.stDesc->setBgColor(WND.darkThemeColor)
	@call .form.edDesc->setTheme(addr WND.darkThemeExplorer)
	@call .form.edDesc->setBgColor(WND.darkThemeColor)
	@call .form.stCreator->setText("Производитель")
	@call .form.stCreator->setBgColor(WND.darkThemeColor)
	@call .form.edCreator->setBgColor(WND.darkThemeColor)
	@call .form.stPhysName->setText("Физ. имя")
	@call .form.stPhysName->setBgColor(WND.darkThemeColor)
	@call .form.edPhysName->setBgColor(WND.darkThemeColor)
	@call .form.stService->setText("Служба")
	@call .form.stService->setBgColor(WND.darkThemeColor)
	@call .form.edService->setBgColor(WND.darkThemeColor)
	@call .form.subForm.comInfo->init()
	cmp [.form.subForm.comInfo.countPorts], 0
	je .noPorts
		movzx rsi, [.form.subForm.comInfo.countPorts]
		dec rsi
		.fillCombo:
			@call .form.subForm.comInfo->choseId(rsi)
			@call .form.subForm.comInfo->getPortName(addr comStr, 1024)
			@call .form.cbPort->addItem(addr comStr)
			@call .form.cbPort->setItemData(rax, rsi)
		dec rsi
		jns .fillCombo
	.noPorts:
	@call WND:setTimer([.form.hWnd], 1, 100, NULL)
	mov [.form.timer], rax
	ret
endp

proc dForm1_Timer uses rbx rsi rdi, formLp, paramsLp
	virtObj .form:arg dForm1 at rbx
	locals
		comInfo 	COMInfo
		comStr 		db 1024 dup (?)
		comboText 	db 1024 dup (?)
		cbTextLen	dq ?
	endl
	mov rbx, rcx
	@call comInfo->init()
	mov ax, [comInfo.countPorts]
	cmp ax, [.form.subForm.comInfo.countPorts]
	je .noUpdate
		@call .form.cbPort->getText(addr comboText, 1024)
		mov [cbTextLen], rax
		@call .form.cbPort->clear()
		mov rax, [.form.subForm.comInfo.hDevInfoSet]
		mov rcx, sizeof.COMInfo
		lea rsi, [comInfo]
		lea rdi, [.form.subForm.comInfo]
		rep movsb
		mov [comInfo.hDevInfoSet], rax
		cmp [.form.subForm.comInfo.countPorts], 0
		je .noPorts
			movzx rsi, [.form.subForm.comInfo.countPorts]
			dec rsi
			.fillCombo:
				@call .form.subForm.comInfo->choseId(rsi)
				@call .form.subForm.comInfo->getPortName(addr comStr, 1024)
				@call .form.cbPort->addItem(addr comStr)
				@call .form.cbPort->setItemData(rax, rsi)
			dec rsi	
			jns .fillCombo
			cmp [cbTextLen], 0
			je .zeroText
				@call .form.cbPort->findItem(-1, addr comboText)
				mov rdx, 0
				cmp eax, CB_ERR
				cmovne rdx, rax
				@call .form.cbPort->setSelected(rdx)
			.zeroText:
		.noPorts:
		@call comboChanged(addr .form)
	.noUpdate:
	@call comInfo->close()
	ret
endp

proc_noprologue

ShblDialog dForm1, 0, 0, 125, 137, NONE, WS_VISIBLE or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or DS_CENTER