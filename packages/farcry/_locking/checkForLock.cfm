<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfset stLock = structNew()>

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectid#" r_stobject="stObj">

<!--- check for lock --->
<cfif stObj.locked>
	<!--- object locked --->
	<cfset stLock.bSuccess = false>
	<cfset stLock.lockedBy = stObj.lockedBy>
	<cfset stLock.message = "Object is currently locked by user: #stObj.lockedBy#">
<cfelse> 
	<!--- object not locked --->
	<cfset stLock.bSuccess = true>
	<cfset stLock.meesage = "Object is not locked and is available for edit">
</cfif>

<cfsetting enablecfoutputonly="no">