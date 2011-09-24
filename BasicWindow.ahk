SetBatchlines, -1
MyWindow := new CBasicWindow("Demo") ;Create an instance of this window class
return

#include <CGUI>
Class CBasicWindow Extends CGUI
{
	btnButton := this.Add("Button", "btnButton", "", "button") ;Defining controls like this is also possible now!
	__New(title)
	{
		;Set some window properties
		this.Title := Title
		this.Resize := true
		this.MinSize := "200x150"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		;Add a control
		this.Add("Edit", "editField", "w100", "Some data")
		
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