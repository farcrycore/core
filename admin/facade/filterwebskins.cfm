<cfsetting enablecfoutputonly="true" />

<cfparam name="form.filters" default="" />

<cffunction name="filterWebskins" access="public" output="false" returntype="query" hint="Returns a query of the webskins that match this filter">
	<cfargument name="webskins" type="query" required="true" hint="The webskin query" />
	<cfargument name="filter" type="string" required="true" hint="The filter to apply" />
	
	<cfset var qResult = "" />
	
	<cfquery dbtype="query" name="qResult">
		select	*
		from	arguments.webskins
		where 	name like <cfqueryparam cfsqltype="cf_sql_varchar" value="#replace(arguments.filter,'*','%')#" />
	</cfquery>
	
	<cfreturn qResult />
</cffunction>

<cfloop list="#form.filters#" index="filter">
	<cfif not find(".",filter) or listfirst(filter,".") eq "*">
		<cfset types = structkeylist(application.stCOAPI) />
	<cfelse>
		<cfset types = listfirst(filter,".") />
	</cfif>
	
	<cfloop list="#types#" index="thistype">
		<cfset qWebskins = filterWebskins(application.stCOAPI[thistype].qWebskins,listlast(filter,".")) />
		<cfloop query="qWebskins">
			<cfoutput>#thistype#.#name#<br/></cfoutput>
		</cfloop>
	</cfloop>
</cfloop>

<cfsetting enablecfoutputonly="false" />