<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/navajo/displayPrinterFriendly.cfm,v 1.6 2004/07/15 02:03:00 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:00 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
-> objectid: objectid of item to display 
<- [er]: outbound var or caller var

|| HISTORY ||
$Log: displayPrinterFriendly.cfm,v $
Revision 1.6  2004/07/15 02:03:00  brendan
i18n updates

Revision 1.5  2003/08/12 02:05:49  brendan
cgi.http_host variable used to show current page

Revision 1.4  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.3  2003/04/08 08:40:11  paul
CFC security updates

Revision 1.2  2002/10/08 05:20:17  brendan
no message

Revision 1.1  2002/10/01 01:24:07  brendan
no message



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
		<cfabort showerror="#application.adminBundle[session.dmProfile.locale].errorNavNodeNoContent#">
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
<cfscript>
	oAuthorisation = request.dmSec.oAuthorisation;
	oAuthentication = request.dmSec.oAuthentication;
</cfscript>


<cfif isDefined("request.navid")>
	<cfscript>
		iHasViewPermission = oAuthorisation.checkInheritedPermission(permissionName="view",objectid=request.navid,lpolicyGroupIds=lpolicyGroupIds);
	</cfscript>
	
	<cfif iHasViewPermission neq 1>
	<!--- log out the user --->
		<cfscript>
			oAuthentication.logout();
		</cfscript>
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
	
	<!---------------------------
	Build floatMenu, as required 
	TODO:
	This should respond to request.mode settings and not require a
	a whole new set of permission checks
	---------------------------->
	<!--- begin: logged in user? --->
	<cfscript>
		stLoggedInUser = oAuthentication.getUserAuthenticationData();
		bLoggedIn = stLoggedInUser.bLoggedIn;
	</cfscript>
	
	<cfif bLoggedIn>
	<!--- check they are admin --->
	<cfscript>
		iAdmin = oAuthorisation.checkPermission(permissionName="Admin",reference="PolicyGroup");
		iCanCommentOnContent = oAuthorisation.checkInheritedPermission(permissionName="CanCommentOnContent",objectid=request.navid);
	</cfscript>
	
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
	</cfif> --->
	
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
	<!--- <cfif request.mode.design>
		<!--- set the users container management permission --->
		<cfif isDefined("request.navid")>
			<cf_dmSec2_PermissionCheck 
				permissionName="ContainerManagement" 
				objectId="#request.navid#" 
				r_iState="request.mode.showcontainers" 
				reference1="dmNavigation">
		</cfif>
	</cfif> --->

	<!--- output printerfriendly display --->
	<nj:importCSS>
	<cfoutput>
	<div class="title">#stObj.Title#</div>
	<p></p>
	<div class="contentbody" style="width:600px">
		#stObj.Body#
		<p></p>
		<b>http://#cgi.http_host##application.url.conjurer#?objectid=#url.objectid#</b>
	</div>
	</cfoutput>
	
		
<cfelse>
	<cfabort showerror="#application.adminBundle[session.dmProfile.locale].badCOAPI#">
</cfif> 
<!--- end: of if object exists... --->

<cfsetting enablecfoutputonly="No">

