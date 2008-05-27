<cfsetting enablecfoutputonly="true" />
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
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