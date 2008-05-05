<cfcomponent displayname="Barnacle" hint="Used to grant an item specific permissions." extends="types" output="false">
	<cfproperty name="roleid" type="uuid" default="" hint="The role this barnacle is attached to" ftSeq="1" ftFieldset="" ftLabel="Role" ftType="uuid" ftJoin="farRole" />
	<cfproperty name="permissionid" type="uuid" default="" hint="The permission this barnacle is controlling" ftSeq="2" ftFieldset="" ftLabel="Permission" ftType="uuid" ftJoin="farPermission" />
	<cfproperty name="referenceid" type="uuid" default="" hint="The object this barnacle is attached to" ftSeq="3" ftFieldset="" ftLabel="Object" ftType="uuid" ftJoin="dmNavigation" />
	<cfproperty name="objecttype" type="string" default="" hint="The type of the object" ftSeq="4" ftFieldset="" ftLabel="Type" ftType="string" />
	<cfproperty name="barnaclevalue" type="numeric" default="0" hint="Deny: -1, Inherity (only for tree types): 0, Grant: 1. Absence of a barnacle implies inherit. If the object can't inherit that is equivilent to deny." ftSeq="5" ftFieldset="" ftLabel="Right" ftType="list" ftList="-1:Deny,0:Inherit,1:Grant" />
	
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
			where	roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
					and permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
					and referenceid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
		</cfquery>
		
		<cfif qBarnacle.recordcount>
			<cfloop list="#qBarnacle.columnlist#" index="col">
				<cfset stBarnacle[col] = qBarnacle[col] />
			</cfloop>
		<cfelse>
			<!--- Barnacle didn't exist - create it --->
			<cfset stBarnacle = getData(objectid=createuuid()) />
			<cfset stBarnacle.roleid = arguments.role />
			<cfset stBarnacle.permissionid = arguments.permission />
			<cfset stBarnacle.referenceid = arguments.object />
			<cfset stBarnacle.barnaclevalue = 0 />
		</cfif>
			
		<cfreturn stBarnacle />
	</cffunction>

	<cffunction name="cacheObjectRights" access="public" output="false" returntype="void" hint="Caches all the permissions for a particular object">
		<cfargument name="object" type="uuid" required="true" hint="The object to cache" />
		
		<cfset var qBarnacles = "" />
		
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select		rp.role as roleid, rp.permission as permission, b.barnaclevalue
			from		(
							select	r.objectid as role, p.parentid as permission
							from	#application.dbowner#farRole r, #application.dbowner#farPermission_aRelatedtypes pt
							where	pt=<cfqueryparam cfsqltype="cf_sql_varchar" value="#findType(arguments.object)#" />
						) rp
						left outer join
						#application.dbowner#farBarnacle b
						on rp.role=b.roleid and rp.permission=b.permissionid
			where		b.referenceid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
			order by	rp.role, rp.permission
		</cfquery>
		
		<cfloop query="qBarnacles">
			<cfif barnaclevalue eq "">
				<cfset application.security.setCache(role=roleid,permission=permissionid,object=arguments.object,right=0) />
			<cfelse>
				<cfset application.security.setCache(role=roleid,permission=permissionid,object=arguments.object,right=barnaclevalue) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied barnacle">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle being queried" />
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="forcerefresh" type="boolean" required="false" default="false" hint="Should the cache be forcably refreshed" />
		
		<cfset var stBarnacle = structnew() />
		<cfset var thisrole = "" />
		<cfset var result = -1 />
		<cfset var thisresult = -1 />
		<cfset var qSequred = "" />
		<cfset var typename = "" />
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)><!--- Barnacle specified by objectid --->
		
			<!--- Get barnacle --->
			<cfset stBarnacle = getData(arguments.barnacle) />
			<cfset arguments.role = stBarnacle.roleid />
			<cfset arguments.permission = stBarnacle.permissionid />
			<cfset arguments.object = stBarnacle.referenceid />
			
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
		<cfif len(typename)>
			<cfquery datasource="#application.dsn#" name="qSecured">
				select	count(parentid) as secured
				from	#application.dbowner#farPermission_aRelatedtypes
				where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
						and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#typename#" />
			</cfquery>
			<cfif not qSecured.secured>
				<cfreturn 1 />
			</cfif>
			
			<cfloop list="#arguments.role#" index="thisrole">
				<!--- If the name of the role was passed in, get the objectid --->
				<cfif not isvalid("uuid",thisrole)>
					<cfset thisrole = application.security.factory.role.getID(thisrole) />
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
		</cfif>

		
		<cfreturn numberFormat(result) />
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
			<cfset arguments.role = stBarnacle.roleid />
			<cfset arguments.permission = stBarnacle.permissionid />
			<cfset arguments.object = stBarnacle.referenceid />
			
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
		<cfif listcontainsnocase("dmNavigation",typename)>
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
		<cfset var typename = application.coapi.coapiAdmin.findType(arguments.object) />
		
		<!--- Check existence of permission --->
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = application.security.factory.permission.getID(arguments.permission) />
			
			<!--- If permission doesn't exist grant it --->
			<cfif not len(arguments.permission)>
				<cfreturn 1 />
			</cfif>
		</cfif>
		<!--- If permission is related to this type, grant it --->
		<cfif not listcontains(application.security.factory.permission.getAllPermissions(typename),arguments.permission)>
			<cfreturn 1 />
		</cfif>
		
		<cfset actual = getRight(role=arguments.role,permission=arguments.permission,object=arguments.object) />
		
		<cfif actual eq 0>
			<cfif getInheritedRight(role=arguments.role,permission=arguments.permission,object=arguments.object) eq 1>
				<cfreturn 1 />
			<cfelse>
				<cfreturn 0 />
			</cfif>
		<cfelseif actual eq 1>
			<cfreturn 1 />
		<cfelse>
			<cfreturn 0 />
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
			where	referenceid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
	</cffunction>

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<!--- Update object type --->
		<cfset arguments.stProperties.objecttype = findType(arguments.stProperties.referenceid) />
		
		<cfif not arguments.bAfterSave>
			<!--- Update permission cache --->
			<cfset application.security.setCache(role=arguments.stProperties.roleid,permission=arguments.stProperties.permissionid,object=arguments.stProperties.referenceid,right=arguments.stProperties.barnaclevalue) />
		</cfif>
		
		<cfreturn super.setData(stProperties=arguments.stProperties,user=arguments.user,auditNote=arguments.auditNote,bAudit=arguments.bAudit,dsn=arguments.dsn,bSessionOnly=arguments.bSessionOnly,bAfterSave=arguments.bAfterSave) />
	</cffunction>
	
</cfcomponent>