<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/statsLog.cfm,v 1.32 2003/11/28 04:05:57 brendan Exp $
$Author: brendan $
$Date: 2003/11/28 04:05:57 $
$Name: milestone_2-1-2 $
$Revision: 1.32 $

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
	<cfif findNoCase("farcry_core",cgi.PATH_TRANSLATED) eq 0>
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
			<cfscript>
			// check is a user is logged in
			if (request.LoggedIn)
				userid = session.dmSec.authentication.userlogin;
			else
				userid="Anonymous";
			
			// check if cgi.http_referer has value 
			if (cgi.http_referer neq "" and len(cgi.http_referer))
				referer="#cgi.http_referer#";
			else
				referer="Unknown";
			
			// log stats
			application.factory.oStats.logEntry(pageId=request.stObj.objectid,navId=request.navid,remoteIP=session.remoteIP,sessionId=session.statsSession,browser=session.userBrowser,userid=userid,referer=referer,locale=session.userLocale,os=session.userOS);
			</cfscript>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="no">