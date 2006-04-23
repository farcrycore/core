<!--- check if underlying draft version, need to get details of approved object --->

<cfprocessingDirective pageencoding="utf-8">

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
		synchTitle('Overview');
		synchTabLinks('site','<cfoutput>#stObj.objectid#</cfoutput>');
	</script>
	<cfscript>
		oAuthorisation = request.dmSec.oAuthorisation;
		iDeveloperPermission = oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
	</cfscript>
			
	<div class="FormTitle"><Cfoutput>#stobj.label#</Cfoutput></div>
	<!--- ### check if underlying draft object ### --->
	<cfif structKeyExists(stObj,"versionID") and structKeyExists(stObj,"status") and stobj.status eq "approved">
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
				<td><cfoutput>#application.adminBundle[session.dmProfile.locale].draftObjOverview#</cfoutput></td>
				<td><cfoutput>#application.adminBundle[session.dmProfile.locale].whatNow#</cfoutput></td>
			</tr>
			<tr class="overview<cfoutput>#stobjDraft.status#</cfoutput>">
				<td width="50%" valign="top">
					<!--- column 1 - overview --->
					<table cellpadding="5" cellspacing="0" border="0">
					<tr>
						<td width="100"><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].objTitleLabel#</cfoutput></strong></td>
						<td>
							<cfif stobjDraft.label neq "">
								<Cfoutput>#stobjDraft.label#</Cfoutput>
							<cfelse>
								<i><cfoutput>#application.adminBundle[session.dmProfile.locale].undefined#</cfoutput></i>
							</cfif></td>
					</tr>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].objTypeLabel#</cfoutput></strong></td>
						<td>
							<cfif structKeyExists(application.types[stobjDraft.typename],"displayname")>
								<Cfoutput>#application.types[stobjDraft.typename].displayname#</Cfoutput>
							<cfelse>
								<Cfoutput>#stobjDraft.typename#</Cfoutput>
							</cfif>
						</td>
					</tr>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].createdByLabel#</cfoutput></strong></td>
						<td><Cfoutput>#stobjDraft.createdby#</Cfoutput></td>
					</tr>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].dateCreatedLabel#</cfoutput></strong></td>
						<td><Cfoutput>#application.thisCalendar.i18nDateFormat(stobjDraft.datetimecreated,session.dmProfile.locale,application.shortF)#</Cfoutput></td>
					</tr>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].lockingLabel#</cfoutput></strong></td>
						<td>
							<cfif stobjDraft.locked and stobjDraft.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
								<!--- locked by current user --->
								<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobjDraft.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>												
								<cfoutput><span style="color:red">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].locked,tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stobjDraft.objectid#&typename=#stobjDraft.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a></cfoutput>
							<cfelseif stobjDraft.locked>
								<!--- locked by another user --->
								<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobjDraft.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobjDraft.lockedby#')>
								<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].lockedBy,subS)#</cfoutput>
								<!--- check if current user is a sysadmin so they can unlock --->
								
								<cfif iDeveloperPermission eq 1>
									<!--- show link to unlock --->
									 <cfoutput><a href="navajo/unlock.cfm?objectid=#stobjDraft.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unlockUC#]</a></cfoutput>
								</cfif>
							
							<cfelse>
								<!--- no locking --->
								<cfoutput>#application.adminBundle[session.dmProfile.locale].unlocked#</cfoutput>
							</cfif>
						</td>
					</tr>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].lastUpdatedLabel#</cfoutput></strong></td>
						<td><Cfoutput>#application.thisCalendar.i18nDateFormat(stobjDraft.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].lastUpdatedByLabel#</cfoutput></strong></td>
						<td><Cfoutput>#stobjDraft.lastupdatedby#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].currentStatusLabel#</cfoutput></strong></td>
						<td><Cfoutput>#stobjDraft.status#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.displaymethod")>
					
					<tr>
						<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].templateLabel#</cfoutput></strong></td>
						<td><cfoutput>#stobjDraft.displaymethod#</cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.teaser") and stobj.teaser neq "">
					<tr>
						<td valign="top"><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].teaserLabel#</cfoutput></strong></td>
						<td><cfoutput>#stobjDraft.teaser#</Cfoutput></td>
					</tr>
					</cfif>
					<cfif IsDefined("stobjDraft.thumbnailimagepath") and stobjDraft.thumbnailimagepath neq "">
					<tr>
						<td valign="top"><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].thumbnailLabel#</cfoutput></strong></td>
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
							
							<strong>#application.adminBundle[session.dmProfile.locale].changeStatus#</strong><Br>
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
												confirmmsg = "#application.adminBundle[session.dmProfile.locale].confirmRestoreLiveObjToDraft#";
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
										<span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stobjDraft.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.adminBundle[session.dmProfile.locale].editObj#</a><BR>
										<span class="frameMenuBullet">&raquo;</span> <a onclick="confirmRestore('#parentid#','#stobjDraft.objectid#');" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].restoreLiveObj#</a><BR>																									
									</Cfif>
									
									<!--- Check user can request approval --->
									<cfif iRequest eq 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=requestapproval" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].requestApproval#</a><br></cfoutput>
									</cfif>
									
									<!--- check user can approve object --->
									<cfif iApprove eq 1 OR iApproveOwn EQ 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=approved" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br></cfoutput>
									</cfif>
								</cfcase>
								
								<cfcase value="pending">
									<!--- check user can approve object --->
								
									<cfif iApprove eq 1>
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=approved" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br></cfoutput>
										<!--- send back to draft --->
										<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stobjDraft.objectid#&status=draft" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a><br></cfoutput>
									</cfif>
								</cfcase>
															
							</cfswitch>
							
							<br><strong>#application.adminBundle[session.dmProfile.locale].general#</strong><Br>
							<!--- preview object --->
							<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.webroot#/index.cfm?objectid=#stobjDraft.objectid#&flushcache=1&showdraft=1" class="frameMenuItem" target="_blank">#application.adminBundle[session.dmProfile.locale].preview#</a><br></cfoutput>
												
							<!--- ### general options not type related ### --->
							<!--- add comments --->
							<span class="frameMenuBullet">&raquo;</span> <a href="navajo/commentOnContent.cfm?objectid=#stobjDraft.objectid#">#application.adminBundle[session.dmProfile.locale].addComments#</a><BR>
	                        <!--- view comments --->
	                        <span class="frameMenuBullet">&raquo;</span> <a href="##" onClick="commWin=window.open('#application.url.farcry#/navajo/viewComments.cfm?objectid=#stobjDraft.objectid#', 'commWin', 'width=400,height=450');commWin.focus();">#application.adminBundle[session.dmProfile.locale].viewComments#</a><BR>
							
							<!--- check user can dump --->
							<cfscript>
								iObjectDumpTab = oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="ObjectDumpTab");
								iDelete = oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="delete");
							</cfscript>
			
							<cfif iObjectDumpTab eq 1>
								<span class="frameMenuBullet">&raquo;</span> <a href="edittabDump.cfm?objectid=#stobjDraft.objectid#">#application.adminBundle[session.dmProfile.locale].dump#</a><BR>
							</cfif>
							
							<!--- check user can delete --->
			
							<cfif iDelete eq 1>
								<span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stobj.objectid#&deleteDraftObjectID=#stobjDraft.ObjectID#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].deleteDraftVersion#</a><BR>
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
	<cfoutput>	
		<td>#application.adminBundle[session.dmProfile.locale].overview#</td>
		<td>#application.adminBundle[session.dmProfile.locale].whatNow#</td>
	</cfoutput>		
	</tr>
	<cfoutput>
	<tr class="overview<cfif isdefined("stObj.status")>#stobj.status#<cfelse>approved</cfif>">
	</cfoutput>
		<td width="50%" valign="top">
			<!--- column 1 - overview --->
			<table cellpadding="5" cellspacing="0" border="0">
			<tr>
				<td width="100"><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].objTitleLabel#</cfoutput></strong></td>
				<td>
					<cfif stobj.label neq "">
						<Cfoutput>#stobj.label#</Cfoutput>
					<cfelse>
						<i><cfoutput>#application.adminBundle[session.dmProfile.locale].undefined#</cfoutput></i>
					</cfif></td>
			</tr>
			<tr>
				<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].objTypeLabel#</cfoutput></strong></td>
				<td>
					<cfif structKeyExists(application.types[stobj.typename],"displayname")>
						<Cfoutput>#application.types[stobj.typename].displayname#</Cfoutput>
					<cfelse>
						<Cfoutput>#stobj.typename#</Cfoutput>
					</cfif>
				</td>
			</tr>
			<tr>
				<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].createdByLabel#</cfoutput></strong></td>
				<td><Cfoutput>#stobj.createdby#</Cfoutput></td>
			</tr>
			<tr>
				<td><strong><cfoutput>#application.adminBundle[session.dmProfile.locale].dateCreatedLabel#</cfoutput></strong></td>
				<td><Cfoutput>#application.thisCalendar.i18nDateFormat(stobj.datetimecreated,session.dmProfile.locale,application.mediumF)#</Cfoutput></td>
			</tr>
			<tr>
				<td><cfoutput><strong>#application.adminBundle[session.dmProfile.locale].lockingLabel#</strong></cfoutput></td>
				<td>
					<cfif stObj.locked and stObj.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
						<!--- locked by current user --->
						<cfset tDT=application.thisCalendar.i18nDateFormat(stObj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>				
						<cfoutput><span style="color:red">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].locked,tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a></cfoutput>
					
					<cfelseif stObj.locked>
						<!--- locked by another user --->
						<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stObj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>									
						<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].lockedBy,subS)#</cfoutput>
						<cfscript>
							iDeveloperPermission = oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="Developer");
						</cfscript>		
						<!--- check if current user is a sysadmin so they can unlock --->
						<cfif iDeveloperPermission eq 1>
							<!--- show link to unlock --->
							 <cfoutput><a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a></cfoutput>
						</cfif>
					
					<cfelse>
						<!--- no locking --->
						<cfoutput>#application.adminBundle[session.dmProfile.locale].Unlocked#</cfoutput>
					</cfif>
				</td>
			</tr>
			<cfif IsDefined("stobj.datetimelastupdated")>
			<tr>
			<cfoutput>
				<td><strong>#application.adminBundle[session.dmProfile.locale].lastUpdatedLabel#</strong></td>
				<td>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</td>
			</cfoutput>	
			</tr>
			</cfif>
			<cfif IsDefined("stobj.lastupdatedby")>
			<tr>
			<cfoutput>
				<td><strong>#application.adminBundle[session.dmProfile.locale].lastUpdatedByLabel#</strong></td>
				<td>#stobj.lastupdatedby#</td>
			</cfoutput>	
			</tr>
			</cfif>
			<cfif IsDefined("stobj.status")>
			<tr>
			<cfoutput>
				<td><strong>#application.adminBundle[session.dmProfile.locale].currentStatusLabel#</strong></td>
				<td>#stobj.status#</td>
			</cfoutput>	
			</tr>
			</cfif>
			<cfif IsDefined("stobj.displaymethod")>
			<tr>
			<cfoutput>
				<td><strong>#application.adminBundle[session.dmProfile.locale].templateLabel#</strong></td>
				<td>#stobj.displaymethod#</td>
			</cfoutput>	
			</tr>
			</cfif>
			<cfif IsDefined("stobj.teaser") and stobj.teaser neq "">
			<tr>
			<cfoutput>
				<td valign="top"><strong>#application.adminBundle[session.dmProfile.locale].teaserLabel#</strong></td>
				<td>#stobj.teaser#</td>
			</cfoutput>	
			</tr>
			</cfif>
			<cfif IsDefined("stobj.thumbnailimagepath") and stobj.thumbnailimagepath neq "">
			<tr>
			<cfoutput>
				<td valign="top"><strong>#application.adminBundle[session.dmProfile.locale].thumbnailLabel#</strong></td>
				<td><img src="#application.url.webroot#/images/#stobj.thumbnail#" border="0"></td>
			</cfoutput>	
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
					<strong><cfoutput>#application.adminBundle[session.dmProfile.locale].navAlias#</cfoutput></strong>
				</td>
				<td>
					<cfif len(stObj.LNAVIDALIAS)>
						<cfoutput>#stObj.LNAVIDALIAS#</cfoutput>
					<cfelse>
						<cfoutput>#application.adminBundle[session.dmProfile.locale].noneSpecified#</cfoutput>
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
						<cfcatch>
							<cfoutput>
							#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].noRenderOverviewMethod,'#stObj.typename#')#
							</cfoutput>
						</cfcatch>
					</cftry>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	
	<!--- legend --->
<cfoutput>	
	<div style="margin-left:30px;margin-top:15px">
		<strong>#application.adminBundle[session.dmProfile.locale].legend#</strong><p></p>
		<!--- draft --->
		<div class="overviewdraft" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="#application.adminBundle[session.dmProfile.locale].draft#"></div><div style="display:inline;height:15px;margin-left:5px;margin-right:20px;vertical-align:middle">#application.adminBundle[session.dmProfile.locale].draft#</div><p></p>
		<!--- pending approval --->
		<div class="overviewpending" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="#application.adminBundle[session.dmProfile.locale].Pending#"></div><div style="display:inline;height:15px;margin-left:5px;margin-right:20px;vertical-align:middle">#application.adminBundle[session.dmProfile.locale].pendingApproval#</div><p></p>
		<!--- approved --->
		<div class="overviewapproved" style="border:solid black thin;display:inline;"><img src="images/shim.gif" border="0" height="13" width="13" alt="#application.adminBundle[session.dmProfile.locale].approved#"></div><div style="display:inline;height:15px;margin-left:5px;vertical-align:middle">#application.adminBundle[session.dmProfile.locale].approvedLive#</div>
	</div>
	</cfoutput>
</cfsavecontent>