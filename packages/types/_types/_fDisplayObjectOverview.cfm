
<cfparam name="stObject.bAlwaysShowEdit" default="0">

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfsavecontent variable="displayContent"><cfoutput>
	<div class="wizard-nav">
	<!--- work out different options depending on object status --->
	<cfif StructKeyExists(stObject,"status") AND stObject.status NEQ "">
		<cfswitch expression="#stObject.status#">
			<cfcase value="draft"> <!--- DRAFT STATUS --->
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1>
					<!--- MJB: added url.ref so that the edit methods know they were initially called by the overview page and they can return here if they so desire. --->
					<a href="edittabEdit.cfm?objectid=#stObject.objectid#&ref=overview&typename=#stObject.typeName#">#apapplication.rb.getResource("editObj")#</a><br />
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#apapplication.rb.getResource("restoreLiveObj")#</a><br />
					</cfif>
				</cfif>
	
				<!--- Check user can request approval --->
				<cfif stPermissions.iRequest eq 1>
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=requestapproval">#apapplication.rb.getResource("requestApproval")#</a><br />
					<cfelse>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=requestapproval">#apapplication.rb.getResource("requestObjApproval")#</a><br />
					</cfif>
				</cfif>
	
				<!--- check user can approve object --->
				<cfif stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1>
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#apapplication.rb.getResource("sendObjLive")#</a><br />
					<cfelse>
						<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#apapplication.rb.getResource("approveObjYourself")#</a><br />
					</cfif>
				</cfif>
	
				<!--- delete draft veresion --->
				<cfif stPermissions.iDelete eq 1> <!--- delete object --->
						<cfif stObject.objectid EQ stObject.objectid_previousversion>
							<cfif listContains(application.navid.home,stObject.objectid) EQ 0 AND listContains(application.navid.root,stObject.objectid) eq 0>
							<!--- check user can delete --->
								<cfif stPermissions.iDelete eq 1>
									<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#" onClick="return confirm('#apapplication.rb.getResource("confirmDeleteObj")#');">#apapplication.rb.getResource("delete")#</a><br />
								</cfif>
										
								<!--- check user can move to trash and is a navigation obj--->
								<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
									<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#apapplication.rb.getResource("confirmTrashObj")#');">#apapplication.rb.getResource("sendToTrash")#</a><br />
								</cfif>
							</cfif>
						<cfelse>
							<a href="edittabEdit.cfm?objectid=#stObject.objectID_PreviousVersion#&deleteDraftObjectID=#stObject.ObjectID#&typename=#stObject.typeName#" onClick="return confirm('#apapplication.rb.getResource("confirmDeleteObj")#');">#apapplication.rb.getResource("deleteDraftVersion")#</a><br />
						</cfif>
				</cfif>
			</cfcase>
		
			<cfcase value="pending"> <!--- PENDING STATUS --->
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1 AND stObject.bAlwaysShowEdit EQ 1>
					<a href="edittabEdit.cfm?objectid=#stObject.objectid#&ref=overview&typename=#stObject.typeName#">#apapplication.rb.getResource("editObj")#</a><br />
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#apapplication.rb.getResource("restoreLiveObj")#</a><br />
					</cfif>
				</cfif>
				
				<cfif stPermissions.iApprove eq 1> <!--- check user can approve object --->
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=approved">#apapplication.rb.getResource("sendObjLive")#</a><br />
					<!--- send back to draft --->
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=draft">#apapplication.rb.getResource("sendBackToDraft")#</a><br />
				</cfif>
			</cfcase>
	
			<cfcase value="approved">	
				<!--- check user can edit --->
				<cfif stPermissions.iEdit EQ 1 AND stObject.bAlwaysShowEdit EQ 1>
					<a href="edittabEdit.cfm?objectid=#stObject.objectid#&ref=overview&typename=#stObject.typeName#">#apapplication.rb.getResource("editObj")#</a><br />
					<cfif stObject.objectid NEQ stObject.objectid_previousversion>
						<a onclick="confirmRestore('#stObject.parentid#','#stObject.objectid#');" href="javascript:void(0);">#apapplication.rb.getResource("restoreLiveObj")#</a><br />
					</cfif>
				</cfif>
				
				<!--- check if draft version exists --->
				<cfset bDraftVersionAllowed = StructKeyExists(stObject,"versionid")>
				<cfif stObject.bHasDraft EQ 0 AND stPermissions.iEdit eq 1 AND bDraftVersionAllowed>
					<a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stObject.objectID#&typename=#stObject.typeName#">#apapplication.rb.getResource("createEditableDraft")#</a><br />
				</cfif>
				<cfif stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1>
					<a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObject.objectid#&status=draft&typename=#stObject.typeName#">#apapplication.rb.getResource("sendBackToDraft")#<cfif structKeyExists(stObject,"versionID") AND stObject.bHasDraft> #apapplication.rb.getResource("deletingDraftVersion")#</cfif></a><br />
				</cfif>
	
				<cfif listContains(application.navid.home,stObject.objectid) EQ 0 AND listContains(application.navid.root,stObject.objectid) eq 0>
					<!--- check user can delete --->
					<cfif stPermissions.iDelete eq 1>
						<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#&typename=#stObject.typeName#" onClick="return confirm('#apapplication.rb.getResource("confirmDeleteObj")#');">#apapplication.rb.getResource("delete")#</a><br />
					</cfif>
					
					<!--- check user can move to trash and is dmNavigation type--->
					<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
						<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#apapplication.rb.getResource("confirmTrashObj")#');">#apapplication.rb.getResource("sendToTrash")#</a><br />
					</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	<cfelse>	<!--- content items without a status --->
		<!--- check user can edit --->
		<cfif stPermissions.iEdit EQ 1>
				<a href="edittabEdit.cfm?objectid=#stObject.objectid#&ref=overview&typename=#stObject.typeName#">#apapplication.rb.getResource("editObj")#</a><br />
		</cfif>
		
		<!--- check user can delete --->
		<cfif stPermissions.iDelete eq 1>
			<a href="navajo/delete.cfm?ObjectId=#stObject.objectId#&typename=#stObject.typeName#" onClick="return confirm('#apapplication.rb.getResource("confirmDeleteObj")#');">#apapplication.rb.getResource("delete")#</a><br />
		</cfif>
		<!--- check user can move to trash and is dmNavigation type--->
		<cfif stPermissions.iTreeSendToTrash eq 1 and stObject.typeName eq "dmNavigation">
			<a href="navajo/move.cfm?srcObjectId=#stObject.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#apapplication.rb.getResource("confirmTrashObj")#');">#apapplication.rb.getResource("sendToTrash")#</a><br />
		</cfif>
	</cfif>
	
	<!--- create child objects --->
	<cfif StructKeyExists(stPermissions,"iCreate") and stPermissions.iCreate eq 1>
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
	<a href="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stObject.objectid#&typename=#aTypesUseInTree[i].typename#">Create #aTypesUseInTree[i].description#</a><br />
		</cfloop>	
	</cfif>

	<!--- preview object --->
	<a href="#application.url.webroot#/index.cfm?objectid=#stObject.objectid#&flushcache=1&showdraft=1" target="_winPreview">#apapplication.rb.getResource("preview")#</a><br />
	
	</div>
	<cfset tIconName = LCase(Right(stObject.typename,len(stObject.typename)-2))>
    <cfif fileExists(expandPath('images/icons/#tIconName#.png'))>
        <cfoutput><img src="#application.url.farcry#/images/icons/#tIconName#.png" alt="alt text" class="icon" /></cfoutput>
    <cfelse>
        <cfoutput><img src="#application.url.farcry#/images/icons/custom.png" alt="alt text" class="icon" /></cfoutput>
    </cfif>
	
	
	<skin:view objectid="#stobject.objectid#" webskin="webtopOverviewSummary" />
	
	<ul class="object-overview-actions" style="border:1px solid red;">

<!--- check user can edit Friendly URLs --->
<cfif stPermissions.iEdit EQ 1 AND Application.config.plugins.fu AND StructKeyExists(stObject,"qListFriendlyURL")>
		<li><a href="##" onclick="return toggleDocumentItem('tgl_CurrentFriendlyURL_#stObject.objectid#');">Show Current Friendly URL</a> <a href="##" onclick="window.open('#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stObject.objectid#','_win_friendlyurl','height=500,width=600,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=no,status=yes').focus();">[Manage]</a><br />
			<span id="tgl_CurrentFriendlyURL_#stObject.objectid#" style="display:none;"><cfloop query="stObject.qListFriendlyURL">
			#stObject.qListFriendlyURL.friendlyURL#<br /></cfloop>
			</span>
		</li>
</cfif>
	<!--- view statistics --->
	<li><a href="#application.url.farcry#/edittabStats.cfm?objectid=#stObject.objectid#">#apapplication.rb.getResource("stats")#</a></li>

	<!--- view audit --->
	<li><a href="#application.url.farcry#/edittabAudit.cfm?objectid=#stObject.objectid#">#apapplication.rb.getResource("audit")#</a></li>
	
<cfif StructKeyExists(stObject,"commentLog")>
		<!--- add comments --->
		<li><a href="navajo/commentOnContent.cfm?objectid=#stObject.objectid#">#apapplication.rb.getResource("addComments")#</a></li>
	<cfif Trim(stObject.commentLog) NEQ "">
		<!--- view comments --->
		<li><a href="##" onclick="return toggleDocumentItem('tgl_viewcomment_#stObject.objectid#');" target="_blank">#apapplication.rb.getResource("viewComments")#</a></li>
		<li id="tgl_viewcomment_#stObject.objectid#" style="display:none;">#ReplaceNoCase(Trim(stObject.commentLog),"#chr(10)##chr(13)#","<br />")#</li>
	</cfif>		
</cfif>
<cfif stPermissions.iObjectDumpTab>
		<!--- dump content --->
		<li><a href="#application.url.farcry#/object_dump.cfm?objectid=#stObject.objectid#" title="view object properties" target="_win_dumpObject">#apapplication.rb.getResource("dump")#</a></li>
		<!--- <li id="tgl_dumpobject_#stObject.objectid#" style="display:none;"><cfdump var="#stObject#"></li> --->
</cfif>
		<cfif (stPermissions.iApprove eq 1 OR stPermissions.iApproveOwn EQ 1) AND StructKeyExists(stObject,"versionid")>
		<!--- rollback content --->
		<li><a href="#application.url.farcry#/archive.cfm?objectid=#stObject.objectid#" target="_self">Show Archive</a></li></cfif>
	</ul>
	
	<hr /></cfoutput>

</cfsavecontent>