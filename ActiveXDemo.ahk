Window := new CActiveXDemo("ActiveXDemo")
return
#include <CGUI>
Class CActiveXDemo Extends CGUI
{
	__New(title)
	{
		base.__New()
		this.Title := Title
		this.Add("ActiveX", "ie", "w800 h600", "Shell.Explorer")
		this.ie.Navigate("http://www.google.com")
		this.DestroyOnClose := true
		this.Show()
	}
	ie_NavigateComplete2(pDisp, URL)
	{
		if(InStr(URL, "google")) ;Prohibit using google :D
			this.ie.Navigate("http://www.microsoft.com")
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
}