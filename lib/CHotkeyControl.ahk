/*
Class: CHotkeyControl
A Hotkey control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CHotkeyControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Hotkey"
	}
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: HotkeyChanged()
	Invoked when the user clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("HotkeyChanged")
	}
}