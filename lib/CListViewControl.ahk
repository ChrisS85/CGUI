/*
Class: CListViewControl
A ListView control. Additionally to its features present in AHK it can use sorting-independent indexing for synchronizing its fields with an array.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CListViewControl Extends CControl
{
	__New(Name, ByRef Options, Text, GUINum)
	{
		global CGUI		
		Events := ["Click", "RightClick", "ItemActivated", "MouseLeave", "EditingStart", "FocusReceived", "FocusLost", "ItemSelected", "ItemDeselected", "ItemFocused", "ItemDefocused", "ItemChecked",  "ItemUnChecked", "SelectionChanged", "CheckedChanged", "FocusedChanged", "KeyPress", "Marquee", "ScrollingStart", "ScrollingEnd"]
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit when necessary
		{
			for index, function in Events
			{
				if(IsFunc(CGUI.GUIList[GUINum][Name "_" Function]))
				{
					Options .= " AltSubmit"
					break
				}
			}
		}
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("Items", new this.CItems(GUINum, Name))
		this._.Insert("ControlStyles", {ReadOnly : -0x200, Header : -0x4000, NoSortHdr : 0x8000, AlwaysShowSelection : 0x8, Multi : -0x4, Sort : 0x10, SortDescending : 0x20})
		this._.Insert("ControlExStyles", {Checked : 0x4, FullRowSelect : 0x20, Grid : 0x1, AllowHeaderReordering : 0x10, HotTrack : 0x8})
		this._.Insert("Events", ["DoubleClick", "DoubleRightClick", "ColumnClick", "EditingEnd", "Click", "RightClick", "ItemActivate", "EditingStart", "KeyPress", "FocusReceived", "FocusLost", "Marquee", "ScrollingStart", "ScrollingEnd", "ItemSelected", "ItemDeselected", "ItemFocused", "ItemDefocused", "ItemChecked", "ItemUnChecked", "SelectionChanged", "CheckedChanged", "FocusedChanged"])
		this._.Insert("ImageListManager", new this.CImageListManager(GUINum, Name))
		this.Type := "ListView"
	}
	
	/*
	Function: ModifyCol
	Modifies a column. See AHK help on LV_ModifyCol for details.
	*/
	ModifyCol(ColumnNumber="", Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_ModifyCol(ColumnNumber, Options, ColumnTitle)
	}
	/*
	Function: InsertCol
	Inserts a column. See AHK help on LV_InsertCol for details.
	*/
	InsertCol(ColumnNumber, Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_InsertCol(ColumnNumber, Options, ColumnTitle)
	}
	/*
	Function: DeleteCol
	Deletes a column. See AHK help on LV_DeleteCol for details.
	*/
	DeleteCol(ColumnNumber)
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_DeleteCol(ColumnNumber)
	}
	/*
	Variable: Items
	An array of all ListView rows. See <CListViewControl.CItems>.
	
	Variable: SelectedItem
	Contains the (first) selected row.
	
	Variable: SelectedItems
	Contains all selected rows.
	
	Variable: SelectedIndex
	Contains the index of the (first) selected row.
	
	Variable: SelectedIndices
	Contains all indices of the selected rows.
	
	Variable: CheckedItem
	Contains the (first) checked row.
	
	Variable: CheckedItems
	Contains all checked rows.
	
	Variable: CheckedIndex
	Contains the index of the (first) checked row.
	
	Variable: CheckedIndices
	Contains all indices of the checked rows.
	
	Variable: FocusedItem
	Contains the focused row.
	
	Variable: FocusedIndex
	Contains the index of the focused row.
	
	Variable: IndependentSorting
	This setting is off by default. In this case, indexing the rows behaves like AHK ListViews usually do. 
	If it is enabled however, the row indexing will be independent of the current sorting. 
	That means that the first row can actually be displayed as the second, third,... or last row on the GUI. 
	This feature is very useful if you need to synchronize an array with the data in the ListView 
	because the index of the array can then be directly mapped to the ListView row index. 
	This would not be possible if this option was off and the ListView gets sorted differently.
	*/
	__Get(Name, Params*)
	{
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Items")
				Value := this._.Items
			else if(Name = "SelectedIndices" || Name = "SelectedItems" || Name = "CheckedIndices" || Name = "CheckedItems")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := []
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value.Insert(InStr(Name, "Indices") ? Index : this._.Items[Index]) ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
					}
			}
			else if(Name = "SelectedIndex" || Name = "SelectedItem" || Name = "CheckedIndex" || Name = "CheckedItem")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, InStr(Name, "Checked") ? "Checked" : "") = A_Index)
					{
						Index := (this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_Index, this.hwnd) : A_Index)
						Value := InStr(Name, "Index") ? Index : this._.Items[Index] ;new this.CItems.CRow(this.CItems.GetSortedIndex(A_Index, this.hwnd), this.GUINum, this.Name))
						break
					}
			}
			else if(Name = "FocusedItem" || Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := LV_GetNext(0, "Focused")
				if(this._.Items.IndependentSorting)
					Value := this.CItems.CRow.GetUnsortedIndex(Value, this.hwnd)
				if(Name = "FocusedItem")
					Value := this._.Items[Value] ;new this.CItems.CRow(Value, this.GUINum, this.Name)
			}
			else if(Name = "IndependentSorting")
				Value := this._.Items.IndependentSorting
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
			if(Name = "SelectedIndices" || Name = "CheckedIndices")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Indices := Value
				if(!IsObject(Value))
				{
					Indices := Array()
					Loop, Parse, Value,|
						if A_LoopField is Integer
							Indices.Insert(A_LoopField)
				}
				LV_Modify(0, Name = "SelectedIndices" ? "-Select" : "-Check")
				Loop % Indices.MaxIndex()
					if(Indices[A_Index] > 0)
						LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Indices[A_Index], this.hwnd) : Indices[A_Index], Name = "SelectedIndices" ? "Select" : "Check")
			}
			else if(Name = "SelectedIndex" || Name = "CheckedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				LV_Modify(0, Name = "SelectedIndex" ? "-Select" : "-Check")
				if(Value > 0)
					LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, Name = "SelectedIndex" ? "Select" : "Check")
			}
			else if(Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				LV_Modify(this._.Items.IndependentSorting ? this.CItems.CRow.GetSortedIndex(Value, this.hwnd) : Value, "Focused")
			}
			else if(Name = "Items" && IsObject(Value) && IsObject(this._.Items) && Params.MaxIndex() > 0)
			{
				Items := this._.Items
				Items[Params*] := Value
			}
			else if(Name = "IndependentSorting")
				this._.Items.IndependentSorting := Value
			else if(Name = "Items")
				Value := 0
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	
	/*
	Class: CListViewControl.CItems
	An array of all ListView rows.
	*/
	Class CItems
	{
		__New(GUINum, ControlName)
		{
			this._Insert("_", {})
			this._.GUINum := GUINum
			this._.ControlName := ControlName
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
		/*
		Function: MaxIndex()
		Returns the number of rows.
		*/
		MaxIndex()
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % this._.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			return LV_GetCount()
		}
		/*
		Function: Add()
		Adds a row.
		
		Parameters:
			Options - Options for the new row. See AHK documentation on LV_Add().
			Fields - Any additional parameters are used as cell text.
		*/
		Add(Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := LV_Add(Options, Fields*)
			UnsortedIndex := LV_GetCount()
			this._.Insert(UnsortedIndex, new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, Control.Name))
		}
		/*
		Function: Insert()
		Inserts a row.
		
		Parameters:
			RowNumber - Index before which the row is inserted.
			Options - Options for the new row. See AHK documentation on LV_Add().
			Fields - Any additional parameters are used as cell text.
		*/
		Insert(RowNumber, Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			if(SortedIndex = -1 || SortedIndex > LV_GetCount())
				SortedIndex := LV_GetCount() + 1
			
			UnsortedIndex := this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			
			;move all unsorted indices >= the insertion point up by one to make place for the insertion
			Loop % LV_GetCount() - UnsortedIndex + 1
			{
				index := LV_GetCount() - A_Index + 1 ;loop backwards
				sIndex := this.CRow.GetSortedIndex(index, Control.hwnd) - 1
				this.CRow.SetUnsortedIndex(sIndex, index + 1, Control.hwnd)
			}
			
			SortedIndex := LV_Insert(SortedIndex, Options, Fields*)
			this._.Insert(UnsortedIndex, new this.CRow(SortedIndex, UnsortedIndex, this._.GUINum, Control.Name))
		}	
		
		/*
		Function: Modify()
		Modifies a row.
		
		Parameters:
			RowNumber - Index of the row which should be modified.
			Options - Options for the modified row. See AHK documentation on LV_Modify().
			Fields - Any additional parameters are used as cell text.
		*/
		Modify(RowNumber, Options, Fields*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			LV_Modify(SortedIndex, Options, Fields*)
		}
		
		/*
		Function: Delete()
		Deletes a row.
		
		Parameters:
			RowNumber - Index of the row which should be deleted.
		*/
		Delete(RowNumber)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI[this._.ControlName]
			Gui, % Control.GUINum ":Default"
			Gui, ListView, % Control.ClassNN
			SortedIndex := this.IndependentSorting ? this.CRow.GetSortedIndex(RowNumber, Control.hwnd) : RowNumber ;If independent sorting is off, the RowNumber parameter of this function is interpreted as sorted index
			UnsortedIndex := this.CRow.GetUnsortedIndex(SortedIndex, Control.hwnd)
			;Decrease the unsorted indices after the deletion index by one
			Loop % LV_GetCount() - UnsortedIndex
				this.CRow.SetUnsortedIndex(this.CRow.GetSortedIndex(UnsortedIndex + A_Index, Control.hwnd), UnsortedIndex + A_Index - 1, Control.hwnd)
			LV_Delete(SortedIndex)
		}
		/*
		Variable: 1,2,3,4,...
		Rows can be accessed by their index, e.g. this.ListView.Items[1][2] accesses the text of the first row and second column.
		
		Variable: Count
		The number of rows.
		*/
		__Get(Name)
		{
			global CGUI
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				if Name is Integer
				{
					if(Name > 0 && Name <= this.Count)
						return this._[this.IndependentSorting ? Name : this.CRow.GetUnsortedIndex(Name, Control.hwnd)]
				}
				else if(Name = "Count")
					return this.MaxIndex()
			}
		}
		__Set(Name, Value, Params*)
		{
			global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			if Name is Integer
			{
				if(!Params.MaxIndex()) ;Setting a row directly is not allowed
					return
				else ;Set a column or other row property
				{			
					Row := this[Name]
					Row[Params*] := Value
					return
				}
			}
		}
		
		/*
		Class: CListViewControl.CItems.CRow
		A single row of a ListView control.
		CRow uses the unsorted row numbers internally, but it can switch to sorted row numbers depending on the setting of the ListView.
		*/
		Class CRow
		{
			__New(SortedIndex, UnsortedIndex, GUINum, ControlName)
			{
				global CGUI
				this.Insert("_", {})				
				this._.RowNumber := UnsortedIndex
				this._.GUINum := GUINum
				this._.ControlName := ControlName
				GUI := CGUI.GUIList[GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[ControlName]				
				;Store the real unsorted index in the custom property lParam field of the list view item so it can be reidentified later
				this.SetUnsortedIndex(SortedIndex, UnsortedIndex, Control.hwnd)
				this.SetIcon("")
				this._.Insert("Controls", {})
			}
			/*
			Function: AddControl()
			Adds a control to this tree node that will be visible only when this node is selected. The parameters correspond to the Add() function of CGUI.
			
			Parameters:
				Type - The type of the control.
				Name - The name of the control.
				Options - Options used for creating the control.
				Text - The text of the control.
			*/
			AddControl(type, Name, Options, Text)
			{
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(!this.Selected)
					Options .= " Hidden"
				Control := GUI.Add(type, Name, Options, Text, this._.Controls)
				this._.Controls.Insert(Name, Control)
				return Control
			}
			/*
			typedef struct {
			  UINT   mask;
			  int    iItem;
			  int    iSubItem;
			  UINT   state;
			  UINT   stateMask;
			  LPTSTR pszText;
			  int    cchTextMax;
			  int    iImage;
			  LPARAM lParam;
			#if (_WIN32_IE >= 0x0300)
			  int    iIndent;
			#endif 
			#if (_WIN32_WINNT >= 0x0501)
			  int    iGroupId;
			  UINT   cColumns;
			  UINT   puColumns;
			#endif 
			#if (_WIN32_WINNT >= 0x0600)
			  int    piColFmt;
			  int    iGroup;
			#endif 
			} LVITEM, *LPLVITEM;
			*/
			SetUnsortedIndex(SortedIndex, lParam, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return
				VarSetCapacity(LVITEM, 13*4 + 2 * A_PtrSize, 0)
				mask := 0x4   ; LVIF_PARAM := 0x4
				NumPut(mask, LVITEM, 0, "UInt") 
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem 
				NumPut(lParam, LVITEM, 7*4 + A_PtrSize, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, (A_IsUnicode ? 0x1000 + 76 : 0x1000 + 6), 0, &LVITEM,, % "ahk_id " hwnd ;LVM_SETITEM
				;~ result := errorlevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_SETITEM := (A_IsUnicode ? 0x1000 + 76 : 0x1000 + 6), "PTR", 0, "PTRP", LVITEM, "PTR")
				;~ lParam2 := this.GetUnsortedIndex(RowNumber, hwnd)
				return ErrorLevel
			}
			;Returns the sorted index (by which AHK usually accesses listviews) by searching for a custom index that is independent of sorting
			/*
			typedef struct tagLVFINDINFO {
			  UINT    flags; 4
			  LPCTSTR psz; 4-8
			  LPARAM  lParam; 4- 8
			  POINT   pt; 8
			  UINT    vkDirection; 4
			} LVFINDINFO, *LPFINDINFO;
			*/
			GetSortedIndex(UnsortedIndex, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return UnsortedIndex
				;Create the LVFINDINFO structure
				VarSetCapacity(LVFINDINFO, 4*4 + 2 * A_PtrSize, 0)
				mask := 0x1   ; LVFI_PARAM := 0x1
				NumPut(mask, LVFINDINFO, 0, "UInt") 
				NumPut(UnsortedIndex, LVFINDINFO, 4 + A_PtrSize, "PTR")
				;~ string := hex(LVFINDINFO,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, (A_IsUnicode ? 0x1000 + 83 : 0x1000 + 13), -1, &LVFINDINFO,, % "ahk_id " hwnd ;LVM_FINDITEM
				;~ MsgReply := ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_FINDITEM := (A_IsUnicode ? 0x1000 + 83 : 0x1000 + 13), "PTR", -1, "UIntP", LVITEM, "PTR") + 1
				return ErrorLevel + 1
			}
			GetUnsortedIndex(SortedIndex, hwnd)
			{
				;~ if(!this.IndependentSorting)
					;~ return SortedIndex
				VarSetCapacity(LVITEM, 13*4 + 2 * A_PtrSize, 0)
				mask := 0x4   ; LVIF_PARAM := 0x4
				NumPut(mask, LVITEM, 0, "UInt") 
				NumPut(SortedIndex - 1, LVITEM, 4, "Int")   ; iItem 
				;~ NumPut(lParam, LVITEM, 7*4 + A_PtrSize, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				SendMessage, (A_IsUnicode ? 0x1000 + 75 : 0x1000 + 5), 0, &LVITEM,,% "ahk_id " hwnd ;LVM_GETITEM
				;~ result := errorlevel
				;~ result := DllCall("SendMessage", "PTR", hwnd, "UInt", LVM_GETITEM := (A_IsUnicode ? 0x1000 + 75 : 0x1000 + 5), "PTR", 0, "PTRP", LVITEM, "PTR")
				;~ string := this.hex(LVITEM,  "UINT|INT|INT|UINT|UINT|PTR|INT|INT|PTR|INT|INT|UINT|UINT|INT|INT")
				UnsortedIndex := NumGet(LVITEM, 7*4 + A_PtrSize, "PTR")
				return UnsortedIndex
			}
			_NewEnum()
			{
				global CEnumerator
				return new CEnumerator(this)
			}
			/*
			Function: MaxIndex()
			Returns the number of columns.
			*/
			MaxIndex()
			{				
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				Gui, % Control.GUINum ":Default"
				Gui, ListView, % Control.ClassNN
				Return LV_GetCount("Column")
			}
			/*
			Function: SetIcon
			Sets the icon of a ListView row
			
			Parameters:
				Filename - The filename of the file containing the icon.
				IconNumberOrTransparencyColor - The icon number or the transparency color if the used file has no transparency support.
			*/
			SetIcon(Filename, IconNumberOrTransparencyColor = 1)
			{
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(GUI.IsDestroyed)
					return
				Control := GUI[this._.ControlName]
				Control._.ImageListManager.SetIcon(this.GetSortedIndex(this._.RowNumber, Control.hwnd), Filename, IconNumberOrTransparencyColor)
				this._.Icon := Filename
				this._.IconNumber := IconNumberOrTransparencyColor
			}
			/*
			Variable: 1,2,3,4,...
			Columns can be accessed by their index, e.g. this.ListView.Items[1][2] accesses the text of the first row and second column.
			
			Variable: Text
			The text of the first column of this row.
			
			Variable: Count
			The number of columns.
			
			Variable: Checked
			True if the row is checked.
			
			Variable: Selected
			True if the row is selected.
			
			Variable: Focused
			True if the row is foucsed.
			
			Variable: Icon
			The filename of the file containing the icon for the current row.
			
			Variable: IconNumber
			The number of the icon in a multi-icon file.
			*/
			__Get(Name)
			{
				global CGUI				
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					Control := GUI[this._.ControlName]
					if Name is Integer
					{
						if(Name > 0 && Name <= this.Count) ;Setting default listview is already done by this.Count __Get
						{
							LV_GetText(value, this.GetSortedIndex(this._.RowNumber, Control.hwnd), Name)
							return value
						}
					}
					else if(Name = "Text")
						return this[1]
					else if(Name = "Count")
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						Return LV_GetCount("Column")
					}
					else if(Value := {Checked : "Checked", Focused : "Focused", "Selected" : ""}[Name])
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						return this.GetUnsortedIndex(LV_GetNext(this.GetSortedIndex(this._.RowNumber, Control.hwnd) - 1, Value), Control.hwnd) = this._.RowNumber
					}
					else if(Name = "Icon" || Name = "IconNumber")
						return this._[Name]
					else if(Name = "Controls")
						return this._.Controls
				}
			}
			__Set(Name, Value)
			{				
				global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					Control := GUI[this._.ControlName]
					if Name is Integer
					{
						if(Name <= this.Count) ;Setting default listview is already done by this.Count __Get
							LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), "Col" Name, Value)
						return Value
					}
					else if(Key := {Checked : "Check", Focused : "Focus", "Select" : ""}[Name])
					{
						Gui, % Control.GUINum ":Default"
						Gui, ListView, % Control.ClassNN
						LV_Modify(this.GetSortedIndex(this._.RowNumber, Control.hwnd), (Value = 0 ? "-" : "") Key)
						return Value
					}
					else if(Name = "Icon")
					{
						this.SetIcon(Value, this._.HasKey("IconNumber") ? this._.IconNumber : 1)
						return Value
					}
					else if(Name = "IconNumber")
					{
						this._.IconNumber := Value
						if(this._.Icon)
							this.SetIcon(this._.Icon, Value)
						return Value
					}
				}
			}
		}
	}
	
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	
	Event: Click(RowIndex)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(RowIndex)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(RowIndex)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(RowIndex)
	Invoked when the user double-right-clicked on the control.
	
	Event: ColumnClick(ColumnIndex)
	Invoked when the user clicked on a column header.
	
	Event: EditingStart(RowIndex)
	Invoked when the user started editing the first cell of a row.
	
	Event: EditingEnd(RowIndex)
	Invoked when the user finished editing a cell.
	
	Event: ItemActivate(RowIndex)
	Invoked when a row was activated.
	
	Event: KeyPress(KeyCode)
	Invoked when the user pressed a key while the control had focus.
		
	Event: MouseLeave()
	Invoked when the mouse leaves the control boundaries.
	
	Event: FocusReceived()
	Invoked when the control receives the focus.
	
	Event: FocusLost()
	Invoked when the control loses the focus.
	
	Event: Marquee()
	Invoked when the mouse gets moved over the control.
	
	Event: ScrollingStart()
	Invoked when the user starts scrolling the control.
	
	Event: ScrollingEnd()
	Invoked when the user ends scrolling the control.
	
	Event: ItemSelected(RowIndex)
	Invoked when the user selects an item.
	
	Event: ItemDeselected(RowIndex)
	Invoked when the user deselects an item.
	
	Event: SelectionChanged(RowIndex)
	Invoked when the selected item(s) has/have changed.
	
	Event: ItemFocused(RowIndex)
	Invoked when a row gets focused.
	
	Event: ItemDefocused(RowIndex)
	Invoked when a row loses the focus.
	
	Event: FocusedChanged(RowIndex)
	Invoked when the row focus has changed.
	
	Event: ItemChecked(RowIndex)
	Invoked when the user checks a row.
	
	Event: ItemUnchecked(RowIndex)
	Invoked when the user unchecks a row.	
	
	Event: CheckedChanged(RowIndex)
	Invoked when the checked row(s) has/have changed.
	*/
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Critical := A_IsCritical
		Critical, On
		ErrLevel := ErrorLevel
		;~ if(!events)
			;~ events := object()
		;~ events[mod(i,30) +1] := A_GuiEvent " " A_EventInfo " " ErrLevel
		;~ i++
		;~ loop 30
			;~ text .= events[A_Index] "`n"
		;~ tooltip %text%
		Mapping := {DoubleClick : "_DoubleClick", R : "_DoubleRightClick", ColClick : "_ColumnClick", eb : "_EditingEnd", Normal : "_Click", RightClick : "_RightClick",  A : "_ItemActivate", Ea : "_EditingStart", K : "_KeyPress"}
		for Event, Function in Mapping
			if((strlen(A_GuiEvent) = 1 && A_GuiEvent == SubStr(Event, 1, 1)) || A_GuiEvent == Event)
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]({DoubleClick : 1, R : 1, Normal : 1, RightClick : 1,  A : 1, E : 1}[A_GUIEvent] && this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
					if(!Critical)
						Critical, Off
					return
				}
		Mapping := {C : "_MouseLeave", Fa : "_FocusReceived", fb : "_FocusLost", M : "_Marquee", Sa : "_ScrollingStart", sb : "_ScrollingEnd"} ;Case insensitivity strikes back!
		for Event, Function in Mapping
			if(A_GuiEvent == SubStr(Event, 1, 1))
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]()
					if(!Critical)
						Critical, Off
					return
				}
		if(A_GuiEvent == "I")
		{
			if(InStr(ErrLevel, "S"))
			{
				if(LV_GetCount("Selected") = 1)
				{
					this.ProcessControlVisibility(this._.PreviouslySelectedItem, this.SelectedItem)
					this._.PreviouslySelectedItem := this.SelectedItem
				}
				else
				{
					this.ProcessControlVisibility(this._.PreviouslySelectedItem, "")
					this._.PreviouslySelectedItem := ""
				}
			}
			Mapping := { Sa : "_ItemSelected", sb : "_ItemDeselected", Fa : "_ItemFocused", fb : "_ItemDefocused", Ca : "_ItemChecked", cb : "_ItemUnChecked"} ;Case insensitivity strikes back!
			for Event, Function in Mapping
				if(InStr(ErrLevel, SubStr(Event, 1, 1), true))
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
						if(!Critical)
							Critical, Off
					}
			Mapping := {S : "_SelectionChanged", C : "_CheckedChanged", F : "_FocusedChanged"}
			for Event, Function in Mapping
				if(InStr(ErrLevel, Event, false) = 1)
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](this._.Items.IndependentSorting ? this.CItems.CRow.GetUnsortedIndex(A_EventInfo, this.hwnd) : A_EventInfo)
					}
			if(!Critical)
				Critical, Off
			return
		}
	}
}