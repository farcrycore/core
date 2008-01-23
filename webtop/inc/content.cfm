<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin">


<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry</title>
<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
</head>
<body class="iframed-content">

	<cfparam name="url.sec" default="" type="string">

	<admin:subSectionOverview sectionid="#url.sec#" webTop="#application.factory.owebtop#" />
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false" />