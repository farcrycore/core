<cfsetting enablecfoutputonly="Yes">

<!--- check all the relevant security permissions for this user in dmSec --->
<!--- 
may want to remove some of these once non-tree menu items move to top 
frame... i note that none of these are actually used on the page with 
exception of iModifyPermissions and maybe iRootNodeManagement
20020217 GB
 --->
<cf_dmSec2_PermissionCheck permissionName="SecurityManagement" reference1="PolicyGroup" r_iState="iSecurityManagementState">
<cf_dmSec2_PermissionCheck permissionName="ModifyPermissions"  reference1="PolicyGroup" r_iState="iModifyPermissionsState">
<cf_dmSec2_PermissionCheck permissionName="Developer"          reference1="PolicyGroup" r_iState="iDeveloperState">
<cf_dmSec2_PermissionCheck permissionName="RootNodeManagement" reference1="PolicyGroup" r_iState="iRootNodeManagement">

<cflock timeout="30" throwontimeout="Yes" type="READONLY" scope="SESSION">
	<cfset sessionId = session.sessionId>
</cflock>

<cftry>
<cflock timeout="0" throwontimeout="Yes" name="refreshLockout_#sessionId#" type="EXCLUSIVE">
	
	<cfset borderStyle="ridge thin">
	<cfset smallPopupFeatures="width=400,height=300,menubar=no,toolbars=no">
	
	<cfinclude template="customIcons.cfm">
	
	<cfoutput>
	<HTML>
	<HEAD>
	<TITLE>Overview Tree</TITLE>
	<!--- <cf_cachecontrol> --->
	<LINK href="../includes/overviewFrame.css" rel="stylesheet" type="text/css">
	</HEAD>
		
	<body>
<!--- 
Buttons now available in top frame...
	<cfif iModifyPermissionsState eq 1>
		<input type="button" class="navajoButton" onclick="parent['editFrame'].location='#application.url.farcry#/navajo/keywords/hierarchyedit.cfm'" value="Manage Keywords"><br>
		<input type="button" class="navajoButton" onclick="parent['editFrame'].location='#application.url.farcry#/navajo/permissions.cfm?reference1=PolicyGroup'" value="Group Permissions"><br>
	</cfif>
	
	<input type="button" class="navajoButton" onclick="window.open('#application.url.farcry#/security/','NavajoExt');" value="Security System"><br>
	<input type="button" class="navajoButton" onclick="parent['editFrame'].location='#application.url.farcry#/navajo/GenericAdmin.cfm?type=news'" value="News"><br>
	<input type="button" class="navajoButton" onclick="parent['editFrame'].location='#application.url.farcry#/unsecured/reindex.cfm'" value="Index Metadata"><br>
 --->
		<b>Site Management</b>
				</cfoutput>
					<cf_nj2Overview customIcons="#customIcons#">
				<cfoutput>
	</body>
	</html>
	</cfoutput>
	
	</cflock>

	<cfcatch type="Lock">
		<cfoutput>
		<p>The system has detected the <b>Overview Tree</b> is already loading.</p>
		
		<p>The <b>Overview Tree</b> cannot be loaded more than once per user at a time.</p>
		
		<p>You are probably receiving this error because you have pushed the refresh button half way through loading.  Pressing the refresh button in the middle of loading can have a significant performance impact on the website as your previous requests must be serviced before your new requests.  Therefore, we have implemented this restriction.</p>

		<p>You will now have to wait for your previous request to complete before you will be allowed to reload this screen.</p>
		
		<p><b>Please try again in 30 seconds.</b></p>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="No">
