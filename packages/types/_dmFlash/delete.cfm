<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFlash/delete.cfm,v 1.1 2003/03/31 06:35:31 brendan Exp $
$Author: brendan $
$Date: 2003/03/31 06:35:31 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmFlash delete method. Deletes physical file from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- delete normal image --->
<cfif len(stObj.flashMovie)>
	<cftry>
		<cffile action="delete" file="#application.defaultFilePath#/#stObj.flashMovie#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<!--- delete actual object --->
<cfset deleteData(stObj.objectId)>

<!--- check if in verity collection --->

<!--- delete from verity --->
