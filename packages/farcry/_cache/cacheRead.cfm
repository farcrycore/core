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
$Header: /cvs/farcry/core/packages/farcry/_cache/cacheRead.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: read Cache Function $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cflock timeout="10" throwontimeout="No" name="GeneratedContentCache_#application.applicationname#" type="READONLY">
	<cfset success = true>
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<cfif structkeyexists(contentcache, cachelookupname)>
		<cfif contentcache[cachelookupname].cachetimestamp gt arguments.dtCachetimeout>
			<cfoutput>#contentcache[cachelookupname].cache#</cfoutput>
			
			<!--- Place any request.inHead variables back into the request scope from which it came. --->
			<cfif structKeyExists(contentcache[cachelookupname], "inHead")>
				<cfparam name="request.inHead" default="#structNew()#" />
				<cfloop list="#structKeyList(contentcache[cachelookupname].inHead)#" index="i">
					<cfset request.inhead[i] = contentcache[cachelookupname].inHead[i] />
				</cfloop>
			</cfif>
			<cfset read = true>
		<cfelse>
			<cfset read = false>
		</cfif>
	</cfif>
</cflock>