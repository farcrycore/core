<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<body>

<span class="formHeader">Clear Stats Log</span>

<!--- drop tables and recreate --->
<cfinvoke component="#application.packagepath#.farcry.stats" method="deploy" returnvariable="deployRet">
	<cfinvokeargument name="bDropTable" value="1"/>
</cfinvoke>

<cfoutput><span class="frameMenuBullet">&raquo;</span> #deployRet.message#...<p></p></cfoutput><cfflush>

<cfoutput>All done.</cfoutput>
<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">