<!--- initialize structure --->
<cfset stPendingNews = structNew()>

<!--- check if user can approve news items --->
<cf_dmSec_PermissionCheck permissionName="NewsApprove" reference1="PolicyGroup" r_iState="iObjectDeletePermission">
		
<cfif iObjectDeletePermission>
	<!--- get all news items pending approval --->
	<cfquery name="qGetNews" datasource="#application.dsn#">
		select * from dmNews, dmUser
		where status= 'pending' and dmNews.createdBy = dmUser.userLogin
	</cfquery>
	
	<cfif qGetNews.recordcount gt 0>
		<cfloop query="qGetNews">
			<!--- Create structure for news details to be outputted later --->
			<cfset stPendingNews[qGetNews.ObjectId] = structNew()>
			<cfset stPendingNews[qGetNews.ObjectId]["objectTitle"] = qGetNews.title>
			<cfset stPendingNews[qGetNews.ObjectId]["objectCreatedBy"] = qGetNews.createdBy>
			<cfset stPendingNews[qGetNews.ObjectId]["objectCreatedByEmail"] = qGetNews.userEmail>
			<cfset stPendingNews[qGetNews.ObjectId]["objectLastUpdate"] = qGetNews.dateTimeLastUpdated>
		</cfloop>
	</cfif>
</cfif>
				
				