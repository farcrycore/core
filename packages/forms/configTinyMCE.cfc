<cfcomponent extends="forms" displayname="TinyMCE Configuration" output="false" 
	hint="Advanced configuration for the TinyMCE rich text editor"
	key="tinymce">
	
	<cfproperty 
		name="bUseConfig" type="boolean" default="0" hint="Enables the conifg."
		ftSeq="1" ftFieldset="Rich Text Editor Configuration" ftLabel="Enable Config"
		fthint="Check the box if you want to override the default settings with those included below."
		fthelptitle="Advanced Rich Text Editor Configuration" 
		ftHelpSection="FarCry comes with an implementation of the popular TinyMCE 4.x rich text editor. You can override the default configuration by activating this configuration and supplying your own configuration settings." />
		
	<cfproperty 
		name="tinyMCE4_config" type="longchar" hint="The config" 
		ftSeq="2" ftFieldset="Rich Text Editor Configuration" ftLabel="TinyMCE 4.x Config" 
		fthint="The configuration should be written in the JavaScript notation for TinyMCE outlined at http://www.tinymce.com/wiki.php/Configuration There is no need to nominate the tinyMCE.init function, just its contents."
		ftStyle="max-width: 600px; height: 200px" />

</cfcomponent>