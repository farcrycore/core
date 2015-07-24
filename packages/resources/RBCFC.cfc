<cfcomponent hint="Manage resource bundles" output="false">
	
	<cfset this.aSets = arraynew(1) />
	<cfset this.lSets = "" />
	<cfset this.locales = false />

	<cfset this.description = "Basic resource bundle management" />

	<cffunction name="init" access="public" output="false" returntype="any" hint="Initializes component">
		<cfargument name="locales" type="string" required="false" default="" />
		
		<cfset var plugin = "" />
		<cfset var stSet = "" />
		
		<!--- First item in array is always core --->
		<cfset stSet = loadSet("#application.path.core#/packages/resources",arguments.locales) />
		<cfif not structisempty(stSet)>
			<cfset arrayappend(this.aSets,stSet) />
			<cfset this.lSets=listappend(this.lSets,"core") />
		</cfif>
		
		<!--- Add plugins in order declared --->
		<cfloop list="#application.plugins#" index="plugin">
			<cfset stSet = loadSet("#application.path.plugins#/#plugin#/packages/resources",arguments.locales) />
			<cfif not structisempty(stSet)>
				<cfset arrayappend(this.aSets,stSet) />
				<cfset this.lSets=listappend(this.lSets,plugin) />
			</cfif>
		</cfloop>
		
		<!--- Last item in array is always the project --->
		<cfset stSet = loadSet("#application.path.project#/packages/resources",arguments.locales) />
		<cfif not structisempty(stSet)>
			<cfset arrayappend(this.aSets,stSet) />
			<cfset this.lSets=listappend(this.lSets,"project") />
		</cfif>
				
		<cfset this.locales = arguments.locales />
				
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadSet" access="private" output="false" returntype="struct" hint="Returns requested bundles plus base in a struct">
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="locales" type="string" required="false" default="" />
		
		<cfset var stResult = structnew() />
		<cfset var locale = "" />
		
		<!--- Make sure the depreciated application.adminBundle variable exists --->
		<cfparam name="application.adminBundle" default="#structnew()#" />
		
		<!--- Get base resources --->
		<cfset stResult['base'] = createobject("component",application.factory.oUtils.getPath("resources","ResourceBundle")).init(arguments.dir & "/admin.properties") />
		
		<cfloop list="#arguments.locales#" index="locale">
			
			<!--- Add the base for this set to the depreciated application.adminbundle variable --->
			<cfparam name="application.adminBundle['#locale#']" default="#structnew()#" />
			<cfset structappend(application.adminBundle[locale],stResult['base'].bundle,true) />
			
			<!--- Get language resource --->
			<!--- <cfset stResult[listfirst(locale,'_')] = createobject("component",application.factory.oUtils.getPath("resources","ResourceBundle")).init(arguments.dir & "/admin_#listfirst(locale,'_')#.properties") /> --->
			<!--- Add language resource to depreciated application.adminBundle variable --->
			<!--- <cfset structappend(application.adminBundle[locale],stResult[listfirst(locale,'_')].bundle,true) /> --->
			
			<!--- Get language+country resource --->
			<cfset stResult[locale] = createobject("component",application.factory.oUtils.getPath("resources","ResourceBundle")).init(arguments.dir & "/admin_#locale#.properties") />
			<!--- Add language+country resource to depreciated application.adminBundle variable --->
			<cfset structappend(application.adminBundle[locale],stResult[locale].bundle,true) />
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getResource" access="public" output="false" returntype="string" hint="Returns the resource string" bDocument="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="default" type="string" required="false" default="#arguments.key#" />
		<cfargument name="locale" type="string" required="false" default="" />
		
		<cfset var i = 0 />
		
		<cfif not len(arguments.locale)>
			<cfset arguments.locale = getCurrentLocale() />
		</cfif>
		
		<cfloop from="#arraylen(this.aSets)#" to="1" step="-1" index="i">
			<cfif structkeyexists(this.aSets[i],arguments.locale) and structkeyexists(this.aSets[i][arguments.locale].bundle,arguments.key)>
				<cfreturn this.aSets[i][arguments.locale].bundle[arguments.key] />
			</cfif>
			<cfif structkeyexists(this.aSets[i],"base") and structkeyexists(this.aSets[i]["base"].bundle,arguments.key)>
				<cfreturn this.aSets[i]["base"].bundle[arguments.key] />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.default />
	</cffunction>
	
	<cffunction name="getCurrentLocale" access="public" output="false" returntype="string" hint="Returns the current locale string based on if the client is logged in or not" bDocument="true">
		<cfset var currentLocale = "" />
		
		<cfif isDefined("session.dmProfile.locale")>
			<cfset currentLocale = session.dmProfile.locale />
		<cfelse>
			<cfset currentLocale = application.fapi.getConfig("general","locale", listFirst(application.locales)) />
		</cfif>
		
		<cfreturn currentLocale />
	</cffunction>

	<cffunction name="formatRBString" access="public" output="no" returnType="string" hint="performs messageFormat like operation on compound rb string" bDocument="true">
		<cfargument name="rbString" required="yes" type="string" />
		<cfargument name="substituteValues" required="yes" />
		<cfargument name="default" required="no" default="#arguments.rbString#" />
		<cfargument name="locale" type="string" required="false" default="" />
		
		<cfset var i=0 />
		<cfset var tmpStr=getResource(arguments.rbString,arguments.default,arguments.locale) />
		
		<cfif isArray(arguments.substituteValues)>
			<cfloop index="i" from="1" to="#arrayLen(arguments.substituteValues)#">
				<cfset tmpStr=replace(tmpStr,"{#i#}",arguments.substituteValues[i],"ALL")>
			</cfloop>
		<cfelse>
			<cfset tmpStr=replace(tmpStr,"{1}",arguments.substituteValues,"ALL")>
		</cfif>
		<cfreturn tmpStr />
	</cffunction>

</cfcomponent>