/*
Class: CSliderControl
A Slider control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CSliderControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Slider"
		this._.Insert("ControlStyles", {Vertical : 0x2, Left : 0x4, Center : 0x8, AutoTicks : 0x1, Thick : 0x40, NoThumb : 0x80, NoTicks : 0x10, Tooltips : 0x100})
		;TODO: Range in options is not parsed but could potentially be set by the user
		this._.Insert("Min", 0)
		this._.Insert("Max", 100)
		this._.Insert("Invert", InStr(Options, "Invert"))
	}	
	
	/*
	Variable: Value
	The value of the Slider control. Relative offsets are possible by adding a sign when assigning it, i.e. Slider.Value := "+10". Slider.Value += 10 is also possible but less efficient.
	
	Variable: Min
	The minimum value of the Slider control.
	
	Variable: Max
	The maximum value of the Slider control.
	*/
	__Get(Name, Params*)
	{
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Value")
				GuiControlGet, Value, % this.GUINum ":", % this.ClassNN
			else if(Name = "Min")
				Value := this._.Min
			else if(Name = "Max")
				Value := this._.Max
			else if(Name = "Invert")
				Value := this._.Invert
			else if(Name = "Line")
				Value := this._.Line
			else if(Name = "Page")
				Value := this._.Page
			else if(Name = "TickInterval")
				Value := this._.TickInterval
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value, Params*)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Value")
				GuiControl, % this.GUINum ":", % this.ClassNN, %Value%
			else if(Name = "Min")
			{
				GuiControl, % this.GUINum ":+Range" Value "-" this._.Max, % this.ClassNN
				this._.Min := Value
			}
			else if(Name = "Max")
			{
				GuiControl, % this.GUINum ":+Range" this._.Min "-" Value, % this.ClassNN
				this._.Max := Value
			}
			else if(Name = "Line")
			{
				GuiControl, % this.GUINum ":+Line" Value, % this.ClassNN
				this._.Line := Value
			}
			else if(Name = "Page")
			{
				GuiControl, % this.GUINum ":+Page" Value, % this.ClassNN
				this._.Page := Value
			}
			else if(Name = "TickInterval")
			{
				GuiControl, % this.GUINum ":+TickInterval" Value, % this.ClassNN
				this._.TickInterval := Value
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
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	Instead of using ControlName_EventName() you may also call <CControl.RegisterEvent()> on a control instance to register a different event function name.
	
	Event: SliderMoved()
	Invoked when the user clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("SliderMoved")
	}
}