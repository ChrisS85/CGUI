gui := new ScriptLauncher()
#include <CGUI>
Class ScriptLauncher Extends CGUI
{
	__New()
	{
		Base.__New()
		this.Add("ListView", "listView1", "x12 y40 w334 h217", "")
		
		this.Add("Button", "button1", "x271 y12 w75 h23", "Browse")
		
		this.Add("Edit", "textBox1", "x12 y14 w253 h20", "")
		
		this.Add("StatusBar", "statusStrip1", "w356 h22", "statusStrip1")
		
		this.Events := ""
		this.height := 299
		this.Title := "ScriptLauncher"
		this.Show()
	}
	button1_Click()
	{
		
	}
}
ScriptLauncher_button1:
CGUI.HandleEvent()
return