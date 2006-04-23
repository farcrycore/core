<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/resetFU.cfm,v 1.9 2003/11/24 03:14:05 paul Exp $
$Author: paul $
$Date: 2003/11/24 03:14:05 $
$Name: milestone_2-1-2 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Deletes existing FU entries and recretes for entire tree$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>
	<cfoutput><span class="FormTitle">Reset Friendly URLs</span><p></p></cfoutput>
	
	<!--- check factory fu object loaded --->
	<cfif not structKeyExists(application.factory,"oFU")>
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU")>
			<cfcatch>
				<cfoutput>Error setting up Friendly URL Plugin. Please check your settings and try again.</cfoutput><cfabort>
			</cfcatch>
		</cftry>
	</cfif>
	
	<!--- call create method --->
	<cfset application.factory.oFU.createALL()>
	
	<!--- show success message --->
	<cfoutput>
	<p></p>
	<span class="frameMenuBullet">&raquo;</span> Friendly url's created.<p></p></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">