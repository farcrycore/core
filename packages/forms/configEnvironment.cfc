<cfcomponent displayname="Environment Configuration" extends="forms" key="environment" output="false"
	hint="Configure environment specific settings for your FarCry application ">

	<cfproperty name="canonicalDomain" type="string" default="" required="false"
		ftSeq="1" ftFieldset="Canonical URL" ftLabel="Canonical Domain"
		ftType="string" 
		ftHint="The canonical domain used in your production environment (e.g. www.mydomain.com)"
		ftHelpSection="Configure your canonical URL for use with canonical metadata used by search engines and other fully qualified permalinks.">

	<cfproperty name="canonicalProtocol" type="string" default="http" required="false"
		ftSeq="2" ftFieldset="Canonical URL" ftLabel="Canonical Protocol"
		ftType="list" ftList="http:HTTP,https:HTTPS"
		ftHint="The protocol used by your canonical domain">

	<cfproperty name="bShowEnvironment" type="boolean" default="true" required="false"
		ftSeq="9" ftFieldset="Environment Header" ftLabel="Show Environment in Header"
		ftType="boolean" ftDefault="true"
		ftHint="Check this box to show the Environment Label in the webtop header"
		ftHelpSection="Configure your production, staging and development domains to allow the application environment to be displayed in the webtop header. The domains can be a list of comma or line-break separated domain names, and can optionally start with an askterisk (*) to perform a wildcard match. The CSS Color can be any valid CSS color value which will be used as the environment label background.">

	<cfproperty name="labelProduction" type="string" default="Production" required="false"
		ftSeq="10" ftFieldset="Production Environment" ftLabel="Label"
		ftType="string">

	<cfproperty name="lDomainsProduction" type="longchar" default="" required="false"
		ftSeq="11" ftFieldset="Production Environment" ftLabel="Domains" 
		ftType="longchar"
		ftHint="e.g. farcrycore.org, www.farcrycore.org">

	<cfproperty name="colorProduction" type="string" default="##66CC44" required="false"
		ftSeq="12" ftFieldset="Production Environment" ftLabel="CSS Color"
		ftType="string" ftDefault="##66CC44"
		ftHint="e.g. ##66CC44">

	<cfproperty name="labelStaging" type="string" default="Staging" required="false"
		ftSeq="20" ftFieldset="Staging Environment" ftLabel="Label"
		ftType="string">

	<cfproperty name="lDomainsStaging" type="longchar" default="" required="false"
		ftSeq="21" ftFieldset="Staging Environment" ftLabel="Domains" 
		ftType="longchar"
		ftHint="e.g. stage.farcrycore.org">

	<cfproperty name="colorStaging" type="string" default="##FFCC00" required="false"
		ftSeq="22" ftFieldset="Staging Environment" ftLabel="CSS Color"
		ftType="string" ftDefault="##FFCC00"
		ftHint="e.g. ##FFCC00">

	<cfproperty name="labelDevelopment" type="string" default="Development" required="false"
		ftSeq="30" ftFieldset="Development Environment" ftLabel="Label"
		ftType="string">

	<cfproperty name="lDomainsDevelopment" type="longchar" default="127.0.0.1, localhost, *.local" required="false"
		ftSeq="31" ftFieldset="Development Environment" ftLabel="Domains" 
		ftType="longchar" ftDefault="127.0.0.1, localhost, *.local"
		ftHint="e.g. 127.0.0.1, localhost, *.local">

	<cfproperty name="colorDevelopment" type="string" default="##AAAAAA" required="false"
		ftSeq="32" ftFieldset="Development Environment" ftLabel="CSS Color"
		ftType="string" ftDefault="##AAAAAA"
		ftHint="e.g. ##AAAAAA">

	<cfproperty name="labelUnknown" type="string" default="Unknown" required="false"
		ftSeq="40" ftFieldset="Unknown Environment" ftLabel="Label"
		ftType="string">

	<cfproperty name="colorUnknown" type="string" default="##CC3333" required="false"
		ftSeq="41" ftFieldset="Unknown Environment" ftLabel="CSS Color"
		ftType="string" ftDefault="##CC3333"
		ftHint="e.g. ##CC3333">


	<!--- environment methods --->

	<cffunction name="getEnvironment" output="false" returntype="string">
		<cfargument name="hostname" default="#listFirst(cgi.http_host, ":")#">
		<cfargument name="ip" default="#cgi.remote_addr#">

		<cfset var env = "">
		<cfset var domain = "">
		<cfset var lDomains = "">

		<cfset var lEnvironments = "production,staging,development">
		<cfloop list="#lEnvironments#" index="env">
			<!--- get lDomains --->
			<cfset lDomains = application.fapi.getConfig("environment", "lDomains" & env)>
			<cfloop list="#lDomains#" index="domain" delimiters=",#chr(32)##chr(13)##chr(10)#">
				<cfif left(domain, 1) eq "*">
					<cfif findNoCase(right(domain,len(domain)-1), arguments.hostname)>
						<cfreturn env>
					</cfif>
				<cfelseif arguments.hostname eq domain OR arguments.hostname eq arguments.ip> 
					<cfreturn env>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn "unknown">
	</cffunction>

	<cffunction name="getLabel" output="false" returntype="string">
		<cfargument name="environment" default="#getEnvironment()#">

		<cfreturn application.fapi.getConfig("environment", "label" & arguments.environment)>
	</cffunction>
	
	<cffunction name="getColor" output="false" returntype="string">
		<cfargument name="environment" default="#getEnvironment()#">

		<cfset var color = application.fapi.getConfig("environment", "color" & arguments.environment)>
		<cfif NOT len(color)>
			<cfset color = "##AAAAAA">			
		<cfelseif NOT left(color, 1) eq "##" AND NOT reFind("[0-9]", color)>
			<cfset color = "##" & color>
		</cfif>

		<cfreturn color>
	</cffunction>


</cfcomponent>