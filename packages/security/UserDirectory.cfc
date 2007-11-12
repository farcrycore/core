<cfcomponent displayname="User Directory" hint="Defines an abstract user directory" output="false" bAbstract="true">
	
	<cfset variables.metadata = structnew() />
	
	<cfset this.title = "Abstract UD" /><!--- Used in the interface where the long name of this UD instance is required --->
	<cfset this.key = "ABSTRACTUD" /><!--- Used in code where a struct key is required --->

	<cffunction name="getLoginForm" access="public" output="false" returntype="component" hint="Returns the form component to use for login">
		
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getLoginForm function" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the authenticate function" />
		
		<!--- This function should return a struct in the form: 
				.AUTHENTICATED = false
				.ERRORMESSAGE = ""
			  OR
				.AUTHENTICATED = true
				.USERID = "" (This ID only needs to be unique for this user directory)
			  OR
				EMPTY (If no form submission was detected)
		--->
		
		<cfreturn structnew() />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="string" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getUserGroups function" />
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="string" hint="Returns all the groups that this user directory supports">
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getAllGroups function" />
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="getGroupUsers" access="public" output="false" returntype="string" hint="Returns all the users in a specified group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getGroupUsers function" />
		
		<cfreturn "" />
	</cffunction>
	
</cfcomponent>