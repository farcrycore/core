<cfsetting enablecfoutputonly="yes">

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
$Header: /cvs/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name:  $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Functionality to be run at the end of every page, including stats logging$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/tags/core" prefix="core" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />
<cfparam name="request.MODE.LVALIDSTATUS" default="approved">
<cfparam name="request.MODE.FLUSHCACHE" default="false">

<skin:pop format="gritter" />

<!--- Add the loaded libraries into the header --->
<cfif not isdefined("request.mode.ajax") or not request.mode.ajax>
	<core:inHead variable="aHead" />
	
	<cfloop from="1" to="#arraylen(aHead)#" index="i">
		<cfif aHead[i].id eq "onReady">
			<cfhtmlHead text="<script type='text/javascript'>$j(document).ready(function(){ #aHead[i].html# });</script>" />
		<cfelse>
			<cfhtmlHead text="#aHead[i].html#" />
		</cfif>
	</cfloop>
</cfif>

<cfif not GetPageContext().GetResponse().IsCommitted()>
	<cfif isdefined("request.fc.okToCache") and request.fc.okToCache>
		<!--- Page ok to cache, a webskin has specified a cache timeout --->
		<cfif not isdefined("request.fc.browserCacheTimeout") or request.fc.browserCacheTimeout eq -1>
			<cfset request.fc.browserCacheTimeout = application.defaultBrowserCacheTimeout />
		</cfif>
		<cfif not isdefined("request.fc.proxyCacheTimeout") or request.fc.proxyCacheTimeout eq -1>
			<cfset request.fc.proxyCacheTimeout = application.defaultProxyCacheTimeout />
		</cfif>
	<cfelse>
		<cfset request.fc.browserCacheTimeout = 0 />
		<cfset request.fc.proxyCacheTimeout = 0 />
	</cfif>
	<misc:cacheControl browserSeconds="#request.fc.browserCacheTimeout#" proxySeconds="#request.fc.proxyCacheTimeout#" />
</cfif>


<cfsetting enablecfoutputonly="no">