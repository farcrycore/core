<cfcomponent displayname="Update App" hint="Provides a granular way to update parts of the application state" extends="forms" output="false">
	<cfproperty name="webtop" type="boolean" default="0" hint="Reload webtop data" ftSeq="1" ftFieldset="Data" ftLabel="Webtop" ftType="boolean" />
	<cfproperty name="friendlyurls" type="boolean" default="0" hint="Reload friendly urls" ftSeq="2" ftFieldset="Data" ftLabel="Friendly URLs" ftType="boolean" />
	<cfproperty name="reloadconfig" type="boolean" default="0" hint="Reloads config data" ftSeq="3" ftFieldset="Data" ftLabel="Config settings" ftType="boolean" />
	<cfproperty name="resourcebundle" type="boolean" default="0" hint="Reloads resource bundles" ftSeq="4" ftFieldset="Data" ftLabel="Resource bundles" ftType="boolean" />
	
	<cfproperty name="typemetadata" type="boolean" default="0" hint="Reload type metadata" ftSeq="11" ftFieldset="COAPI" ftLabel="COAPI metadata" ftType="boolean" />
	
	<cfproperty name="security" type="boolean" default="0" hint="Reload user directories" ftSeq="21" ftFieldset="Security" ftLabel="Security" ftType="boolean" />
	<cfproperty name="javascript" type="boolean" default="0" hint="Reload javascript libraries" ftSeq="30" ftFieldset="Javascript" ftLabel="Javascript" ftType="boolean" />
	
	<cfproperty ftSeq="35" ftFieldset="" name="factories" type="boolean" default="0" hint="Reload factories" ftLabel="Factories" ftType="boolean" />
	
	<cffunction name="process" access="public" output="true" returntype="struct" hint="Performs application refresh according to options selected">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<cfset var thisprop = "" />
		<cfset var bSuccess = false />
		
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		
		<cfparam name="arguments.fields.bOutput" default="false" />
		
		<cfloop collection="#application.stCOAPI.UpdateApp.stProps#" item="thisprop">
			<cfif not listcontains("objectid,label,datetimecreated,createdby,ownedby,datetimelastupdated,lastupdatedby,lockedby,locked",thisprop) and structkeyexists(this,"process#thisprop#")>
				<cfinvoke component="#this#" method="process#thisprop#" returnvariable="bSuccess" />
				<cfif bSuccess and arguments.bOutput>
					<extjs:bubble title="#application.stCOAPI.UpdateApp.stProps[thisprop].metadata.ftLabel#" message="Done" />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn arguments.fields />
	</cffunction>

	<cffunction name="processWebtop" access="public" returntype="boolean" description="Resets the webtop" output="false">
		<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processFriendlyURLs" access="public" returntype="boolean" description="Resets friendly urls" output="false">
		<cfset createObject("component","#application.packagepath#.farcry.fu").refreshApplicationScope() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processReloadConfig" access="public" returntype="boolean" description="Resets config" output="false">
		<cfset var oConfig = "" />
		<cfset var configkey = "" />
		
		<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
		<cfset structclear(application.config) />
		<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
			<cfset application.config[configkey] = oConfig.getConfig(configkey) />
		</cfloop>
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processTypeMetadata" access="public" returntype="boolean" description="Resets type metadata" output="false">
		<cfset createObject("component", "#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processSecurity" access="public" returntype="boolean" description="Resets security" output="false">
		<cfset application.security = createobject("component",application.factory.oUtils.getPath("security","security")).init() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processResourceBundle" access="public" returntype="boolean" description="Resets resource bundles" output="false">
		<cfset application.rb=createObject("component",application.factory.oUtils.getPath("resources","RBCFC")).init(application.locales) />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processJavaScript" access="public" returntype="boolean" description="Resets JavaScript caching" output="false">
		<cfset application.randomID = createUUID() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processFactories" access="public" returntype="boolean" description="Resets FarCry factories" output="false">
		<cfset application.factory.oAlterType = createobject("component","#application.packagepath#.farcry.alterType") />
		<cfset application.factory.oAuthorisation = createobject("component","#application.packagepath#.security.authorisation") />
		<cfset application.factory.oUtils = createobject("component","#application.packagepath#.farcry.utils") />
		<cfset application.factory.oAudit = createObject("component","#application.packagepath#.farcry.audit") />
		<cfset application.factory.oTree = createObject("component","#application.packagepath#.farcry.tree") />
		<cfset application.factory.oCache = createObject("component","#application.packagepath#.farcry.cache") />
		<cfset application.factory.oLocking = createObject("component","#application.packagepath#.farcry.locking") />
		<cfset application.factory.oVersioning = createObject("component","#application.packagepath#.farcry.versioning") />
		<cfset application.factory.oWorkflow = createObject("component","#application.packagepath#.farcry.workflow") />
		<cfset application.factory.oStats = createObject("component","#application.packagepath#.farcry.stats") />
		<cfset application.factory.oCategory = createObject("component","#application.packagepath#.farcry.category") />
		<cfset application.factory.oGenericAdmin = createObject("component","#application.packagepath#.farcry.genericAdmin") />
		<cfset application.factory.oVerity = createObject("component","#application.packagepath#.farcry.verity") />
		<cfset application.factory.oCon = createObject("component","#application.packagepath#.rules.container") />
		<cfset application.factory.oGeoLocator = createObject("component","#application.packagepath#.farcry.geoLocator") />
		<cfset application.bGeoLocatorInit = application.factory.oGeoLocator.init() />
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU") />
			<cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn true />
	</cffunction>

</cfcomponent>