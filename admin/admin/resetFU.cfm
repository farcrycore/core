<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/resetFU.cfm,v 1.11 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Deletes existing FU entries and recretes for entire tree$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes" requestTimeOut="1000">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>
	<cfoutput><span class="FormTitle">#application.adminBundle[session.dmProfile.locale].resetFriendlyURLs#</span><p></p></cfoutput>
	
	<!--- check factory fu object loaded --->
	<cfif not structKeyExists(application.factory,"oFU")>
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU")>
			<cfcatch>
				<cfoutput>#application.adminBundle[session.dmProfile.locale].fuPluginError#</cfoutput><cfabort>
			</cfcatch>
		</cftry>
	</cfif>
	
	<!--- call create method --->
	<cfset application.factory.oFU.createALL()>
	
	<!--- show success message --->
	<cfoutput>
	<p></p>
	<span class="frameMenuBullet">&raquo;</span> #application.adminBundle[session.dmProfile.locale].friendlyURLsCreated#<p></p></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">