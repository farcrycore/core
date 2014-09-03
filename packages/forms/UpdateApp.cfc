<cfcomponent displayname="Update App" hint="Provides a granular way to update parts of the application state" extends="forms" output="false">
		
	<cfproperty ftSeq="1" ftFieldset="Reinitialize" name="reinit" type="boolean" default="0" hint="Re-Initialize the entire application" ftLabel="Reinitialize Application" ftType="boolean" ftHint="This will reinitialize the entire application. It should be used when manually changing the FarCry Contructor located in the webroot of your project." />
	
	<cfproperty ftSeq="5" ftFieldset="COAPI" name="typemetadata" type="boolean" default="0" hint="Reload type metadata" ftLabel="COAPI metadata" ftType="boolean" />
	
	<cfproperty ftSeq="6" ftFieldset="Security" name="security" type="boolean" default="0" hint="Reload user directories" ftLabel="Security" ftType="boolean" />
	
	<cfproperty ftSeq="10" ftFieldset="Miscellaneous" name="webtop" type="boolean" default="0" hint="Reload webtop data" ftLabel="Webtop" ftType="boolean" />
	<cfproperty ftSeq="11" ftFieldset="Miscellaneous" name="friendlyurls" type="boolean" default="0" hint="Reload friendly urls" ftLabel="Friendly URLs" ftType="boolean" />
	<cfproperty ftSeq="12" ftFieldset="Miscellaneous" name="reloadconfig" type="boolean" default="0" hint="Reloads config data" ftLabel="Config settings" ftType="boolean" />
	<cfproperty ftSeq="13" ftFieldset="Miscellaneous" name="resourcebundle" type="boolean" default="0" hint="Reloads resource bundles" ftLabel="Resource bundles" ftType="boolean" />
	<cfproperty ftSeq="14" ftFieldset="Miscellaneous" name="javascript" type="boolean" default="0" hint="Reload javascript libraries" ftLabel="Javascript" ftType="boolean" />
	<cfproperty ftSeq="15" ftFieldset="Miscellaneous" name="factories" type="boolean" default="0" hint="Reload factories" ftLabel="Factories" ftType="boolean" />
	<cfproperty ftSeq="16" ftFieldset="Miscellaneous" name="wizards" type="boolean" default="0" hint="Re-Initialize all Wizards" ftLabel="Wizards" ftType="boolean" ftHint="This will reset all wizards. Any changes currently in progress will be deleted." />

	
	<cffunction name="process" access="public" output="true" returntype="struct" hint="Performs application refresh according to options selected">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<cfset var thisprop = "" />
		<cfset var bSuccess = false />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfparam name="arguments.fields.bOutput" default="true" />
		
		<cfloop collection="#application.stCOAPI.UpdateApp.stProps#" item="thisprop">
			<cfif not listcontainsnocase("objectid,label,datetimecreated,createdby,ownedby,datetimelastupdated,lastupdatedby,lockedby,locked",thisprop) and structkeyexists(arguments.fields,thisprop) and arguments.fields[thisprop] and structkeyexists(this,"process#thisprop#")>
				<cfinvoke component="#this#" method="process#thisprop#" returnvariable="bSuccess" />
				<cfif bSuccess and arguments.fields.bOutput>
					<skin:bubble title="#application.stCOAPI.UpdateApp.stProps[thisprop].metadata.ftLabel#" message="Done" tags="system,info" />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn arguments.fields />
	</cffunction>

	<cffunction name="processWebtop" access="public" returntype="boolean" description="Resets the webtop" output="false">
		<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="processReinit" access="public" returntype="boolean" description="Reinitializes the entire application" output="false">
		
		<cfset application.binit = false />
		
		<cflocation url="#cgi.script_name#?#cgi.query_string#" addtoken="false" />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processFriendlyURLs" access="public" returntype="boolean" description="Resets friendly urls" output="false">
		<cfset application.fc.factory.farFU.onAppInit() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processReloadConfig" access="public" returntype="boolean" description="Resets config" output="false">
		<cfset var oConfig = "" />
		<cfset var configkey = "" />
		
		<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
		<cfset oConfig.reloadConfig()>
		
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
		<cfset application.randomID = application.fc.utils.createJavaUUID() />
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processFactories" access="public" returntype="boolean" description="Resets FarCry factories" output="false">
		<cfset application.factory.oAlterType = createobject("component","#application.packagepath#.farcry.alterType") />
		<cfset application.factory.oUtils = createobject("component","#application.packagepath#.farcry.utils") />
		<cfset application.factory.oTree = createObject("component","#application.packagepath#.farcry.tree") />
		<cfset application.factory.oCache = createObject("component","#application.packagepath#.farcry.cache") />
		<cfset application.factory.oLocking = createObject("component","#application.packagepath#.farcry.locking") />
		<cfset application.factory.oVersioning = createObject("component","#application.packagepath#.farcry.versioning") />
		<cfset application.factory.oWorkflow = createObject("component","#application.packagepath#.farcry.workflow") />
		<cfset application.factory.oCategory = createObject("component","#application.packagepath#.farcry.category") />
		<cfset application.factory.oCon = createObject("component","#application.packagepath#.rules.container") />
		<cftry>
			<cfset application.factory.oFU = createObject("component","#application.packagepath#.farcry.FU") />
			<cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn true />
	</cffunction>

	<cffunction name="processWizards" access="public" returntype="boolean" description="Resets Wizard Table" output="false">
		<cfset var qDeleteWizards = queryNew("")>
		<!--- Wizards --->
		<cfquery datasource="#application.dsn#" name="qDeleteWizards">
			delete from dmWizard
		</cfquery>
		
		<cfreturn true />
	</cffunction>
	
</cfcomponent>
