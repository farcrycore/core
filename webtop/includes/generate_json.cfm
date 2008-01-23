<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfparam name="objectid" default="">
<cfparam name="templatename" default="">
<cfparam name="typename" default="">
<cfif objectid NEQ "" AND typename NEQ "" AND templatename NEQ "">
	<!--- include the json encode/decode functions --->
	<cfinclude template="/farcry/core/webtop/includes/json.cfm">
	<cfset objTypes = CreateObject("component","#application.types[typename].typepath#")>
	<!--- generate the html to insert --->
	<cfsavecontent variable="json_content">
		<cfset objTypes.getDisplay(objectid, templatename)>
	</cfsavecontent>
	<cfset json_content = jsstringformat(json_content)>
<cfcontent type="text/plain"><cfoutput>
#jsonencode(json_content)#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">