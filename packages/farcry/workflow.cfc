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
$Header: /cvs/farcry/core/packages/farcry/workflow.cfc,v 1.8 2005/10/24 06:10:13 guy Exp $
$Author: guy $
$Date: 2005/10/24 06:10:13 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: workflow cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Workflow" hint="Workflow methods">
	<cffunction name="getObjectApprovers" access="public" returntype="struct" hint="Returns all users that can approve pending objects">
		<cfargument name="objectID" type="UUID" required="yes">
		
		<cfinclude template="_workflow/getObjectApprovers.cfm">
		
		<cfreturn stApprovers>
	</cffunction>
	
</cfcomponent>