<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/rollbackArchive.cfm,v 1.10 2004/04/22 07:42:50 brendan Exp $
$Author: brendan $
$Date: 2004/04/22 07:42:50 $
$Name: milestone_2-2-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
Rolls back current object to selected archive version and creates an archive of current version.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
ObjectId - current objectid
ArchiveId - id of archive version which will be sent back to live

|| END FUSEDOC ||
--->

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<!--- TODO - no where near enough error checking in this CFC --->
<cfscript>
	stResult = structNew();
	stResult.result = false;
	stRestult.message = 'No update has taken place';
</cfscript>

<cfif NOT isDefined("typename")>
	<cfinvoke component="farcry.fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#ObjectId#">
	<cfset typename = thisTypename>	
</cfif>

<cflock name="archive_#arguments.archiveID#" timeout="50" type="exclusive">
	<!--- Make the archive - type is dmArchive --->
	<cfset oType = createObject("component",application.types[typename].typePath)>
	<cfset stResult = oType.archiveObject(objectid=arguments.objectid,typename=typename)>
		
	<!--- retrieve archive version --->
	<q4:contentobjectget ObjectId="#arguments.archiveID#" r_stObject="stArchive" typename="#application.types.dmArchive.typePath#"> 
	
	<!--- Convert wddx archive object --->
	<cfwddx input="#stArchive.objectwddx#" output="stArchiveDetail"  action="wddx2cfml">
	<cfset stArchiveDetail.objectid = arguments.objectID>
	<cfset stArchiveDetail.locked = 0>
	<cfset stArchiveDetail.lockedBy = "">
	
	<!--- Update current live object with archive property values	 --->
	<cfset oType.setData(stProperties=stArchiveDetail,auditNote='Archive rolled back')>
		
	<!--- update tree --->
	<nj:getNavigation objectId="#arguments.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">	
	<nj:updateTree ObjectId="#stNav.objectId#">
						
</cflock>	