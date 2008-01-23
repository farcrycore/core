<html>
<head>
<title>Farcry Core b105 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
	<!--- add teaserImage fields --->
	<cfset lTables = "dmHTML,dmNews,dmInclude">
	
	<cfloop list="#lTables#" index="table">
		<cfset error = 0>
		<cftry>
		<cfquery name="update" datasource="#application.dsn#">
			ALTER TABLE #table# ADD
			teaserImage varchar(510) NULL
		</cfquery>
		<cfcatch type="database">
			<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
			<cfset error = 1>
		</cfcatch>
		</cftry>
		<cfif not error>
			<cfoutput>#table#</cfoutput> altered <p></p><cfflush>
		</cfif>
	</cfloop>
	
	<!--- remove userEmail from dmUser --->
	<cfset error = 0>
	<cftry>
	<cfquery name="update" datasource="#application.dsn#">
		ALTER TABLE dmUser drop column userEmail
	</cfquery>
	<cfcatch type="database">
		<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
		<cfset error = 1>
	</cfcatch>
	</cftry>
	<cfif not error>
		User Email dropped from dmUser table<p></p><cfflush>
	</cfif>
	
	<!--- remove aTeaserImages from dmHTML --->
	<cfset error = 0>
	<cftry>
	<cfquery name="update" datasource="#application.dsn#">
		drop TABLE dmHTML_aTeaserImageIDs
	</cfquery>
	<cfcatch type="database">
		<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
		<cfset error = 1>
	</cfcatch>
	</cftry>
	<cfif not error>
		dmHTML_aTeaserImageIDs dropped <p></p><cfflush>
	</cfif>
	
	 <!--- deploy defaultSoEditor config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditor" returnvariable="stStatus"></cfinvoke>
		
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	 <!--- deploy defaultSoEditorPro config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditorPro" returnvariable="stStatus"></cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- deploy defaultGeneral config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultGeneral" returnvariable="stStatus"></cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- handpicked rule --->
	<!--- This table no longer required --->
	<cftry>
		<cfquery name="update" datasource="#application.dsn#">
			drop TABLE ruleHandpicked_aObjects
		</cfquery>
		<cfcatch type="database">
			<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
			<cfset error = 1>
		</cfcatch>
	</cftry>
	<cfif not error>
		<span class="frameMenuBullet">&raquo;</span>Dropped ruleHandpicked_aObjects<p><cfflush>
	</cfif>

	<cftry>
		<cfinvoke component="#application.packagepath#.rules.ruleHandpicked" method="deployType" btestrun="False" returnvariable="stStatus" bDropTable="true"/>
		<cfdump var="#stStatus#" label="ruleHandpicked deployment">
		<cfcatch type="any">
			<cfoutput><span style="color:red">#cfcatch.message#</span></cfoutput><p></p><cfflush>
		</cfcatch>
	</cftry>

<cfelse>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b105 Updates" name="submit">
	</form>
</cfif>

</body>
</html>
