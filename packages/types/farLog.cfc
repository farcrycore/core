<cfcomponent displayname="FarCry Log" hint="Manages FarCry event logs" extends="types" output="false">
	<cfproperty name="object" type="uuid" default="" hint="The associated object" ftSeq="1" ftFieldset="" ftLabel="Object" ftType="string" />
	<cfproperty name="type" type="string" default="" hint="The type of the object or event group (e.g. security, coapi)" ftSeq="2" ftFieldset="" ftLabel="Object type" ftType="string" />
	<cfproperty name="event" type="string" default="" hint="The event this log is associated with" ftSeq="3" ftFieldset="" ftLabel="Event" ftType="string" />
	<cfproperty name="location" type="string" default="" hint="The location of the event if relevant" ftSeq="4" ftFieldset="" ftLabel="Location" ftType="string" />
	<cfproperty name="userid" type="string" default="" hint="The id of the user" ftSeq="5" ftFieldset="" ftLabel="User" ftType="string" />
	<cfproperty name="ipaddress" type="string" default="" hint="IP address of user" ftSeq="6" ftFieldset="" ftLabel="IP address" ftType="string" />
	<cfproperty name="notes" type="longchar" default="" hint="Extra notes" ftSeq="7" ftFieldset="" ftLabel="Notes" ftType="longchar" />

	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="bAudit" type="boolean" required="false" hint="Set to false to disable logging" />
		
		<cfif not structkeyexists(arguments.stProperties,"user") or not len(arguments.stProperties.user)>
			<cfset arguments.stProperties.user = "anonymous" />
		</cfif>
		
		<cfif structkeyexists(arguments.stProperties,"object") and len(arguments.stProperties.object) and (not structkeyexists(arguments.stProperties,"type") or not len(arguments.stProperties.type))>
			<cfset arguments.stProperties.typename = findType(arguments.stProperties.object) />
		</cfif>
		
		<cfreturn super.createData(stProperties=arguments.stProperties,user=arguments.user,auditNote=arguments.auditNote,dsn=arguments.dsn,bAudit=false) />
	</cffunction>
	
</cfcomponent>