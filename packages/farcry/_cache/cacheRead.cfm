<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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