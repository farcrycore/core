<cfcomponent extends="forms" displayname="TinyMCE Configuration" output="false" 
	hint="Configuration for the TinyMCE rich text editor. This is an ADVANCED configuration that requires an understanding of Javascript and tinyMCEs peculiarities."
	key="tinymce">
	
	<cfproperty 
		name="bUseConfig" type="boolean" default="0" hint="Enables the conifg."
		ftSeq="1" ftFieldset="Rich Text Editor Configuration" ftLabel="Enable Config"
		fthint="Check the box if you want to override the default Javascript config settings with those of your own. DANGER Will Robinson..."
		fthelptitle="Advanced Rich Text Editor Configuration" 
		ftHelpSection="FarCry comes with an implementation of the popular TinyMCE 4.x rich text editor. You can override the default configuration by activating this configuration and supplying your own configuration settings." />
		
	<cfproperty 
		name="tinyMCE_config" type="longchar" hint="The config" 
		ftSeq="2" ftFieldset="Rich Text Editor Configuration" ftLabel="TinyMCE 4.x Config" 
		fthint="The configuration should be written in the Javascript notation for TinyMCE outlined at http://www.tinymce.com/wiki.php/Configuration. There is no need to nominate the tinyMCE.init function, just its contents."
		ftStyle="width:500px;height:300px;" />

</cfcomponent>