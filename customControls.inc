struct comboBox COMBOBOX
	; CBN_DROPDOWN	event comboOpen
	CBN_SELCHANGE event comboChanged
ends

struct editRo EDIT
	EN_SETFOCUS event edit_SetFocus
ends

struct button BUTTON
	BN_CLICKED event ?
ends

proc edit_SetFocus, formLp, paramsLp, controlLp
	virtObj .edit editRo at r8
	@call .edit->hideCur()
	ret
endp