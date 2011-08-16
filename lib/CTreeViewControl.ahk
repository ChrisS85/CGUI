/*
Class: CTreeViewControl
A TreeView control.
*/
Class CTreeViewControl Extends CControl
{
	__New(Name, ByRef Options, Text, GUINum)
	{
		global CGUI
		Events := ["_Click", "_RightClick", "_EditingStart", "_FocusReceived", "_FocusLost", "_KeyPress", "_ItemExpanded", "_ItemCollapsed"]
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit when necessary
		{
			for index, function in Events
			{
				if(IsFunc(CGUI.GUIList[GUINum][Name Function]))
				{
					Options .= " AltSubmit"
					break
				}
			}
		}
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("Items", new this.CItem(0, GUINum, Name))
		this._.Insert("ControlStyles", {Checked : 0x100, ReadOnly : -0x8, FullRowSelect : 0x1000, Buttons : 0x1, Lines : 0x2, HScroll : -0x8000, AlwaysShowSelection : 0x20, SingleExpand : 0x400, HotTrack : 0x200})
		this._.Insert("Events", ["DoubleClick", "EditingEnd", "ItemSelected", "Click", "RightClick", "EditingStart", "KeyPress", "ItemExpanded", "ItemCollapsed", "FocusReceived", "FocusLost"])
		this._.Insert("ImageListManager", new this.CImageListManager(GUINum, Name))
		this.Type := "TreeView"
	}
	
	;Find an item by its ID
	FindItem(ID, Root = "")
	{
		if(!ID) ;Root node
			return this.Items
		if(!IsObject(Root))
			Root := this.Items
		if(ID = Root.ID)
			return Root
		Loop % Root.MaxIndex()
			if(result := this.FindItem(ID, Root[A_Index]))
				return result
		return 0
		
	}
	/*
	Variable: Items
	Contains the nodes of the tree. Each level can be iterated and indexed.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Items")
			Value := this._.Items
		Loop % Params.MaxIndex()
			if(IsObject(Value)) ;Fix unlucky multi parameter __GET
				Value := Value[Params[A_Index]]
		if(Value)
			return Value
	}
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click(NodeIndex)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(NodeIndex)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(NodeIndex)
	Invoked when the user right-clicked on the control.
	
	Event: EditingStart(NodeIndex)
	Invoked when the user started editing a node.
	
	Event: EditingEnd(NodeIndex)
	Invoked when the user finished editing a node.
	
	Event: ItemSelected(NodeIndex)
	Invoked when the user selected a node.
	
	Event: ItemExpanded(NodeIndex)
	Invoked when the user expanded a node.
	
	Event: ItemCollapsed(NodeIndex)
	Invoked when the user collapsed a node.
	
	Event: KeyPress(KeyCode)
	Invoked when the user pressed a key while the control was focused.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		;~ Critical := A_IsCritical
		;~ Critical, On
		ErrLevel := ErrorLevel
		Mapping := {DoubleClick : "_DoubleClick", eb : "_EditingEnd", S : "_ItemSelected", Normal : "_Click", RightClick : "_RightClick", Ea : "_EditingStart", K : "_KeyPress", "+" : "_ItemExpanded", "-" : "ItemCollapsed"}
		for Event, Function in Mapping
			if((strlen(A_GuiEvent) = 1 && A_GuiEvent == SubStr(Event, 1, 1)) || A_GuiEvent == Event)
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function](this.FindItem(A_EventInfo))
					;~ if(!Critical)
						;~ Critical, Off
					return
				}
		Mapping := {Fa : "_FocusReceived", fb : "_FocusLost"} ;Case insensitivity strikes back!
		for Event, Function in Mapping
			if(A_GuiEvent == SubStr(Event, 1, 1))
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]()
					;~ if(!Critical)
						;~ Critical, Off
					return
				}
	}
	
	/*
	Class: CItem
	A tree node.
	*/
	Class CItem
	{
		__New(ID, GUINum, ControlName)
		{
			this.Insert("_", {})
			this._.Insert("GUINum", GUINum)
			this._.Insert("ControlName", ControlName)
			this._.Insert("ID", ID)
		}
		/*
			Function: Add
			Adds a new item to the TreeView.
			
			Parameters:
				Text - The text of the item.
				Options - Various options, see Autohotkey TreeView documentation
			
			Returns:
			An object of type CItem representing the newly added item.
		*/
		Add(Text, Options = "")
		{
			global CGUI, CTreeViewControl
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			ID := TV_Add(Text, this.ID, Options)
			Item := new CTreeViewControl.CItem(ID, this._.GUINum, this._.ControlName)
			;~ Item.Icon := ""
			this.Insert(Item)
			return Item
		}
		/*
			Function: Remove
			Removes an item.
			
			Parameters:
				ObjectOrIndex - The item object or the index of the child item of this.
		*/
		Remove(ObjectOrIndex)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			if(!IsObject(ObjectOrIndex)) ;If index, get object and then handle
				ObjectOrIndex := this[ObjectOrIndex]
			if(ObjectOrIndex.ID = 0) ;Don't delete root node
				return
			p := ObjectOrIndex.Parent
			for Index, Item in ObjectOrIndex.Parent
				if(Item = ObjectOrIndex)
				{
					ObjectOrIndex.Parent._Remove(A_Index)
					break
				}
			TV_Delete(ObjectOrIndex.ID)
			if(TV_GetCount() = 0) ;If all TreeView items are deleted, fire a selection changed event
				if(IsFunc(GUI[Control.Name "_ItemSelected"]))
				{
					ErrorLevel := ErrLevel
					GUI[Control.Name "_ItemSelected"](Control.Items)
					if(!Critical)
						Critical, Off
					return
				}
		}
		/*
		Function: Move
		Moves an Item to another position.
		
		Parameters:
			Position - The new (one-based) - position in the child items of Parent.
			Parent - The item will be inserted as child of the Parent item. Leave empty to use its current parent.
		*/
		Move(Position=1, Parent = "")
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			
			;Backup properties which are stored in the TreeList itself
			Text := this.Text
			Bold := this.bold
			Expanded := this.Expanded
			Checked := this.Checked
			Selected := this.Selected
			OldID := this.ID
			
			;If no parent is specified, the item will be moved on the current level
			if(!Parent)
				Parent := this.Parent
			OldParent := this.Parent
			
			;Add new node. At this point there are two nodes.
			NewID := TV_Add(Text, Parent.ID, (Position = 1 ? "First" : Parent[Position-1].ID) " " (Bold ? "+Bold" : "") (Expanded ?  "Expand" : "") (Checked ? "Check" : "") (Selected ? "Select" : ""))
			
			;Collect all child items
			Childs := []
			for index, Item in this
				Childs.Insert(Item)
			
			this._.ID := NewID
			
			;Remove old parent node link and set the new one
			if(OldParent != Parent)
			{
				for Index, Item in OldParent
					if(Item = this)
					{
						OldParent.Remove(A_Index)
						break
					}
				Parent.Insert(Position, this)
			}
			
			if(this.Icon)
				Control._.ImageListManager.SetIcon(this._.ID, this.Icon, this.IconNumber)
			
			;Move child items
			for index, Item in Childs
				Item.Move(index, this)
			
			;Delete old tree node
			TV_Delete(OldID)
		}
		SetIcon(Filename, IconNumberOrTransparencyColor = 1)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Control._.ImageListManager.SetIcon(this._.ID, Filename, IconNumberOrTransparencyColor)
			this._.Icon := Filename
			this._.IconNumber := IconNumberOrTransparencyColor
		}
		MaxIndex()
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			text := this.text
			Gui, TreeView, % Control.ClassNN
			current := this._.ID ? TV_GetChild(this._.ID) : TV_GetNext() ;Get first child or first top node
			if(!current)
				return 0 ;No children
			count := 0
			while(current && current := TV_GetNext(current))
				count++
			return count + 1
		}
		;Access a child item by its ID
		ItemByID(ID)
		{
			Loop % this.MaxIndex()
				if(this[A_Index]._.ID = ID)
					return this[A_Index]
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
		__Get(Name, Params*)
		{
			global CTreeViewControl, CGUI
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{					
					;~ if Name is Integer ;get a child node
					;~ {
						;~ if(Name <= this.MaxIndex())
						;~ {
							;~ Control := GUI[this._.ControlName]
							;~ Gui, % this._.GUINum ":Default"
							;~ Gui, TreeView, % Control.ClassNN
							;~ child := TV_GetChild(this._.ID) ;Find child node id
							;~ Loop % Name - 1
								;~ child := TV_GetNext(child)
							;~ Value := new CTreeViewControl.CItem(child, this._.GUINum, this._.ControlName)
						;~ }
					;~ }
					if(Name = "CheckedItems")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(Item)				
					}
					else if(Name = "CheckedIndices")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(index)				
					}
					else if(Name = "Parent")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						VaLue := Control.FindItem(TV_GetParent(this._.ID))
					}
					else if(Name = "ID" || Name = "Icon")
						Value := this._[Name]
					else if(Name = "Count")
						Value := this.MaxIndex()
					else if(Name = "HasChildren")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_GetChild(this._.ID) > 0
					}
					else if(Name = "Text")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_GetText(Value, this._.ID)
					}
					else if(Name = "Checked" || Name = "Expanded" || Name = "Bold")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_Get(this._.ID, Name) > 0
					}
					else if(Name = "Selected")
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_GetSelection() = this._.ID
					}
					Loop % Params.MaxIndex()
						if(IsObject(Value)) ;Fix unlucky multi parameter __GET
							Value := Value[Params[A_Index]]
					if(Value)
						return Value
				}
			}
		}
		__Set(Name, Params*)
		{
			global CGUI
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			GUI := CGUI.GUIList[this._.GUINum]
			if(!GUI.IsDestroyed)
			{
				if(Name = "Text")
				{
					if(Value = "New Category")
						outputdebug break
					Control := GUI[this._.ControlName]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN
					TV_Modify(this._.ID, "", Value)
					return Value
				}
				else if(Name = "Selected") ;Deselecting is not possible it seems
				{
					if(Value = 1)
					{
						Control := GUI[this._.ControlName]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_Modify(this._.ID)
					}
					return Value
				}
				else if(Option := {Checked : "Check", Expanded : "Expand", Bold : "Bold"}[Name]) ;Wee, check and remapping in one step
				{
					Control := GUI[this._.ControlName]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN				
					TV_Modify(this._.ID, (Value = 1 ? "+" : "-") Option)
				}
				else if(Name = "Icon")
				{
					this.SetIcon(Value, this._.HasKey("IconNumber") ? this._.IconNumber : 1)
					return Value
				}
			}
		}
	}
}