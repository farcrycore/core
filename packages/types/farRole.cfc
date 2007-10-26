<cfcomponent displayname="Role" hint="Used to group permission settings and associating them with user groups" extends="types" output="false">
	<cfproperty name="title" type="string" default="" hint="The name of the role" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	<cfproperty name="permissions" type="array" hint="The simple permissions that are granted as part of this role" ftSeq="2" ftFieldset="" ftLabel="Permissions" ftJoin="farPermission" />
	<cfproperty name="barnacles" type="array" hint="Item specific permissions that are granted as part of this role" ftSeq="3" ftFieldset="" ftLabel="Barnacles" ftJoin="farBarnacle" />
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var qPermissions = "" />
		<cfset var oPermission = createobject("component",application.stCOAPI.farPermission.packagepath) />
		
		<!--- Find all permissions that require barnacles --->
		<cfquery datasource="#application.dsn#" name="qPermissions">
			select		objectid
			from		farPermission
			where		relatedtypes <> ''
		</cfquery>		
		
		<!--- Update the barnacles for that permission --->
		<cfloop query="qPermissions">
			<cfset oPermission.addRelatedBarnacles(objectid=objectid) />
		</cfloop>
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farBarnacle" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var qBarnacles = "" />
		<cfset var oBarnacle = createobject("component",application.stCOAPI.farBarnacle.packagepath) />
		
		<!--- Find related barnacles --->
		<cfquery datasource="#application.dsn#" name="qBarnacles">
			select		data
			from		farRole_barnacles
			where		objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>		
		
		<!--- Delete them --->
		<cfloop query="qBarnacles">
			<cfset oBarnacle.delete(objectid=qBarnacles.data[currentrow]) />
		</cfloop>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>

</cfcomponent>