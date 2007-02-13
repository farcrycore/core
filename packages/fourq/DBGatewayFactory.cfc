<cfcomponent output="false" hint="This component handles the work of figuring out which DB gateway CFC to use for a given method call in fourq">
	
	<cffunction name="init" access="public" returntype="DBGatewayFactory" output="false" hint="Initializes the instance data for the component.">
		<cfset variables.connections = structNew() />
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getGateway" returntype="farcry.farcry_core.packages.fourq.gateway.DBGateway" output="false" access="public" hint="Returns an initialized DBGateway instance for the given db type and authentication details">
		<cfargument name="dsn" type="string" required="true" hint="The name of the datasource we will be using." />
		<cfargument name="dbowner" type="string" required="true" hint="The name of the owner for the db tables we will be using." />
		<cfargument name="dbType" type="string" required="true" hint="The type of database that we will be connecting to." />
		
		<cfset var connection = "" />
		
		<cfif structKeyExists(variables.connections,arguments.dsn)>
			<cfreturn variables.connections[dsn] />
		</cfif>
		
		<cfswitch expression="#arguments.dbtype#">
			<cfcase value="MSSQL">
				<cfset connection = createObject('component','farcry.farcry_core.packages.fourq.gateway.MSSQLGateway').init(arguments.dsn,arguments.dbowner) />
			</cfcase>
			<cfcase value="mysql">
				<cfset connection = createObject('component','farcry.farcry_core.packages.fourq.gateway.MySQLGateway').init(arguments.dsn,arguments.dbowner) />
			</cfcase>
			<cfcase value="mysql5">
				<cfset connection = createObject('component','farcry.farcry_core.packages.fourq.gateway.MySQL5Gateway').init(arguments.dsn,arguments.dbowner) />
			</cfcase>
			<cfcase value="Oracle,ora">
				<cfset connection = createObject('component','farcry.farcry_core.packages.fourq.gateway.OracleGateway').init(arguments.dsn,arguments.dbowner) />
			</cfcase>
			<cfcase value="PostgreSQL">
				<cfset connection = createObject('component','farcry.farcry_core.packages.fourq.gateway.PostgreSQLGateway').init(arguments.dsn,arguments.dbowner) />
			</cfcase>
			<cfdefaultcase>
				<cfset connection = createobject('component','farcry.farcry_core.packages.fourq.gateway.MSSQLGateway').init(arguments.dsn,arguments.dbowner) />
				<cftrace type="warning" inline="false" text="DBGatewayFactory creating farcry.farcry_core.packages.fourq.gateway.MSSQLGateway connection because no recognized connection type was specified in argument 'dbtype' to method getGateway(). Connection type passed was <b>#arguments.dbtype#</b>">
			</cfdefaultcase>
		</cfswitch>

		<cfset variables.connections[arguments.dsn] = connection />
		<cfreturn connection>
	</cffunction>
	
</cfcomponent>