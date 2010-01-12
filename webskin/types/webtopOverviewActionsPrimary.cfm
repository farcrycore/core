<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />



<ft:processForm action="Delete" bHideForms="true">
	<skin:onReady>
	<cfoutput>
		$j($fc.objectAdminActionDiv).dialog('close');
	</cfoutput>
	</skin:onReady>
</ft:processForm>

	
				
<!------------------ 
START WEBSKIN
 ------------------>
<cfset stOverviewParams = structNew() />


<nj:getNavigation objectId="#stobj.objectid#" r_ObjectId="parentID" r_stObject="stParent" bInclusive="1">
<cfset stOverviewParams.parentID = parentID>
<cfset stOverviewParams.stParent = stParent>

<!--- generate all data required for the overview html --->
<!--- check/generate permission --->
<cfset stOverviewParams.stPermissions = StructNew()>


<cfif StructKeyExists(application.stcoapi[stobj.typename], "bUseInTree") AND application.stcoapi[stobj.typename].bUseInTree AND len(stOverviewParams.parentID)>
	<sec:CheckPermission permission="developer" result="stOverviewParams.stPermissions.iDeveloperPermission" />
	<sec:CheckPermission permission="Edit" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iEdit" />
	<sec:CheckPermission permission="RequestApproval" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iRequest" />
	<sec:CheckPermission permission="Approve" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iApprove" />
	<sec:CheckPermission permission="CanApproveOwnContent" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iApproveOwn" />
	<sec:CheckPermission permission="ObjectDumpTab" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iObjectDumpTab" />
	<sec:CheckPermission permission="Delete" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iDelete" />
	<sec:CheckPermission permission="Create" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iCreate" />
	<sec:CheckPermission permission="SendToTrash" type="#stOverviewParams.stParent.typename#" objectid="#stOverviewParams.parentid#" result="stOverviewParams.stPermissions.iTreeSendToTrash" />
<cfelse>
	<sec:CheckPermission permission="developer" result="stOverviewParams.stPermissions.iDeveloperPermission" />
	<sec:CheckPermission permission="Edit" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iEdit" />
	<sec:CheckPermission permission="RequestApproval" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iRequest" />
	<sec:CheckPermission permission="Approve" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iApprove" />
	<sec:CheckPermission permission="CanApproveOwnContent" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iApproveOwn" />
	<sec:CheckPermission permission="ObjectDumpTab" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iObjectDumpTab" />
	<sec:CheckPermission permission="Delete" type="#stObj.typename#" objectid="#stObj.objectid#" result="stOverviewParams.stPermissions.iDelete" />
	<cfset stOverviewParams.stPermissions.iTreeSendToTrash = 0>
</cfif>

<!--- grab draft object overview --->
<cfset stDraftObject = StructNew()>
<cfset bHasDraft = false />

	
<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
	<cfset oVersioning = createObject("component", "#application.packagepath#.farcry.versioning")>
	<cfset qDraft = oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
	<cfif qDraft.recordcount>
		<cfset stDraftObject = getData(qDraft.objectid)>
		<cfset bHasDraft = true />
		<!--- object tid of the current live version used by the delete function --->
		<cfif stOverviewParams.stPermissions.iApproveOwn EQ 1 AND NOT stDraftObject.lastUpdatedBy EQ application.security.getCurrentUserID()>
			<cfset stOverviewParams.stPermissions.iApproveOwn = 0>
		</cfif>
	</cfif>
</cfif>


<cfparam name="stobj.bAlwaysShowEdit" default="0">
<cfparam name="url.ref" default="overview" />


		

	<cfif isBoolean(stobj.locked) AND stobj.locked>
		<cfset stLockedBy = application.fapi.getContentType("dmProfile").getProfile(stobj.lockedby) />
		
		<cfoutput>
		<cfif stobj.lockedby eq session.security.userid>
			<!--- locked by current user --->
			<ft:button 	value="Unlock" 
						text="<h1>UNLOCK</h1>#application.rb.formatRBString('workflow.labels.lockedwhen@label', stLockedBy.label,'Locked by YOU')#"
						class="primary"
						rbkey="workflow.labels.lockedwhen@label" 
						url="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#&ref=#url.ref#" />
		<cfelseif stOverviewParams.stPermissions.iDeveloperPermission eq 1>
			<!--- locked by another user --->
			<ft:button 	value="Unlock" 
						text="<h1>UNLOCK</h1>#application.rb.formatRBString('workflow.labels.lockedwhen@label', stLockedBy.label,'Locked by {1}')#"
						class="primary"
						rbkey="workflow.labels.lockedwhen@label" 
						url="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#&ref=#url.ref#" />
		<cfelse>
			<!--- locked by another user --->
			<ft:button	value="Unlock" 
						text="<h1>LOCKED</h1>#uCase(application.rb.formatRBString('workflow.labels.lockedby@label', stLockedBy.label,'<span style="color:red">Locked by {1}</span>'))#"
						class="primary"
						type="button"
						rbkey="workflow.labels.lockedwhen@label" 
						onclick="alert('You do not have permission to unlock this content item.')" />		
			
		</cfif>
		</cfoutput>
		
	<cfelse>		
		<!--- work out different options depending on object status --->
		<cfif StructKeyExists(stobj,"status") AND stobj.status NEQ "">
			<cfswitch expression="#stobj.status#">
				<cfcase value="draft"> <!--- DRAFT STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1>
						<!--- MJB: added url.ref so that the edit methods know they were initially called by the overview page and they can return here if they so desire. --->
						<ft:button 	value="Edit this content item" 
									text="<h1>EDIT</h1>Edit this content item"
									class="primary"
									rbkey="workflow.buttons.edit" 
									url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
		
					<!--- check user can approve object --->
					<cfif stOverviewParams.stPermissions.iApprove eq 1 OR stOverviewParams.stPermissions.iApproveOwn EQ 1>
						<ft:button 	value="Send content item live"
									text="<h2>PUBLISH</h2>Approve content item"
									class="secondary"
									rbkey="workflow.buttons.sendlive" 
									url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved" />	
					</cfif>

				</cfcase>
			
				<cfcase value="pending"> <!--- PENDING STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND stobj.bAlwaysShowEdit EQ 1>
						<ft:button 	value="Edit this content item"
									text="<h1>EDIT</h1>Edit content item"
									class="primary" 
									rbkey="workflow.buttons.edit" 
									url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
				</cfcase>
		
				<cfcase value="approved">	
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND (not structkeyexists(stObj,"versionid") or stobj.bAlwaysShowEdit EQ 1)>
						<ft:button 	value="Edit this content item" 
									text="<h1>EDIT</h1>Edit content item"
									class="primary"
									rbkey="workflow.buttons.edit" 
									url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
					
					<!--- check if draft version exists --->
					<cfset bDraftVersionAllowed = StructKeyExists(stobj,"versionid")>
					<cfif bHasDraft EQ 0 AND stOverviewParams.stPermissions.iEdit eq 1 AND bDraftVersionAllowed>
						<ft:button 	value="Create an editable draft version"
									text="<h1>EDIT</h1>Create Underlying Draft"
									class="primary"
									rbkey="workflow.buttons.createdraft" 
									url="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stobj.objectID#&typename=#stobj.typeName#&ref=#url.ref#" />
					</cfif>
					<cfif stOverviewParams.stPermissions.iApprove eq 1 OR stOverviewParams.stPermissions.iApproveOwn EQ 1>
						<cfset buttonValue = application.rb.getResource("sendBackToDraft") />
						<cfif structKeyExists(stobj,"versionID") AND bHasDraft>
							<ft:button 	value="Send this content item back to draft (deleting the draft version)" 
										text="<h2>UNPUBLISH</h2>Send To Draft."
										class="secondary"
										rbkey="workflow.buttons.sendbacktodraftdeletedraft" 
										url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&typename=#stobj.typeName#&ref=#url.ref#"
										confirmText="This will delete the currently underlying draft version. Are you sure you wish to continue?" />
						<cfelse>
							<ft:button 	value="Send this content item back to draft" 
										text="<h2>UNPUBLISH</h2>Send To Draft"
										class="secondary" 
										rbkey="workflow.buttons.sendbacktodraft" 
										url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&typename=#stobj.typeName#&ref=#url.ref#" />
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		<cfelse>	<!--- content items without a status --->
			<!--- check user can edit --->
			<cfif stOverviewParams.stPermissions.iEdit EQ 1>
				<ft:button	value="Edit this content item" 
							text="<h2>EDIT</h2>Edit Content Item"
							class="primary" 
							rbkey="workflow.buttons.edit" 
							url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
			</cfif>
		</cfif>

		<!--- work out different options depending on object status --->
		<cfif StructKeyExists(stobj,"status") AND stobj.status NEQ "">
			<cfswitch expression="#stobj.status#">
				<cfcase value="draft"> <!--- DRAFT STATUS --->
		
					<!--- Check user can request approval --->
					<cfif stOverviewParams.stPermissions.iRequest eq 1>
							<ft:button 	value="Request approval" 
										text="<h2>PUBLISH</h2>Request approval."
										class="secondary"  
										rbkey="workflow.buttons.requestapproval" 
										url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=requestapproval&ref=#url.ref#" />

					</cfif>
		
					<!--- delete draft veresion --->
					<cfif stOverviewParams.stPermissions.iDelete eq 1> <!--- delete object --->
							<cfif listContains(application.navid.home,stobj.objectid) EQ 0 AND listContains(application.navid.root,stobj.objectid) eq 0>
							<!--- check user can delete --->
								<cfif stOverviewParams.stPermissions.iDelete eq 1>
									<cfif structkeyexists(stobj,"versionid") and len(stObj.versionid)>
										<cfset returnto = "returnto=#urlencodedformat('#cgi.script_name#?objectid=#stObj.versionid#&ref=#url.ref#')#" />
									<cfelse>
										<cfset returnto = "" />
									</cfif>
									<ft:button 	value="Delete"
												text="<h2>DELETE</h2>Delete Content Item."
												class="secondary"   
												rbkey="workflow.buttons.delete" 
												url="navajo/delete.cfm?ObjectId=#stobj.objectId#&#returnto#&ref=#url.ref#" 
												confirmText="Are you sure you wish to delete this content item?" />
								</cfif>
							</cfif>
					</cfif>
				</cfcase>
			
				<cfcase value="pending"> <!--- PENDING STATUS --->
					
					<cfif stOverviewParams.stPermissions.iApprove eq 1> <!--- check user can approve object --->
						<ft:button 	value="Send content item live" 
									text="<h2>PUBLISH</h2>Send content item live."
									class="secondary"  
									rbkey="workflow.buttons.sendlive" 
									url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved&ref=#url.ref#" />
						<!--- send back to draft --->
						<ft:button 	value="Send this content item back to draft"
									text="<h2>REJECT</h2>Send back to draft."
									class="secondary"   
									rbkey="workflow.buttons.sendbacktodraft" 
									url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&ref=#url.ref#" />
					</cfif>
				</cfcase>
		
				<cfcase value="approved">	
		
					<cfif listContains(application.navid.home,stobj.objectid) EQ 0 AND listContains(application.navid.root,stobj.objectid) eq 0>
						<!--- check user can delete --->
						<cfif stOverviewParams.stPermissions.iDelete eq 1>
							<ft:button 	value="Delete"  
										text="<h2>DELETE</h2>Delete this content item."
										class="secondary"   
										rbkey="workflow.buttons.delete" 
										url="navajo/delete.cfm?ObjectId=#stobj.objectId#&typename=#stobj.typeName#&ref=#url.ref#" 
										confirmText="Are you sure you wish to delete this content item?" />
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		<cfelse>	<!--- content items without a status --->
			
			<!--- check user can delete --->
			<cfif stOverviewParams.stPermissions.iDelete eq 1>
				<ft:button 	value="Delete" 
							text="<h2>DELETE</h2>delete this content item."
							class="secondary"   
							rbkey="workflow.buttons.delete" 
							url="navajo/delete.cfm?ObjectId=#stobj.objectId#&typename=#stobj.typeName#&ref=#url.ref#" 
							confirmText="Are you sure you wish to delete this content item?" />
			</cfif>
		</cfif>

	
		
		<!--- create child objects for dmNavigation --->
		<cfif stobj.typename EQ  "dmNavigation">
	
			<cfif application.security.checkPermission("ModifyPermissions") and listcontains(application.fapi.getPropertyMetadata(typename="farBarnacle", property="referenceid", md="ftJoin", default=""), stObj.typename)>
				<ft:button 	value="Modify Permissions" 
							text="<h2>PERMISSIONS</h2>User access"
							class="secondary"  
							type="button" 
							style="width:180px;"
							onClick="$fc.openDialogIFrame('Permissions', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions');" />
			</cfif>	
		</cfif>	



		<!--- preview object --->
		<cfswitch expression="#url.ref#">
			<cfcase value="iframe">
				<cfset target = "_top" />
			</cfcase>
			
			<cfdefaultcase>
				<cfset target = "_winPreview" />
			</cfdefaultcase>
		</cfswitch>
		<ft:button 	value="Preview" 
					text="<h2>PREVIEW</h2>View Content Item"
					class="secondary" 
					rbkey="workflow.buttons.preview" 
					url="#application.url.webroot#/index.cfm?objectid=#stobj.objectid#&flushcache=1&showdraft=1" 
					target="#target#" />

	
	</cfif>

	<cfif session.overviewRef EQ "iframe">
		<ft:button 	value="Close" 
					text="<h2>DONE</h2>Finished with this item"
					class="secondary" 
					type="button" 
					rbkey="workflow.buttons.close" 
					onClick="parent.$fc.objectAdminActionDiv.dialog('close');" />
	</cfif>
	

<cfsetting enablecfoutputonly="false">

