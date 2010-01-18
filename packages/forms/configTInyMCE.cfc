<cfcomponent extends="forms" displayname="TinyMCE Configuration" output="false" 
	hint="Configuration for the TinyMCE rich text editor"
	key="tinymce">
	
	<cfproperty 
		name="bUseConfig" type="boolean" default="0" hint="Should the system use this config"
		ftSeq="1" ftFieldset="Configuration Activation" ftLabel="Enable Config"
		fthint="Check the box if you want to override the default settings with those included below."
		fthelptitle="Default Rich Text Editor Configuration" 
		ftHelpSection="FarCry comes with an implementation of the popular TinyMCE rich text editor. You can override the default configuration by activating this configuration and supplying your own configuration settings." />
		
	<cfproperty 
		name="tinyMCE_config" type="longchar" hint="The config" 
		ftSeq="2" ftFieldset="Configuration Settings" ftLabel="TinyMCE Config" 
		fthint="The configuration should be written in the Javascript notation for TinyMCE outlined at http://wiki.moxiecode.com/index.php/TinyMCE:Configuration  
		For example:
		theme : ""advanced""
		There is no need to nominate the tinyMCE.init function, just its contents.
		Please note that the config item MODE is always set to exact and cannot be changed. All other configuration items are available.
		 "
		ftStyle="width:500px;height:300px;" />

</cfcomponent>