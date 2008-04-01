<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Standard Core Header --->
<!--- @@description: Very basic header and is available to all content types  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.pageTitle" default="" />

<cfoutput>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>#application.config.general.sitetitle#: #stParam.pageTitle#</title>
</head>
<body>

	<div class="container">
	
		 <skin:genericNav navID="#application.navid.home#"
			id="nav"
			depth="2"
			bActive="true"
			bIncludeHome="true">	
			
</cfoutput>



<cfsetting enablecfoutputonly="false">