/*
Class: CPictureControl
A picture control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CPictureControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Picture"
		this._.Picture := Text
		this._.Insert("ControlStyles", {Center : 0x200, ResizeImage : 0x40})
		this._.Insert("Events", ["Click", "DoubleClick"])
	}
	
	/*
	Variable: Picture
	The picture can be changed by assigning a filename to this property.
	*/
	__Get(Name) 
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Picture")
				Value := this._.Picture
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	
	__Set(Name, Value)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Picture")
			{
				Gui, % this.GUINum ":Default"
				GuiControl,, % this.ClassNN, %Value%
				this._.Picture := Value
			}
			else
				Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
		}
	}
	/*
	Function: SetImageFromHBitmap
	Sets the image of this control.
	
	Parameters:
		hBitamp - The bitmap handle to which the picture of this control is set
	*/
	SetImageFromHBitmap(hBitmap)
	{
		SendMessage, 0x172, 0x0, hBitmap,, % "ahk_id " this.hwnd
		DllCall("gdi32\DeleteObject", "PTR", ErrorLevel)
	}
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click()
	Invoked when the user clicked on the control.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		func := A_GUIEvent = "DoubleClick" ? "_DoubleClick" : "_Click"
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name func]()
		}
	}
}