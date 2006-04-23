<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/delete.cfm,v 1.2 2003/09/11 01:04:17 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:04:17 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmFile delete method. Deletes physical file from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- delete physical file --->
<cftry>
	<cffile action="delete" file="#stObj.filepath#/#stObj.filename#">
	<cfcatch type="any"></cfcatch>
</cftry>

<!--- delete --->
<cfset super.delete(stObj.objectId)>