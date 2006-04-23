<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/customXMLDump.cfm,v 1.6 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.6 $

|| DESCRIPTION || 
$DESCRIPTION: Dumps custom admin setup$
$TODO: $ 

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>

	<span class="formHeader"><cfoutput>#application.adminBundle[session.dmProfile.locale].customXMLDump#</cfoutput></span>
	<cfif isXMLDoc(application.customAdminXML)>
		<cfdump var="#application.customAdminXML#" label="application.customAdminXML"><cfoutput><p>&nbsp;</p></cfoutput>
	<cfelse>
		<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].noValidCustomXMLDefined#</h3></cfoutput>	
	</cfif>
			
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">