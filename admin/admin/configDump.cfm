<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/configDump.cfm,v 1.5 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$DESCRIPTION: Dumps config values$
$TODO: $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

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

	<span class="formHeader">Config Dumps</span>
	
	<!--- loop over all configs and dump the contents of them --->
	<cfloop collection="#application.config#" item="config">
		<cfdump var="#application.config[config]#" label="#config#"><cfoutput><p>&nbsp;</p></cfoutput>
	</cfloop>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">