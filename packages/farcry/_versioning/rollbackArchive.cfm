<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/rollbackArchive.cfm,v 1.9 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.9 $

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

<cfset typename = application.types[typename].typePath>

<!--- get the current Live Object to archive --->
<q4:contentobjectget ObjectId="#arguments.objectID#" r_stObject="stLiveObject" typename="#typename#"> 
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

<cflock name="archive_#arguments.archiveID#" timeout="50" type="exclusive">
	<!--- Make the archive - type is dmArchive --->
	<cfscript>
		oType = createobject("component","#application.packagepath#.types.#dmArchiveType#");
		stNewObj = oType.createData(stProperties=stProps);
		archiveObjID = stNewObj.objectid;
	</cfscript>	
		
	<!--- retrieve archive version --->
	<q4:contentobjectget ObjectId="#arguments.archiveID#" r_stObject="stArchive" typename="#application.types.dmArchive.typePath#"> 
	
	<!--- Convert wddx archive object --->
	<cfwddx input="#stArchive.objectwddx#" output="stArchiveDetail"  action="wddx2cfml">
	<cfset stArchiveDetail.objectid = stLiveObject.objectID>
	
	<!--- Update current live object with archive property values	 --->
	<cfscript>
		oContentType = createobject("component","#typename#");
		oContentType.setData(stProperties=stArchiveDetail,auditNote='Archive rolled back');
	</cfscript>
		
	<!--- update tree --->
	<nj:getNavigation objectId="#stLiveObject.objectID#" bInclusive="1" r_stObject="stNav" r_ObjectId="objectId">	
	<nj:updateTree ObjectId="#stNav.objectId#">
						
</cflock>	