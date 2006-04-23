<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabDump.cfm,v 1.7 2005/01/17 00:22:27 brendan Exp $
$Author: brendan $
$Date: 2005/01/17 00:22:27 $
$Name: milestone_2-3-2 $
$Revision: 1.7 $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$
$TODO:  $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iDumpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectDumpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iDumpTab eq 1>
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	
	<br>
	<span class="FormTitle"><cfoutput>#application.adminBundle[session.dmProfile.locale].objectDump#</cfoutput></span>
	<p></p>
	
	<!--- get object details and dump results --->
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
	<cfdump var="#stobj#" label="#stobj.label# Dump">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
