<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_locking/unlock.cfm,v 1.14 2004/06/17 04:48:41 geoff Exp $
$Author: geoff $
$Date: 2004/06/17 04:48:41 $
$Name: milestone_2-2-1 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: unlocks an object $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<cfset stLock.bSuccess=true>

<cfparam name="arguments.stObj" default="">

<cfif isStruct(arguments.stObj)>
	<cfset stProperties = Duplicate(arguments.stObj)>
<cfelse>
	<!--- get object details --->
	<q4:contentobjectget objectID="#arguments.objectid#" r_stobject="stObj">
	<cfset stProperties = Duplicate(stObj)>
</cfif>

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
	<!--- update the OBJECT	 --->
	<cfset oType.setData(stProperties=stProperties,bAudit=0)>
	
	<cfcatch>
		<cfset stLock.bSuccess=false>
		<cfset stLock.message=cfcatch>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">