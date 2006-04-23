<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_cache/cacheRead.cfm,v 1.3 2004/03/25 03:28:57 brendan Exp $
$Author: brendan $
$Date: 2004/03/25 03:28:57 $
$Name: milestone_2-2-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: read Cache Function $
$TODO: $

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
			<cfset read = true>
		<cfelse>
			<cfset read = false>
		</cfif>
	</cfif>
</cflock>