<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmXMLExport/delete.cfm,v 1.1 2003/09/17 07:35:34 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 07:35:34 $
$Name: milestone_3-0-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmXMLExport delete method. Deletes physical file from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- delete physical file --->
<cftry>
	<cffile action="delete" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#">
	<cfcatch type="any"></cfcatch>
</cftry>

<!--- delete --->
<cfset super.delete(stObj.objectId)>
