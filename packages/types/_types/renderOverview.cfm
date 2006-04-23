<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_types/renderOverview.cfm,v 1.10 2004/04/21 07:19:47 paul Exp $
$Author: paul $
$Date: 2004/04/21 07:19:47 $
$Name: milestone_2-2-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$DESCRIPTION: Dispalys summary and options for editing/approving/previewing etc for selected object$
$TODO: $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

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
<strong>Edit/Change Status</strong><br/>

<!--- check if object has status field --->
<cfif structKeyExists(stobj,"status") and stObj.typename neq "dmFile" and stObj.typename neq "dmImage">
	<!--- work out different options depending on object status --->
	<cfswitch expression="#stobj.status#">
		<cfcase value="draft">
			<Cfif iEdit eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stObj.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">Edit this object</a><br/></cfoutput>
			</Cfif>
			
			<!--- Check user can request approval --->			
			<cfif iRequest eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=requestapproval" class="frameMenuItem">Request Approval for this object</a><br/></cfoutput>
			</cfif>
			
			<!--- check user can approve object --->
			<cfif iApprove eq 1 OR iApproveOwn EQ 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">Approve the object yourself</a><br/></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="pending">
			<cfif iApprove eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">Approve the object yourself</a><br/></cfoutput>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">Send object back to draft</a><br/></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="approved">
			<cfif structKeyExists(stObj,"versionID")>
				<cfscript>
					oVersioning = createObject("component", "#application.packagepath#.farcry.versioning");
					qHasDraft = oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename);
				</cfscript>
				<!--- check if draft version exists --->					
				<cfif qHasDraft.recordcount eq 0>
					<!--- check user can edit --->
					<Cfif iEdit eq 1>
						<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#stObj.objectID#" class="frameMenuItem" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">Create an editable draft version</a><br/></cfoutput>
					</cfif>
				</cfif>
			</cfif>
			
			<cfif iApprove eq 1 OR iApproveOwn EQ 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">Send object back to draft</a> <cfif structKeyExists(stObj,"versionID") and qHasDraft.recordcount> (deleting above draft version)</cfif><br/></cfoutput>
			</cfif>
			
		</cfcase>
	</cfswitch>
<cfelse>
	<Cfif iEdit eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stObj.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">Edit this object</a><br/></cfoutput>
	</Cfif>
</cfif>

<br/><strong>General</strong><br/>
<!--- preview object --->
<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&flushcache=1&showdraft=1" class="frameMenuItem" target="_blank">Preview</a><br/></cfoutput>


<!--- add comments --->
<span class="frameMenuBullet">&raquo;</span> <a href="navajo/commentOnContent.cfm?objectid=<cfoutput>#stObj.objectid#</cfoutput>">Add Comments</a><br/>
<!--- view comments --->
<span class="frameMenuBullet">&raquo;</span> <a href="##" onClick="commWin=window.open('<cfoutput>#application.url.farcry#/navajo/viewComments.cfm?objectid=#stObj.objectid#</cfoutput>', 'commWin', 'scrollbars=yes,width=400,height=450');commWin.focus();">View Comments</a><br/>


<cfif iObjectDumpTab eq 1>
	<span class="frameMenuBullet">&raquo;</span> <a href="edittabDump.cfm?objectid=<cfoutput>#stObj.objectid#</cfoutput>">Dump</a><br/>
</cfif>

<cfif listContains(application.navid.home,stObj.objectid) eq 0 AND listContains(application.navid.root,stObj.objectid) eq 0>
	<!--- check user can delete --->
	<cfif iDelete eq 1>
		<span class="frameMenuBullet">&raquo;</span> <a href="navajo/delete.cfm?ObjectId=<cfoutput>#stObj.objectId#</cfoutput>" onClick="return confirm('Are you sure you wish to delete this object?');">Delete</a><br/>
	</cfif>
	
	<!--- check user can move to trash --->
	<cfif iTreeSendToTrash eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/move.cfm?srcObjectId=#stObj.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('Are you sure you wish to trash this object?');">Send to trash</a></br></cfoutput>
	</cfif>
</cfif>
</cfsavecontent>