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
$Header: /cvs/farcry/core/packages/farcry/versioning.cfc,v 1.11 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: versioning cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Object Versioning" hint="Functions to handle versioning of objects">

<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
	
	<cffunction name="sendObjectLive" access="public" returntype="struct" hint="Sends a versioned object with draft live.Archives existing live object if it exists and deletes old live object">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="stDraftObject"  type="struct" required="true" hint="the draft stuct to be updated">
		<cfargument name="typename" type="string" required="false" hint="Providing typename avoids a type-lookup from the objectid, offering a slight performance increase.">
		<cfargument name="bCopyDraftContainers" type="boolean" required="false" default="true" hint="Containers configured for the draft object will be copied when the object is sent live.">
		
		<cfset var stResult = structNew() />
		<cfset var o = "" />
		
		<cfset stResult.result = false />
		<cfset stResult.message = 'No update has taken place' />
		
		<cfif NOT structkeyexists(arguments,"typename")>
			<cfset arguments.typename = application.fapi.findType(objectid=arguments.objectid) />
		</cfif>
		
		<cfset o = application.fapi.getContentType(arguments.typename) />
		
		<cfif structKeyExists(arguments.stDraftObject,"versionID") AND NOT len(trim(arguments.stDraftObject.versionID)) EQ 0 >
			<cflock name="sendlive_#arguments.stDraftObject.versionID#" timeout="50" type="exclusive">
				
				<!--- copy all container data to live object --->
				<cfif arguments.bCopyDraftContainers>
					<cfset application.factory.oCon.copyContainers(srcObjectID=arguments.stDraftObject.objectId,destObjectID=arguments.stDraftObject.versionID,bDeleteSrcData=1) />
				</cfif>
				
				<!--- this will copy categories from draft object to live --->
				<cfset application.factory.oCategory.copyCategories(arguments.stDraftObject.objectid,arguments.stDraftObject.versionID) />
				
				<!--- delete the old draft --->
				<cfset o.deleteData(objectid=arguments.stDraftObject.objectid) />
				<cfset application.factory.oCategory.deleteAssignedCategories(objectid=arguments.stDraftObject.objectid) />
				
				<!--- need to set stDraft object to live for fourq update. Update datetimeLastUpdated and clear out versionID --->
				<cfset arguments.stDraftObject.objectid = arguments.stDraftObject.versionID />
				<cfset arguments.stDraftObject.versionID = "" />
				<cfset arguments.stDraftObject.status = "approved" />
				<cfset arguments.stDraftObject.dateTimeLastUpdated = createODBCDateTime(Now()) />
				<cfset structDelete(arguments.stDraftObject,"dateTimeCreated") /><!--- do not update created time when publishing --->
				<cfset o.setData(stProperties=arguments.stDraftObject,auditNote='Draft version sent live',previousStatus="draft") />
				
				<cfset stResult.result = true />
				<cfset stResult.message = 'Update Successful' />
							
			</cflock>
			
		</cfif>
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getVersioningRules" access="public" returntype="struct" hint="Returns a structure of boolean rules concerning the editing of farcry objects">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">
		
		<cfset var stObject = structnew() />
		<cfset var stRules = structnew() />
		<cfset var qHasDraft = "" />
		
		<cfif NOT structkeyexists(arguments,"typename")>
			<cfset arguments.typename = application.fapi.findType(arguments.objectid) />
		</cfif>
		
		<cfset stObject = application.fapi.getContentObject(typename=arguments.typename,objectid=arguments.objectid) />
		
		<!--- Determine if draft/pending objects have a live parent --->
		<!--- init struct - probably including too much stuff here - but extras may be useful at some point --->
		<cfset stRules = structNew() />
		<cfset stRules.versioning = true /><!--- Is versioning performed on this object? --->
		<cfset stRules.bEdit = false /><!--- Can the user edit this object? --->
		<cfset stRules.bComment = false /><!--- can the user make comments on object --->
		<cfset stRules.bApprove = false /><!--- can user approve object - ie send live --->
		<cfset stRules.bDecline = false /><!--- can user send object back to draft --->
		<cfset stRules.bCreateDraft = false /><!--- create a draft version of object to edit? --->
		<cfset stRules.bDraftVersionExists = false />
		<cfset stRules.bLiveVersionExists = false />
		<cfset stRules.draftObjectID = "" /><!--- this objectID (if exists) of the draft object --->
		<cfset stRules.bDeleteDraft = false />
		
		<!--- check if status is part of object --->
		<cfif NOT structKeyExists(stObject,"versionID")>
			<cfset stRules.status = false />
		<cfelse>
			<cfset stRules.status = stObject.status /><!--- draft,pending,approved? --->
		</cfif>
		
		<!--- if property doesn't exist - the versioning is not an issue --->
		<cfif NOT structKeyExists(stObject,"versionID")>
			<cfset stRules.versioning = false />
		<cfelse>
			<cfif len(trim(stObject.versionID)) NEQ 0><!--- flags whether a live version of this object exists --->
				<cfset stRules.bLiveVersionExists = true />
			<cfelse>
				<cfset stRules.bLiveVersionExists = false />
			</cfif>
			
			<cfswitch expression="#stRules.status#">
				<cfcase value="approved">
					<cfset stRules.bComment = true />
					<cfset stRules.bDecline = true /><!--- need to make sure relevant permissions to do this on calling page --->
					<cfset stRules.bCreateDraft = true />
				</cfcase>
				
				<cfcase value="pending">
					<cfif stRules.bLiveVersionExists>
						<cfset stRules.bComment = true />
						<cfset stRules.bPreview = true />
						<cfset stRules.bApprove = true />
						<cfset stRules.bDecline = true />
					<cfelse>
						<cfset stRules.bComment = true />
						<cfset stRules.bApprove = true />
						<cfset stRules.bDecline = true />
					</cfif>
				</cfcase>
				
				<cfcase value="draft">
					<cfif stRules.bLiveVersionExists>
						<cfset stRules.bEdit = true />
						<cfset stRules.bApprove = true />
						<cfset stRules.bComment = true />
					<cfelse>
						<cfset stRules.bEdit = true />
						<cfset stRules.bComment = true />
						<cfset stRules.bApprove = true />
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>
		
		<!--- Now check to see if a draft version exists --->
		<cfif stRules.status IS "Approved" and structKeyExists(stObject,"versionID")>
			<cfset qHasDraft = application.fapi.getContentObjects(typename=stObject.typename,lProperties="objectid,status",versionID_eq=arguments.objectid) />
			<cfif qHasDraft.recordcount GT 1>
				<cfthrow extendedinfo="Multiple draft children returned" message="Multiple draft error">
			<cfelseif qHasDraft.recordcount eq 1>
				<cfset stRules.bDraftVersionExists = true />
				<cfset stRules.bDecline = false />
				<cfset stRules.draftObjectID = qHasDraft.objectID />
				<cfset stRules.draftStatus = qHasDraft.status />
				<cfset stRules.bDeleteDraft = true />
			</cfif> 
		</cfif>

		<cfreturn stRules>
	</cffunction>	 
	
	<cffunction name="checkEdit" access="public" hint="See if we can edit this object">
		<cfargument name="stRules" type="struct" required="true">
		<cfargument name="stObj" type="struct" required="true">
		
		<cfset var oNav = "" />
		<cfset var qParent = "" />
		<cfset var parentNavID = "" />
		
		<cfif NOT arguments.stRules.bEdit AND arguments.stRules.versioning>
			<!--- User may not edit LIVE/Approved objects - a draft must be created first --->
			
			<cfswitch expression="#arguments.stRules.status#">
				<cfcase value="approved">
					<cfoutput>
						<script>
							function confirmDelete(){
								if(confirm('Are you sure you wish to delete this draft?')){
									parent.frames['editFrame'].location.href='#application.url.farcry#/edittabEdit.cfm?objectid=#arguments.stobj.objectid#&deleteDraftObjectID=#arguments.stRules.draftObjectID#';
									parent.frames['editFrame'].location.reload();}								
							}
						</script>
						<ul>
					</cfoutput>
			
					<cfif arguments.stRules.bDraftVersionExists>
						<cfset oNav = application.fapi.getContentType("dmNavigation") />
						<cfset qParent = oNav.getParent(objectid=arguments.stObj.objectid) />
						<cfset parentNavID = qParent.parentID />
						
						<cfoutput>
							<span class="formtitle">A DRAFT version of this object exists...</span>
							<p></p>
							<li type="square">
								<a href="#application.url.farcry#/edittabEdit.cfm?objectID=#arguments.stRules.draftObjectID#&usingnavajo=1&typename=#url.typename#" class="frameMenuItem">Edit draft version</a><br>
								Edit the DRAFT version of this object while retaining the LIVE version for  public viewing.
							</li>
							<br><br>
						</cfoutput>
						
						<cfif not parentNavID eq "">
							<cfif arguments.stRules.bDeleteDraft AND application.security.checkPermission(permission="delete",object=parentNavID) EQ 1>
								<cfoutput>
									<li type="square">
										<a href="edittabEdit.cfm?objectid=#URL.objectID#&deleteDraftObjectID=#arguments.stRules.draftObjectID#" onClick="return confirm('Are you sure you wish to delete this object?');" class="frameMenuItem">Delete draft object</a><br>
										Delete the DRAFT version of this object. 
									</li>
									<br><br>
								</cfoutput>
							</cfif>
						</cfif>
						
						<cfif arguments.stRules.draftStatus IS "pending">
							<cfoutput>
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#arguments.stRules.draftObjectID#&status=approved" class="frameMenuItem">Send draft version live</a>
									 <br>Send the current draft version live, replacing the existing live version with the draft.
								</li>
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#arguments.stRules.draftObjectID#&status=draft" class="frameMenuItem">Decline pending version</a>
									 <br>Send the current pending version back to draft.
								</li>
							</cfoutput>
						<cfelseif arguments.stRules.draftStatus IS "draft">
							<cfoutput>
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?draftobjectID=#arguments.stRules.draftObjectID#&objectID=#arguments.stObj.ObjectID#&status=requestApproval" class="frameMenuItem">Request DRAFT version be sent LIVE </a><br>Request that the DRAFT version be sent LIVE for public viewing and archive the existing LIVE version's content. 
								</li>
							</cfoutput>
						</cfif>
						
						<cfoutput><br><br></cfoutput>
					<cfelse>
						<cfoutput>
							<span class="formtitle">You may not edit approved objects</span>
							<p></p>
							<li type="square">
								<a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#URL.objectID#" class="frameMenuItem">Create an editable draft version</a><br>
								Create a new editable DRAFT version of this object while retaining the LIVE version for public viewing.
							</li>
							<br><br>
						</cfoutput>
					</cfif>
					
					<cfif arguments.stRules.bComment>
						<cfoutput>
							<li type="square">
								<a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#arguments.stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on live object</a><br>
								Append your comments to the LIVE version's comment log. 
							</li>
							<br><br>
						</cfoutput>
					</cfif>
					
					<cfif arguments.stRules.bDraftVersionExists>
						<cfoutput>
							<li type="square">
								<a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#arguments.strules.draftobjectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on draft object</a><br>
								Append your comments to the DRAFT version's comment log. 
							</li>
							<br><br>	
						</cfoutput>
					</cfif>
					
					<cfif arguments.stRules.bDecline AND NOT arguments.stRules.bDraftVersionExists>
						<cfoutput>
							<li type="square">
								 <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#arguments.stobj.objectid#&status=draft" class="frameMenuItem">Send this object to draft</a>
								<br>
							</li>
							<br><br>	
						</cfoutput>			
					</cfif>
					
					<cfoutput></ul></cfoutput>
				</cfcase>	
				<cfcase value="pending">
					<cfoutput><span class="formtitle">You may not edit "pending" objects</span></cfoutput>
				</cfcase>
				<cfdefaultcase>
					<cfoutput><span class="formtitle">No action specified</span></cfoutput>
				</cfdefaultcase>	
			</cfswitch>
			
			<cfoutput>
				<br>
				<table bgcolor="white">
					<tr>
						<td><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/edittabOverview.cfm?objectid=#arguments.stobj.objectid#" class="frameMenuItem">CANCEL</a></td>
					</tr>
				</table>
			</cfoutput>
			
			<cfabort>
		</cfif>
	</cffunction>
	
	<!--- Approval emails --->
	<cffunction name="approveEmail_approved" access="public" hint="Sends out email informing lastupdated user that object has been approved">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectid) />
		<cfset var stProfile = application.fapi.getContentType("dmProfile").getProfile(userName=stObj.lastupdatedby)>
		<cfset var stEmail = structnew() />
		<cfset var returnstruct = structnew() />
		
		<!--- send email to lastupdater to let them know object is approved --->
		<cfif stProfile.emailAddress neq "" AND stProfile.bReceiveEmail>

		    <cfif session.dmProfile.emailAddress neq "">
		        <cfset stEmail.from = session.dmProfile.emailAddress>
		    <cfelse>
		        <cfset stEmail.from = stProfile.emailAddress>
		    </cfif>
			
			<cfset stEmail.to = stProfile.emailAddress>
			<cfset stEmail.subject = "{1} - Page Approved">
			
			<cfset stEmail.rbkey = "workflow.email.approved" />
			<cfset stEmail.variables = arraynew(1) />
			<cfset stEmail.variables[1] = application.fapi.getConfig("general","sitetitle") />
			<cfif len(stProfile.firstName) gt 0>
				<cfset stEmail.variables[2] = stProfile.firstName />
			<cfelse>
				<cfset stEmail.variables[2] = stProfile.userName />
			</cfif>
			<cfif isDefined("stObj.title") and len(trim(stObj.title))>
				<cfset stEmail.variables[3] = stObj.title />
			<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>
				<cfset stEmail.variables[3] = stObj.label />
			<cfelse>
				<cfset stEmail.variables[3] = "undefined" />
			</cfif>
			<cfif len(arguments.comment)>
				<cfset stEmail.variables[4] = application.fapi.getResource("workflow.email.comment@text","Comments added on status change:
{1}",arguments.comment) />
			<cfelse>
				<cfset stEmail.variables[4] = "" />
			</cfif>
			
			<cfsavecontent variable="stEmail.bodyPlain"><cfoutput>
Hi {2},

Your page "{3}" has been approved.

{4}
			</cfoutput></cfsavecontent>
			
			<cfsavecontent variable="stEmail.bodyHTML"><cfoutput>
				<p>Hi {2},</p>

				<p>Your page "{3}" has been approved.</p>

				<p>{4}</p>
			</cfoutput></cfsavecontent>
			
			<cfset returnstruct = application.fc.lib.email.send(argumentCollection=stEmail) />
		</cfif>
	</cffunction>
	
	<cffunction name="approveEmail_pending" access="public" hint="Sends out email to list of approvers to approve/decline object">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		<cfargument name="lApprovers" type="string" required="true" hint="List of approvers to send email to" default="all">
		
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectID) />
		<cfset var qHasDraft = "" />
		<cfset var child = "" />
		<cfset var parentID = "" />
		<cfset var item = "" />
		<cfset var stApprovers = structnew() />
		<cfset var stEmail = structnew() />
		<cfset var returnstruct = structnew() />
		
		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
		
		<!--- check if underlying draft --->
		<cfif IsDefined("stObj.versionID") and stObj.versionID neq "">
			<cfset qHasDraft = application.fapi.getContentObjects(typename=stObj.typename,objectid_eq=stObj.versionID) />
			<cfset child = qHasDraft.objectid>
		<cfelse>
			<cfset child = stobj.objectid>
		</cfif>
		
		<!--- get navigation parent --->
		<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#child#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
		
		<!--- get list of approvers for this object --->
		<cfinvoke component="#application.packagepath#.farcry.workflow" method="getObjectApprovers" returnvariable="stApprovers">
			<cfinvokeargument name="objectID" value="#arguments.objectID#"/>
		</cfinvoke>
		
		<cfloop collection="#stApprovers#" item="item">
			<!--- check user had email profile and is in list of approvers --->
			<cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail and stApprovers[item].userName neq application.security.getCurrentUserID() AND (arguments.lApprovers eq "all" or listFind(arguments.lApprovers,stApprovers[item].userName))>
				
			    <cfif session.dmProfile.emailAddress neq "">
			        <cfset stEmail.from = session.dmProfile.emailAddress>
			    <cfelse>
			        <cfset stEmail.from = stApprovers[item].emailAddress>
			    </cfif>
				
				<cfset stEmail.to = stApprovers[item].emailAddress>
				<cfset stEmail.subject = "{1} - Page Approval Request">
				
				<cfset stEmail.rbkey = "workflow.email.pending" />
				<cfset stEmail.variables = arraynew(1) />
				<cfset stEmail.variables[1] = application.fapi.getConfig("general","sitetitle") />
				<cfif len(stApprovers[item].firstName) gt 0>
					<cfset stEmail.variables[2] = trim(stApprovers[item].firstName) />
				<cfelse>
					<cfset stEmail.variables[2] = trim(stApprovers[item].userName) />
				</cfif>
				<cfif isDefined("stObj.title") and len(trim(stObj.title))>
					<cfset stEmail.variables[3] = stObj.title />
				<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>
					<cfset stEmail.variables[3] = stObj.label />
				<cfelse>
					<cfset stEmail.variables[3] = "undefined" />
				</cfif>
				<cfif len(application.fapi.getConfig('general','adminServer',''))>
					<cfset stEmail.variables[4] = application.fapi.getConfig('general','adminServer','') & application.url.webtop />
				<cfelse>
					<cfset stEmail.variables[4] = application.fc.lib.seo.getCanonicalBaseURL() & application.url.webtop />
				</cfif>
				<cfif len(parentID)>
					<cfset stEmail.variables[4] = stEmail.variables[4] & "/index.cfm?sec=site&rootObjectID=" & parentID />
				<cfelse>
					<cfset stEmail.variables[4] = stEmail.variables[4] & "/edittabOverview.cfm?objectid=#arguments.objectID#" />
				</cfif>
				<cfset stEmail.variables[5] = arguments.comment />
				
				<cfsavecontent variable="stEmail.bodyPlain"><cfoutput>
Hi {2},

Page "{3}" is awaiting your approval.

You may approve/decline this page by browsing to the following location:
{4}

Comments added on status change:
{5}
				</cfoutput></cfsavecontent>
		
				<cfsavecontent variable="stEmail.bodyHTML"><cfoutput>
					<p>Hi {2},</p>

					<p>Page "{3}" is awaiting your approval.</p>

					<p>You may approve/decline this page by browsing to the <a href="{4}">Webtop</a>.</p>

					<p>Comments added on status change:<br>{5}</p>
				</cfoutput></cfsavecontent>
		
				<!--- send email alerting them to object is waiting approval  --->
				<cfset returnstruct = application.fc.lib.email.send(argumentCollection=stEmail) />
		  </cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="approveEmail_draft" access="public" hint="Sends out email informing lastupdated user that object has been sent back to draft">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectid) />
		<cfset var parentID = "" />
		<cfset var stProfile = structnew() />
		<cfset var stEmail = structnew() />
		<cfset var returnstruct = structnew() />
		
		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
		
		<!--- get navigation parent --->
		<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.objectid#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
		
		<!--- get dmProfile object --->
		<cfset stProfile = application.fapi.getContentType("dmProfile").getProfile(userName=stObj.lastupdatedby) />
		
		<!--- send email to lastupdater to let them know object is sent back to draft --->
		<cfif stProfile.emailAddress neq "" AND stProfile.bReceiveEmail>
		
		    <cfif session.dmProfile.emailAddress neq "">
		        <cfset stEmail.from = session.dmProfile.emailAddress>
		    <cfelse>
		        <cfset stEmail.from = stProfile.emailAddress>
		    </cfif>
			
			<cfset stEmail.to = stProfile.emailAddress>
			<cfset stEmail.subject = "{1} - Page sent back to Draft">
			
			<cfset stEmail.rbkey = "workflow.email.draft" />
			<cfset stEmail.variables = arraynew(1) />
			<cfset stEmail.variables[1] = application.fapi.getConfig("general","sitetitle") />
			<cfif len(stProfile.firstName) gt 0>
				<cfset stEmail.variables[2] = stProfile.firstName />
			<cfelse>
				<cfset stEmail.variables[2] = stProfile.userName />
			</cfif>
			<cfif isDefined("stObj.title") and len(trim(stObj.title))>
				<cfset stEmail.variables[3] = stObj.title />
			<cfelseif isDefined("stObj.label") and len(trim(stObj.label))>
				<cfset stEmail.variables[3] = stObj.label />
			<cfelse>
				<cfset stEmail.variables[3] = "undefined" />
			</cfif>
			<cfset stEmail.variables[4] = arguments.comment />
			<cfif len(application.fapi.getConfig('general','adminServer',''))>
				<cfset stEmail.variables[5] = application.fapi.getConfig('general','adminServer','') & application.url.webtop />
			<cfelse>
				<cfset stEmail.variables[5] = application.fc.lib.seo.getCanonicalBaseURL() & application.url.webtop />
			</cfif>
			<cfif len(parentID)>
				<cfset stEmail.variables[5] = stEmail.variables[4] & "/index.cfm?sec=site&rootObjectID=" & parentID />
			<cfelse>
				<cfset stEmail.variables[5] = stEmail.variables[4] & "/edittabOverview.cfm?objectid=#arguments.objectID#" />
			</cfif>
			
			<cfsavecontent variable="stEmail.bodyPlain"><cfoutput>
Hi {2},

Your page "{3}" has been sent back to draft.

Comments added on status change:
{4}

You may edit this page by browsing to the following location:
{5}
			</cfoutput></cfsavecontent>
				
			<cfsavecontent variable="stEmail.bodyHTML"><cfoutput>
				<p>Hi {2},</p>

				<p>Your page "{3}" has been sent back to draft.</p>

				<p>Comments added on status change:<br>{4}</p>

				<p>You may edit this page by browsing to the <a href="{5}">Webtop</a>.</p>
			</cfoutput></cfsavecontent>
				
			<cfset returnstruct = application.fc.lib.email.send(argumentCollection=stEmail) />
		</cfif>
	</cffunction>
	
	<cffunction name="checkIsDraft" access="public" returntype="query" hint="Checks to see if object is an underlying draft object">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object to be checked">
		<cfargument name="type" type="string" required="true" hint="Object type to be checked">
		<cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">

		<cfset var qCheckIsDraft = "">

		<cfquery datasource="#arguments.dsn#" name="qCheckIsDraft">
			SELECT objectID,status from #application.dbowner##arguments.type# where versionID = '#arguments.objectID#'
		</cfquery>
		
		<cfreturn qCheckIsDraft>
	</cffunction>
	
</cfcomponent>