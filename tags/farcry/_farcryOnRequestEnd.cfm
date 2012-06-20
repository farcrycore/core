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

<!--- If we are in the middle of a <skin:location> or we failed to init then we dont want to output a bunch of javascript --->
<cfif not structKeyExists(request.fc, "bLocating") and not structKeyExists(request,"fcInitError")>

	<skin:pop format="gritter" />



	
	<!--- Add the loaded libraries into the header --->
	<core:cssInHead />
	<core:jsInHead />
	
	
	
	<cfif structKeyExists(Request,"inHead") AND NOT structIsEmpty(Request.InHead) AND NOT request.mode.ajax>		
	<!--- Check for each stPlaceInHead variable and output relevent html/css/js --->
			
	<cfsavecontent variable="variables.placeInHead">		
				
		<!--- This is the result of any skin:htmlHead calls --->
		<cfparam name="request.inhead.stCustom" default="#structNew()#" />
		<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aCustomIDs)>
			<cfloop from="1" to="#arrayLen(request.inHead.aCustomIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stCustom, request.inHead.aCustomIDs[i])>
					<cfoutput>
					#request.inHead.stCustom[request.inHead.aCustomIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
		</cfif>
		
			
		<!--- This is the result of any skin:onReady calls --->
		<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
		<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aOnReadyIDs)>
			<cfoutput>
			<script type="text/javascript">
				$j(document).ready(function() {	
			</cfoutput>
			
			<cfloop from="1" to="#arrayLen(request.inHead.aOnReadyIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stOnReady, request.inHead.aOnReadyIDs[i])>
					<cfoutput>
					#request.inHead.stOnReady[request.inHead.aOnReadyIDs[i]]#
					</cfoutput>
				</cfif>
			</cfloop>
			
			<cfoutput>
				})
			</script>
			</cfoutput>
			
		</cfif>
	
	</cfsavecontent>
	
	<cfif len(variables.placeInHead)>
		<cftry>
 			<cfhtmlHead text="#variables.placeInHead#" />
			<cfcatch type="any">
				<cfset application.fapi.throw(argumentCollection="#cfcatch#") />
			</cfcatch>
		</cftry>	
	</cfif>
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
</cfif>


<cfsetting enablecfoutputonly="no">