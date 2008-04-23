<cfcomponent displayname="TinyMCE configuration" hint="Configuration for the TinyMCE rich text editor" extends="forms" output="false" key="tinymce">
	<cfproperty ftSeq="1" ftWizardStep="" ftFieldset="" name="bUseConfig" type="boolean" default="0" ftLabel="Use this config" hint="Should the system use this config" />
	<cfproperty ftSeq="2" ftWizardStep="" ftFieldset="" name="tinyMCE_config" type="longchar" ftLabel="Tiny MCE config" hint="The config" ftStyle="width:400px;height:200px;"/>

</cfcomponent>