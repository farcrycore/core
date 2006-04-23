<cfquery name="qUser" datasource="#application.dsn#">
	SELECT * FROM dmUser
	WHERE userLogin = '#stArgs.userId#'	
</cfquery>