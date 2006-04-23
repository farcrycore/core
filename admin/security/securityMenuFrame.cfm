
<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/security/securityMenuFrame.cfm,v 1.14 2004/04/27 18:39:35 tom Exp $
$Author: tom $
$Date: 2004/04/27 18:39:35 $
$Name: milestone_2-2-1 $
$Revision: 1.14 $

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

<html>
<head>
	<title>securityMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>

<cfparam name="url.type" default="security">

<!--- display menu --->
<div id="frameMenu">
	<cfswitch expression="#url.type#">
		<cfcase value="security">
			<!--- permission check --->
			<cfif iSecurityTab eq 1>	
				<div class="frameMenuTitle">Setup</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestSecuritySetup" class="frameMenuItem" target="editFrame">Test Security Setup</a></div>
				<div class="frameMenuTitle">Users</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserSearch" class="frameMenuItem" target="editFrame">Search for User</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserCreateEdit" class="frameMenuItem" target="editFrame">Create a User</a></div>
				<div class="frameMenuTitle">Groups</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupSearch" class="frameMenuItem" target="editFrame">Search for Group</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupCreateEdit" class="frameMenuItem" target="editFrame">Create a Group</a></div>	
			</cfif>
		</cfcase>
		
		<cfcase value="policy">
			<!--- permission check --->
			<cfif iPolicyTab eq 1>	
				<div class="frameMenuTitle">Setup</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestPolicySetup" class="frameMenuItem" target="editFrame">Test Policy Setup</a></div>
				
				<div class="frameMenuTitle">Policy Groups</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupSearch" class="frameMenuItem" target="editFrame">Policy Groups</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/permissions.cfm?reference1=PolicyGroup" class="frameMenuItem" target="editFrame">Policy Group Permissions</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupCreateEdit" class="frameMenuItem" target="editFrame">Create a Policy Group</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupCopy" class="frameMenuItem" target="editFrame">Copy a Policy Group</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMappingSearch" class="frameMenuItem" target="editFrame">Show Policy Group Mappings</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMap" class="frameMenuItem" target="editFrame">Map Policy Group</a></div>
				
				<div class="frameMenuTitle">Permissions</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionSearch" class="frameMenuItem" target="editFrame">Permissions</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionCreateEdit" class="frameMenuItem" target="editFrame">Create a Permission</a></div>		
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=reInitPermissionsCache" class="frameMenuItem" target="editFrame">Rebuild Permissions</a></div>		
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=permissionsMap" class="frameMenuItem" target="editFrame">Permissions Map</a></div>		
			</cfif>
		</cfcase>
	</cfswitch>
	

</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">
