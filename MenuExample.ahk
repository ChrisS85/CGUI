SetBatchlines, -1
MyWindow := new CMyWindow("first") ;Create an instance of this window class
;~ MySecondWindow := new CMyWindow("second") ;Create a second instance of this window class
return

#include <CGUI>
Class CMyWindow Extends CGUI
{
	EditTest := this.AddControl("Button", "EditTest", "", "")
	__New(Title)
	{
		this.Title := Title
		this.Resize := true
		this.MinSize := "500x200"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		Menu1 := new CMenu("Main")
		Menu1.AddMenuItem("hello", "test")
		Menu1[1].Text := "Test"
		Menu1[1].Checked := true
		Menu1[1].Enabled := false
		Menu1.AddSubMenu("sub1", "Test")
		Menu1[2].AddMenuItem("blup", "blup")
		sub2 := New CMenu("sub2")
		sub2.AddMenuItem("blah", "blah")
		Menu1.AddSubMenu("sub2", sub2)
		sub2.Icon := "C:\Program Files\Autohotkey\SciTE_beta5\AutoHotkey.exe"
		Menu1.DeleteMenuItem(1)
		this.EditTest.Menu := Menu1
		;~ this.Menu(this.Menu1) ;Menu can't be used for context and menu bar at once...
		this.Show("")
	}
	EditTest_ContextMenu()
	{
		MsgBox menu
		;~ this.ShowMenu(this.Menu1)
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