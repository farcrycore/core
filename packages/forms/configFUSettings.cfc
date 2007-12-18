<cfcomponent displayname="Friendly URL Config" hint="Configuration for Friendly urls" extends="forms" output="false" key="fusettings">
	<cfproperty ftSeq="1" ftFieldset="" name="Domains" type="string" default="" ftDefaultType="Evaluate" ftDefault="cgi.SERVER_NAME" hint="The user login" ftLabel="Domains" />
	<cfproperty ftSeq="2" ftFieldset="" name="urlPattern" type="string" default="/go/" hint="The URL Pattern" ftLabel="URL Pattern"  />
	<cfproperty ftSeq="3" ftFieldset="" name="suffix" type="string" default="" hint="Suffix" ftLabel="Suffix"  />
	<cfproperty ftSeq="4" ftFieldset="" name="sesurls" type="string" default="no" hint="Suffix"  ftLabel="Suffix"  />
	<cfproperty ftSeq="5" ftFieldset="" name="lExcludeNavAlias" type="string" default="" hint="Nav Alias's to exclude"  ftLabel="Nav Alias's to Exclude"  />
	<cfproperty ftSeq="6" ftFieldset="" name="lExcludeObjectIDs" type="string" default="" hint="Object ID's to exclude"  ftLabel="Object ID's to exclude"  />
	
</cfcomponent>