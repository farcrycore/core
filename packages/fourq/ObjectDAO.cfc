<cfcomponent hint="I read Object data from a MySQL4 database.">
	
	
	<cffunction name="getDBObjects" access="public" output="false" returntype="query">
		<cfargument name="DSN" required="yes" type="string" hint="I am the CF datasource name">
		
		
		<cfset var qObjects = QueryNew("typename","VarChar")>
		
		
		<!--- MYSQL --->
		<!---<cfquery name="qDBObjects" datasource="#arguments.dsn#">
			SHOW TABLES;
		</cfquery>
		
		<!--- Need to change the column name from TABLES_IN_DSN to "tablename" --->
		<cfset newRow = QueryAddRow(qObjects, qDBObjects.RecordCount)>
		<cfoutput query="qDBObjects">
			<cfset newRow = QuerySetCell(qObjects, "typename", Evaluate("qDBObjects.TABLES_IN_#arguments.dsn#"), qDBObjects.CurrentRow)>
			
		</cfoutput>	
		
		 --->
		
		<!--- MSSQL --->
		<cfquery name="qDBObjects" datasource="#arguments.dsn#">
		SELECT *
		FROM INFORMATION_SCHEMA.TABLES
		</cfquery>
		
		<!--- Need to change the column name from TABLES_IN_DSN to "tablename" --->
		<cfset newRow = QueryAddRow(qObjects, qDBObjects.RecordCount)>
		<cfoutput query="qDBObjects">
			<cfset newRow = QuerySetCell(qObjects, "typename", Evaluate("qDBObjects.table_name"), qDBObjects.CurrentRow)>
		</cfoutput>	
		
		<cfreturn qObjects>
	</cffunction>
		
	<cffunction name="readObject" access="public" hint="I confirm that this object exists at all.  If not, I throw an error." output="false" returntype="query">
		
		<cfargument name="DSN" hint="I am the CF datasource name" required="yes" type="string">
		<cfargument name="ObjectName" hint="I am the object to check on." required="yes" type="string" />
		
		<!--- MySQL --->
		<!---
		<cftry>
			<cfquery name="qObject" datasource="#arguments.DSN#">
				EXPLAIN dbo.#arguments.Objectname#
			</cfquery>
			<cfcatch type="any">
				<cfabort showerror="#arguments.ObjectName# does not exist">
			</cfcatch>
		</cftry> --->


		<!--- MSSQL --->
		<cfquery name="qObject" datasource="#arguments.dsn#">
		SELECT *
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = '#arguments.ObjectName#'
		</cfquery>		
		<cfreturn qObject />
		
	</cffunction>
	
	<cffunction name="readFields" access="public" hint="I populate the table with fields." output="false" returntype="array">
		<cfargument name="qObject" type="query" required="true" />
		<cfset var qFields = arguments.qObject />
		<cfset var Field = 0 />
		<cfset var dataType = 0 />
		<cfset var length = 0 />
			
		<cfset aFields = ArrayNew(1)>
			
		<cfoutput query="qFields">
			<!--- 
				mod by SPJ: in MySql 4 tinytext, text, mediumtext and longtext don't report their maxlength value, so we 
				have to set it by hand.  The field lengths were obtained from http://www.cs.wcupa.edu/~rkline/mysqlEZinfo/data_types.html#Storage_requirements
			--->
			<cfswitch expression="#qFields.TYPE#">
				<cfcase value="tinytext">
					<cfset dataType = "text" />
					<cfset length = 2^8 />
				</cfcase>
				<cfcase value="text">
					<cfset dataType = "text" />
					<cfset length = 2^16 + 1 />
				</cfcase>
				<cfcase value="mediumtext">
					<cfset dataType = "text" />
					<cfset length = 2^24 + 2 />
				</cfcase>
				<cfcase value="longtext">
					<cfset dataType = "longtext" />
					<cfset length = 2^32 + 3 />
				</cfcase>
				<cfdefaultcase>
					<!--- this is the original MySql 4 code, look for textfields in the format type(maxlen) --->
					<cfif REFind(".*\(.*\)",qFields.TYPE) eq 0>
						<cfset dataType = qFields.TYPE />
						<cfset length = 0 />
					<cfelse>
						<cfset dataType = REReplace(qFields.TYPE,"(.*)\((.*)\)","\1") />
						<cfset length = REReplace(qFields.TYPE,"(.*)\((.*)\)","\2") />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<!--- end mod by SPJ --->
			
			<!--- create the field --->
			<cfset Field = structNew() />
			<cfset Field.Name = (qFields.FIELD) />
			<cfset Field.PrimaryKey = (qFields.KEY is "PRI") />
			<cfset Field.Identity = (qFields.EXTRA is "auto_increment") />
			<cfset Field.Nullable = (qFields.NULL is "YES") />
			<cfset Field.DbDataType = (dataType) />
			<cfset Field.CfDataType = (getCfDataType(dataType)) />
			<cfset Field.CfSqlType = (getCfSqlType(dataType)) />
			<cfset Field.Length = (length) />
			<cfset Field.Default = (getDefault(qFields.default, Field.CfDataType, Field.Nullable)) />
			
			<cfset aFields[qFields.CurrentRow] = Field>
		</cfoutput>
		
		<cfreturn aFields>
	</cffunction>
	
	<cffunction name="getDefault" access="public" hint="I get a default value for a cf datatype." output="false" returntype="string">
		<cfargument name="sqlDefaultValue" hint="I am the default value defined by SQL." required="yes" type="string" />
		<cfargument name="typeName" hint="I am the cf type name to get a default value for." required="yes" type="string" />
		<cfargument name="nullable" hint="I indicate if the column is nullable." required="yes" type="boolean" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="numeric">
				<cfif IsNumeric(arguments.sqlDefaultValue)>
					<cfreturn arguments.sqlDefaultValue />
				<cfelseif arguments.nullable>
					<cfreturn ""/>
				<cfelse>
					<cfreturn 0 />
				</cfif>
			</cfcase>
			<cfcase value="integer">
				<cfif IsNumeric(arguments.sqlDefaultValue)>
					<cfreturn arguments.sqlDefaultValue />
				<cfelseif arguments.nullable>
					<cfreturn ""/>
				<cfelse>
					<cfreturn 0 />
				</cfif>
			</cfcase>			
			<cfcase value="binary">
				<cfreturn "" />
			</cfcase>
			<cfcase value="boolean">
				<cfif IsBoolean(arguments.sqlDefaultValue)>
					<cfreturn Iif(arguments.sqlDefaultValue, DE(true), DE(false)) />
				<cfelse>
					<cfreturn false />
				</cfif>
			</cfcase>
			<cfcase value="string">
				<!--- insure that the first and last characters are "'" --->
				<cfif Left(arguments.sqlDefaultValue, 1) IS "'" AND Right(arguments.sqlDefaultValue, 1) IS "'">
					<!--- mssql functions must be constants.  for this reason I can convert anything quoted in single quotes safely to a string --->
					<cfset arguments.sqlDefaultValue = Mid(arguments.sqlDefaultValue, 2, Len(arguments.sqlDefaultValue)-2) />
					<cfset arguments.sqlDefaultValue = Replace(arguments.sqlDefaultValue, "''", "'", "All") />
					<cfset arguments.sqlDefaultValue = Replace(arguments.sqlDefaultValue, """", """""", "All") />
					<cfreturn arguments.sqlDefaultValue />
				<cfelse>
					<cfreturn "" />
				</cfif>
			</cfcase>
			<cfcase value="date">
				<cfif Left(arguments.sqlDefaultValue, 1) IS "'" AND Right(arguments.sqlDefaultValue, 1) IS "'">
					<cfreturn Mid(arguments.sqlDefaultValue, 2, Len(arguments.sqlDefaultValue)-2) />
				<cfelseif arguments.sqlDefaultValue IS "getDate()">
					<cfreturn "##Now()##" />
				<cfelse>
					<cfreturn "" />
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfreturn "" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="getCfSqlType" access="private" hint="I translate the MSSQL data type names into ColdFusion cf_sql_xyz names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />

		<cfset arguments.typeName = ReplaceNoCase(arguments.typeName, " unsigned", "") />

		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bit,bool,boolean">
				<cfreturn "cf_sql_bit" />
			</cfcase>
			<cfcase value="tinyint">
				<cfreturn "cf_sql_tinyint" />
			</cfcase>
			<cfcase value="smallint,year">
				<cfreturn "cf_sql_smallint" />
			</cfcase>
			<cfcase value="mediumint,int,integer">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="bigint">
				<cfreturn "cf_sql_bigint" />
			</cfcase>
			<cfcase value="float">
				<cfreturn "cf_sql_float" />
			</cfcase>
			<cfcase value="double,double percision">
				<cfreturn "cf_sql_double" />
			</cfcase>
			<cfcase value="decimal,dec">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="date">
				<cfreturn "cf_sql_date" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="timestamp">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>			
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="tinytext,text,mediumtext,longtext">
				<cfreturn "cf_sql_longvarchar" />
			</cfcase>
			<cfcase value="varbinary">
				<cfreturn "cf_sql_varbinary" />
			</cfcase>
			<cfcase value="tinyblob,blob,mediumblob,longblob">
				<cfreturn "cf_sql_blob" />
			</cfcase>
			<cfcase value="binary">
				<cfreturn "cf_sql_binary" />
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getCfDataType" access="private" hint="I translate the MSSQL data type names into ColdFusion data type names" output="false" returntype="string">
		<cfargument name="typeName" hint="I am the type name to translate" required="yes" type="string" />
		
		<cfswitch expression="#arguments.typeName#">
			<cfcase value="bit,bool,boolean">
				<cfreturn "boolean" />
			</cfcase>
			<cfcase value="tinyint,smallint,mediumint,int,integer,bigint,float,double,double percision,decimal,dec,year">
				<cfreturn "numeric" />
			</cfcase>
			<cfcase value="date,datetime,timestamp">
				<cfreturn "date" />
			</cfcase>
			<cfcase value="time,enum,set">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="char,varchar,tinytext,text,mediumtext,longtext">
				<cfreturn "string" />
			</cfcase>
			<cfcase value="binary,varbinary,tinyblob,blob,mediumblob,longblob">
				<cfreturn "binary" />
			</cfcase>			
		</cfswitch>
	</cffunction>

	<cffunction name="CreateFarcryPackage" access="public" output="false" returntype="any">
		<cfargument name="typename" required="yes" type="string">
		
		
		
		<cfset qObject = readObject("breathe",arguments.typename)>
		
		<cfset aFields = readFields(qObject)>

<cfsavecontent variable="NewComponent">		
<cfoutput>||cfcomponent extends="farcry.farcry_core.packages.types.types" displayname="#arguments.typename#" hint="#arguments.typename#"></cfoutput>
<cfloop from="1" to="#ArrayLen(aFields)#" index="i">
	<cfif NOT listcontainsNoCase("objectid,label,datetimecreated,createdby,ownedby,datetimelastupdated,lastupdatedby,lockedBy,locked",aFields[i].Name)>
	<cfoutput>||cfproperty name="#aFields[i].Name#" type="#aFields[i].dbDataType#" hint="" required="No" default="#aFields[i].Default#" PrimaryKey="#aFields[i].PrimaryKey#" Length="#aFields[i].Length#" identity="#aFields[i].identity#" nullable="#aFields[i].nullable#"></cfoutput>
	</cfif>
</cfloop>
<cfoutput>||/cfcomponent></cfoutput>
</cfsavecontent>
				
	<cfset NewComponent = "#ReplaceNoCase(NewComponent, '#Chr(10)##Chr(10)#', '' , 'All')#">
	<cfset NewComponent = "#ReplaceNoCase(NewComponent, '		#Chr(10)#', '' , 'All')#">
	<cfset NewComponent = "#ReplaceNoCase(NewComponent, '||', '<' , 'All')#">

		
		
		<cffile action="write" file="c:\webapps\b2\packages\types\#arguments.typename#.cfc" output="#NewComponent#">

		
	</cffunction>
</cfcomponent>
