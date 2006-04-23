<cfsetting enablecfoutputonly="Yes">

<cfapplication name="farcry_install" sessionmanagement="Yes">

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

// initialise any server structs that are non existant
rc = application.o_dmSecInit.initServer();
// initialise any session structs that are non existant
rc = application.o_dmSecInit.initSession();

// determing browser being used
if (CGI.HTTP_USER_AGENT contains "MSIE") browser = "IE"; else browser = "NS";
</cfscript>

<cfsetting enablecfoutputonly="No">
