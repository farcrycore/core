<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/rollbackArchive.cfm,v 1.2 2003/04/09 08:04:59 spike Exp $
$Author: spike $
$Date: 2003/04/09 08:04:59 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
Rolls back current object to selected archive version and creates an archive of current version.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
ObjectId - current objectid
ArchiveId - id of archive version which will be sent back to live

|| HISTORY ||
$Log: rollbackArchive.cfm,v $
Revision 1.2  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.1  2003/01/09 01:01:08  brendan
*** empty log message ***

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
<cfset typename = "#application.packagepath#.types.#typename#">

<!--- get the current Live Object to archive --->
<q4:contentobjectget ObjectId="#stArgs.objectID#" r_stObject="stLiveObject" typename="#typename#"> 
<!--- Convert current live object to WDDX --->
<cfwddx input="#stLiveObject#" output="stLiveWDDX"  action="cfml2wddx">

<cfscript>
	//set up the dmArchive structure to save
	dmArchiveType = 'dmArchive';
	//typeID = Evaluate("application.#dmArchiveType#TypeID");
	stProps = structNew();
	stProps.objectID = createUUID();
	stProps.archiveID = stLiveObject.objectID;
	stProps.objectWDDX = stLiveWDDX;
	stProps.lastupdatedby = session.dmSec.authentication.userlogin;
	stProps.datetimelastupdated = Now();
	stProps.createdby = session.dmSec.authentication.userlogin;
	stProps.datetimecreated = Now();
	stProps.label = stLiveObject.title;
	stResult.result = true;
	stRestult.message = 'Update Successful';
</cfscript>

<cflock name="createUUID();" timeout="50" type="exclusive">
	<!--- Make the archive - type is dmArchive --->
	<q4:contentobjectcreate typename="#application.packagepath#.types.#dmArchiveType#" stproperties="#stProps#" r_objectid="archiveObjID">
	
	<!--- retrieve archive version --->
	<q4:contentobjectget ObjectId="#stArgs.archiveID#" r_stObject="stArchive" typename="#application.packagepath#.types.dmArchive"> 
	
	<!--- Convert wddx archive object --->
	<cfwddx input="#stArchive.objectwddx#" output="stArchiveDetail"  action="wddx2cfml">
	
	<!--- Update current live object with archive property values	 --->
	<q4:contentobjectdata objectid="#stLiveObject.objectID#" 
		typename="#typename#"
		stProperties="#stArchiveDetail#">
	
	<!--- update tree --->
	<nj:getNavigation objectId="#stLiveObject.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">	
	<nj:updateTree ObjectId="#stNav.objectId#">
						
</cflock>	