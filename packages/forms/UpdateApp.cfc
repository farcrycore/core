<cfcomponent displayname="Update App" hint="Provides a granular way to update parts of the application state" extends="forms" output="false">
	<cfproperty name="webtop" type="boolean" default="0" hint="Reload webtop data" ftSeq="1" ftFieldset="Data" ftLabel="Webtop" ftType="boolean" />
	<cfproperty name="friendlyurls" type="boolean" default="0" hint="Reload friendly urls" ftSeq="2" ftFieldset="Data" ftLabel="Friendly URLs" ftType="boolean" />
	<cfproperty name="reloadconfig" type="boolean" default="0" hint="Reloads config data" ftSeq="3" ftFieldset="Data" ftLabel="Config settings" ftType="boolean" />
	<cfproperty name="resourcebundle" type="boolean" default="0" hint="Reloads resource bundles" ftSeq="4" ftFieldset="Data" ftLabel="Resource bundles" ftType="boolean" />
	
	<cfproperty name="typemetadata" type="boolean" default="0" hint="Reload type metadata" ftSeq="11" ftFieldset="COAPI" ftLabel="COAPI metadata" ftType="boolean" />
	
	<cfproperty name="security" type="boolean" default="0" hint="Reload user directories" ftSeq="21" ftFieldset="Security" ftLabel="Security" ftType="boolean" />
	
	<cffunction name="process" access="public" output="true" returntype="struct" hint="Performs application refresh according to options selected">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<!--- Webtop reload --->
		<cfif structkeyexists(arguments.fields,"webtop") and arguments.fields.webtop>
			<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
		</cfif>
		
		<!--- Friendly URLs --->
		<cfif structkeyexists(arguments.fields,"friendlyurls") and arguments.fields.friendlyurls>
			<cfset createObject("component","#application.packagepath#.farcry.fu").refreshApplicationScope() />
		</cfif>
		
		<!--- Config settings --->
		<cfif structkeyexists(arguments.fields,"config") and arguments.fields.config>
			<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
			<cfset structclear(application.config) />
			<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
				<cfset application.config[configkey] = oConfig.getConfig(configkey) />
			</cfloop>
		</cfif>
		
		<!--- Type metadata --->
		<cfif structkeyexists(arguments.fields,"typemetadata") and arguments.fields.typemetadata>
			<cfset createObject("component", "#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
		</cfif>
		
		<!--- User directories --->
		<cfif structkeyexists(arguments.fields,"security") and arguments.fields.security>	
			<cfset application.security = createobject("component",application.factory.oUtils.getPath("security","security")).init() />
		</cfif>
		
		<!--- Resource bundles --->
		<cfif structkeyexists(arguments.fields,"resourcebundles") and arguments.fields.resourcebundles>
			<cfset application.rb=createObject("component",application.factory.oUtils.getPath("resources","RBCFC")).init(application.locales) />
		</cfif>
		
		<cfreturn arguments.fields />
	</cffunction>

</cfcomponent>