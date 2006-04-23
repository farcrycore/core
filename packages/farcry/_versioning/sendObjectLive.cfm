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
		
		<cfset stDraftObject = stArgs.stDraftObject>
				
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

				<cflock name="createUUID();" timeout="50" type="exclusive">
					<!--- Make the archive - type is dmArchive --->
					<q4:contentobjectcreate typename="#application.packagepath#.types.#dmArchiveType#" stproperties="#stProps#" r_objectid="archiveObjID">     
					
					<!--- Update current live object with draft property values	 --->
					<q4:contentobjectdata objectid="#stLiveObject.objectID#" 
						typename="#typename#"
						stProperties="#stDraftObject#">
						
					<!--- Now delete the draft object --->
					<q4:contentObjectDelete 
						ObjectId="#thisDraftObjectID#"
						typename="#typename#">
										
					</cflock>
			</cfif>	
		</cfif>	