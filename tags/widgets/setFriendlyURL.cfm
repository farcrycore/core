<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.objectid" default="">
<cfparam name="attributes.querystring" default="">
<cfparam name="attributes.customFriendlyURL" default="">

<cfset stFriendlyURL = StructNew()>
<cfset stFriendlyURL.objectid = attributes.objectid>
<cfset stFriendlyURL.friendlyURL = "">
<cfset stFriendlyURL.querystring = attributes.querystring>

<cfset objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
<cfset objNavigation = CreateObject("component","#Application.packagepath#.types.dmNavigation")>
<cfif stFriendlyURL.objectid NEQ "">
	<!---
	The stFriendlyURL.friendlyURL can be what ever you want just as long as it starts with #application.config.fusettings.urlpattern#
	eg. #application.config.fusettings.urlpattern#my_funky_contentname/my_funky_keywords/unique_id" but each url needs to be unique
	[note if customFriendlyURL (also each customFriendlyURL must be unique) not passed in, the FriendlyURL will generated based on where it sits in the navigation]
	--->

	<cfif attributes.customFriendlyURL EQ "">
		<!--- This determines the friendly url by where it sits in the navigation node  --->		
		<cfset qNavigation = objNavigation.getParent(attributes.objectid)>
		<cfif qNavigation.recordcount>
			<cfset stFriendlyURL.navigationParentID = qNavigation.objectid>
			<cfset stFriendlyURL.friendlyURL = objFU.createFUAlias(stFriendlyURL.navigationParentID)>
		</cfif>
		<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & "/#stFriendlyURL.objectid#">
	<cfelse>
		<cfset stFriendlyURL.friendlyURL = application.config.fusettings.urlpattern & attributes.customFriendlyURL>
	</cfif>

	<cfset objFU.setFU(stFriendlyURL.objectid, stFriendlyURL.friendlyURL, stFriendlyURL.querystring)>
	<cfset objFU.updateAppScope()>
</cfif>

<cfsetting enablecfoutputonly="no">