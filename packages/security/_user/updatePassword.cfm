<!--- get user details --->
<cfscript>
	stUser = request.dmsec.oAuthentication.getUser(userlogin="#session.dmsec.authentication.userlogin#",userDirectory="#session.dmsec.authentication.userdirectory#");
</cfscript>

<!--- check old password is entered correctly --->
<cfif stUser.userPassword eq form.oldPassword>
	<cfquery name="update" datasource="#stArgs.dsn#">
		UPDATE #application.dbowner#dmUser SET
		userPassword=<cfqueryparam value="#stArgs.newPassword#" cfsqltype="CF_SQL_VARCHAR"  null="No">
		WHERE userId=<cfqueryparam value="#stArgs.userId#" cfsqltype="CF_SQL_VARCHAR" null="No">
	</cfquery>
	<cfset bUpdate = true>
<cfelse>
	<cfset bUpdate = false>
</cfif>