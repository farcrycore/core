<html>
<head>
<title>Farcry Core b108 Update</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfif isdefined("form.submit")>
		<cfset error = 0>
		<cfset error2 = 0>
		<cfset error3 = 0>
		
		<cftry>
			<cfswitch expression="#form.dsn#">
				<cfcase value="ora" >
					<cfquery name="update" datasource="#form.dsn#">
						ALTER TABLE ruleHandpicked ADD
						INTRO varchar2(510) NULL
					</cfquery>
				</cfcase>	
				<cfdefaultcase>
					<cfquery name="update" datasource="#form.dsn#">
						ALTER TABLE ruleHandpicked ADD
						intro varchar(510) NULL
					</cfquery>
				</cfdefaultcase>	
			</cfswitch>
		<cfcatch type="database">
			<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
			<cfset error = 1>
		</cfcatch>
		</cftry>
		<cfif not error>
			<cfoutput>RuleHandpicked</cfoutput> altered <p></p><cfflush>
		</cfif>
		
		<!--- add stats table --->
		<cftry>
			
			<cfswitch expression="#application.dbtype#">
				<cfcase value="ora">
					<cfquery name="update" datasource="#form.dsn#">
						CREATE TABLE STATSDAYS (
							DAY NUMBER NOT NULL ,
							NAME VARCHAR2(10) NOT NULL 
						) 
					</cfquery>
				</cfcase>
				<cfdefaultcase>
					<cfquery name="update" datasource="#form.dsn#">
						CREATE TABLE [dbo].[StatsDays] (
							[Day] [int] NOT NULL ,
							[Name] [varchar] (10) NOT NULL 
						) ON [PRIMARY]
					</cfquery>
				
				</cfdefaultcase>
			
			</cfswitch>
						
			<cfcatch type="database">
					<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
					<cfset error2 = 1>
				</cfcatch>
		</cftry>
		<cfif not error2>
			StatsDays Created<p></p><cfflush>
		</cfif>
		
		<!--- set up days array --->
		<cfset days = arrayNew(2)>
		<cfset days[1][1] = 1>
		<cfset days[1][2] = "Sunday">
		<cfset days[2][1] = 2>
		<cfset days[2][2] = "Monday">
		<cfset days[3][1] = 3>
		<cfset days[3][2] = "Tuesday">
		<cfset days[4][1] = 4>
		<cfset days[4][2] = "Wednesday">
		<cfset days[5][1] = 5>
		<cfset days[5][2] = "Thursday">
		<cfset days[6][1] = 6>
		<cfset days[6][2] = "Friday">
		<cfset days[7][1] = 7>
		<cfset days[7][2] = "Saturday">
		
		<cfloop from=1 to=7 index="day">
			<cftry>
				<cfquery name="update" datasource="#form.dsn#">
				INSERT INTO STATSDAYS
				(Day,Name)
				VALUES
				(<cfoutput>#days[day][1]#,'#days[day][2]#'</cfoutput>)
				</cfquery>
				
				<cfcatch type="database">
					<cfoutput><span style="color:red">#cfcatch.queryerror#</span></cfoutput><p></p><cfflush>
					<cfset error3 = 1>
				</cfcatch>
			</cftry>
			<cfif not error3>
				Days Updated - '<cfoutput>#days[day][2]#</cfoutput>'<p></p><cfflush>
			</cfif>
		</cfloop>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Adds a 'text' column called 'intro' to the table 'ruleHandpicked'</li>
		<li type="square">Creates a table called 'StatsDays' used in graphing statistics</li>
	</ul> 
	</p>
	<form action="" method="post">
		Enter DSN : <input type="text" name="dsn" value="#application.dsn#">
				<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b108 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
