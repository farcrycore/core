<cfset stStatus = StructNew()>
<cfset stStatus.msg = "Table deployed successfully">
<cftry>
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfif stArgs.bDropTable>
			<cfquery datasource="#stArgs.dsn#" name="qExists">
				SELECT * FROM #application.dbowner#USER_TABLES WHERE TABLE_NAME = 'CONFIG'
			</cfquery>
			<cfif qExists.recordCount>
			<cfquery datasource="#stArgs.dsn#" name="dropConfig">
				DROP TABLE #application.dbowner#config
			</cfquery>
			</cfif>	
		</cfif>
		<cfquery datasource="#stArgs.dsn#" name="createConfig">
			CREATE TABLE #application.dbowner#config
				(
				CONFIGNAME VARCHAR2(50) NOT NULL,
				WCONFIG CLOB NULL,
				CONSTRAINT PK_CONFIG PRIMARY KEY (CONFIGNAME)
				) 
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfif stArgs.bDropTable>
			<cfquery datasource="#stArgs.dsn#" name="dropConfig">			
				DROP TABLE IF EXISTS config			
			</cfquery>
		</cfif>
		<cfquery datasource="#stArgs.dsn#" name="createConfig">
			CREATE TABLE config
				(
				configName char(50) NOT NULL,
				wConfig text NULL,
				PRIMARY KEY (configName)
				) 
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfif stArgs.bDropTable>
			<cfquery datasource="#stArgs.dsn#" name="dropConfig">
			if exists (select * from sysobjects where name = 'config')
			DROP TABLE dbo.config
		
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>
		</cfif>
		<cfquery datasource="#stArgs.dsn#" name="createConfig">
			CREATE TABLE dbo.config
				(
				configName char(50) NOT NULL,
				wConfig ntext NULL
				) ON [PRIMARY]
				 TEXTIMAGE_ON [PRIMARY];
			
			ALTER TABLE dbo.config ADD CONSTRAINT
				PK_config PRIMARY KEY NONCLUSTERED 
				(
				configName
				) ON [PRIMARY];
		</cfquery>
	</cfdefaultcase>
	</cfswitch>
	<cfcatch>
		<cfset stStatus.bSuccess = "false">
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>
<cfset stStatus.bSuccess = "true">