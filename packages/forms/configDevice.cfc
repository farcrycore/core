<cfcomponent displayname="Device Configuration" extends="forms" key="device" output="false"
	hint="Configure client device settings and preview options">

	<cfproperty name="desktopWidth" type="string" default="1050" required="false"
		ftSeq="1" ftFieldset="Device Widths" ftLabel="Desktop Width"
		ftType="string" 
		ftHint="e.g. 1050"
		ftHelpSection="Configure the screen width (in pixels) for previewing content as a particular device type.">

	<cfproperty name="tabletWidth" type="string" default="768" required="false"
		ftSeq="2" ftFieldset="Device Widths" ftLabel="Tablet Width"
		ftType="string" 
		ftHint="e.g. 768">

	<cfproperty name="mobileWidth" type="string" default="480" required="false"
		ftSeq="3" ftFieldset="Device Widths" ftLabel="Mobile Width"
		ftType="string" 
		ftHint="e.g. 480"
		ftRenderWebskinAfter="editDeviceWebskins">


</cfcomponent>