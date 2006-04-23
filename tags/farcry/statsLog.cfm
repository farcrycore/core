<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/statsLog.cfm,v 1.31 2003/09/08 04:41:16 brendan Exp $
$Author: brendan $
$Date: 2003/09/08 04:41:16 $
$Name: b201 $
$Revision: 1.31 $

|| DESCRIPTION || 
$Description: Logs visit of page including pageId, navid,ip address and user (if applicable) $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">

<!--- check logging of stats is enabled --->
<cfif application.config.general.logStats>
	<!--- check not viewing a farcry admin page --->
	<cfif listcontainsnocase(cgi.PATH_TRANSLATED,"farcry_core") eq 0>
		<!--- check if session exists --->
		<cfif NOT isdefined("session.statsSession")>
			<!--- create unique session id --->
			<cfset session.statsSession = createUUID()>
			
			<!--- get browser --->
			<cfset stBrowser = application.factory.oStats.getBrowser()>
			<cfset session.userBrowser = "#stBrowser.name# #stBrowser.version#">
			
			<!--- get operating system --->
			<cfset session.UserOS = application.factory.oStats.getUserOS()>
			
			<!--- get remote ip --->
			<cfset session.remoteIP = trim(cgi.REMOTE_ADDR)>
			
			<!--- set session start time --->
			<cfset session.startTime = now()>
			
			<!--- work out user's locale --->
			<cfif application.config.plugins.geoLocator>
				<cfscript>
					geoLocator=createObject("component", "#application.packagepath#.farcry.geoLocator");
					bInit = geoLocator.init();
					if (bInit) {
						session.userLocale=geoLocator.findLocale(thisLanguage=CGI.http_accept_Language,thisip=cgi.REMOTE_ADDR); 
					} else {
						session.userLocale=CGI.http_accept_Language;
					}
				</cfscript>
			<cfelse>
				<cfset session.userLocale = CGI.HTTP_ACCEPT_LANGUAGE>
			</cfif>
		</cfif>
		<!--- log page view --->
		<cftry>
			<cfinvoke component="#application.packagepath#.farcry.stats" method="logEntry">
				<cfinvokeargument name="pageId" value="#request.stObj.objectid#"/>
				<cfinvokeargument name="navId" value="#request.navid#"/>
				<cfinvokeargument name="remoteIP" value="#session.remoteIP#"/>
				<cfinvokeargument name="sessionId" value="#session.statsSession#"/>
				<cfinvokeargument name="browser" value="#session.userBrowser#"/>
				<!--- check is a user is logged in --->
				<cfif request.LoggedIn>
					<cfinvokeargument name="userid" value="#session.dmSec.authentication.userlogin#"/>
				<cfelse>
					<cfinvokeargument name="userid" value="Anonymous"/>		
				</cfif>
				<!--- check if cgi.http_referer has value --->
				<cfif cgi.http_referer neq "" and len(cgi.http_referer)>
					<cfinvokeargument name="referer" value="#cgi.http_referer#"/>
				<cfelse>
					<cfinvokeargument name="referer" value="Unknown"/>		
				</cfif>
				<cfinvokeargument name="locale" value="#session.userLocale#"/>
				<cfinvokeargument name="os" value="#session.userOS#"/>
			</cfinvoke>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">