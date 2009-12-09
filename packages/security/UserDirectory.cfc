<cfcomponent displayname="User Directory" hint="Defines an abstract user directory" output="false" bAbstract="true">
	
	<cfset variables.metadata = structnew() />

	<cffunction name="init" access="public" output="true" returntype="any" hint="Does initialisation of user directory">
		<cfset var stMetadata = getMetadata(this) />
		<cfset var attr = "" />
		
		<cfloop condition="not structisempty(stMetadata)">
			<!--- Get attributes --->
			<cfloop collection="#stMetadata#" item="attr">
				<cfif issimplevalue(stMetadata[attr]) and not listcontains("bindingname,extends,fullname,functions,hint,name,namespace,output,path,porttypename,serviceportname,style,type,wsdlfile",attr) and not structkeyexists(this,attr)>
					<cfset this[attr] = stMetadata[attr] />
				</cfif>
			</cfloop>
			
			<!--- Do the same for ancestors --->
			<cfif structkeyexists(stMetadata,"extends")>
				<cfset stMetadata = stMetadata.extends />
			<cfelse>
				<cfset stMetadata = structnew() />
			</cfif>
		</cfloop>
		
		<cfset stMetadata = getMetadata(this) />
		
		<!--- If key isn't specified, use the name of the component --->
		<cfif not structkeyexists(this,"key")>
			<cfset this.key = listlast(stMetadata.name,".") />
		</cfif>
		
		<!--- If title isn't specified, use the displayname --->
		<cfif not structkeyexists(this,"title")>
			<cfset this.title = this.displayname />
		</cfif>
		
		<!--- If seq isn't specified, use the 9999 --->
		<cfif not structkeyexists(this,"seq")>
			<cfset this.seq = 9999 />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfthrow message="The #this.title# user directory needs to implement the getLoginForm function" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfthrow message="The #this.title# user directory needs to implement the authenticate function" />
		
		<!--- This function should return a struct in the form: 
				.AUTHENTICATED = false
				.MESSAGE = ""
				OTHER VALUES CAN BE ADDED FOR USE BY CUSTOM LOGIN FORMS
			  OR
				.AUTHENTICATED = true
				.USERID = "" (This ID only needs to be unique for this user directory)
			  OR
				EMPTY (If no form submission was detected)
		--->
		
		<cfreturn structnew() />
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="array" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfthrow message="The #this.title# user directory needs to implement the getUserGroups function" />
		
		<cfreturn arraynew(1) />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="array" hint="Returns all the groups that this user directory supports">
		<cfthrow message="The #this.title# user directory needs to implement the getAllGroups function" />
		
		<cfreturn arraynew(1) />
	</cffunction>
	
	<cffunction name="getGroupUsers" access="public" output="false" returntype="array" hint="Returns all the users in a particular group">
		<cfargument name="group" type="string" required="true" hint="The group to query" />
		
		<cfthrow message="The #this.title# user directory needs to implement the getGroupUsers function" />
		
		<cfreturn arraynew(1) />
	</cffunction>
	
	<cffunction name="getProfile" access="public" output="false" returntype="struct" hint="Returns profile data available through the user directory">
		<cfargument name="userid" type="string" required="true" hint="The user directory specific user id" />
		<cfargument name="stCurrentProfile" type="struct" required="false" hint="The current user profile" />
		
		<!---
			This struct should contain values that do (or can) map to dmProfile properties.
			
			A special "override" flag in this struct should be set to true if these values are intended to replace values stored in dmProfile. Leave out
			or set to false if these values are only meant to be the initial defaults.
		 --->
		
		<cfreturn structnew() />
	</cffunction>
	
	<cffunction name="isEnabled" access="public" output="false" returntype="boolean" hint="Returns true if this user directory is active. This function can be overridden to check for the existence of config settings.">
		
		<cfreturn true />
	</cffunction>
	
</cfcomponent>