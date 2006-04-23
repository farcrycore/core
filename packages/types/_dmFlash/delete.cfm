<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFlash/delete.cfm,v 1.4 2004/12/06 19:03:10 tom Exp $
$Author: tom $
$Date: 2004/12/06 19:03:10 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmFlash delete method. Deletes physical file from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- delete normal image --->
<cfif len(stObj.flashMovie)>
	<cftry>
		<cffile action="delete" file="#application.path.defaultFilePath#/#stObj.flashMovie#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<!--- delete --->
<cfset super.delete(stObj.objectId)>