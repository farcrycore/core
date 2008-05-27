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
$Header: /cvs/farcry/core/tags/webskin/simpleSearch.cfm,v 1.2 2003/09/25 23:28:08 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 23:28:08 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$DESCRIPTION: Simple search form$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
--->

<cfsetting enablecfoutputonly="Yes">
<cfoutput>
<form action="#application.url.conjurer#?objectid=#application.navid.search#" method="post">
<input type="text" name="criteria" value="">
<input type="submit" name="action" value="Search">
</form>
</cfoutput>
<cfsetting enablecfoutputonly="No">
