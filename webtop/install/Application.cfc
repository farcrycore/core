<cfcomponent>

	<cfset this.name = "farcryinstall" & hash(expandPath("/"))>

 
	<!--- 
	 // set up the farcry dsn from the environment 
	 -- note, this is a copy from the ./core/Application.cfc
	--------------------------------------------------------------------------------->
	<cfset system = createObject("java", "java.lang.System")>
	<cfset FARCRY_DSN = "" & system.getEnv("FARCRY_DSN")>

	<cfif len(FARCRY_DSN)>

		<!--- set the farcry dsn, dbtype and dbowner --->
		<cfset THIS.dsn = FARCRY_DSN /> 
		<cfset FARCRY_DBTYPE = system.getEnv("FARCRY_DBTYPE")>
		<cfif NOT isNull(FARCRY_DBTYPE)>
			<cfset THIS.dbType = FARCRY_DBTYPE>
		</cfif>
		<cfset FARCRY_DBOWNER = system.getEnv("FARCRY_DBOWNER")>
		<cfif NOT isNull(FARCRY_DBOWNER)>
			<cfset THIS.dbOwner = FARCRY_DBOWNER>
		</cfif>

		<!--- set up the datasource settings --->
		<cfset this.datasources[FARCRY_DSN] = {
			"class" = system.getEnv("FARCRY_DSN_CLASS"),
			"connectionString" = system.getEnv("FARCRY_DSN_CONNECTIONSTRING"),
			"database" = system.getEnv("FARCRY_DSN_DATABASE"),
			"driver" = system.getEnv("FARCRY_DSN_DRIVER"),
			"host" = system.getEnv("FARCRY_DSN_HOST"),
			"port" = system.getEnv("FARCRY_DSN_PORT"),
			"type" = system.getEnv("FARCRY_DSN_TYPE"),
			"url" = system.getEnv("FARCRY_DSN_URL"),
			"username" = system.getEnv("FARCRY_DSN_USERNAME"),
			"password" = system.getEnv("FARCRY_DSN_PASSWORD")
		}>

		<!--- set custom options when not using a connection string --->
		<cfset FARCRY_DSN_CUSTOM = system.getEnv("FARCRY_DSN_CUSTOM")>
		<cfif NOT isNull(FARCRY_DSN_CUSTOM) AND len(FARCRY_DSN_CUSTOM)>
			<cfif isJSON(FARCRY_DSN_CUSTOM)>
				<cfset this.datasources[FARCRY_DSN].custom = deserializeJSON(FARCRY_DSN_CUSTOM)>
			<cfelse>
				<cfset stCustom = {}>
				<cfloop list="#FARCRY_DSN_CUSTOM#" index="item" delimiters="&">
					<cfset stCustom[listFirst(item, "=")] = listRest(item, "=")>
				</cfloop>
				<cfset this.datasources[FARCRY_DSN].custom = stCustom>
			</cfif>
		</cfif>

		<!--- set linked db hostname/port using the provided alias --->
		<cfset FARCRY_DB_LINK_ALIAS = system.getEnv("FARCRY_DB_LINK_ALIAS")>
		<cfif NOT isNull(FARCRY_DB_LINK_ALIAS) AND len(FARCRY_DB_LINK_ALIAS)>
			<cfset DB_PORT = system.getEnv(ucase(FARCRY_DB_LINK_ALIAS) & "_PORT")>
			<cfif NOT isNull(DB_PORT) AND len(DB_PORT)>
				<cfset this.datasources[FARCRY_DSN].host = listFirst(listLast(DB_PORT, "/"), ":")>
				<cfset this.datasources[FARCRY_DSN].port = listLast(listLast(DB_PORT, "/"), ":")>
			</cfif>
		</cfif>
	</cfif>

</cfcomponent>