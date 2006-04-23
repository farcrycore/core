<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getNewsPendingApproval.cfm,v 1.8 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: gets users who can approve pending items $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- initialize structure --->
<cfset stPendingNews = structNew()>

<!--- check if user can approve news items --->
<cfscript>
	iObjectDeletePermission = request.dmSec.oAuthorisation.checkPermission(permissionName="NewsApprove",reference="PolicyGroup");
</cfscript>

		
<cfif iObjectDeletePermission eq 1>
	<!--- get all news items pending approval --->
	<cfquery name="qGetNews" datasource="#application.dsn#">
    SELECT * FROM #application.dbowner#dmNews WHERE status = 'pending'
	</cfquery>
	
	<cfif qGetNews.recordcount gt 0>
		<cfloop query="qGetNews">
			<!--- Create structure for news details to be outputted later --->
            <cfscript>
            o_profile = createObject("component", application.types.dmProfile.typePath);
            stProfile = o_profile.getProfile(userName=qGetNews.createdBy);

			stPendingNews[qGetNews.objectID] = structNew();
			stPendingNews[qGetNews.objectID]["objectTitle"] = qGetNews.title;
			stPendingNews[qGetNews.objectID]["objectCreatedBy"] = qGetNews.createdBy;
			stPendingNews[qGetNews.objectID]["objectCreatedByEmail"] = stProfile.emailAddress;
			stPendingNews[qGetNews.objectID]["objectLastUpdate"] = qGetNews.dateTimeLastUpdated;
            </cfscript>
		</cfloop>
	</cfif>
</cfif>