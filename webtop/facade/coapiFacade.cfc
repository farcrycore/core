<cfcomponent displayname="coapiFacade" output="false">

	<cffunction name="init" returntype="void" hint="ensure coapiManager is available (should implement security model for security)">
		<cfif not structKeyExists(application,"coapiManager")>
			<cfset application.coapiManager = createObject("component","farcry.core.packages.coapi.coapiManager")>
			<cfset application.coapiManager.init()>
		</cfif>
	</cffunction>
	
	<cffunction name="getTypeFrom" hint="return properties all farcry types" returntype="array" access="remote">
		<cfargument name="scope" required="true" type="string">
		<cfargument name="refresh" required="false" default="false" type="boolean">
		<cfscript>
			var arResult = arrayNew(1);
			init();
			arResult = application.coapiManager.getFarcryScopeConflicts(arguments.scope, arguments.refresh);
		</cfscript>
		<cfreturn arResult>
	</cffunction>
	
	<cffunction name="getCFCStatus" access="remote" output="false" returntype="struct">
		<cfargument name="scope" required="true" type="string">
		<cfargument name="cfcName" required="true" type="string">
		<cfset var tmpObj = structNew()>
		<cfscript>
			init();
			application.coapiManager.refreshCFCMetaData(arguments.cfcName);
		</cfscript>
		<cfreturn application.coapiManager.getCFCStatus(arguments.scope,arguments.cfcName)>
	</cffunction>
	
	<cffunction name="renameProperty" hint="update property type and default value" returntype="struct"  access="remote">
		<cfargument name="componentName" type="string" hint="name of the component for the type or rule">
		<cfargument name="propertyName" type="string" hint="name of the component property">
		<cfargument name="renameto" type="string" hint="new name for the db column">
		<cfargument name="colType" type="string" hint="DB type content type or rule property">
		<cfargument name="colLength" type="numeric" hint="length for the db content type or rule property">
		<cfscript>
			var stResult = structNew();
			init();
			stResult = application.coapiManager.renameProperty(componentName=arguments.componentName, propertyName=arguments.propertyName, renameto=arguments.renameto, colType=arguments.colType, colLength=arguments.colLength);
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="deployProperty" returntype="struct" access="remote">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="cfcType" required="true" type="string">
		<cfscript>
			var stResult = structNew();
			
			init();
			stResult = application.coapiManager.deployProperty(arguments.componentName,arguments.propertyName,arguments.cfcType);
		</cfscript>
			
		<cfreturn stResult>
	</cffunction>

	<cffunction name="repairProperty" access="remote" returntype="struct">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="dbType" required="true" type="string">
		<cfscript>
			var stResult = structNew();
			init();
			stResult = application.coapiManager.repairProperty(arguments.componentName,arguments.propertyName,arguments.dbType);
		</cfscript>
		<cfreturn stResult>
	</cffunction>

	<cffunction name="deleteProperty" access="remote" returntype="struct">
		<cfargument name="componentName" required="true" type="string">	
		<cfargument name="propertyName" required="true" type="string">
		<cfargument name="dbType" required="true" type="string">
		<cfscript>
			var stResult = structNew();
			init();
			stResult = application.coapiManager.deleteProperty(arguments.componentName,arguments.propertyName,arguments.dbType);
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="deployCFC"  access="remote">
		<cfargument name="componentName" required="true" type="string">	
		<cfscript>
			var stResult = structNew();
			init();
			stResult = application.coapiManager.deployCFC(arguments.componentName);
		</cfscript>
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="refreshCFCMetaData"  access="remote" returntype="boolean">
		<cfargument name="componentName" type="string">
		<cfscript>
			return application.coapiManager.refreshCFCMetaData(arguments.componentName);
		</cfscript>
	</cffunction>
	
	
	<cffunction name="setFarcryScopeDbStruct"  access="remote" returntype="any">
		<cfscript>
			return application.coapiManager.getFarcryScopeConflicts("types");
		</cfscript>
	</cffunction>

	<cffunction name="buildDBTableStructure"  access="remote" returntype="any">
		<cfargument name="typename">
		<cfscript>
			return application.coapiManager.getDBTableStruct(arguments.typename);
		</cfscript>
	</cffunction>
	<cffunction name="stDB"  access="remote" returntype="any">
		
		<cfscript>
			return application.coapiManager.stDB();
		</cfscript>
	</cffunction>
	
	

</cfcomponent>