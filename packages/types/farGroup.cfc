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
				where	title=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" />
			</cfquery>
			
			<cfreturn qItem.objectid[1] />
		</cfif>
	</cffunction>
	
</cfcomponent>