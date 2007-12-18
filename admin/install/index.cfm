
<cfsetting requesttimeout="600" />



<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<title>FARCRY INSTALLER. </title>
		
		<!--- EXT CSS & JS--->
		<link rel="stylesheet" type="text/css" href="/farcry/core/admin/js/ext/resources/css/ext-all.css">
		<script type="text/javascript" src="/farcry/core/admin/js/ext/adapter/ext/ext-base.js"></script>
		<script type="text/javascript" src="/farcry/core/admin/js/ext/ext-all.js"></script>
		
		<!--- INSTALL CSS & JS --->
		<link rel="stylesheet" type="text/css" href="css/install.css">
		<script type="text/javascript" src="js/install.js"></script>
		
	</head>
	
	<body>
</cfoutput>




<!------------------------------------ 
SETUP PATHS AND DIRECTORY LISTINGS
 ------------------------------------>
<cfset getLocalEnvironmentVariables() />


<!--------------------------------------- 
DETERMINE THE CURRENT VERSION OF FARCRY
 --------------------------------------->
<cfset request.coreVersion = getCoreVersion() />
<cfoutput><p>You are currently running version <strong>#request.coreVersion.major#-#request.coreVersion.minor#-#request.coreVersion.patch#</strong> of Farcry Core.</p></cfoutput>



<!------------------------------------------------ 
SETUP DEFAULTS FOR ALL INSTALLATION WIZARD FIELDS 
------------------------------------------------>
<!--- <cfset session.stFarcryInstall = structNew() /> --->
<cfparam name="session.stFarcryInstall" default="#structNew()#" />
<cfparam name="session.stFarcryInstall.currentStep" default="1" />
<cfparam name="session.stFarcryInstall.lCompletedSteps" default="" />
<cfparam name="session.stFarcryInstall.stConfig" default="#structNew()#" />
<cfparam name="session.stFarcryInstall.stConfig.applicationName" default="" />
<cfparam name="session.stFarcryInstall.stConfig.DSN" default="" />
<cfparam name="session.stFarcryInstall.stConfig.DBType" default="" />
<cfparam name="session.stFarcryInstall.stConfig.DBOwner" default="" />
<cfparam name="session.stFarcryInstall.stConfig.skeleton" default="" />
<cfparam name="session.stFarcryInstall.stConfig.plugins" default="farcrycms" />
<cfparam name="session.stFarcryInstall.stConfig.projectInstallType" default="subDirectory" />
<cfparam name="session.stFarcryInstall.stConfig.webtopInstallType" default="project" />



<!------------------------------------------ 
SAVE AND CONTROL THE INSTAL PROCESS WIZARD
 ------------------------------------------>

<cf_processStep step="ALL">
	
	<cfloop collection="#form#" item="field">
		<cfif structKeyExists(session.stFarcryInstall.stConfig, field)>
			<cfset session.stFarcryInstall.stConfig[field] = form[field] />
		</cfif>
	</cfloop>
	
</cf_processStep>



<cf_processStep step="1">
	
	<cfif directoryExists(expandPath("/farcry/projects/#session.stFarcryInstall.stConfig.applicationName#"))>
		
		<cf_redoStep field="applicationName" errorTitle="INVALID APPLICATION NAME" errorDescription="There is already project called #session.stFarcryInstall.stConfig.applicationName# on this server. Please delete this project or select a new name." />

	</cfif>

</cf_processStep>



<cf_processStep step="2">

	<cfset stResult = createObject("component", "flightCheck").checkDSN(session.stFarcryInstall.stConfig.dsn) />
	
	<cfif not stResult.bSuccess>
		<cf_redoStep field="DSN" errorTitle="#stResult.errorTitle#" errorDescription="#stResult.errorDescription#" />
	</cfif>
	
	
	<cfset stResult = createObject("component", "flightCheck").checkDBType(dsn="#session.stFarcryInstall.stConfig.dsn#", DBType="#session.stFarcryInstall.stConfig.DBType#") />
	
	<cfif not stResult.bSuccess>
		<cf_redoStep field="DBType" errorTitle="#stResult.errorTitle#" errorDescription="#stResult.errorDescription#" />
	</cfif>

	
</cf_processStep>


<cf_processStep step="3">
	<cfif not len(session.stFarcryInstall.stConfig.skeleton)>
		<cf_redoStep field="skeleton" errorTitle="Select Skeleton" errorDescription="You must select a skeleton in order to proceed." />
	</cfif>
</cf_processStep>



<cf_processStep step="4">

	<cfset oSkeletonManifest = createObject("component", "farcry.skeletons.#session.stFarcryInstall.stConfig.skeleton#.install.manifest")>

	<cfif listContainsNoCase(oSkeletonManifest.lRequiredPlugins, qPlugins.name) AND NOT listContainsNoCase(session.stFarcryInstall.stConfig.plugins, qPlugins.name)>
		
		<cf_redoStep field="plugin-#qPlugins.name#" errorTitle="Required" errorDescription="This plugin is required by the selected skeleton." />
	</cfif>
	
</cf_processStep>



<cf_processStep step="5">
	
</cf_processStep>



<cf_processStep step="6">	
	
	<cfif form.farcrySubmitButton EQ "INSTALL NOW">
		<cflocation url="installFarcry.cfm"  addtoken="false" />
	</cfif>
	
</cf_processStep>



<!--- 
SETUP THE FORM AND HIDDEN FIELDS TO CONTROL THE WIZARD
 --->
<cfoutput>
<form action="#cgi.script_name#" method="post" name="installForm">
	
	<input type="hidden" id="goToStep" name="goToStep" value="" >
	<input type="hidden" name="currentStep" value="#session.stFarcryInstall.currentStep#" />
</cfoutput>



<!------------------------------ 
DISPLAY THE WIZARD NAVIGATION
 ------------------------------>
<cfset wizardNav = getWizardNav() />
<cfoutput>#wizardNav#</cfoutput>



<!--------------------------------- 
RENDER THE CURRENT STEP
 --------------------------------->

	
<cf_displayStep step="1">
	<cfoutput>	
	<h1>PROJECT NAME</h1>
	<div class="item">
      	<label for="applicationName">Project Name <em>*</em></label>
		<div class="field">
			<input type="text" id="applicationName" name="applicationName" value="#session.stFarcryInstall.stConfig.applicationName#">
		</div>
		<div class="clear"></div>
	</div>			
	</cfoutput>
</cf_displayStep>

<cf_displayStep step="2">
	<cfoutput>
	<h1>DATABASE SETUP</h1>
	<div class="item">
      	<label for="DSN">Project DSN <em>*</em></label>
		<div class="field">
			<input type="text" id="DSN" name="DSN" value="#session.stFarcryInstall.stConfig.DSN#">
		</div>
		<div class="clear"></div>
	</div>
	

  	<div class="item">
      	<label for="DBType">Database Type <em>*</em></label>
		<div class="field">
	      	<select name="DBType" id="DBType" class="selectOne">
		        <option value="">-- Select --</option>
		        <option value="mssql" <cfif session.stFarcryInstall.stConfig.dbType EQ "mssql"> selected="selected"</cfif>>Microsoft SQL Server</option>
		        <option value="ora" <cfif session.stFarcryInstall.stConfig.dbType EQ "ora"> selected="selected"</cfif>>Oracle</option>
		        <option value="mysql" <cfif session.stFarcryInstall.stConfig.dbType EQ "mysql"> selected="selected"</cfif>>MySQL</option>
		        <option value="postgresql" <cfif session.stFarcryInstall.stConfig.dbType EQ "postgresql"> selected="selected"</cfif>>PostgreSQL</option>
			</select>
		</div>
		<div class="clear"></div>
	</div>
	
	<cfif session.stFarcryInstall.stConfig.dbType EQ "mssql" OR session.stFarcryInstall.stConfig.dbType EQ "ora">
		<cfset ownerDisplay = 'block' />
	<cfelse>
		<cfset ownerDisplay = 'none' />
	</cfif>
    <div class="item" id="divDBOwner" style="display:#ownerDisplay#;">
      	<label for="dbOwner">Database Owner</label>
		<div class="field">
			<input type="text" id="DBOwner" name="DBOwner" value="#session.stFarcryInstall.stConfig.DBOwner#">
		</div>
		<div class="clear"></div>
	</div>
	
	</cfoutput>
	
	<cfoutput>
	<script type="text/javascript">
		Ext.onReady(function(){	
			var field = Ext.get('DBType');
			field.on('change', checkDBType);
			
		})
		
		function checkDBType() {
			
			
			
			if(this.dom.value == "postgresql" || this.dom.value == "mysql" || this.dom.value == "")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.set({value:''});			
				
				var el = Ext.get('divDBOwner');	
				el.ghost('b', {
				    easing: 'easeOut',
				    duration: .5,
				    remove: false,
				    useDisplay: true
				});
					
			}
			else if (this.dom.value == "ora")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.set({value:'username'},false);			
					
				var el = Ext.get('divDBOwner');	
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
			}
			else 
			{		
				
				var DBOwner = Ext.get('DBOwner');
				DBOwner.set({value:'dbo.'},false);			
					
				var el = Ext.get('divDBOwner');	
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
			}
		}
	</script>	
	</cfoutput>
</cf_displayStep>


<cf_displayStep step="3">
	<cfoutput>
	<h1>SKELETON</h1>
    <div class="item">
      	<label for="skeleton">Skeleton</label>
		<div class="field">
			<select id="skeleton" name="skeleton">
				<option value="">-- Select Skeleton --</option>
				<cfloop query="qSkeletons">
					<cfif qSkeletons.type EQ "DIR" and fileExists("#skeletonPath#/#qSkeletons.name#/install/manifest.cfc")>
						<cfset oManifest = createObject("component", "farcry.skeletons.#qSkeletons.name#.install.manifest")>
						<option value="#qSkeletons.name#" <cfif qSkeletons.name EQ session.stFarcryInstall.stConfig.skeleton>selected</cfif>>
							#oManifest.name#
							- Supported: #oManifest.isSupported(coreMajorVersion="#request.coreVersion.major#",coreMinorVersion="#request.coreVersion.minor#",corePatchVersion="#request.coreVersion.patch#")#
						</option>
					</cfif>
				</cfloop>
			</select>
		</div>
		<div class="clear"></div>
	</div>
	</cfoutput>
	

</cf_displayStep>


<cf_displayStep step="4">

	

	<cfoutput>		
	<h1>PLUGINS</h1>
    <div class="item">
      	<label>Plugins</label>
		<div class="field">
			
			<cfloop query="qPlugins">
				<cfif qPlugins.type EQ "DIR" and fileExists("#pluginPath#/#qPlugins.name#/install/manifest.cfc")>
					<cfset oManifest = createObject("component", "farcry.plugins.#qPlugins.name#.install.manifest")>
					<div id="plugin-#qPlugins.name#">
						<input type="checkbox" name="plugins" value="#qPlugins.name#" <cfif listContainsNoCase(session.stFarcryInstall.stConfig.plugins, qPlugins.name)>checked</cfif>>
						#oManifest.name# (#oManifest.description#)
					</div>
					
					<cfset pluginSupported = oManifest.isSupported(coreMajorVersion="#request.coreVersion.major#",coreMinorVersion="#request.coreVersion.minor#",corePatchVersion="#request.coreVersion.patch#")>
					<cfif not pluginSupported>
						
						<cf_redoStep field="plugin-#qPlugins.name#" errorTitle="Unsupported" errorDescription="This plugin is not supported on your current version of farcry. Please be aware you may experience problems with this plugin." />
					
					</cfif>
						
	
				</cfif>
			</cfloop>
			
		</div>
		<div class="clear"></div>
	</div>	
	</cfoutput>		
</cf_displayStep>


<cf_displayStep step="5">
	<cfoutput>
	<h1>PLUGINS</h1>
    <div class="item">
      	<label>Project Install Type</label>
		<div class="field">

			<input type="radio" id="projectInstallType-subDirectory" name="projectInstallType" value="subDirectory" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "subDirectory">checked</cfif>>Sub-Directory Under the web root<br />	
			<input type="radio" id="projectInstallType-webroot" name="projectInstallType" value="webroot" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "webroot">checked</cfif>>Into the web root<br />	
			<input type="radio" id="projectInstallType-farcry" name="projectInstallType" value="farcry" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "farcry">checked</cfif>>Keep in projects directory (Requires Webserver Mapping)<br />	
		</div>
		<div class="clear"></div>
	</div>

    <div class="item">
      	<label>Webtop Install Type</label>
		<div class="field">
			<input type="radio" id="webtopInstallType-project" name="webtopInstallType" value="project" <cfif session.stFarcryInstall.stConfig.webtopInstallType EQ "project">checked</cfif>>Make a copy under the project<br />	
			<input type="radio" id="webtopInstallType-farcry" name="webtopInstallType" value="farcry" <cfif session.stFarcryInstall.stConfig.webtopInstallType EQ "farcry">checked</cfif>>Shared Webroot in core (Requires Webserver Mapping)<br />	
		</div>
		<div class="clear"></div>
	</div>
	</cfoutput>		
</cf_displayStep>


<cf_displayStep step="6">
	<cfdump var="#session.stFarcryInstall.stConfig#" expand="true" label="session.stFarcryInstall.stConfig" />	
</cf_displayStep>



<cfoutput>
</form>
</cfoutput>




<cfoutput>
</body>
</html>
</cfoutput>



<!---------------------------------
 INSTALL SPECIFIC FUNCTIONS BELOW
 --------------------------------->


<!---
 Copies a directory.
 
 @param source 	 Source directory. (Required)
 @param destination 	 Destination directory. (Required)
 @param nameConflict 	 What to do when a conflict occurs (skip, overwrite, makeunique). Defaults to overwrite. (Optional)
 @return Returns nothing. 
 @author Joe Rinehart (joe.rinehart@gmail.com) 
 @version 1, July 27, 2005 
--->
<!--- <cffunction name="directoryCopy" output="true">
	<cfargument name="source" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="nameconflict" required="true" default="overwrite">

	<cfset var contents = "" />
	
	<!--- DO NOT COPY .SVN Directories if they exist --->
	<cfif not findNoCase(".svn", arguments.destination)>

		<cfif not(directoryExists(arguments.destination))>
			<cfdirectory action="create" directory="#arguments.destination#" mode="777">
		</cfif>
		
		<cfdirectory action="list" directory="#arguments.source#" name="contents">
		
		<cfloop query="contents">
			<cfif contents.type eq "file" and contents.name NEQ "manifest.cfc">
				<cffile action="copy" source="#arguments.source#/#contents.name#" destination="#arguments.destination#/#contents.name#" nameconflict="#arguments.nameConflict#" mode="777">
			<cfelseif contents.type eq "dir">
				<cfset directoryCopy(arguments.source & "/" & contents.name, arguments.destination & "/" &  contents.name) />
			</cfif>
		</cfloop>
	</cfif>
</cffunction> --->



<cffunction name="getLocalEnvironmentVariables" access="private" returntype="void" hint="Gets the paths and directory listings of local environment to be installed">

	<!--- Skeletons --->
	<cfset skeletonPath = expandPath('/farcry/skeletons') />
	<cfdirectory action="list" directory="#skeletonPath#" name="qSkeletons" />
	
	<cfif not qSkeletons.recordCount>
		<cfoutput>You have no farcry skeleton projects to install.</cfoutput>
		<cfabort>
	</cfif>
	
	<!--- Plugins --->
	<cfset pluginPath = expandPath('/farcry/plugins') />
	<cfdirectory action="list" directory="#pluginPath#" name="qPlugins" />
	
	<!--- Project --->
	<cfset farcryProjectsPath = expandPath('/farcry/projects') />
	<cfdirectory action="list" directory="#farcryProjectsPath#" name="qProjects" />
	
	
	<!--- Base --->
	<cfset baseProjectPath = expandPath('/farcry/core/admin/install/base') />
	
	<!--- Webroot --->
	<cfset webrootPath = expandPath('/') />
	
	<!--- Webtop --->
	<cfset webtopPath = expandPath('/farcry/core/admin') />
</cffunction>

<cffunction name="getCoreVersion" access="private" returntype="struct" hint="returns a structure containing the major, minor and patch version of farcry.">
	
	<cfset var coreVersion = structNew() />
	
	<cftry>	
		<cffile action="read" file="#expandPath('/farcry/core/major.version')#" variable="coreVersion.major">
		<cffile action="read" file="#expandPath('/farcry/core/minor.version')#" variable="coreVersion.minor">
		<cffile action="read" file="#expandPath('/farcry/core/patch.version')#" variable="coreVersion.patch">

		<cfcatch>		
			<cfset coreVersion.major = 0 />
			<cfset coreVersion.minor = 0 />
			<cfset coreVersion.patch = 0 />
		</cfcatch>
	</cftry>
	
	<cfreturn coreVersion>
</cffunction>

<cffunction name="getWizardNav" access="private" returntype="string" hint="returns the wizard navigation.">
	
	<cfset var wizardNavHTML = "" />
	
	<cfsavecontent variable="wizardNavHTML">
		<cfoutput>
		<div style="background:url(images/dots.gif) repeat-x center;">
		<table align="center">
		<tr>
		</cfoutput>
			
			<cfloop from="1" to="6" index="i">
				
				<cfif i EQ session.stFarcryInstall.currentStep>
					<cfset iconType = 1 />
				<cfelseif listFindNoCase(session.stFarcryInstall.lCompletedSteps, i)>
					<cfset iconType = 0 />
				<cfelse>
					<cfset iconType = 2 />
				</cfif>
				
				<cfoutput>
				<td align="center" style="width:60px;">
					<cfif iconType EQ 0>
						<input type="image" name="farcrySubmitButton" value="goToStep" src="images/function_#i#_#iconType#.gif" onclick="Ext.get('goToStep').set({value:'#i#'},false);" />
					<cfelse>
						<img src="images/function_#i#_#iconType#.gif" />
					</cfif>
					
				</td>
				</cfoutput>
				
			</cfloop>
		
		<cfoutput>
		</tr>
		</table>
		</div>
		</cfoutput>
		
	</cfsavecontent>

	<cfreturn wizardNavHTML />
	
</cffunction>
