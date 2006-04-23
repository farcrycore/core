<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_types/renderOverview.cfm,v 1.14 2005/07/19 03:59:21 pottery Exp $
$Author: pottery $
$Date: 2005/07/19 03:59:21 $
$Name: milestone_3-0-1 $
$Revision: 1.14 $

|| DESCRIPTION || 
$DESCRIPTION: Dispalys summary and options for editing/approving/previewing etc for selected object$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<!--- get navigation parent for permission checks --->
<nj:getNavigation 
	objectId="#stObj.ObjectID#"
	r_objectId="ParentID"
	r_stObject="stParent"
	bInclusive="1">

<!--- check permissions --->
<cfscript>
	oAuthentication = request.dmsec.oAuthentication;
	stUser = oAuthentication.getUserAuthenticationData();

	iEdit = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="edit");
	iRequest = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="RequestApproval");
	iApprove = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="approve");
	iApproveOwn = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="CanApproveOwnContent"); 	
	if(iApproveOwn EQ 1 AND NOT stObj.lastUpdatedBy IS stUser.userLogin)
		iApproveOwn = 0;
	iTreeSendToTrash = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="SendToTrash");
	iObjectDumpTab = request.dmSec.oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="ObjectDumpTab");
	iDelete = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#parentid#",permissionName="delete");
</cfscript>

<cfsavecontent variable="overviewHtml">
<strong><cfoutput>#application.adminBundle[session.dmProfile.locale].changeStatus#</cfoutput></strong><br />

<!--- check if object has status field --->
<cfif structKeyExists(stobj,"status") AND stObj.typename NEQ "dmFile" AND stObj.typename NEQ "dmImage">
	<!--- work out different options depending on object status --->
	<cfswitch expression="#stobj.status#">
		<cfcase value="draft">
			<Cfif iEdit eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stObj.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.adminBundle[session.dmProfile.locale].editObj#</a><br /></cfoutput>
			</Cfif>
			
			<!--- Check user can request approval --->			
			<cfif iRequest eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=requestapproval" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].requestObjApproval#</a><br /></cfoutput>
			</cfif>
			
			<!--- check user can approve object --->
			<cfif iApprove eq 1 OR iApproveOwn EQ 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].approveObjYourself#</a><br /></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="pending">
			<cfif iApprove eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">>#application.adminBundle[session.dmProfile.locale].approveObjYourself#</a><br /></cfoutput>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a><br /></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="approved">
			<cfif structKeyExists(stObj,"versionID")>				
				<cfset oVersioning = createObject("component", "#application.packagepath#.farcry.versioning")>
				<cfset qHasDraft = oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
				
				<!--- check if draft version exists --->					
				<cfif qHasDraft.recordcount eq 0>
					<!--- check user can edit --->
					<cfif iEdit eq 1>
						<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stObj.objectID#" class="frameMenuItem" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.adminBundle[session.dmProfile.locale].createEditableDraft#</a><br /></cfoutput>
					</cfif>
				</cfif>
			</cfif>
			
			<cfif iApprove eq 1 OR iApproveOwn EQ 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a> <cfif structKeyExists(stObj,"versionID") and qHasDraft.recordcount> #application.adminBundle[session.dmProfile.locale].deletingDraftVersion#</cfif><br /></cfoutput>
			</cfif>
			
		</cfcase>
	</cfswitch>
<cfelse>
	<Cfif iEdit eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stObj.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.adminBundle[session.dmProfile.locale].editObj#</a><br /></cfoutput>
	</cfif>
</cfif>

<cfoutput><br /><strong>#application.adminBundle[session.dmProfile.locale].general#</strong><br /></cfoutput>
<!--- preview object --->
<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&flushcache=1&showdraft=1" class="frameMenuItem" target="_blank"><cfoutput>#application.adminBundle[session.dmProfile.locale].Preview#</cfoutput></a><br /></cfoutput>


<!--- add comments --->
<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/commentOnContent.cfm?objectid=#stObj.objectid#">#application.adminBundle[session.dmProfile.locale].addComments#</a><br /></cfoutput>
<!--- view comments --->
<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="##" onClick="commWin=window.open('#application.url.farcry#/navajo/viewComments.cfm?objectid=#stObj.objectid#', 'commWin', 'scrollbars=yes,width=400,height=450');commWin.focus();">#application.adminBundle[session.dmProfile.locale].viewComments#</a><br /></cfoutput>


<cfif iObjectDumpTab eq 1>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabDump.cfm?objectid=#stObj.objectid#">#application.adminBundle[session.dmProfile.locale].dump#</a><br /></cfoutput>
</cfif>

<cfif listContains(application.navid.home,stObj.objectid) eq 0 AND listContains(application.navid.root,stObj.objectid) eq 0>
	<!--- check user can delete --->
	<cfif iDelete eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/delete.cfm?ObjectId=#stObj.objectId#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].delete#</a><br /></cfoutput>
	</cfif>
	
	<!--- check user can move to trash --->
	<cfif iTreeSendToTrash eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/move.cfm?srcObjectId=#stObj.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmTrashObj#');">#application.adminBundle[session.dmProfile.locale].sendToTrash#</a></br></cfoutput>
	</cfif>
</cfif>
</cfsavecontent>