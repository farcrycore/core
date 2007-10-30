<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Permission Admin" />

<cfquery datasource="#application.dsn#" name="qConfig">
	select		*
	from		#application.dbowner#farConfig
	order by	configkey
</cfquery>

<cfoutput>
	<h3>FarCry Internal Configuration</h3>
	<ul>
</cfoutput>
<cfloop query="qConfig">
	<cfoutput>
		<li><a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#objectid#&typename=farConfig&method=edit&ref=typeadmin&module=customlists/farConfig.cfm">#configkey#</a></li>
	</cfoutput>
</cfloop>
<cfoutput>
	</ul>
</cfoutput>

<admin:footer />