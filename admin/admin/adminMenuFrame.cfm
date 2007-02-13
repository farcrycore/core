<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>adminMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>
<cfparam name="url.type" default="general">
<div id="frameMenu">

	<cfswitch expression="#url.type#">
		<cfcase value="general">
			<!--- permission check --->
			<cfif iGeneralTab eq 1>			
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].configuration#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].configFiles#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_restore.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmRestoreDefault#');">#application.adminBundle[session.dmProfile.locale].restoreDefaultConfig#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config_custom.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].customConfig#</a></div>
				<!--- check user has developer permission --->
				<cfscript>
					oAuthorisation = request.dmSec.oAuthorisation;
					iDeveloperPermission = oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
				</cfscript>
				
				<cfif iDeveloperPermission eq 1>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="configDump.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].dumpConfig#</a></div>
				</cfif>
				<cfif iDeveloperPermission eq 1>
					<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].customAdminXML#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="customXMLDump.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].dumpCustomAdminXML#</a></div>
					
					<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].scopeDump#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="scopeDump.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].scopeDump#</a></div>
					
					<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].quickSiteBuilder#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="quickBuilder.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].quickSiteBuilder#</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="quickBuilderCat.cfm" class="frameMenuItem" target="editFrame">Quick Category Builder</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="bulkImageUpload.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].bulkImageUpload#</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="bulkFileUpload.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].bulkFileUpload#</a></div>
				</cfif>	
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].cache#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cacheSummary.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].cacheSummary#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cacheAll.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmCacheEntireWebsite#');">#application.adminBundle[session.dmProfile.locale].autoCache#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].scheduledTasks#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="scheduledTasks.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].scheduledTasks#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].messageCenter#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="messageCentre.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].messages#</a></div>
				
				<cfif application.config.plugins.fu>
					<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].friendlyURLs#</div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="resetFU.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmResetURLs#');">#application.adminBundle[session.dmProfile.locale].resetURLs#</a></div>
					<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="manageFU.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].manageURLs#</a></div>
				</cfif>
			</cfif>	
		</cfcase>
		
		<cfcase value="search">
			<!--- permission check --->
			<cfif iSearchTab eq 1>	
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].freeTextSearch#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityManage.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].manageCollections#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityBuild.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmVerityUpdate#');">#application.adminBundle[session.dmProfile.locale].updateCollections#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="verityOptimise.cfm" class="frameMenuItem" target="editFrame" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmOptimizeVerity#');">#application.adminBundle[session.dmProfile.locale].optimizeCollections#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="config.cfm?configName=verity" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].verityConfig#</a></div>
			</cfif>
		</cfcase>
		
		<cfcase value="COAPI">
			<!--- permission check --->
			
			<cfif iCOAPITab eq 1>	
				<div class="frameMenuTitle">COAPI</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiTypes.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].typeClasses#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiRules.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].ruleClasses#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiMetaData.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].COAPImetadata#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="coapiSchema.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].COAPIschema#</a></div>
				
				<div class="frameMenuTitle">#application.adminBundle[session.dmProfile.locale].Diagnostics#</div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="diagTreeNodes.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].orphanedNodes#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="fixtree.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].fixTreeLevels#</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="cleanTree.cfm" class="frameMenuItem" target="editFrame">#application.adminBundle[session.dmProfile.locale].removeRogueTreeData#</a></div>
				<!--- TODO: i18n --->
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="rebuildTree.cfm" class="frameMenuItem" target="editFrame">Rebuild Tree</a></div>
				<div class="frameMenuItem"><span class="frameMenuBullet">&raquo;</span> <a href="fixRefObjects.cfm" class="frameMenuItem" target="editFrame">Fix RefObjects</a></div>
			</cfif>
		</cfcase>
	</cfswitch>	
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">