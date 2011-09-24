SetBatchlines, -1
MyWindow := new CBasicWindow("Demo") ;Create an instance of this window class
return

#include <CGUI>
Class CBasicWindow Extends CGUI
{
	;Controls can be defined as class variables at the top of the class like this:
	btnButton := this.AddControl("Button", "btnButton", "", "button") 
	__New(Title)
	{
		;Set some window properties
		this.Title := Title
		this.Resize := true
		this.MinSize := "200x150"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		;Add a control dynamically
		this.editField := this.AddControl("Edit", "editField", "w100", "Some data")
		
		;Show the window
		this.Show("")
	}
	
	;Called when the button is clicked
	btnButton_Click()
	{
		;Set text of the edit control
		this.editField.Text := "Button was clicked"
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
}

;Required to handle control events
CBasicWindow_btnButton:
CGUI.HandleEvent()
return