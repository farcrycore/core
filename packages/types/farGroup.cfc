<cfcomponent displayname="FarcryUD Group" hint="A group that FarcryUD users can be members of" extends="types" output="false">
	<cfproperty name="title" type="string" default="" hint="The title of this group" ftSeq="1" ftFieldset="" ftLabel="Title" ftType="string" />
	
	<cffunction name="getID" access="public" output="false" returntype="uuid" hint="Returns the objectid for the specified object (name can be the objectid or the title)">
		<cfargument name="name" type="string" required="true" hint="Pass in a role name and the objectid will be returned" />
		
		<cfset var qItem = "" />
		
		<cfif isvalid("uuid",arguments.name)>
			<cfreturn arguments.name />
		<cfelse>
			<cfquery datasource="#application.dsn#" name="qItem">
				select	*
				from	#application.dbOwner#farGroup
				where	lower(title)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.name)#" />
			</cfquery>
			
			<cfreturn qItem.objectid[1] />
		</cfif>
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Removes any corresponding entries in farUser" returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<cfset var stUser = structnew() />
		<cfset var qUser = "" />
		<cfset var oUser = createObject("component", application.stcoapi["farUser"].packagePath) />
		
		<cfquery datasource="#application.dsn#" name="qUser">
			select	*
			from	#application.dbowner#farUser_aGroups
			where	data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		
		<cfloop query="qUser">
			<cfset stUser = oUser.getData(parentid) />
			<cfset arraydeleteat(stUser.aGroups,seq) />
			<cfset oUser.setData(stProperties=stUser) />
		</cfloop>
		
		<cfreturn super.delete(objectid=arguments.objectid,user=arguments.user,audittype=arguments.audittype) />
	</cffunction>
	
</cfcomponent>