<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/OnRequestEnd.cfm,v 1.6.2.2 2005/06/07 08:42:35 suspiria Exp $
$Author: suspiria $
$Date: 2005/06/07 08:42:35 $
$Name: milestone_2-3-2 $
$Revision: 1.6.2.2 $

|| DESCRIPTION || 
$Description: Determine the OnRequestEnd.cfm global include for farcry admin. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->

<cfif isDefined("server.farcry.stInstalls")>
	<cfparam name="cookie.farcryAdmin" default="" type="string">
	<!--- try and determine appropriate app for farcry admin --->
	<cfloop collection="#server.farcry.stInstalls#" item="i">
		<cfif cookie.farcryAdmin eq server.farcry.stInstalls[i].match>
			<cfinclude template="#server.farcry.stInstalls[i].path#/OnRequestEnd.cfm">
		</cfif>
	</cfloop>
	<!--- <cfabort showerror="Unable to find a match for include file."> --->
<cfelse>
	<cftry>
	<!--- Try to include apps.cfm from the farcry directory --->
	<cfinclude template="/farcry/apps.cfm">
	<cfinclude template="/farcry/#stApps[cgi.server_name]#/www/OnRequestEnd.cfm">

		<cfcatch>
            <!--- hack workaround to handle context roots in the interim --->
			<cfif server.coldfusion.appserver eq "J2EE">
				<cfset contextRoot = listGetAt(CGI.SCRIPT_NAME, 1, "/")>
				<cfinclude template="/#contextRoot#/OnRequestEnd.cfm">
			<cfelse>
				<cfinclude template="/OnRequestEnd.cfm">
			</cfif>
		</cfcatch>
	</cftry>
</cfif>

