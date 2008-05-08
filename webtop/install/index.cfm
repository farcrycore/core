
<cfsetting requesttimeout="600" />

<!--- IF THE INSTALLATION IS COMPLETE, SEND TO THE CONFIRMATION PAGE --->
<cfif isDefined("session.stFarcryInstall.bComplete") and session.stFarcryInstall.bComplete>
	<cflocation url="installFarcry.cfm" addToken="false" />
</cfif>



<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<title>FarCry Core Framework Installer</title>
		
		<!--- EXT CSS & JS--->
		<link rel="stylesheet" type="text/css" href="../js/ext/resources/css/ext-all.css" />
		<script type="text/javascript" src="../js/ext/adapter/ext/ext-base.js"></script>
		<script type="text/javascript" src="../js/ext/ext-all.js"></script>
		
		<!--- INSTALL CSS & JS --->
		<link rel="stylesheet" type="text/css" href="css/install.css" />
		<script type="text/javascript" src="js/install.js"></script>
		

		
	</head>
	<body style="background-color: ##5A7EB9;">
		<div style="border: 8px solid ##eee;background:##fff;width:600px;margin: 50px auto;padding: 20px;color:##666">

</cfoutput>







<!------------------------------------ 
SETUP PATHS AND DIRECTORY LISTINGS
 ------------------------------------>
<cfset getLocalEnvironmentVariables() />

		
<!--------------------------------------- 
DETERMINE THE CURRENT VERSION OF FARCRY
 --------------------------------------->
<cfset request.coreVersion = getCoreVersion() />



<!------------------------------------------------ 
SETUP DEFAULTS FOR ALL INSTALLATION WIZARD FIELDS 
------------------------------------------------>

<cfif not structKeyExists(session, "stFarcryInstall")>
	<cfset session.stFarcryInstall = "#structNew()#" />
	<cfset session.stFarcryInstall.bComplete = false />
	<cfset session.stFarcryInstall.currentStep = "1" />
	<cfset session.stFarcryInstall.lCompletedSteps = "" />
	<cfset session.stFarcryInstall.stConfig = "#structNew()#" />
	<cfset session.stFarcryInstall.stConfig.applicationName = "" />
	<cfset session.stFarcryInstall.stConfig.displayName = "" />
	<cfset session.stFarcryInstall.stConfig.locales = "en_AU,en_US" />
	<cfset session.stFarcryInstall.stConfig.DSN = "" />
	<cfset session.stFarcryInstall.stConfig.DBType = "" />
	<cfset session.stFarcryInstall.stConfig.DBOwner = "" />
	<cfset session.stFarcryInstall.stConfig.skeleton = "" />
	<cfset session.stFarcryInstall.stConfig.plugins = "" />
	<cfset session.stFarcryInstall.stConfig.projectInstallType = "subDirectory" />
	<cfset session.stFarcryInstall.stConfig.webtopInstallType = "project" />
	<cfset session.stFarcryInstall.stConfig.adminPassword = "#right(createUUID(),6)#" />
	<cfset session.stFarcryInstall.stConfig.updateappKey = "#right(createUUID(),4)#" />
	
	<cflocation url="#cgi.SCRIPT_NAME#?#cgi.query_string#" addtoken="false">
</cfif>


<!------------------------------------------ 
SAVE AND CONTROL THE INSTAL PROCESS WIZARD
 ------------------------------------------>

<cf_processStep step="ALL">
	
	<cfloop collection="#form#" item="field">
		<cfif findNoCase("addWebrootMapping", field)>
			<cfset session.stFarcryInstall.stConfig[field] = listFirst(form[field]) />
		<cfelse>
			<cfset session.stFarcryInstall.stConfig[field] = form[field] />
		</cfif>
		
		<cfif len(session.stFarcryInstall.stConfig.DBOwner) AND right(session.stFarcryInstall.stConfig.DBOwner,1) NEQ ".">
			<cfset session.stFarcryInstall.stConfig.DBOwner = "#session.stFarcryInstall.stConfig.DBOwner#." />
		</cfif>
	</cfloop>
	
</cf_processStep>



<cf_processStep step="1,6">
	
	<cfif not len(session.stFarcryInstall.stConfig.displayName)>		
		<cf_redoStep step="1" field="displayName" errorTitle="REQUIRED" errorDescription="You must select the project name." />
	</cfif>
		
	<!--- Check Its not empty --->
	<cfif not len(session.stFarcryInstall.stConfig.applicationName)>		
		<cf_redoStep step="1" field="applicationName" errorTitle="REQUIRED" errorDescription="You must select the project folder name." />
	<cfelse>
		<!--- Check its a valid variable name --->
		<cftry>
			<cfset "variables.#session.stFarcryInstall.stConfig.applicationName#" = 1 />
			<cfset bValidApplicationName = true />
			<cfcatch type="any">
				<!--- Means it wasnt a valide application name --->
				<cfset bValidApplicationName = false />
			</cfcatch>
		</cftry>
		<cfif not bValidApplicationName>
			<cf_redoStep step="1" field="applicationName" errorTitle="INVALID PROJECT FOLDER NAME" errorDescription="- no spaces<br />- only alpha numerics and _ (underscore)<br />- must start with an alpha" />
		<cfelse>
			<!--- Check its not already created. --->
			<cfif directoryExists(expandPath("/farcry/projects/#session.stFarcryInstall.stConfig.applicationName#"))>
				<cf_redoStep step="1" field="applicationName" errorTitle="INVALID PROJECT FOLDER NAME" errorDescription="The project folder name <b>#session.stFarcryInstall.stConfig.applicationName#</b> is invalid or already exists on this server. Please remove this project folder or select an alternative name." />
			</cfif>
		</cfif>
	</cfif>

	<cfif not len(session.stFarcryInstall.stConfig.locales)>
		<cf_redoStep step="1" field="locales" errorTitle="INVALID LOCALE" errorDescription="You must select at lease 1 locale." />
	</cfif>

</cf_processStep>


<cf_processStep step="2,6">

	<cfset stResult = createObject("component", "FlightCheck").checkDSN(session.stFarcryInstall.stConfig.dsn) />
	
	<cfif not stResult.bSuccess>
		<cf_redoStep step="2" field="DSN" errorTitle="#stResult.errorTitle#" errorDescription="#stResult.errorDescription#" />
	</cfif>
	
	<cfif not len(session.stFarcryInstall.stConfig.dbType)>
		
		<cf_redoStep step="2" field="DBType" errorTitle="REQUIRED" errorDescription="You must select the database type." />

	</cfif>
	

	<cfset stResult = createObject("component", "FlightCheck").checkDBType(DBOwner="#session.stFarcryInstall.stConfig.DBOwner#",dsn="#session.stFarcryInstall.stConfig.dsn#", DBType="#session.stFarcryInstall.stConfig.DBType#") />
	
	<cfif not stResult.bSuccess>
		<cf_redoStep step="2" field="DBType" errorTitle="#stResult.errorTitle#" errorDescription="#stResult.errorDescription#" />
	</cfif>
		

	

	
</cf_processStep>


<cf_processStep step="3,6">
	<cfif not len(trim(session.stFarcryInstall.stConfig.skeleton))>
		<cf_redoStep step="3" field="skeleton" errorTitle="Select Skeleton" errorDescription="You must select a skeleton in order to proceed." />
	<cfelse>
		<cfset oManifest = createObject("component", "#session.stFarcryInstall.stConfig.skeleton#.install.manifest")>
		
		<cfif len(oManifest.lRequiredPlugins) AND not len(session.stFarcryInstall.stConfig.plugins)>
			<cfset session.stFarcryInstall.stConfig.plugins =  oManifest.lRequiredPlugins />
		</cfif>	
	</cfif>
	
	
</cf_processStep>



<cf_processStep step="4,6">

	<cfset oSkeletonManifest = createObject("component", "#session.stFarcryInstall.stConfig.skeleton#.install.manifest")>

	<cfif listContainsNoCase(oSkeletonManifest.lRequiredPlugins, qPlugins.name) AND NOT listContainsNoCase(session.stFarcryInstall.stConfig.plugins, qPlugins.name)>
		
		<cf_redoStep step="4" field="plugin-#qPlugins.name#" errorTitle="Required" errorDescription="This plugin is required by the selected skeleton." />
	</cfif>
	
</cf_processStep>



<cf_processStep step="5,6">
	
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
<cfoutput>
<div style="margin-bottom:25px;">#wizardNav#</div>
<!---<h1>Farcry Core Installer</h1>--->
</cfoutput>



<!--------------------------------- 
RENDER THE CURRENT STEP
 --------------------------------->

	
<cf_displayStep step="1">
	

	<cfoutput>	
	<h1>Project Details</h1>
	
	<div class="item">
      	<label for="displayName">Project Name <em>*</em></label>
		<div class="field">
			<input type="text" id="displayName" name="displayName" value="#session.stFarcryInstall.stConfig.displayName#" />
			<div class="fieldHint">Project name is for display purposes only, and can be just about anything you like.</div>
		</div>
		<div class="clear"></div>
	</div>	
	<div class="item">
      	<label for="applicationName">Project Folder Name <em>*</em></label>
		<div class="field">
			<input type="text" id="applicationName" name="applicationName" value="#session.stFarcryInstall.stConfig.applicationName#" />
			<div class="fieldHint">Project folder name corresponds to the underlying installation folder and application name of your project.  It must adhere to the standard ColdFusion naming conventions for variables; namely start with a letter and consist of only letters, numbers and underscores.</div>
		</div>
		<div class="clear"></div>
	</div>
	<div class="item">
      	<label for="displayName">Administrator Password <em>*</em></label>
		<div class="field">
			<input type="text" id="adminPassword" name="adminPassword" value="#session.stFarcryInstall.stConfig.adminPassword#" />
			<div class="fieldHint">This is the password you will use to log in to your project with the "farcry" username.</div>
		</div>
		<div class="clear"></div>
	</div>	
	<div class="item">
      	<label for="applicationName">Update Application Key <em>*</em></label>
		<div class="field">
			<input type="text" id="updateappKey" name="updateappKey" value="#session.stFarcryInstall.stConfig.updateappKey#" />
			<div class="fieldHint">This is the key that can be used at the end of the url parameter [updateapp] to reinitialise your application. <strong>Administrators can use updateapp=1</strong></div>
		</div>
		<div class="clear"></div>
	</div>
	<div class="item">
      	<label for="applicationName">Locales <em>*</em></label>
		<div class="field">
			<cfset variables.aLocales = createObject("java","java.util.Locale").getAvailableLocales() />
			<cfset variables.lLocales = "" />
			<cfloop from="1" to="#arrayLen(variables.aLocales)#" index="i">
				<cfif listLen(variables.aLocales[i],"_") EQ 2>
					<cfset variables.lLocales = listAppend(variables.lLocales, "#variables.aLocales[i].toString()#:#variables.aLocales[i].getDisplayName()#") />
				</cfif>
			</cfloop>
			<cfset variables.lLocales = listSort(variables.lLocales,"textNoCase", "asc") />
			<input type="hidden" name="locales" value="">
			<select id="locales" name="locales" multiple="true" size="5">
				<cfloop list="#variables.lLocales#" index="i">
					<option value="#listFirst(i, ":")#" <cfif listFindNoCase(session.stFarcryInstall.stConfig.locales, listFirst(i, ":"))>selected</cfif>>#listLast(i, ":")#</option>
				</cfloop>
			</select>
			<div class="fieldHint">Set the relevant locales for your application.  Just because the locale can be selected does not mean a relevant translation is available.  If in doubt just leave the defaults.</div>
		</div>
		<div class="clear"></div>
	</div>			
	</cfoutput>
</cf_displayStep>

<cf_displayStep step="2">
	<cfoutput>
	<h1>Database Configuration</h1>
	<div class="item">
      	<label for="DSN">Project Datasource (DSN) <em>*</em></label>
		<div class="field">
			<input type="text" id="DSN" name="DSN" value="#session.stFarcryInstall.stConfig.DSN#" />
			<div class="fieldHint">You must type in the name of a valid datasource, preconfigured in the ColdFusion Administrator.  The database must be empty otherwise the installer will not proceed.</div>
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
			<div class="fieldHint">Funnily enough, your choice of database type must reflect the database your datasource is pointing to.</div>
		</div>
		<div class="clear"></div>
		<input type="hidden" name="DBType" value="">
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
	<input type="hidden" name="DBOwner" value=""><!--- Think makes sure that at the very least, an empty string is set for dbowner --->
	</cfoutput>
	
	<cfoutput>
	<script type="text/javascript">
		Ext.onReady(function(){	
			var field = Ext.get('DBType');
			field.on('change', checkDBType);
			
		});
		<cfif session.stFarcryInstall.stConfig.dbType EQ "mssql" OR session.stFarcryInstall.stConfig.dbType EQ "ora">
			var showingOwner = true;
		<cfelse>
			var showingOwner = false;
		</cfif>
				
		
		
		function checkDBType() {
			
			
			if(this.dom.value == "postgresql" || this.dom.value == "mysql" || this.dom.value == "")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = '';		
				
				if (showingOwner) {	
					var el = Ext.get('divDBOwner');	
				
					el.ghost('b', {
					    easing: 'easeOut',
					    duration: .5,
					    remove: false,
					    useDisplay: true
					});
					
					showingOwner = false;
				}
					
			}
			else if (this.dom.value == "ora")
			{
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = 'username.';		
				
				
				var el = Ext.get('divDBOwner');	
			
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
				
				showingOwner = true;
				
			}
			else 
			{		
				
				var DBOwner = Ext.get('DBOwner');
				DBOwner.dom.value = 'dbo.';		
				
			
				var el = Ext.get('divDBOwner');	
			
				el.slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
				
				showingOwner = true;
				
			}
		}
	</script>	
	</cfoutput>
</cf_displayStep>


<cf_displayStep step="3">
	<cfoutput>
	<h1>Project Skeleton</h1>
    <div class="item">
      	<label for="skeleton">Skeleton <em>*</em></label>
		<div class="field">
			<select id="skeleton" name="skeleton">
				<option value="">-- Select Skeleton --</option>
				<cfloop query="qSkeletons">
					<cfif qSkeletons.type EQ "DIR" and fileExists("#skeletonPath#/#qSkeletons.name#/install/manifest.cfc")>
						<cfset oManifest = createObject("component", "farcry.skeletons.#qSkeletons.name#.install.manifest") />
						<option value="farcry.skeletons.#qSkeletons.name#" <cfif session.stFarcryInstall.stConfig.skeleton EQ "farcry.skeletons.#qSkeletons.name#">selected</cfif>>
							#oManifest.name# (#IIF(oManifest.isSupported(coreMajorVersion="#request.coreVersion.major#", coreMinorVersion="#request.coreVersion.minor#", corePatchVersion="#request.coreVersion.patch#"), de("Supported"), de("Unsupported"))#)
						</option>
					</cfif>
				</cfloop>
				<cfif isDefined("qProjectSkeletons")>
					<cfloop query="qProjectSkeletons">
						<cfif qProjectSkeletons.type EQ "DIR" and fileExists("#projectsPath#/#qProjectSkeletons.name#/install/manifest.cfc")>
							<cfset oManifest = createObject("component", "farcry.projects.#qProjectSkeletons.name#.install.manifest") />
							<option value="farcry.projects.#qProjectSkeletons.name#" <cfif session.stFarcryInstall.stConfig.skeleton EQ "farcry.projects.#qProjectSkeletons.name#">selected</cfif>>
								#oManifest.name# (#IIF(oManifest.isSupported(coreMajorVersion="#request.coreVersion.major#", coreMinorVersion="#request.coreVersion.minor#", corePatchVersion="#request.coreVersion.patch#"), de("Supported"), de("Unsupported"))#)
							</option>
						</cfif>
					</cfloop>
				</cfif>
			</select>
			<div class="fieldHint">Skeletons are like sample applications.  They can contain specific templates, functionality and data.  Choose the skeleton that most closely resembles the application you are building.  If in doubt, select <strong>Mollio</strong> &##8212; its a simple web application.</div>
		</div>
		<div class="clear"></div>
	</div>
	</cfoutput>
	

</cf_displayStep>


<cf_displayStep step="4">

	
	<cfoutput>
	<h1>Plugins</h1>
	<p>Plugins are code libraries that can be added to your project to change the look and feel, extend existing functionality or even add completely new features.  Your choice of "skeleton" will have pre-selected those plugins required for your skeleton to work properly. Feel free to add additional plugins that you think might be useful &##8212; remember, you can always uninstall or install plugins at a later date.</p>
	<p>&nbsp;</p>
	
	<!--- set plugins to blank in case no plugins are listed at all and skeleton is requiring one --->
    <input type="hidden" name="plugins" value="" />
		<div class="plugins">
		<cfloop query="qPlugins">
			<cfif qPlugins.type EQ "DIR" and fileExists("#pluginPath#/#qPlugins.name#/install/manifest.cfc")>
				<cfset oManifest = createObject("component", "farcry.plugins.#qPlugins.name#.install.manifest")>
				<cfset pluginSupported = oManifest.isSupported(coreMajorVersion="#request.coreVersion.major#",coreMinorVersion="#request.coreVersion.minor#",corePatchVersion="#request.coreVersion.patch#")>
				
				<div id="plugin-#qPlugins.name#">
					<table cellspacing="10" cellpadding="0" class="plugin">
					<tr>
						<td valign="top" width="25px;">
							<input type="checkbox" id="plugin#qPlugins.name#" name="plugins" value="#qPlugins.name#" <cfif listContainsNoCase(session.stFarcryInstall.stConfig.plugins, qPlugins.name)>checked</cfif>>
						</td>
						<td valign="top">
							<p>
								<strong>#oManifest.name#</strong> <cfif not pluginSupported>(unsupported)</cfif> <br />
								<em>#oManifest.description#</em>
							</p>
							<cfif directoryExists("#pluginPath#/#qPlugins.name#/www") >
								<cfif listContainsNoCase(session.stFarcryInstall.stConfig.plugins, qPlugins.name)>
									<cfset pluginMappingDisplay = 'block' />
								<cfelse>
									<cfset pluginMappingDisplay = 'none' />
								</cfif>
								<table cellspacing="10" cellpadding="0" id="plugin#qPlugins.name#AddWebroot" style="display:#pluginMappingDisplay#;">
								<tr>
									<td valign="top" width="25px;">
										<input type="checkbox" id="addWebrootMapping#qPlugins.name#" name="addWebrootMapping#qPlugins.name#" value="1" <cfif not isDefined("session.stFarcryInstall.stConfig.addWebrootMapping#qPlugins.name#") or session.stFarcryInstall.stConfig["addWebrootMapping#qPlugins.name#"]>checked</cfif>>
									</td>
									<td>
										<p><strong>Copy Plugin Webroot to project</strong></p>
										<div class="fieldHint">This plugin requires a webroot mapping. You can create the webroot mapping on your webserver, or alteratively you can select to have the webroot copied into your project to avoid having to create the mapping.</div>
									</td>
								</tr>
								</table>
								<input type="hidden" name="addWebrootMapping#qPlugins.name#" value="0" />
									<script type="text/javascript">
									Ext.onReady(function(){	
										var field = Ext.get('plugin#qPlugins.name#');
										field.on('change', checkPluginWebroot);
										
									})
									</script>
							</cfif>
							

						</td>
					</tr>
					</table>
				</div>
				
				
			<!--- 	
				<cfif not pluginSupported>
					
					<cf_redoStep field="plugin-#qPlugins.name#" errorTitle="Unsupported" errorDescription="This plugin is not supported on your current version of farcry. Please be aware you may experience problems with this plugin." />
				
				</cfif>
					 --->

			</cfif>
		</cfloop>
		</div>

	</cfoutput>	
	
	<cfoutput>
	<script type="text/javascript">
		
		function checkPluginWebroot() {
			
			
			
			if(this.dom.checked)
			{
				Ext.get(this.id + 'AddWebroot').slideIn('t', {
				    easing: 'easeIn',
				    duration: .5,
				    useDisplay: true
				});	
					
			}
			else 
			{
				
				Ext.get(this.id + 'AddWebroot').ghost('b', {
				    easing: 'easeOut',
				    duration: .5,
				    remove: false,
				    useDisplay: true
				});
			}
		}
	</script>	
	</cfoutput>
</cf_displayStep>


<cf_displayStep step="5">
	<cfoutput>
	<h1>Deployment Configuration</h1>
	<p>FarCry Core can support a variety of different configurations for deployment.  The installer supports three options.  If you are after a custom deployment option select "Advanced Configuration".</p>
	<p>&nbsp;</p>
	
	
	<div class="section">		
		<h3>
			<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
				<input type="radio" id="projectInstallType" name="projectInstallType" disabled="true" value="SubDirectory">
				<span style="text-decoration:line-through;">Sub-Directory</span>
			<cfelse>
				<input type="radio" id="projectInstallType" name="projectInstallType" value="SubDirectory" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "SubDirectory">checked</cfif>>
				Sub-Directory
			</cfif>
		</h3>
		<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
			<p><strong style="color:red;">You can't install as a sub-directory when a project exists in the webroot</strong></p>
		</cfif>
		<p>For multiple application deployment under a single webroot.  If you only have a single web site configured for your server, and would like to run multiple FarCry applications select me.</p>
		<p>Note each application will run under its own sub-directory, for example: http://localhost:8500/myproject</p>
	</div>
	
	<div class="section">	
		<h3>
			<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
				<input type="radio" id="projectInstallType" name="projectInstallType" disabled="true" value="Standalone">
				<span style="text-decoration:line-through;">Standalone</span>
			<cfelse>
				<input type="radio" id="projectInstallType" name="projectInstallType" value="Standalone" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "Standalone">checked</cfif>>
				Standalone
			</cfif>
		</h3>
		<cfif fileExists(expandPath("/farcryConstructor.cfm"))>
			<p><strong style="color:red;">You can't install as standalone when a project exists in the webroot</strong></p>
		</cfif>
		<p>Specifically aimed at one application per website. For standalone application deployment and/or shared hosting deployment that allows for a single project select me.</p>
		<p>Note the application will run directly under the webroot, for example: http://localhost/</p>
	</div>
	
	<div class="section">		
		<h3>
			<input type="radio" id="projectInstallType" name="projectInstallType" value="CFMapping" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "CFMapping">checked</cfif>>
			Advanced Configuration (ColdFusion and/or Web Server Mappings)
		</h3>
		<p>An enterprise configuration that allows for an unlimited number of projects to share a single core framework and library of plugins. Sharing is done through common reference to specific ColdFusion mapping or specific web server mapping (aka web virtual directory) of /farcry.</p>
		<p>Note this is an advanced option for custom configurations and deployments.  You may need to perform additional configuration to make your FarCry application operational.  Only select me if you know what you are doing.
	</div>
			
	
	<!--- <div class="item">
      	<label>Project Install Type</label>
		<div class="field">

			<input type="radio" id="section-subDirectory" name="section" value="subDirectory" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "subDirectory">checked</cfif>>Sub-Directory Under the web root<br />	
			<input type="radio" id="section-webroot" name="section" value="webroot" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "webroot">checked</cfif>>Into the web root<br />	
			<input type="radio" id="section-farcry" name="section" value="farcry" <cfif session.stFarcryInstall.stConfig.projectInstallType EQ "farcry">checked</cfif>>Keep in projects directory (Requires Webserver Mapping)<br />	
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
	</div> --->
	
	
	</cfoutput>		
</cf_displayStep>


<cf_displayStep step="6">

<cfoutput>
<h1>Installation Confirmation</h1>
<div class="section">
<div class="item summary">
	<label>Project Name:</label>
	<div class="field fieldDisplay">#session.stFarcryInstall.stConfig.displayName#</div>
	<div class="clear">&nbsp;</div>
</div>
<div class="item summary">
	<label>Project Folder Name:</label>
	<div class="field fieldDisplay">#session.stFarcryInstall.stConfig.applicationName#</div>
	<div class="clear">&nbsp;</div>
</div>
<div class="item summary">
	<label>Locales:</label>
	<div class="field fieldDisplay">
			<cfset variables.aLocales = createObject("java","java.util.Locale").getAvailableLocales() />
			<cfset variables.lLocales = "" />
			<cfloop from="1" to="#arrayLen(variables.aLocales)#" index="i">
				<cfif listLen(variables.aLocales[i],"_") EQ 2>
					<cfset variables.lLocales = listAppend(variables.lLocales, "#variables.aLocales[i].toString()#:#variables.aLocales[i].getDisplayName()#") />
				</cfif>
			</cfloop>
			<cfset variables.lLocales = listSort(variables.lLocales,"textNoCase", "asc") />
			<cfloop list="#variables.lLocales#" index="i">
				<cfif listFindNoCase(session.stFarcryInstall.stConfig.locales, listFirst(i, ":"))>
					#listLast(i, ":")#<br />
				</cfif>
			</cfloop>

	</div>
	<div class="clear">&nbsp;</div>
</div>
</div>

<div class="section">
<div class="item summary">
	<label>DSN:</label>
	<div class="field fieldDisplay">#session.stFarcryInstall.stConfig.dsn#</div>
	<div class="clear">&nbsp;</div>
</div>
<div class="item summary">
	<label>Database Type:</label>
	<div class="field fieldDisplay">#session.stFarcryInstall.stConfig.dbType#</div>
	<div class="clear">&nbsp;</div>
</div>
<cfif len(session.stFarcryInstall.stConfig.dbOwner)>
	<div class="item summary">
		<label>Database Owner:</label>
		<div class="field fieldDisplay">#session.stFarcryInstall.stConfig.dbOwner#</div>
		<div class="clear">&nbsp;</div>
	</div>
</cfif>
</div>

<div class="section">
<div class="item summary">
	<label>Skeleton:</label>
	<div class="field fieldDisplay">
		<cfset oManifest = createObject("component", "#session.stFarcryInstall.stConfig.skeleton#.install.manifest")>
		#oManifest.name#
	</div>
	<div class="clear">&nbsp;</div>
</div>
</div>


<div class="section">
<div class="item summary">
	<label>Plugins:</label>
	<div class="field fieldDisplay">
		<cfloop list="#session.stFarcryInstall.stConfig.plugins#" index="PluginName">
			<cfset oManifest = createObject("component", "farcry.plugins.#PluginName#.install.manifest")>
			<div style="border:1px dotted ##e3e3e3;margin-bottom:10px;padding:5px;">
				#oManifest.name# - #oManifest.description#
				<cfif isDefined("session.stFarcryInstall.stConfig.addWebrootMapping#PluginName#") AND session.stFarcryInstall.stConfig["addWebrootMapping#PluginName#"]>
					<div class="fieldHint">COPYING WEBROOT</div>
				</cfif>
			</div>
		</cfloop>
	</div>
	<div class="clear">&nbsp;</div>
</div>
</div>


<div class="section">
<div class="item summary">
	<label>Project Webroot Install Type:</label>
	<div class="field fieldDisplay">
		<cfswitch expression="#session.stFarcryInstall.stConfig.projectInstallType#">
			<cfcase value="SubDirectory">
				A sub-directory under the web root
			</cfcase>
			<cfcase value="Standalone">
				Directly into the web root
			</cfcase>
			<cfdefaultcase>
				Into /farcry/projects/#session.stFarcryInstall.stConfig.applicationName#/www
			</cfdefaultcase>
		</cfswitch>
	</div>
	<div class="clear">&nbsp;</div>
</div>
</div>
</cfoutput>	
</cf_displayStep>



<cfoutput>
</form>
</cfoutput>




<cfoutput>
		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>You are currently running version <strong>#request.coreVersion.major#-#request.coreVersion.minor#-#request.coreVersion.patch#</strong> of Farcry Core.</small></p>
	</div>
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
	
	<!--- Plugins --->
	<cfset pluginPath = expandPath('/farcry/plugins') />
	<cfdirectory action="list" directory="#pluginPath#" name="qPlugins" />
	
	<!--- Project --->
	<cfset projectsPath = expandPath('/farcry/projects') />
	<cfdirectory action="list" directory="#projectsPath#" name="qProjects" />
	
	
	<!--- Base --->
	<cfset baseProjectPath = expandPath('/farcry/core/webtop/install/base') />
	
	<!--- Webroot --->
	<cfset webrootPath = expandPath('/') />
	
	<!--- Webtop --->
	<cfset webtopPath = expandPath('/farcry/core/webtop') />
		
	
	
	
	<!--- FIND ANY PROJECTS THAT ARE SKELETONS --->

	<cfloop query="qProjects">
		<cfif qProjects.type EQ "DIR">

			<cfif fileExists("#qProjects.directory#/#qProjects.name#/install/manifest.cfc")>
				
				<cfquery dbtype="query" name="qCurrentProject">
				SELECT * FROM qProjects
				WHERE name = '#qProjects.name#'
				</cfquery>
				
				<cfif isDefined("qProjectSkeletons")>
					<cfquery dbtype="query" name="qProjectSkeletons">
					SELECT * FROM qProjectSkeletons
					UNION
					SELECT * FROM qCurrentProject
					</cfquery>
				<cfelse>
					<cfquery dbtype="query" name="qProjectSkeletons">
					SELECT * FROM qCurrentProject
					</cfquery>
				</cfif>

			</cfif>
		</cfif>
	</cfloop>
	
	<cfif not qSkeletons.recordCount AND not qProjectSkeletons.recordCount>
		<cfoutput>You have no farcry skeleton projects to install.</cfoutput>
		<cfabort>
	</cfif>

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
