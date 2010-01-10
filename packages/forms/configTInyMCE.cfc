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
		tinyMCE.init({
			theme : ""advanced"",
			mode : ""textareas""
		});
		There is no need to nominate the tinyMCE.init function, just its contents.
		 "
		ftStyle="width:500px;height:300px;" />

</cfcomponent>