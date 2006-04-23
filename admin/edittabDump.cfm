<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabDump.cfm,v 1.5 2003/09/11 01:26:52 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:26:52 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$
$TODO:  $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<!--- check permissions --->
<cfscript>
	iDumpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectDumpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iDumpTab eq 1>
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	
	<br>
	<span class="FormTitle">Object Dump</span>
	<p></p>
	
	<!--- get object details and dump results --->
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
	<cfdump var="#stobj#" label="#stobj.title# Dump">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
