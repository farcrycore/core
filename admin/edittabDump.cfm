<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabDump.cfm,v 1.8 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

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

	<h3><cfoutput>#application.adminBundle[session.dmProfile.locale].objectDump#</cfoutput></h3>
	
	<!--- get object details and dump results --->
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
	<cfdump var="#stobj#" label="#stobj.label# Dump">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
