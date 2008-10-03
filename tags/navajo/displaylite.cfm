<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/display.cfm,v 1.46.2.1 2005/12/10 13:38:15 paul Exp $
$Author: paul $
$Date: 2005/12/10 13:38:15 $
$Name:  $
$Revision: 1.46.2.1 $

|| DESCRIPTION ||
$Description: Primary controller for invoking the object to be rendered for the website.$
$TODO: This needs to be converted into a CFC! GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- optional attributes --->
<cfparam name="attributes.method" default="display" type="string">
<cfparam name="attributes.lmethods" default="display" type="string">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

<!--- set random wacky-tobaccy environment variables --->
<cfparam name="request.bHideContextMenu" default="false">

<!--- method for dealing with the missing url param... redirect to home page --->
<cfif not isDefined("url.objectId")>
	<cfif isDefined("application.navid.home")>
		<cfset url.objectid = application.navid.home>
		<cftrace var="application.navid.home" text="home UUID set" />
	<cfelse>
		<cflocation url="#application.url.webroot#/" addtoken="No">
	</cfif>
</cfif>

<!--- grab the object we are displaying --->
<cftry>
		<q4:contentobjectget objectid="#url.ObjectID#" r_stobject="stObj">

	<cftrace var="stobj.typename" text="object retrieved" />

	<!--- check that an appropriate result was returned from COAPI --->
	<cfif NOT IsStruct(stObj) OR StructIsEmpty(stObj)>
		<cfthrow message="#application.rb.getResource('coapi.messages.badcoapi@text','Error: COAPI returned a malformed or empty object instance')#">
	</cfif>
	<cfcatch type="Any">
		<cflocation url="#application.url.webroot#/" addtoken="No">
		<!--- $TODO:
		log this error if it occurs
		or perhaps provide URL 404 type error for user$
		--->
		<cfabort>
	</cfcatch>
</cftry>

<!--- if we are displaying a navigation point, get the first approved object to display --->
<cfif stObj.typename IS "dmNavigation">
	<!--- check for sim link --->
    <cfif len(stObj.externalLink) gt 0>
        <q4:contentobjectget objectid="#stObj.externalLink#" r_stobject="stObj">
    	<cftrace var="url.objectid" text="Setting navid to URL.objectid as external link is specified" />
		<cfset request.navid = URL.objectid>
		<!--- It is often useful to know the navid of the externalLink for use on the page that is being rendered --->
		<cfset request.externalLinkNavid = stObj.objectid>
		
		
    </cfif>

    <cfif structKeyExists(stObj,"aObjectIds")
	      AND arrayLen(stObj.aObjectIds)>

    	<cfloop index="idIndex" from="1" to="#arrayLen(stObj.aObjectIds)#">
    		<q4:contentobjectget objectid="#stObj.aObjectIds[idIndex]#" r_stobject="stObjTemp">
    		<!--- request.mode.lValidStatus is typically approved, or draft, pending, approved in SHOWDRAFT mode --->
    		<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status)>
    			<!--- if in request.mode.showdraft=true mode grab underlying draft page (if it exists). Only display if user is loggedin --->
    			<cfif IsDefined("stObjTemp.versionID") AND request.mode.showdraft AND application.security.isLoggedIn()>
    				<cfquery datasource="#application.dsn#" name="qHasDraft">
    					SELECT objectID,status from #application.dbowner##stObjTemp.typename# where versionID = '#stObjTemp.objectID#'
    				</cfquery>
    				<cfif qHasDraft.recordcount gt 0>
    					<q4:contentobjectget objectid="#qHasDraft.objectid#" r_stobject="stObjDraft">
    					<!--- reset object structure to be DRAFT object --->
    					<cfset stObjTemp = stObjDraft>
    				</cfif>
    			</cfif>
    			<!--- set the navigation point for the child obj - unless its a symnolic link in which case wed have already set navid --->
		
				<cfif isDefined("URL.navid")>
					<cftrace var="url.navid" text="URL.navid exists - setting request.navid = to url.navid" />
					<cfset request.navid = URL.navID>
				<cfelseif NOT isDefined("request.navid")>		
	    			<cfset request.navid = stObj.objectID>
	    			<cftrace var="stobj.objectid" text="URL.navid is not defined - setting to stObj.objectid" />
				</cfif>	
				
    			<!--- reset stObj to appropriate object to be displayed --->
    			<cfset stObj = stObjTemp>
    			<!--- end loop now --->
    			<cfbreak>
    		<cfelseif stObjTemp.typename neq "dmCSS">
    			<!--- no status so just show object --->
    			<!--- set the navigation point for the child obj --->
    			<cfif isDefined("URL.navid")>
    				<cfset request.navid = URL.navid>
    				<cftrace var="stobj.objectid" text="object type not CSS,URL.navid exists - setting navid = url.navid" />
    			<cfelse>
    				<cfset request.navid = stObj.objectID>		
    				<cftrace var="stobj.objectid" text="object type not CSS - setting navid = stobj.objectid" />
    			</cfif>
    			
    			<!--- reset stObj to appropriate object to be displayed --->
    			<cfset stObj = stObjTemp>
    			<!--- end loop now --->
    			<cfbreak>
    		</cfif>
    	</cfloop>
	
    	<!--- if request.navid is not set, then no valid objects available for this node. --->
    	<cfif NOT isDefined("request.navid")>
    		<!--- check if object has status --->
    		<cfif StructKeyExists(stObjTemp,"status")>
    			<!--- check if logged in --->
    			<cfif application.security.isLoggedIn()>
    				<!--- change to draft mode --->
    				<cflocation url="#cgi.script_name#?#cgi.query_string#&showdraft=1" addtoken="No">
    			<cfelse>
    				<!--- send to login page and return in draft mode --->
    				<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=draft&showdraft=1" addtoken="No">
    			</cfif>
    		</cfif>
    	</cfif>
    </cfif>
<!--- else get the navigation point from the URL --->
<cfelseif isDefined("url.navid")>
	<!--- ie. this is a dynamic object looking for context --->
	<cftrace var="url.navid" text="url.navid is defined for non dmNavigation object" />
	<cfset request.navid = url.navid>

<!--- otherwise get the navigation point for this object --->
<cfelse>
	<!--- If the user is not logged in and are trying to view a draft - request login --->
	<cfif isDefined("stobj.status")>
		<cfif stObj.status IS "DRAFT" AND NOT application.security.isLoggedIn()>
			<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=draft&showdraft=1" addtoken="No">
		</cfif>
	</cfif>
	<nj:getNavigation objectId="#stObj.objectId#" r_stobject="stNav">
	<!--- if the object is in the tree this will give us the node --->

	<cfif isDefined("stNav.objectid") AND len(stNav.objectid)>
		<cfset request.navid = stNav.objectID>
		<cftrace var="stNav.objectid" text="url.navid is not defined, getNavigation called to find navid" />

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

<!--- check permissions on the current nav node --->
<cfscript>
	iHasViewPermission = application.security.checkPermission(object=request.navid,permission="View");
</cfscript>

<!--- if the user is unable to view the object, then logout and send to login form --->
<cfif iHasViewPermission NEQ 1>
	<!--- log out the user --->
	<cfset application.factory.oAuthentication.logout()>
	<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
	<cfabort>
</cfif>

<!--- If we are in designmode then check the containermanagement permissions --->
<cfif request.mode.design>
	<!--- set the users container management permission --->
	<cfset request.mode.showcontainers = application.security.checkPermission(object=request.navid,permission="ContainerManagement")>
</cfif>

<!--- determine display method for object --->
<cfset request.stObj = stObj>
<!--- $TODO: refactor object calls... for now put stOBj into request$ --->

<cfif attributes.method neq "display" AND attributes.lmethods contains attributes.method>
	<!--- ie. if a method has been passed in deliberately and is allowed use this --->
	<cftrace var="attributes.method" text="Passed in attribute method used" />
	<q4:contentobject
		typename="#application.types[stObj.typename].typePath#"
		objectid="#stObj.ObjectID#"
		method="#attributes.method#">
	
<cfelseif IsDefined("stObj.displayMethod") AND len(stObj.displayMethod)>
	<!--- Invoke display method of page --->
	<cftrace var="stObj.displayMethod" text="Object displayMethod used" />
	
	<cfif isDefined("stArchive")>
		<cftry>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/#application.path.handler#/#stObj.typename#/#stObj.displayMethod#.cfm">
				<cfcatch>
					<!--- check to see if the displayMethod template exists --->
					<cfif NOT fileExists("#application.path.webskin#/#stObj.typename#/#stObj.displayMethod#.cfm")>
						 <cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#stObj.displayMethod#.cfm]."> 
					<cfelse>
						<cfif isdefined("url.debug")><cfset request.cfdumpinited = false><cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput><cfdump var="#cfcatch#"></cfif>
					</cfif>
				</cfcatch>
			</cftry>
		
	<cfelse>
		<cfset o = createObject("component", application.types[stObj.typename].typePath)>
		<cfset o.getDisplay(objectid=stObj.ObjectID, template=stObj.displayMethod)>
	</cfif>
<cfelse>
	<!--- Invoke default display method of page --->
	<cftrace text="Default display method used" />
	<q4:contentobject
		typename="#application.types[stObj.typename].typePath#"
		objectid="#stObj.ObjectID#"
		method="display">
</cfif>

<!---------------------------
Build floatMenu, as required
$TODO: This should respond to request.mode settings and not require a
a whole new set of permission checks, have trapped any errors and suppressed GB 20031024 $
---------------------------->
<cftry>

<cfif len(application.security.getCurrentUserID())>
	<!--- check they are admin --->
	<!--- check they are able to comment --->
	<cfscript>
		iAdmin = application.security.checkPermission(permission="Admin");
		iCanCommentOnContent = application.security.checkPermission(object=request.navid,permission='CanCommentOnContent');
	</cfscript>
	
	
	
	<cfif (iAdmin eq 1 or iCanCommentOnContent eq 1) AND NOT request.bHideContextMenu>
		<cfset request.floaterIsOnPage = true>
		<cfinclude template="floatMenu.cfm">
	</cfif>
</cfif>
<!--- end: logged in user? --->
<cfcatch>
<!--- suppress error --->
</cfcatch>
</cftry>
<cfsetting enablecfoutputonly="No">

