<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_versioning/checkEdit.cfm,v 1.16.2.1 2006/02/14 02:55:28 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/14 02:55:28 $
$Name: milestone_3-0-1 $
$Revision: 1.16.2.1 $

|| DESCRIPTION || 
$Description: checks versioning before editing $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->


<cfif NOT arguments.stRules.bEdit AND arguments.stRules.versioning>  <!--- User may not edit LIVE/Approved objects - a draft must be created first --->


	<cfoutput>
		<cfswitch expression="#arguments.stRules.status#">
			<cfcase value="approved">
					<script>
						
						function confirmDelete(){
							if(confirm('Are you sure you wish to delete this draft?')){
								parent.frames['editFrame'].location.href='#application.url.farcry#/edittabEdit.cfm?objectid=#arguments.stobj.objectid#&deleteDraftObjectID=#arguments.stRules.draftObjectID#';
								parent.frames['editFrame'].location.reload();}								
						}		
						
					</script>
					<ul>
					
					<cfif arguments.stRules.bDraftVersionExists>
						
						<cfscript>
							oNav = createObject("component",application.types['dmNavigation'].typepath);
							qParent = oNav.getParent(objectid=arguments.stObj.objectid);
							parentNavID = qParent.parentID;
						</cfscript>
					
						<span class="formtitle">A DRAFT version of this object exists...</span>
						<p></p>								
						<li type="square">
						 <a href="#application.url.farcry#/edittabEdit.cfm?objectID=#arguments.stRules.draftObjectID#&usingnavajo=1&typename=#url.typename#" class="frameMenuItem">Edit draft version</a><br>
						Edit the DRAFT version of this object while retaining the LIVE version for  public viewing.
						</li>
						<br><br>
						<cfif not parentNavID eq "">
							<cfif arguments.stRules.bDeleteDraft AND application.security.checkPermission(permission="delete",object=parentNavID) EQ 1>
							<li type="square">
							 <a href="edittabEdit.cfm?objectid=#URL.objectID#&deleteDraftObjectID=#arguments.stRules.draftObjectID#" onClick="return confirm('Are you sure you wish to delete this object?');" class="frameMenuItem">Delete draft object</a><br>
							Delete the DRAFT version of this object. 
							</li>
							<br><br>
							</cfif>
						</cfif>
						<cfif arguments.stRules.draftStatus IS "pending">
						<li type="square">
							 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#arguments.stRules.draftObjectID#&status=approved" class="frameMenuItem">Send draft version live</a>
							 <br>Send the current draft version live, replacing the existing live version with the draft.
						</li>
						<li type="square">
							 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#arguments.stRules.draftObjectID#&status=draft" class="frameMenuItem">Decline pending version</a>
							 <br>Send the current pending version back to draft.
						</li>
						<cfelseif arguments.stRules.draftStatus IS "draft">
						<li type="square">
							 <a href="#application.url.farcry#/navajo/approve.cfm?draftobjectID=#arguments.stRules.draftObjectID#&objectID=#arguments.stObj.ObjectID#&status=requestApproval" class="frameMenuItem">Request DRAFT version be sent LIVE </a><br>Request that the DRAFT version be sent LIVE for public viewing and archive the existing LIVE version's content. 

						</li>
						</cfif>
						<br><br>
					<cfelse>
						<span class="formtitle">You may not edit approved objects</span>
						<p></p>
						<li type="square"><a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#URL.objectID#" class="frameMenuItem">Create an editable draft version</a><br>
					Create a new editable DRAFT version of this object while retaining the LIVE 
  version for public viewing. </li>	<br><br>
					</cfif>
					
					<cfif arguments.stRules.bComment>
						<li type="square"><a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#arguments.stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on live object</a><br>
						Append your comments to the LIVE version's comment log. 
						</li>
						<br><br>
					</cfif>
					<cfif arguments.stRules.bDraftVersionExists>
						<li type="square"><a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#arguments.strules.draftobjectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on draft object</a><br>
						Append your comments to the DRAFT version's comment log. 
					</li>
					<br><br>	
					
					</cfif>
				
				<cfif arguments.stRules.bDecline AND NOT arguments.stRules.bDraftVersionExists>
					<li type="square">
						 <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#arguments.stobj.objectid#&status=draft" class="frameMenuItem">Send this object to draft</a>
						<br>
					</li>
					<br><br>	
							
				</cfif>

			</ul>
			</cfcase>	
			<cfcase value="pending">
				<span class="formtitle">You may not edit "pending" objects</span>
			</cfcase>
			<cfdefaultcase>
				<span class="formtitle">No action specified</span>
			</cfdefaultcase>	
		</cfswitch>
		<br>
		<table bgcolor="white">
			<tr>
				<td><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/edittabOverview.cfm?objectid=#arguments.stobj.objectid#" class="frameMenuItem">CANCEL</a></td>
			</tr>
		</table>
	</cfoutput>
	
	<cfabort>
</cfif>