<cfcomponent displayname="FarcryUD User" hint="Used by FarcryUD to store user information" extends="types" output="false" description="Stores login information about a FarCry User Directory user, and the groups they are members of">
	<cfproperty name="userid" type="string" default="" hint="The unique id for this user. Used for logging in" ftSeq="1" ftFieldset="" ftLabel="User ID" ftType="string" />
	<cfproperty name="password" type="string" default="" hint="" ftSeq="2" ftFieldset="" ftLabel="Password" ftType="password" />
	<cfproperty name="userstatus" type="string" default="invactive" hint="The status of this user" ftSeq="3" ftFieldset="" ftLabel="User status" ftType="list" ftList="active:Active,inactive:Inactive,pending:Pending" />
	<cfproperty name="groups" type="array" default="" hint="The groups this member is a member of" ftSeq="4" ftFieldset="" ftLabel="Groups" ftType="array" ftJoin="farGroup" />
	
	<cffunction name="getByUserID" access="public" output="false" returntype="struct" hint="Returns the data struct for the specified user id">
		<cfargument name="userid" type="string" required="true" hint="The user id" />
		
		<cfset var stResult = structnew() />
		<cfset var qUser = "" />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farUser
			where	userid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#" />
		</cfquery>
		
		<cfif qUser.recordcount>
			<cfset stResult = getData(qUser.objectid) />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>