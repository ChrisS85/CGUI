gui := new Explorer()
#include <CGUI>
Class Explorer Extends CGUI
{
	ExplorerLeft := this.AddControl("ActiveX", "ExplorerLeft", "x187 y38 w358 h475", "Shell.Explorer")
	ExplorerRight := this.AddControl("ActiveX", "ExplorerRight", "x551 y38 w352 h475", "Shell.Explorer")
	statusbar := this.AddControl("StatusBar", "statusbar", "w917 h22", "statusStrip1")
	editAddress := this.AddControl("Edit", "editAddress", "x187 y12 w716 h20", "")
	treeFiles := this.AddControl("TreeView", "treeFiles", "x12 y12 w165 h502", "")
	__New()
	{
		this.Title := "Explorer"
		this.Show()
		this.ExplorerLeft.AddressBar := true
		this.ExplorerLeft.Navigate("C:\")
		this.ExplorerRight.Navigate("C:\")
		DriveGet,list,List
		Loop, Parse, list
			this.treeFiles.Items.Add(A_LoopField ":")
	}
	treeFiles_FocusEnter()
	{
		;~ MsgBox Enter
	}
	treeFiles_ItemSelected()
	{
		this.GetActiveView().Navigate(Path := this.BuildPath(this.treeFiles.SelectedItem))
		this.SetAddress(Path)
		for index, node in this.TreeFiles.SelectedItem
			this.TreeFiles.SelectedItem.Remove(node)
		Loop, %Path%\*, 2, 0
			;~ MsgBox % A_LoopFileName
			this.treeFiles.SelectedItem.Add(A_LoopFileName)
	}
	BuildPath(TreeNode)
	{
		while(TreeNode.ID)
		{
			Path := TreeNode.Text "\" Path
			TreeNode := TreeNode.Parent
		}
		return Path
	}
	GetActiveView()
	{
		return this.LastFocus = "SysListView322" ? this.ExplorerRight : this.ExplorerLeft
	}
	OnKeyDown()
	{
		if(A_ThisHotkey = "Enter" && this.ActiveControl.name = "editAddress" && FileExist(this.editAddress.Text))
		{
			this.GetActiveView().Navigate(this.editAddress.Text)
		}
	}
	FocusChange()
	{
		ControlGetFocus, Class, A
		this.StatusBar.Parts[1].Text := "Active: " Class
		if(InStr(Class, "SysListView32"))
		this.LastFocus := Class
	}
	ExplorerLeft_NavigateComplete2(pDisp, URL, Params*)
	{
		ControlGetFocus, Value, % "ahk_id " this.hwnd
		if(Value = "SysListView321")
			this.SetAddress(URL)
	}
	
	ExplorerRight_NavigateComplete2(pDisp, URL, Params*)
	{
		ControlGetFocus, Value, % "ahk_id " this.hwnd
		if(Value = "SysListView322")
			this.SetAddress(URL)
	}
	SetAddress(URL)
	{
		this.editAddress.Text := URL
	}
	WM_KEYDOWN(nMsg, wParam, lParam) 
	{
		MsgBox keydown
	   If  (wParam = 0x09 || wParam = 0x0D || wParam = 0x2E || wParam = 0x26 || wParam = 0x28) ; tab enter delete up down 
	   ;If  (wParam = 9 || wParam = 13 || wParam = 46 || wParam = 38 || wParam = 40) ; tab enter delete up down 
	   { 
		  control := this.ActiveControl
		  ;tooltip % class 
		  If  (control.Type = "ActiveX") 
		  { 
			MsgBox activex
			control.goback()
			 ;~ VarSetCapacity(Msg, 28) 
			 ;~ NumPut(hWnd,Msg), NumPut(nMsg,Msg,4), NumPut(wParam,Msg,8), NumPut(lParam,Msg,12) 
			 ;~ NumPut(A_EventInfo,Msg,16), NumPut(A_GuiX,Msg,20), NumPut(A_GuiY,Msg,24) 
			 ;~ DllCall(NumGet(NumGet(1*pipaun)+20), "Ptr", pipaun, "Ptr", &Msg) 
			 Return 0 
		  } 
	   } 
	}
	PreClose()
	{
		ExitApp
	}
}

#If WinActive("Explorer ahk_class AutoHotkeyGUI")
BackSpace::
Enter::
RerouteHotkey()
return

RerouteHotkey()
{
	hwnd := WinExist("A")
	for name, GUI in CGUI.GUIList
		if(GUI.hwnd = hwnd)
			GUI.OnKeyDown()
}