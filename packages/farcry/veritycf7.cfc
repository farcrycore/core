<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header$
$Author$
$Date$
$Name$
$Revision$

|| DESCRIPTION ||
$Description: 
verity search cfc extended to accommodate cf7 only features 
 - category indexes
 - category filtered searches

Known Issues:
 - can't chain collections with category filter so UNIONing results
 - updating objects individually as we can't generate query including categories easily
 - slow to index.. searching performance hindered by UNION step
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent displayName="Verity Search" hint="CFC based around verity search engine, with extensions for CF7" extends="verity">

	<cffunction name="buildCollection" output="no" hint="creates new verity collection" access="public" returntype="void">
		<cfargument name="collection" required="yes" hint="Name of collection to be created">
		<cfargument name="path" required="yes" default="#application.config.general.verityStoragePath#" hint="Name of collection to be created">
		<cfargument name="language" required="yes" default="English" hint="Language of collection to be created">
		<cfargument name="categories" required="false" default="true" hint="Add category filtering options to collection.">

		<cfcollection 
			action="CREATE" 
			collection="#arguments.collection#" 
			path="#arguments.path#" 
			categories="#arguments.categories#"
			language="#arguments.language#">

	</cffunction>

<cffunction name="updateTypeCollection" access="public" hint="Update a Verity database collection based on a FarCry content type." output="true" returntype="struct">
	<cfargument name="collection" required="yes" hint="Name of type based collection to be updated; without application name prefix." type="string" />
	<cfargument name="lExcludeObjectID" required="false" hint="List of object IDs to be excluded from the collection." type="string">
	<cfargument name="bUseCategories" required="false" default="true" hint="Update collection with category information." type="boolean">
	<cfset var stResult = structNew()>
	<cfset var key = arguments.collection>
	<cfset var rpt1 = "">
	<cfset var rpt2 = "">
	
	<!--- if not using category feature just run standard type update --->
	<cfif NOT arguments.bUseCategories>
		<cfset stResult=super.updateTypeCollection(argumentCollection=arguments) />
		<cfreturn stResult />
	</cfif>
	
	<cfset stresult.bsuccess="true">

<!--- 
CATEGORY UPDATE
Update for individual content types to capture categories 
--->

		<!--- build index from type table --->
		<cfquery datasource="#application.dsn#" name="q">
			SELECT objectid
			FROM #key#
			WHERE 1 = 1
			<cfif lExcludeObjectID NEQ "">
				AND objectid NOT IN (#preserveSingleQuotes(lExcludeObjectID)#)
			</cfif>
			<!--- <cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated")>
				AND datetimelastupdated > #application.config.verity.contenttype[key].lastupdated#
			</cfif> --->
			<cfif structKeyExists(application.types[key].stProps, "status")>
				AND upper(status) = 'APPROVED'
			</cfif>
		</cfquery>
		
		<cfset subS=listToArray("#q.recordCount#, #key#")>
		<cfset arrayappend(subS, arrayToList(application.config.verity.contenttype[key].aprops))>
		
		<cfsavecontent variable="rpt1">
		<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString("updatingRecsFor",subS)#<br></cfoutput>
		</cfsavecontent>
		
		<!--- update collection --->
		<cfif q.recordcount>
			<cfloop query="q">
				<cfset qObject=getObjectAsQuery(q.objectid,key)>
				<cftry>
				<cfindex action="UPDATE" query="qobject" body="#arrayToList(application.config.verity.contenttype[key].aprops)#" custom1="#key#" key="objectid" category="#qobject.lcategories#" title="label" collection="#application.applicationname#_#key#">
				<cfcatch><cfset rpt1 = rpt1 & "#qobject.objectid#: #qobject.label# (#cfcatch.message#)<br />"></cfcatch>
				</cftry>
			</cfloop>
		</cfif>	
		
		<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated") and structKeyExists(application.types[key].stProps, "status")>
			<!--- remove any objects that may have been sent back to draft or pending --->
			<cfquery datasource="#application.dsn#" name="q">
				SELECT objectid
				FROM #key#
				WHERE <!--- datetimelastupdated > #application.config.verity.contenttype[key].lastupdated# --->
					upper(status) IN ('DRAFT','PENDING')
				<cfif lExcludeObjectID NEQ "">
					OR objectid IN (#preserveSingleQuotes(lExcludeObjectID)#)
				</cfif>					
			</cfquery>
			
			<cfset subS=listToArray("#q.recordCount#, #key#")>
			<cfset arrayappend(subS, arrayToList(application.config.verity.contenttype[key].aprops))>

			<cfsavecontent variable="rpt2">
			<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString("purgingDeadRecsFor",subS)#<p></cfoutput>
			</cfsavecontent>
			
			<cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid">

		</cfif>
		
		<!--- final catchall to ensure any deleted items are also removed from archive --->
		<cfquery datasource="#application.dsn#" name="qDelete">
		SELECT DISTINCT archiveID AS objectid
		FROM         dmArchive
		WHERE     (archiveID NOT IN
                          (SELECT     objectid
                            FROM          refObjects))
		</cfquery>
		
		<cfindex 
			collection="#application.applicationname#_#key#" 
	    	action="delete"
			type="custom"
			query="qDelete"
   			key="objectid">
		
		<!--- return reult --->
		<cfset stresult.report=rpt1 & rpt2 >
		<cfreturn stresult />
</cffunction>

<cffunction name="getObjectAsQuery" access="private" hint="Return a content item and associated categories as a single query object." output="false" returntype="query">
	<cfargument name="objectid" type="uuid" required="true" hint="OBJECTID for content item to be retrieved.">
	<cfargument name="typename" type="string" required="true" hint="Typename for content item.">

	<cfset var qresult=querynew("blah")>
	<cfset var stObj=createObject("component", application.types[arguments.typename].typepath).getData(arguments.objectid)>
	<cfset stObj.lCategories=createobject("component", "#application.packagepath#.farcry.category").getCategories(objectid=arguments.objectID, bReturnCategoryIDs=true)>
	
	<!--- convert to query --->
	<cfif NOT structIsEmpty(stobj)>
		<cfset qResult = queryNew(structKeyList(stobj))>
		<cfset queryaddrow(qresult,1)>
		<cfloop collection="#stobj#" item="i">
			<cfset querysetcell(qResult,i,stobj[i])>		
		</cfloop>
	</cfif>
	<cfreturn qResult />
</cffunction>

	<cffunction name="searchCollection" output="true" returnType="struct" hint="Searches against collections, logs search, prepares results and returns." access="public">
		<cfargument name="lCollections" type="string" requried="yes" hint="List of collections to search against">
		<cfargument name="searchString" type="string" requried="yes" hint="User search string">
		<cfargument name="maxRows" type="numeric" requried="yes" default="250" hint="Maximum number of results to return.">
		<cfargument name="lCategories" type="string" requried="false" hint="List of categories to filter search against." default="">
		<cfargument name="suggestions" type="string" requried="false" default="never" hint="Suggestions attribute for CFSEARCH; defaults to never.">

		<!--- create return query; should replicate CFMX 6.1 Verity query --->
		<cfset var stResults = structNew()>
		<cfset var stinfo = structNew()>
		<cfset var qResults = queryNew("AUTHOR,CATEGORY,CATEGORYTREE,CONTEXT,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,KEY,RANK,RECORDSSEARCHED,SCORE,SIZE,SUMMARY,TITLE,TYPE,URL")>
		<cfset var qUnion = queryNew("AUTHOR,CATEGORY,CATEGORYTREE,CONTEXT,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,KEY,RANK,RECORDSSEARCHED,SCORE,SIZE,SUMMARY,TITLE,TYPE,URL")>

		<cfset stResults.qResults=qResults>
		<cfset stResults.status=stinfo>
				
		<!--- perform search --->
		<!--- 
		Multiple collections not supported for searching using categories. 
		 - must go through and UNION result sets 
		 - abandoning status for now
		--->
		<cfloop list="#arguments.lCollections#" index="i">
			<!--- reset results bucket --->
			<cfset qResults = queryNew("AUTHOR,CATEGORY,CATEGORYTREE,CONTEXT,CUSTOM1,CUSTOM2,CUSTOM3,CUSTOM4,KEY,RANK,RECORDSSEARCHED,SCORE,SIZE,SUMMARY,TITLE,TYPE,URL")>
			<cftry>
				<cfsearch 
					collection="#i#" 
					criteria="#arguments.searchString#" 
					name="qResults" 
					maxrows="#arguments.maxRows#"
					category="#arguments.lcategories#"
					status="stinfo"
					suggestions="#arguments.suggestions#">
	
				<!--- log search --->
				<cfif not isdefined("url.startRow")>
					<cfset application.factory.oStats.logSearch(searchString=arguments.searchString,lcollections=arguments.lCollections,results=qResults.recordcount)>
				</cfif>
				
				<cfcatch>
					<cftrace category="farcry.verity" type="warning" text="Verity result error; #cfcatch.message#">
				</cfcatch>
			</cftry>
	
			<cfif qresults.recordcount>
			<cfquery dbtype="query" name="qUnion">
				SELECT * FROM qResults
				<cfif qunion.recordcount>
				UNION
				SELECT * FROM qUnion
				ORDER BY score DESC
				</cfif>
			</cfquery>
			</cfif>
		</cfloop>
		
		<cfset stResults.qResults=qUnion>
		
		<cfreturn stResults>
	</cffunction>

</cfcomponent>	