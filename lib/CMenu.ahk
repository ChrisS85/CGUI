Class CMenu
{
	static Menus := [] ;All menu objects are stored statically in CMenu for easier callback routing. This means that all submenus must have unique names.
	
	__New(Name)
	{
		global CGUI
		this.Name := Name
		if(!CGUI_Assert(!this.Menus.HasKey(Name), "Menu Name" Name " is not unique! Submenus must have unique names!"))
			return
		this.Menus[Name] := this
		;Add a temporary menu entry and delete it again to create an empty menu
		Menu, % this.Name, Add, Test, CMenu_Callback
		Menu, % this.Name, Delete, Test
	}
	
	AddSubMenu(Text, NameOrMenuObject)
	{
		if(CGUI_TypeOf(NameOrMenuObject) = "CMenu")
			Menu := NameOrMenuObject
		else if(!IsObject(NameOrMenuObject))
			Menu := new this(NameOrMenuObject)
		else
			CGUI_Assert(0, "Invalid parameter NameOrMenuObject: " NameOrMenuObject " in CMenu.AddSubmenu()", -1)
		if(CGUI_TypeOf(Menu) = "CMenu")
		{
			Menu.Insert("Text", Text)
			Menu.Insert("Parent", this.Name)
			this.Insert(Menu)
			Menu, % this.Name, Add, %Text%, % ":" Menu.Name
		}
		else
			CGUI_Assert(0, "Failed to create submenu")
	}
	AddMenuItem(Text, Callback = "")
	{
		this.Insert(new this.CMenuItem(Text, this.Name, Callback))
	}
	AddSeparator()
	{
		Menu, % this.Name, Add
	}
	RouteCallback()
	{
		global CGUI
		Item := this.Menus[A_ThisMenu][A_ThisMenuItemPos]
		if(IsObject(Item) && Item.HasKey("Callback"))
		{
			GUI := CGUI.GUIList[A_GUI ? A_GUI : this.LastGUI]
			GUI[Item.Callback]()
		}
	}
	__Set(Name, Value)
	{
		if(Name = "Text")
		{
			if(CGUI_Assert(CGUI_TypeOf(this.Menus[this.Parent]) = "CMenu", "Can't set Text on a menu object that is no submenu."))
			{
				Menu, % this.Menus[this.Parent].Name, Rename, % this.Text, %Value%
				this.Insert("Text", Value)
			}
		}
	}
	Show(GUINum, X="", Y="")
	{
		this.Base.LastGUI := GUINum
		Menu,% this.Name, Show, %X%, %Y%
	}
	Class CMenuItem
	{
		__New(Text, Menu, Callback="")
		{
			this.Text := Text
			this.Callback := Callback
			this.Menu := Menu
			Menu, % this.Menu, Add, %Text%, CMenu_Callback
		}
		__Set(Name, Value)
		{
			if(Name = "Text")
			{
				Menu, % this.Menu, Rename, % this.Text, %Value%
				this.Insert("Text", Value)
			}
		}
	}
}

CMenu_Callback:
CMenu.RouteCallback()
return