<cfimport taglib="/fourq/tags/" prefix="q4">
		
		<cfif NOT isDefined("stArgs.typename")>
			<cfinvoke component="fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#ObjectId#">
			<cfset typename = thisTypename>	
		</cfif>
		<cfset typename = "#application.packagepath#.types.#typename#">
		<q4:contentobjectget ObjectId="#objectId#" r_stObjects="stObject" typename="#typename#"> 
		
		<!--- Determine if draft/pending objects have a live parent --->
		<cfscript>
			/*init struct - probably including too much stuff here - but extras may be useful at some point*/
			stRules = structNew();
			stRules.versioning = true;// Is versioning performed on this object?
			stRules.bEdit = false; // Can the user edit this object?
			stRules.bComment = false; //can the user make comments on object
			stRules.bApprove = false; //can user approve object - ie send live
			stRules.bDecline = false; // can user send object back to draft
			stRules.bCreateDraft = false; // create a draft version of object to edit?
			stRules.bDraftVersionExists = false;
			stRules.bLiveVersionExists = false;
			stRules.draftObjectID = "";//this objectID (if exists) of the draft object
			stRules.status = stObject.status; //draft,pending,approved?
			
			
			// if property doesn't exist - the versioning is not an issue
			if (NOT structKeyExists(stObject,"versionID"))
				stRules.versioning = false; 	
			else
			{	
				if (len(trim(stObject.versionID)) NEQ 0)  // flags whether a live version of this object exists
					stRules.bLiveVersionExists = true;
				else
					stRules.bLiveVersionExists = false;	
				switch (stRules.status){
					case "approved":
						stRules.bComment = true;
						stRules.bDecline = true;  //need to make sure relevant permissions to do this on calling page
						stRules.bCreateDraft = true;
						break;
					case "pending" :
						if (stRules.bLiveVersionExists) {
							stRules.bComment = true;
							stRules.bPreview = true;
							stRules.bApprove = true;
							stRules.bDecline = true;
							break;
						}	
						else
						{
							stRules.bComment = true;
							stRules.bApprove = true;	
							stRules.bDecline = true;
							break;
						}
					case "draft" :
						if (stRules.bLiveVersionExists){
							stRules.bEdit = true;
							stRules.bApprove = true;
							stRules.bComment = true;
							break;
						}
						else
						{
							stRules.bEdit = true;
							stRules.bComment = true;
							stRules.bApprove = true;
							break;
						}
					}
				}		
		</cfscript>
		<!--- Now check to see if a draft version exists --->
		<cfif stRules.status IS "Approved" and structKeyExists(stObject,"versionID")>
			<cfquery datasource="#application.dsn#" name="qHasDraft">
				SELECT objectID from #stObject.typename# where versionID = '#objectID#' 
			</cfquery>
			<cfif qHasDraft.recordcount GT 1>
				<cfthrow extendedinfo="Multiple draft children returned" message="Multiple draft error">
			<cfelseif qHasDraft.recordcount eq 1>
				<cfset stRules.bDraftVersionExists = true>
				<cfset stRules.bDecline = false>
				<cfset stRules.draftObjectID = qHasDraft.objectID>				
			</cfif> 
		</cfif>