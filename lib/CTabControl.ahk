/*
Class: CTabControl
A tab container control. The controls added to a tab panel can be accessed through this object.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CTabControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Tab"
		this._.Insert("ControlStyles", {Bottom : 0x2, HotTrack : 0x40, Buttons : 0x100, MultiLine : 0x200})
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
	}
	
	PostCreate()
	{
		this._.Insert("ImageListManager", new this.CImageListManager(this.GUINum, this.hwnd))
		this._.Tabs := new this.CTabs(this.GUINum, this.hwnd)
		Content := this.Content
		Loop, Parse, Content, |
			this._.Tabs._.Insert(new this.CTabs.CTab(A_LoopField, A_Index, this.GUINum, this.hwnd))
	}
	/*
	Variable: Tabs
	A list of all tabs. Each tab contains a list of controls that belong to it. The returned object is of type <CTabControl.CTabs>
	
	Variable: Text
	The text of the first tab.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Tabs")
			Value := this._.Tabs
		else if(Name = "Text")
			Value := this._.Tabs[1].Text
		if(Params.MaxIndex() >= 1 && IsObject(value)) ;Fix unlucky multi parameter __GET
		{
			Value := Value[Params[1]]
			if(Params.MaxIndex() >= 2 && IsObject(value))
				Value := Value[Params[2]]
		}
		if(Value != "")
			return Value
	}
	__Set(Name, Params*)
	{
		Value := Params[Params.MaxIndex()]
		Params.Remove(Params.MaxIndex())
		if(Name = "Text") ;Assign text -> assign text of first Tab
		{
			this._.Tabs[1].Text := Value
			return true
		}
		if(Name = "Tabs") ;Assign all Tabs at once
		{
			if(Params[1] >= 1 && Params[1] <= this._.Tabs.MaxIndex()) ;Set a single Tab
			{
				if(IsObject(Value)) ;Set an object
				{
					this._.Tabs[Params[1]].Text := Value.Text
					;Maybe do this later when icons are available?
					;~ Tab := new this.CTabs.CTab(Value.HasKey("Text") ? Value.Text : "", Params[1], this.GUINum, this.Name)					
					;~ this._.Tabs._.Remove(Params[1])
					;~ this._.Tabs._.Insert(Params[1], Tab)
				}
				else ;Just set text directly
					this._Tabs[Params[1]].Text := Value
				return Value
			}
			return 0
		}
	}
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click(TabIndex)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(TabIndex)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(TabIndex)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(TabIndex)
	Invoked when the user double-right-clicked on the control.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		Mapping := {Normal : "_Click", DoubleClick : "_DoubleClick", Right : "_RightClick", R : "_DoubleRightClick"}
		func := this.Name Mapping[A_GuiEvent]
		if(IsFunc(CGUI.GUIList[this.GUINum][func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[func](A_EventInfo)
		}
	}
	/*
	Class: CTabControl.CTabs
	An array of tabs.
	*/
	Class CTabs
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.hwnd := hwnd
		}
		/*
		Variable: 1,2,3,4,...
		Individual tabs can be accessed by their index.
		*/
		__Get(Name, Params*)
		{
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1)
						return this._[Name][Params*]
					else						
						return this._[Name]
				}
			}
		}
		/*
		Function: MaxIndex()
		Returns the number of tabs.
		*/
		MaxIndex()
		{
			return this._.MaxIndex()
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this._)
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1) ;Set a property of CTab
					{
						Tab := this._[Name]
						Tab[Params*] := Value
					}
					return Value
				}
			}
		}
		
		/*
		Function: Add()
		Adds a tab.
		
		Parameters:
			Text - The text of the new tab.
			
		Returns:
			An object of type <CTabControl.CTabs.CTab>.
		*/
		Add(Text)
		{
			global CGUI
			Tabs := []
			Loop, Parse, Text, |
			{
				Tab := new this.CTab(A_loopField, this._.MaxIndex() + 1, this.GUINum, this.hwnd)
				this._.Insert(Tab)
				Tabs.Insert(Tab)
				Control := CGUI.GUIList[this.GUINum][this.hwnd]
				GuiControl, % this.GUINum ":", % Control.ClassNN, %A_loopField%
			}
			return Tabs.MaxIndex() > 1 ? Tabs : Tabs[1]
		}
		
		;Removing tabs is unsupported for now because the controls will not be removed
		;~ Remove(TabNumber)
		;~ {
		;~ }
		
		/*
		Class: CTabControl.CTabs.CTab
		A single tab object.
		*/
		Class CTab
		{
			__New(Text, TabNumber, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.TabNumber := TabNumber
				this._.GUINum := GUINum
				this._.hwnd := hwnd
				this._.Controls := {}
			}
			
			/*
			Function: AddControl()
			Adds a control to this tab. The parameters correspond to the Add() function of CGUI.
			
			Parameters:
				Type - The type of the control.
				Name - The name of the control.
				Options - Options used for creating the control.
				Text - The text of the control.
			*/
			AddControl(type, Name, Options, Text)
			{
				global CGUI
				if(type != "Tab")
				{
					GUI := CGUI.GUIList[this.GUINum]
					Gui, % this.GUINum ":Tab", % this._.TabNumber
					Control := GUI.Add(type, Name, Options, Text)
					this._.Controls.Insert(Name, Control)
					Gui, % this.GUINum ":Tab"
					return Control
				}
				else
					Msgbox Tabs may not be added in a tab container.
			}
			/*
			Variable: Text
			The text of the tab.
			
			Variable: Icon
			The filename of the icon associated with this tab.
			
			Variable: IconNumber
			The index of the icon in a multi-icon file.
			*/
			__Get(Name, Params*)
			{
				if(Name != "_" && this._.HasKey(Name))
					Value := this._[Name]
				Loop % Params.MaxIndex()
					if(IsObject(Value)) ;Fix unlucky multi parameter __GET
						Value := Value[Params[A_Index]]
				if(Value)
					return Value
			}
			__Set(Name, Value)
			{
				global CGUI
				if(Name = "Text")
				{
					Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
					Tabs := ""
					for index, Tab in Control.Tabs
						if(index != this._.TabNumber)
							Tabs .= "|" Tab.Text
						else
							Tabs .= "|" Value
					this._[Name] := Value
					GuiControl, % this.GUINum ":", % Control.ClassNN, %Tabs%
					return Value
				}
				else if(Name = "Icon")
				{
					this.SetIcon(Value, this.IconNumber ? this.IconNumber : 1)
					return Value
				}
				else if(Name = "IconNumber")
				{
					this.IconNumber := Value
					if(this.Icon)
						this.SetIcon(this.Icon, Value)
					return Value
				}
			}
			/*
			Function: SetIcon
			Sets the icon of a tab.
			
			Parameters:
				Filename - The filename of the file containing the icon.
				IconNumber - The icon number in a multi-icon file.
			*/
			SetIcon(Filename, IconNumber = 1)
			{
				global CGUI
				this._.Icon := Filename
				this._.IconNumber := IconNumber
				Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
				Control._.ImageListManager.SetIcon(this._.TabNumber, Filename, IconNumber)
			}
		}
	}
}