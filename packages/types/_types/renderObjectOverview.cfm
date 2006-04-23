<!--- check if underlying draft version, need to get details of approved object --->

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<cfif structKeyExists(stObj,"versionID") and stObj.versionID neq "">
	<cflocation url="edittabOverview.cfm?objectid=#stObj.versionID#" addtoken="no">
</cfif>

<cfscript>
	oAuthentication = request.dmsec.oAuthentication;
	stUser = oAuthentication.getUserAuthenticationData();
</cfscript>


<cfsavecontent variable="html">
	<!--- make sure overview tab is selected --->
	<script>
		synchTab('editFrame','activesubtab','subtab','siteEditOverview');
		synchTitle('Overview')
	</script>
	<cfscript>
		oAuthorisation = request.dmSec.oAuthorisation;
		iDeveloperPermission = oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
	</cfscript>
			
	<div class="FormTitle"><Cfoutput>#stobj.title#</Cfoutput></div>
	<!--- ### check if underlying draft object ### --->
	<cfif structKeyExists(stObj,"versionID") and stobj.status eq "approved">
		<!--- check for draft --->
		<cfscript>
			oVersioning = createObject("component", "#application.packagepath#.farcry.versioning");
			qHasDraft = oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename);
		</cfscript>
		<cfif qHasDraft.recordcount>
			<!--- get draft object details --->
			<q4:contentobjectget objectid="#qHasDraft.objectid#" r_stobject="stobjDraft">
						
			<!--- main table --->
			<table cellpadding="5" cellspacing="0" border="1" style="margin-bottom:30px" width="95%" align="center">
			<tr class="dataheader">
				<td>Overview - Draft Object</td>
				<td>What would you like to do now?</td>
			</tr>
			<tr class="overview<cfoutput>#stobjDraft.status#</cfoutput>">
				<td width="50%" valign="top">
					<!--- column 1 - overview --->
					<table cellpadding="5" cellspacing="0" border="0">
					<tr>
						<td width="100"><strong>Object Title:</strong></td>
						<td>
							<cfif stobjDraft.title neq "">
								<Cfoutput>#stobjDraft.title#</Cfoutput>
							<cfelse>
								<i>undefined</i>
							</cfif></td>
					</tr>
					<tr>
						<td><strong>Created by:</strong></td>
						<td><Cfoutput>#stobjDraft.createdby#</Cfoutput></td>
					</tr>
					<tr>
						<td><strong>Date Created:</strong></td>
						<td><Cfoutput>#dateformat(stobjDraft.datetimecreated)#</Cfoutput></td>
					</tr>
					<tr>
						<td><strong>Locking:</strong></td>
						<td>
							<cfif stobjDraft.locked and stobjDraft.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
								<!--- locked by current user --->				
								<cfoutput><span style="color:red">Locked (#dateFormat(stobjDraft.dateTimeLastUpdated,"dd-mmm-yy")# #timeformat(stobjDraft.dateTimeLastUpdated, "hh:mm")#)</span> <a href="navajo/unlock.cfm?objectid=#stobjDraft.objectid#&typename=#stobjDraft.typename#">[UnLock]</a></cfoutput>
							
							<cfelseif stobjDraft.locked>
								<!--- locked by another user --->
								<cfoutput><span style="color:red">Locked (#dateFormat(stobjDraft.dateTimeLastUpdated,"dd-mmm-yy")# #timeformat(stobjDraft.dateTimeLastUpdated, "hh:mm")#)</span> by #stobjDraft.lockedby#</cfoutput>
								<!--- check if current user is a sysadmin so they can unlock --->
								
								
								<cfif iDeveloperPermission eq 1>
									<!--- show link to unlock --->
									 <cfoutput><a href="navajo/unlock.cfm?objectid=#stobjDraft.objectid#&typename=#stobj.typename#">[UnLock]</a></cfoutput>
								</cfif>
							
							<cfelse>
								<!--- no locking --->
								<cfoutput>Unlocked</cfoutput>
							</cfif>
						</td>
					</tr>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong>Last Updated:</strong></td>
						<td><Cfoutput>#dateformat(stobjDraft.datetimelastupdated)#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong>Last Updated By:</strong></td>
						<td><Cfoutput>#stobjDraft.lastupdatedby#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong>Current Status:</strong></td>
						<td><Cfoutput>#stobjDraft.status#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					
					<tr>
						<td><strong>Template:</strong></td>
						<td><cfoutput>#stobjDraft.displaymethod#</cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.teaser") and stobj.teaser neq "">
					<tr>
						<td valign="top"><strong>Teaser:</strong></td>
						<td><cfoutput>#stobjDraft.teaser#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.thumbnailimagepath") and stobjDraft.thumbnailimagepath neq "">
					<tr>
						<td valign="top"><strong>Thumbnail:</strong></td>
						<td><cfoutput><img src="#application.url.webroot#/images/#stobjDraft.thumbnail#" border="0"></Cfoutput></td>
					</tr>
					</cfif>
					<cfif iDeveloperPermission eq 1>
					<tr>
						<td>
							<strong>ObjectID</strong>
						</td>
						<td>
							<cfoutput>#stobjDraft.objectid#</cfoutput>
						</td>
					</tr>
					</cfif>
					
					</table>
				</td>
				<td width="50%" valign="top">
					<!--- column 2 - what to do now --->
					<table cellpadding="5" cellspacing="0" border="0">
					<tr>
						<td>
							<!--- get navigation parent for permission checks --->
							<nj:getNavigation 
								objectId="#stObj.ObjectID#"
								r_objectId="ParentID"
								r_stObject="stParent"
								bInclusive="1">
								
							<cfoutput>
							
							<strong>Edit/Change Status</strong><Br>
							<!--- work out different options depending on object status --->
							<cfscript>
								iEdit = oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="edit");
								iRequest = oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="RequestApproval");
								iApprove = oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="Approve");
								iApproveOwn = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="CanApproveOwnContent"); 	
								if(iApproveOwn EQ 1 AND NOT stObjDraft.lastUpdatedBy IS stUser.userLogin)
									iApproveOwn = 0;
							</cfscript>
							<cfswitch expression="#stobjDraft.status#">
								
								<cfcase value="draft">
									<!--- check user can edit --->
																	
									<Cfif iEdit eq 1>
										
										<script>
											function confirmRestore(navid,draftObjectID)
											{
												confirmmsg = "This will restore the current live objects data to this draft. The draft content will be replaced and any changes you have made lost. ";
												confirmmsg = confirmmsg + "\nAre you sure you wish to do this?";
												if(confirm(confirmmsg))
												{
													strURL = "#application.url.farcry#/navajo/restoreDraft.cfm";
													strURL = strURL + "?navid=" + navid + "&objectid=" + draftObjectID;
													if( document.all )
														document.idServer.location = strURL;
													else if(document.getElementById)
														document.getElementById("idServer").contentDocument.location = strURL;
													else if( document.layers )
														document.idServer.src = strURL;
													return true;	
												}
												else
													return false;	
												
											}
											
											function restoreResult(msg)
											{
												alert(msg);
												return true;
											}
											
										</script>
										<span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stobjDraft.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">Edit this object</a><BR>
										<span class="frameMenuBullet">&raquo;</span> <a onclick="confirmRestore('#parentid#','#stobjDraft.objectid#');" href="javascript:void(0);">Restore live object over this draft</a><BR>																									
									</Cfif>
									
									<!--- Check user can request approval --->
									<cfif iRequest eq 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=requestapproval" class="frameMenuItem">Request Approval</a><br></cfoutput>
									</cfif>
									
									<!--- check user can approve object --->
									<cfif iApprove eq 1 OR iApproveOwn EQ 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=approved" class="frameMenuItem">Send object Live</a><br></cfoutput>
									</cfif>
								</cfcase>
								
								<cfcase value="pending">
									<!--- check user can approve object --->
								
									<cfif iApprove eq 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=approved" class="frameMenuItem">Send object Live</a><br></cfoutput>
										<!--- send back to draft --->
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=draft" class="frameMenuItem">Send object back to draft</a><br></cfoutput>
									</cfif>
								</cfcase>
															
							</cfswitch>
							
							<br><strong>General</strong><Br>
							<!--- preview object --->
							<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.webroot#/index.cfm?objectid=#stobjDraft.objectid#&flushcache=1&showdraft=1" class="frameMenuItem" target="_blank">Preview</a><br></cfoutput>
												
							<!--- ### general options not type related ### --->
							<!--- add comments --->
							<span class="frameMenuBullet">&raquo;</span> <a href="navajo/commentOnContent.cfm?objectid=#stobjDraft.objectid#">Add Comments</a><BR>
	                        <!--- view comments --->
	                        <span class="frameMenuBullet">&raquo;</span> <a href="##" onClick="commWin=window.open('#application.url.farcry#/navajo/viewComments.cfm?objectid=#stobjDraft.objectid#', 'commWin', 'width=400,height=450');commWin.focus();">View Comments</a><BR>
							
							<!--- check user can dump --->
							<cfscript>
								iObjectDumpTab = oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="ObjectDumpTab");
								iDelete = oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="delete");
							</cfscript>
			
							<cfif iObjectDumpTab eq 1>
								<span class="frameMenuBullet">&raquo;</span> <a href="edittabDump.cfm?objectid=#stobjDraft.objectid#">Dump</a><BR>
							</cfif>
							
							<!--- check user can delete --->
			
							<cfif iDelete eq 1>
								<span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stobj.objectid#&deleteDraftObjectID=#stobjDraft.ObjectID#" onClick="return confirm('Are you sure you wish to delete this object?');">Delete this draft version</a><BR>
							</cfif>
							

		
													
							</cfoutput>
							
						</td>
					</tr>
					</table>
				</td>
			</tr>
			</table>
	
		</cfif>

	</cfif>
		
	<!--- main table --->
	<table cellpadding="5" cellspacing="0" border="1" style="margin-top:10px" width="95%" align="center">
	<tr class="dataheader">
		<td>Overview</td>
		<td>What would you like to do now?</td>
	</tr>
	<tr class="overview<cfoutput>#stobj.status#</cfoutput>">
		<td width="50%" valign="top">
			<!--- column 1 - overview --->
			<table cellpadding="5" cellspacing="0" border="0">
			<tr>
				<td width="100"><strong>Object Title:</strong></td>
				<td>
					<cfif stobj.title neq "">
						<Cfoutput>#stobj.title#</Cfoutput>
					<cfelse>
						<i>undefined</i>
					</cfif></td>
			</tr>
			<tr>
				<td><strong>Created by:</strong></td>
				<td><Cfoutput>#stobj.createdby#</Cfoutput></tdC>
			</tr>
			<tr>
				<td><strong>Date Created:</strong></td>
				<td><Cfoutput>#dateformat(stobj.datetimecreated)#</Cfoutput></td>
			</tr>
			<tr>
				<td><strong>Locking:</strong></td>
				<td>
					<cfif stObj.locked and stObj.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
						<!--- locked by current user --->				
						<cfoutput><span style="color:red">Locked (#dateFormat(stObj.dateTimeLastUpdated,"dd-mmm-yy")# #timeformat(stObj.dateTimeLastUpdated, "hh:mm")#)</span> <a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[UnLock]</a></cfoutput>
					
					<cfelseif stObj.locked>
						<!--- locked by another user --->
						<cfoutput><span style="color:red">Locked (#dateFormat(stObj.dateTimeLastUpdated,"dd-mmm-yy")# #timeformat(stObj.dateTimeLastUpdated, "hh:mm")#)</span> by #stobj.lockedby#</cfoutput>
						<cfscript>
							iDeveloperPermission = oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="Developer");
						</cfscript>		
						<!--- check if current user is a sysadmin so they can unlock --->
						<cfif iDeveloperPermission eq 1>
							<!--- show link to unlock --->
							 <cfoutput><a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[UnLock]</a></cfoutput>
						</cfif>
					
					<cfelse>
						<!--- no locking --->
						<cfoutput>Unlocked</cfoutput>
					</cfif>
				</td>
			</tr>
			<cfif IsDefined("stobj.displaymethod")>
			<tr>
				<td><strong>Last Updated:</strong></td>
				<td><Cfoutput>#dateformat(stobj.datetimelastupdated)#</Cfoutput></td>
			</tr>
			</cfif>
			<cfif IsDefined("stobj.displaymethod")>
			<tr>
				<td><strong>Last Updated By:</strong></td>
				<td><Cfoutput>#stobj.lastupdatedby#</Cfoutput></td>
			</tr>
			</cfif>
			<cfif IsDefined("stobj.displaymethod")>
			<tr>
				<td><strong>Current Status:</strong></td>
				<td><Cfoutput>#stobj.status#</Cfoutput></td>
			</tr>
			</cfif>
			<cfif IsDefined("stobj.displaymethod")>
			
			<tr>
				<td><strong>Template:</strong></td>
				<td><cfoutput>#stobj.displaymethod#</cfoutput></td>
			</tr>
			</cfif>
			<cfif IsDefined("stobj.teaser") and stobj.teaser neq "">
			<tr>
				<td valign="top"><strong>Teaser:</strong></td>
				<td><cfoutput>#stobj.teaser#</Cfoutput></td>
			</tr>
			</cfif>
			<cfif IsDefined("stobj.thumbnailimagepath") and stobj.thumbnailimagepath neq "">
			<tr>
				<td valign="top"><strong>Thumbnail:</strong></td>
				<td><cfoutput><img src="#application.url.webroot#/images/#stobj.thumbnail#" border="0"></Cfoutput></td>
			</tr>
			</cfif>
			
			<cfif iDeveloperPermission eq 1>
			<tr>
				<td>
					<strong>ObjectID</strong>
				</td>
				<td>
					<cfoutput>#stObj.objectid#</cfoutput>
				</td>
			</tr>
			</cfif>
			<cfif stObj.typename IS "dmNavigation" AND iDeveloperPermission eq 1 >
			<tr>
				<td>
					<strong>Nav Alias</strong>
				</td>
				<td>
					<cfif len(stObj.LNAVIDALIAS)>
						<cfoutput>#stObj.LNAVIDALIAS#</cfoutput>
					<cfelse>
						None Specified
					</cfif>
				</td>
			</tr>
			</cfif>
			</table>
		</td>
		<td width="50%" valign="top">
			<!--- column 2 - what to do now --->
			<table cellpadding="5" cellspacing="0" border="0">
			<tr>
				<td>
					<!--- get navigation parent for permission checks --->
					<nj:getNavigation 
						objectId="#stObj.ObjectID#"
						r_objectId="ParentID"
						r_stObject="stParent"
						bInclusive="1">
						
					<!--- get type specific overview options --->
					<cftry>
						<cfscript>
							overviewHTML = renderOverview(stObj.objectid);
						</cfscript>
						<cfoutput>#overviewHTML#</cfoutput>
						<cfcatch>You need to create a renderOverview method for this <cfoutput>#stObj.typename#<p></p></cfoutput></cfcatch>
					</cftry>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	
	<!--- legend --->
	<div style="margin-left:30px;margin-top:15px">
		<strong>Legend</strong><p></p>
		<!--- draft --->
		<div class="overviewdraft" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="Draft"></div><div style="display:inline;height:15px;margin-left:5px;margin-right:20px;vertical-align:middle">Draft</div><p></p>
		<!--- pending approval --->
		<div class="overviewpending" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="Pending"></div><div style="display:inline;height:15px;margin-left:5px;margin-right:20px;vertical-align:middle">Pending Approval</div><p></p>
		<!--- approved --->
		<div class="overviewapproved" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="Approved"></div><div style="display:inline;height:15px;margin-left:5px;vertical-align:middle">Approved/Live</div>
	</div>
</cfsavecontent>