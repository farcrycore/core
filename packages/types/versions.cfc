<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/versions.cfc,v 1.4 2005/10/11 07:14:52 guy Exp $
$Author: guy $
$Date: 2005/10/11 07:14:52 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Component Versions Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
--->
<cfcomponent extends="farcry.farcry_core.packages.types.types" bAbstract="true" displayname="Versions Abstract Class" hint="Provides default properties and handlers for content object types using farcry versioning.  This component should never be instantiated directly -- it should only be inherited.">
<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="" />

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	

	<!--- // STATUS: versions status changing methods --->
	<cffunction name="statustodraft" access="public" returntype="struct" hint="Sends object to draft state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- delete underlying draft if it exists
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustodraft()>
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustopending" access="public" returntype="struct" hint="Sends object to pending state." output="false">
	<!--- 	
	// TODO: 
		probably nothing to do here but super
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustopending>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustoapproved" access="public" returntype="struct" hint="Sends object to approved state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- archive current live
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustoapproved()>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
 		<cfreturn stResult>
	</cffunction>

	<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="the default set friendly url for an object." output="true">
		<cfargument name="stProperties" required="true" type="struct">
		
		<cfset var stLocal = structnew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cfset stLocal.stFriendlyURL = StructNew()>
		<cfset stLocal.stFriendlyURL.objectid = arguments.stProperties.objectid>
		<cfset stLocal.stFriendlyURL.friendlyURL = "">
		<cfset stLocal.stFriendlyURL.querystring = "">

		<cfset stLocal.objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
		<!--- used to retrieve default of where item is in tree --->
		<cfset stLocal.objNavigation = CreateObject("component","#Application.packagepath#.types.dmnavigation")>

		<!--- This determines the friendly url by where it sits in the navigation node  --->
		<cfset stLocal.qNavigation = stLocal.objNavigation.getParent(arguments.stProperties.objectid)>

		<cfif stLocal.qNavigation.recordcount>
			<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.objFU.createFUAlias(stLocal.qNavigation.objectid)>
		<cfelse> <!--- generate friendly url based on content type --->
			<cfif StructkeyExists(application.types[arguments.stProperties.typename],"displayName")>
				<cfset stLocal.stFriendlyURL.friendlyURL = "/#application.types[arguments.stProperties.typename].displayName#">
			<cfelse>
				<cfset stLocal.stFriendlyURL.friendlyURL = "/#ListLast(application.types[arguments.stProperties.typename].name,'.')#">
			</cfif>
		</cfif>

		<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.stFriendlyURL.friendlyURL & "/#arguments.stProperties.label#">
		<cfset stLocal.objFU.setFU(stLocal.stFriendlyURL.objectid, stLocal.stFriendlyURL.friendlyURL, stLocal.stFriendlyURL.querystring)>

 		<cfreturn stLocal.returnstruct>
	</cffunction>
</cfcomponent>

