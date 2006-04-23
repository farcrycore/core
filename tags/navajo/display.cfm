<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/display.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Geoff Bowers (modius@daemon.com.au)

|| ATTRIBUTES ||
-> [um]: inbound var or attribute 
<- [er]: outbound var or caller var

|| HISTORY ||
$Log: display.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.14  2002/09/22 21:24:08  geoff
fixed - view permissions now based on default and loggedin policy groups

Revision 1.13  2002/09/18 01:03:28  geoff
no message

Revision 1.12  2002/09/17 00:39:06  geoff
no message

Revision 1.11  2002/09/10 23:52:56  geoff
no message

Revision 1.10  2002/09/06 05:49:06  geoff
updated request.mode settings

Revision 1.9  2002/09/06 01:02:17  geoff
allows anonymous login

Revision 1.8  2002/09/01 23:55:49  geoff
working on display modes - with menuFloat

Revision 1.7  2002/08/30 05:44:59  geoff
working on display modes

Revision 1.6  2002/08/27 13:14:14  geoff
admin floater menu now floating.. menu items still incorrect

Revision 1.5  2002/08/27 06:44:19  geoff
general bug fixes... see comments

Revision 1.4  2002/08/27 01:06:40  geoff
display custom tag now works - much work to do yet

Revision 1.3  2002/08/22 05:13:37  geoff
no message

Revision 1.2  2002/08/22 00:09:38  geoff
no message

Revision 1.1  2002/07/16 07:25:21  geoff

|| END FUSEDOC ||
--->

<!--- method for dealing with the missing url param... redirect to home page --->
<cfif not isDefined("url.objectId")>
	<cfif isDefined("application.navid.home")>
		<cfset url.objectid = application.navid.home>
		<cftrace var="application.navid.home" text="home UUID set">
	<cfelse>
		<cflocation url="#application.url.farcry#/" addtoken="No">
	</cfif>
</cfif>

<!--- grab the object we are displaying --->
<cftry>	  
	<q4:contentobjectget objectid="#url.ObjectID#" r_stobject="stObj">
	<CFCATCH type="Any">
		<cflocation url="#application.url.farcry#/" addtoken="No">
		<!--- TODO: 
		log this error if it occurs 
		or perhaps provide URL 404 type error for user
		--->
		<cfabort>
	</CFCATCH>
</cftry>

<!--- if we are displaying a navigation point, get the first approved object to display --->
<cfif 
	stObj.typename eq "dmNavigation"
	AND structKeyExists(stObj,"aObjectIds")
	AND arrayLen(stObj.aObjectIds)>
	
	<cfloop index="idIndex" from="1" to="#arrayLen(stObj.aObjectIds)#">
		<q4:contentobjectget objectid="#stObj.aObjectIds[idIndex]#" r_stobject="stObjTemp">
		<!--- request.lValidStatus is approved, or draft, pending, approved in SHOWDRAFT mode --->
		<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status)>
			<!--- set the navigation point for the child obj --->
			<cfset request.navid = stObj.objectID>
			<!--- reset stObj to appropriate object to be displayed --->
			<cfset stObj = stObjTemp>
			<!--- end loop now --->
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- if request.navid is not set, then no valid objects available for 
	this node. --->
	<cfif NOT isDefined("request.navid")>
		<cfabort showerror="Error: This navigation node has no viewable content attached. If you believe that some content should exist at this point it is more than likely that it is in DRAFT and needs to be approved..">
	</cfif>

<!--- else get the navigation point from the URL --->
<cfelseif isDefined("url.navid")>
	<!--- ie. this is a dynamic object looking for context --->
	<cfset request.navid = url.navid>

<!--- otherwise get the navigation point for this object --->
<cfelse>
	<nj:GetNavigation objectId="#stObj.objectId#" r_stobject="stNav">
	<!--- if the object is in the tree this will give us the node --->
	<cfif isDefined("stNav.objectid") AND len(stNav.objectid)>
		<cfset request.navid = stNav.objectID>
	
	<!--- otherwise, use the home node as a last resort --->
	<cfelse>
		<cfset request.navid = application.navid.home>
	</cfif>
</cfif>

<!--- 
check security,... 
remember security is applied through the tree navigation point *not*
the individual object being rendered.
lpolicyGroupIds="#application.dmsec.ldefaultpolicygroups#"
the latter is the policy group for anonymous...
--->
<cfif isDefined("session.dmsec.lPolicyGroupIDs")>
	<!--- concatenate logged in group permissions with anonymous group permissions --->
	<cfset lpolicyGroupIds = session.dmsec.lPolicyGroupIDs & "," & application.dmsec.ldefaultpolicygroups>
<cfelse>
	<!--- user not logged in, assume anonymous permissions --->
	<cfset lpolicyGroupIds = application.dmsec.ldefaultpolicygroups>
</cfif>

<cfif isDefined("request.navid")>
	<cf_dmSec2_PermissionCheck 
		permissionName="View" 
		objectId="#request.navid#" 
		r_iState="iHasViewPermission" 
		reference1="dmNavigation"
		lpolicyGroupIds="#lpolicyGroupIds#">
	
	<cfif iHasViewPermission neq 1>
	<!--- log out the user --->
	<cf_dmSec_logout>
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
		<cfabort>
	</cfif>

<cfelse>
	<cfdump var="#stObj#" label="Object Structure for stObj">
	<cfdump var="#request#" label="Request Scope">
	<cfabort showerror="Error: no navigational context could be established for this object.">
	<!--- <cfset request.navid = application.navid["home"]> --->
</cfif>

<!--- <cfdump var="#stObj#" label="Object Structure for stObj"> --->

<cfif IsStruct(stObj) and not StructIsEmpty(stObj)>
	<cfscript>
	// fake a typeID for the tree code
		typename = stObj.typename;
		//SetVariable("stObj.TYPEID", Evaluate("application.#typename#TypeID"));
	</cfscript>
	
	<!---------------------------
	Build floatMenu, as required 
	TODO:
	This should respond to request.mode settings and not require a
	a whole new set of permission checks
	---------------------------->
	<!--- begin: logged in user? --->
	<cf_dmSec_loggedIn r_bLoggedIn="bLoggedIn">
	
	<cfif bLoggedIn>
	<!--- check they are admin --->
	<cf_dmSec2_PermissionCheck
		permissionName="Admin"
		reference1="PolicyGroup"
		targetType="PolicyGroup"
		r_iState="iAdmin">
	
	<!--- check they are able to comment --->
	<cf_dmSec2_PermissionCheck 
		permissionName="CanCommentOnContent" 
		objectId="#request.NavID#" 
		r_iState="iCanCommentOnContent" 
		reference1="dmNavigation">
	
	<cfif iAdmin eq 1 or iCanCommentOnContent eq 1>
		<cfset request.floaterIsOnPage = true>
		<cfinclude template="floatMenu.cfm">
	</cfif>
	</cfif>
	<!--- end: logged in user? --->
		
	<!--- Setup page caching (cached on objectID of page) --->
	<cfparam name="stObj.PageType" default="">
	<cfif isDefined("url.displayMethod")>
		<cfset stObj.displayMethod=url.displayMethod>
	</cfif>
	
	<!--- 
	TODO:
	This session is supposed to persist the parameter state of the 
	admin user, we need to:
	 - persist all parameters this way
	 - not sure that desmodedisplay is going to be used at all in farcry 
	
	 
	<cflock timeout="10" throwontimeout="Yes" type="READONLY" scope="SESSION">
		<cfif isdefined("session.designmodedisplay") and session.designmodedisplay>
			<cfset DesModeDisplay = true>
		<cfelse>
			<cfset DesModeDisplay = false>
		</cfif>
	</cflock>
	--->
	
	<!--- 
	If the user has admin priveleges and this page has a nav node,
	check the containermanagement permissions and set request.mode.design
	--->
	<cfif request.mode.design>
		<!--- set the users container management permission --->
		<cfif isDefined("request.navid")>
			<cf_dmSec2_PermissionCheck 
				permissionName="ContainerManagement" 
				objectId="#request.navid#" 
				r_iState="request.mode.showcontainers" 
				reference1="dmNavigation">
		</cfif>
	</cfif>

	<!--- determine display method for object --->
	<cfif IsDefined("stObj.displayMethod") AND len(stObj.displayMethod)>
	<!--- Invoke display method of page --->
	<cftrace var="stObj.displayMethod" text="Object displayMethod used">
	<cfscript>
		// TODO: refactor object calls... for now put stOBj into request
		request.stObj = stObj;
		o = createObject("component", "#application.packagepath#.types.#stObj.typename#");
		o.getDisplay(stObj.ObjectID, stObj.displayMethod);	
	</cfscript>
	<!--- 
	pre-getDisplay()
	<q4:contentobject 
		typename="#application.fourq.packagepath#.types.#typename#"
		objectid="#stObj.objectID#"
		method="#stObj.displayMethod#"> --->
	<cfelse>	
	<!--- Invoke default display method of page --->
	<cftrace text="Default display method used">
	<q4:contentobject 
		typename="#application.packagepath#.types.#typename#"
		objectid="#stObj.objectID#"
		method="display">
	</cfif>
		
<cfelse>
	<cfabort showerror="Error: COAPI returned a malformed or empty object instance.">
</cfif> 
<!--- end: of if object exists... --->

<cfsetting enablecfoutputonly="No">

