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
$Header: /cvs/farcry/core/packages/security/user.cfc,v 1.5 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: user cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="User Functions" hint="Functions dealing with FarCry Users">
	<cffunction name="updatePassword" access="public" returntype="boolean" hint="Updates a user's password">
		<cfargument name="userId" type="string" required="true">
		<cfargument name="oldPassword" type="string" required="true">
		<cfargument name="newPassword" type="string" required="true">
		<cfargument name="newPassword2" type="string" required="true">
		<cfargument name="dsn" type="string" required="true" hint="Database DSN">
		
		<cfinclude template="_user/updatePassword.cfm">
		
		<cfreturn bUpdate>
	</cffunction>
</cfcomponent>