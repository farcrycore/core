<cfcomponent extends="forms" displayname="TinyMCE Configuration" output="false"
	hint="Advanced configuration for the TinyMCE rich text editor"
	key="tinymce">

	<cfproperty
		name="bUseConfig" type="boolean" default="0" hint="Enables the config."
		ftSeq="1" ftFieldset="Rich Text Editor Configuration" ftLabel="Enable Config"
		fthint="Check the box if you want to override the default settings with the TinyMCE 8 Config below."
		fthelptitle="Advanced Rich Text Editor Configuration"
		ftHelpSection="FarCry comes with an implementation of the TinyMCE 8 rich text editor. You can override the default configuration by activating this configuration and supplying your own configuration settings in the TinyMCE 8 Config field below." />

	<cfproperty
		name="licenseKey" type="string" default="gpl"
		ftSeq="2" ftFieldset="Rich Text Editor Configuration" ftLabel="License Key"
		fthint="TinyMCE 8 license key. Leave as 'gpl' (the default) to accept the open-source GPL terms for the self-hosted community build, or enter your commercial Tiny license key. Applied whether or not 'Enable Config' is checked." />

	<cfproperty
		name="tinyMCE8Config" type="longchar" hint="The TinyMCE 8 config"
		ftSeq="3" ftFieldset="Rich Text Editor Configuration" ftLabel="TinyMCE 8 Config"
		fthint="The configuration written in JavaScript notation for TinyMCE (the contents of tinymce.init, without the wrapper or the surrounding braces). Used in place of the defaults when 'Enable Config' is checked. See https://www.tiny.cloud/docs/tinymce/latest/"
		ftStyle="max-width: 600px; height: 200px" />

	<cfproperty
		name="tinyMCE4_config" type="longchar" hint="Deprecated TinyMCE 4 config"
		ftSeq="4" ftFieldset="Rich Text Editor Configuration" ftLabel="TinyMCE 4.x Config (deprecated)"
		fthint="DEPRECATED and no longer used since the upgrade to TinyMCE 8. Retained only so existing settings can be copied across. Migrate your configuration into the TinyMCE 8 Config field above and update it for v8."
		ftStyle="max-width: 600px; height: 200px" />

</cfcomponent>
