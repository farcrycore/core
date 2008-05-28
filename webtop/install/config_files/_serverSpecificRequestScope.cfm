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
$Header: $
$Author:  $
$Date:  $
$Name:  $
$Revision:  $

|| DESCRIPTION || 
$Description: 	This file is run after /core/tags/farcry/_requestScope.cfm
				It enables us to both override the default farcry request scope variables and also add our own
$

|| DEVELOPER ||mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">
	
<!--- Setup for specific developers --->
<cfswitch expression="#application.sysInfo.machineName#">
	
	
	<cfdefaultcase>
		<cfscript>
			request.mode.bDeveloper = 0; // Developer Mode
		</cfscript>	
	</cfdefaultcase> 
	
	
</cfswitch>
	
	
<cfsetting enablecfoutputonly="no">