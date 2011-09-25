SetBatchlines, -1
MyWindow := new CMyWindow("first") ;Create an instance of this window class
;~ MySecondWindow := new CMyWindow("second") ;Create a second instance of this window class
return

#include <CGUI>
Class CMyWindow Extends CGUI
{
	EditTest := this.AddControl("Edit", "EditTest", "", "")
	__New(Title)
	{
		this.Title := Title
		this.Resize := true
		this.MinSize := "500x200"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		this.Menu1 := new CMenu("Main")
		this.Menu1.AddMenuItem("hello", "test")
		this.Menu1[1].Text := "Test"
		this.Menu1[1].Checked := true
		this.Menu1[1].Enabled := false
		this.Menu1.AddSubMenu("sub1", "Test")
		this.Menu1[2].AddMenuItem("blup", "blup")
		sub2 := New CMenu("sub2")
		sub2.AddMenuItem("blah", "blah")
		this.Menu1.AddSubMenu("sub2", sub2)
		sub2.Icon := "C:\Program Files\Autohotkey\SciTE_beta5\AutoHotkey.exe"
		this.Menu1.DeleteMenuItem(1)
		;~ this.Menu(this.Menu1) ;Menu can't be used for context and menu bar at once...
		this.Show("")
	}
	ContextMenu()
	{
		this.ShowMenu(this.Menu1)
	}
	blup()
	{
		MsgBox blup
	}
	test()
	{
		MsgBox hello
	}
	blah()
	{
		MsgBox blah
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
}