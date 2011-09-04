/*
Class: CActiveXControl
An ActiveX control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CActiveXControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Insert("Type", "ActiveX")
	}	
	Class CEvents
	{
		__New(GUINum, ControlName)
		{
			this.GUINum := GUINum
			this.ControlName := ControlName
		}
		__Call(Name, Params*)
		{
			global CGUI
			if(ObjHasKey(CGUI.GUIList[this.GUINum].base, this.ControlName "_" Name))
				`(CGUI.GUIList[this.GUINum])[this.ControlName "_" Name](Params*)
		}
	}
	/*
	*/
	__GetEx(ByRef Result, Name, Params*)
	{
		global CGUI
		if(!Base.HasKey(Name))
			If Name not in Base,_,GUINum
			{
				if(base.__GetEx(Result, Name, Params*))
					return true
				if(!CGUI.GUIList[this.GUINum].IsDestroyed)
				{
					DetectHidden := A_DetectHiddenWindows
					DetectHiddenWindows, On
					Value := this._.Object[Name]
					Loop % Params.MaxIndex()
						if(IsObject(Value)) ;Fix unlucky multi parameter __GET
							Value := Value[Params[A_Index]]
					if(!DetectHidden)
						DetectHiddenWindows, Off
					if(Value != "")
						return Value
				}
			}
	}
	__Set(Name, Value, Params*)
	{
		global CGUI
		;~ If Name not in _,GUINum,Type,Options,Text,x,y,width,height,Position,Size,ClassNN,hwnd,Name,Content,Base,Focused,Tooltip
		if(!base.__GetEx(Result, Name, Params*))
			if(!CGUI.GUIList[this.GUINum].IsDestroyed)
			{
				DetectHidden := A_DetectHiddenWindows
				DetectHiddenWindows, On
				Handled := true
				this._.Object[Name] := Value
				if(!DetectHidden)
					DetectHiddenWindows, Off
				if(Handled)
					return Value
			}
	}
	__Call(Name, Params*)
	{
		if Name not in Insert,Remove,HasKey,__GetEx
		{
			if(!ObjHasKey(this.base.base, Name) && !ObjHasKey(this.base, Name))
				`(this._.Object)[Name](Params*)
		}	
	}
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: ActiveXMoved()
	Invoked when the user clicked on the control.
	*/
	HandleEvent(Params*)
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_ActiveXMoved"]))
			`(CGUI.GUIList[this.GUINum])[this.Name "_ActiveXMoved"]()
	}
}