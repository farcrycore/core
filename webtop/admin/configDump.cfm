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
$Header: /cvs/farcry/core/webtop/admin/configDump.cfm,v 1.7 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$DESCRIPTION: Dumps config values$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	<h3>Config Dumps</h3>
	
	<!--- loop over all configs and dump the contents of them --->
	<cfloop collection="#application.config#" item="config">
		<cfdump var="#application.config[config]#" label="#config#"><cfoutput><p>&nbsp;</p></cfoutput>
	</cfloop>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">