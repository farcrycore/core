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
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/core/" prefix="core" />

<!--- run once only --->
<cfif thistag.executionmode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>


<!--- TRAY VARIABLES --->
<cfparam name="request.fc.startTickCount" default="#GetTickCount()#" />
<cfparam name="request.bHideContextMenu" default="false" type="boolean" /><!--- Hide the tray.  For backwards compatibility --->


<!--- optional attributes --->
<cfparam name="attributes.objectid" default="" />
<cfparam name="attributes.typename" default="" />
<!--- <cfparam name="attributes.method" default="" type="string" /> --->
<cfparam name="attributes.loginpath" default="#application.fapi.getLink(href=application.url.publiclogin,urlParameters='returnUrl='&application.fc.lib.esapi.encodeForURL(cgi.script_name&'?'&cgi.query_string))#" type="string">

<!--- passing in attributes.objectid will override the url value. This is done when a dmNavigation recusively calls the template. --->
<cfif len(attributes.objectid)>
	<cfset url.objectid = attributes.objectid />
</cfif>
<cfif len(attributes.typename)>
	<cfset url.type = attributes.typename />
</cfif>

<cfif structKeyExists(url, "404")>
	<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error(url["404"])) />
	<cfexit method="exittag" />
</cfif>

<!--- DEFAULT URL PARAMETERS. url.bodyView is set depending on whether the call is a type webskin call or not. --->
<cfparam name="url.objectid" default="" />
<cfparam name="url.type" default="" />
<cfparam name="url.view" default="" />


<!--- get standard webskin names by device type --->
<cfset stWebskins = application.fc.lib.device.getDeviceWebskinNames()>

<!--- TODO: device redirection --->
<!---
<cfif application.fc.lib.device.isDeviceRedirectionEnabled() AND application.fc.lib.device.getDeviceType() neq application.fc.lib.device.getDomainDeviceType()>
	<cfset application.fc.lib.device.redirectDevice()>
</cfif>
--->


<!--- method for dealing with the missing url param... redirect to home page --->
<cfif NOT len(url.objectid)>
	<cfif NOT len(url.type)>
		
		<!--- IF THIS IS NOT THE HOME PAGE AND WE HAVE A 404 PAGE, THEN CALL THE 404 --->
		<cfif structKeyExists(url, "furl") AND url.furl NEQ "/">
			<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("No objectid or type specified")) />
			<cfexit method="exittag" />
		</cfif>
		
		<!--- If we make it to here, we just have to redirect to the home page. --->
		<cfif application.fapi.checkNavID("home")>
			<cfset url.objectid = application.fapi.getNavID("home") />
			<cfset url.type = "dmNavigation" />
		<cfelse>
			<cflocation url="#application.url.webroot#/" addtoken="No">
		</cfif>
	</cfif>
</cfif>

<cfif len(url.objectid)>
	
	<!--- grab the object we are displaying --->
	<cftry>
		<cfset application.fapi.addProfilePoint("Display","Object") />
		<cfset stObj = application.fapi.getContentObject(url.objectid, url.type) />

				
		<!--- check that an appropriate result was returned from COAPI --->
		<cfif NOT IsStruct(stObj) OR StructIsEmpty(stObj)>
			<cfthrow />
		</cfif>
		
		<cfcatch type="Any">
			<farcry:logevent object="#url.objectid#" type="display" event="404" />
			<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("Object [#url.objectid#] does not exist")) />
			<cfexit method="exittag" />
		</cfcatch>
	</cftry>
	
	<!--- The webskin name that can be used as the body view webskin --->
	<cfif structkeyexists(url,"bodyView")and len(url.bodyView)>
		<!--- Update the view with the display method --->
		<cfset url.bodyView = application.fc.lib.device.getDeviceWebskin(stObj.typename, url.bodyView) />
	<cfelse>
		<cfset url.bodyView = stWebskins.body />
	</cfif>
	
	<!--- 
	CHECK TO SEE IF OBJECT IS IN DRAFT
	- If the current user is not permitted to see draft objects, then make them login 
	--->
	<cfif structkeyexists(stObj,"status") and NOT ListContainsnocase(request.mode.lValidStatus, stObj.status)>
		<cfif request.mode.bAdmin>
			<!--- SET DRAFT MODE ONLY FOR THIS REQUEST. --->
			<cfset request.mode.showdraft = 1 />
			<cfset request.mode.lValidStatus = "draft,pending,approved" />
			<!---<skin:bubble title="Currently Viewing a Draft Object" message="You are currently viewing a draft object. Your profile has now been changed to 'Showing Drafts'." />--->
		<cfelse>			
			<!--- send to login page and return in draft mode --->
			<skin:location url="#attributes.loginpath#" urlParameters="showdraft=1&error=draft" statusCode="302" />
		</cfif>
	</cfif>
	
	<!--- 
	DETERMINE request.navid
	- Get the navigational context of the content object 
	--->	
	<cfif not structKeyExists(request, "navID")>
		<cfset request.navid = application.fapi.getContentType("#stObj.typename#").getNavID(objectid="#stobj.objectid#", typename="#stobj.typename#", stobject="#stobj#") />
		<cfif not len(request.navID)>
			<cfif application.fapi.checkNavID("home")>
				<cfset request.navID = application.fapi.getNavID("home") />
			<cfelse>
				<cfthrow type="FarCry Controller" message="No Navigation ID can be found. Please see administrator." />
			</cfif>
		</cfif>
	</cfif>
	

	<!--- Check security --->
	<cfset application.fapi.addProfilePoint("Display","Check permission") />
	<sec:CheckPermission permission="View" objectID="#stobj.objectid#" typename="#stobj.typename#" result="iHasViewPermission" />

	<!--- if the user is unable to view the object, then show the denied access webskin --->
	<cfif iHasViewPermission NEQ 1>
		<skin:view objectid="#stobj.objectid#" typename="#stObj.typename#" webskin="deniedaccess" loginpath="#attributes.loginpath#" />
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
	<cfif structkeyexists(stObj,"versionID") AND request.mode.showdraft AND application.fapi.isLoggedIn()>
		<cfquery datasource="#application.dsn#" name="qHasDraft">
			select		objectID,status 
			from 		#application.dbowner##stObj.typename# 
			where 		versionID = '#stObj.objectID#'
		</cfquery>
		
		<cfif qHasDraft.recordcount gt 0>
			<!--- set the navigation point for the child obj - unless its a symnolic link in which case wed have already set navid --->
			<cfif NOT structKeyExists(request, "navid")>
				<cfset request.navid = stobj.objectID>
			</cfif>
			
			<nj:display objectid="#qHasDraft.objectid[1]#" />
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="exittemplate">
		</cfif>
	</cfif>
	
	<!--- determine display method for object --->
	<cfset request.stObj = stObj>


	<cfif len(url.view)>

		<!--- Update the view with the display method --->
		<cfset url.view = application.fc.lib.device.getDeviceWebskin(stObj.typename, url.view) />
		<skin:view objectid="#stobj.objectid#" typename="#stObj.typename#" webskin="#url.view#" alternateHTML="" r_html="result" />

	<cfelseif structKeyExists(stObj, "displayMethod") AND len(stObj.displayMethod)>

		<!--- Update the view with the display method --->
		<cfset url.view = application.fc.lib.device.getDeviceWebskin(stObj.typename, stObj.displayMethod) />
		<skin:view objectid="#stobj.objectid#" typename="#stObj.typename#" webskin="#url.view#" alternateHTML="" r_html="result" />

	<cfelseif application.fapi.hasWebskin(typename="#stobj.typename#", webskin="#stWebskins.page#")>

		<!--- use the standard page webskin if there is one --->
		<!--- NOTE: do not set url.view here as recursive calls from dmNavigation will break --->
		<skin:view objectid="#stobj.objectid#" typename="#stObj.typename#" webskin="#stWebskins.page#" alternateHTML="" r_html="result" />

	<cfelse>

		<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("I was looking at the type: #stobj.typename# and couldn't find a #stWebskins.page#. You'll want to create the default view for this object. To do that, create a #stWebskins.page#.cfm webskin in the webskin folder in a directory named #stobj.typename#.")) />
		
	</cfif>

	<!--- either stream the webskin result with an appropriate mime type, or output it normally --->
	<cfif len(url.type) AND len(url.view) AND application.stCOAPI[url.type].stWebskins[url.view].viewstack eq "ajax">
		<cfset request.mode.ajax = true />
	</cfif>
	<cfif len(url.type) AND len(url.view) AND application.stCOAPI[url.type].stWebskins[url.view].viewstack eq "data" AND structkeyexists(application.stCOAPI[url.type].stWebskins[url.view],"mimeType")>
		<cfset request.mode.ajax = true />

		<cfinvoke component="#application.fapi#" method="stream">
			<cfinvokeargument name="content" value="#result#" />
			<cfinvokeargument name="type" value="#application.stCOAPI[url.type].stWebskins[url.view].mimeType#" />
			<cfif structkeyexists(application.stCOAPI[url.type].stWebskins[url.view],"filename")>
				<cfinvokeargument name="filename" value="#application.stCOAPI[url.type].stWebskins[url.view].filename#" />
			</cfif>
		</cfinvoke>
	<cfelse>
		<cfoutput>#result#</cfoutput>
	</cfif>


<cfelse>

	<cfset application.fapi.addProfilePoint("Display","Type") />
	
	<!--- Default method for typewebskins is standard page --->
	<cfif len(url.view)>
		<!--- Update the view with the display method --->
		<cfset url.view = application.fc.lib.device.getDeviceWebskin(url.type, url.view) />
	<cfelse>
		<cfset url.view = stWebskins.page />
	</cfif>
	
	<!--- The webskin name that can be used as the body view webskin --->
	<cfif structkeyexists(url,"bodyView")and len(url.bodyView)>
		<!--- Update the view with the display method --->
		<cfset url.bodyView = application.fc.lib.device.getDeviceWebskin(url.type, url.bodyView) />
	<cfelse>
		<cfset url.bodyView = stWebskins.typeBody />
	</cfif>
	
	<!--- If we are in designmode then check the containermanagement permissions --->
	<cfif request.mode.design>
		<!--- set the users container management permission --->
		<sec:CheckPermission type="#url.type#" permission="ContainerManagement" result="iShowContainers" />
		<cfset request.mode.showcontainers = iShowContainers />
	</cfif>
	
	<!--- Handle type webskins --->
	<sec:CheckPermission type="#url.type#" webskinpermission="#url.view#" result="bView" />
	
	<cfif bView>
		<cfif not structKeyExists(request, "navID")>
			<cftry>
				<cfset request.navid = application.fapi.getContentType("#url.type#").getNavID(typename="#url.type#") />
				<cfif not len(request.navID)>
					<cfif application.fapi.checkNavID("home")>
						<cfset request.navID = application.fapi.getNavID("home") />
					<cfelse>
						<cfthrow type="FarCry Controller" message="No Navigation ID can be found. Please see administrator." />
					</cfif>
				</cfif>
				<cfcatch>
					<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error(message=cfcatch.message)) />
					<cfexit method="exittag">
				</cfcatch>
			</cftry>
		</cfif>

		<!--- check if webskin(s) exist --->
		<cfif NOT application.fapi.hasWebskin(typename=url.type, webskin=url.view)>
			<cfset bView = false>
		<cfelseif url.view eq stWebskins.page AND len(url.bodyview) AND NOT application.fapi.hasWebskin(typename=url.type, webskin=url.bodyview)>
			<cfset bView = false>
		</cfif>

		<cfif bView>

			<!--- Call the view on the types coapi object --->
			<skin:view typename="#url.type#" webskin="#url.view#" r_html="result" />
			
			<cfif application.stCOAPI[url.type].stWebskins[url.view].viewstack eq "ajax">
				<cfset request.mode.ajax = true />
			</cfif>
			<cfif application.stCOAPI[url.type].stWebskins[url.view].viewstack eq "data" and structkeyexists(application.stCOAPI[url.type].stWebskins[url.view],"mimeType")>
				<cfset request.mode.ajax = true />

				<cfinvoke component="#application.fapi#" method="stream">
					<cfinvokeargument name="content" value="#result#" />
					<cfinvokeargument name="type" value="#application.stCOAPI[url.type].stWebskins[url.view].mimeType#" />
					<cfif structkeyexists(application.stCOAPI[url.type].stWebskins[url.view],"filename")>
						<cfinvokeargument name="filename" value="#application.stCOAPI[url.type].stWebskins[url.view].filename#" />
					</cfif>
				</cfinvoke>
			<cfelse>
				<cfoutput>#result#</cfoutput>
			</cfif>
			
		<cfelse>
			
			<cfset application.fc.lib.error.showErrorPage("404 Page missing",application.fc.lib.error.create404Error("I was looking at the type: #url.type# and couldn't find both #url.view# and #url.bodyview#.")) />
			
		</cfif>	
		
	<cfelse>

		<skin:view typename="#url.type#" webskin="deniedaccess" loginpath="#attributes.loginpath#" />
		<cfsetting enablecfoutputonly="false" />
		<cfexit method="exittag" />

	</cfif>
	
</cfif>

<core:displayTray />

<cfsetting enablecfoutputonly="false" />