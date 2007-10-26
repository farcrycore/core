<cfcomponent displayname="Configuration" hint="Encapsulates all config value sets" extends="types" output="false">
	<cfproperty name="configkey" type="string" default="" hint="The variable used in the config struct" ftSeq="1" ftLabel="Key" ftType="string" ftValidation="required" bLabel="true" />
	<cfproperty name="configdata" type="longchar" default="" hint="The config values encoded in WDDX" ftSeq="2" ftLabel="Config" ftType="WDDX" ftChangable="false" />
	
	<cffunction name="getConfig" access="public" output="false" returntype="struct" hint="Finds the config for the specified config, create it if it doesn't exist, then return it">
		<cfargument name="key" type="string" required="true" hint="The key of the config to load" />
		
		<cfset var stResult = structnew() />
		<cfset var qConfig = "" />
		<cfset var stObj = structnew() />
		<cfset var thisform = "" />
		<cfset var stConfig = "" />
		<cfset var wConfig = "" />
		<cfset var configkey = "" />
		
		<!--- Find a config item that stores this config data --->
		<cfquery datasource="#application.dsn#" name="qConfig">
			select	*
			from	dmConfig
			where	configkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#" />
		</cfquery>
		
		<cfif qConfig.recordcount>
			<!--- If the config item exists convert the data to a struct --->
			<cfwddx action="wddx2cfml" input="#qConfig.configdata[1]#" output="stResult" />
		<cfelse>
			<!--- If it doesn't, find the config form component with that key and get the default values --->
			<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
				<cfif refindnocase("^config",thisform) and application.stCOAPI[thisform].key eq arguments.key>
					<cfset stResult = createobject("component",application.stCOAPI[thisform].packagepath).getData(createuuid()) />
					<cfset stResult.typename = thisform />
				</cfif>
			</cfloop>
		
			<!--- Set up the config item values --->
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.typename = "dmConfig" />
			<cfset stObj.configkey = arguments.key />
			
			<!--- Check to see if the old version is still in the system --->
			<!--- <cftry> --->
				
				<cfquery datasource="#application.dsn#" name="qConfig">
					select		*
					from		#application.dbowner#config
					where		configname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#">
				</cfquery>
				
				<cfif qConfig.recordcount>
					<!--- Get data --->
					<cfwddx action="wddx2cfml" input="#qConfig.wConfig#" output="stConfig" />
					
					<!--- If data has not been copied --->
					<cfif not structkeyexists(stConfig,"copied") or not stConfig.copied>
						<cfloop collection="#stConfig#" item="configkey">
							<cfset stResult[configkey] = stConfig[configkey] />
						</cfloop>
					</cfif>
					
					<!--- Set data as copied --->
					<cfset stConfig.copied = true />
					<cfwddx action="cfml2wddx" input="#stConfig#" output="wConfig" />
					<cfquery datasource="#application.dsn#">
						update		#application.dbowner#config
						set			wconfig=<cfqueryparam cfsqltype="cf_sql_varchar" value="#wConfig#" />
						where		configname=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#" />
					</cfquery>
				</cfif>
				
<!--- 				<cfcatch type="any">
					<!--- If table doesn't exist, continue --->
					
				</cfcatch>
			</cftry> --->
			
			<cfwddx action="cfml2wddx" input="#stResult#" output="stObj.configdata" />
			
			<!--- Save the config data --->
			<cfset createData(stProperties=stObj) />
		</cfif>
		
		<cfset structdelete(stResult,"typename") />
		<cfset structdelete(stResult,"objectid") />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getConfigKeys" access="public" output="false" returntype="string" hint="Returns a list of the config keys the application supports">
		<cfset var thisform = "" />
		<cfset var result = "" />
		
		<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
			<cfif refindnocase("^config",thisform)>
				<cfset result = listappend(result,application.stCOAPI[thisform].key) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="afterSave" access="public" output="false" returntype="struct" hint="Processes new type content">
		<cfargument name="stProperties" type="struct" required="true" hint="The properties that have been saved" />
		
		<cfset var config = "" />
		
		<cfwddx action="wddx2cfml" input="#arguments.stProperties.configdata#" output="config" />
		
		<cfset application.config[arguments.stProperties.configkey] = duplicate(config) />
		
		<cfreturn arguments.stProperties />
	</cffunction>
	
</cfcomponent>