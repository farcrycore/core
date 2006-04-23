<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/delete.cfm,v 1.5 2005/07/28 06:06:52 guy Exp $
$Author: guy $
$Date: 2005/07/28 06:06:52 $
$Name: milestone_3-0-0 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: dmFile delete method. Deletes physical file from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- delete --->
<cfset super.delete(stObj.objectId)>

<!--- delete physical file --->
<cftry>
	<cfif NOT (structKeyExists(stObj,"bLibrary") AND stObj.bLibrary EQ 1) AND stObj.filename NEQ "">
		<cffile action="delete" file="#stObj.filepath#/#stObj.filename#">
	</cfif>
	<cfcatch type="any"></cfcatch>
</cftry>