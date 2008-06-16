<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_locking/unlock.cfm,v 1.19 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: unlocks an object $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

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
<cfset stProperties.dateTimeLastUpdated = createodbcdatetime(now())>

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

<!--- try to remove any associated plp's --->
<cfif stLock.bSuccess>
	<cftry>
		<cffile action="delete" file="#application.path.plpstorage#/#listFirst(stObj.lockedBy,'_')#_#stObj.objectid#.plp">
		<cfcatch></cfcatch>
	</cftry>
</cfif>

<cfsetting enablecfoutputonly="no">