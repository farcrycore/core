<!--- @@description:
Deploys new Plugins config file<br> 
Adds three new fields to the stats table (referer, operating system and locale)
--->
<html>
<head>
<title>Farcry Core b122 Update: <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultPlugins" returnvariable="stStatus"></cfinvoke>
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfset error = 0>
	<!--- alter stats table --->
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					referer VARCHAR2(1024) NOT NULL default 'unknown'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					locale VARCHAR2(100) NOT NULL default 'unknown'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					os VARCHAR2(50) NOT NULL default 'unknown'
				</cfquery>
			</cfcase>
			<cfcase value="mysql,mysql5">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					referer TEXT 
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					locale VARCHAR(100) NOT NULL default 'unknown'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					os VARCHAR(50) NOT NULL default 'unknown'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					referer VARCHAR(1024) NOT NULL default('unknown'),
					locale VARCHAR(100) NOT NULL default('unknown'), 
					os char(50) NOT NULL default('unknown')
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span><p></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Stats table altered<p></p></cfoutput><cfflush>
	</cfif>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Update Complete</cfoutput><cfflush>	
	
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Deploys new Plugins config file</li>
		<li type="square">Adds three new fields to the stats table (referer, operating system and locale)</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b122 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
