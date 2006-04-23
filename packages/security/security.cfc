<cfcomponent displayName="Security Functions" hint="FarCry security update functions">

<cffunction name="fValidDatasource" access="public" hint="check if the datasource is valid" returntype="struct">
	<cfargument name="datasource" required="true" type="string">
	
	<cfset var stLocal = StructNew()>
	<cfset stLocal.returnstruct = StructNew()>
	<cfset stLocal.returnstruct.returncode = 1>
	<cfset stLocal.returnstruct.returnmessage = "">
			
	<cfset stLocal.returnValue = true>
	<cftry>
		<cfswitch expression="#application.dbType#">
			<cfcase value="ora">
				<cfquery name="testODBC" datasource="#arguments.datasource#" dbtype="ODBC">
					SELECT 1 FROM DUAL
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<cfquery name="testODBC" datasource="#arguments.datasource#" dbtype="ODBC">
					SELECT 1;
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch type="any">
			<cfset stLocal.returnstruct.returncode = 0>
			<cfset stLocal.returnstruct.returnmessage = 'Error:Cannot find datasource #arguments.datasource# in ODBC'>
		</cfcatch>
	</cftry>

	<!--- add error class --->
	<cfif stLocal.returnstruct.returncode EQ 0>
		<cfset stLocal.returnstruct.returnmessage = '<span class="error">' & stLocal.returnstruct.returnmessage & '</span>'>
	</cfif>
	<cfreturn stLocal.returnstruct>
</cffunction>

<cffunction name="fValidateTable" access="public" hint="check if the table is valid" returntype="struct">
	<cfargument name="datasource" required="true" type="string">
	<cfargument name="tablename" required="true" type="string">
	<cfargument name="lFieldName" required="true" type="string">
			
	<cfset var stLocal = StructNew()>
	<cfset stLocal.returnstruct = StructNew()>
	<cfset stLocal.returnstruct.returncode = 1>
	<cfset stLocal.returnstruct.returnmessage = application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].tableSetupOK,arguments.tablename)>
			
	<cfset stLocal.returnValue = true>
	<cftry>
		<cfquery name="stLocal.qTest" datasource="#arguments.datasource#" dbtype="ODBC">
		SELECT #arguments.lFieldName# FROM #arguments.tablename#
		</cfquery>

		<cfcatch type="Database">
			<cfset stLocal.subS = listToArray('#arguments.tablename#,#cfcatch.message#,#arguments.lFieldName#')>
			<cfset stLocal.returnstruct.returncode = 0>
			<cfif cfcatch.message contains "S0002">
				<cfset stLocal.returnstruct.returnmessage = application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errorS0002,subS)>
			<cfelseif cfcatch.message contains "S0022">
				<cfset stLocal.returnstruct.returnmessage = application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errorS0022,subS)>
			<cfelse>
				<cfset stLocal.returnstruct.returnmessage = "Sorry an error has occurred [security.cfc|fValidateTable()].">
			</cfif>
		</cfcatch>
	</cftry>

	<!--- add error class --->
	<cfif stLocal.returnstruct.returncode EQ 0>
		<cfset stLocal.returnstruct.returnmessage = '<span class="error">' & stLocal.returnstruct.returnmessage & '</span>'>
	</cfif>
	<cfreturn stLocal.returnstruct>
</cffunction>

</cfcomponent>