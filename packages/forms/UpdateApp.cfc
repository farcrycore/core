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
		
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		
		<!--- Webtop reload --->
		<cfif structkeyexists(arguments.fields,"webtop") and arguments.fields.webtop>
			<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
			<extjs:bubble title="Reloaded webtop" />
		</cfif>
		
		<!--- Friendly URLs --->
		<cfif structkeyexists(arguments.fields,"friendlyurls") and arguments.fields.friendlyurls>
			<cfset createObject("component","#application.packagepath#.farcry.fu").refreshApplicationScope() />
			<extjs:bubble title="Reloaded friendly URLs" />
		</cfif>
		
		<!--- Config settings --->
		<cfif structkeyexists(arguments.fields,"config") and arguments.fields.config>
			<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
			<cfset structclear(application.config) />
			<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
				<cfset application.config[configkey] = oConfig.getConfig(configkey) />
			</cfloop>
			<extjs:bubble title="Reloaded config settings" />
		</cfif>
		
		<!--- Type metadata --->
		<cfif structkeyexists(arguments.fields,"typemetadata") and arguments.fields.typemetadata>
			<cfset createObject("component", "#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
			<extjs:bubble title="Reloaded COAPI metadata" />
		</cfif>
		
		<!--- User directories --->
		<cfif structkeyexists(arguments.fields,"security") and arguments.fields.security>	
			<cfset application.security = createobject("component",application.factory.oUtils.getPath("security","security")).init() />
			<extjs:bubble title="Reloaded security components and cache" />
		</cfif>
		
		<!--- Resource bundles --->
		<cfif structkeyexists(arguments.fields,"resourcebundles") and arguments.fields.resourcebundles>
			<cfset application.rb=createObject("component",application.factory.oUtils.getPath("resources","RBCFC")).init(application.locales) />
			<extjs:bubble title="Reloaded resource bundles" />
		</cfif>
		
		<!--- Javascript --->
		<cfif structkeyexists(arguments.fields,"Javascript") and arguments.fields.Javascript>
			<cfset application.randomID = createUUID() />
			<extjs:bubble title="Reloaded javascript" />
		</cfif>
		
		<!--- initialise factory objects --->
		<cfif structkeyexists(arguments.fields,"factories") and arguments.fields.factories>
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
			<extjs:bubble title="Reloaded factories" />
		</cfif>
		
		<cfreturn arguments.fields />
	</cffunction>

</cfcomponent>