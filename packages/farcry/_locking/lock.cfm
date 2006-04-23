<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">
<cfset stLock = structNew()>
<cfset stLock.bSuccess=true>

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectid#" r_stobject="stObj">

<!--- update locking fields --->
<cfset stProperties = structNew()>
<cfset stProperties.locked = 1>
<cfset stProperties.lockedBy = "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">

<cftry>
	<!--- save object details --->
	<cfscript>
	if (application.types['#stArgs.typename#'].bCustomType)
		thisPackagePath = "#application.custompackagepath#.types.#stArgs.typename#";
	else
		thisPackagePath = "#application.packagepath#.types.#stArgs.typename#";
	</cfscript>	
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