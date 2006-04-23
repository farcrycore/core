<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/OnRequestEnd.cfm,v 1.10.2.2 2005/11/23 06:18:06 suspiria Exp $
$Author: suspiria $
$Date: 2005/11/23 06:18:06 $
$Name: milestone_3-0-1 $
$Revision: 1.10.2.2 $

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
    <cfinclude template="/farcry/#stApps[cgi.server_name]#/www/OnRequestEnd.cfm">
    <cfcatch>
        <cftry>
            <cfinclude template="/#listGetAt(CGI.SCRIPT_NAME, 1, '/')#/OnRequestEnd.cfm">
        <cfcatch>
            <cfinclude template="/OnRequestEnd.cfm">
        </cfcatch>
        </cftry>
    </cfcatch>
    </cftry>
</cfif>

