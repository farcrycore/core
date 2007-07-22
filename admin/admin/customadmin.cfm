<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION || 
$Description: This template simply invokes the custom admin module 
with the relevant custom admin code.  Header and footer information 
should be provided by the invoked template. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<!--- environment variables --->
<cfparam name="URL.module" type="string" />
<cfparam name="URL.plugin" default="" type="string" />

<cfif len(URL.plugin)>
	<!--- load admin from the nominated plugin --->
	<cfmodule template="/farcry/plugins/#URL.plugin#/customadmin/#URL.module#">
<cfelseif fileExists(expandPath("/farcry/projects/#application.applicationname#/customadmin/#URL.module#"))>
	<!--- load admin from the project --->
	<cfmodule template="/farcry/projects/#application.applicationname#/customadmin/#URL.module#">
<cfelseif fileExists(expandPath("/farcry/core/admin/customadmin/#URL.module#"))>
	<!--- load admin from the project --->
	<cfmodule template="/farcry/core/admin/customadmin/#URL.module#">
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