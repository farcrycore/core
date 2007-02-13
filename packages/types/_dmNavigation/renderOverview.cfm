<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmnavigation/renderOverview.cfm,v 1.10 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$DESCRIPTION: Dispalys summary and options for editing/approving/previewing etc for selected object$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">

<!--- check permissions --->
<cfscript>
	oAuthentication = request.dmsec.oAuthentication;
	stUser = oAuthentication.getUserAuthenticationData();
	
	iCreate = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="create");
	iEdit = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="edit");
	iRequest = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="RequestApproval");
	iApprove = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="Approve");
	iApproveOwn = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="CanApproveOwnContent"); 	
	if(iApproveOwn EQ 1 AND NOT stObj.lastUpdatedBy IS stUser.userLogin)
		iApproveOwn = 0;
	iTreeSendToTrash = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="SendToTrash");
	iObjectDumpTab = request.dmSec.oAuthorisation.checkPermission(reference="PolicyGroup",permissionName="ObjectDumpTab");
	iDelete = request.dmSec.oAuthorisation.checkInheritedPermission(objectid="#stObj.objectid#",permissionName="delete");
</cfscript>

<cfsavecontent variable="html">
<cfif listContains(application.navid.home,stObj.objectid) eq 0 AND listContains(application.navid.root,stObj.objectid) eq 0>
	
	<strong><cfoutput>#application.adminBundle[session.dmProfile.locale].changeStatus#</cfoutput></strong><Br>
	
	<!--- work out different options depending on object status --->
	<cfswitch expression="#stobj.status#">
		<cfcase value="draft">
			<Cfif iEdit eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabEdit.cfm?objectid=#stObj.objectid#" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.adminBundle[session.dmProfile.locale].editObj#</a><BR></cfoutput>
			</Cfif>
				
			<!--- Check user can request approval --->			
			<cfif iRequest eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=requestapproval" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].requestObjApproval#</a><br></cfoutput>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=requestapproval&approveBranch=1" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].requestBranchApproval#</a><br></cfoutput>
			</cfif>
			
			<!--- check user can approve object --->
			<cfif iApprove eq 1 OR iApproveOwn eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].approveObjYourself#</a><br></cfoutput>			
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved&approveBranch=1" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].approveBranchYourself#</a><br></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="pending">
			<cfif iApprove eq 1 OR iApproveOwn eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].approveObjYourself#</a><br></cfoutput>			
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=approved&approveBranch=1" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].approveBranchYourself#</a><br></cfoutput>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBackToDraft#</a><br></cfoutput>			
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft&approveBranch=1" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBranchToDraft#</a><br></cfoutput>
			</cfif>
		</cfcase>
		
		<cfcase value="approved">
			<cfif iApprove eq 1 OR iApproveOwn eq 1>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendbackToDraft#</a><br></cfoutput>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/approve.cfm?objectid=#stObj.objectid#&status=draft&approveBranch=1" class="frameMenuItem">#application.adminBundle[session.dmProfile.locale].sendBranchToDraft#</a><br></cfoutput>
			</cfif>
		</cfcase>
	</cfswitch>

</cfif>

<cfif iCreate eq 1>
	<cfoutput><br><strong>#application.adminBundle[session.dmProfile.locale].create#</strong><Br></cfoutput>
	<cfscript>
		function buildTreeCreateTypes(a,lTypes)
		{
			
			var aTypes = listToArray(lTypes);
			
			//build core types first
			for(i=1;i LTE arrayLen(aTypes);i = i+1)
			{		
				if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND NOT application.types[aTypes[i]].bcustomType)
				{	stType = structNew();
					stType.typename = aTypes[i];
					if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
						stType.description = application.types[aTypes[i]].displayName;
					else
						stType.description = aTypes[i];
					arrayAppend(a,stType);
				}	
			}	
			//now custom types
			for(i=1;i LTE arrayLen(aTypes);i = i+1)
			{		
				if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND application.types[aTypes[i]].bcustomType)
				{	stType = structNew();
					stType.typename = aTypes[i];
					if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
						stType.description = application.types[aTypes[i]].displayName;
					else
						stType.description = aTypes[i];
					arrayAppend(a,stType);
				}	
			}	
			
			return a;
		}
		
		aTypesUseInTree = arrayNew(1);
		lPreferredTypeSeq = 'dmNavigation,dmHTML'; // this list will determine preffered order of objects in create menu - maybe this should be configurable.
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lPreferredTypeSeq); 
		lAllTypes = structKeyList(application.types);
		
		//remove preffered types from *all* list
		aPreferredTypeSeq = listToArray(lPreferredTypeSeq);
		for (i=1;i LTE arrayLen(aPreferredTypeSeq);i=i+1)
		{
			lAlltypes = listDeleteAt(lAllTypes,listFindNoCase(lAllTypes,aPreferredTypeSeq[i]));
		}
		aTypesUseInTree = buildTreeCreateTypes(aTypesUseInTree,lAllTypes); 
	</cfscript>
		
	<cfloop from="1" to="#arrayLen(aTypesUseInTree)#" index="i">
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/navajo/createObject.cfm?objectId=#stObj.objectid#&typename=#aTypesUseInTree[i].typename#" class="frameMenuItem" onClick="synchTab('editFrame','activesubtab','subtab','siteEditEdit');synchTitle('Edit')">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].createSomething,'#aTypesUseInTree[i].description#')#</a><br></cfoutput>
	</cfloop>
</cfif>	

<cfoutput><br><strong>#application.adminBundle[session.dmProfile.locale].general#</strong><Br></cfoutput>
<!--- preview object --->
<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&flushcache=1&showdraft=1" class="frameMenuItem" target="_blank">#application.adminBundle[session.dmProfile.locale].preview#</a><br></cfoutput>

<cfif iObjectDumpTab eq 1>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="edittabDump.cfm?objectid=#stObj.objectid#">#application.adminBundle[session.dmProfile.locale].dump#</a><BR></cfoutput>
</cfif>

<cfif listContains(application.navid.home,stObj.objectid) eq 0 AND listContains(application.navid.root,stObj.objectid) eq 0>
	<!--- check user can delete --->
	<cfif iDelete eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/delete.cfm?ObjectId=#stObj.objectId#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteObj#');">#application.adminBundle[session.dmProfile.locale].delete#</a><BR></cfoutput>
	</cfif>
	
	<!--- check user can move to trash --->
	<cfif iTreeSendToTrash eq 1>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> <a href="navajo/move.cfm?srcObjectId=#stObj.objectId#&destObjectId=#application.navid.rubbish#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmTrashObj#');">#application.adminBundle[session.dmProfile.locale].sendToTrash#</a><BR></cfoutput>
	</cfif>
</cfif>
</cfsavecontent>