<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->


<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >



<cfif thistag.executionMode eq "Start">

	
	
		<!--- Get the BaseTagData  --->
		<cfset PaginateData = getBaseTagData("cf_pagination")>
		<cfset structAppend(attributes, PaginateData.attributes,false) />
			
	
		<cfparam name="attributes.r_stObject" default="stObject">
		<cfparam name="attributes.editWebskin" default="edit">
		<cfparam name="attributes.CustomList" default="#attributes.typename#">
		<cfparam name="attributes.startRow" default="1">
		<cfparam name="attributes.lArrayProps" default="">
		<cfparam name="attributes.bIncludeFields" default="false">
		<cfparam name="attributes.bIncludeObjects" default="true">
		<cfparam name="attributes.BINCLUDEALLCOLUMNS" default="false">
		<cfparam name="attributes.bTypeAdmin" default="true">
		<cfparam name="attributes.stpermissions" default="#structNew()#">
		
		<cfif structKeyExists(application.types, attributes.typename)>
			<cfset PrimaryPackage = application.types[attributes.typename] />
			<cfset PrimaryPackagePath = application.types[attributes.typename].typepath />
		<cfelse>
			<cfset PrimaryPackage = application.rules[attributes.typename] />
			<cfset PrimaryPackagePath = application.rules[attributes.typename].rulepath />
		</cfif>
		
		<cfset variables.currentRow = attributes.startRow />
	
		<cfset o = createObject("component", PrimaryPackagePath) />
		<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
	
		<cfif attributes.bIncludeObjects>
			<cfset aObjects = oFormtoolUtil.getRecordSetObjectStructures(recordset=attributes.qRecordSet,typename=attributes.typename, lArrayProps=attributes.lArrayProps) />
		</cfif>	
	
	
	
		<cfif len(attributes.r_stobject) and variables.currentRow LTE attributes.totalRecords AND attributes.totalRecords>
	
			<cfset caller[attributes.r_stobject] = structNew() />
			<cfif attributes.bIncludeFields>
				<cfset caller[attributes.r_stobject].stFields = oFormtoolUtil.getRecordsetObject(recordset=attributes.qRecordSet, row=variables.currentRow, typename=attributes.typename) />
			</cfif>
			<cfif attributes.bIncludeObjects>
				<cfset caller[attributes.r_stobject].stObject = aObjects[variables.currentRow] />
			</cfif>		
			<cfif attributes.bIncludeAllColumns>
				<cfparam name="caller['#attributes.r_stobject#'].stFields" default="#structNew()#" type="struct" />
				<cfloop list="#attributes.qRecordSet.columnlist#" index="col">
					<cfif NOT structKeyExists(caller[attributes.r_stobject].stFields, col)>
						<cfset caller[attributes.r_stobject].stFields[col] = attributes.qRecordSet[col][variables.currentRow] />
					</cfif>
				</cfloop>
			</cfif>	
				
			<!---------------------------------------------------
			ONLY REQUIRE THE FOLLOWING IF CALED FROM TYPEADMIN
			 --------------------------------------------------->
			<cfif attributes.bTypeAdmin>	
				<cfset caller[attributes.r_stobject].select = "<input type='checkbox' name='objectid' value='#attributes.qRecordSet.objectid[variables.currentRow]#' onclick='setRowBackground(this);' class='formCheckbox' />" />
				<cfset caller[attributes.r_stobject].currentRow = (attributes.CurrentPage - 1) * attributes.RecordsPerPage + variables.currentRow - attributes.startRow + 1 />
				
				<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0>
					<cfset caller[attributes.r_stobject].currentRow = "#caller[attributes.r_stobject].currentRow# <img src='#application.url.farcry#/images/treeImages/customIcons/padlock.gif'>" />
				</cfif>
			
			
	
				<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"bHasMultipleVersion") AND attributes.qRecordSet.bHasMultipleVersion[variables.currentrow]>
					<cfset caller[attributes.r_stobject].status = "<span style='color:red;'>versioned</span>" />
				<cfelseif listFindNoCase(attributes.qRecordSet.columnlist,"status")>
					<cfset caller[attributes.r_stobject].status = attributes.qRecordSet.status[variables.currentrow] />
				</cfif>
				
				
		<!---		<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] AND attributes.qRecordSet.lockedby[variables.currentRow] eq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
					<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
				<cfelse>
					<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#attributes.qRecordSet.objectid[variables.currentrow]#&typename=#attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
				</cfif>
				
				<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
				
				<cfif structKeyExists(application.stPlugins, "flow")>
					<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.stPlugins.flow.url#/?startid=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
				</cfif> --->
				
				<cfsavecontent variable="ActionDropdown">
					<cfset request.inhead.prototype = 1 />
					<cfoutput>
					<select name="action#variables.currentrow#" id="action#variables.currentrow#" class="actionDropdown" onchange="$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.qRecordSet.objectid[variables.currentrow]#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=this.value;submit();">
						<option value="">-- action --</option>
		
						<option value="overview">Overview</option>
									
						<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0 AND attributes.qRecordSet.lockedby[variables.currentRow] neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
							<cfif structKeyExists(attributes.stPermissions, "iApprove") AND attributes.stPermissions.iApprove>
								<option value="unlock">Unlock</option>
							</cfif>		
						<cfelseif structKeyExists(attributes.stPermissions, "iEdit") AND attributes.stPermissions.iEdit>
							<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"bHasMultipleVersion")>
								<cfif NOT(attributes.qRecordSet.bHasMultipleVersion[variables.currentrow]) AND attributes.qRecordSet.status[variables.currentRow] EQ "approved">
									<option value="createDraft">Create Draft Object</option>
								<cfelseif NOT(attributes.qRecordSet.bHasMultipleVersion[variables.currentrow])>
									<option value="edit">Edit</option>
								</cfif>
							<cfelse>
								<option value="edit">Edit</option>
							</cfif>
						</cfif>
						
						<option value="view">View</option>
						
						<cfif structKeyExists(application.stPlugins, "flow")>
							<option value="flow">Flow</option>
						</cfif>
						
						
						<cfif structKeyExists(attributes.stPermissions, "iRequestApproval") 
								AND attributes.stPermissions.iRequestApproval
							AND listFindNoCase(attributes.qRecordSet.columnlist,"status") 
							AND attributes.qRecordSet.status[variables.currentRow] EQ "draft">
							<option value="requestApproval">Request Approval</option>
						</cfif>
						
						<cfif structKeyExists(attributes.stPermissions, "iApprove") 
							AND attributes.stPermissions.iApprove
							AND listFindNoCase(attributes.qRecordSet.columnlist,"status")
							AND (
								attributes.qRecordSet.status[variables.currentRow] EQ "draft" 
								OR attributes.qRecordSet.status[variables.currentRow] EQ "pending"
							)>
							<option value="approve">Approve</option>
						</cfif>
						
						
						<!--- <option value="delete">Delete</option> --->
					</select>
					</cfoutput>
				</cfsavecontent>
				
				<cfset caller[attributes.r_stObject].action = ActionDropdown />
			</cfif>
			
			
			
					
			<cfset variables.currentRow = variables.CurrentRow + 1 />
		<cfelse>
			<cfexit method="exittag" />
		</cfif>
	
	
</cfif>


<cfif thistag.executionMode eq "End">

	
		<cfif len(attributes.r_stobject) and variables.currentRow LTE attributes.endRow>
			
			<cfset caller[attributes.r_stobject] = structNew() />
			<cfif attributes.bIncludeFields>
				<cfset caller[attributes.r_stobject].stFields = oFormtoolUtil.getRecordsetObject(recordset=attributes.qRecordSet, row=variables.currentRow, typename=attributes.typename) />
			</cfif>
			<cfif attributes.bIncludeObjects>
				<cfset caller[attributes.r_stobject].stObject = aObjects[variables.currentRow] />
			</cfif>			
	
			<cfif attributes.bIncludeAllColumns>
				<cfparam name="caller['#attributes.r_stobject#'].stFields" default="#structNew()#" type="struct" />
				<cfloop list="#attributes.qRecordSet.columnlist#" index="col">
					<cfif NOT structKeyExists(caller[attributes.r_stobject].stFields, col)>
						<cfset caller[attributes.r_stobject].stFields[col] = attributes.qRecordSet[col][variables.currentRow] />
					</cfif>
				</cfloop>
			</cfif>	
			
			<!---------------------------------------------------
			ONLY REQUIRE THE FOLLOWING IF CALLED FROM TYPEADMIN
			 --------------------------------------------------->
			<cfif attributes.bTypeAdmin>	
				<cfset caller[attributes.r_stobject].select = "<input type='checkbox' name='objectid' value='#attributes.qRecordSet.objectid[variables.currentRow]#' onclick='setRowBackground(this);' class='formCheckbox' />" />
				<cfset caller[attributes.r_stobject].currentRow = (attributes.CurrentPage - 1) * attributes.RecordsPerPage + variables.currentRow - attributes.startRow + 1 />
				
				<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0>
					<cfset caller[attributes.r_stobject].currentRow = "#caller[attributes.r_stobject].currentRow# <img src='#application.url.farcry#/images/treeImages/customIcons/padlock.gif'>" />
				</cfif>
			
			
	
				<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"bHasMultipleVersion") AND attributes.qRecordSet.bHasMultipleVersion[variables.currentrow]>
					<cfset caller[attributes.r_stobject].status = "<span style='color:red;'>versioned</span>" />
				<cfelseif listFindNoCase(attributes.qRecordSet.columnlist,"status")>
					<cfset caller[attributes.r_stobject].status = attributes.qRecordSet.status[variables.currentrow] />
				</cfif>
				
				
		<!---		<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] AND attributes.qRecordSet.lockedby[variables.currentRow] eq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
					<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
				<cfelse>
					<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#attributes.qRecordSet.objectid[variables.currentrow]#&typename=#attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
				</cfif>
				
				<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
				
				<cfif structKeyExists(application.stPlugins, "flow")>
					<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.stPlugins.flow.url#/?startid=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
				</cfif> --->
				
				<cfsavecontent variable="ActionDropdown">
					<cfset request.inhead.prototype = 1 />
					<cfoutput>
					<select name="action#variables.currentrow#" id="action#variables.currentrow#" class="actionDropdown" onchange="$('SelectedObjectID#Request.farcryForm.Name#').value='#attributes.qRecordSet.objectid[variables.currentrow]#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=this.value;submit();">
						<option value="">-- action --</option>
		
						<option value="overview">Overview</option>
									
						<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0 AND attributes.qRecordSet.lockedby[variables.currentRow] neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
							<cfif structKeyExists(attributes.stPermissions, "iApprove") AND attributes.stPermissions.iApprove>
								<option value="unlock">Unlock</option>
							</cfif>		
						<cfelseif structKeyExists(attributes.stPermissions, "iEdit") AND attributes.stPermissions.iEdit>
							<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"bHasMultipleVersion")>
								<cfif NOT(attributes.qRecordSet.bHasMultipleVersion[variables.currentrow]) AND attributes.qRecordSet.status[variables.currentRow] EQ "approved">
									<option value="createDraft">Create Draft Object</option>
								<cfelseif NOT(attributes.qRecordSet.bHasMultipleVersion[variables.currentrow])>
									<option value="edit">Edit</option>
								</cfif>
							<cfelse>
								<option value="edit">Edit</option>
							</cfif>
						</cfif>
						
						<option value="view">View</option>
						
						<cfif structKeyExists(application.stPlugins, "flow")>
							<option value="flow">Flow</option>
						</cfif>
						
						
						<cfif structKeyExists(attributes.stPermissions, "iRequestApproval") 
								AND attributes.stPermissions.iRequestApproval
							AND listFindNoCase(attributes.qRecordSet.columnlist,"status") 
							AND attributes.qRecordSet.status[variables.currentRow] EQ "draft">
							<option value="requestApproval">Request Approval</option>
						</cfif>
						
						<cfif structKeyExists(attributes.stPermissions, "iApprove") 
							AND attributes.stPermissions.iApprove
							AND listFindNoCase(attributes.qRecordSet.columnlist,"status")
							AND (
								attributes.qRecordSet.status[variables.currentRow] EQ "draft" 
								OR attributes.qRecordSet.status[variables.currentRow] EQ "pending"
							)>
							<option value="approve">Approve</option>
						</cfif>
						
						
						<!--- <option value="delete">Delete</option> --->
					</select>
					</cfoutput>
				</cfsavecontent>
				
				<cfset caller[attributes.r_stObject].action = ActionDropdown />
			</cfif>
			
			
			<cfset variables.currentRow = variables.CurrentRow + 1 />
			
			<cfexit method="loop" />
		</cfif>

	
</cfif>



<cfsetting enablecfoutputonly="no">



