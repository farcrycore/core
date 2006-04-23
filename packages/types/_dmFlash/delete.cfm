<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFlash/delete.cfm,v 1.5 2005/08/12 06:55:59 guy Exp $
$Author: guy $
$Date: 2005/08/12 06:55:59 $
$Name: milestone_3-0-0 $
$Revision: 1.5 $

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
		<cfcatch type="any">
			<cfset stReturn.bSuccess = 0>
			<cfset stReturn.message = "#cfcatch.message#">
		</cfcatch>
	</cftry>
</cfif>

<!--- delete --->
<cfset super.delete(stObj.objectId)>