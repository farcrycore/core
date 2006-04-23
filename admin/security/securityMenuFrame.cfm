<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>securityMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<cfparam name="url.type" default="security">
<div id="frameMenu">

	<!--- <div class="frameMenuHeader">Security Management</div> --->
	<cfswitch expression="#url.type#">
		<cfcase value="security">
			<div class="frameMenuTitle">Setup</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestSecuritySetup" class="frameMenuItem" target="editFrame">Test Security Setup</a></div>
			
			<div class="frameMenuTitle">Users</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserSearch" class="frameMenuItem" target="editFrame">Search for User</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=UserCreateEdit" class="frameMenuItem" target="editFrame">Create a User</a></div>
			
			<div class="frameMenuTitle">Groups</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupSearch" class="frameMenuItem" target="editFrame">Search for Group</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=GroupCreateEdit" class="frameMenuItem" target="editFrame">Create a Group</a></div>	
			
			<div class="frameMenuTitle">Admin Roles</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/permissions.cfm?reference1=PolicyGroup" class="frameMenuItem" target="editFrame">Group Permissions</a></div>
		</cfcase>
		
		<cfcase value="policy">
			<div class="frameMenuTitle">Setup</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=TestPolicySetup" class="frameMenuItem" target="editFrame">Test Policy Setup</a></div>
			
			<div class="frameMenuTitle">Policy Groups</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupSearch" class="frameMenuItem" target="editFrame">Policy Groups</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupCreateEdit" class="frameMenuItem" target="editFrame">Create a Policy Group</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMappingSearch" class="frameMenuItem" target="editFrame">Show Policy Group Mappings</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PolicyGroupMap" class="frameMenuItem" target="editFrame">Map Policy Group</a></div>
			
			<div class="frameMenuTitle">Permissions</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionSearch" class="frameMenuItem" target="editFrame">Permissions</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../security/redirect.cfm?tag=PermissionCreateEdit" class="frameMenuItem" target="editFrame">Create a Permission</a></div>		
		</cfcase>
	</cfswitch>
	

</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">