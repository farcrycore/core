<cfsetting enablecfoutputonly="yes">

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
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />


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
		<cfparam name="attributes.bTypeAdmin" default="false">
		<!--- <cfparam name="attributes.stpermissions" default="#structNew()#"> --->
		<cfparam name="attributes.lCustomActions" default="">
		<cfparam name="attributes.typename" default="">
				
		<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
		
		<cfset variables.currentRow = attributes.startRow />
		<cfset variables.lWorkflowTypenames = "" />
		<cfset variables.bIncludeTypeSpecific = false /><!--- If we are only paginating over objects of a single type, we can provide additional information --->
		
		<cfif len(attributes.typename)>
			<cfif structKeyExists(application.stcoapi, attributes.typename)>
			
				<cfset variables.bIncludeTypeSpecific = true />
				
				<cfset variables.PrimaryPackage = application.stcoapi[attributes.typename] />
				<cfset variables.PrimaryPackagePath = application.stcoapi[attributes.typename].typepath />

				<cfset variables.lWorkflowTypenames = createObject("component", application.stcoapi.farWorkflow.packagepath).getWorkflowList(typename="#attributes.typename#") />
	
				<cfif attributes.bIncludeObjects>
					<cfset variables.aObjects = oFormtoolUtil.getRecordSetObjectStructures(recordset=attributes.qRecordSet,typename=attributes.typename, lArrayProps=attributes.lArrayProps) />
				</cfif>	
			
			</cfif>	
		</cfif>
		
	

		
		
		<!--- <cfset o = createObject("component", PrimaryPackagePath) /> --->

	
		<cfif len(attributes.r_stobject) and variables.currentRow LTE attributes.totalRecords AND attributes.totalRecords>
		
			<cfset caller[attributes.r_stobject] = structNew() />
			

			<cfif listFindNoCase(attributes.qRecordSet.columnList, "objectid")>
				<cfset caller[attributes.r_stobject].objectid = attributes.qRecordSet.objectid[variables.currentRow] />
				
				<cfif variables.bIncludeTypeSpecific>
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
						
						
				<!---		<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] AND attributes.qRecordSet.lockedby[variables.currentRow] eq 'application.security.getCurrentUserID()'>
							<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
						<cfelse>
							<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#attributes.qRecordSet.objectid[variables.currentrow]#&typename=#attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
						</cfif>
						
						<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
						
						<cfif structKeyExists(application.stPlugins, "flow")>
							<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.stPlugins.flow.url#/?startid=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
						</cfif> --->
						
						<cfif structkeyexists(attributes,"stPermissions")>
							<cfset thistag.stPermissions = duplicate(attributes.stPermissions) />
						<cfelse>
							<cfset thistag.stPermissions = structnew() />
							<sec:CheckPermission permission="Create" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iCreate" />
							<sec:CheckPermission permission="Delete" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iDelete" />
							<sec:CheckPermission permission="RequestApproval" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iRequestApproval" />
							<sec:CheckPermission permission="Approve" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iApprove" />
							<sec:CheckPermission permission="Edit" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iEdit" />
							<sec:CheckPermission permission="ObjectDumpTab" result="thistag.stPermissions.iDumpTab" />
							<sec:CheckPermission permission="Developer" result="thistag.stPermissions.iDeveloper" />
						</cfif>
						
						<cfsavecontent variable="ActionDropdown">
							<cfset request.inhead.prototype = 1 />
							<cfoutput>
							<select name="action#variables.currentrow#" id="action#variables.currentrow#" class="actionDropdown" onchange="selectObjectID('#attributes.qRecordSet.objectid[variables.currentrow]#');$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=this.value;submit();">
								<option value="">-- action --</option>
				
								<option value="overview">Overview</option>
								
								
								<!--- We do not include the Edit Link if workflow is available for this content item. The user must go to the overview page. --->
								<cfif not listLen(variables.lWorkflowTypenames)>	
									<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0 AND attributes.qRecordSet.lockedby[variables.currentRow] neq '#application.security.getCurrentUserID()#'>
										<cfif structKeyExists(thistag.stPermissions, "iApprove") AND thistag.stPermissions.iApprove>
											<option value="unlock">Unlock</option>
										</cfif>		
									<cfelseif structKeyExists(thistag.stPermissions, "iEdit") AND thistag.stPermissions.iEdit>
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
								</cfif>
								<option value="view">View</option>
								
								<cfif structKeyExists(application.stPlugins, "flow")>
									<option value="flow">Flow</option>
								</cfif>
								
								
								<cfif structKeyExists(thistag.stPermissions, "iRequestApproval") 
										AND thistag.stPermissions.iRequestApproval
									AND listFindNoCase(attributes.qRecordSet.columnlist,"status") 
									AND attributes.qRecordSet.status[variables.currentRow] EQ "draft">
									<option value="requestApproval">Request Approval</option>
								</cfif>
								
								<cfif structKeyExists(thistag.stPermissions, "iApprove") 
									AND thistag.stPermissions.iApprove
									AND listFindNoCase(attributes.qRecordSet.columnlist,"status")
									AND (
										attributes.qRecordSet.status[variables.currentRow] EQ "draft" 
										OR attributes.qRecordSet.status[variables.currentRow] EQ "pending"
									)>
									<option value="approve">Approve</option>
								</cfif>
								
								<cfif listLen(attributes.lCustomActions)>
									<cfloop list="#attributes.lCustomActions#" index="i">
										<option value="#listFirst(i, ":")#">#listLast(i, ":")#</option>
									</cfloop>
								</cfif>
								<!--- <option value="delete">Delete</option> --->
							</select>
							</cfoutput>
						</cfsavecontent>
						
						<cfset caller[attributes.r_stObject].action = ActionDropdown />
					</cfif>
				
				</cfif>		
			</cfif>
			
			<cfloop list="#attributes.qRecordset.columnList#" index="i">
				<cfif not structKeyExists(caller[attributes.r_stObject], i)>
					<cfset caller[attributes.r_stObject][i] = attributes.qRecordset[i][variables.currentRow] />
				</cfif>
			</cfloop>
					
			<cfset variables.currentRow = variables.CurrentRow + 1 />
		<cfelse>
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="exittag" />
		</cfif>
	
	
</cfif>


<cfif thistag.executionMode eq "End">

	
		<cfif len(attributes.r_stobject) and variables.currentRow LTE attributes.endRow>
			
			<cfset caller[attributes.r_stobject] = structNew() />
			
			<cfif listFindNoCase(attributes.qRecordSet.columnList, "objectid")>
			
				<cfset caller[attributes.r_stobject].objectid = attributes.qRecordSet.objectid[variables.currentRow] />
				
				<cfif variables.bIncludeTypeSpecific>
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
						
						
				<!---		<cfif listContainsNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] AND attributes.qRecordSet.lockedby[variables.currentRow] eq 'application.security.getCurrentUserID()'>
							<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
						<cfelse>
							<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#attributes.qRecordSet.objectid[variables.currentrow]#&typename=#attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
						</cfif>
						
						<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
						
						<cfif structKeyExists(application.stPlugins, "flow")>
							<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.stPlugins.flow.url#/?startid=#attributes.qRecordSet.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
						</cfif> --->
						
						<cfif structkeyexists(attributes,"stPermissions")>
							<cfset thistag.stPermissions = duplicate(attributes.stPermissions) />
						<cfelse>
							<cfset thistag.stPermissions = structnew() />
							<sec:CheckPermission permission="Create" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iCreate" />
							<sec:CheckPermission permission="Delete" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iDelete" />
							<sec:CheckPermission permission="RequestApproval" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iRequestApproval" />
							<sec:CheckPermission permission="Approve" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iApprove" />
							<sec:CheckPermission permission="Edit" type="#attributes.typename#" objectid="#attributes.qRecordSet.objectid[variables.currentrow]#" result="thistag.stPermissions.iEdit" />
							<sec:CheckPermission permission="ObjectDumpTab" result="thistag.stPermissions.iDumpTab" />
							<sec:CheckPermission permission="Developer" result="thistag.stPermissions.iDeveloper" />
						</cfif>
						
						<cfsavecontent variable="ActionDropdown">
							<cfset request.inhead.prototype = 1 />
							<cfoutput>
							<select name="action#variables.currentrow#" id="action#variables.currentrow#" class="actionDropdown" onchange="selectObjectID('#attributes.qRecordSet.objectid[variables.currentrow]#');$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=this.value;submit();">
								<option value="">-- action --</option>
				
								<option value="overview">Overview</option>
											
								<!--- We do not include the Edit Link if workflow is available for this content item. The user must go to the overview page. --->
								<cfif not listLen(variables.lWorkflowTypenames)>										
									<cfif listFindNoCase(attributes.qRecordSet.columnlist,"locked") AND attributes.qRecordSet.locked[variables.currentRow] neq 0 AND attributes.qRecordSet.lockedby[variables.currentRow] neq '#application.security.getCurrentUserID()#'>
										<cfif structKeyExists(thistag.stPermissions, "iApprove") AND thistag.stPermissions.iApprove>
											<option value="unlock">Unlock</option>
										</cfif>		
									<cfelseif structKeyExists(thistag.stPermissions, "iEdit") AND thistag.stPermissions.iEdit>
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
								</cfif>
								
								<option value="view">View</option>
								
								<cfif structKeyExists(application.stPlugins, "flow")>
									<option value="flow">Flow</option>
								</cfif>
								
								
								<cfif structKeyExists(thistag.stPermissions, "iRequestApproval") 
										AND thistag.stPermissions.iRequestApproval
									AND listFindNoCase(attributes.qRecordSet.columnlist,"status") 
									AND attributes.qRecordSet.status[variables.currentRow] EQ "draft">
									<option value="requestApproval">Request Approval</option>
								</cfif>
								
								<cfif structKeyExists(thistag.stPermissions, "iApprove") 
									AND thistag.stPermissions.iApprove
									AND listFindNoCase(attributes.qRecordSet.columnlist,"status")
									AND (
										attributes.qRecordSet.status[variables.currentRow] EQ "draft" 
										OR attributes.qRecordSet.status[variables.currentRow] EQ "pending"
									)>
									<option value="approve">Approve</option>
								</cfif>
								
								<cfif listLen(attributes.lCustomActions)>
									<cfloop list="#attributes.lCustomActions#" index="i">
										<option value="#listFirst(i, ":")#">#listLast(i, ":")#</option>
									</cfloop>
								</cfif>
								
								
								<!--- <option value="delete">Delete</option> --->
							</select>
							</cfoutput>
						</cfsavecontent>
						
						<cfset caller[attributes.r_stObject].action = ActionDropdown />
					</cfif>
				
				</cfif>
			</cfif>
			
			<cfloop list="#attributes.qRecordset.columnList#" index="i">
				<cfif not structKeyExists(caller[attributes.r_stObject], i)>
					<cfset caller[attributes.r_stObject][i] = attributes.qRecordset[i][variables.currentRow] />
				</cfif>
			</cfloop>
			
			<cfset variables.currentRow = variables.CurrentRow + 1 />
			
			<cfsetting enablecfoutputonly="false" />
			<cfexit method="loop" />
		</cfif>

	
</cfif>



<cfsetting enablecfoutputonly="no">



