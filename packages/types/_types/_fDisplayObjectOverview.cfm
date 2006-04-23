<cfparam name="stObject.bAlwaysShowEdit" default="0">
<cfsavecontent variable="displayContent"><cfoutput>
	<div class="wizard-nav">
	<!--- work out different options depending on object status --->
	<cfif StructKeyExists(stObject,"status") AND stObject.status NEQ "">
		<cfswitch expression="#stObject.status#">
			<cfcase value="draft"> <!--- DRAFT STATUS --->
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1>
					<a href="edittabedit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].editObj#</a><br /><cfif stObject.objectid NEQ stObject.objectid_previousversion>
					<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].restoreLiveObj#</a><br /></cfif>
				</cfif>
	
				<!--- Check user can request approval --->
				<cfif stPermissions.iRequest eq 1>
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=requestapproval">#application.adminBundle[session.dmProfile.locale].requestApproval#</a><br />
					<cfelse>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=requestapproval">#application.adminBundle[session.dmProfile.locale].requestObjApproval#</a><br />
					</cfif>
				</cfif>
	
				<!--- check user can approve object --->
				<cfif stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1>
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br />
					<cfelse>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#application.adminBundle[session.dmProfile.locale].approveObjYourself#</a><br />
					</cfif>
				</cfif>
	
				<!--- delete draft veresion --->
				<cfif stPermissions.iDelete eq 1> <!--- delete object --->
						<cfif stObject.objectid EQ stObject.objectid_previousversion>
							<cfif listContains(application.navid.home,stObject.objectid) EQ 0 AND listContains(application.navid.root,stObject.objectid) eq 0>
							<!--- check user can delete --->
								<cfif stPermissions.iDelete eq 1>
							<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].delete#</a><br />
								</cfif>
										
								<!--- check user can move to trash and is a navigation obj--->
								<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
							<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmTrashObj#');">#application.adminBundle[session.dmProfile.locale].sendToTrash#</a><br />
								</cfif>
							</cfif>
						<cfelse>
							<a href="edittabEdit.cfm?objectid=#stObject.objectID_PreviousVersion#&deleteDraftObjectID=#stObject.ObjectID#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].deleteDraftVersion#</a><br />
						</cfif>
				</cfif>
			</cfcase>
		
			<cfcase value="pending"> <!--- PENDING STATUS --->
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1 AND stObject.bAlwaysShowEdit EQ 1>
					<a href="edittabedit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].editObj#</a><br /><cfif stObject.objectid NEQ stObject.objectid_previousversion>
					<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].restoreLiveObj#</a><br /></cfif>
				</cfif>
				
				<cfif stPermissions.iApprove eq 1> <!--- check user can approve object --->
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#application.adminBundle[session.dmProfile.locale].sendObjLive#</a><br />
							<!--- send back to draft --->
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=draft">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a><br />
				</cfif>
			</cfcase>
	
			<cfcase value="approved">	
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1 AND stObject.bAlwaysShowEdit EQ 1>
					<a href="edittabedit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].editObj#</a><br /><cfif stObject.objectid NEQ stObject.objectid_previousversion>
					<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#application.adminBundle[session.dmProfile.locale].restoreLiveObj#</a><br /></cfif>
				</cfif>
				
				<!--- check if draft version exists --->
				<cfset bDraftVersionAllowed = StructKeyExists(stObject,"versionid")>
				<cfif stObject.bHasDraft EQ 0 AND stPermissions.iEdit eq 1 AND bDraftVersionAllowed>
					<a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stObject.objectID#">#application.adminBundle[session.dmProfile.locale].createEditableDraft#</a><br />
				</cfif>
				<cfif stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1>
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=draft">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#<cfif structKeyExists(stObject,"versionID") AND stObject.bHasDraft> #application.adminBundle[session.dmProfile.locale].deletingDraftVersion#</cfif></a><br />
				</cfif>
	
				<cfif listContains(application.navid.home,stObject.objectid) EQ 0 AND listContains(application.navid.root,stObject.objectid) eq 0>
					<!--- check user can delete --->
					<cfif stPermissions.iDelete eq 1>
						<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].delete#</a><br />
					</cfif>
					
					<!--- check user can move to trash and is dmNavigation type--->
					<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
						<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmTrashObj#');">#application.adminBundle[session.dmProfile.locale].sendToTrash#</a><br />
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	<cfelse>	<!--- content items without a status --->
		<!--- check user can edit --->
		<cfif stPermissions.iEdit EQ 1>
				<a href="edittabedit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].editObj#</a><br />
		</cfif>
		
		<!--- check user can delete --->
		<cfif stPermissions.iDelete eq 1>
			<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].delete#</a><br />
		</cfif>
		<!--- check user can move to trash and is dmNavigation type--->
		<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
			<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmTrashObj#');">#application.adminBundle[session.dmProfile.locale].sendToTrash#</a><br />
		</cfif>
	</cfif>
	
	<!--- create child objects --->
	<cfif StructKeyExists(stPermissions,"iCreate")>
		<cfset objType = CreateObject("component","#Application.types[stObject.typename].typepath#")>
		<cfset lPreferredTypeSeq = "dmNavigation,dmHTML"> <!--- this list will determine preffered order of objects in create menu - maybe this should be configurable. --->
		<!--- <cfset aTypesUseInTree = objType.buildTreeCreateTypes(lPreferredTypeSeq)> --->
		<cfset lAllTypes = structKeyList(application.types)>
		<!--- remove preffered types from *all* list --->
		<cfset aPreferredTypeSeq = listToArray(lPreferredTypeSeq)>
		<cfloop index="i" from="1" to="#arrayLen(aPreferredTypeSeq)#">
			<cfset lAlltypes = listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]))>
		</cfloop>
		<cfset lAlltypes = ListAppend(lPreferredTypeSeq,lAlltypes)>
		<cfset aTypesUseInTree = objType.buildTreeCreateTypes(lAllTypes)>
		<cfloop index="i" from="1" to="#ArrayLen(aTypesUseInTree)#">
	<a href="#application.url.farcry#/navajo/createObject.cfm?objectId=#stObject.objectid#&typename=#aTypesUseInTree[i].typename#">Create #aTypesUseInTree[i].description#</a><br />
		</cfloop>	
	</cfif>

	<!--- preview object --->
	<a href="#application.url.webroot#/index.cfm?objectid=#stObject.objectid#&flushcache=1&showdraft=1" target="_winPreview">#application.adminBundle[session.dmProfile.locale].preview#</a><br />
								
	</div><cfset tIconName = LCase(Right(stObject.typename,len(stObject.typename)-2))><cfoutput>
	<img src="#application.url.farcry#/images/icons/#tIconName#.png" alt="alt text" class="icon" /></cfoutput>
	
	<dl class="dl-style1">
	<dt>#application.adminBundle[session.dmProfile.locale].objTitleLabel#</dt>
	<dd><cfif stObject.label NEQ "">
		#stObject.label#<cfelse>
		<i>#application.adminBundle[session.dmProfile.locale].undefined#</i></cfif>
	</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].objTypeLabel#</dt>
	<dd><cfif structKeyExists(application.types[stObject.typename],"displayname")>
		#application.types[stObject.typename].displayname#<cfelse>
		#stObject.typename#</cfif>
	</dd><cfif StructKeyExists(stObject,"lnavidalias")>
	<dt>Navigation Alias(es):</dt>
	<dd>#stObject.lnavidalias#</dd></cfif>
	<dt>#application.adminBundle[session.dmProfile.locale].createdByLabel#</dt>
	<dd>#stObject.createdby#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].dateCreatedLabel#</dt>
	<dd>#application.thisCalendar.i18nDateFormat(stObject.datetimecreated,session.dmProfile.locale,application.shortF)#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].lockingLabel#</dt>
	<dd><cfif stObject.locked and stObject.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
			<!--- locked by current user --->
			<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stObject.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
		<span style="color:red">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].locked,tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stObject.objectid#&typename=#stObject.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a>
		<cfelseif stObject.locked>
			<!--- locked by another user --->
			<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stObject.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stObject.lockedby#')>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].lockedBy,subS)#
			<!--- check if current user is a sysadmin so they can unlock --->
			<cfif stPermissions.iDeveloperPermission eq 1><!--- show link to unlock --->
			<a href="navajo/unlock.cfm?objectid=#stObject.objectid#&typename=#stObject.typename#">[#application.adminBundle[session.dmProfile.locale].unlockUC#]</a>
			</cfif><cfelse><!--- no locking --->
			#application.adminBundle[session.dmProfile.locale].unlocked#</cfif>
	</dd><cfif IsDefined("stObject.displaymethod")>
	<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedLabel#</dt>
	<dd>#application.thisCalendar.i18nDateFormat(stObject.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedByLabel#</dt>
	<dd>#stObject.lastupdatedby#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].currentStatusLabel#</dt>
	<dd>#stObject.status#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].templateLabel#</dt>
	<dd>#stObject.displaymethod#</dd></cfif><cfif IsDefined("stObject.teaser")>
	<dt>#application.adminBundle[session.dmProfile.locale].teaserLabel#</dt>
	<dd>#stObject.teaser#</dd></cfif><cfif IsDefined("stObject.thumbnailimagepath") AND stObject.thumbnailimagepath NEQ "">
	<dt>#application.adminBundle[session.dmProfile.locale].thumbnailLabel#</dt>
	<dd><img src="#application.url.webroot#/images/#stObject.thumbnail#"></dd></cfif><cfif stPermissions.iDeveloperPermission eq 1>
	<dt>ObjectID</dt>
	<dd>#stObject.objectid#</dd></cfif>
	</dl>
	<hr />
	<ul>

<!--- check user can edit Friendly URLs --->
<cfif stPermissions.iEdit EQ 1 AND Application.config.plugins.fu AND StructKeyExists(stObject,"qListFriendlyURL")>
		<li><a href="##" onclick="return toggleDocumentItem('tgl_CurrentFriendlyURL_#stObject.objectid#');">Show Current Friendly URL</a> <a href="##" onclick="window.open('#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stObject.objectid#','_win_friendlyurl','height=500,width=600,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=no,status=yes').focus();">[Manage]</a><br />
			<span id="tgl_CurrentFriendlyURL_#stObject.objectid#" style="display:none;"><cfloop query="stObject.qListFriendlyURL">
			#stObject.qListFriendlyURL.friendlyURL#<br /></cfloop>
			</span>
		</li>
</cfif>
	<!--- view statistics --->
	<li><a href="#application.url.farcry#/editTabStats.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].stats#</a></li>

	<!--- view audit --->
	<li><a href="#application.url.farcry#/editTabAudit.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].audit#</a></li>
	
<cfif StructKeyExists(stObject,"commentLog")>
		<!--- add comments --->
		<li><a href="navajo/commentOnContent.cfm?objectid=#stObject.objectid#">#application.adminBundle[session.dmProfile.locale].addComments#</a></li>
	<cfif Trim(stObject.commentLog) NEQ "">
		<!--- view comments --->
		<li><a href="##" onclick="return toggleDocumentItem('tgl_viewcomment_#stObject.objectid#');" target="_blank">#application.adminBundle[session.dmProfile.locale].viewComments#</a></li>
		<li id="tgl_viewcomment_#stObject.objectid#" style="display:none;">#ReplaceNoCase(Trim(stObject.commentLog),"#chr(10)##chr(13)#","<br />")#</li>
	</cfif>		
</cfif>
<cfif stPermissions.iObjectDumpTab>
		<!--- dump content --->
		<li><a href="#application.url.farcry#/object_dump.cfm?objectid=#stObject.objectid#" title="view object properties" target="_win_dumpObject">#application.adminBundle[session.dmProfile.locale].dump#</a></li>
		<!--- <li id="tgl_dumpobject_#stObject.objectid#" style="display:none;"><cfdump var="#stObject#"></li> --->
</cfif>
		<cfif (stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1) AND StructKeyExists(stObject,"versionid")>
		<!--- rollback content --->
		<li><a href="#application.url.farcry#/archive.cfm?objectid=#stObject.objectid#" target="_self">Show Archive</a></li></cfif>
	</ul></cfoutput>

</cfsavecontent>