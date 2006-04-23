<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/delete.cfm,v 1.2 2003/09/11 01:04:17 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:04:17 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmImage delete method. Deletes physical files from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- delete normal image --->
<cfif len(stObj.imagefile)>
	<cftry>
		<cffile action="delete" file="#stObj.originalImagePath#/#stObj.imagefile#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<!--- delete thumbnail image --->
<cfif len(stObj.thumbnail)>
	<cftry>
		<cffile action="delete" file="#stObj.thumbnailImagePath#/#stObj.thumbnail#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<!--- delete optimised image --->
<cfif len(stObj.optimisedImage)>
	<cftry>
		<cffile action="delete" file="#stObj.optimisedImagePath#/#stObj.optimisedImage#">
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

<!--- delete --->
<cfset super.delete(stObj.objectId)>