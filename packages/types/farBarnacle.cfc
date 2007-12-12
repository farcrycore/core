<cfcomponent displayname="Barnacle" hint="Used to grant an item specific permissions." extends="types" output="false">
	<cfproperty name="role" type="uuid" default="" hint="The role this barnacle is attached to" ftSeq="1" ftFieldset="" ftLabel="Role" ftType="uuid" ftJoin="farRole" />
	<cfproperty name="permission" type="uuid" default="" hint="The permission this barnacle is controlling" ftSeq="2" ftFieldset="" ftLabel="Permission" ftType="uuid" ftJoin="farPermission" />
	<cfproperty name="object" type="uuid" default="" hint="The object this barnacle is attached to" ftSeq="3" ftFieldset="" ftLabel="Object" ftType="uuid" ftJoin="dmNavigation" />
	<cfproperty name="objecttype" type="string" default="" hint="The type of the object" ftSeq="4" ftFieldset="" ftLabel="Type" ftType="string" />
	<cfproperty name="barnaclevalue" type="numeric" default="0" hint="Deny: -1, Inherity (only for tree types): 0, Grant: 1. Absence of a barnacle implies deny." ftSeq="5" ftFieldset="" ftLabel="Right" ftType="list" ftList="-1:Deny,0:Inherit,1:Grant" />
	
	<!--- 
		Content types like navigation have rights (permissions) that can be granted item by item. That
		is, the permission is added to a role for SPECIFIC OBJECTS. A barnacle is a role+permission+object
		combination. Values for the right are deny (-1), inherit (0), and grant(1). If the user is a member
		of multiple roles, the most permissive right for a given permission+object is returned.
		
		For checking tree permissions, each item from the specified object up to root is checked. The first
		non-inherit right is returned. If every node has an inherit permission, deny access.
	 --->

	<cffunction name="getBarnacle" access="public" output="false" returntype="struct" hint="Returns a barnacle based on the permission and role and object">
		<cfargument name="role" type="uuid" required="true" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="uuid" required="true" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="uuid" required="true" hint="The object the barnacle is attached to" />
		
		<cfset var qBarnacle = "" />
		<cfset var stBarnacle = structnew() />
		<cfset var col = "" />
		
		<cfquery datasource="#application.dsn#" name="qBarnacle">
			select	*
			from	#application.dbowner#farBarnacle
			where	role=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
					and permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
					and object=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
		</cfquery>
		
		<cfif qBarnacle.recordcount>
			<cfloop list="#qBarnacle.columnlist#" index="col">
				<cfset stBarnacle[col] = qBarnacle[col] />
			</cfloop>
		<cfelse>
			<!--- Barnacle didn't exist - create it --->
			<cfset stBarnacle = getData(objectid=createuuid()) />
			<cfset stBarnacle.role = arguments.role />
			<cfset stBarnacle.permission = arguments.permission />
			<cfset stBarnacle.object = arguments.object />
		</cfif>
			
		<cfreturn stBarnacle />
	</cffunction>

	<cffunction name="cacheObjectRights" access="public" output="false" returntype="void" hint="Caches all the permissions for a particular object">
		<cfargument name="object" type="uuid" required="true" hint="The object to cache" />
		
		<cfset var qBarnacles = "" />
		
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select		rp.role as role, rp.permission as permission, b.barnaclevalue
			from		(
							select	r.objectid as role, p.parentid as permission
							from	#application.dbowner#farRole r, #application.dbowner#farPermission_relatedtypes pt
							where	pt=<cfqueryparam cfsqltype="cf_sql_varchar" value="#findType(arguments.object)#" />
						) rp
						left outer join
						#application.dbowner#farBarnacle b
						on rp.role=b.role and rp.permission=b.permission
			where		b.object=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
			order by	rp.role, rp.permission
		</cfquery>
		
		<cfloop query="qBarnacles">
			<cfif barnaclevalue eq "">
				<cfset application.security.setCache(role=role,permission=permission,object=arguments.object,right=0) />
			<cfelse>
				<cfset application.security.setCache(role=role,permission=permission,object=arguments.object,right=barnaclevalue) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied barnacle">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle being queried" />
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />
		
		<cfset stBarnacle = structnew() />
		<cfset thisrole = "" />
		<cfset result = -1 />
		<cfset thisresult = -1 />
		<cfset qSequred = "" />
		<cfset typename = "" />
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)><!--- Barnacle specified by objectid --->
		
			<!--- Get barnacle --->
			<cfset stBarnacle = getData(arguments.barnacle) />
			<cfset arguments.role = stBarnacle.role />
			<cfset arguments.permission = stBarnacle.permission />
			<cfset arguments.object = stBarnacle.object />
			
		<cfelseif isvalid("uuid",arguments.permission) and isvalid("uuid",arguments.object)>
			
			<cfif not len(arguments.role)>
				<cfset arguments.role = application.security.getCurrentRoles() />
			</cfif>
			
		<cfelse>
		
			<!--- Invalid arguments --->
			<cfthrow message="farBarnacle.getRight: required arguments - barnacle or role + permission + object" />
			
		</cfif>
		
		<!--- If this type hasn't been secured (i.e. no object permissions) default to grant --->
		<cfset typename = findType(arguments.object) />
		<cfif not len(typename)>
			<cfset thisobject = getData(objectid=arguments.object) />
			<cfif structkeyexists(thisobject,"typename")>
				<cfset typename = thisobject.typename />
			</cfif>
		</cfif>
		<cfquery datasource="#application.dsn#" name="qSecured">
			select	count(parentid) as secured
			from	#application.dbowner#farPermission_relatedtypes
			where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
					and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#typename#" />
		</cfquery>
		<cfif not qSecured.secured>
			<cfreturn true />
		</cfif>
			
		<cfloop list="#arguments.role#" index="thisrole">
			<!--- If the name of the role was passed in, get the objectid --->
			<cfif not isvalid("uuid",thisrole)>
				<cfset thisrole = getID(thisrole) />
			</cfif>
			
			<!--- If possible use the cache, otherwise update cache --->
			<cfif not arguments.forcerefresh and application.security.isCached(role=thisrole,permission=arguments.permission,object=arguments.object)>
				<cfset thisresult = application.security.getCache(role=thisrole,permission=arguments.permission,object=arguments.object) />
			<cfelse>
				<cfset thisresult = application.security.setCache(role=thisrole,permission=arguments.permission,object=arguments.object,right=getBarnacle(thisrole,arguments.permission,arguments.object).barnaclevalue) />
			</cfif>
			
			<!--- Result is the most permissable right. 1 is the most permissable, so if that is returned we don't need to check any more --->
			<cfif thisresult eq 1>
				<cfreturn 1 />
			<cfelseif thisresult gt result>
				<cfset result = thisresult />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getInheritedRight" access="public" output="false" returntype="numeric" hint="Returns the right that would be granted if this barnacle was set to inherit">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle being queried" />
		<cfargument name="role" type="string" required="false" default="" hint="The roles to check" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />

		<cfset var stBarnacle = structnew() />
		<cfset var thisobject = "" />
		<cfset var thisresult = 0 />
		<cfset var result = -1 />
		<cfset var typename = "" />
		<cfset var qAncestors = "" />
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)><!--- Barnacle specified by objectid --->
		
			<!--- Get barnacle --->
			<cfset stBarnacle = getData(arguments.barnacle).objectid />
			<cfset arguments.role = stBarnacle.role />
			<cfset arguments.permission = stBarnacle.permission />
			<cfset arguments.object = stBarnacle.object />
			
		<cfelseif not (len(arguments.role) and isvalid("uuid",arguments.permission) and isvalid("uuid",arguments.object))>
		
			<!--- Invalid arguments --->
			<cfthrow message="farBarnacle.getInheritedRight: required arguments - barnacle or role + permission + object" />
			
		</cfif>
		
		<!--- Get object type --->
		<cfset typename = findType(arguments.object) />
		<cfif not len(typename)>
			<cfset thisobject = getData(objectid=arguments.object) />
			<cfif structkeyexists(thisobject,"typename")>
				<cfset typename = thisobject.typename />
			</cfif>
		</cfif>
		
		<!--- If this is a tree type, get the ancestors --->
		<cfif listcontains("dmNavigation",typename)>
			<cfset qAncestors = application.factory.oTree.getAncestors(objectid=arguments.object) />
			<cfset arguments.object = application.factory.oUtils.listReverse(listappend(valuelist(qAncestors.objectid),arguments.object)) />
		</cfif>
		
		<!--- Check each object --->
		<cfloop list="#arguments.object#" index="thisobject">
		
			<!--- Default is -1 when there is no barnacle --->
			<cfset thisresult = getRight(role=arguments.role,permission=arguments.permission,object=thisobject,forcerefresh=arguments.forcerefresh) />
		
			<cfif thisresult neq 0>
				<!--- If the permission is specified rather than inherited, return it --->
				<cfreturn thisresult />
			</cfif>
			
		</cfloop>
		
		<!--- If every role says inherit right up the ancestory chain then deny --->
		<cfreturn -1 />
	</cffunction>
	
	<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Checks the permission on an object">
		<cfargument name="object" type="uuid" required="true" hint="The objectid to check. If it is for a tree type, searches up the ancestor list, and returns the first non-zero (not inherited) result, false if there isn't one." />
		<cfargument name="permission" type="uuid" required="true" hint="The permission to check" />
		<cfargument name="role" type="string" required="false" hint="List of roles to check" />
		
		<cfset var actual = -1 />
		
		<cfset actual = getRight(role=arguments.role,permission=arguments.permission,object=arguments.object) />
		
		<cfif actual eq 0>
			<cfreturn getInheritedRight(role=arguments.role,permission=arguments.permission,object=arguments.object) />
		<cfelse>
			<cfreturn actual />
		</cfif>
	</cffunction>

	<cffunction name="updateRight" access="public" output="false" returntype="void" hint="Adds or removes a permission">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle to update" />
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="right" type="numeric" required="true" hint="Deny: -1, inherit: 0, grant: 1" />
		
		<cfset stBarnacle = structnew() />
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)>
			<!--- Get barnacle by objectid --->
			<cfset stBarnacle = getData(arguments.barnacle) />
		<cfelseif isvalid("uuid",arguments.role) and isvalid("uuid",arguments.permission) and isvalid("uuid",arguments.object)>
			<!--- Get barnacle by rolect+permission+object --->
			<cfset stBarnacle = getBarnacle(arguments.role,arguments.permission,arguments.object) />
		<cfelse>
			<!--- Invalid arguments --->
			<cfthrow message="farBarnacle.updateRight: required arguments - barnacle or role + permission + object" />
		</cfif>
		
		<!--- Update barnacle --->
		<cfset stBarnacle.barnaclevalue = arguments.right />
		<cfset setData(stBarnacle) />
	</cffunction>

	<cffunction name="deleteObjectBarnacles" access="public" output="false" returntype="void" hint="Deletes the barnacles for the specified object">
		<cfargument name="objectid" type="uuid" required="true" hint="The object to remove" />
	
		<cfquery datasource="#application.dsn#">
			delete
			from	#application.dbowner#farBarnacle
			where	object=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
	</cffunction>

	<cffunction name="AfterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />

		<!--- Update object type --->
		<cfset arguments.stProperties.objecttype = findType(arguments.stProperties.object) />
		
		<!--- Update permission cache --->
		<cfset application.security.setCache(role=arguments.stProperties.role,permission=arguments.stProperties.permission,object=arguments.stProperties.object,right=arguments.stProperties.barnaclevalue) />
		
		<cfreturn super.AfterSave(arguments.stProperties) />
	</cffunction>
	
</cfcomponent>