<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">
		<cfif NOT stArgs.stRules.bEdit AND stArgs.stRules.versioning>  <!--- User may not edit LIVE/Approved objects - a draft must be created first --->
		
		
			<cfoutput>
				<cfswitch expression="#stArgs.stRules.status#">
					<cfcase value="approved">
							<script>
								
								function confirmDelete(){
									if(confirm('Are you sure you wish to delete this draft?')){
										parent.frames['editFrame'].location.href='#application.url.farcry#/edittabedit.cfm?objectid=#stArgs.stobj.objectid#&deleteDraftObjectID=#stArgs.stRules.draftObjectID#';
										parent.frames['editFrame'].location.reload();}								
								}		
								
							</script>
							<ul>
							<cfif stArgs.stRules.bDraftVersionExists>
								<span class="formtitle">A DRAFT version of this object exists...</span>
								<p></p>								
								<li type="square">
								 <a href="#application.url.farcry#/edittabEdit.cfm?objectID=#stArgs.stRules.draftObjectID#&usingnavajo=1&type=#url.type#" class="frameMenuItem">Edit draft version</a><br>
								Edit the DRAFT version of this object while retaining the LIVE version for  public viewing.
								</li>
								<br><br>
							
								<cfif stArgs.stRules.bDeleteDraft AND application.permission.dmnavigation.Delete.permissionId>
								<li type="square">
								 <a href="edittabEdit.cfm?objectid=#URL.objectID#&deleteDraftObjectID=#stArgs.stRules.draftObjectID#" onClick="return confirm('Are you sure you wish to delete this object?');" class="frameMenuItem">Delete draft object</a><br>
								Delete the DRAFT version of this object. 
								
								</li>
								<br><br>
			
								</cfif>
								<cfif stArgs.stRules.draftStatus IS "pending">
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#stArgs.stRules.draftObjectID#&status=approved" class="frameMenuItem">Send draft version live</a>
									 <br>Send the current draft version live, replacing the existing live version with the draft.
								</li>
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#stArgs.stRules.draftObjectID#&status=draft" class="frameMenuItem">Decline pending version</a>
									 <br>Send the current pending version back to draft.
								</li>
								<cfelseif stArgs.stRules.draftStatus IS "draft">
								<li type="square">
									 <a href="#application.url.farcry#/navajo/approve.cfm?draftobjectID=#stArgs.stRules.draftObjectID#&objectID=#stArgs.stObj.ObjectID#&status=requestApproval" class="frameMenuItem">Request DRAFT version be sent LIVE </a><br>Request that the DRAFT version be sent LIVE for public viewing and archive the existing LIVE version's content. 

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
							
							<cfif stArgs.stRules.bComment>
								<li type="square"><a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stArgs.stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on live object</a><br>
								Append your comments to the LIVE version's comment log. 
								</li>
								<br><br>
							</cfif>
							<cfif stArgs.stRules.bDraftVersionExists>
								<li type="square"><a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stArgs.strules.draftobjectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on draft object</a><br>
								Append your comments to the DRAFT version's comment log. 
							</li>
							<br><br>	
							
							</cfif>
						
						<cfif stArgs.stRules.bDecline AND NOT stArgs.stRules.bDraftVersionExists>
							<li type="square">
								 <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stArgs.stobj.objectid#&status=draft" class="frameMenuItem">Send this object to draft</a>
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
						<td><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/edittabOverview.cfm?objectid=#stArgs.stobj.objectid#" class="frameMenuItem">CANCEL</a></td>
					</tr>
				</table>
			</cfoutput>
			
			<cfabort>
		</cfif>