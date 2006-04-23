<cfif stArgs.objectType eq "dmHTML">
	<!--- Get recent objects and nav parent --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#stArgs.numberOfObjects#">
		select #stArgs.objectType#.objectID,#stArgs.objectType#.title, #stArgs.objectType#.createdby, #stArgs.objectType#.dateTimeCreated, userEmail, dmNavigation_aObjectIds.objectid as objectParent
		From #stArgs.objectType#, dmUser, dmNavigation_aObjectIds 
		WHERE dmUser.userLogin = createdby
			and dmNavigation_aObjectIds.data = #stArgs.objectType#.objectid
		order by #stArgs.objectType#.dateTimeCreated desc
	</cfquery>
<cfelse>
	<!--- Get recent objects --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#stArgs.numberOfObjects#">
		select objectID,title, createdby, dateTimeCreated, userEmail
		From #stArgs.objectType#, dmUser
		WHERE dmUser.userLogin = createdby
		order by dateTimeCreated desc
	</cfquery>
</cfif>

