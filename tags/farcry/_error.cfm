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
$Header: /cvs/farcry/core/tags/farcry/_error.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: basic error control page. Emails administrator and shows dump if requested$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- email administrator --->
<cfmail to="#application.config.general.ADMINEMAIL#" from="#application.config.general.ADMINEMAIL#" subject="Error in #application.applicationname#" type="html">
<cfdump var="#error#" label="Error Diagnostics">
</cfmail>

<!--- dump error diagnostics for developers --->
<cfif isdefined("url.debug")>
	<!--- reset dump variable in request scope to try cf into thinking it hasn't already dumped on the page --->
	<cfset request.cfdumpinited = false>
	<p></p><cfdump var="#error#" label="Error Diagnostics">
</cfif>