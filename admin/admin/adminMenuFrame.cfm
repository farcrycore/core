<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>adminMenuFrame</title>
	<misc:cachecontrol>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<div id="frameMenu">

<!--- <div class="frameMenuHeader">Admin</div>
 --->

<div class="frameMenuTitle">Free Text Search</div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span><a href="verityBuild.cfm" class="frameMenuItem" target="editFrame">Build/Update Collections</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span><a href="verityOptimise.cfm" class="frameMenuItem" target="editFrame">Optimise Collections</a></div>

<div class="frameMenuTitle">Categorisation</div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="../navajo/keywords/hierarchyedit.cfm" class="frameMenuItem" target="editFrame">Manage Keywords</a></div>

<div class="frameMenuTitle">COAPI</div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiTypes.cfm" class="frameMenuItem" target="editFrame">Type Classes</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiRules.cfm" class="frameMenuItem" target="editFrame">Rule Classes</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiMetaData.cfm" class="frameMenuItem" target="editFrame">COAPI Metadata</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiSchema.cfm" class="frameMenuItem" target="editFrame">COAPI Schema</a></div>

<div class="frameMenuTitle">Configuration</div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm" class="frameMenuItem" target="editFrame">Config Files</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_restore.cfm" class="frameMenuItem" target="editFrame">Restore Default Config</a></div>

<div class="frameMenuTitle">Diagnostics</div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="diagTreeNodes.cfm" class="frameMenuItem" target="editFrame">dmNavigation</a></div>

<div class="frameMenuTitle">Audit</div>
<!--- <div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditHome.cfm" class="frameMenuItem" target="editFrame">Audit Home</a></div> --->
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditFailedLogins.cfm" class="frameMenuItem" target="editFrame">Failed Logins</a></div>
<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="auditUserActivity.cfm" class="frameMenuItem" target="editFrame">User Activity</a></div>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">