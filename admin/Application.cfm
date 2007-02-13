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
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->

<!--- 
 dynamically determine the right farcry application instance to administer
 and include the relevant Application.cfm file from the project; default
 to webroot.
--->


<!---------------------------------------------------------
DETERMINE WHICH PROJECT WE ARE ATTEMPTING TO ADMINISTER
 --------------------------------------------------------->	
<cfmodule template="/farcry/core/tags/farcry/callProjectApplication.cfm" plugin="farcry" />
	
	

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
<cfif application.sysinfo.bwebtopaccess>
	<!--- grab webtop config file and parse --->
	<cfset application.factory.owebtop=createobject("component", "#application.packagepath#.farcry.webtop").init()>
<cfelse>
	<cfoutput>
	<div style="margin: 10% 30% 0% 30%; padding: 10px; border: 2px navy solid; background: ##dedeff; font-family: Verdana; font-color: navy; text-align: center;">
		<h2>Webtop Access Restricted</h2>
		<p>Webtop access has been specifically restricted on this server.  Please contact your system administrator for details.</p>
	</div>
	</cfoutput>
	<cfabort />
</cfif>

<!--- end: initialise webtop factory object --->


<cfsetting enablecfoutputonly="no">