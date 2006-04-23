<cfimport taglib="/farcry/tags/display/" prefix="display">
		<cfif NOT stArgs.stRules.bEdit AND stArgs.stRules.versioning>  <!--- User may not edit LIVE/Approved objects - a draft must be created first --->
		
		<display:openlayer width="600" title="&nbsp;A L E R T&nbsp;" titlecolor="navy" isClosed="No" bordersize="2">
			<cfoutput>
				<cfswitch expression="#stArgs.stRules.status#">
					<cfcase value="approved">
						<table bgcolor="white">
						<tr>
							<td>
							<cfif stArgs.stRules.bDraftVersionExists>
								<span class="formtitle">You may not directly edit this object</span>
								<p></p>
								<span class="frameMenuBullet">&raquo;</span> <a href="edit.cfm?objectID=#stArgs.stRules.draftObjectID#&usingnavajo=1&type=#url.type#" class="frameMenuItem">Edit draft version</a><br>
								</tr><tr><td>
								<span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectID=#stArgs.stRules.draftObjectID#&status=approved" class="frameMenuItem">Send draft version live</a><br>
							<cfelse>
								<span class="formtitle">You may not edit approved objects</span>
								<p></p>
								<span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#URL.objectID#" class="frameMenuItem">Create an editable draft version</a><br>
							</cfif>
							</td>
						</tr>
						<tr>
							<td>
							<cfif stArgs.stRules.bComment>
								<span class="frameMenuBullet">&raquo;</span> <a href="javascript:void(0);" onClick="window.open('#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stArgs.stobj.objectid#', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Comment on this object</a><br>
							<cfelse>
								<span class="frameMenuBullet">&raquo;</span> You man not comment on this object	<br>
							</cfif>
							</td>
						</tr>
						
						<cfif stArgs.stRules.bDecline AND NOT stArgs.stRules.bDraftVersionExists>
							<tr>
								<td>
								<span class="frameMenuBullet">&raquo;</span> <a href="javascript:void(0);"  onClick="window.open('#application.url.farcry#/navajo/approve.cfm?objectid=#stArgs.stobj.objectid#&status=draft', '_blank','width=500,height=400,menubar=no,toolbars=no,resize=yes', false);" class="frameMenuItem">Send this object to draft</a>
								<br>
								</td>
							</tr>	
						</cfif>
						
					</table>
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
						<td><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/complete.cfm" class="frameMenuItem">CANCEL</a></td>
					</tr>
				</table>
			</cfoutput>
			</display:openlayer>
			<cfabort>
		</cfif>