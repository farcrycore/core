<!--- @@description:
Update Image Config<br />
Adds the SourceImage, StandardImage and ThumbnailImage entry to dmImage table<br />
Create SourceImages, thumbnailImages and StandardImages directories<br />
Update SourceImage, StandardImage and ThumbnailImage initial values<br />
Copy Files from Old Locations to New Locations
Add Typename Field to each array table.
Populate each new typename field.

--->
<cfoutput>
<html>
<head>
<title>Farcry Core 4.0.1 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>



	<!--- Add typename and rename objectid to parentid to all array tables --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding datetimelastupdate field to all rule tables...</cfoutput><cfflush>
	<cftry>
		
		<cfloop list="#structKeyList(application.rules)#" index="iRule">
			
				
		
				<cfswitch expression="#application.dbtype#">
					
					<cfcase value="ora">																
						<cftry>
							<cfquery name="qAlterTable" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##iRule# ADD datetimelastupdated date NULL
							</cfquery>
							<cfoutput><div>datetimelastupdated added to rule table #iRule#</div></cfoutput>
							<cfcatch type="database"><cfoutput><div>datetimelastupdated already exists in rule table #iRule#</div></cfoutput></cfcatch>
						</cftry>
					</cfcase>
					

					<cfcase value="mysql,mysql5">																
						<cftry>
							<cfquery name="qAlterTable" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##iRule# ADD datetimelastupdated datetime NULL
							</cfquery>
							<cfoutput><div>datetimelastupdated added to rule table #iRule#</div></cfoutput>
							<cfcatch type="database"><cfoutput><div>datetimelastupdated already exists in rule table #iRule#</div></cfoutput></cfcatch>
						</cftry>
						
											
					</cfcase>
					
					<cfcase value="postgresql">																
						<cftry>
							<cfquery name="qAlterTable" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##iRule# ADD datetimelastupdated timestamp NULL
							</cfquery>
							<cfoutput><div>datetimelastupdated added to rule table #iRule#</div></cfoutput>
							<cfcatch type="database"><cfoutput><div>datetimelastupdated already exists in rule table #iRule#</div></cfoutput></cfcatch>
						</cftry>		
					</cfcase>

					<cfcase value="mssql,odbc">																
						<cftry>
							<cfquery name="qAlterTable" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##iRule# ADD datetimelastupdated datetime NULL
							</cfquery>
							<cfoutput><div>datetimelastupdated added to rule table #iRule#</div></cfoutput>
							<cfcatch type="database"><cfoutput><div>datetimelastupdated already exists in rule table #iRule#</div></cfoutput></cfcatch>
						</cftry>
											
					</cfcase>					
					
					<cfdefaultcase>
						<cfthrow message="Your database type is not supported for this update (4.0.1)." /> 
					</cfdefaultcase>
				
				</cfswitch>

		</cfloop>
		

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>
	
		
	
	
	

	<!---
		clean up caching: kill all shared scopes and force application initialisation
			- application
			- session
			- server.dmSec[application.applicationname]
	 --->
	<cfset application.init=false>
	<cfset session=structnew()>
	<cfset server.dmSec[application.applicationname] = StructNew()>
	<cfoutput><p><strong>All done.</strong> Return to <a href="#application.url.farcry#/index.cfm">FarCry Webtop</a>.</p></cfoutput>
	<cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li>Adds datetimelastupdated to all rules</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run 4.0.1 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
