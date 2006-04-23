<cfsetting enablecfoutputonly="Yes">

<cfapplication name="farcry_migration" sessionmanagement="Yes">

<cfscript>
// root install directories + webroot
application.url.webroot = ""; // leave blank if farcry hosted as site

application.dsn = ""; // needed so fourq tags don't break
application.dbtype = "odbc";
application.dbowner = "dbo.";

// application paths
application.path.core = replaceNoCase(getCurrentTemplatePath(), "\farcry_core\admin\migration\Application.cfm", "") & "\farcry_core";
application.path.project = replaceNoCase(getCurrentTemplatePath(), "\farcry_core\admin\migration\Application.cfm", "") & "\integralMX";

application.defaultFilePath = application.path.project & "\www\files";
application.defaultImagePath = application.path.project & "\www\images";

// application Packages path
application.packagepath = "farcry.farcry_core.packages";
application.securitypackagepath = application.packagepath & ".security";

// persistent objects
application.o_q4 = createObject("component", "farcry.fourq.fourq");
application.o_dmTree = createObject("component", "#application.packagepath#.farcry.tree");
application.o_dmNav = createObject("component", "#application.packagepath#.types.dmNavigation");
application.o_dmHTML = createObject("component", "#application.packagepath#.types.dmHTML");
application.o_dmInclude = createObject("component", "#application.packagepath#.types.dmInclude");
application.o_dmImage = createObject("component", "#application.packagepath#.types.dmImage");
application.o_dmFile = createObject("component", "#application.packagepath#.types.dmFile");
application.o_dmNews = createObject("component", "#application.packagepath#.types.dmNews");
application.o_category = createObject("component", "#application.packagepath#.farcry.category");
application.o_ruleHandPicked = createObject("component", "#application.packagepath#.rules.ruleHandpicked");

// Java classes
application.o_serviceFactory = createObject("Java", "coldfusion.server.ServiceFactory");
application.o_stringReader = createObject("Java", "java.io.StringReader");
application.o_inputSource = createObject("Java", "org.xml.sax.InputSource");

application.o_wddxDeserializer = createObject("Java", "com.allaire.wddx.WddxDeserializer");
application.o_wddxDeserializer.init("com.jclark.xml.sax.Driver");

application.o_dmSecInit = createObject("component", "#application.packagepath#.security.init");

// initialise any server structs that are non existant
rc = application.o_dmSecInit.initServer();
// initialise any session structs that are non existant
rc = application.o_dmSecInit.initSession();

// determing browser being used
if (CGI.HTTP_USER_AGENT contains "MSIE") browser = "IE";
else browser = "NS";
</cfscript>

<cfsetting enablecfoutputonly="No">
