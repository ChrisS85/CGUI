gui := new NoteExample()
#include <CGUI>
Class NoteExample Extends CGUI
{
	__New()
	{
		Base.__New()
		this.Add("TreeView", "treeNoteList", "x12 y12 w214 h400", "")
		
		this.Add("Button", "btnAddCategory", "x12 y418 w79 h23", "Add category")
		
		this.Add("Button", "btnDelete", "x164 y418 w62 h23", "Delete")
		
		this.Add("Edit", "txtNote", "x232 y12 w508 h429", "")
		this.txtNote.Multi := 1
		
		this.Add("Button", "button1", "x97 y418 w61 h23", "Add note")
		
		this.Title := "NoteExample"
		this.Show()
	}
}
