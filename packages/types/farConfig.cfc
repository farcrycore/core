<cfcomponent displayname="Configuration" hint="Encapsulates all config value sets" extends="types" output="false">
	<cfproperty name="configkey" type="string" default="" hint="The variable used in the config struct" ftSeq="1" ftLabel="Key" ftType="string" ftValidation="required" bLabel="true" />
	<cfproperty name="configdata" type="longchar" default="" hint="The config values encoded in WDDX" ftSeq="2" ftLabel="Config" ftType="WDDX" ftChangable="false" />
	
	<cffunction name="migrateConfig" access="public" output="false" returntype="struct" hint="Creates a new config record based on pre 4.1 data">
		<cfargument name="key" type="string" required="true" hint="The key of the old config record" />
		
		<cfset var stResult = structnew() />
		<cfset var qConfig = "" />
		<cfset var wConfig = "" />
		<cfset var stObj = structnew() />
		
		<cfquery datasource="#application.dsn#" name="qConfig">
			select		configname, wConfig
			from		#application.dbowner#config
			where		configname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#">
		</cfquery>
		
		<cfif qConfig.recordcount>
			<!--- Set up the config item values --->
			<cfset stObj.objectid = createuuid() />
			<cfset stObj.typename = "farConfig" />
			<cfset stObj.configkey = trim(arguments.key) />
			
			<!--- Get data --->
			<cfwddx action="wddx2cfml" input="#qConfig.wConfig#" output="stResult" />
			
			<!--- Find the config form component with that key and get the default values --->
			<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
				<cfif left(thisform,6) eq "config" and application.stCOAPI[thisform].key eq trim(arguments.key)>
					<cfset structappend(stResult,createobject("component",application.stCOAPI[thisform].packagepath).getData(createuuid()),false) />
					<cfset stResult.typename = thisform />
				</cfif>
			</cfloop>
			
			<cfwddx action="cfml2wddx" input="#stResult#" output="stObj.configdata" />
			
			<!--- Save the config data --->
			<cfset createData(stProperties=stObj) />
		</cfif>
		
		<cfreturn stObj />
	</cffunction>
	
	<cffunction name="getConfig" access="public" output="true" returntype="struct" hint="Finds the config for the specified config, create it if it doesn't exist, then return it">
		<cfargument name="key" type="string" required="true" hint="The key of the config to load" />
		<cfargument name="bAudit" type="boolean" default="true" required="false" hint="Allows the installer to not audit" />
		
		<cfset var stResult = structnew() />
		<cfset var qConfig = "" />
		<cfset var stObj = structnew() />
		<cfset var thisform = "" />
		<cfset var wConfig = "" />
		<cfset var configkey = "" />
		
		<!--- Find a config item that stores this config data --->
		<cfquery datasource="#application.dsn#" name="qConfig">
			select	*
			from	farConfig
			where	configkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.key#" />
		</cfquery>
		
		<cfif qConfig.recordcount>
			<!--- If the config item exists convert the data to a struct --->
			<cfwddx action="wddx2cfml" input="#qConfig.configdata[1]#" output="stResult" />
		</cfif>
		
		<cfif not qConfig.recordcount or not isstruct(stResult)>
			<!--- Set up the config item values --->
			<cfif qConfig.recordcount>
				<cfset stObj.objectid = qConfig.objectid[1] />
			<cfelse>
				<cfset stObj.objectid = createuuid() />
			</cfif>
			<cfset stObj.typename = "farConfig" />
			<cfset stObj.configkey = arguments.key />
			
			<!--- If it doesn't, find the config form component with that key and get the default values --->
			<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
				<cfif left(thisform,6) eq "config" and application.stCOAPI[thisform].key eq arguments.key>
					<cfset stResult = createobject("component",application.stCOAPI[thisform].packagepath).getData(createuuid()) />
					<cfset stResult.typename = thisform />
				</cfif>
			</cfloop>
			
			<cfwddx action="cfml2wddx" input="#stresult#" output="stObj.configdata" />
			
			<!--- Save the config data --->
			<cfset setData(stProperties=stObj,bAudit=arguments.bAudit) />
		</cfif>
		
		<cfif structkeyexists(stResult,"typename")>
			<cfset structdelete(stResult,"typename") />
		</cfif>
		<cfif structkeyexists(stResult,"objectid")>
			<cfset structdelete(stResult,"objectid") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getConfigKeys" access="public" output="false" returntype="string" hint="Returns a list of the config keys the application supports">
		<cfset var thisform = "" />
		<cfset var result = "" />
		<cfset var qConfig = "" />
		
		<cfquery datasource="#application.dsn#" name="qConfig">
			select	*
			from	#application.dbowner#farConfig
			<cfif len(result)>
				where	configkey not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="result" />)
			</cfif>
		</cfquery>
		
		<cfset result = valuelist(qConfig.configkey) />
		
		<cfloop list="#application.factory.oUtils.getComponents('forms')#" index="thisform">
			<cfif left(thisform,6) eq "config" and not listcontains(result,application.stCOAPI[thisform].key)>
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