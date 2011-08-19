/*
Class: CTextControl
A static text control that can also be used as hyperlink.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CTextControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Text"
		this._.Insert("ControlStyles", {Center : 0x1, Left : 0, Right : 0x2, Wrap : -0xC})
		this._.Insert("Events", ["Click", "DoubleClick"])
	}
	/*
	Variable: Link
	If true, the control will appear like a hyperlink. To react to a click, implement the Click() event.
	*/
	__Set(Name, Value)
	{
		if(Name = "Link")
		{
			WM_SETCURSOR := 0x20
			WM_MOUSEMOVE := 0x200
			WM_NCMOUSELEAVE := 0x2A2
			WM_MOUSELEAVE := 0x2A3
			if(Value)
			{
				OnMessage(WM_SETCURSOR, "CGUI.HandleMessage")
				OnMessage(WM_MOUSEMOVE, "CGUI.HandleMessage")
			}
			this._.Link := Value > 0
			this.Font.Options := "cBlue"
		}
	}
	__Get(Name)
	{
		if(Name = "Link")
			return this._.Link
	}
	HandleMessage(wParam, lParam, msg)
	{
		static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_NCMOUSELEAVE := 0x2A2, WM_MOUSELEAVE := 0x2A3
		static   URL_hover, h_cursor_hand, CtrlIsURL, LastCtrl
		if(!this.Link)
			return
		If (msg = WM_SETCURSOR)
		{
			tooltip setcursor
			If(this._.Hovering)
				Return true
		}
		Else If (p_m = WM_MOUSEMOVE)
		{
			; Mouse cursor hovers URL text control
			If URL_hover=
			{
				Gui, 1:Font, cBlue underline
				GuiControl, 1:Font, %A_GuiControl%
				LastCtrl = %A_GuiControl%

				h_cursor_hand := DllCall("LoadCursor", "Ptr", 0, "uint", 32649, "Ptr")

				URL_hover := true
			}
			this._.h_old_cursor := DllCall("SetCursor", "Ptr", h_cursor_hand, "Ptr")
			; Mouse cursor doesn't hover URL text control
			;~ Else
			;~ {
				;~ If URL_hover
				;~ {
					;~ Gui, 1:Font, norm cBlue
					;~ GuiControl, 1:Font, %LastCtrl%

					;~ DllCall("SetCursor", "Ptr", h_old_cursor)

					;~ URL_hover=
				;~ }
			;~ }
		}
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
		if(A_GUIEvent = "DoubleClick")
		{
			if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_DoubleClick"]))
			{
				ErrorLevel := ErrLevel
				`(CGUI.GUIList[this.GUINum])[this.Name "_DoubleClick"]()
			}
		}
		else
		{
			if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_Click"]))
			{
				ErrorLevel := ErrLevel
				`(CGUI.GUIList[this.GUINum])[this.Name "_Click"]()
			}
		}
	}
}