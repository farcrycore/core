<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmFlash/delete.cfm,v 1.5.2.1 2005/11/28 03:58:30 suspiria Exp $
$Author: suspiria $
$Date: 2005/11/28 03:58:30 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

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
		<cffile action="delete" file="#application.config.file.folderpath_flash#/#stObj.flashMovie#">
		<cfcatch type="any">
			<cfset stReturn.bSuccess = 0>
			<cfset stReturn.message = "#cfcatch.message#">
		</cfcatch>
	</cftry>
</cfif>

<!--- delete --->
<cfset super.delete(stObj.objectId)>