<cfsetting enablecfoutputonly="true" />

<cfparam name="form.filters" default="" />

<cffunction name="filterWebskins" access="public" output="false" returntype="query" hint="Returns a query of the webskins that match this filter">
	<cfargument name="webskins" type="query" required="true" hint="The webskin query" />
	<cfargument name="filter" type="string" required="true" hint="The filter to apply" />
	
	<cfset var qResult = "" />
	
	<cfquery dbtype="query" name="qResult">
		select	methodname
		from	arguments.webskins
		where 	methodname like <cfqueryparam cfsqltype="cf_sql_varchar" value="#replace(arguments.filter,'*','%')#" />
	</cfquery>
	
	<cfreturn qResult />
</cffunction>

<!--- Initialize webskin result set --->
<cfset stWebskins = structnew() />
<cfloop collection="#application.stCOAPI#" item="thistype">
	<cfloop query="application.stCOAPI.#thistype#.qWebskins">
		<cfif methodname neq "deniedaccess">
			<cfset stWebskins[thistype][methodname] = "Denied" />
		</cfif>
	</cfloop>
</cfloop>

<!--- Update granted webskins --->
<cfloop list="#form.filters#" index="filter" delimiters="#chr(10)##chr(13)#,">
	<cfif not find(".",filter) or listfirst(filter,".") eq "*">
		<cfset types = structkeylist(application.stCOAPI) />
	<cfelse>
		<cfset types = listfirst(filter,".") />
	</cfif>
	
	<cfloop list="#types#" index="thistype">
		<cfset qWebskins = filterWebskins(application.stCOAPI[thistype].qWebskins,listlast(filter,".")) />
		<cfloop query="qWebskins">
			<cfif methodname neq "deniedaccess">
				<cfset stWebskins[thistype][methodname] = "Granted" />
			</cfif>
		</cfloop>
	</cfloop>
</cfloop>

<!--- Output result --->
<cfset rows = "" />
<cfset total = 0 />
<cfloop collection="#stWebskins#" item="thistype">
	<cfloop collection="#stWebskins[thistype]#" item="webskin">
		<cfset rows = listappend(rows,"{Type:'#thistype#',Webskin:'#Webskin#',Right:'#stWebskins[thistype][webskin]#'}") />
		<cfset total = total + 1 />
	</cfloop>
</cfloop>
<cfoutput>{rows:[#rows#],total:#total#}</cfoutput>

<cfsetting enablecfoutputonly="false" />