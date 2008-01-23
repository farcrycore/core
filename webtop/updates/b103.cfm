<html>
<head>
<title>Farcry Core b103 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
	<!--- add locking fields --->
	<cfset lTables = "dmHTML,dmNews,dmCSS,dmImage,dmFile,dmNavigation,dmInclude">
	
	<cfloop list="#lTables#" index="table">
		<cfset error = 0>
		<cftry>
		<cfquery name="update" datasource="#application.dsn#">
			ALTER TABLE #table# ADD
			lockedby varchar(510) NULL,
			locked bit default(0) NOT NULL
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
	
	<!--- add stats tables --->
	<cfinvoke component="#application.packagepath#.farcry.stats" method="deploy" returnvariable="deployRet">
		<cfinvokeargument name="bDropTable" value="1"/>
	</cfinvoke>
	
<cfelse>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b103 Updates" name="submit">
	</form>
</cfif>

</body>
</html>
