<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Standard Login Header --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
	<title>#application.config.general.siteTitle# :: #application.applicationname#</title>

	<!--- check for custom Admin CSS in project codebase --->
	<cfif fileExists("#application.path.project#/www/css/customadmin/admin.css")>
	    <link href="#application.url.webroot#/css/customadmin/admin.css" rel="stylesheet" type="text/css">
	<cfelse>
	    <link href="#application.url.farcry#/css/main.css" rel="stylesheet" type="text/css">
	</cfif>
</head>

<body id="sec-login">
<div id="login">
	
	<h1>
		<a href="#application.url.webroot#/index.cfm">
			<!--- if there is a site logo, use it instead of the default placeholder --->       
			<cfif structKeyExists(application.config.general,'siteLogoPath') and application.config.general.siteLogoPath NEQ "">
				<img src="#application.config.general.siteLogoPath#" alt="#application.config.general.siteTitle#" />
			<cfelse>
				<img src="#application.url.webtop#/images/logo_placeholder.gif" alt="#application.config.general.siteTitle#" />
			</cfif>
		</a>
		#application.config.general.siteTitle#
		<span>#application.config.general.siteTagLine#</span>
	</h1>
</cfoutput>

<cfsetting enablecfoutputonly="false">