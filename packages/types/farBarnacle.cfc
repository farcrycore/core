<cfcomponent displayname="Barnacle" hint="Used to grant an item specific permissions." extends="types" output="false" bRefObjects="false" bSystem="true">
	<cfproperty name="roleid" type="uuid" default="" hint="The role this barnacle is attached to" ftSeq="1" ftFieldset="" ftLabel="Role" ftType="uuid" ftJoin="farRole" />
	<cfproperty name="permissionid" type="uuid" default="" hint="The permission this barnacle is controlling" ftSeq="2" ftFieldset="" ftLabel="Permission" ftType="uuid" ftJoin="farPermission" />
	<cfproperty name="referenceid" type="uuid" default="" hint="The object this barnacle is attached to" ftSeq="3" ftFieldset="" ftLabel="Object" ftType="uuid" ftJoin="dmNavigation,farCoapi" />
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
		<cfargument name="object" type="string" required="true" hint="The object the barnacle is attached to" />
		
		<cfset var qBarnacle = "" />
		<cfset var stBarnacle = structnew() />
		<cfset var col = "" />
		<cfset var barnacleHashID = hash("#arguments.role#-#arguments.permission#-#arguments.object#") />

		<cfparam name="request.stBarnacleCache" default="#structNew()#" />
		
		<cfif structKeyExists(request.stBarnacleCache, barnacleHashID)>
			<cfreturn request.stBarnacleCache[barnacleHashID] />
		</cfif>
		
		<cfquery datasource="#application.dsn#" name="qBarnacle">
			select	objectid,roleid,permissionid,referenceid,barnaclevalue
			from	#application.dbowner#farBarnacle
			where	roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
					and permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
					and referenceid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
		</cfquery>
		
		<cfif qBarnacle.recordcount>
			<cfloop list="#qBarnacle.columnlist#" index="col">
				<cfset stBarnacle[col] = qBarnacle[col][1] />
			</cfloop>
		<cfelse>
			<!--- Barnacle didn't exist - create it --->
			<cfset stBarnacle = structNew() />
			<cfset stBarnacle.objectid = application.fc.utils.createJavaUUID() />
			<cfset stBarnacle.typename = "farBarnacle" />
			<cfset stBarnacle.roleid = arguments.role />
			<cfset stBarnacle.permissionid = arguments.permission />
			<cfset stBarnacle.referenceid = arguments.object />
			<cfset stBarnacle.barnaclevalue = 0 />
		</cfif>
		
		<cfset request.stBarnacleCache[barnacleHashID] = stBarnacle />
		
		<cfreturn stBarnacle />
	</cffunction>

	<cffunction name="cacheNodeBarnacles" access="public" output="false" returntype="void" hint="Grabs the barnacle information for a node and it's ancestors and caches it in the request scope">
		<cfargument name="referenceid" type="uuid" required="true" hint="The object to cache" />
		
		<cfquery datasource="#application.dsn#" name="request.barnaclecache">
			select		*
			from		#application.dbowner#nested_tree_objects t
						inner join
						#application.dbowner#farBarnacle b
						on t.objectid=b.referenceid
			where		nleft <= (
						    select	nleft
						    from	nested_tree_objects
						    where	objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.referenceid#" />
						)
						and nright >= (
						    select	nright
						    from	nested_tree_objects
						    where	objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.referenceid#" />
						)
		</cfquery>
	</cffunction>
	
	<cffunction name="getRight" access="public" output="false" returntype="numeric" hint="Returns the right for the specfied barnacle">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle being queried" />
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="objecttype" type="string" required="false" default="" hint="The type of object to check." />
		<cfargument name="requestcache" type="boolean" required="false" default="false" hint="Use request cache" />
		
		<cfset var stBarnacle = structnew() />
		<cfset var thisrole = "" />
		<cfset var result = -1 />
		<cfset var thisresult = -1 />
		<cfset var qSecured = "" />
		<cfset var typename = "" />

		<!--- If request cache is turned on (mainly for Manage Permissions) use that --->
		<cfif arguments.requestcache>
			<cfif not structkeyexists(request,"barnaclecache")>
				<cfset cacheNodeBarnacles(arguments.object) />
			</cfif>
			<cfquery dbtype="query" name="qSecured">
				select		barnaclevalue
				from		request.barnaclecache
				where		roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
							and permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
							and referenceid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
			</cfquery>
			
			<cfif qSecured.recordcount>
				<cfreturn qSecured.barnaclevalue[1] />
			<cfelse>
				<cfreturn 0 />
			</cfif>
		</cfif>
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)><!--- Barnacle specified by objectid --->
		
			<!--- Get barnacle --->
			<cfset stBarnacle = getData(arguments.barnacle) />
			<cfset arguments.role = stBarnacle.roleid />
			<cfset arguments.permission = stBarnacle.permissionid />
			<cfset arguments.object = stBarnacle.referenceid />
			
		<cfelseif isvalid("uuid",arguments.permission) and len(arguments.object)>
			
			<cfif not len(arguments.role)>
				<cfset arguments.role = application.security.getCurrentRoles() />
			</cfif>
			
		<cfelse>
		
			<!--- Invalid arguments --->
			<cfthrow message="farBarnacle.getRight: required arguments - barnacle or role + permission + object" />
			
		</cfif>
		
		<!--- If this type hasn't been secured (i.e. no object permissions) default to grant --->
		
		<cfif not len(arguments.objecttype)>
			<cfset arguments.objecttype = findType(arguments.object) />
		</cfif>
		<cfif len(arguments.objecttype)>
			<cfquery datasource="#application.dsn#" name="qSecured">
				select	count(parentid) as secured
				from	#application.dbowner#farPermission_aRelatedtypes
				where	parentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
						and data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objecttype#" />
			</cfquery>
			<cfif not qSecured.secured>
				<cfreturn 1 />
			</cfif>
			
			<cfset thisrole = arguments.role>
			<!--- If the name of the role was passed in, get the objectid --->
			<cfif not isvalid("uuid",thisrole)>
				<cfset thisrole = application.security.factory.role.getID(thisrole) />
			</cfif>
			
			<cfset result = getBarnacle(thisrole,arguments.permission,arguments.object).barnaclevalue />

		</cfif>
		
		<cfreturn numberFormat(result) />
	</cffunction>
	
	<cffunction name="getInheritedRight" access="public" output="false" returntype="numeric" hint="Returns the right that would be granted if this barnacle was set to inherit">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle being queried" />
		<cfargument name="role" type="string" required="false" default="" hint="The roles to check" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="objecttype" type="string" required="false" default="" hint="The type of object to check." />
		<cfargument name="requestcache" type="boolean" required="false" default="false" hint="Use request cache" />
		
		<cfset var stBarnacle = structnew() />
		<cfset var thisobject = "" />
		<cfset var result = -1 />
		<cfset var typename = "" />
		<cfset var qResult = "" />
		<cfset var inheritedRightHashID = hash("#arguments.barnacle#-#arguments.role#-#arguments.permission#-#arguments.object#-#arguments.requestcache#") />
		<cfset var qSecured	= '' />

		<cfparam name="request.stinheritedRightCache" default="#structNew()#" />
		
		<cfif structKeyExists(request.stinheritedRightCache, inheritedRightHashID)>
			<cfreturn request.stinheritedRightCache[inheritedRightHashID] />
		</cfif>
		
		<!--- If request cache is turned on (mainly for Manage Permissions) use that --->
		<cfif arguments.requestcache>
			<cfif not structkeyexists(request,"barnaclecache")>
				<cfset cacheNodeBarnacles(arguments.object) />
			</cfif>
			<cfquery dbtype="query" name="qSecured">
				select		barnaclevalue
				from		request.barnaclecache
				where		roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
							and permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
							and referenceid<><cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
							and barnaclevalue<>0
				order by	nlevel desc
			</cfquery>
			
			<cfif qSecured.recordcount>
				<cfset request.stInheritedRightCache[inheritedRightHashID] = qSecured.barnaclevalue[1] />
				<cfreturn qSecured.barnaclevalue[1] />
			<cfelse>
				<cfset request.stInheritedRightCache[inheritedRightHashID] = 0 />
				<cfreturn 0 />
			</cfif>
		</cfif>
		
		<!--- Either barnacle or role+permission+object must be specified --->
		<cfif isvalid("uuid",arguments.barnacle)><!--- Barnacle specified by objectid --->
		
			<!--- Get barnacle --->
			<cfset stBarnacle = getData(arguments.barnacle).objectid />
			<cfset arguments.role = stBarnacle.roleid />
			<cfset arguments.permission = stBarnacle.permissionid />
			<cfset arguments.object = stBarnacle.referenceid />
			
		<cfelseif not (len(arguments.role) and isvalid("uuid",arguments.permission) and len(arguments.object))>
		
			<!--- Invalid arguments --->
			<cfthrow message="farBarnacle.getInheritedRight: required arguments - barnacle or role + permission + object" />
			
		</cfif>
		
		<!--- Get object type --->
		
		
		<cfif not len(arguments.objecttype)>
			<cfset arguments.objecttype = findType(arguments.object) />
		</cfif>
		<cfif not len(arguments.objecttype)>
			<cfset thisobject = getData(objectid=arguments.object) />
			<cfif structkeyexists(thisobject,"typename")>
				<cfset arguments.objecttype = thisobject.typename />
			</cfif>
		</cfif>

		<!--- If this is a tree type, get the ancestors --->
		<cfif listcontainsnocase("dmNavigation",arguments.objecttype)>

			<cfquery name="qResult" datasource="#application.dsn#">
				select	t.*, b.*
				from	#application.dbowner#nested_tree_objects t
						inner join
						#application.dbowner#farBarnacle b
						on t.objectid=b.referenceid,
						
						#application.dbowner#nested_tree_objects tc
					
				where	t.nleft <= tc.nleft and t.nright >= tc.nright
						and tc.objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.object#" />
						
						and b.roleid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.role#" />
						and b.permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permission#" />
						and b.barnaclevalue<>0
					
				order by t.nlevel desc
			</cfquery>

			<cfif qResult.recordCount gt 0>
				<cfset result = qResult.barnaclevalue[1]>
			<cfelse>
				<!--- If every object says inherit right up the ancestory chain then deny --->
				<cfset result = -1>
			</cfif>

		<cfelse>
			<cfset result = getRight(role=arguments.role,permission=arguments.permission,object=arguments.object, objecttype=arguments.objecttype) />
		</cfif>
		
		<cfset request.stInheritedRightCache[inheritedRightHashID] = result />
		<cfreturn result />
	</cffunction>
	
	<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Checks the permission on an object">
		<cfargument name="object" type="string" required="true" hint="The referenceid to check. If it is for a tree type, searches up the ancestor list, and returns the first non-zero (not inherited) result, false if there isn't one." />
		<cfargument name="permission" type="uuid" required="true" hint="The permission to check" />
		<cfargument name="objecttype" type="string" required="false" default="" hint="The type of object to check." />
		<cfargument name="role" type="string" required="false" hint="List of roles to check" />
		
		<cfset var typename = "" />
		<cfset var thisrole = "" />
		
		<cfset var hashID = hash("#arguments.object#-#arguments.permission#-#arguments.objecttype#-#arguments.role#") />		

		<cfparam name="request.stCheckPermissionCache" default="#structNew()#" />

		<cfif structKeyExists(request.stCheckPermissionCache, hashID)>
			<cfreturn request.stCheckPermissionCache[hashID] />
		</cfif>
		
		<cfif not len(arguments.objecttype)>
			<cfset arguments.objecttype = application.coapi.coapiAdmin.findType(arguments.object) />
		</cfif>
		
		<!--- Check existence of permission --->
		<cfif not isvalid("uuid",arguments.permission)>
			<cfset arguments.permission = application.security.factory.permission.getID(arguments.permission) />
			
			<!--- If permission doesn't exist grant it --->
			<cfif not len(arguments.permission)>
				<cfreturn 1 />
			</cfif>
		</cfif>
		
		<!--- If permission is not related to this type, grant it --->
		<!--- This allows FarCry to easily handle the many combinations of type and object permission setups --->
		<cfif not listcontains(application.security.factory.permission.getAllPermissions(arguments.objecttype),arguments.permission)>
			<cfreturn 1 />
		</cfif>

		<!--- check each role --->
		<cfloop list="#arguments.role#" index="thisrole">
			
			<!--- return as soon as any role has explicit grant permission --->
			<cfif getInheritedRight(role=thisrole,permission=arguments.permission,object=arguments.object, objecttype="#arguments.objecttype#") eq 1>
				<cfset request.stCheckPermissionCache[hashID] = 1 />
				<cfreturn 1 />
			</cfif>

		</cfloop>

		<cfset request.stCheckPermissionCache[hashID] = 0 />
		<cfreturn 0 />
	</cffunction>

	<cffunction name="updateRight" access="public" output="false" returntype="void" hint="Adds or removes a permission">
		<cfargument name="barnacle" type="string" required="false" default="" hint="The barnacle to update" />
		<cfargument name="role" type="string" required="false" default="" hint="The role the barnacle is attached to" />
		<cfargument name="permission" type="string" required="false" default="" hint="The permission the barnacle is based on" />
		<cfargument name="object" type="string" required="false" default="" hint="The object the barnacle is attached to" />
		<cfargument name="right" type="numeric" required="true" hint="Deny: -1, inherit: 0, grant: 1" />
		
		<cfset var stBarnacle = structnew() />
		<cfset var oldright = 0 />
		
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
		<cfset oldright = stBarnacle.barnaclevalue />
		<cfset stBarnacle.barnaclevalue = arguments.right />
		<cfset setData(stBarnacle) />
		
		<!--- Notify object of change --->
		<cfif oldright neq arguments.right>
			<cfset application.fapi.getContentType(typename=stBarnacle.objecttype).onSecurityChange(changetype="object",objectid=stBarnacle.referenceid,typename=stBarnacle.objecttype,farRoleID=stBarnacle.roleid,farPermissionID=stBarnacle.permissionid,oldright=oldright,newright=arguments.right) />
		</cfif>
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
		<cfif not structKeyExists(arguments.stProperties, "objecttype") OR not len(arguments.stProperties.objecttype)>
			<cfset arguments.stProperties.objecttype = findType(arguments.stProperties.referenceid) />
		</cfif>
		
		<!--- Clear security cache --->
		<cfset application.security.initCache() />
				
		<cfreturn super.setData(stProperties=arguments.stProperties,user=arguments.user,auditNote=arguments.auditNote,bAudit=arguments.bAudit,dsn=arguments.dsn,bSessionOnly=arguments.bSessionOnly,bAfterSave=arguments.bAfterSave) />
	</cffunction>
	
</cfcomponent>