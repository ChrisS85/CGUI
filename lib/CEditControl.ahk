/*
Class: CEditControl
An edit control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CEditControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Edit"
		this._.Insert("ControlStyles", {Center : 0x1, LowerCase : 0x10, Number : 0x2000, Multi : 0x4, Password : 0x20, ReadOnly : 0x800, Right : 0x2, Uppercase : 0x8, WantReturn : 0x1000})
		this._.Insert("Events", ["TextChanged"])
	}
	AddUpDown(Min, Max)
	{
		WM_USER := 0x0400 
		UDM_SETBUDDY := WM_USER + 105
		Gui, % this.GUINum ":Add", UpDown, -16 Range%Min%-%Max% hwndhUpDown, % this.Text
		hwnd := this.hwnd
		SendMessage, UDM_SETBUDDY, hwnd, 0,, % "ahk_id " hwnd
		this._.UpDownHwnd := hUpDown
		this._.Min := Min
		this._.Max := Max
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			if(Name = "Text" && this._.UpDownHwnd)
				GuiControlGet, Value, % this.GUINum ":", % this.ClassNN
		}
		if(Value)
			return Value
	}
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: TextChanged()
	Invoked when the text of the control is changed.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_TextChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_TextChanged"]()
		}
	}
}