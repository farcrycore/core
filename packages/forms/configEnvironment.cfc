<cfcomponent displayname="Environment Configuration" extends="forms" key="environment" output="false"
	hint="Identify your FarCry application environment in the webtop using colors and labels">

	<cfproperty name="labelProduction" type="string" default="Production" required="false"
		ftSeq="10" ftFieldset="Production Environment" ftLabel="Production Label"
		ftType="string">

	<cfproperty name="colorProduction" type="string" default="##66CC44" required="false"
		ftSeq="12" ftFieldset="Production Environment" ftLabel="Production Color"
		ftType="string" ftDefault="##66CC44">

	<cfproperty name="lDomainsProduction" type="longchar" default="" required="false"
		ftSeq="11" ftFieldset="Production Environment" ftLabel="Production Domains" 
		ftType="longchar">

	<cfproperty name="labelStaging" type="string" default="Staging" required="false"
		ftSeq="20" ftFieldset="Staging Environment" ftLabel="Staging Label"
		ftType="string">

	<cfproperty name="colorStaging" type="string" default="##FFCC00" required="false"
		ftSeq="22" ftFieldset="Staging Environment" ftLabel="Staging Color"
		ftType="string" ftDefault="##FFCC00">

	<cfproperty name="lDomainsStaging" type="longchar" default="" required="false"
		ftSeq="21" ftFieldset="Staging Environment" ftLabel="Staging Domains" 
		ftType="longchar">

	<cfproperty name="labelDevelopment" type="string" default="Development" required="false"
		ftSeq="30" ftFieldset="Development Environment" ftLabel="Development Label"
		ftType="string">

	<cfproperty name="colorDevelopment" type="string" default="##AAAAAA" required="false"
		ftSeq="32" ftFieldset="Development Environment" ftLabel="Development Color"
		ftType="string"  ftDefault="##AAAAAA">

	<cfproperty name="lDomainsDevelopment" type="longchar" default="127.0.0.1,localhost,*.local" required="false"
		ftSeq="31" ftFieldset="Development Environment" ftLabel="Development Domains" 
		ftType="longchar" ftDefault="127.0.0.1,localhost,*.local">


	<cffunction name="getEnvironment" returntype="string">
		<cfargument name="hostname" default="#listFirst(cgi.http_host, ":")#">
		<cfargument name="ip" default="#cgi.http_addr#">

		<cfset var env = "">
		<cfset var domain = "">

		<cfset var lEnvironments = "production,staging,development">
		<cfloop list="#lEnvironments#" index="env">
			<!--- get lDomains --->
			<cfset lDomains = application.fapi.getConfig("environment", "lDomains" & env)>
			<cfloop list="#lDomains#" index="domain" delimiters=",#chr(13)##chr(10)#">
				<cfif left(domain, 1) eq "*">
					<cfif findNoCase(right(domain,len(domain)-1), arguments.hostname)>
						<cfreturn env>
					</cfif>
				<cfelseif arguments.hostname eq domain OR arguments.hostname eq arguments.ip> 
					<cfreturn env>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn "development">
	</cffunction>


	<cffunction name="getLabel" returntype="string">
		<cfargument name="environment" default="#getEnvironment()#">

		<cfreturn application.fapi.getConfig("environment", "label" & arguments.environment)>
	</cffunction>
	
	<cffunction name="getColor" returntype="string">
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