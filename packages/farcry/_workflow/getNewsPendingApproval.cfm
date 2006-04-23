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
            o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
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