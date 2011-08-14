/*
Class: CGroupBoxControl
A GroupBox control. Nothing special.
*/
Class CGroupBoxControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "GroupBox"
		;No styles here for now, why would you want them?
	}
}