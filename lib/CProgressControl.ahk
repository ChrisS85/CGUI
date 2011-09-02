/*
Class: CProgressControl
A Progress control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CProgressControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Progress"
		this._.Insert("ControlStyles", {Vertical : 0x4, Smooth : 0x1, Marquee : 0x8})
		;TODO: Range in options is not parsed but could potentially be set by the user
		this._.Insert("Min", 0)
		this._.Insert("Max", 100)
	}	
	
	/*
	Variable: Position
	The position of the progress indicator. Relative offsets are possible by adding a sign when assigning it, i.e. Progress.Position := "+10". Progress.Position += 10 is also possible but less efficient.
	
	Variable: Min
	The minimum value of the progress indicator.
	
	Variable: Max
	The maximum value of the progress indicator.
	*/
	__Get(Name, Params*)
	{
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Position")
				GuiControlGet, Value, % this.GUINum ":", % this.ClassNN
			else if(Name = "Min")
				Value := this._.Min
			else if(Name = "Max")
				Value := this._.Max
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
			if(Name = "Position")
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
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
}