<cfsetting enablecfoutputonly="true" />
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
$Header$
$Author$
$Date$
$Name$
$Revision$

|| DESCRIPTION ||
$Description: Generic type administration. $
$TODO: i18n resource bundle update$
$TODO: requires specific permission set for access$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfdirectory action="list" directory="#application.config.general.ARCHIVEDIRECTORY#" name="qFiles" filter="*" />


<!--- set up page header --->
<admin:header title="Archived Media Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<cfoutput>
<h1>Archived Media Assets</h1>
<p>Archive: #application.config.general.ARCHIVEDIRECTORY#</p>
</cfoutput>

<cfdump var="#qFiles#">

<admin:footer>
<cfsetting enablecfoutputonly="false" />