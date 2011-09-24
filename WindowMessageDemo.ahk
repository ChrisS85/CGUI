SetBatchlines, -1
MyWindow := new CWindowMessageDemo() ;Create an instance of this window class
MySecondWindow := new CWindowMessageDemo() ;Create a second instance of this window class
return

#include <CGUI>
Class CWindowMessageDemo Extends CGUI
{
	txtX 		:= this.AddControl("Text", "txtX", "x10", "X:")
	editX 	:= this.AddControl("Edit", "editX", "x+10", "")
	txtY		:= this.AddControl("Text", "txtY", "x10", "Y:")
	editY	:= this.AddControl("Edit", "editY", "x+10", "")
	__New()
	{
		this.Title := "Window message demo"
		this.Resize := true
		this.MinSize := "400x300"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		this.OnMessage(0x200, "MouseMove")
		this.Show("")
		return this
	}
	MouseMove(Msg, wParam, lParam)
	{
		this.editX.text := lParam & 0xFFFF
		this.editY.text := (lParam & 0xFFFF0000) >> 16
		return 0
	}
	editX_Leave()
	{
		tooltip editX leave
	}
}