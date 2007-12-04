<cfcomponent displayname="User Directory" hint="Defines an abstract user directory" output="false" bAbstract="true" title="Abstract UD" key="ABSTRACTUD">
	
	<cfset variables.metadata = structnew() />

	<cffunction name="init" access="public" output="true" returntype="any" hint="Does initialisation of user directory">
		<cfset var stMetadata = getMetadata(this) />
		<cfset var attr = "" />
		
		<cfloop condition="not structisempty(stMetadata)">
			<!--- Get attributes --->
			<cfloop collection="#stMetadata#" item="attr">
				<cfif issimplevalue(stMetadata[attr]) and not listcontains("bindingname,displayname,extends,fullname,functions,hint,name,namespace,output,path,porttypename,serviceportname,style,type,wsdlfile",attr) and not structkeyexists(this,attr)>
					<cfset this[attr] = stMetadata[attr] />
				</cfif>
			</cfloop>
			
			<!--- If key isn't specified, use the name of the component --->
			<cfif not structkeyexists(this,"key")>
				<cfset this.key = listlast(stMetadata.fullname,".") />
			</cfif>
			
			<!--- If title isn't specified, use the displayname --->
			<cfif not structkeyexists(this,"key")>
				<cfset this.title = stMetadata.displayname />
			</cfif>
			
			<!--- Do the same for ancestors --->
			<cfif structkeyexists(stMetadata,"extends")>
				<cfset stMetadata = stMetadata.extends />
			<cfelse>
				<cfset stMetadata = structnew() />
			</cfif>
		</cfloop>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="getLoginForm" access="public" output="false" returntype="string" hint="Returns the form component to use for login">
		
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getLoginForm function" />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="struct" hint="Attempts to process a user. Runs every time the login form is loaded.">
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the authenticate function" />
		
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
	
	<cffunction name="getUserGroups" access="public" output="false" returntype="string" hint="Returns the groups that the specified user is a member of">
		<cfargument name="UserID" type="string" required="true" hint="The user being queried" />
		
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getUserGroups function" />
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="getAllGroups" access="public" output="false" returntype="string" hint="Returns all the groups that this user directory supports">
		<cfthrow message="The #variables.metadata.displayname# user directory needs to implement the getAllGroups function" />
		
		<cfreturn "" />
	</cffunction>
	
</cfcomponent>