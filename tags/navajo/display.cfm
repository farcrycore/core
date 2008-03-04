<cfsetting enablecfoutputonly="Yes">
<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/navajo/display.cfm,v 1.46.2.2 2006/03/17 06:45:42 geoff Exp $
$Author: geoff $
$Date: 2006/03/17 06:45:42 $
$Name: milestone_3-0-1 $
$Revision: 1.46.2.2 $

|| DESCRIPTION ||
$Description: Primary controller for invoking the object to be rendered for the website.$
$TODO: This needs to be converted into a CFC! GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cfprocessingdirective pageencoding="utf-8" />

<!--- Tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- run once only --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<cftimer label="NAVAJO DISPLAY">
	
<cfparam name="attributes.objectid" default="" />
<cfparam name="attributes.typename" default="" />
	
<!--- optional attributes --->
<cfparam name="attributes.method" default="display" type="string">
<cfparam name="attributes.lmethods" default="display" type="string">
<cfparam name="attributes.loginpath" default="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" type="string">

<!--- make sure that the attributes.method variable is not empty --->
<cfif not len(attributes.method)>
	<cfset attributes.method = "display">
</cfif>

<cfparam name="request.bHideContextMenu" default="false">

<!--- Handle options for passing object/type in --->
<cfif not len(attributes.typename) and structkeyexists(url,"type")>
	<cfset attributes.typename = url.type />
</cfif>
<cfif not len(attributes.objectid) and structkeyexists(url,"objectid")>
	<cfset attributes.objectid = url.objectid />
</cfif>
<cfif not len(attributes.objectid) and structkeyexists(url,"view")>
	<cfset attributes.method = url.view />
</cfif>

<!--- method for dealing with the missing url param... redirect to home page --->
<cfif not len(attributes.objectid)>
	<cfif len(attributes.typename)>
		<cfset attributes.objectid = "" />
	<cfelse>
		<cfif isDefined("application.navid.home")>
			<cfset url.objectid = application.navid.home />
			<cfset attributes.objectid = application.navid.home />
		<cfelse>
			<cflocation url="#application.url.webroot#/" addtoken="No">
		</cfif>
	</cfif>
</cfif>

<cfif len(attributes.objectid)>

	<!--- grab the object we are displaying --->
	<cftry>
		<q4:contentobjectget objectid="#attributes.objectid#" r_stobject="stObj">
		
		<cftrace var="stobj.typename" text="object retrieved" />
	
		<!--- check that an appropriate result was returned from COAPI --->
		<cfif NOT IsStruct(stObj) OR StructIsEmpty(stObj)>
			<cfthrow message="#apapplication.rb.getResource("badCOAPI")#">
		</cfif>
		<cfcatch type="Any">
			<farcry:logevent object="#attributes.objectid#" type="display" event="404" />
			<cfif fileexists("#application.path.project#/errors/404.cfm")>
				<cfinclude template="#application.path.project#/errors/404.cfm" />
				<cfexit method="exittag" />
			<cfelseif isDefined("application.navid.home")>
				<cflocation url="#application.url.conjurer#?objectid=#application.navid.home#" addtoken="No" />
			<cfelse>
				<cflocation url="#application.url.webroot#/" addtoken="No">
			</cfif>
		</cfcatch>
	</cftry>
	
	<!--- CHECK TO SEE IF OBJECT IS IN DRAFT --->
	<!--- If the current user is not permitted to see draft objects, then make them login --->
	<cfif structkeyexists(stObj,"status") and stObj.status EQ "draft" and NOT ListContains(request.mode.lValidStatus, stObj.status)>
		<!--- send to login page and return in draft mode --->
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=draft&showdraft=1" addtoken="No" />
	</cfif>
	
	<!--- Get the navigation point from the URL --->
	<cfif not structkeyexists(request,"navid") and structkeyexists(url,"navid")>
	
		<!--- ie. this is a dynamic object looking for context --->
		<cftrace var="url.navid" text="url.navid is defined for non dmNavigation object" />
		<cfset request.navid = url.navid />
	
	<!--- otherwise get the navigation point for this object --->
	<cfelseif not stObj.typename eq "dmNavigation" and not structkeyexists(request,"navid")>
	
		<nj:getNavigation objectId="#stObj.objectId#" r_stobject="stNav">
		
		<!--- if the object is in the tree this will give us the node --->
		<cfif isDefined("stNav.objectid") AND len(stNav.objectid)>
			<cfset request.navid = stNav.objectID>
			<cftrace var="stNav.objectid" text="url.navid is not defined, getNavigation called to find navid" />
	
		<!--- otherwise, use the home node as a last resort --->
		<cfelse>
			<cfset request.navid = application.navid.home>
		</cfif>
	<cfelse>
	
		<cfparam name="request.navid" default="#application.navid.home#">
	
	</cfif>
	
	<!--- Check security --->
	<sec:CheckPermission permission="View" objectID="#attributes.objectid#" typename="#stObj.typename#" result="iHasViewPermission" />
	
	<!--- if the user is unable to view the object, then show the denied access webskin --->
	<cfif iHasViewPermission NEQ 1>
		<skin:view objectid="#attributes.objectid#" webskin="deniedaccess" />
		<cfexit method="exittag" />
	</cfif>
		
	<!--- If we are in designmode then check the containermanagement permissions --->
	<cfif request.mode.design>
		<!--- set the users container management permission --->
		<sec:CheckPermission permission="ContainerManagement" objectid="#request.navid#" result="iShowContainers" />
		<cfset request.mode.showcontainers = iShowContainers />
	</cfif>
	
	<!--- if in request.mode.showdraft=true mode grab underlying draft page (if it exists). Only display if user is loggedin --->
	<cfif structkeyexists(stObj,"versionID") AND request.mode.showdraft AND application.security.isLoggedIn()>
		<cfquery datasource="#application.dsn#" name="qHasDraft">
			select		objectID,status 
			from 		#application.dbowner##stObj.typename# 
			where 		versionID = '#stObj.objectID#'
		</cfquery>
		
		<cfif qHasDraft.recordcount gt 0>
			<!--- set the navigation point for the child obj - unless its a symnolic link in which case wed have already set navid --->
			<cfif isDefined("URL.navid")>
				<cftrace var="url.navid" text="URL.navid exists - setting request.navid = to url.navid" />
				<cfset request.navid = URL.navID>
			<cfelseif NOT isDefined("request.navid")>		
				<cfset request.navid = stObj.objectID>
				<cftrace var="stobj.objectid" text="URL.navid is not defined - setting to stObj.objectid" />
			</cfif>
			
			<nj:display objectid="#qHasDraft.objectid[1]#" />
			<cfexit method="exittemplate">
		</cfif>
	</cfif>
	
	<!--- determine display method for object --->
	<cfset request.stObj = stObj>

	<cfif attributes.method neq "display" AND  attributes.lmethods contains attributes.method>
	
		<!--- If a method has been passed in deliberately and is allowed use this --->
		<cftrace var="attributes.method" text="Passed in attribute method used" />
		<skin:view objectid="#attributes.objectid#" webskin="#attributes.method#" alternateHTML="" />
		
	<cfelseif IsDefined("stObj.displayMethod") AND len(stObj.displayMethod)>
	
		<!--- Invoke display method of page --->
		<cftrace var="stObj.displayMethod" text="Object displayMethod used" />
		<skin:view objectid="#attributes.objectid#" webskin="#stObj.displayMethod#" />
		
	<cfelse>
	
		<skin:view objectid="#attributes.objectid#" webskin="displayPageStandard" r_html="HTML" />
		
		<cfif len(trim(HTML))>
			<cfoutput>#HTML#</cfoutput>
		<cfelse>
			<!--- Invoke default display method of page --->
			<cftrace text="Default display method used" />
			
			<cftry>
				<cfset HTML = createObject("component", application.types[stObj.typename].typePath).display(objectid=stObj.objectId) />
				<cfoutput>#HTML#</cfoutput>
				
				<cfcatch type="any">
					<cfthrow type="core.tags.navajo.display" message="Default display method for object could not be found." />
				</cfcatch>
			</cftry>
		</cfif>
	</cfif>
	
	<!---------------------------
	Build floatMenu, as required
	$TODO: This should respond to request.mode settings and not require a
	a whole new set of permission checks, have trapped any errors and suppressed GB 20031024 $
	---------------------------->
	<cftry>	
		<cfif len(application.security.getCurrentUserID()) AND NOT request.bHideContextMenu>
			<!--- check they are admin --->
			<!--- check they are able to comment --->
		
			<cfset iAdmin = application.security.checkPermission(permission="Admin") />
			<cfset iCanCommentOnContent = application.security.checkPermission(object=request.navid,permission='CanCommentOnContent') />
		
			<cfif (iAdmin eq 1 or iCanCommentOnContent eq 1)>
				<cfset request.floaterIsOnPage = true>
				<cfinclude template="floatMenu.cfm">
			</cfif>
		</cfif>
		<!--- end: logged in user? --->
		<cfcatch>
		<!--- suppress error --->
		<cftrace text="Float menu failed: #cfcatch.message#" />
		</cfcatch>
	</cftry>

<cfelse>

	<!--- Handle type webskins --->
	<sec:CheckPermission webskinpermission="#attributes.method#" result="bView" />
	
	<cfif bView>
		<skin:view typename="#attributes.typename#" webskin="#attributes.method#" />
	<cfelse>
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=restricted" addtoken="No" />
	</cfif>
	
</cfif>

</cftimer>

<cfsetting enablecfoutputonly="No">

