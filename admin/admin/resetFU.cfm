<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/resetFU.cfm,v 1.14 2005/08/31 07:32:03 guy Exp $
$Author: guy $
$Date: 2005/08/31 07:32:03 $
$Name: milestone_3-0-0 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: Deletes existing FU entries and recretes for entire tree$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes" requestTimeOut="1000">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfset iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>
	<cfset objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
	<cfset objFU.createALL()>

	<cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].resetFriendlyURLs#</h3>
	<span class="frameMenuBullet">&raquo;</span> #application.adminBundle[session.dmProfile.locale].friendlyURLsCreated#<p></p>
	</cfoutput>
	
	<!--- check factory fu object loaded --->
	<!--- <cfif not structKeyExists(application.factory,"oFU")>
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU")>
			<cfcatch>
				<cfoutput>#application.adminBundle[session.dmProfile.locale].fuPluginError#</cfoutput><cfabort>
			</cfcatch>
		</cftry>
	</cfif> --->
	
	<!--- call create method --->
	<!--- <cfset application.factory.oFU.createALL()> --->
	
	<!--- show success message --->


<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">