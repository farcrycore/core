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
<!--- @@displayname: Custom Admin Module --->
<!--- @@Description: 
This template simply invokes the custom admin module 
with the relevant custom admin code.  Header and footer information 
should be provided by the invoked template. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- set page encoding for controller --->
<cfprocessingDirective pageencoding="utf-8" />

<!--- environment variables --->
<cfparam name="URL.module" type="string" />
<cfparam name="URL.plugin" default="" type="string" />

<cfif len(URL.plugin)>
	<!--- load admin from the nominated plugin --->
	<cfmodule template="/farcry/plugins/#URL.plugin#/customadmin/#URL.module#" attributecollection="#duplicate(url)#">

<cfelseif fileExists(expandPath("/farcry/projects/#application.projectDirectoryName#/customadmin/#URL.module#"))>
	<!--- load admin from the project --->
	<cfmodule template="/farcry/projects/#application.projectDirectoryName#/customadmin/#URL.module#" attributecollection="#duplicate(url)#">

<cfelseif fileExists(expandPath("/farcry/core/webtop/customadmin/#URL.module#"))>
	<!--- load admin from the project --->
	<cfmodule template="/farcry/core/webtop/customadmin/#URL.module#" attributecollection="#duplicate(url)#">

<cfelse>
	<cfsavecontent variable="errorHTML">
	<cfoutput>
	<h2>Administration UI Not Found</h2>
	<ul>
		<li>module: #url.module#</li>
		<li>plugin: #url.plugin#</li>
	</ul>
	</cfoutput>
	</cfsavecontent>
	<cfthrow type="Application" message="#errorHTML#" />	
</cfif>

<cfsetting enablecfoutputonly="false" />