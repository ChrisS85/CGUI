gui := new NoteExample()
#include <CGUI>
;json modifies #Escapechar and #Commentflag unfortunately so they're restored here
#include <json>
#Escapechar ` 
#Commentflag ;
Class NoteExample Extends CGUI
{
	__New()
	{
		Base.__New() ;init CGUI
		this.j := FileExist(A_ScriptDir "\Notes.json") ? json_load(A_ScriptDir "\Notes.json") : {Categories : [], Notes : []} ;Load notes and categories
		this.Add("TreeView", "treeNoteList", "x12 y12 w214 h400", "")
		this.FillTreeView(this.j) ;Add loaded notes/categories to the TreeView
		this.SelectedTreeItem := this.treeNoteList.Items
		this.SelectedItem := this.j
		this.Add("Button", "btnAddCategory", "x12 y418 w79 h23", "Add category")
		
		this.Add("Button", "btnDelete", "x164 y418 w62 h23", "Delete")
		
		this.Add("Edit", "txtName", "x232 y12 w508 h23", "")
		
		this.Add("Edit", "txtNote", "x232 y42 w508 h400", "")
		this.txtNote.Multi := 1
		
		this.Add("Button", "btnAddNote", "x97 y418 w61 h23", "Add note")
		
		this.Title := "NoteExample"
		this.DestroyOnClose := true ;By Setting this the window will destroy itself when the user cloeses it
		this.Show()
	}
	;Fill tree view and assign the treeview IDs to the object
	FillTreeView(j, Parent=0)
	{
		if(Parent=0) ;Root
		{
			Parent := this.treeNoteList.Items ;There is a root item of class CTreeViewControl.CItem. It's ID is 0.
			j.ID := 0
		}
		else
		{
			Parent := Parent.Add(j.Name)
			j.ID := Parent.ID
		}
		if(j.HasKey("Categories")) ;Add sub-categories
			for index, Category in j.Categories
				this.FillTreeView(Category, Parent)
		if(j.HasKey("Notes")) ;Add notes
			for index2, Note in j.Notes
				Note.ID := (Parent.Add(Note.Name)).ID		
	}
	;Triggered when the selected item in the TreeView was changed by the user or through code
	treeNoteList_ItemSelected(Item)
	{
		if(this.SelectedTreeItem.ID && this.SelectedItem.ID) ;if a note was selected before, store its text
		{
			if(!this.SelectedItem.HasKey("Categories")) ;if selected item was a note, store its text
				this.SelectedItem.Text := this.txtNote.Text
			this.SelectedItem.Name := this.txtName.Text ;store name
		}
		this.SelectedItem := this.FindItem(Item.ID)
		this.SelectedTreeItem := Item
		if(this.SelectedItem.HasKey("Categories")) ;If new item is a category
		{
			this.txtNote.Enabled := false
			this.txtNote.Text := ""
		}
		else
		{
			this.txtNote.Enabled := true
			this.txtNote.Text := this.SelectedItem.Text
		}
		this.txtName.Text := this.SelectedItem.Name ;display the name of the category/note
	}
	;Called when btnAddCategory was clicked
	btnAddCategory_Click()
	{
		if(this.SelectedItem.HasKey("Categories"))
		{
			TreeParent := this.SelectedTreeItem
			Parent := this.SelectedItem
		}
		else
		{
			TreeParent := this.SelectedTreeItem.Parent
			Parent := this.FindItem(TreeParent.ID)
		}
		SelectedTreeItem := TreeParent.Add(Name := "New category") ;Add a new item as child node
		Category := {Name : Name, Categories : [], Notes : [], ID : SelectedTreeItem.ID}
		Parent.Categories.Insert(Category)
		SelectedTreeItem.Selected := true ;This will trigger treeNoteList_ItemSelected()
	}
	;Called when btnAddNote was clicked
	btnAddNote_Click()
	{
		if(this.SelectedItem.HasKey("Categories"))
		{
			TreeParent := this.SelectedTreeItem
			Parent := this.SelectedItem
		}
		else
		{
			TreeParent := this.SelectedTreeItem.Parent
			Parent := this.FindItem(TreeParent.ID)
		}
		SelectedTreeItem := TreeParent.Add(Name := "New Note") ;Add a new item to the tree and store it
		Note := {Name : Name, Text : "Lorem ipsum", ID : SelectedTreeItem.ID}
		Parent.Notes.Insert(Note)
		SelectedTreeItem.Selected := true ;This will trigger treeNoteList_ItemSelected()
	}
	;Called when btnDelete was clicked
	btnDelete_Click()
	{
		;First delete the selected item in the custom maintained tree structure.
		Parent := this.FindItem(this.SelectedTreeItem.Parent.ID)
		if(this.SelectedItem.HasKey("Categories"))
		{
			for index, item in Parent.Categories
				if(item = this.SelectedItem)
					Parent.Categories.Remove(index)
		}
		else
		{
			for index, item in Parent.Notes
				if(item = this.SelectedItem)
					Parent.Notes.Remove(index)
		}
		this.SelectedItem := ""
		SelectedTreeItem := this.SelectedTreeItem
		this.SelectedTreeItem := ""
		SelectedTreeItem.Parent.Remove(SelectedTreeItem)
	}
	;Called when the text of txtName was changed
	txtName_TextChanged()
	{
		this.SelectedTreeItem.Text := this.txtName.Text
		this.SelectedItem.Name := this.txtName.Text
	}
	;Called when the window was destroyed (e.g. closed here)
	PostDestroy()
	{
		json_save(this.j, A_ScriptDir "\notes.json") ;Save all notes/categories
		ExitApp
	}
	;Find an item by its ID
	FindItem(ID, Root = "")
	{
		if(!ID) ;Root node
			return this.j
		if(!IsObject(Root))
			Root := this.j
		if(ID = Root.ID)
			return Root
		Loop % Root.Categories.MaxIndex()
			if(result := this.FindItem(ID, Root.Categories[A_Index]))
				return result
		Loop % Root.Notes.MaxIndex()
			if(result := this.FindItem(ID, Root.Notes[A_Index]))
				return result
		return 0		
	}
}
;The following labels are required to make the event notification functions work (until something like A_ControlHWND is implemented for g-labels)
NoteExample_treeNoteList:
NoteExample_txtNote:
NoteExample_btnAddCategory:
NoteExample_btnAddNote:
NoteExample_btnDelete:
NoteExample_txtName:
CGUI.HandleEvent()
return