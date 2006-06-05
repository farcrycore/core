<cfsetting enablecfoutputonly="Yes">

<cfparam name="form.sitename" default="farcry">

<cfapplication name="#form.sitename#" sessionmanagement="Yes">

<!--- Logout and destroy session variables --->
<cfloop list="#structkeylist(application)#" index="a">
	<cfif a neq "applicationname">
		<cfset selfdestruct = StructDelete(application,a)>
	</cfif>
</cfloop>
<cfloop list="#structkeylist(session)#" index="a">
	<cfif a neq "sessionid" and a neq "cfid">
		<cfset selfdestruct = StructDelete(session,a)>
	</cfif>
</cfloop>
	
<cfset lAllowHosts = "127.0.0.1">
<cfif NOT listFindNoCase(lAllowHosts,cgi.remote_addr)>
	<cfthrow errorcode="install_invalid_host" detail="Your IP address is not permitted to access the install directory." extendedinfo="By default, installation is only permitted to the following hosts : 127.0.0.1  To give access to other hosts, then append the desired IP address to the variable lAllowHosts in /farcry_core/admin/install/application.cfm">
</cfif>

<cfscript>
// root install directories + webroot
application.url.webroot = ""; // leave blank if farcry hosted as default/root site

// CF mappings
if (not isDefined("application.path.core")) {
    application.o_mappings = createObject("component", "cfmxmappings");
    application.o_mappings.addMapping(mapping="farcry", path=REreplaceNoCase(getCurrentTemplatePath(), "[/\\]farcry_core[/\\]admin[/\\]install[/\\]Application.cfm", ""));
	//application.o_mappings.addMapping(mapping="farcry", path=replaceNoCase(getCurrentTemplatePath(), "\farcry_core\admin\install\Application.cfm", ""));

    // application paths
    application.path.core = replaceNoCase(replace(getCurrentTemplatePath(),"\","/","all"), "/farcry_core/admin/install/Application.cfm", "") & "/farcry_core";

    // application Packages path
    application.packagepath = "farcry.farcry_core.packages";
    application.securitypackagepath = application.packagepath & ".security";
}

// persistant objects
application.o_serviceFactory = createObject("java", "coldfusion.server.ServiceFactory");
application.o_dmSecInit = createObject("component", "#application.packagepath#.security.init");
application.o_dmAuthentication = createObject("component", "#application.packagepath#.security.authentication");
application.o_dmAuthorisation = createObject("component", "#application.packagepath#.security.authorisation");
application.factory.oAudit = createObject("component","#application.packagepath#.farcry.audit");

// initialise any server structs that are non existant
application.o_dmSecInit.initServer();
// initialise any session structs that are non existant
application.o_dmSecInit.initSession();

// determing browser being used
if (CGI.HTTP_USER_AGENT contains "MSIE") browser = "IE"; else browser = "NS";
</cfscript>

<cfsetting enablecfoutputonly="No">
