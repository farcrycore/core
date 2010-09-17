<cfsetting enablecfoutputonly="yes" />
<!--- 
@@description: Register a JS library into the application:
 --->

<cfif not thisTag.HasEndTag>
	<cfabort showerror="skin:registerJS requires an end tag." />
</cfif>

<cfif thistag.executionMode eq "Start">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "End">
	<cfparam name="attributes.id" default=""><!--- The id of the library that has been registered with the application --->
	<cfparam name="attributes.lCombineIDs" default=""><!--- A list of registered JS ids, to be included in this library --->
	<cfparam name="attributes.baseHREF" default=""><!--- The url baseHREF to the JS files--->
	<cfparam name="attributes.lFiles" default=""><!--- The files to include in that baseHREF --->
	<cfparam name="attributes.condition" default=""><!--- the condition to wrap around the style tag --->
	<cfparam name="attributes.prepend" default=""><!--- any JS to prepend to the begining of the script block --->
	<cfparam name="attributes.append" default=""><!--- any JS to append to the end of the script block --->
	<cfparam name="attributes.bCombine" default="true"><!--- Should the files be combined into a single cached js file. --->
	
	<cfif len(trim(thisTag.generatedContent))>
		<cfset attributes.append = "#attributes.append##thisTag.generatedContent#" />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfset application.fapi.registerJS(argumentCollection=attributes) />
	
</cfif>

<cfsetting enablecfoutputonly="no" />