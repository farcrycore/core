<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/Application.cfm,v 1.17.2.2 2005/11/23 06:18:06 suspiria Exp $
$Author: suspiria $
$Date: 2005/11/23 06:18:06 $
$Name: milestone_3-0-1 $
$Revision: 1.17.2.2 $

|| DESCRIPTION || 
$Description: Application.cfm global include for farcry admin. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au)$
--->



<!---
Include the Parent Application.cfm
If the farcry admin area is located inside the project then the Application.cfm location will be correct.
If the farcry admin area is located inside core, the project location is dynamically determined.
 --->
<cfinclude template="../Application.cfm" />
	
	

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


<!--- Restrict access if webtop access is disabled --->
<cfif not application.sysinfo.bwebtopaccess>
	<cfoutput>
	<div style="margin: 10% 30% 0% 30%; padding: 10px; border: 2px navy solid; background: ##dedeff; font-family: Verdana; font-color: navy; text-align: center;">
		<h2>Webtop Access Restricted</h2>
		<p>Webtop access has been specifically restricted on this server.  Please contact your system administrator for details.</p>
	</div>
	</cfoutput>
	<cfabort />
</cfif>


<cfsetting enablecfoutputonly="no">