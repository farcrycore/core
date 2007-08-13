<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Tag for Building Sitemap --->
<!--- @@Description: Build s a sitemap by calling generic nav with specific parameters. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<!--- run once only --->
<cfif thistag.ExecutionMode eq "end">
	<cfexit method="exittag" />
</cfif>

<!--- optional attributes --->
<cfparam name="attributes.depth" default="4" type="numeric" />
<cfparam name="attributes.startPoint" default="#application.navid.home#" type="string" />

<!--- deprecated attributes --->
<cfparam name="attributes.bDisplay" default="true" />
<cfparam name="attributes.r_navQuery" default="r_navQuery" />
<cfparam name="attributes.id" default="sitemapNav" />

<!--- build site map & display --->
<skin:genericNav id="#attributes.id#" navID="#attributes.startPoint#" depth="#attributes.depth#">

<cfsetting enablecfoutputonly="false" />