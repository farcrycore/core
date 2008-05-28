<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/custom/sidebar.cfm,v 1.4 2005/08/09 03:42:09 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:42:09 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Custom admin sidebar. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">

<cfparam name="url.sub" default="" type="string">
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
