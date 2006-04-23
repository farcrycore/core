<cfsetting enablecfoutputonly="Yes">

<cfscript>
application.dsn = "farcry_pliant";
application.dbtype = "odbc";
application.dbowner = "dbo."; // don't forget the "."

application.path.project = replaceNoCase(replace(getCurrentTemplatePath(),"\","/","all"),"/config/_serverSpecificVars.cfm","");
application.path.core = listDeleteAt(application.path.project,listlen(application.path.project,"/"),"/") & "/farcry_core";
	
// application web urls
application.url.webroot = "";
application.url.farcry = application.url.webroot & "/farcry"; //admin
	
application.packagepath = "farcry.farcry_core.packages";
application.custompackagepath = "farcry.#application.applicationname#.packages";
application.securitypackagepath = application.packagepath & ".security";
</cfscript>

<cfsetting enablecfoutputonly="no">