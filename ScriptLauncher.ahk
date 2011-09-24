gui := new ScriptLauncher()
#include <CGUI>
Class ScriptLauncher Extends CGUI
{
	listView1			:= this.AddControl("ListView", "listView1", "x12 y40 w334 h217", "")
	button1			:= this.AddControl("Button", "button1", "x271 y12 w75 h23", "Browse")
	textBox1			:= this.AddControl("Edit", "textBox1", "x12 y14 w253 h20", "")
	statusStrip1	:= this.AddControl("StatusBar", "statusStrip1", "w356 h22", "Double-click a script to launch it!")
		
	__New()
	{
		this.Title := "ScriptLauncher"
		this.Show()
	}
	listView1_DoubleClick(RowNumber)
	{
		run, % this.listView1.Items[1][1]
	}
	button1_Click()
	{
		global CFileDialog
		FileDialog := new CFileDialog("Open")
		FileDialog.Filter := "*.ahk"
		if(FileDialog.Show())
		{
			
		}
	}
	textBox1_TextChanged()
	{
		
	}
}
ScriptLauncher_listView1:
ScriptLauncher_button1:
ScriptLauncher_textBox1:
CGUI.HandleEvent()
return