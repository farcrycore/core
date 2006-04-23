<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/cache.cfm,v 1.6 2003/04/16 07:11:28 brendan Exp $
$Author: brendan $
$Date: 2003/04/16 07:11:28 $
$Name: b131 $
$Revision: 1.6 $

|| PRIMARY DEVELOPER ||
Aaron Shurmer (aaron@daemon.com.au)

|| MODIFICATIONS ||
Brendan Sisson (brendan@daemon.com.au) - modified to work on CFMX

|| DESCRIPTION || 
Content caches blocks of code.
This tag will handle cache nesting.

|| USAGE ||
<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">
<skin:cache hours="6" CacheBlockName="topbanneradd" cacheName="#Request.section#" paging=true>
	content!!
</skin:cache>

* Leaving all the timeperiods blank will result in a perminent cache.

Url Parameters that the cache responds to:
* url.flushcache: setting this will force a flush of all caches on the page.
* url.pgno: (page number) will append the page number to the name of the cache so that you can have paging caches on the same content cache (for container archives / etc).
* url.busecontentcache: this allows you to turn off the cacheing for this request for testing purposes.

CacheBlockName usage:
If you want to group together a bunch of caches so that they all flush with eachother then set this. It will take cacheBlockName and build a list of all the 
cacheName caches that are sent to it, upon flushing, it will flush anything in this list when it flushes the current cache.


|| ATTRIBUTES ||
paging				: optional, default = false. If set to true, it will utilize url.pgno to keep page caches.
cacheBlockName		: optional, required if a paging cache. Char for the name of a block of caches that you wish to be grouped together for flushing.
cacheName			: optional, but required if not a paging cache. Char for the name of the cache.
flushcache			: optional, boolean - force a flush programatically, true flushes.
days				: optional, cache days.
hours				: optional, cache hours.
minutes				: optional, cache minutes.
seconds				: optional, cache seconds.
r_output			: optional, return variable to put the cached content into.

|| HISTORY ||
$Log: cache.cfm,v $
Revision 1.6  2003/04/16 07:11:28  brendan
set default cacheBlockName to FarCry

Revision 1.5  2003/04/09 09:57:54  spike
Update with several bug fixes relating to using a single ColdFusion and web mapping

Revision 1.4  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.3  2002/10/14 04:47:15  brendan
updated to use cache cfc

Revision 1.2  2002/10/11 07:03:35  brendan
checks request mode instead of url

Revision 1.1  2002/10/01 06:23:48  brendan
no message

Revision 1.1  2002/10/01 00:52:50  brendan
no message

Revision 1.1  2002/09/30 23:56:51  brendan
new file for Cache control


|| END FUSEDOC ||
--->

<cfif thistag.executionmode is "start">
	<cfparam name="request.cachedcontentblocknumber" default="0">
	<cfset request.cachedcontentblocknumber = request.cachedcontentblocknumber + 1>

	<cfif isdefined("attributes.paging") and attributes.paging eq true>
		<cfparam name="attributes.cacheBlockName" default="FarCry">
		<cfparam name="attributes.cacheName" default="">
		<cfparam name="url.pgno" default="1">
		<cfset attributes.cacheName = attributes.cacheName & url.pgno>
	<cfelse>
		<cfparam name="attributes.cacheBlockName" default="FarCry">
		<cfparam name="attributes.cacheName">
	</cfif>
	<cfif not thistag.hasendtag>
		<cfthrow message="Missng End Tag for ContentCache.">
	</cfif>


	<cfif not isdefined("request.busecontentcache")>
		<cfif request.mode.design eq 1 or (isdefined("url.busecontentcache") and url.busecontentcache eq false)>
			<cfset request.busecontentcache = false>
		<cfelse>
			<cfset request.busecontentcache = true>
		</cfif>
	</cfif>

	<cfif request.mode.flushcache>
		<cfset cacheread = false>
		<cfif len(attributes.cacheBlockName)>
			<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheFlush">
				<cfinvokeargument name="cacheBlockName" value="#attributes.cacheBlockName#"/>
			</cfinvoke>
		</cfif>
		<cfif request.cachedcontentblocknumber eq 1>
			<cfoutput><script>window.defaultStatus="caches flushed:";</script></cfoutput>
		</cfif>
		<cfif len(attributes.cacheBlockName)>
			<cfset tempoutput = "*" & trim(attributes.cacheBlockName)>
		<cfelse>
			<cfset tempoutput = trim(attributes.cacheName)>
		</cfif>
		<cfif len(tempoutput) gt 10>
			<cfset tempoutput = left(tempoutput, 10) & "..">
		</cfif>
		<cfoutput><script>window.defaultStatus=window.defaultStatus + '<cfif request.cachedcontentblocknumber neq 1>,</cfif> #tempoutput#';</script></cfoutput>
	<cfelse>
		<cfset cacheread = true>
	</cfif>

	<cfset dtCachetimeout = 0>

	<cfset timeout = false>
	<cfif isdefined("attributes.days")>
		<cfset dtCachetimeout = dtCachetimeout + attributes.days>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.hours")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.hours / 24)>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.minutes")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.minutes / 1440)>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.seconds")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.seconds / 86400)>
		<cfset timeout = true>
	</cfif>
	<cfif timeout eq true>
		<cfset Cachetimeout = now() - dtCachetimeout>
	<cfelse>
		<cfset Cachetimeout = 0>
	</cfif>
	
	<cfif request.busecontentcache eq false>
		<cfset timeout = false>
		<cfset currentblock = request.cachedcontentblocknumber>
		<cfif request.mode.design eq 1 AND not isDefined("request.noContentCacheDebug")>
			<cfoutput><div style="font-size: 10px;">&lt;&lt;&lt; Content Cache start (#attributes.cacheName#) :::: (timeout </cfoutput>
			<cfif isdefined("attributes.days")>
				<cfoutput>#attributes.days#:</cfoutput>
				<cfset timeout = true>
			</cfif>
			<cfif isdefined("attributes.hours")>
				<cfoutput>#attributes.hours#:</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00:</cfoutput>
			</cfif>
			<cfif isdefined("attributes.minutes")>
				<cfoutput>#attributes.minutes#:</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00:</cfoutput>
			</cfif>
			<cfif isdefined("attributes.seconds")>
				<cfoutput>#attributes.seconds#</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00</cfoutput>
			</cfif>
			<cfif timeout eq false><cfoutput>Perminent</cfoutput></cfif>
			<cfoutput>)&gt;&gt;&gt;</div></cfoutput>
		</cfif>
	<cfelse>
		<cfif cacheread eq true>
			<cfinvoke component="farcry.farcry_core.packages.farcry.cache" method="cacheRead" returnvariable="read">
				<cfinvokeargument name="cacheBlockName" value="#attributes.cacheBlockName#"/>
				<cfinvokeargument name="cacheName" value="#attributes.cachename#"/>
				<cfinvokeargument name="dtCachetimeout" value="#Cachetimeout#"/>
			</cfinvoke>
			<cfset setvariable("caller.cacheRead",  read)>
		<cfelse>
			<cfset setvariable("caller.cacheRead",  false)>
		</cfif>	
		<cfif caller.cacheRead>
			<cfexit>
		</cfif>
	</cfif>
<cfelse>
<!--- end of the tag. write output and set up block cache structures. --->
	
	<cfif request.busecontentcache eq false>
		<cfif request.mode.design eq 1 AND not isDefined("request.noContentCacheDebug")>
			<cfoutput><div style="font-size: 10px;">&lt;&lt;&lt; Content Cache End (#attributes.cacheName#) &gt;&gt;&gt;</div></cfoutput>
		</cfif>
	<!--- if not in flushcase mode, write to cache --->
	<cfelseif not request.mode.flushcache and caller.cacheRead eq "false">
		
		<cfscript>
			contentcache = StructNew() ;
			contentcache.cache = ThisTag.GeneratedContent;
			contentcache.cachetimestamp = Now() - 0;
			contentcache.cachetimeout = dtCachetimeout;
		</cfscript>
		<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheWrite">
			<cfinvokeargument name="cacheBlockName" value="#attributes.cacheBlockName#"/>
			<cfinvokeargument name="cacheName" value="#attributes.cachename#"/>
			<cfinvokeargument name="stcacheblock" value="#contentcache#"/>
		</cfinvoke> 
	</cfif>
</cfif>