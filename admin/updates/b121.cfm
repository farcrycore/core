<!--- @@description:
Adds two new fields to the stats table (sessionId and browser)<br> 
Creates visitor sessions for existing stats
--->

<html>
<head>
<title>Farcry Core b121 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	<!--- alter stats table --->
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					sessionid VARCHAR2(100) NOT NULL default 'blank'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					browser VARCHAR2(100) NOT NULL default 'blank'
				</cfquery>
			</cfcase>
			<cfcase value="mysql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					sessionid VARCHAR(100) NOT NULL default 'blank'
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					browser VARCHAR(100) NOT NULL default 'blank'
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#Stats ADD
					sessionid varchar(100) NOT NULL default('blank'),
					browser varchar(100) NOT NULL default('blank')
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span><p></p></cfoutput></cfcatch>
	</cftry>
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Stats table altered<p></p></cfoutput><cfflush>
	</cfif>
	
	<!--- create dummy sessionids --->
	<cfquery name="qGetExisting" datasource="#application.dsn#">
		SELECT *
		FROM #application.dbowner#Stats
		WHERE sessionID = 'blank'
		ORDER BY remoteIP,logDateTime
	</cfquery>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> About to create sessions for #qGetExisting.recordcount# log entries<p></p></cfoutput><cfflush>
	
	<cfset lastIp = "">
	<cfset lastDate = "#now()#">
	<cfset counter = 0>
	
	
	<!--- loop over existing grouped by ip address --->
	<cfloop query="qGetExisting">
		
		<cfif lastIp neq remoteIP or DateDiff("n",lastDate,logDateTime) gt 30>
			<cfset counter = counter + 1>
			<!--- create dummy session --->
			<cfset dummySession = application.ApplicationName & "_" & trim(logId)>
			<!--- show progress to user --->
			<cfif counter mod 100 eq 0>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> #counter# sessions created...<p></p></cfoutput><cfflush>
			</cfif>
		</cfif>
		
		<!--- update stats --->
		<cfquery name="qUpdateStats" datasource="#application.dsn#">
			UPDATE #application.dbowner#Stats SET
			sessionID = '#dummySession#', browser = 'blank'
			WHERE logId = '#logId#'
		</cfquery>
		
		<!--- reset values --->
		<cfset lastIP = remoteIP>
		<cfset lastDate = logDateTime>
	</cfloop>

	<cfoutput><span class="frameMenuBullet">&raquo;</span> Update Complete (#counter# sessions created)</cfoutput><cfflush>	
	
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds two new fields to the stats table (sessionId and browser)</li>
		<li type="square">Creates visitor sessions for existing stats</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b121 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
