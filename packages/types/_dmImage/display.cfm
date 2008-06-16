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
$Header: /cvs/farcry/core/packages/types/_dmImage/display.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: display handler$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<!--- display all images --->
<cfif stObj.thumbnailimage neq "">
	<cfoutput>#application.rb.getResource("thumbnailLabel")# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.thumbnailimage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.standardimage neq "">
	<cfoutput>Standard Image <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.StandardImage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>
<cfif stObj.sourceimage neq "">
	<cfoutput>#application.rb.getResource("imageLabel")# <br /><div style="margin-left:20px;margin-top:20px;"><img src="#application.url.webroot##stObj.sourceimage#" alt="#stObj.alt#" border="0"></div></cfoutput>
</cfif>

<cfif stObj.sourceimage eq "" and stObj.thumbnailimage eq "" and stObj.standardimage eq "">
	<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
</cfif> 
<cfsetting enablecfoutputonly="No">