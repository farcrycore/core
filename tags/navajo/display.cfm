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

<cfset application.fc.factory.farFU.parseURL() />
<cfset StructAppend(url, request.fc, "true") />

<!--- environment variables --->
<cfparam name="request.bHideContextMenu" default="false" type="boolean" />

<cfparam name="url.bodyView" default="displayBody" /><!--- The webskin name that can be used as the body view webskin --->

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
		<cflocation url="#attributes.loginpath#&showdraft=1&error=draft" addtoken="No" />
	</cfif>
	

	<!--- 
	DETERMINE request.navid
	- Get the navigational context of the content object 
	--->	
	<cfif not structKeyExists(request, "navID")>
		<cfset request.navid = createObject("component", application.stcoapi["#stObj.typename#"].packagePath).getNavID(stobject="#stobj#") />
		<cfif not len(request.navID)>
			<cfif structKeyExists(application.navid, "home")>
				<cfset request.navID = listFirst(application.navid.home) />
			<cfelse>
				<cfthrow type="FarCry Controller" message="No Navigation ID can be found. Please see administrator." />
			</cfif>
		</cfif>
	</cfif>
	
	<!--- Check security --->
	<sec:CheckPermission permission="View" objectID="#attributes.objectid#" typename="#stObj.typename#" result="iHasViewPermission" />

	<!--- if the user is unable to view the object, then show the denied access webskin --->
	<cfif iHasViewPermission NEQ 1>
		<skin:view objectid="#attributes.objectid#" webskin="deniedaccess" loginpath="#attributes.loginpath#"/>
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
	
		<skin:view objectid="#attributes.objectid#" typename="#stObj.typename#" webskin="displayPageStandard" r_html="HTML" alternateHTML="" />
		
		<cfif len(trim(HTML))>
			<cfoutput>#HTML#</cfoutput>
		<cfelse>
			<cfthrow message="For the default view of an object, create a displayPageStandard webskin." />
		</cfif>
	</cfif>
		
	<cfif request.mode.bAdmin and request.fc.bShowTray and not (structkeyexists(request,"bHideContextMenu") and request.bHideContextMenu) and not attributes.method eq "displayAdminToolbar">
		<!--- Show tray once for this request --->
		<cfset request.fc.bShowTray = false />
		
		<!--- Output tray info --->
		<cfset thisurl = "#cgi.script_name#?#rereplacenocase(cgi.QUERY_STRING,'[\?&](flushcache|showdraft|designmode|bShowTray|updateapp)=[^&]*','','ALL')#" />
		<cfset thistray = "#application.url.webroot#/index.cfm?objectid=#attributes.objectid#&view=displayAdminToolbar&key=#hash(application.fc.utils.createJavaUUID())#" />
		<extjs:iframeDialog />
		<skin:htmlHead><cfoutput>
			<script type="text/javascript">
				if (top.location == location)
					location = "#application.url.webtop#/tray.cfm###urlencodedformat(thisurl)#|summary";
				else
					parent.updateTray('#thistray#',document.title,'#thisurl#');
			</script>
		</cfoutput></skin:htmlHead>
	<cfelseif request.mode.bAdmin and structkeyexists(session.dmProfile,"bShowTray") and not session.dmProfile.bShowTray and not request.mode.ajax><!--- Tray will only be disabled for admins if the admin has turned it off --->
		<skin:htmlHead library="jQueryJS" />
		<skin:htmlHead id="enabletray"><cfoutput>
			<style type="text/css">
				##enabletray {
					position: fixed;
					bottom: 0; left: 0;
					z-index: 10;
					padding:5px;
					border:0 none;
				}
			</style>
			<!--[if gte IE 5.5]>
			<![if lt IE 7]>
			<style type="text/css">
			div##enabletray {
				/* IE5.5+/Win - this is more specific than the IE 5.0 version */
				right: auto; bottom: auto;
				left: expression( ( 5 + ( ignoreMe2 = document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft ) ) + 'px' );
				top: expression( ( -5 - enabletray.offsetHeight + ( document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight ) + ( ignoreMe = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop ) ) + 'px' );
			}
			</style>
			<![endif]>
			<![endif]-->
		</cfoutput></skin:htmlHead>
		<extjs:onReady><cfoutput>
			Ext.DomHelper.append(Ext.getBody(),"<a href='#cgi.script_name#?#rereplacenocase(cgi.QUERY_STRING,'[\?&](flushcache|showdraft|designmode|bShowTray)=[^&]*','','ALL')#&bShowTray=1' id='enabletray' title='Enable tray'><img src='#application.url.webtop#/facade/icon.cfm?icon=toggletray&size=64' /></a>");
		</cfoutput></extjs:onReady>
	</cfif>

<cfelse>
	<!--- If we are in designmode then check the containermanagement permissions --->
	<cfif request.mode.design>
		<!--- set the users container management permission --->
		<sec:CheckPermission type="#attributes.typename#" permission="ContainerManagement" result="iShowContainers" />
		<cfset request.mode.showcontainers = iShowContainers />
	</cfif>
	
	<!--- Default method for typewebskins is displayPageStandard --->
	<cfif not len(attributes.method)>
		<cfset attributes.method = "displayPageStandard" />
	</cfif>
	
	<!--- Handle type webskins --->
	<sec:CheckPermission type="#attributes.typename#" webskinpermission="#attributes.method#" result="bView" />
	
	<cfif bView>
		<cfif not structKeyExists(request, "navID")>
			<cfset request.navid = createObject("component", application.stcoapi["#attributes.typename#"].packagePath).getNavID(typename="#attributes.typename#") />
			<cfif not len(request.navID)>
				<cfif structKeyExists(application.navid, "home")>
					<cfset request.navID = listFirst(application.navid.home) />
				<cfelse>
					<cfthrow type="FarCry Controller" message="No Navigation ID can be found. Please see administrator." />
				</cfif>
			</cfif>
		</cfif>
		
		<skin:view typename="#attributes.typename#" webskin="#attributes.method#" />
		
		<cfif request.mode.bAdmin and request.fc.bShowTray and not (structkeyexists(request,"bHideContextMenu") and request.bHideContextMenu) and not attributes.method eq "displayAdminToolbar">
			<!--- Show tray once for this request --->
			<cfset request.fc.bShowTray = false />
			
			<!--- Output tray info --->
			<cfset thisurl = "#cgi.script_name#?#rereplacenocase(cgi.QUERY_STRING,'[\?&](flushcache|showdraft|designmode|bShowTray|updateapp)=[^&]*','','ALL')#" />
			<cfif structkeyexists(url,"bodyView")>
				<cfset thistray = "#application.url.webroot#/index.cfm?type=#attributes.typename#&view=displayAdminToolbar&webskinused=#url.bodyView#" />
			<cfelse>
				<cfset thistray = "#application.url.webroot#/index.cfm?type=#attributes.typename#&view=displayAdminToolbar&webskinused=#attributes.method#" />
			</cfif>
			<extjs:iframeDialog />
			<skin:htmlHead><cfoutput>
				<script type="text/javascript">
					if (top.location == location)
						location = "#application.url.webtop#/tray.cfm###urlencodedformat(thisurl)#|summary";
					else
						top.updateTray('#thistray#',document.title,'#thisurl#');
				</script>
			</cfoutput></skin:htmlHead>
		<cfelseif request.mode.bAdmin and structkeyexists(session.dmProfile,"bShowTray") and not session.dmProfile.bShowTray and not request.mode.ajax><!--- Tray will only be disabled for admins if the admin has turned it off --->
			<skin:htmlHead library="jQueryJS" />
			<skin:htmlHead id="enabletray"><cfoutput>
				<style type="text/css">
					##enabletray {
						position: fixed;
						bottom: 0; left: 0;
						z-index: 10;
						padding:5px;
						border:0 none;
					}
				</style>
				<!--[if gte IE 5.5]>
				<![if lt IE 7]>
				<style type="text/css">
				div##enabletray {
					/* IE5.5+/Win - this is more specific than the IE 5.0 version */
					right: auto; bottom: auto;
					left: expression( ( 5 + ( ignoreMe2 = document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft ) ) + 'px' );
					top: expression( ( -5 - enabletray.offsetHeight + ( document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight ) + ( ignoreMe = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop ) ) + 'px' );
				}
				</style>
				<![endif]>
				<![endif]-->
			</cfoutput></skin:htmlHead>
			<extjs:onReady><cfoutput>
				Ext.DomHelper.append(Ext.getBody(),"<a href='#cgi.script_name#?#rereplacenocase(cgi.QUERY_STRING,'[\?&](flushcache|showdraft|designmode|bShowTray)=[^&]*','','ALL')#&bShowTray=1' id='enabletray' title='Enable tray'><img src='#application.url.webtop#/facade/icon.cfm?icon=toggletray&size=64' /></a>");
			</cfoutput></extjs:onReady>
		</cfif>
	<cfelse>
		<extjs:bubble title="Security" message="You do not have permission to access this view" />
		<cflocation url="#attributes.loginpath#&error=restricted" addtoken="No" />
	</cfif>
	
</cfif>

</cftimer>

<cfsetting enablecfoutputonly="No">

