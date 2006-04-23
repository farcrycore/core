<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/security/securityMenuFrame.cfm,v 1.15 2004/07/15 01:52:20 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:52:20 $
$Name: milestone_2-3-2 $
$Revision: 1.15 $

|| DESCRIPTION || 
Displays menu items for security section in Farcry. If user has user security permissions, defaults to user tab, otherwise default to audit tab.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: url.type (which section of security menu)
out: none

|| END DAEMONDOC||
--->
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityUserManagementTab");
	iPolicyTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>securityMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>

<cfparam name="url.type" default="security">

<!--- display menu --->
<div id="frameMenu">
	<cfswitch expression="#url.type#">
		<cfcase value="security">
			<!--- permission check --->
			<cfif iSecurityTab eq 1>	
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].setup#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestSecuritySetup" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].testSecuritySetup#</a></div>
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].users#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserSearch" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].searchForUser#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserCreateEdit" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].createAUser#</a></div>
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].groups#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupSearch" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].searchForGroup#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupCreateEdit" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].createGroup#</a></div>	
			</cfif>
		</cfcase>
		
		<cfcase value="policy">
			<!--- permission check --->
			<cfif iPolicyTab eq 1>	
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].setup#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestPolicySetup" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].testPolicySetup#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].policyGroups#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupSearch" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].policyGroups#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/permissions.cfm?reference1=PolicyGroup" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].policyGroupPermissions#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupCreateEdit" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].createPolicyGroup#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupCopy" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].copyPolicyGroup#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMappingSearch" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].showPolicyGroupMappings#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMap" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].mapPolicyGroup#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].permissions#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionSearch" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].permissions#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionCreateEdit" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].createPermission#</a></div>		
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=reInitPermissionsCache" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].rebuildPermissions#</a></div>		
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=permissionsMap" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].permissionsMap#</a></div>		
			</cfif>
		</cfcase>
	</cfswitch>


</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
