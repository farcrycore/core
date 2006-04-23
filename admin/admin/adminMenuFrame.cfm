<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

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

	<cfswitch expression="#url.type#">
		<cfcase value="general">
			<!--- permission check --->
			<cfif iGeneralTab eq 1>			
				<div class="frameMenuTitle">Configuration</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm" class="frameMenuItem" target="editFrame">Config Files</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_restore.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to restore the Default Config?');">Restore Default Core Config</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_custom.cfm" class="frameMenuItem" target="editFrame">Custom Config</a></div>
				
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
					
					<div class="frameMenuTitle">Quick Site Builder</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="quickBuilder.cfm" class="frameMenuItem" target="editFrame">Quick Site Builder</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="bulkImageUpload.cfm" class="frameMenuItem" target="editFrame">Bulk Image Upload</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="bulkFileUpload.cfm" class="frameMenuItem" target="editFrame">Bulk File Upload</a></div>
				</cfif>	
				
				<div class="frameMenuTitle">Cache</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cacheSummary.cfm" class="frameMenuItem" target="editFrame">Cache Summary</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cacheAll.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you want to cache your entire website?');">Auto Cache</a></div>
				
				<div class="frameMenuTitle">Scheduled Tasks</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="scheduledTasks.cfm" class="frameMenuItem" target="editFrame">Scheduled Tasks</a></div>
				
				<div class="frameMenuTitle">Message Centre</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="messageCentre.cfm" class="frameMenuItem" target="editFrame">Messages</a></div>
				
				<cfif application.config.plugins.fu>
					<div class="frameMenuTitle">Friendly URLs</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="resetFU.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you want to reset all Friendly URLs?');">Reset all Friendly URLs</a></div>
				</cfif>
			</cfif>	
		</cfcase>
		
		<cfcase value="search">
			<!--- permission check --->
			<cfif iSearchTab eq 1>	
				<div class="frameMenuTitle">Free Text Search</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityManage.cfm" class="frameMenuItem" target="editFrame">Manage Collections</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityBuild.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to Build/Update all your Verity Collection?');">Build/Update All Collections</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityOptimise.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('Are you sure you wish to Optimise all your Verity Collections?');">Optimise All Collections</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm?configName=verity" class="frameMenuItem" target="editFrame">Verity Config</a></div>
			</cfif>
		</cfcase>
		
		<cfcase value="COAPI">
			<!--- permission check --->
			<cfif iCOAPITab eq 1>	
				<div class="frameMenuTitle">COAPI</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiTypes.cfm" class="frameMenuItem" target="editFrame">Type Classes</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiRules.cfm" class="frameMenuItem" target="editFrame">Rule Classes</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiMetaData.cfm" class="frameMenuItem" target="editFrame">COAPI Metadata</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiSchema.cfm" class="frameMenuItem" target="editFrame">COAPI Schema</a></div>
				
				<div class="frameMenuTitle">Diagnostics</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="diagTreeNodes.cfm" class="frameMenuItem" target="editFrame">Orphaned Nodes</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="fixtree.cfm" class="frameMenuItem" target="editFrame">Fix Tree Levels</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cleanTree.cfm" class="frameMenuItem" target="editFrame">Remove Rogue Tree Data</a></div>
			</cfif>
		</cfcase>
	</cfswitch>	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">