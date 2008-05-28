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
|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Guy Phanvongsa (guy@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmcss">

<!--- set up page header --->
<admin:header title="Includes Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmInclude"
	permissionset="news"
	title="Includes Administration"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
