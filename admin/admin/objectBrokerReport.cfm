<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$Community: FarCry CMS http://www.farcrycms.org $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: Verity Configurator Prototype; will have to tie us over till config engine is rebuilt. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport prefix="admin" taglib="/farcry/core/tags/admin/" />

<admin:header />

<cfoutput>
	<h1>Object Broker Settings</h1>
	<p>Object broker has been activated for the following content types.</p>

<table class="table-1">
<tr>
	<th>Typename</th>
	<th>Cached Objects</th>
	<th>Capacity %</th>
</tr>
<cfloop collection="#application.types#" item="key">
<cfif structkeyexists(application.types[key], "bObjectBroker") AND application.types[key].bObjectBroker>
<tr>
	<cfif structkeyexists(application.types[key], "displayname")>
		<td>#application.types[key].displayname#</td>
	<cfelse>
		<td>#key#</td>
	</cfif>
	<cfif structkeyexists(application.objectbroker, key)>
		<td>#arrayLen(application.objectbroker[key].aobjects)#/#application.types[key].objectbrokermaxobjects#</td>
		<td>#numberFormat((arrayLen(application.objectbroker[key].aobjects)/application.types[key].objectbrokermaxobjects)*100)#%</td>
	<cfelse>
		<td colspan="2">Unknown</td>
	</cfif>
</tr>
</cfif>
</cfloop>
</table>

</cfoutput>


<admin:footer />

<cfsetting enablecfoutputonly="true" />
