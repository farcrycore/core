<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/sendObjectLive.cfm,v 1.8 2003/10/31 06:40:57 paul Exp $
$Author: paul $
$Date: 2003/10/31 06:40:57 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: sends versioned object live $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
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

<!--- check for custom type --->
<cfif application.types[typename].bCustomType>
	<cfset typename = "#application.custompackagepath#.types.#typename#">
<cfelse>
	<cfset typename = "#application.packagepath#.types.#typename#">
</cfif>

<cfset stDraftObject = arguments.stDraftObject>
		
<cfif structKeyExists(stDraftObject,"versionID")>
	<cfif NOT len(trim(stDraftObject.versionID)) EQ 0>
		<!--- get the current Live Object to archive --->
		<q4:contentobjectget ObjectId="#stDraftObject.versionID#" r_stObject="stLiveObject" typename="#typename#"> 
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
			//make the draft assume the objectID of the current live object. 
			stDraftObject.versionID = "";
			// need this to delete the draft
			thisDraftObjectID = stDraftObject.objectID;
			//need to set stDraft object to live for fourq update
			stDraftObject.objectID = stLiveObject.objectID;
			stResult.result = true;
			stRestult.message = 'Update Successful';
		</cfscript>

		<cflock name="sendlive_#stLiveObject.objectID#" timeout="50" type="exclusive">
			<!--- Make the archive - type is dmArchive --->
			<cfscript>
				oType = createobject("component","#application.packagepath#.types.#dmArchiveType#");
				stNewObj = oType.createData(stProperties=stProps);
				archiveObjID = stNewObj.objectid;
				
				// Update current live object with draft property values
				stDraftObject.objectid = stLiveObject.objectID;
				oContentType = createobject("component","#typename#");
				oContentType.setData(stProperties=stDraftObject,auditNote='Draft version sent live');
			</cfscript>	
				
			<!--- Now delete the draft object --->
			<q4:contentObjectDelete 
				ObjectId="#thisDraftObjectID#"
				typename="#typename#">
								
			</cflock>
	</cfif>	
</cfif>	