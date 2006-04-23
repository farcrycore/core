<cfsetting requestTimeout="600">

<!--- determing config files path --->
<cfset configFilePath = application.path.core & "/admin/install/config_files">

<!--- create config directory for farcry project --->
<cfif not directoryExists("#application.path.project#/config")>
    <cfdirectory action="CREATE" directory="#application.path.project#/config">
</cfif>

<!--- create config files in config directory --->
<cffile action="READ" file="#configFilePath#/_applicationInit.cfm" variable="appInit">
<cffile action="READ" file="#configFilePath#/_dmSecUserDirectories.cfm" variable="userDirs">
<cffile action="READ" file="#configFilePath#/_serverSpecificVars.cfm" variable="serverVars">

<cfscript>
serverVars = replaceNoCase(serverVars, "application.dsn = ""farcry_aura""", "application.dsn = ""#application.dsn#""");
serverVars = replaceNoCase(serverVars, "application.dbtype = ""odbc""", "application.dbtype = ""#form.dbType#""");
serverVars = replaceNoCase(serverVars, "application.dbowner = ""dbo.""", "application.dbowner = ""#application.dbOwner#""");
if (form.appMapping neq "/") {
	serverVars = replaceNoCase(serverVars, "application.url.webroot = """"", "application.url.webroot = ""#form.appMapping#""");
	serverVars = replaceNoCase(serverVars, "application.url.farcry = application.url.webroot & ""/farcry""", "application.url.farcry = ""#form.farcryMapping#""");
}
else {
	serverVars = replaceNoCase(serverVars, "application.url.webroot = """"", "application.url.webroot = """"");
}
</cfscript>

<cffile action="WRITE" file="#application.path.project#/config/_applicationInit.cfm" output="#appInit#" addnewline="Yes">
<cffile action="WRITE" file="#application.path.project#/config/_dmSecUserDirectories.cfm" output="#userDirs#" addnewline="Yes">
<cffile action="WRITE" file="#application.path.project#/config/_serverSpecificVars.cfm" output="#serverVars#" addnewline="Yes">

<!--- create Application.cfm in project path --->
<cffile action="READ" file="#configFilePath#/Application.cfm" variable="appCFM">
<cfset appCFM = replaceNoCase(appCFM, "<cfapplication name=""farcry_aura"" sessionmanagement=""Yes"" sessiontimeout=""##createTimeSpan(0,1,0,0)##"">", "<cfapplication name=""#form.siteName#"" sessionmanagement=""Yes"" sessiontimeout=""##createTimeSpan(0,1,0,0)##"">")>
<cffile action="WRITE" file="#application.path.project#/www/Application.cfm" output="#appCFM#" addnewline="Yes">

<!--- modify apps.cfm file --->
<!--- added by Gary Menzel --->
<CFTRY>
	<!--- see if we can load the apps.cfm to initialise the stApps structure --->
	<CFINCLUDE template="/farcry/apps.cfm">
	<CFCATCH>
		<!--- otherwise - create an stApps structure --->
		<CFSCRIPT>
		stApps = StructNew();
		</CFSCRIPT>
	</CFCATCH>
</CFTRY>

<!--- add the new site in with the domain provided --->
<CFSCRIPT>
	stApps[form.domain] = form.siteName;
</CFSCRIPT>

<!--- compose the "script" for apps.cfm --->
<CFSET appsFile = "<cfscript>#chr(13)##chr(10)#stApps = structNew();#chr(13)##chr(10)#">
<CFLOOP collection="#stApps#" item="site">
	<CFSET appsFile = appsFile & "stApps['#site#'] = '#stApps[site]#';#chr(13)##chr(10)#">
</CFLOOP>
<CFSET appsFile = appsFile & "</cfscript>">

<!--- write the updated apps.cfm back out --->
<cffile action="WRITE" file="#basePath#/apps.cfm" output="#appsFile#">
<!--- ABOVE added by Gary Menzel --->


<!--- commented out by Gary Menzel
<cfset appsFile = "<cfscript>#chr(13)##chr(10)#stApps = structNew();#chr(13)##chr(10)#stApps['#form.domain#'] = '#form.siteName#'; // name of physical directory for your FarCry Application#chr(13)##chr(10)#</cfscript>">
<cffile action="WRITE" file="#basePath#/apps.cfm" output="#appsFile#">
--->
