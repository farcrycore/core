<cfcomponent extends="forms" displayname="Form Theme Configuration" output="false"
	key="formtheme"
	hint="Configuration for the markup rendering of forms">


	<cfproperty name="webtop" type="string" required="false" default="bootstrap" 
		ftSeq="10" ftFieldset="Form Theme Properties" ftLabel="Webtop Forms" 
		ftType="list" ftListData="getFormThemeListData"
		ftHint="Form markup for forms used in the webtop.">

	<cfproperty name="site" type="string" required="false" default="uniform" 
		ftSeq="20" ftFieldset="Form Theme Properties" ftLabel="Front-end Forms" 
		ftType="list" ftListData="getFormThemeListData"
		ftHint="Form markup for forms used in the front-end of the web site.">


	<cffunction name="getFormThemeListData">
		<cfset var lResult = "">
		<cfset var lFormThemes = "">
		<cfset var item = "">
		<cfset var formTheme = "">

		<cfloop collection="#application.forms#" item="item">
			<cfif reFindNoCase("^formTheme.+$", item)>
				<cfset lFormThemes = listAppend(lFormThemes, item)>
			</cfif>
		</cfloop>

		<cfset lFormThemes = listSort(lFormThemes, "text")>

		<cfloop list="#lFormThemes#" index="item">
			<cfset formTheme = replaceNoCase(item, "formTheme", "")>
			<cfif len(formTheme)>
				<cfset lResult = listAppend(lResult, formTheme & ":" & application.fapi.getContentTypeMetadata(item, "displayname", formTheme))>
			</cfif>
		</cfloop>

		<cfreturn lResult>
	</cffunction>


</cfcomponent>