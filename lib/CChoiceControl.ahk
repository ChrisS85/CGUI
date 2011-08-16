/*
Class: CChoiceControl
This class implements DropDownList, ComboBox and ListBox controls.
*/
Class CChoiceControl Extends CControl ;This class is a ComboBox, ListBox and DropDownList
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		if(Type = "Combobox")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100, Simple : 0x1})
		else if(Type = "DropDownList")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100})
		else if(Type = "ListBox")
			this._.Insert("ControlStyles", {Multi : 0x800, ReadOnly : 0x4000, Sort : 0x2, ToggleSelection : 0x8})
		this._.Insert("Events", ["SelectionChanged"])
		this._.Items := new this.CItems(GUINum, Name)
	}
	/*
	Variable: SelectedItem
	The text of the selected item.
	
	Variable: SelectedIndex
	The index of the selected item.
	
	Variable: Items
	An array containing all items. See <CChoiceControl.CItems>.
	*/
	__Get(Name, Params*)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "SelectedItem")
				ControlGet, Value, Choice,,,% "ahk_id " this.hwnd
			else if(Name = "SelectedIndex")
			{
				SendMessage, 0x147, 0, 0,,% "ahk_id " this.hwnd
				Value := ErrorLevel + 1
			}
			else if(Name = "Items")
				Value := this._.Items
			;~ else if(Name = "Items")
			;~ {
				;~ ControlGet, List, List,,, % " ahk_id " this.hwnd
				;~ Value := Array()
				;~ Loop, Parse, List, `n
					;~ Value.Insert(A_LoopField)			
			;~ }
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedItem")
			{
				Items := this.Items
				Loop % Items.MaxIndex()
					if(Items[A_Index] = Value)
						Control, Choose, %A_Index%,,% "ahk_id " this.hwnd
			}
			else if(Name = "SelectedIndex" && Value >= 1)
				Control, Choose, %Value%,,% "ahk_id " this.hwnd
			else if(Name = "Items" && !Params[1])
			{
				Items := this.Items
				if(!IsObject(Value))
				{
					if(InStr(Value, "|") = 1) ;Overwrite current items
						Items := []
					Loop, Parse, Value,|
						if(A_LoopField)
							Items.Insert(A_LoopField)
				}
				else
				{
					Items := []
					Loop % Value.MaxIndex()
						Items.Insert(Value[A_Index])
				}
				ItemsString := ""
				Loop % Items.MaxIndex()
					ItemsString .= "|" Items[A_Index]
				GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				if(!IsObject(Value) && InStr(Value, "||"))
				{
					if(RegExMatch(Value, "(?:^|\|)(..*?)\|\|", SelectedItem))
						Control, ChooseString, %SelectedItem1%,,% "ahk_id " this.hwnd
				}
			}
			else if(Name = "Items" && Params[1] > 0)
			{
				this._.Items[Params[1]] := Value
				;~ msgbox should not be here
				;~ Items := this.Items
				;~ Items[Params[1]] := Value
				;~ ItemsString := ""
				;~ Loop % Items.MaxIndex()
					;~ ItemsString .= "|" Items[A_Index]
				;~ SelectedIndex := this.SelectedIndex
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ GuiControl, % this.GUINum ":Choose", % this.ClassNN, %SelectedIndex%
			}
			else if(Name = "Text" && this.Type != "DropDownList")
				Handled := false ;Do nothing
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
	
	Event: SelectionChanged(TabIndex)
	Invoked when the selection was changed.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_SelectionChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_SelectionChanged"]()
		}
	}
	/*
	Class CChoiceControl.CItems
	An array containing all items of the control.
	*/
	Class CItems
	{
		__New(GUINum, ControlName)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.ControlName := ControlName
		}
		
		/*
		Variable: 1,2,3,4,...
		Individual items can be accessed by their index.
		
		Variable: Count
		The number of items in this control.
		*/		
		__Get(Name)
		{
			global CGUI
			if Name is Integer
			{
				if(Name <= this.MaxIndex())
				{
					DetectHidden := A_DetectHiddenWindows
					DetectHiddenWindows, On
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI[this._.ControlName]
					ControlGet, List, List,,, % " ahk_id " Control.hwnd
					Loop, Parse, List, `n
						if(A_Index = Name)
						{
							Value := A_LoopField
							break
						}
					if(!DetectHidden)
						DetectHiddenWindows, Off
					return Value
				}
			}
			else if(Name = "Count")
				return this.MaxIndex()
		}
		__Set(Name, Value)
		{
			global CGUI
			if Name is Integer
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI[this._.ControlName]
				ItemsString := ""
				SelectedIndex := Control.SelectedIndex
				for index, item in this
					ItemsString .= "|" (index = Name ? Value : this[A_Index])
				GuiControl, % this._.GUINum ":", % Control.ClassNN, %ItemsString%
				GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, %SelectedIndex%
				return Value
			}
		}
		/*
		Function: MaxIndex()
		Returns the number of items in this control.
		*/
		MaxIndex()
		{
			global CGUI
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI[this._.ControlName]
			ControlGet, List, List,,, % " ahk_id " Control.hwnd
			count := 0
			Loop, Parse, List, `n
				count++
			if(!DetectHidden)
				DetectHiddenWindows, Off
			return count
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
	}
}