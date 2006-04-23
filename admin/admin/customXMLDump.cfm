<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/customXMLDump.cfm,v 1.5 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.5 $

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

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>

	<span class="formHeader">Custom XML Dump</span>
	<cfif isXMLDoc(application.customAdminXML)>
		<cfdump var="#application.customAdminXML#" label="application.customAdminXML"><cfoutput><p>&nbsp;</p></cfoutput>
	<cfelse>
		<cfoutput><h3>No VALID Custom Admin XML schema defined </h3></cfoutput>	
	</cfif>
			
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">