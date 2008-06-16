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
$Header: /cvs/farcry/core/packages/farcry/reporting.cfc,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: reporting cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="reporting" hint="Functions for reporting on my farcry tab">
	<cffunction name="getAgeBreakdown" access="public" returntype="struct" hint="Returns a count of objects broken down into date segments">
		<cfargument name="breakdown" type="string" required="false" default="25,50,75,100">
				
		<cfinclude template="_reporting/getAgeBreakdown.cfm">
		
		<cfreturn stAge>
	</cffunction>

	<cffunction name="getRecentObjects" access="public" returntype="struct" hint="Returns a recent list of Objects added to the system">
		<cfargument name="numberOfObjects" type="string" required="false" default="5">
		<cfargument name="objectType" type="string" required="true">
				
		<cfinclude template="_reporting/getRecentObjects.cfm">
		
		<cfreturn stRecentObjects>
	</cffunction>
</cfcomponent>