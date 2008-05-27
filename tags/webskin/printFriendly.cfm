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
$Header: /cvs/farcry/core/tags/webskin/printFriendly.cfm,v 1.2 2003/09/25 23:28:09 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 23:28:09 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$DESCRIPTION: Creates a link to a printfriendly version of the page$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
--->

<cfsetting enablecfoutputonly="yes">
<cfparam name="attributes.linktext" default="Printer Friendly Version">

<cfoutput><a href="#application.url.webroot#/printFriendly.cfm?objectid=#url.objectid#" target="_blank">#attributes.linkText#</a></cfoutput>

<cfsetting enablecfoutputonly="no">
