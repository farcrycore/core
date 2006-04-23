<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/customXMLDump.cfm,v 1.8 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.8 $

|| DESCRIPTION || 
$DESCRIPTION: Dumps custom admin setup$
 

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

	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].customXMLDump#</h3></cfoutput>
	<cfif isXMLDoc(application.customAdminXML)>
		<cfdump var="#application.customAdminXML#" label="application.customAdminXML"><cfoutput><p>&nbsp;</p></cfoutput>
	<cfelse>
		<cfoutput><h5 class="error">#application.adminBundle[session.dmProfile.locale].noValidCustomXMLDefined#</h5></cfoutput>	
	</cfif>
			
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">