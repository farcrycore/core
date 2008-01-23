<cfparam name="objectid" default="">
<cfparam name="typename" default="">

<cfsetting showdebugoutput="false">

<cfif objectID NEQ "" AND typename NEQ "">
	<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
	<cfinclude template="/farcry/core/admin/includes/json.cfm">
	<cfset objType = CreateObject("component","#application.types[typename].typepath#")>
	<cfset stObject = objType.getData(objectid)>
	<cfset stReturnObject = StructNew()>
	<cfset stReturnObject.objectid = objectid>
	<cfset stReturnObject.label = stObject.label>
	<cfswitch expression="#typename#">
		<cfcase value="dmImage">
			<cfset stReturnObject.imageURL = StructNew()>
			<cfset stReturnObject.imageURL.thumb = objType.getURLImagePath(objectid,"thumb")>
			<cfset stReturnObject.imageURL.original = objType.getURLImagePath(objectid,"original")>
			<cfset stReturnObject.imageURL.optimised = objType.getURLImagePath(objectid,"optimised")>
		</cfcase>
	</cfswitch>
	<cfcontent type="text/plain"><cfoutput>
#jsonencode(stReturnObject)#</cfoutput>
</cfif>