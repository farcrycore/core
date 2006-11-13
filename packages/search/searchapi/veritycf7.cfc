<cfcomponent name="veritycf7" extends="searchapi" hint="Verity CF7 Search Features">

<cffunction name="init" access="public" returntype="veritycf7" output="false" hint="Initialisation method.">
	<cfreturn this />
</cffunction>


<cffunction name="search" access="public" hint="Search indices and return recordset." output="false" returntype="struct">
	<cfargument name="criteria" required="true" type="string" hint="Search criteria." />
	<cfargument name="ltypenames" required="false" default="" type="string" hint="List of typenames names to search" />
	<cfargument name="lcollections" required="false" default="" type="string" hint="List of collection names to search" />
	<cfargument name="searchtype" required="false" default="internet" type="string" hint="Search algorythm." />
	<cfargument name="startrow" required="false" default="1" type="numeric" hint="Start row for result cursor" />
	<cfargument name="maxrows" required="false" default="1000" type="numeric" hint="Maximum number of results to return" />

	<cfset var stResult=structNew() />
	<cfset var stInfo=structNew() />
	<cfset var q=queryNew("blah") />
	<cfset var collection=arguments.lcollections />
		
	<cfif len(ltypenames)>
		<cfset collection=getCollectionFromTypes(ltypenames) />
	</cfif>
	
	<cfif NOT len(collection)>
		<cfthrow type="search.searchapi" message="Collection not specified." detail="Search() could not determine a valid list of collections to seach. ltypenames (#ltypenames#)" />
	</cfif>
	
	<cfsearch
		name="q"
		collection="#collection#"
		criteria="#arguments.criteria#"
		type="#arguments.searchtype#"
		startrow="#arguments.startrow#"
		maxrows="#arguments.maxrows#"
		status="stinfo" />
	
	<!--- add objectid to query for pagination code --->	
	<cfquery dbtype="query" name="q">
	SELECT *, [key] AS objectid
	FROM q
	</cfquery>
	
	<cfset stResult.recordset=q />
	<cfset stResult.stinfo=stinfo />

	<cfreturn stResult />
	
</cffunction>

<cffunction name="getIndicies" access="public" hint="Get a query of available search indices." output="false" returntype="query">
	<cfset var qResults=queryNew("blah") />
	
	<cfcollection action="list" name="qResults" />
	
	<cfquery dbtype="query" name="qResults">
	SELECT * FROM qResults
	WHERE name LIKE '#application.applicationname#%'
	</cfquery>
	
	<cfreturn qResults />
</cffunction>


<cffunction name="getCollectionFromTypes" access="private" hint="Returns a list of collection names from a given list of typenames." output="false" returntype="string">
	<cfargument name="ltypenames" required="true" type="string" />
	<cfset var lResults="" />
	<cfset var aResults=arrayNew(1) />
	<cfset var qCollections=getIndicies() />
	<cfset var qLookup=queryNew("name") />
	<cfset var i=0 />
	
	<cfloop list="#arguments.ltypenames#" index="i">
		<cfquery dbtype="query" name="qLookup">
		SELECT name FROM qCollections
		WHERE name LIKE '%#lcase(i)#%'
		</cfquery>
		
		<cfif qLookup.recordcount>
			<cfset arrayAppend(aResults, qlookup.name) />
		</cfif>
	</cfloop>

	<cfset lresults=arraytolist(aresults) />

	<cfreturn lResults />
</cffunction>

</cfcomponent>


