<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>adminMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
</head>

<body>
<cfparam name="url.type" default="general">
<div id="frameMenu">

<!--- <div class="frameMenuHeader">Admin</div>
 --->
	<cfswitch expression="#url.type#">
		<cfcase value="general">			
			<div class="frameMenuTitle">Configuration</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm" class="frameMenuItem" target="editFrame">Config Files</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_restore.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to restore the Default Config?');">Restore Default Config</a></div>
			
			<!--- check user has developer permission --->
			<cfscript>
				oAuthorisation = request.dmSec.oAuthorisation;
				iDeveloperPermission = oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
			</cfscript>

			<cfif iDeveloperPermission eq 1>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="configDump.cfm" class="frameMenuItem" target="editFrame">Dump Config</a></div>
			</cfif>
			<cfif iDeveloperPermission eq 1>
				<div class="frameMenuTitle">Custom Admin XML</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="customXMLDump.cfm" class="frameMenuItem" target="editFrame">Dump Custom Admin XML</a></div>
				
				<div class="frameMenuTitle">Scope Dump</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="scopeDump.cfm" class="frameMenuItem" target="editFrame">Scope Dump</a></div>
			</cfif>	
			
			<div class="frameMenuTitle">Cache</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cacheSummary.cfm" class="frameMenuItem" target="editFrame">Cache Summary</a></div>
			
			<cfif application.config.plugins.fu>
				<div class="frameMenuTitle">Friendly URLs</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="resetFU.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you want to reset all Friendly URLs?');">Reset all Friendly URLs</a></div>
			</cfif>	
		</cfcase>
		
		<cfcase value="search">
			<div class="frameMenuTitle">Free Text Search</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span><a href="verityBuild.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to Build/Update your Verity Collection?');">Build/Update Collections</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span><a href="verityOptimise.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to Optimise your Verity Collections?');">Optimise Collections</a></div>
		</cfcase>
		
		<cfcase value="COAPI">
			<div class="frameMenuTitle">COAPI</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiTypes.cfm" class="frameMenuItem" target="editFrame">Type Classes</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiRules.cfm" class="frameMenuItem" target="editFrame">Rule Classes</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiMetaData.cfm" class="frameMenuItem" target="editFrame">COAPI Metadata</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiSchema.cfm" class="frameMenuItem" target="editFrame">COAPI Schema</a></div>
			
			<div class="frameMenuTitle">Diagnostics</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="diagTreeNodes.cfm" class="frameMenuItem" target="editFrame">Orphaned Nodes</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="fixtree.cfm" class="frameMenuItem" target="editFrame">Fix Tree</a></div>
		</cfcase>
		
		<cfcase value="stats">
			<div class="frameMenuTitle">General</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsMostPopular.cfm" class="frameMenuItem" target="editFrame">View Summary</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsReferer.cfm" class="frameMenuItem" target="editFrame">Referer Summary</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsLocale.cfm" class="frameMenuItem" target="editFrame">Locale Summary</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsOS.cfm" class="frameMenuItem" target="editFrame">Operating System Summary</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsBrowsers.cfm" class="frameMenuItem" target="editFrame">Browser Summary</a></div>		
			
			<div class="frameMenuTitle">Sessions</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitors.cfm" class="frameMenuItem" target="editFrame">Session Summary</a></div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsVisitorPaths.cfm" class="frameMenuItem" target="editFrame">Session Paths</a></div>
			
			<div class="frameMenuTitle">Maintenance</div>
			<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="statsClear.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to delete all Stats records?');">Clear Stats Log</a></div>
		</cfcase>
	</cfswitch>	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">