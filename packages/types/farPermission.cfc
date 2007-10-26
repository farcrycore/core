<cfcomponent displayname="Permission" hint="A right that can be granted via a role" extends="types" output="false">
	<cfproperty name="title" type="string" default="" hint="The name of this permission" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="shortcut" type="string" default="" hint="Shortcut for permission to use in code" ftSeq="2" ftFieldset="" ftLabel="Shortcut" ftType="string" />
	<cfproperty name="relatedtypes" type="string" default="" hint="If this permission is item-specific set this field to the types that it can be applied to" ftSeq="3" ftFieldset="" ftLabel="Related types" ftType="list" ftListDataTypename="farPermission" ftListData="getRelatedTypeList" ftSelectMultiple="true" />
	
	<cffunction name="getRelatedTypesList" access="public" output="false" returntype="string" hint="Returns the types that can be associated with a permission. References the ftJoin attribute of the farBarnacle aObjects property.">
		<cfargument name="objectid" type="uuid" required="true" hint="Not used" />
		
		<cfset var thistype = "" />
		<cfset var result = "" />
		
		<cfif structkeyexists(application.stCOAPI,"farBarnacle")>
			<cfloop list="#application.stCOAPI.farBarnacle.stProps.aObjects.metadata.aObjects.ftJoin#" index="thistype">
				<cfif structkeyexists(application.stCOAPI,thistype)>
					<cfset result = listappend(result,"#thistype#:#application.stCOAPI[thistype].displayname#")>
				</cfif>
			</cfloop>
		<cfelse>
			 WTF - apparantly farBarnacle doesn't exist --->
			<cfreturn "" />
		</cfif>
		
	</cffunction>
	
	<cffunction name="addRelatedBarnacles" access="public" output="false" returntype="void" hint="Sets up related barnacles on all roles">
		<cfargument name="objectid" type="uuid" required="true" hint="The permission to set up barnacles for" />
		
		<!--- Find roles without related barnacles --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select	objectid
			from	farRole
			where	objectid not in (
						select	parentid
						from	farRole_barnacles
						where	data in (
							select	objectid
							from	farBarnacle
							where 	permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
					)
		</cfquery>
		
		<!--- Create a barnacle and add it to each role without --->
		<cfloop query="qRoles">
			<cfset stBarnacle = structnew() />
			<cfset stBarnacle.objectid = createuuid() />
			<cfset stBarnacle.permission = arguments.objectid />
			<cfset oBarnacle.createData(stProperties=stBarnacle) />
			
			<cfset stRole = oRole.getData(objectid=qRoles.objectid[currentrow]) />
			<cfparam name="stRole.barnacles" default="#arraynew(1)#" />
			<cfset arrayappend(stRole.barnacles,stBarnacle.objectid) />
			<cfset oRole.setData(stProperties=stRole) />
		</cfloop>
	</cffunction>
	
	<cffunction name="removeRelatedBarnacles" access="public" output="false" returntype="void" hint="Removes related barnacles from all roles">
		<cfargument name="objectid" type="uuid" required="true" hint="The permission to remove barnacles for" />
	
		<cfset var qRole = "" />
		<cfset var oBarnacle = createobject("component",application.stCOAPI.farBarnacle.packagepath) />
		<cfset var stRole = structnew() />
		<cfset var oRole = createobject("component",application.stCOAPI.farRole.packagepath) />
		
		<!--- Find related barnacles --->
		<cfquery datasource="#application.dsn#" name="qRoles">
			select		*
			from		farRole_barnacles
			where		data in (
							select	objectid
							from	farBarnacle
							where	permission=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
						)
		</cfquery>		
		
		<!--- Remove them from the roles --->
		<cfloop query="qRoles">
			<!--- Remove the barnacle from the role --->
			<cfset stRole = oRole.getData(objectid=parentid) />
			<cfset arraydeleteat(stRole.barnacles,seq) />
			<cfset stRole.setData(stProperties=stRole) />
			
			<!--- Delete the barnacle --->
			<cfset oBarnacle.delete(objectid=data) />
		</cfloop>
	</cffunction>
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var qRoles = "" />
		<cfset var stBarnacle = structnew() />
		<cfset var oBarnacle = createobject("component",application.stCOAPI.farBarnacle.packagepath) />
		<cfset var stRole = structnew() />
		<cfset var oRole = createobject("component",application.stCOAPI.farRole.packagepath) />
		
		<cfif len(arguments.stProperties.relatedtypes)>
			<cfset addRelatedBarnacles(arguments.stProperties.objectid) />
		<cfelse>
			<!--- If this isn't a item-specific permission, make sure none of the roles have associated barnacles --->
			<cfset removeRelatedBarnacles(arguments.stProperties.objectid) />
		</cfif>
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farRole and farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset removeRelatedBarnacles(arguments.stProperties.objectid) />
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>
	
</cfcomponent>