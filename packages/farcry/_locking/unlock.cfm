<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfset stLock = structNew()>
<cfset stLock.bSuccess=true>

<cfparam name="stArgs.stObj" default="">

<cfif isstruct(stArgs.stObj)>
	<cfset stProperties = Duplicate(stArgs.stObj)>
<cfelse>
	<!--- get object details --->
	<q4:contentobjectget objectID="#stArgs.objectid#" r_stobject="stObj">
	<cfset stProperties = Duplicate(stObj)>
</cfif>

<cfset stProperties.label = stproperties.title>
<!--- update locking fields (unlock) --->
<cfset stProperties.locked = 0>
<cfset stProperties.lockedBy = "">
<cfset stProperties.lastUpdatedBy = session.dmSec.authentication.userlogin>

<!--- hack to get dates correct --->
<cfloop collection="#stProperties#" item="field">
	<cfif StructKeyExists(Evaluate("application.types."&stProperties.typeName&".stProps"), field)>
		<cfset fieldType = Evaluate("application.types."&stProperties.typeName&".stProps."&field&".metaData.type")>
	<cfelse>
		<cfset fieldType = "string">
	</cfif>
	<cfif fieldType EQ "date" and field neq "lastupdatedby">
		<cfif Evaluate("stProperties.#field#") NEQ "">
			<cfset "stProperties.#field#" = createodbcdatetime(stProperties[field])>
		</cfif>
	</cfif>
</cfloop>

<cftry>
	<cfscript>
	if (application.types['#stArgs.typename#'].bCustomType)
		thisPackagePath = "#application.custompackagepath#.types.#stArgs.typename#";
	else
		thisPackagePath = "#application.packagepath#.types.#stArgs.typename#";
	</cfscript>
	<!--- save object details --->
	<q4:contentobjectdata
	 typename="#thisPackagePath#"
	 stProperties="#stProperties#"
	 objectid="#stArgs.ObjectID#">
	<cfcatch>
		<cfset stLock.bSuccess=false>
		<cfset stLock.message=cfcatch>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">