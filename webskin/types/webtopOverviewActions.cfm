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


<!--- Add the extjs iframe dialog to the head --->
<extjs:iframeDialog />
			
<!------------------ 
START WEBSKIN
 ------------------>
<cfset stOverviewParams = structNew() />


<nj:getNavigation objectId="#stobj.objectid#" r_ObjectId="parentID" r_stObject="stParent" bInclusive="1">
<cfset stOverviewParams.parentID = parentID>
<cfset stOverviewParams.stParent = stParent>

<cfset stOverviewParams.objectID_PreviousVersion = stobj.objectID>
<!--- <cfif NOT StructKeyExists(stobj,"status")>
	<cfset stobj.status = "Approved">
</cfif> --->

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


<ft:form>


	<extjs:item title="#application.rb.getResource('workflow.headings.mainactions@text','Main Actions')#">
		
		<!--- work out different options depending on object status --->
		<cfif StructKeyExists(stobj,"status") AND stobj.status NEQ "">
			<cfswitch expression="#stobj.status#">
				<cfcase value="draft"> <!--- DRAFT STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1>
						<!--- MJB: added url.ref so that the edit methods know they were initially called by the overview page and they can return here if they so desire. --->
						<ft:button width="240px" size="large" color="orange" icon="#application.url.webtop#/images/crystal/32x32/actions/edit.png" iconPos="top" style="" value="Edit this content item" rbkey="workflow.buttons.edit" bInPanel="true" url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
		
					<!--- check user can approve object --->
					<cfif stOverviewParams.stPermissions.iApprove eq 1 OR stOverviewParams.stPermissions.iApproveOwn EQ 1>
						<cfif stobj.objectid NEQ stOverviewParams.objectid_previousversion>
							<ft:button width="240px" style="" value="Send content item live" rbkey="workflow.buttons.sendlive" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved" />		
						<cfelse>
							<ft:button width="240px" style="" value="Approve this item yourself" rbkey="workflow.buttons.approveyourself" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved" />
						</cfif>
					</cfif>

				</cfcase>
			
				<cfcase value="pending"> <!--- PENDING STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND stobj.bAlwaysShowEdit EQ 1>
						<ft:button width="240px" size="large" color="orange" icon="#application.url.webtop#/images/crystal/32x32/actions/edit.png" iconPos="top" style="" value="Edit this content item" rbkey="workflow.buttons.edit" bInPanel="true" url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
				</cfcase>
		
				<cfcase value="approved">	
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND (not structkeyexists(stObj,"versionid") or stobj.bAlwaysShowEdit EQ 1)>
						<ft:button width="240px" size="large" color="orange" icon="#application.url.webtop#/images/crystal/32x32/actions/edit.png" iconPos="top" style="" value="Edit this content item" rbkey="workflow.buttons.edit" bInPanel="true" url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
					</cfif>
					
					<!--- check if draft version exists --->
					<cfset bDraftVersionAllowed = StructKeyExists(stobj,"versionid")>
					<cfif bHasDraft EQ 0 AND stOverviewParams.stPermissions.iEdit eq 1 AND bDraftVersionAllowed>
						<ft:button width="240px" style="" value="Create an editable draft version" rbkey="workflow.buttons.createdraft" bInPanel="true" url="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stobj.objectID#&typename=#stobj.typeName#&ref=#url.ref#" />
					</cfif>
					<cfif stOverviewParams.stPermissions.iApprove eq 1 OR stOverviewParams.stPermissions.iApproveOwn EQ 1>
						<cfset buttonValue = application.rb.getResource("sendBackToDraft") />
						<cfif structKeyExists(stobj,"versionID") AND bHasDraft>
							<ft:button width="240px" style="" value="Send this content item back to draft (deleting the draft version)" rbkey="workflow.buttons.sendbacktodraftdeletedraft" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&typename=#stobj.typeName#&ref=#url.ref#" />
						<cfelse>
							<ft:button width="240px" style="" value="Send this content item back to draft" rbkey="workflow.buttons.sendbacktodraft" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&typename=#stobj.typeName#&ref=#url.ref#" />
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		<cfelse>	<!--- content items without a status --->
			<!--- check user can edit --->
			<cfif stOverviewParams.stPermissions.iEdit EQ 1>
				<ft:button width="240px" size="large" color="green" icon="#application.url.webtop#/images/crystal/32x32/actions/edit.png" iconPos="top" style="" value="Edit this content item" rbkey="workflow.buttons.edit" bInPanel="true" url="edittabEdit.cfm?objectid=#stobj.objectid#&ref=#url.ref#&typename=#stobj.typeName#" />
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
		<ft:button width="240px" style="" value="Preview" rbkey="workflow.buttons.preview" bInPanel="true" url="#application.url.webroot#/index.cfm?objectid=#stobj.objectid#&flushcache=1&showdraft=1" target="#target#" />
		
	</extjs:item>
	
	
	<extjs:item title="#application.rb.getResource('workflow.headings.approvalandworkflow@text','Approval & Work Flow')#">
	
		<!--- work out different options depending on object status --->
		<cfif StructKeyExists(stobj,"status") AND stobj.status NEQ "">
			<cfswitch expression="#stobj.status#">
				<cfcase value="draft"> <!--- DRAFT STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1>
						<!--- MJB: added url.ref so that the edit methods know they were initially called by the overview page and they can return here if they so desire. --->
						<cfif stobj.objectid NEQ stOverviewParams.objectid_previousversion>
							<ft:button width="240px" style="" value="Restore live content item over this draft" rbkey="workflow.buttons.restorelivecontent" bInPanel="true" onClick="confirmRestore('#stobj.parentid#','#stobj.objectid#');" />
						</cfif>
					</cfif>
		
					<!--- Check user can request approval --->
					<cfif stOverviewParams.stPermissions.iRequest eq 1>
						<cfif stobj.objectid NEQ stOverviewParams.objectid_previousversion>
							<ft:button width="240px" style="" value="Request approval" rbkey="workflow.buttons.requestapproval" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=requestapproval&ref=#url.ref#" />
						<cfelse>
							<ft:button width="240px" style="" value="Request approval for this content item" rbkey="workflow.buttons.requestapprovalforcontent" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=requestapproval&ref=#url.ref#" />	
						</cfif>
					</cfif>
		
					<!--- delete draft veresion --->
					<cfif stOverviewParams.stPermissions.iDelete eq 1> <!--- delete object --->
							<cfif stobj.objectid EQ stOverviewParams.objectid_previousversion>
								<cfif listContains(application.navid.home,stobj.objectid) EQ 0 AND listContains(application.navid.root,stobj.objectid) eq 0>
								<!--- check user can delete --->
									<cfif stOverviewParams.stPermissions.iDelete eq 1>
										<cfif structkeyexists(stobj,"versionid") and len(stObj.versionid)>
											<cfset returnto = "returnto=#urlencodedformat('#cgi.script_name#?objectid=#stObj.versionid#&ref=#url.ref#')#" />
										<cfelse>
											<cfset returnto = "" />
										</cfif>
										<ft:button width="240px" style="" value="Delete" rbkey="workflow.buttons.delete" bInPanel="true" url="navajo/delete.cfm?ObjectId=#stobj.objectId#&#returnto#&ref=#url.ref#" confirmText="Are you sure you wish to delete this content item?" />
									</cfif>
											
									<!--- check user can move to trash and is a navigation obj--->
									<cfif stOverviewParams.stPermissions.iTreeSendToTrash eq 1 and stobj.typeName eq "dmNavigation">
										<ft:button width="240px" style="" value="Send to trash" rbkey="workflow.buttons.sendtotrash" bInPanel="true" url="navajo/move.cfm?srcObjectId=#stobj.objectId#&destobjId=#application.navid.rubbish#&ref=#url.ref#" confirmText="Are you sure you wish to trash this item?" />
									</cfif>
								</cfif>
							<cfelse>
								<ft:button width="240px" style="" value="Delete this draft version" rbkey="workflow.buttons.deletedraft" bInPanel="true" url="edittabEdit.cfm?objectid=#stOverviewParams.objectid_previousversion#&deleteDraftObjectID=#stobj.ObjectID#&typename=#stobj.typeName#&ref=#url.ref#" confirmText="Are you sure you wish to delete this content item?" />
							</cfif>
					</cfif>
				</cfcase>
			
				<cfcase value="pending"> <!--- PENDING STATUS --->
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND stobj.bAlwaysShowEdit EQ 1>
						<cfif stobj.objectid NEQ stOverviewParams.objectid_previousversion>
							<ft:button width="240px" style="" value="Restore live content item over this draft" rbkey="workflow.buttons.restorelive" bInPanel="true" url="" onclick="confirmRestore('#stobj.parentid#','#stobj.objectid#')" />
						</cfif>
					</cfif>
					
					<cfif stOverviewParams.stPermissions.iApprove eq 1> <!--- check user can approve object --->
						<ft:button width="240px" style="" value="Send content item live" rbkey="workflow.buttons.sendlive" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved&ref=#url.ref#" />
						<!--- send back to draft --->
						<ft:button width="240px" style="" value="Send this content item back to draft" rbkey="workflow.buttons.sendbacktodraft" bInPanel="true" url="#application.url.farcry#/navajo/approve.cfm?objectid=#stobj.objectid#&status=draft&ref=#url.ref#" />
					</cfif>
				</cfcase>
		
				<cfcase value="approved">	
					<!--- check user can edit --->
					<cfif stOverviewParams.stPermissions.iEdit EQ 1 AND stobj.bAlwaysShowEdit EQ 1>
						<cfif stobj.objectid NEQ stOverviewParams.objectid_previousversion>
							<ft:button width="240px" style="" value="Restore live content item over this draft" rbkey="workflow.buttons.restorelivecontent" bInPanel="true" url="" onclick="confirmRestore('#stobj.parentid#','#stobj.objectid#');" />
						</cfif>
					</cfif>
		
					<cfif listContains(application.navid.home,stobj.objectid) EQ 0 AND listContains(application.navid.root,stobj.objectid) eq 0>
						<!--- check user can delete --->
						<cfif stOverviewParams.stPermissions.iDelete eq 1>
							<ft:button width="240px" style="" value="Delete" rbkey="workflow.buttons.delete" bInPanel="true" url="navajo/delete.cfm?ObjectId=#stobj.objectId#&typename=#stobj.typeName#&ref=#url.ref#" confirmText="Are you sure you wish to delete this content item?" />
						</cfif>
						
						<!--- check user can move to trash and is dmNavigation type--->
						<cfif stOverviewParams.stPermissions.iTreeSendToTrash eq 1 and stobj.typeName eq "dmNavigation">
							<ft:button width="240px" style="" value="Send to trash" rbkey="workflow.buttons.sendtotrash" bInPanel="true" url="navajo/move.cfm?srcObjectId=#stobj.objectId#&destobjId=#application.navid.rubbish#&ref=#url.ref#" confirmText="Are you sure you wish to trash this item?" />
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		<cfelse>	<!--- content items without a status --->
			
			<!--- check user can delete --->
			<cfif stOverviewParams.stPermissions.iDelete eq 1>
				<ft:button width="240px" style="" value="Delete" rbkey="workflow.buttons.delete" bInPanel="true" url="navajo/delete.cfm?ObjectId=#stobj.objectId#&typename=#stobj.typeName#&ref=#url.ref#" confirmText="Are you sure you wish to delete this content item?" />
			</cfif>
			<!--- check user can move to trash and is dmNavigation type--->
			<cfif stOverviewParams.stPermissions.iTreeSendToTrash eq 1 and stobj.typeName eq "dmNavigation">
				<ft:button width="240px" style="" value="Send to trash" rbkey="workflow.buttons.sendtotrash" bInPanel="true" url="navajo/move.cfm?srcObjectId=#stobj.objectId#&destobjId=#application.navid.rubbish#&ref=#url.ref#" confirmText="Are you sure you wish to trash this item?" />
			</cfif>
		</cfif>

	</extjs:item>
	
	
	
	
	<!--- create child objects for dmNavigation --->
	<cfif stobj.typename EQ  "dmNavigation">
		<cfif StructKeyExists(stOverviewParams.stPermissions,"iCreate") and stOverviewParams.stPermissions.iCreate eq 1>
			<cfset objType = CreateObject("component","#Application.types[stobj.typename].typepath#")>
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
			<cfif ArrayLen(aTypesUseInTree)>
				<cfset panelCollapsed = true />
				<cfif structKeyExists(stobj, "aObjectIDs") and not arrayLen(stobj.aObjectIDs)>
					<cfset panelCollapsed = false />
				</cfif>
				<extjs:item title="Create Pages">
					<cfloop index="i" from="1" to="#ArrayLen(aTypesUseInTree)#">
						<ft:button width="240px" style="" value="Create #aTypesUseInTree[i].description#" rbkey="coapi.#aTypesUseInTree[i].typename#.buttons.createtype" bInPanel="true" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#stobj.objectid#&typename=#aTypesUseInTree[i].typename#&ref=#url.ref#" />
					</cfloop>	
				</extjs:item>	
			</cfif>
		</cfif>
	</cfif>	
	
	<cfif stOverviewParams.stPermissions.iEdit EQ 1>
		<cfset qFUs = application.fc.factory.farFU.getFUList(objectID="#stobj.objectid#", fuStatus="current")>

		<extjs:item title="Current Friendly URLs">
			<cfif NOT application.fc.factory.farFU.isUsingFU()>
				<cfoutput><p class="highlight">You do not currently have Friendly URLs available. Ask your administrator to add the required webserver rewrite.</p></cfoutput>
			</cfif>
			<cfoutput><ul></cfoutput>
			<cfloop query="qFUs">
				<cfoutput><li>#qFUs.friendlyURL#</li></cfoutput>
			</cfloop>
			<cfoutput></ul></cfoutput>
			<ft:button width="240px" style="" value="Manage" bInPanel="true" url="" onclick="window.open('#application.url.farcry#/manage_friendlyurl.cfm?objectid=#stobj.objectid#','_win_friendlyurl','height=500,width=700,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=no,status=yes').focus();" />		
		</extjs:item>
	</cfif>		
	
	<!--- add comments --->
	<extjs:item title="#application.rb.getResource('workflow.headings.viewcomments@text','View Comments')#" autoScroll="true">

		<ft:button width="240px" style="" value="Add Comments" rbkey="workflow.buttons.addcomments" bInPanel="true" url="#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#&ref=#url.ref#" />					
		<nj:showcomments objectid="#stObj.objectid#" typename="#stObj.typename#" />

	</extjs:item>
	
	<extjs:item title="#application.rb.getResource('workflow.headings.miscellaneous@text','Miscellaneous')#" >	
		
		<!--- view statistics --->	
		<ft:button width="240px" style="" type="button" value="Statistics" rbkey="workflow.buttons.statistics" url="#application.url.farcry#/edittabStats.cfm?objectid=#stobj.objectid#&ref=#url.ref#" target="objectStatistics" />		
			
		<!--- view audit --->	
		<ft:button width="240px" style="" type="button" value="Audit" rbkey="workflow.buttons.audit" onclick="openScaffoldDialog('#application.url.farcry#/edittabAudit.cfm?objectid=#stobj.objectid#','Audit',400,400,true);" />		
			

		
		<cfif stOverviewParams.stPermissions.iObjectDumpTab>
			<!--- dump content --->
			
			<ft:button width="240px" style="" type="button" value="Properties" rbkey="workflow.buttons.properties" onclick="openScaffoldDialog('#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#','Properties',400,400,true);" />		
			<!--- <li id="tgl_dumpobject_#stobj.objectid#" style="display:none;"><cfdump var="#stobj#"></li> --->
		</cfif>
		
		<cfif (stOverviewParams.stPermissions.iApprove eq 1 OR stOverviewParams.stPermissions.iApproveOwn EQ 1) AND StructKeyExists(stobj,"versionid")>
			<!--- rollback content --->
			<ft:button width="240px" style="" type="button" value="Show Archive" rbkey="workflow.buttons.showarchive" onclick="openScaffoldDialog('#application.url.farcry#/archive.cfm?objectid=#stobj.objectid#','Archive',400,400,true);" />
		</cfif>
		
		<cfif application.security.checkPermission("ModifyPermissions") and listcontains(application.stCOAPI.farBarnacle.stProps.referenceid.metadata.ftJoin,stObj.typename)>
			<ft:button width="240px" style="" type="button" value="Manage Permissions" rbkey="workflow.buttons.managepermissions" onclick="window.location='#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=adminPermissions&ref=#url.ref#';" />
		</cfif>


	</extjs:item>
	


</ft:form>
<cfsetting enablecfoutputonly="false">

