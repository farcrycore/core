<!--- <cfinclude template="/farcry/core/ui/updates/fu.cfm"> --->
<cfsetting enablecfoutputonly="true">

<!--- re/create the FU table --->
<cftry>
	<cfquery name="qCheck" datasource="#application.dsn#" maxrows="1">
	SELECT objectid FROM #application.dbOwner#reffriendlyURL
	</cfquery>
	
	<!--- bowden --->
	<cfswitch expression="#application.dbtype#">
		
		<cfcase value="ora">
			<cfquery name="qTableExists" datasource="#application.dsn#">
			select 1
			from user_tables
			where table_name =  'REFFRIENDLYURL' 
			</cfquery>
			
			<cfif qTableExists.recordcount gt 0>
				<cfquery name="qDrop" datasource="#application.dsn#" maxrows="1">
				DROP TABLE #application.dbOwner#reffriendlyURL
				</cfquery> 
			</cfif>
			
		</cfcase>
		
		<cfdefaultcase>
			<cfquery name="qDrop" datasource="#application.dsn#" maxrows="1">
			DROP TABLE #application.dbOwner#reffriendlyURL
			</cfquery> 
		</cfdefaultcase>
		
	</cfswitch>

	<cfcatch>
		<!--- only create table if one doesnt exist --->
		<!--- bowden --->
		<cfswitch expression="#application.dbtype#">
			
			<cfcase value="ora">
				<cfquery name="qCreateFUTable" datasource="#application.dsn#">
				CREATE TABLE #application.dbOwner#reffriendlyURL ( 
				objectid    		varchar2(50) NOT NULL,
				refobjectid 		varchar2(50) NOT NULL,
				friendlyurl	        varchar2(4000) NULL,
				query_string        varchar2(4000) NULL,
				datetimelastupdated date NULL,
				status      		numeric NULL 
				)
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<cfquery name="qCreateFUTable" datasource="#application.dsn#">
				CREATE TABLE #application.dbOwner#reffriendlyURL ( 
				objectid varchar(50) NOT NULL,
				refobjectid varchar(50) NOT NULL,
				
				<cfswitch expression="#application.dbtype#">
					
					<cfcase value="ODBC">
					friendlyurl	varchar(8000) NULL,
					query_string varchar(8000) NULL,
					datetimelastupdated datetime NULL,
					</cfcase>
					
					<cfcase value="mssql">
					friendlyurl	varchar(8000) NULL,
					query_string varchar(8000) NULL,
					datetimelastupdated datetime NULL,
					</cfcase>
					
					<cfcase value="mysql">
					friendlyurl	varchar(255) NULL,
					query_string varchar(255) NULL,
					datetimelastupdated datetime NULL,
					</cfcase>
					
					<cfdefaultcase>
					friendlyurl	varchar(255) NULL,
					query_string varchar(255) NULL,
					datetimelastupdated datetime NULL,
					</cfdefaultcase>
				
				</cfswitch>
				status numeric NULL 
				)
				</cfquery>
			</cfdefaultcase>
		 </cfswitch>
	</cfcatch>
</cftry>

<cfset FUFileName = "FriendlyURLs.txt">
<!--- read the FU,txt --->

<!--- try if exist in coldfusion lib --->
<cfset FUFileLocation_1 = "#server.coldfusion.rootDir#\lib\#FUFileName#">
<cfset FUFileLocation_2 = "">
<cfset FUFileLocation = "">

<!--- check servers lib --->
<cfset listLen = ListFindNoCase(server.coldfusion.rootDir,"servers","\")>
<cfif listLen GT 0>
	<cfloop index="i" from="1" to="#listLen#">
		<cfset FUFileLocation_2 = FUFileLocation_2 & ListGetAt(server.coldfusion.rootDir,i,"\") & "\">
	</cfloop>
	<cfset FUFileLocation_2 = FUFileLocation_2 & "lib\#FUFileName#">
</cfif>

<cfif FileExists(FUFileLocation_1)>
	<cfset FUFileLocation = FUFileLocation_1>
<cfelseif FileExists(FUFileLocation_2)>
	<cfset FUFileLocation = FUFileLocation_2>
</cfif>
<cfset iCounter_Success = 0>
<cfset iCounter_Failure = 0>
<cfif FUFileLocation NEQ "">
	<!--- read the FU file --->
	<cffile action="read" file="#FUFileLocation#" variable="fuContent">
	<cfset FUDelim = "#chr(10)##chr(13)#">
	<cfset aFUContent = ListToArray(fuContent,FUDelim)>
	<cfloop index="i" from="1" to="#ArrayLen(aFUContent)#">
		<cfset lContent = trim(aFUContent[i])>
		<cfif Left(lContent,1) NEQ "##">
			<cfif ListLen(lContent,"=") EQ 3>
				<cfset friendlyURL = ListFirst(lContent,"=")>
				<cfset refObjectID = ListLast(lContent,"=")>
				<cfset friendlyURL = ReplaceNoCase(friendlyURL,cgi.server_name,"")>
				<cftry>
					<cfquery name="qCreateFUTable" datasource="#application.dsn#">
					INSERT INTO #application.dbOwner#URL(objectid, refObjectID, friendlyURL, datetimelastupdated, status)
					VALUES (<cfqueryparam value="#application.fc.utils.createJavaUUID()#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#refObjectID#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#friendlyURL#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp">,1)
					</cfquery>
					<cfset iCounter_Success = iCounter_Success + 1>
					<cfcatch>
						<cfset iCounter_Failure = iCounter_Failure + 1>
					</cfcatch>				
				</cftry>
			</cfif>
		</cfif>
	</cfloop>
</cfif>

<cfset GOFileLocation_to = "#application.path.project#/www/go.cfm">
<cfset GOFileLocation_from = "#application.path.core#/webtop/updates/go.cfm">
<cfoutput>#GOFileLocation_from#<br /></cfoutput>
<cfset message = "">
<cfif fileExists(GOFileLocation_to)>
	<cfset message = "NOTE: There is an existing #application.path.project#/www/go.cfm file, please ensure it is the same or similar to #application.path.core#/webtop/admin/updates/go.cfm">
<cfelseif fileExists(GOFileLocation_from)>
	<cftry>
		<cffile action="copy" source="#GOFileLocation_from#" destination="#GOFileLocation_to#">
		<cfset message = "NOTE: go.cfm copied">
		<cfcatch>
			<cfset message = "ERROR: #cfcatch.message#">
		</cfcatch>
	</cftry>
<cfelse>
	<cfset message = "ERROR: You need to download #application.path.core#/webtop/admin/updates/go.cfm">
</cfif>

<cfsetting enablecfoutputonly="false"><cfoutput>
Create Table Success: #application.dbOwner#URL<br />
<cfif FUFileLocation NEQ "">
--------------------------------------------------------------<br />
FriendlyUrl Migrated: #FUFileLocation#<br />
Success: #iCounter_Success#<br />
Failures: #iCounter_Failure#<br />
--------------------------------------------------------------<br />
</cfif><cfif message NEQ "">
#message#<br /></cfif>
</cfoutput>