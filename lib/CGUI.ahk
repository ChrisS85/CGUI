#NoEnv ;Leave this here if you don't want weird ListView icon behavior (and possibly other side effects)
/*
   Class: CGUI
   The main GUI class. User created GUIs need to extend this class and call Base.__New() in their constructor before doing anything related to this class.
*/
Class CGUI
{
	static GUIList := Object()
	_ := Object() ;Proxy object
	/*	
	Get only:
	var Controls := Object()
	var hwnd := 0
	var GUINum := 0
	MinMax
	Instances ;Returns a list of instances of this window class
	
	
	var CloseOnEscape := 0 ;If true, pressing escape will call the Close() event function if defined. Otherwise, it will call Escape() if it is defined.
	var DestroyOnClose := 0 ;If true, the gui will be destroyed instead of being hidden when it gets closed by the user.
		
	Not supported:	
	var Delimiter := "|" ;It's always | for now
	var Label := "CGUI_" ;Labels are handled internally and get rerouted to event functions defined in the class which extends CGUI
	var LastFoundExist := 0 ;This is not needed because the GUI is created anyway when the class gets instantiated.
	
	Event functions that can be defined in the class that extends CGUI:
	Size(Event) ;Called when window size changes
				;Possible values for Event:
				;0: The window has been restored, or resized normally such as by dragging its edges.
				;1: The window has been minimized.
				;2: The window has been maximized.

	ContextMenu() ;Called when a context menu is about to be invoked. This is mostly useless for now because the control can not get identified properly
	DropFiles() ;Called when files were dropped on the gui. This is mostly useless for now because the control can not get identified properly
	PreClose() ;Called when the window is about to be closed or when Escape was pressed and CloseOnEscape = true. If it returns true, the window is kept open. Otherwise it will be hidden or destroyed depending on the value of DestroyOnClose
	PostDestroy() ;Called when the window was destroyed. Attention: Many variables and functions in this object aren't usable anymore. This function is mostly used to release additional resources or to exit the program.
	Escape() ;Called when escape is pressed and CloseOnEscape = false. The window is not automatically hidden/destroyed when CloseOnEscape = false.
	*/
	__New()
	{
		global CGUI, CFont
		start := 10 ;Let's keep some gui numbers free for other uses
		loop {
			Gui %start%:+LastFoundExist
			IfWinNotExist
			{
				this.GUINum := start
				break
			}
			start++
			if(start = 100)
				break
		}
		if(!this.GUINum)
			return ""
		this.Controls := Object()
		;~ this.Insert("_", {}) ;Create proxy object to store some keys in it and still trigger __Get and __Set
		this.Font := new CFont(this.GUINum)
		CGUI.GUIList[this.GUINum] := this
		GUI, % this.GUINum ":+LabelCGUI_ +LastFound"		
		this.hwnd := WinExist()
		;~ this.Base.ImageListManager := new this.CImageListManager(GUINum) ;ImageListManager is stored in the base object of a gui class so that multiple instances of a gui may reuse the same Imagelist
	}
	__Delete()
	{
	}
	
	/*
	Function: Destroy
	
	Destroys the window. Any possible references to this class should be removed so its __Delete() function may get called. Make sure not attempt to use this window anymore!
	*/
	Destroy()
	{
		global CGUI
		if(this.IsDestroyed)
			return
		;~ for hwnd, Control in this.Private.Controls ;Break circular references to allow object release
			;~ Control.GUI := ""
		CGUI.GUIList.Remove(this.GUINum, "") ;make sure not to alter other GUIs here
		this.IsDestroyed := true		
		;Destroy the GUI and remove it from gui lists
		Gui, % this.GUINum ":Destroy"
		if(IsFunc(this.PostDestroy))
			this.PostDestroy()
	}
	
	/*
	Function: Show
	
	Shows the window.
	
	Parameters:
	
		Options - Same as in Gui, Show command
	*/
	Show(Options="")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Show",%Options%, % this.Title
	}
	
	/*
	Function: Activate
	
	Activates the window.
	*/
	Activate()
	{
		if(this.IsDestroyed)
			return
		WinActivate, % "ahk_id " this.hwnd
	}
	
	/*
	Function: Hide
	
	Hides the window.
	*/
	Hide()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Hide"
	}
	
	/*
	Function: Minimize
	
	Minimizese the window.
	*/
	Minimize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Minimize"
	}
	
	/*
	Function: Maximize
	
	Maximizes the window.
	*/
	Maximize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Maximize"
	}
	
	/*
	Function: Restore
	
	Restores the window.
	*/
	Restore()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Restore"
	}
	/*
	Function: Redraw
	
	Attempts to redraw the window.
	*/
	Redraw()
	{
		if(this.IsDestroyed)
			return
		WinSet, Redraw,,% "ahk_id " this.hwnd
	}
	
	/*
	Function: Font
	
	Changes the default font used for controls from here on.
	
	Parameters:
		Options - Font options, size etc. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
		Fontname - Name of the font. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
	*/
	;~ Font(Options, Fontname)
	;~ {
		;~ if(this.IsDestroyed)
			;~ return
		;~ Gui, % this.GUINum ":Font", %Options%, %Fontname%
	;~ }
	
	/*
	Function: Color
	
	Changes the default font used for controls from here on.
	
	Parameters:
		WindowColor - Color of the window background. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
		ControlColor - Color for controls. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
	*/
	Color(WindowColor, ControlColor)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Color", %WindowColor%, %ControlColor%
	}
	
	/*
	Function: Margin
	
	Changes the margin used between controls. Previously added controls are not affected.
	
	Parameters:
		x - Distance between controls on the x-axis.
		y - Distance between controls on the y-axis.
	*/
	Margin(x, y)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Margin", %x%, %y%
	}
	
	/*
	Function: Flash
	
	Flashes the taskbar button of this window.
	
	Parameters:
		Off - Leave empty to flash the taskbar. Use "Off" to disable flashing and restore normal state.
	*/
	Flash(Off = "")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Flash", %Off%
	}
	
	/*
	Function: Menu
	
	Attaches a menu bar to the window.
	
	Parameters:
		Menuname - The name of a menu which was previously created with the Menu (<http://www.autohotkey.com/docs/commands/Menu.htm>) command. Leave empty to remove the menu bar.
	*/
	Menu(Menuname="")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Menu", %Menname%
	}
	
	/*
	Function: Add
	
	Creates and adds a control to the window.
	
	Parameters:
		Control - The type of the control. The control needs to be a name that can be translated to a class inheriting from CControl, e.g. "Text" -> "CTextControl". Valid values are:
					- Text
					- Edit
					- Button
					- Checkbox
					- Radio
					- ListView
					- ComboBox
					- DropDownList
					- ListBox
					- TreeView
					- Tab
					- GroupBox
					- Picture
					- Progress
		Name - The name of the control. The control can be accessed by its name directly from the GUI object, i.e. GUI.MyEdit1 or similar. Names must be unique and must not be empty.
		Options - Default options to be used for the control. These are in default AHK syntax according to <http://www.autohotkey.com/docs/commands/Gui.htm#OtherOptions> and <http://www.autohotkey.com/docs/commands/GuiControls.htm>. Do not use GUI variables (v option) and g-labels (g option).
		Text - Text of the control. For some controls, this parameter has a special meaning. It can be a list of items or a collection of column headers separated by "|".
	*/
	Add(Control, Name, Options, Text, ControlList="")
	{
		global
		local hControl, type
		if(this.IsDestroyed)
			return
		if(!Name)
		{
			Msgbox No name specified. Please supply a proper control name.
			return
		}
		if(!ControlList)
			ControlList := this
		if(IsObject(ControlList[Name]))
		{
			Msgbox The control %Name% already exists. Please choose another name!
			return
		}
		if(Control = "DropDownList" || Control = "ComboBox" || Control = "ListBox")
		{
			type := Control
			Control := object("base", CChoiceControl)
			Control.__New(Name, Options, Text, this.GUINum, type)
		}
		else if(Control = "Checkbox" || Control = "Radio" )
		{
			type := Control
			Control := object("base", CCheckboxControl)
			Control.__New(Name, Options, Text, this.GUINum, type)
		}
		else if(Control = "Tab" )
		{
			type := "Tab2"
			Control := object("base", CTabControl)
			Control.__New(Name, Options, Text, this.GUINum)
		}
		else
		{
			Control := "C" Control "Control"
			if(IsObject(%Control%))
			{
				Control := object("base", %Control%)
				Control.__New(Name, Options, Text, this.GUINum)
			}
			else
			{
				Msgbox The control %Control% was not found!
				return
			}
		}
		Gui, % this.GUINum ":Add", % Control.Type, % Control.Options " hwndhControl " (IsLabel(this.__Class "_" Control.Name) ? "g" this.__Class "_" Control.Name : ""), % Control.Content ;Create the control and get its window handle and setup a g-label
		Control.Remove("Content")
		Control.hwnd := hControl ;Window handle is used for all further operations on this control
		ControlList[Control.Name] := Control
		if(ControlList = this)
			this.Controls[Name] := Control ;Add to list of controls
		;Check if the programmer missed a g-label
		for index, Event in Control._.Events
			if(IsFunc(this.__Class "." Control.Name "_" Event) && !IsLabel(this.__Class "_" Control.Name))
			{
				Msgbox % "Event notification function found for " Control.Name ", but the appropriate label " this.__Class "_" Control.Name " does not exist!"
				break
			}
		
		if(type = "Tab2") ;Fix tab name
		{
			Gui, % this.GUINum ":Tab"
			Control.Type := "Tab"
		}
		return Control
	}
	
	/*
	Function: ControlFromHWND
	Returns the object that belongs to a control with a specific window handle.
	Parameters:
		HWND - The window handle.
	*/
	ControlFromHWND(HWND)
	{
		for GUINum, GUI in this.GUIList
			for Name, Control in GUI.Controls
				if(Control.hwnd = hwnd)
					return Control
	}
	
	/*
	Variable: GUIList
	This static array contains a list of all GUIs created with this library.
	It is maintained automatically and should not need to be used directly.
	
	Variable: IsDestroyed
	True if the window has been destroyed and this object is not usable anymore.
	
	Variable: x
	x-Position of the window.
	
	Variable: y
	y-Position of the window.
	
	Variable: width
	Width of the window.
	
	Variable: height
	Height of the window.
	
	Variable: Position
	An object containing the x and y values. They can not be set separately through this object, only both at once.
	
	Variable: Size
	An object containing the width and height values. They can not be set separately through this object, only both at once.
	
	Variable: Title
	The window title.
	
	Variable: Style
	The window style.
	
	Variable: ExStyle
	The window extended style.
	
	Variable: Transcolor
	A color that will be made invisible/see-through on the window. Values: RGB|ColorName|Off
	
	Variable: Transparent
	The window style.
	
	Variable: MinMax
	The window state: -1: minimized / 1: maximized / 0: neither. Can not be set this way.
	
	Variable: ActiveControl
	The control object that is focused. Can also be set.
	
	Variable: Enabled
	If false, the user can not interact with this window. Used for creating modal windows.
	
	Variable: Visible
	Sets wether the window is visible or hidden.
	
	Variable: AlwaysOnTop
	If true, the window will be in front of other windows.
	
	Variable: Border
	Provides a thin border around the window.
	
	Variable: Caption
	Set to false to remove the title bar.
	
	Variable: MinimizeBox
	Determines if the window has a minimize button in the title bar.
	
	Variable: MaximizeBox
	Determines if the window has a maximize button in the title bar.
	
	Variable: Resize
	Determines if the window can be resized by the user.
	
	Variable: SysMenu
	If true, the window will show a it's program icon in the title bar and show its system menu there.
	
	Variable: Instances
	A list of all instances of the current window class. If you inherit from CGUI you can use this to find all windows of this type.
	
	Variable: MinSize
	Minimum window size when Resize is enabled.
	
	Variable: MaxSize
	Maximum window size when Resize is enabled.
	
	Variable: Theme
	
	Variable: Toolwindow
	Provides a thin title bar.
	
	Variable: Owner
	Assigning a hwnd to this property makes this window owned by another so it will act like a tool window of said window. Supports any window, not just windows from this process.
	
	Variable: OwnerAutoClose
	By enabling this, an owned window (which has its Owner property set to the window handle of its parent window) will automatically close itself when its parent window closes.
	The window can use its PreClose() event to decide if it should really be closed, but the owner status will be removed anyway.
	To archive this behaviour a shell message hook is used. If there is already such a hook present in the script, this library will intercept it and forward any messages to the original callback function.
	
	Variable: OwnDialogs
	Determines if the dialogs that this window shows will be owned by it.
	
	Variable: Region
	
	Variable: WindowColor
	
	Variable: ControlColor
	
	Variable: DestroyOnClose
	If set, the window will be destroyed when it gets closed.
	
	Variable: CloseOnEscape
	If set, the window will close itself when escape is pressed.	
	*/
	__Get(Name)
	{
		global CGUI	
			
		DetectHidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if(Name = "IsDestroyed" && this.GUINum) ;Extra check in __Get for this property because it might be destroyed through an old-style Gui, Destroy command
		{
			GUI, % this.GUINum ":+LastFoundExist"
			Value := WinExist() = 0
		}
		else if(Name != "IsDestroyed" && Name != "GUINum" && !this.IsDestroyed)
		{
			if Name in x,y,width, height
			{
				WinGetPos, x,y,width,height,% "ahk_id " this.hwnd
				Value := %Name%
			}
			else if(Name = "Position")
			{
				WinGetPos, x,y,,,% "ahk_id " this.hwnd
				Value := {x:x,y:y}
			}
			else if(Name = "Size")
			{
				WinGetPos,,,width,height,% "ahk_id " this.hwnd
				Value := {width:width, height:height}
			}
			else if(Name = "Title")
				WinGetTitle, Value, % "ahk_id " this.hwnd
			else if Name in Style,ExStyle, TransColor, Transparent, MinMax
				WinGet, Value, %Name%, % "ahk_id " this.hwnd
			else if(Name = "ActiveControl") ;Returns the control object that has keyboard focus
			{
				ControlGetFocus, Value, % "ahk_id " this.hwnd
				ControlGet, Value, Hwnd,, %Value%, % "ahk_id " this.hwnd
				for Name, Control in this.Controls
					if(Control.hwnd = Value)
					{
						Value := Control
						break
					}
			}
			else if(Name="Enabled")
				Value := !(this.Style & 0x8000000) ;WS_DISABLED
			else if(Name = "Visible")
				Value :=  this.Style & 0x10000000
			else if(Name = "AlwaysOnTop")
				Value := this.ExStyle & 0x8
			else if(Name = "Border")
				Value := this.Style & 0x800000
			else if(Name = "Caption")
				Value := this.Style & 0xC00000
			else if(Name = "MaximizeBox")
				Value := this.Style & 0x10000
			else if(Name = "MinimizeBox")
				Value := this.Style & 0x10000
			else if(Name = "Resize")
				Value := this.Style & 0x40000
			else if(Name = "SysMenu")
				Value := this.Style & 0x80000
		}
		if(Value = "" && Name = "Instances") ;Returns a list of instances of this window class
		{
			Value := Array()
			for GuiNum,GUI in CGUI.GUIList
				if(GUI.__Class = this.__Class)
					Value.Insert(GUI)
		}
		else if(Value = "" && Name = "MinSize")
			Value := this._.MinSize
		else if(Value = "" && Name = "MaxSize")
			Value := this._.MaxSize
		else if(Value = "" && Name = "Theme")
			Value := this._.Theme
		else if(Value = "" && Name = "ToolWindow")
			Value := this._.ToolWindow
		else if(Value = "" && Name = "Owner")
			Value := this._.Owner
		else if(Value = "" && Name = "OwnDialogs")
			Value := this._.OwnDialogs
		else if(Value = "" && Name = "Region")
			Value := this._.Region
		else if(Value = "" && Name = "WindowColor")
			Value := this._.WindowColor
		else if(Value = "" && Name = "ControlColor")
			Value := this._.ControlColor
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Value != "")
			return Value
	}
	__Set(Name, Value)
	{
		global CGUI
		DetectHidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		Handled := true
		if(!this.IsDestroyed)
		{
			if Name in AlwaysOnTop,Border,Caption,LastFound,LastFoundExist,MaximizeBox,MaximizeBox,MinimizeBox,Resize,SysMenu
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
			else if Name in OwnDialogs, Theme, ToolWindow
			{
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
				this._[Name] := Value = 1
			}
			else if Name in MinSize, MaxSize
			{
				Gui, % this.GUINum ":+" Name Value
				if(!IsObject(this._[Name]))
					this._[Name] := {}
				Loop, Parse, Value, x
				{
					if(!A_LoopField)
						this._[Name][A_Index = 1 ? "width" : "height"] := A_Index = 1 ? this.width : this.height
					else
						this._[Name][A_Index = 1 ? "width" : "height"] := A_LoopField
				}
			}
			else if(Name = "Owner")
			{
				if(Value && WinExist("ahk_id " Value))
				{
					DllCall("SetWindowLong" (A_PtrSize = 4 ? "" : "Ptr"), "Ptr", this.hwnd, "int", -8, "PTR", Value) ;This line actually sets the owner behavior
					this._.hOwner := Value
				}
				else
				{
					DllCall("SetWindowLong" (A_PtrSize = 4 ? "" : "Ptr"), "Ptr", this.hwnd, "int", -8, "PTR", 0) ;Remove tool window behavior
					this._.Remove("hOwner")
				}
			}
			else if(Name = "OwnerAutoClose" && this._.HasKey("hOwner"))
			{
				if(Value = 1)
				{
					if(!CGUI._.ShelllHook)
					{
						DllCall( "RegisterShellHookWindow", "Ptr", A_ScriptHWND) 
						CGUI._.ShellHookMsg := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ) 
						CGUI._.ShellHook := OnMessage(CGUI._.ShellHookMsg, "CGUI_ShellMessage")
						if(CGUI._.ShellHook = "CGUI_ShellMessage")
							CGUI._.ShellHook := 1
					}
					this._.OwnerAutoClose := 1
				}
				else
				{
					if(this._.OwnerAutoClose)
					{
						for GUINum, GUI in CGUI.GUIList
							if(GUI.hwnd != this.hwnd && GUI._.OwnerAutoClose)
								found := true
						if(!found)
						{
							OnMessage(CGUI._.ShellHookMsg, (CGUI._.ShellHook && CGUI._.ShellHook != 1) ? CGUI._.ShellHook : "")
							if(!CGUI._.ShellHook)
								DllCall("DeRegisterShellHookWindow", "Ptr", A_ScriptHWND)
							CGUI._.Remove("ShellHook")
						}
					}
					this._.OwnerAutoClose := 0
				}
			}
			else if Name in Style, ExStyle, Transparent, TransColor
				WinSet, %Name%, %Value%, % "ahk_id " this.hwnd
			else if(Name = "Region")
			{
				WinSet, Region, %Value%, % "ahk_id " this.hwnd
				this._.Region := Value
			}
			else if Name in x,y,width, height
				WinMove,% "ahk_id " this.hwnd,,% Name = "x" ? Value : "", % Name = "y" ? Value : "", % Name = "width" ? Value : "", % Name = "height" ? Value : ""
			else if(Name = "Position")
				WinMove,% "ahk_id " this.hwnd,,% Value.x, % Value.y
			else if(Name = "Size")
				WinMove,% "ahk_id " this.hwnd,,,, % Value.width, % Value.height
			else if(Name = "Title")
				WinSetTitle, % "ahk_id " this.hwnd,,%Value%
			else if(Name = "WindowColor")
				Gui, % this.GUINum ":Color", %Value%
			else if(Name = "ControlColor")
				Gui, % this.GUINum ":Color",, %Value%
			else if(Name = "ActiveControl")
			{
				if(!IsObject(Value))
					Value := this[Value]
				if(IsObject(Value))
					ControlFocus,,% "ahk_id " Value.hwnd
			}
			else if(Name = "Enabled")
				this.Style := (Value ? "-" : "+") 0x8000000 ;WS_DISABLED
			else if(Name = "Visible")
				this.Style := (Value ? "+" : "-") 0x10000000 ;WS_VISIBLE			
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else
				Handled := false
		}
		else
			Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
	}
	/*
	Event: Introduction
	Events are used by implementing the specific event function in the class that extends CGUI. No g-labels are required nor anything else.
	
	Event: ContextMenu()
	Invoked when the user right clicks on a control of this window.
	
	Event: DropFiles()
	Invoked when the user dropped files on the window.
	
	Event: Escape()
	Invoked when the user pressed Escape. Having the window close itself when escape gets pressed can be easily done by setting CloseOnEscape := 1 and does not need this event.
	
	Event: PreClose()
	Invoked when the window is about to close. This function can stop the closing of the window by returning true. Otherwise the window will be destroyed or hidden, depending on the setting of DestroyOnClose.
	
	Event: PostDestroy()
	Invoked when the window was destroyed. It's not possible to interact with the window or its controls anymore so this event should only be used to free possible resources.
	
	Event: Size(Event)
	Invoked when the window gets resized.
	0: The window has been restored, or resized normally such as by dragging its edges.
	1: The window has been minimized.
	2: The window has been maximized.
	/*
	Main event rerouting function. It identifies the associated window/control and calls the related event function if it is defined. It also handles some things on its own, such as window closing.
	*/
	HandleEvent()
	{
		global CGUI
		if(this.IsDestroyed)
			return
		ErrLevel := ErrorLevel
		ControlName := SubStr(A_ThisLabel, InStr(A_ThisLabel, "_") + 1)
		GUI := CGUI.GUIList[A_GUI]
		if(IsObject(GUI))
		{
			if(InStr(A_ThisLabel, "CGUI_")) ;Handle default gui events (Close, Escape, DropFiles, ContextMenu)
			{
				func := SubStr(A_ThisLabel, InStr(A_ThisLabel, "_") + 1)
				func := func = "Escape" && GUI.CloseOnEscape ? "PreClose" : func
				func := func = "Close" ? "PreClose" : func
				if(IsFunc(GUI[func]))
				{				
					ErrorLevel := ErrLevel
					if(A_ThisLabel = "CGUI_Size")
						result := `(GUI)[func](A_EventInfo)
					else
						result := `(GUI)[func]()
				}
				if(!this.IsDestroyed)
				{
					if(func = "PreClose" && !result && !GUI.DestroyOnClose) ;Hide the GUI
						GUI.Hide()
					else if(func = "PreClose" && !result)
						GUI.Destroy()
				}
			}
			else
			{
				for Name, Control in GUI.Controls
				{
					if(Name = ControlName)
					{
						ErrorLevel := ErrLevel
						Control.HandleEvent()
						return
					}
				}
			}
		}
	}
	HandleMessage(lParam, msg, hwnd)
	{
		global CGUI
		static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, h_cursor_hand
		wParam := this ;Fix parameter offset caused by this being a class method
		GUI := CGUI.GUIList[A_GUI]
		if(msg = WM_SETCURSOR || msg = WM_MOUSEMOVE) ;Text control Link support, thanks Shimanov!
		{
			if(msg = WM_SETCURSOR)
			{
				If(GUI._.Hovering)
					Return true
			}
			else if(msg = WM_MOUSEMOVE)
			{
				MouseGetPos,,,,ControlHWND, 2
				for name, Control in GUI.Controls
					if(Control.hwnd = ControlHWND && Control.Link)
					{
						ShouldHover := true
						break
					}
				if(ShouldHover)
				{
					if(!GUI._.Hovering)
					{
						Control.Font.Options := "cBlue underline"
						Gui._.LastHoveredControl := Control.hwnd
						h_cursor_hand := DllCall("LoadCursor", "Ptr", 0, "uint", 32649, "Ptr")
						GUI._.Hovering := true
					}
					GUI._.h_old_cursor := DllCall("SetCursor", "Ptr", h_cursor_hand, "Ptr")
				}
				; Mouse cursor doesn't hover URL text control
				else
				{
					if(GUI._.Hovering)
					{					
						for name, Control in GUI.Controls
							if(Control.hwnd = GUI._.LastHoveredControl && Control.Link)
							{
								Control.Font.Options := "norm cBlue"
								DllCall("SetCursor", "Ptr", GUI._.h_old_cursor)
								GUI._.Hovering := false
								break
							}					
					}
				}
			}
		}
	}
}


;Event handlers for gui and control events:
CGUI_Size:
CGUI_ContextMenu:
CGUI_DropFiles:
CGUI_Close:
CGUI_Escape:
CControl_Event:
CGUI.HandleEvent()
return

/*
Function: CGUI_ShellMessage()
This function is used to monitor closing of the parent windows of owned GUIs. It does not need to be called directly.
It is still possible to use a shell message hook as usual in your script as long as you initialize it before setting GUI.OwnerAutoClose := 1.
This library will intercept all ShellMessage calls and forward it to the previously used ShellMessage callback function.
This callback function will only be used when there are owned windows which have OwnerAutoClose activated. In all other cases it won't be used and can safely be ignored.
*/
CGUI_ShellMessage(wParam, lParam, msg, hwnd) 
{ 
   global CGUI 
   outputdebug shellmessage %wparam% %lparam%
   if(wParam = 2) ;Window Destroyed 
   {
	  Loop % CGUI.GUIList.MaxIndex() 
	  { 
		 if(CGUI.GUIList[A_Index]._.hOwner = lParam && CGUI.GUIList[A_Index]._.OwnerAutoClose)
		 {
			PostMessage, 0x112, 0xF060,,, % "ahk_id " CGUI.GUIList[A_Index].hwnd  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE --> this should trigger AHK CGUI_Close label so the GUI class may process the close request
			CGUI.GUIList[A_Index]._.Remove("hOwner")
			CGUI.GUIList[A_Index]._.Remove("OwnerAutoClose")
			for GUINum, GUI in CGUI.GUIList
				if(GUI._.OwnerAutoClose)
					found := true
			if(!found) ;No more tool windows, remove shell hook 
			{ 
				OnMessage(CGUI._.ShellHookMsg, (CGUI._.ShellHook && CGUI._.ShellHook != 1) ? CGUI._.ShellHook : "")
				if(!CGUI._.ShellHook)
					DllCall("DeRegisterShellHookWindow", "Ptr", A_ScriptHWND)
				CGUI._.Remove("ShellHook")
			} 
			break 
		 } 
	  } 
   } 
   if(IsFunc(CGUI._.ShellHook)) 
   { 
		msgbox % "reroute to " CGUI._.ShellHook
	  ShellHook := CGUI._.ShellHook 
	  %ShellHook%(wParam, lParam, msg, hwnd) ;This is allowed even if the function uses less parameters 
   } 
}

Class CFont
{
	__New(GUINum, ControlName)
	{
		this.Insert("_", {})
		this._.GUINum := GUINum
		this._.ControlName := ControlName
	}
	__Set(Name, Value)
	{
		global CGUI
		if(Name = "Options")
		{
			if(this._.ControlName) ;belonging to a control
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI[this._.ControlName]
				Gui, % this._.GUINum ":Font", %Value%
				GuiControl, % this.GUINum ":Font", % Control.ClassNN
				Gui, % this._.GUINum ":Font", % GUI.Font.Options ;Restore current font
			}
			else ;belonging to a window
				Gui, % this._.GUINum ":Font", %Value%
			this._[Name] := Value
			return Value
		}
		else if(Name = "Font")
		{
			if(this._.ControlName) ;belonging to a control
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI[this._.ControlName]
				Gui, % this._.GUINum ":Font",, %Value%
				GuiControl, % this.GUINum ":Font", % Control.ClassNN
				Gui, % this._.GUINum ":Font",, % GUI.Font.Font ;Restore current font
			}
			else ;belonging to a window
				Gui, % this._.GUINum ":Font",, %Value%
			this._[Name] := Value
			return Value
		}
	}
	__Get(Name)
	{
		if(Name != "_" && this._.HasKey(Name))
			return this._[Name]
	}
}
#include <CControl>
#include <CFileDialog>
#include <CFolderDialog>
#include <CEnumerator>