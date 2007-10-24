<!--- resolve default iframe for this section view --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">

<cfparam name="url.sub" default="dynamic" type="string">
<cfparam name="url.sec" default="" type="string">
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>FarCry Sidebar</title>
		<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
	</head>
	<body class="iframed">
</cfoutput>
		
<admin:menu sectionid="#url.sec#" subsectionid="#url.sub#" webTop="#application.factory.owebtop#" />

<cfoutput>
	</body>
	</html>
</cfoutput>