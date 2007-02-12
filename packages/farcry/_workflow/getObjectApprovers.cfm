<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_workflow/getObjectApprovers.cfm,v 1.18 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$DESCRIPTION: Gets a list of approvers for a navigatio node$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfset lApprovePGs = "">

<!--- check if object is an underlying draft object --->
<q4:contentobjectget objectID="#arguments.objectID#" r_stobject="stObj">

<cfif isdefined("stObj.versionID") and len(stObj.versionID)>
	<cfset objectTest = stObj.versionID>
<cfelse>
	<cfset objectTest = arguments.objectID>
</cfif>

		
<!--- get navigation parent for permission checks --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#objectTest#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">

<cfscript>
oAuthorisation = request.dmsec.oAuthorisation;
stObjectPermissions = oAuthorisation.collateObjectPermissions(objectid=stObj.Objectid,  typename=stObj.typename);
</cfscript>
<!--- if parent returned --->
<cfif len(ParentID)>
	
	<!--- Get policy groups for that object --->
	<cfscript>
		stObjectPermissions = oAuthorisation.collateObjectPermissions(objectid=ParentID);
	</cfscript>
	
	<!--- Check policy groups can approve (T=1) --->
	<cfloop collection="#stObjectPermissions#" item="policyGroupID">
		<cfif stObjectPermissions[policyGroupID][application.permission.dmNavigation.Approve.permissionID].T eq 1>
			<!--- add to list of policy groups allowed to approve pending object if not already entered --->
			<cfif listFind(lApprovePGs, policyGroupID) eq 0>
				<cfset lApprovePGs = listAppend(lApprovePGs, policyGroupID)>
			</cfif>
		</cfif>	
	</cfloop>

</cfif>
	

<!--- get usernames for all members of approve policy groups --->
<cfscript>
	aUsers = oAuthorisation.getPolicyGroupUsers(lpolicygroupIDs=lApprovePGs);
</cfscript>

<!--- build struct of dmProfile objects for each user --->
<cfset stApprovers = structNew()>

<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
    <cfscript>
    o_profile = createObject("component", application.types.dmProfile.typePath);
    stProfile = o_profile.getProfile(aUsers[i]);
	if (not structIsEmpty(stProfile) AND stProfile.bActive) stApprovers[aUsers[i]] = stProfile;
    </cfscript>
</cfloop>
