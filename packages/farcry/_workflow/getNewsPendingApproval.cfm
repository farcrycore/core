<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_workflow/getNewsPendingApproval.cfm,v 1.9 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: gets users who can approve pending items $


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
	iObjectDeletePermission = application.security.checkPermission(permission="NewsApprove");
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