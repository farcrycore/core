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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/statsLog.cfm,v 1.36 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.36 $

|| DESCRIPTION || 
$Description: Logs visit of page including pageId, navid,ip address and user (if applicable) $


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
	<cfif findNoCase("core",cgi.PATH_TRANSLATED) eq 0>
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
			<cfif not isDefined("session.dmProfile.locale")>
				<cfscript>
					//geoLocator=createObject("component", "#application.packagepath#.farcry.geoLocator");
					//bInit = application.factory.oGeoLocator.init();
					if (application.bGeoLocatorInit) {
						session.dmProfile.locale=application.factory.oGeoLocator.findLocale(thisLanguage=CGI.http_accept_Language,thisip=cgi.REMOTE_ADDR); 
					} else {
						session.dmProfile.locale=CGI.http_accept_Language;
					}
				</cfscript>
			</cfif>
		</cfif>
		
		<!--- log page view --->
		<cftry>
			<cfscript>
			// check is a user is logged in
			if (application.security.isLoggedIn())
				userid = session.dmSec.authentication.userlogin;
			else
				userid="Anonymous";
			
			// check if cgi.http_referer has value 
			if (cgi.http_referer neq "" and len(cgi.http_referer))
				referer="#cgi.http_referer#";
			else
				referer="Unknown";
				
			if (isDefined("request.stObj") AND isDefined("request.navId"))	//if these don't exist it most likely means a user is previewing from the webtop, in this case we don't want to log stats
			{
				// log stats
				application.factory.oStats.logEntry(pageId=request.stObj.objectid,navId=request.navid,remoteIP=session.remoteIP,sessionId=session.statsSession,browser=session.userBrowser,userid=userid,referer=referer,locale=session.dmProfile.locale,os=session.userOS);
			}
			</cfscript>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">