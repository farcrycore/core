<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<body>

<span class="formHeader">Restore Default Config</span>

<!--- drop tables and recreate --->
<cfinvoke component="#application.packagepath#.farcry.config" method="deployConfig" returnvariable="deployConfigRet">
	<cfinvokeargument name="bDropTable" value="1"/>
</cfinvoke>

<cfoutput><span class="frameMenuBullet">&raquo;</span> #deployConfigRet.msg#...<p></p></cfoutput><cfflush><cfflush>

<!--- setup default file config --->
<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFile" returnvariable="stStatus">
</cfinvoke>

<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>

<!--- setup default image config --->
<cfinvoke component="#application.packagepath#.farcry.config" method="defaultImage" returnvariable="stStatus">
</cfinvoke>

<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>

<!--- setup default verity config --->
<cfinvoke component="#application.packagepath#.farcry.config" method="defaultVerity" returnvariable="stStatus">
</cfinvoke>

<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>

<cfoutput>All done.</cfoutput>
<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">