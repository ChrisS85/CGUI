/*
Class: CGroupBoxControl
A GroupBox control. Nothing special.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CGroupBoxControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "GroupBox"
		this.Insert("_", {})
		this._.Insert("Controls", {})
		;No styles here for now, why would you want them?
	}
	/*
	Function: AddControl
	Adds a control to this groupbox. The parameters correspond to the Add() function of CGUI, but the coordinates are relative to the GroupBox.
	
	Parameters:
		Type - The type of the control.
		Name - The name of the control.
		Options - Options used for creating the control. X and Y coordinates are relative to the GroupBox.
		Text - The text of the control.
	*/
	AddControl(type, Name, Options, Text)
	{
		;~ global CGUI
		GUI := CGUI.GUIList[this.GUINum]
		Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
		Control.hParentControl := this.hwnd
		return Control
	}
}