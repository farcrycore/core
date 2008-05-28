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
$Header: /cvs/farcry/core/webtop/content/dmhtml.cfm,v 1.2.2.1 2006/01/04 07:45:53 paul Exp $
$Author: paul $
$Date: 2006/01/04 07:45:53 $
$Name: milestone_3-0-1 $
$Revision: 1.2.2.1 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmhtml">

<!--- set up page header --->
<admin:header title="HTML Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmHTML"
	permissionset="news"
	title="#application.rb.getResource("SiteTreeContentHtmlAdministration")#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
