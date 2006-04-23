<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/Application.cfm,v 1.17.2.2 2005/11/23 06:18:06 suspiria Exp $
$Author: suspiria $
$Date: 2005/11/23 06:18:06 $
$Name: milestone_3-0-1 $
$Revision: 1.17.2.2 $

|| DESCRIPTION || 
$Description: Application.cfm global include for farcry admin. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->

<!--- 
 dynamically determine the right farcry application instance to administer
 and include the relevant Application.cfm file from the project; default
 to webroot.
--->
<cfif isDefined("server.farcry.stInstalls")>
    <cftry>
        <!--- try and determine appropriate app for farcry admin --->
        <cfloop collection="#server.farcry.stInstalls#" item="i">
            <cfif cookie.farcryAdmin eq server.farcry.stInstalls[i].match>
                <cfinclude template="#server.farcry.stInstalls[i].path#/Application.cfm">
            </cfif>
        </cfloop>
        <cfcatch>
            <cftry>
                <!--- Try to include apps.cfm from the farcry directory --->
                <cfinclude template="/farcry/apps.cfm">
                <cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">
            <cfcatch>
                <cftry>
                    <cfinclude template="/#listGetAt(CGI.SCRIPT_NAME, 1, '/')#/Application.cfm">
                <cfcatch>
                    <cfinclude template="/Application.cfm">
                </cfcatch>
                </cftry>
            </cfcatch>
            </cftry>
        </cfcatch>
    </cftry>
    <!--- <cfabort showerror="Unable to find a match for include file."> --->
<cfelse>
    <cftry>
        <!--- Try to include apps.cfm from the farcry directory --->
        <cfinclude template="/farcry/apps.cfm">
        <cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">
    <cfcatch>
        <cftry>
            <!--- Try to include apps.cfm from the farcry directory --->
            <cfinclude template="/farcry/apps.cfm">
            <cfinclude template="/farcry/#stApps[cgi.server_name]#/www/Application.cfm">
        <cfcatch>
            <cftry>
                <cfinclude template="/#listGetAt(CGI.SCRIPT_NAME, 1, '/')#/Application.cfm">
            <cfcatch>
                <cfinclude template="/Application.cfm">
            </cfcatch>
            </cftry>
        </cfcatch>
        </cftry>
    </cfcatch>
    </cftry>
</cfif>

<!--- i18n date/time format styles --->
<cfset application.shortF=3>        <!--- 3/27/25 --->
<cfset application.mediumF=2>       <!--- Rabi' I 27, 1425 (yeah, i know) --->
<cfset application.longF=1>         <!--- Rabi' I 27, 1425 --->
<cfset application.fullF=0>         <!--- Monday, Rabi' I 27, 1425 --->
<cfset debugRB=true>    <!--- load rb with debug markup? --->

<!--- check to see if the person has general admin permissions --->
<cfif NOT request.mode.bAdmin>
    <!--- logout illegal users --->
    <cfscript>
        request.dmsec.oAuthentication.logout();
    </cfscript>

    <!--- redirect them to the login page --->
    <cfif not ListContains( cgi.script_name, "#application.url.farcry#/login.cfm" )>
        <cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#" addtoken="No">
        <cfabort>
    </cfif>
</cfif>


<!--- begin: initialise webtop factory object --->
<!--- TODO: move to application initialisation --->
<!--- grab webtop config file and parse --->
<cfset application.factory.owebtop=createobject("component", "#application.packagepath#.farcry.webtop").init()>
<!--- <cfdump var="#application.factory.owebtop#"> --->
<!--- end: initialise webtop factory object --->


<cfsetting enablecfoutputonly="no">