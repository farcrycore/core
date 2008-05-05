<cfcomponent displayname="Permission" hint="A right that can be granted via a role" extends="types" output="false" description="This allows developers to add new permissions to the application. Each permission corresponds to a right to perform an action, access a section of the webtop, or view a webskin.">
	<cfproperty name="title" type="string" default="" hint="The name of this permission" bLabel="true" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="shortcut" type="string" default="" hint="Shortcut for permission to use in code" ftSeq="2" ftFieldset="" ftLabel="Shortcut" ftType="string" />
	<cfproperty name="aRelatedtypes" type="array" default="" hint="If this permission is item-specific set this field to the types that it can be applied to" ftSeq="3" ftFieldset="" ftLabel="Join on" ftType="array" ftJoin="farPermission" ftRenderType="list" ftLibraryData="getRelatedTypeList" ftShowLibraryLink="false" />
	<cfproperty name="aRoles" type="string" default="" hint="Meta-property for managing this properties relationships with roles" ftSeq="4" ftFieldset="" ftLabel="Roles" ftType="reversearray" ftSelectMultiple="true" ftJoin="farRole" ftJoinProperty="aPermissions" bSave="false" />
	
	<cffunction name="getRelatedTypeList" access="public" output="false" returntype="query" hint="Returns the types that can be associated with a permission. References the ftJoin attribute of the farBarnacle aObjects property.">
		<cfset var qResult = querynew("objectid,label","varchar,varchar") />
		<cfset var ud = "" />
		<cfset var group = "" />
		
		<cfif structkeyexists(application.stCOAPI,"farBarnacle")>
			<cfloop list="#application.stCOAPI.farBarnacle.stProps.referenceid.metadata.ftJoin#" index="thistype">
				<cfif structkeyexists(application.stCOAPI,thistype)>
					<cfset queryaddrow(qResult) />
					<cfset querysetcell(qResult,"objectid","#thistype#") />
					<cfset querysetcell(qResult,"label","#application.stCOAPI[thistype].displayname#")>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="permissionExists" access="public" output="false" returntype="boolean" hint="Returns true if the permission exists">
		<cfargument name="permission" type="string" required="true" hint="The permission shortcut" />
	
		<cfset var qPermissions = "" />
		
		<cfif not application.security.hasLookup(permission=arguments.permission)>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbOwner#farPermission
				where	lower(shortcut)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.permission)#" />
			</cfquery>
			
			<cfif qPermissions.recordcount>
				<cfset application.security.setLookup(permission=arguments.permission,objectid=qPermissions.objectid[1]) />
				<cfreturn true />
			<cfelse>
				<cfreturn false />
			</cfif>
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="string" hint="Returns the objectid for the specified object">
		<cfargument name="name" type="string" required="true" hint="Pass in a permission name and the objectid will be returned" />
		
		<cfset var qPermissions = "" />
		
		<cfif not application.security.hasLookup(permission=arguments.name)>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbOwner#farPermission
				where	lower(shortcut)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfif qPermissions.recordcount>
				<cfreturn application.security.setLookup(permission=arguments.name,objectid=qPermissions.objectid[1]) />
			<cfelse>
				<cfreturn "" />
			</cfif>
		<cfelse>
			<cfreturn application.security.getLookup(permission=arguments.name) />
		</cfif>
	</cffunction>
	
	<cffunction name="getLabel" access="public" output="false" returntype="string" hint="Returns the label for the specified object">
		<cfargument name="objectid" type="uuid" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qPermissions = "" />
		
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select	shortcut
			from	#application.dbOwner#farPermission
			where	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfreturn qPermissions.shortcut[1] />
	</cffunction>	

	<cffunction name="setData" access="public" output="true" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		
		<cfset var qRoles = "" />
		<cfset var qBarnacles = "" />
		<cfset var stRole = structnew() />
		
		<cfif arraylen(arguments.stProperties.aRelatedtypes)>
			<!--- Find related role-permissions --->
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	parentid as objectid, seq
				from	#application.dbowner#farRole_aPermissions
				where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
			</cfquery>
			
			<!--- Remove them from the roles --->
			<cfloop query="qRoles">
				<!--- Delete the barnacle --->
				<cfset stRole = application.security.factory.role.getData(qRoles.objectid[currentrow]) />
				<cfset arraydeleteat(stRole.aPermissions,qRoles.seq[currentrow]) />
				<cfset application.security.factory.role.setData(stRole) />
				
				<cfif application.security.isCached(role=qRoles.objectid[currentrow],permission=arguments.stProperties.objectid)>
					<cfset application.security.deleteCache(role=qRoles.objectid[currentrow],permission=arguments.stProperties.objectid) />
				</cfif>
			</cfloop>
			
			<!--- Find barnacles with types not in the new list --->
			<cfquery datasource="#application.dsn#" name="qBarnacles">
				select	objectid,referenceid,roleid
				from	#application.dbowner#farBarnacle
				where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
						and objecttype not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arraytolist(arguments.stProperties.aRelatedtypes)#" />)
			</cfquery>
			
			<!--- Remove barnacles --->
			<cfloop query="qBarnacles">
				<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid[currentrow]) />
				
				<cfif application.security.isCached(role=qBarnacles.roleid[currentrow],permission=arguments.stProperties.objectid,object=qBarnacles.referenceid[currentrow])>
					<cfset application.security.deleteCache(role=qBarnacles.roleid[currentrow],permission=arguments.stProperties.objectid,object=qBarnacles.referenceid[currentrow]) />
				</cfif>
			</cfloop>
		<cfelse>
			<!--- Find related barnacles --->
			<cfquery datasource="#application.dsn#" name="qBarnacles">
				select	objectid,referenceid,roleid
				from	#application.dbowner#farBarnacle
				where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#" />
			</cfquery>
			
			<!--- Remove barnacles --->
			<cfloop query="qBarnacles">
				<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid[currentrow]) />
				
				<cfif application.security.isCached(role=qBarnacles.roleid[currentrow],permission=arguments.stProperties.objectid,object=qBarnacles.referenceid[currentrow])>
					<cfset application.security.deleteCache(role=qBarnacles.roleid[currentrow],permission=arguments.stProperties.objectid,object=qBarnacles.referenceid[currentrow]) />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- Remove objectid lookup --->
		<cfset application.security.removelookup(permission=arguments.stProperties.objectid) />

		<cfreturn super.setData(stProperties=arguments.stProperties,user=arguments.user,auditNote=arguments.auditNote,bAudit=arguments.bAudit,dsn=arguments.dsn,bSessionOnly=arguments.bSessionOnly,bAfterSave=arguments.bAfterSave) />
	</cffunction>
	
	<cffunction name="getAllPermissions" access="public" output="false" returntype="string" hint="Returns a list of all permissions (optionally restricted by related type)">
		<cfargument name="relatedtype" type="string" required="false" hint="The type to restrict permissions by" />
		
		<cfset var qPermissions = "" />
		
		<cfif not structkeyexists(arguments,"relatedtype")>
			<!--- Get all permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		objectid
				from		#application.dbowner#farPermission
				order by	title asc
			</cfquery>
		<cfelseif arguments.relatedtype eq "">
			<!--- Get all general permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		objectid
				from		#application.dbowner#farPermission
				where		objectid not in (
								select distinct parentid
								from	#application.dbowner#farPermission_aRelatedtypes
							)
				order by	title asc
			</cfquery>
		<cfelse>
			<!--- Get type specific permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select		p.objectid
				from		#application.dbowner#farPermission p
							inner join
							#application.dbowner#farPermission_aRelatedtypes pt
							on p.objectid=pt.parentid
				where		pt.data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.relatedtype#" />
				order by	title asc
			</cfquery>
		</cfif>
		
		<cfreturn valuelist(qPermissions.objectid) />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farRole and farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var qRoles = "" />
		<cfset var qBarnacles = "" />
		<cfset var stRole = structnew() />
		<cfset var stPermission = structnew() />
		
		<!--- Find related role-permissions --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	parentid as objectid, seq
			from	#application.dbowner#farRole_aPermissions
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>		
		
		<!--- Remove them from the roles --->
		<cfloop query="qRoles">
			<!--- Delete the barnacle --->
			<cfset stRole = application.security.factory.role.getData(qRoles.objectid[currentrow]) />
			<cfset arraydeleteat(stRole.aPermissions,qRoles.seq[currentrow]) />
			<cfset application.security.factory.role.setData(stRole) />
				
			<cfif application.security.isCached(role=qRoles.objectid[currentrow],permission=arguments.objectid)>
				<cfset application.security.deleteCache(role=qRoles.objectid[currentrow],permission=arguments.objectid) />
			</cfif>
		</cfloop>
		
		<!--- Find related barnacles --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select	objectid,referenceid,roleid
			from	#application.dbowner#farBarnacle
			where	permissionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<!--- Remove barnacles --->
		<cfloop query="qBarnacles">
			<cfset application.security.factory.barnacle.delete(objectid=qBarnacles.objectid[currentrow]) />
			
			<cfif application.security.isCached(role=qBarnacles.roleid[currentrow],permission=arguments.objectid,object=qBarnacles.referenceid[currentrow])>
				<cfset application.security.deleteCache(role=qBarnacles.roleid[currentrow],permission=arguments.objectid,object=qBarnacles.referenceid[currentrow]) />
			</cfif>
		</cfloop>
		
		<!--- Remove name lookup --->
		<cfset application.security.removeLookup(permission=arguments.objectid) />
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,auditNote=arguments.auditNote) />
	</cffunction>
	
</cfcomponent>