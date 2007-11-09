<cfcomponent displayname="Permission" hint="A right that can be granted via a role" extends="types" output="false" description="This allows developers to add new permissions to the application. Each permission corresponds to a right to perform an action, access a section of the webtop, or view a webskin.">
	<cfproperty name="title" type="string" default="" hint="The name of this permission" bLabel="true" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="shortcut" type="string" default="" hint="Shortcut for permission to use in code" ftSeq="2" ftFieldset="" ftLabel="Shortcut" ftType="string" />
	<cfproperty name="relatedtypes" type="array" default="" hint="If this permission is item-specific set this field to the types that it can be applied to" ftSeq="3" ftFieldset="" ftLabel="Join on" ftType="array" ftJoin="farPermission" ftRenderType="list" ftLibraryData="getRelatedTypeList" ftShowLibraryLink="false" />
	
	<cffunction name="getRelatedTypeList" access="public" output="false" returntype="string" hint="Returns the types that can be associated with a permission. References the ftJoin attribute of the farBarnacle aObjects property.">
		<cfset var qResult = querynew("objectid,label","varchar,varchar") />
		<cfset var ud = "" />
		<cfset var group = "" />
		
		<cfif structkeyexists(application.stCOAPI,"farBarnacle")>
			<cfloop list="#application.stCOAPI.farBarnacle.stProps.aObjectIDs.metadata.ftJoin#" index="thistype">
				<cfif structkeyexists(application.stCOAPI,thistype)>
					<cfset queryaddrow(qResult) />
					<cfset querysetcell(qResult,"objectid","#thistype#") />
					<cfset querysetcell(qResult,"label","#application.stCOAPI[thistype].displayname#")>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn qResult />
	</cffunction>
	
	<cffunction name="getID" access="public" output="false" returntype="uuid" hint="Returns the objectid for the specified object">
		<cfargument name="name" type="string" required="true" hint="Pass in a permission name and the objectid will be returned" />
		
		<cfset var qPermissions = "" />
		
		<cfif not isdefined("application.security.permissionlookup") or not structkeyexists(application.security.permissionlookup,arguments.name)>
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid,shortcut
				from	#application.dbOwner#farPermission
			</cfquery>
			
			<cfparam name="application.security" default="#structnew()#" />
			<cfparam name="application.security.permissionlookup" default="#structnew()#" />
			<cfloop query="qPermissions">
				<cfset application.security.permissionlookup[shortcut] = objectid />
			</cfloop>
		</cfif>
		
		<cfif structkeyexists(application.security.permissionlookup,arguments.name)>
			<cfreturn application.security.permissionlookup[arguments.name] />
		<cfelse>
			<cfthrow message="Permission '#arguments.name#' doesn't exist." />
		</cfif>
	</cffunction>

	<cffunction name="removeRelated" access="public" output="false" returntype="void" hint="Removes related barnacles">
		<cfargument name="objectid" type="uuid" required="true" hint="The permission to remove barnacles for" />
	
		<cfset var qRoles = "" />
		<cfset var stRole = structnew() />
		<cfset var oRole = createObject("component", application.stcoapi["farRole"].packagePath) />
		<cfset var oBarnacle = createobject("component",application.stCOAPI.farBarnacle.packagepath) />
		
		<!--- Find related role-permissions --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	parentid as objectid, seq
			from	#application.dbowner#farRole_permissions
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>		
		
		<!--- Remove them from the roles --->
		<cfloop query="qRoles">
			<!--- Delete the barnacle --->
			<cfset stRole = oRole.getData(qRoles.objectid[currentrow]) />
			<cfset arraydeleteat(stRole.permissions,qRoles.seq[currentrow]) />
			<cfset oRole.setData(stRole) />
		</cfloop>
		
		<!--- Remove barnacles --->
		<cfquery datasource="#application.dsn#">
			delete
			from	#application.dbowner#farBarnacle
			where	permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
	</cffunction>
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfif len(arguments.relatedtypes)>
			<!--- Find related role-permissions --->
			<cfquery datasource="#application.dsn#" name="qRoles">
				select	parentid as objectid, seq
				from	#application.dbowner#farRole_permissions
				where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
			</cfquery>		
			
			<!--- Remove them from the roles --->
			<cfloop query="qRoles">
				<!--- Delete the barnacle --->
				<cfset stRole = oRole.getData(qRoles.objectid[currentrow]) />
				<cfset arraydeleteat(stRole.permissions,qRoles.seq[currentrow]) />
				<cfset oRole.setData(stRole) />
			</cfloop>
			
			<!--- Remove barnacles for wrong types --->
			<cfquery datasource="#application.dsn#">
				delete
				from	#application.dbowner#farBarnacle
				where	permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
						objecttype not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.stProperties.relatedtypes#" />)
			</cfquery>
		<cfelse>
			<!--- Remove barnacles --->
			<cfquery datasource="#application.dsn#">
				delete
				from	#application.dbowner#farBarnacle
				where	permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
			</cfquery>
		</cfif>

		<cfreturn arguments.stProperties />
	</cffunction>
	
	<cffunction name="getAllPermissions" access="public" output="false" returntype="string" hint="Returns a list of all permissions (optionally restricted by related type)">
		<cfargument name="relatedtype" type="string" required="false" hint="The type to restrict permissions by" />
		
		<cfset var qPermissions = "" />
		
		<cfif not structkeyexists(arguments,"relatedtype")>
			<!--- Get all permissions --->
			<cfquery datasource="#applications.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbowner#farPermission
			</cfquery>
		<cfelseif arguments.relatedtype eq "">
			<!--- Get all general permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	objectid
				from	#application.dbowner#farPermission
				where	objectid not in (
							select distinct parentid
							from	#application.dbowner#farPermission_relatedtypes
						)
			</cfquery>
		<cfelse>
			<!--- Get type specific permissions --->
			<cfquery datasource="#application.dsn#" name="qPermissions">
				select	p.objectid
				from	#application.dbowner#farPermission p
						inner join
						#application.dbowner#farPermission_relatedtypes pt
						on p.objectid=pt.parentid
				where	pt.data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.realtedtype#" />
			</cfquery>
		</cfif>
		
		<cfreturn valuelist(qPermissions.objectid) />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farRole and farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset removeRelated(arguments.stProperties.objectid) />
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>
	
	<cffunction name="getUsers" access="public" output="false" returntype="string" hint="Returns a list of the users that have this permission">
		<cfargument name="objectid" type="uuid" required="true" hint="The permission to query" />
	
		<cfset var qRoles = "" />
		<cfset var qGroups = "" />
		<cfset var group = "" />
		<cfset var result = "" />
	
		<!--- Get roles with that permission --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	parentid
			from	#application.dbowner#farRole_permissions
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permissionid#" />
		</cfquery>
		
		<cfif qRoles.recorcount>
			<!--- Get the groups for those roles --->
			<cfquery datasource="#application.dsn#" name="qGroups">
				select	data
				from	#appliation.dbowner#farRole_groups
				where	parentid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qRoles.parentid)#" />)
			</cfquery>
			
			<!--- Get the users for those groups --->
			<cfloop query="qGroups">
				<cfif structkeyexist(application.security.userdirectories,listlast(data,"_"))>
					<cfloop list="#application.security.userdirectories[listlast(data,'_')].getGroupUsers(listfirst(data,'_'))#" index="group">
						<cfset result = application.factory.oUtils.listMerge(result,"#group#_#listlast(data,'_')#") />
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
</cfcomponent>