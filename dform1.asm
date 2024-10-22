struct dForm1 DIALOGFORM
	@on_colors
	const _cx 			= 125
	const _cy  			= 137
	WM_INITDIALOG 		event dForm1_Init
	WM_TIMER 			event dForm1_Timer
	ringList_dForm2 	RingList
	control gpPort		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", 5, 5, 115, dForm1.btShowPort._ry-dForm1.gpPort._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpPort	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Порт", dForm1.gpPort._rx-dForm1.stGpPort._cx-5, dForm1.gpPort._y-4, 20, 10, WS_VISIBLE or ES_RIGHT
	control cbPort 		comboBox, NONE,\
		"", dForm1.gpPort._x+5, dForm1.gpPort._y+5, 50, 12, CBS_DROPDOWNLIST or WS_VISIBLE or CBS_SORT or WS_TABSTOP
	control btShowPort	button, <btPort_clicked>,\
		"Открыть", dForm1.cbPort._rx+5, dForm1.gpPort._y+5, 50, 12, WS_VISIBLE or WS_GROUP or WS_TABSTOP or BS_DEFPUSHBUTTON
	control gpDesc		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpPort._x, dForm1.gpPort._ry+5, 115, dForm1.edService._ry-dForm1.gpDesc._y+5, WS_VISIBLE or BS_GROUPBOX
	control stGpDesc	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Сведения", dForm1.gpDesc._rx-dForm1.stGpDesc._cx-5, dForm1.gpDesc._y-4, 34, 10, WS_VISIBLE or ES_RIGHT
	control stDesc		STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Описание", dForm1.gpDesc._x+5, dForm1.gpDesc._y+5, 100, 8, WS_VISIBLE
	control edDesc 		editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stDesc._ry, 105, 28, WS_VISIBLE or ES_READONLY or ES_MULTILINE or WS_VSCROLL, WS_EX_STATICEDGE
	control stCreator	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Производитель", dForm1.gpDesc._x+5, dForm1.edDesc._ry, 100, 8, WS_VISIBLE
	control edCreator 	editRo, <WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stCreator._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	control stPhysName	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Физ. имя", dForm1.gpDesc._x+5, dForm1.edCreator._ry, 100, 8, WS_VISIBLE
	control edPhysName 	editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stPhysName._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	control stService	STATIC, <WND.darkThemeColor, 0xFFFFFF>,\
		"Служба", dForm1.gpDesc._x+5, dForm1.edPhysName._ry, 100, 8, WS_VISIBLE
	control edService 	editRo, 	<WND.darkThemeColor, 0xFFFFFF>,\
		"", dForm1.gpDesc._x+5, dForm1.stService._ry, 105, 10, WS_VISIBLE or ES_READONLY, WS_EX_STATICEDGE
	comInfo 			COMInfo
	hIcon				dq ?
	timer 				dq ?
	oldClose 			dq ?
ends

proc_noprologue

proc btPort_clicked uses rbx r12 r13 r14, formLp, paramsLp, controlLp
	virtObj .form dForm1 at rbx
	mov rbx, rcx
	; @call WND:msgBox("Lol", NULL, MB_OK, [.form.hWnd])
	@call .form.cbPort->getTextLen()
	test rax, rax
	jnz .issetPort
		@jret WND:msgBox("COM-порт не выбран!", NULL, MB_OK, [.form.hWnd])
	.issetPort:
	@call CNV:alloc(100)
	mov r12, rax
	@call .form.comInfo->getPortName(r12, 100)
	@call CNV:alloc(sizeof.RingElem_dForm2)
	mov r13, [.form.hIcon]
	lea r14, [.form.ringList_dForm2]
	mov rbx, rax
	virtObj .dfElem RingElem_dForm2 at rbx
	@call CNV:fill(addr .dfElem, <const RingElem_dForm2>, sizeof.RingElem_dForm2)
	mov [.dfElem.dForm.hIcon], r13
	mov [.dfElem.dForm.Text], r12
	mov [.dfElem.dForm.ringElemFormLp], rbx
	mov [.dfElem.dForm.ringListLp], r14
	virtObj .ringList:arg RingList at r14
	@call .ringList->push(addr .dfElem)
	@jret .dfElem.dForm->startNM(NULL)
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
		@call .form.comInfo->choseId(rax)
		@call .form.comInfo->getPortInfo(COMInfo.desc, addr strBuf, 1024)
		@call .form.edDesc->setText(addr strBuf)
		@call .form.comInfo->getPortInfo(COMInfo.MFG, addr strBuf, 1024)
		@call .form.edCreator->setText(addr strBuf)
		@call .form.comInfo->getPortInfo(COMInfo.physName, addr strBuf, 1024)
		@call .form.edPhysName->setText(addr strBuf)
		@call .form.comInfo->getPortInfo(COMInfo.service, addr strBuf, 1024)
		@call .form.edService->setText(addr strBuf)
	.noText:
	ret
endp

; proc enumCallback, hWnd, lparam
; 	locals
; 		strBuf db 1024 dup (?)
; 	endl
; 	mov [lparam], rdx
; 	; @call [GetAncestor](rcx, GA_PARENT)
; 	; test rax, rax
; 	; jz @f
; 	; cmp rax, [lparam]
; 	; je @f
; 		@call [GetWindowTextA](rcx, addr strBuf, 1024)
; 		@call [puts](addr strBuf)
; 	@@:
; 	mov rax, 1
; 	ret
; endp

proc dForm1_close, this, paramsLp
	virtObj .form:arg dForm1
	mov [this], rcx
	mov [paramsLp], rdx
	; @call [GetDesktopWindow]()
	; @call [EnumWindows](enumCallback, rax)
	; @call [SendMessageA](HWND_BROADCAST, WM_BROADCASTCLOSE, 0, 0)
	; @call [puts]("lol")
	; mov rdx, [.form.ringList_dForm2.length]
	; @call [printf](<"%d", 0Ah>, rdx)
	@call RingList:foreach(addr .form.ringList_dForm2, FCallback_dForm1, NULL)
	@jret [.form.oldClose]([this], [paramsLp])
endp

proc FCallback_dForm1 uses rbx rsi, list, elem, paramsLp, index
	mov rbx, rcx
	virtObj .list:arg RingList at rbx
	mov rsi, rdx
	virtObj .elem:arg RingElem_dForm2 at rsi
	@call .list->delete(addr .elem)
	@jret .elem.dForm->close()
endp

proc dForm1_Init uses rbx rsi, formLp, paramsLp
	virtObj .form:arg dForm1 at rbx
	locals 
		stackFrame dq ?
		comStr db 100 dup(?)
	endl
	mov rbx, rcx
	@call WND:getStockIcon(SIID.DRIVERAM)
	mov [.form.hIcon], rax
	@call .form->setIcon(rax)
	@call .form->setCornerType(DWMWCP.DONOTROUND)
	@call .form->setBgColor(WND.darkThemeColor)
	@call .form->setCaptionColor(WND.darkThemeColor)
	mov rax, [.form.WM_CLOSE]
	mov [.form.oldClose], rax
	mov [.form.WM_CLOSE], dForm1_close
	
	; Порт
	@call .form.stGpPort->setBgColor(WND.darkThemeColor)
	@call .form.cbPort->initSubControl()
	@call .form.cbPort->setTheme(addr WND.darkThemeCFD)
	@call .form.cbPort.cListBox->setBgColor(WND.darkThemeColor)
	mov [.form.cbPort.cListBox.txColor], 0xFFFFFF
	
	; Открыть
	@call .form.btShowPort->setTheme(addr WND.darkThemeExplorer)

	; Сведения
	@call .form.stGpDesc->setBgColor(WND.darkThemeColor)

	; Описание
	@call .form.stDesc->setBgColor(WND.darkThemeColor)
	@call .form.edDesc->setTheme(addr WND.darkThemeExplorer)
	@call .form.edDesc->setBgColor(WND.darkThemeColor)

	; Производитель
	@call .form.stCreator->setBgColor(WND.darkThemeColor)
	@call .form.edCreator->setBgColor(WND.darkThemeColor)

	; Физ. имя
	@call .form.stPhysName->setBgColor(WND.darkThemeColor)
	@call .form.edPhysName->setBgColor(WND.darkThemeColor)

	; Служба
	@call .form.stService->setBgColor(WND.darkThemeColor)
	@call .form.edService->setBgColor(WND.darkThemeColor)
	@call .form.comInfo->init()
	cmp [.form.comInfo.countPorts], 0
	je .noPorts
		movzx rsi, [.form.comInfo.countPorts]
		dec rsi
		.fillCombo:
			@call .form.comInfo->choseId(rsi)
			@call .form.comInfo->getPortName(addr comStr, 100)
			@call .form.cbPort->addItem(addr comStr)
			@call .form.cbPort->setItemData(rax, rsi)
		dec rsi
		jns .fillCombo
	.noPorts:
	@call WND:setTimer(100, NULL, 1, [.form.hWnd])
	mov [.form.timer], rax
	ret
endp

proc dForm1_Timer uses rbx, formLp, paramsLp
	virtObj .form:arg dForm1 at rbx
	locals
		comInfo 	COMInfo
		comStr 		db 100 dup (?)
		comboText 	db 100 dup (?)
		cbTextLen	dq ?
		regsBuf 	dq 2 dup(?)
	endl
	mov rbx, rcx
	@call comInfo->init()
	movzx eax, [comInfo.countPorts]
	cmp ax, [.form.comInfo.countPorts]
	je .noUpdate
		mov [regsBuf], rsi
		mov [regsBuf+8], rdi
		@call .form.cbPort->getText(addr comboText, 100)
		mov [cbTextLen], rax
		@call .form.cbPort->clear()
		mov rax, [.form.comInfo.hDevInfoSet]
		xchg rax, [comInfo.hDevInfoSet]
		mov [.form.comInfo.hDevInfoSet], rax
		@call CNV:fill(addr .form.comInfo+8, addr comInfo+8, sizeof.COMInfo-8, FILL_NO_SAVE)
		cmp [.form.comInfo.countPorts], 0
		je .noPorts
			movzx rsi, [.form.comInfo.countPorts]
			dec rsi
			.fillCombo:
				@call .form.comInfo->choseId(rsi)
				@call .form.comInfo->getPortName(addr comStr, 100)
				@call .form.cbPort->addItem(addr comStr)
				@call .form.cbPort->setItemData(rax, rsi)
			dec rsi	
			jns .fillCombo
			cmp [cbTextLen], 0
			je .zeroText
				@call .form.cbPort->findItem(-1, addr comboText)
				mov r8, 0
				cmp eax, CB_ERR
					cmovne r8, rax
				@call .form.cbPort->setSelected(r8)
			.zeroText:
		.noPorts:
		mov rsi, [regsBuf]
		mov rdi, [regsBuf+8]
		@call comboChanged(addr .form)
	.noUpdate:
	@jret comInfo->close()
endp

proc_noprologue

ShblDialog dForm1, "COMCheker", WS_VISIBLE or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or DS_CENTER or DS_SETFONT