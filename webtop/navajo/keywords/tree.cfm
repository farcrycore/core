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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/navajo/keywords/tree.cfm,v 1.7 2005/09/06 12:39:39 paul Exp $
$Author: paul $
$Date: 2005/09/06 12:39:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays category tree $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">

<cfoutput>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
<head>
</head>
<body class="iframed-content">
</cfoutput>
<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	oCat.displayTree();
</cfscript>
<cfoutput>
</body>
</html>
</cfoutput>
