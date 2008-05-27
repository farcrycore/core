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
$Header: /cvs/farcry/core/packages/farcry/_tree/getChildren.cfm,v 1.8.2.1 2006/01/18 23:46:54 paul Exp $
$Author: paul $
$Date: 2006/01/18 23:46:54 $
$Name: milestone_3-0-1 $
$Revision: 1.8.2.1 $

|| DESCRIPTION || 
$Description: getChildren Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfquery datasource="#arguments.dsn#" name="children">
select objectid, objectname,nLeft,nRight,nLevel from #arguments.dbowner#nested_tree_objects
where parentid =  '#arguments.objectid#'
order by nleft
</cfquery>

<!--- set return variable --->
<cfset qReturn=children>

<cfsetting enablecfoutputonly="no">