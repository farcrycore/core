<cfsetting enablecfoutputonly="true" />
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
<!--- @@displayname: ./navajo/display.cfm --->
<!--- @@Description: Primary controller for invoking the object to be rendered for the website. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- directives --->
<cfprocessingdirective pageencoding="utf-8" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />

<!--- run once only --->
<cfif thistag.executionmode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

<cftimer label="NAVAJO DISPLAY">

<!--- environment variables --->
<cfparam name="request.bHideContextMenu" default="false" type="boolean" />

<!--- optional attributes --->
<cfparam name="attributes.objectid" default="" />
<cfparam name="attributes.typename" default="" />
<cfparam name="attributes.method" default="" type="string" />
<cfparam name="attributes.loginpath" default="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" type="string">



<!--- Handle options for passing object/type in --->
<cfif not len(attributes.typename) and structkeyexists(url,"type")>
	<cfset attributes.typename = url.type />
</cfif>
<cfif not len(attributes.objectid) and structkeyexists(url,"objectid")>
	<cfset attributes.objectid = url.objectid />
</cfif>
<cfif structkeyexists(url,"view")>
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
		
		<cftrace var="stobj.typename" text="Object typename determined." type="information" />
	
		<!--- check that an appropriate result was returned from COAPI --->
		<cfif NOT IsStruct(stObj) OR StructIsEmpty(stObj)>
			<cfthrow />
		</cfif>
		
		<cfcatch type="Any">
			<farcry:logevent object="#attributes.objectid#" type="display" event="404" />

			<cfif fileexists("#application.path.project#/errors/404.cfm")>
				<cfinclude template="#application.path.project#/errors/404.cfm" />
				<cfsetting enablecfoutputonly="false" />
				<cfexit method="exittag" />

			<cfelseif isDefined("application.navid.home")>
				<cflocation url="#application.url.conjurer#?objectid=#application.navid.home#" addtoken="No" />

			<cfelse>
				<cflocation url="#application.url.webroot#/" addtoken="No" />
			</cfif>
		</cfcatch>
	</cftry>
	
	<!--- 
	CHECK TO SEE IF OBJECT IS IN DRAFT
	- If the current user is not permitted to see draft objects, then make them login 
	--->
	<cfif structkeyexists(stObj,"status") and stObj.status EQ "draft" and NOT ListContainsnocase(request.mode.lValidStatus, stObj.status)>
		<!--- send to login page and return in draft mode --->
		<extjs:bubble title="Security" message="This object is in draft" />
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string&"&showdraft=1")#&error=draft" addtoken="No" />
	</cfif>
	
	<!--- 
	DETERMINE request.navid
	- Get the navigational context of the content object 
	--->
	<!--- passed on the url? --->
	<cfif stObj.typename eq "dmNavigation">
		<cfset request.navid = stobj.objectid />
		<cftrace var="stobj.objectid" text="Content item is a navigation node." type="information" />	
	
	<cfelseif not structkeyexists(request,"navid") and structkeyexists(url,"navid")>
	
		<!--- ie. this is a dynamic object looking for context, passing nav on the URL --->
		<cfset request.navid = url.navid />
		<cftrace var="url.navid" text="navid passed on the URL." />
	
	<!--- otherwise get the navigation point for this object --->
	<cfelseif not stObj.typename eq "dmNavigation" and not structkeyexists(request,"navid")>
	
		<nj:getNavigation objectId="#stObj.objectId#" r_stobject="stNav" />
		
		<!--- if the object is in the tree this will give us the node --->
		<cfif isDefined("stNav.objectid") AND len(stNav.objectid)>
			<cfset request.navid = stNav.objectID>
			<cftrace var="stNav.objectid" text="url.navid is not defined, getNavigation called to find navid." type="information" />
	
		<!--- otherwise, use the home node as a last resort --->
		<cfelse>
			<cfset request.navid = application.navid.home />
			<cftrace var="application.navid.home" text="navid could not be determined; defaulting to application.navid.home." type="information" />
		</cfif>

	<cfelseif not structKeyExists(request, "navid")>
		<!--- otherwise, use the home node as a last resort --->
		<cfset request.navid = "#application.navid.home#" />
		<cftrace var="application.navid.home" text="nav object corrupt; defaulting to application.navid.home." type="information" />
		
	</cfif>
	
	<!--- Check security --->
	<sec:CheckPermission permission="View" objectID="#attributes.objectid#" typename="#stObj.typename#" result="iHasViewPermission" />
	
	<!--- if the user is unable to view the object, then show the denied access webskin --->
	<cfif iHasViewPermission NEQ 1>
		<skin:view objectid="#attributes.objectid#" webskin="deniedaccess" />
		<cfsetting enablecfoutputonly="false" />
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
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="exittemplate">
		</cfif>
	</cfif>
	
	<!--- determine display method for object --->
	<cfset request.stObj = stObj>

	<cfif len(attributes.method)>
	
		<!--- If a method has been passed in deliberately and is allowed use this --->
		<cftrace var="attributes.method" text="Passed in attribute method used" />
		<skin:view objectid="#attributes.objectid#" webskin="#attributes.method#" alternateHTML="" />
		
	<cfelseif IsDefined("stObj.displayMethod") AND len(stObj.displayMethod)>
	
		<!--- Invoke display method of page --->
		<cftrace var="stObj.displayMethod" text="Object displayMethod used" />
		<skin:view objectid="#attributes.objectid#" webskin="#stObj.displayMethod#" />
		
	<cfelse>
	
		<skin:view objectid="#attributes.objectid#" webskin="displayPageStandard" r_html="HTML" alternateHTML="" />
		
		<cfif len(trim(HTML))>
			<cfoutput>#HTML#</cfoutput>
		<cfelse>
			<cfthrow message="For the default view of an object, create a displayPageStandard webskin." />
		</cfif>
	</cfif>
	

<cfelse>

	<!--- If we are in designmode then check the containermanagement permissions --->
	<cfif request.mode.design>
		<!--- set the users container management permission --->
		<sec:CheckPermission type="#attributes.typename#" permission="ContainerManagement" result="iShowContainers" />
		<cfset request.mode.showcontainers = iShowContainers />
	</cfif>
	
	<!--- Handle type webskins --->
	<sec:CheckPermission type="#attributes.typename#" webskinpermission="#attributes.method#" result="bView" />
	
	<cfif bView>
		<cfset request.typewebskin = "#attributes.typename#.#attributes.method#" />
		<skin:view typename="#attributes.typename#" webskin="#attributes.method#" />
	<cfelse>
		<extjs:bubble title="Security" message="You do not have permission to access this view" />
		<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=restricted" addtoken="No" />
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

	
</cftimer>

<cfsetting enablecfoutputonly="No">

