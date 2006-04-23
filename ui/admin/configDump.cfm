<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<body>

<span class="formHeader">Config Dumps</span>

<!--- loop over all configs and dump the contents of them --->
<cfloop collection="#application.config#" item="config">
	<cfdump var="#application.config[config]#" label="#config#"><cfoutput><p>&nbsp;</p></cfoutput>
</cfloop>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">