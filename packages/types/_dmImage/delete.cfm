<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/delete.cfm,v 1.4 2005/05/30 02:37:43 guy Exp $
$Author: guy $
$Date: 2005/05/30 02:37:43 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmImage delete method. Deletes physical files from server$
$TODO: Verity check/delete$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfif NOT StructIsEmpty(stObj)>

	<!--- delete --->
	<cfset super.delete(stObj.objectId)>

	<!--- delete Source Image --->
	<cfif len(stObj.SourceImage)>
		<cftry>
      <cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.SourceImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	
	<!--- delete Standard Image --->
	<cfif len(stObj.StandardImage)>
		<cftry>
			<cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.StandardImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	
	<!--- delete Thumbnail Image --->
	<cfif len(stObj.ThumbnailImage)>
		<cftry>
			<cffile action="delete" file="#expandPath("#application.url.webroot#/#stObj.ThumbnailImage#")#">
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>	
</cfif>