/*
Class: CActiveXControl
An ActiveX control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.

Variable: Accessing the properties of the ActiveX object
The specific properties of the ActiveX control can simply be accessed through this control object as if it were the ActiveX object itself.
However if you need to access the ActiveX object directly you can do so by using Control._.Object .
*/
Class CActiveXControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Insert("Type", "ActiveX")
	}
	PostCreate()
	{
		;Acquire COM Object and connect its events with this instance
		GuiControlGet, object, % this.GUINum ":", % this.ClassNN
		this._.Object := object
		this._.Events := new this.CEvents(this.GUINum, this.Name, this.hwnd)
		ComObjConnect(object, this._.Events)
	}
	Class CEvents
	{
		__New(GUINum, ControlName, hwnd)
		{
			this.GUINum := GUINum
			this.ControlName := ControlName
			this.hwnd := hwnd
		}
		__Call(Name, Params*)
		{
			;~ global CGUI
			CGUI.GUIList[this.GUINum].Controls[this.hwnd].CallEvent(Name, Params*)
			;~ if(ObjHasKey(CGUI.GUIList[this.GUINum].base, this.ControlName "_" Name))
				;~ `(CGUI.GUIList[this.GUINum])[this.ControlName "_" Name](Params*)
		}
	}
	/*
	*/
	__GetEx(ByRef Result, Name, Params*)
	{
		;~ global CGUI
		if(!Base.HasKey(Name))
			If Name not in Base,_,GUINum
			{
				if(base.__GetEx(Result, Name, Params*))
					return true
				if(!CGUI.GUIList[this.GUINum].IsDestroyed)
				{
					DetectHidden := A_DetectHiddenWindows
					DetectHiddenWindows, On
					if(this.IsMemberOf(Name))
					{
						Value := this._.Object[Name]
						Loop % Params.MaxIndex()
							if(IsObject(Value)) ;Fix unlucky multi parameter __GET
								Value := Value[Params[A_Index]]
					}
					if(!DetectHidden)
						DetectHiddenWindows, Off
					if(Value != "")
						return Value
				}
			}
	}
	__Set(Name, Value, Params*)
	{
		;~ global CGUI
		;~ If Name not in _,GUINum,Type,Options,Text,x,y,width,height,Position,Size,ClassNN,hwnd,Name,Content,Base,Focused,Tooltip
		if(!base.__GetEx(Result, Name, Params*))
			if(!CGUI.GUIList[this.GUINum].IsDestroyed)
			{
				DetectHidden := A_DetectHiddenWindows
				DetectHiddenWindows, On
				if(this.IsMemberOf(Name))
				{
					;~ Handled := true
					Error := ComObjError()
					ComObjError(false)
					this._.Object[Name] := Value
					Handled := true
					ComObjError(Error)
					if(A_LastError)
						Value := 0
				}
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
	Function: IsMemberOf
	Checks if the ActiveX object supports a parameter. This does not check if it is read/write/call-able.
	Thanks to jethrow, Lexikos and Sean for this function!
	
	Parameters:
		name - the parameter to check for.
	*/
	IsMemberOf(name) {
	   out := DllCall(NumGet(NumGet(1*p:=ComObjUnwrap(this._.Object))+A_PtrSize*5), "Ptr",p, "Ptr",VarSetCapacity(iid,16,0)*0+&iid, "Ptr*",&name, "UInt",1, "UInt",1024, "Int*",dispID)=0 && dispID+1
	   ObjRelease(p)
	   return out
	}
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases. 
	You can look up the definitions of the parameters in the documentation of the ActiveX control.
	ActiveX controls do not require a separate G-label to make the events work.
	*/
	;~ HandleEvent(Params*)
	;~ {
		;~ global CGUI
		;~ if(CGUI.GUIList[this.GUINum].IsDestroyed)
			;~ return
		;~ if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_ActiveXMoved"]))
			;~ `(CGUI.GUIList[this.GUINum])[this.Name "_ActiveXMoved"]()
	;~ }
}