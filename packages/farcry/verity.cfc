<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/verity.cfc,v 1.6 2005/09/08 15:56:45 tom Exp $
$Author: tom $
$Date: 2005/09/08 15:56:45 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION ||
$Description: verity search cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Verity Search" hint="CFC based around verity search engine">

	<cffunction name="buildCollection" output="no" hint="creates new verity collection">
		<cfargument name="collection" required="yes" hint="Name of collection to be created">
		<cfargument name="path" required="yes" default="#application.config.general.verityStoragePath#" hint="Name of collection to be created">
		<cfargument name="language" required="yes" default="English" hint="Language of collection to be created">

		<cfcollection action="CREATE" collection="#arguments.collection#" path="#arguments.path#" language="#arguments.language#">
	</cffunction>

	<cffunction name="deleteCollection" returnType="struct" output="no" hint="Deletes a verity collection">
		<cfargument name="collection" required="yes" hint="Name of collection to be deleted">

		<cfset var stMessage = structNew()>

		<cftry>
			<cfcollection action="delete" collection="#arguments.collection#">
			<!--- clear lastupdated, if it exists --->
			<cfset structDelete(application.config.verity.contenttype[replaceNoCase(arguments.collection,"#application.applicationName#_","")], "lastupdated")>
			<!--- clear aIndices detail --->
			<cfloop from="1" to="#arrayLen(application.config.verity.aIndices)#" index="i">
				<cfif application.config.verity.aIndices[i] eq arguments.collection>
					<cfset arrayDeleteAt(application.config.verity.aIndices,i)>
				</cfif>
			</cfloop>

			<cfset stMessage.bSuccess = 1>
			<cfset stMessage.message = "#arguments.collection# has been deleted">

			<cfcatch>
				<cfset stMessage.bSuccess = 0>
				<cfset stMessage.message = "There was an error trying to delete #arguments.collection#.">
			</cfcatch>
		</cftry>

		<cfreturn stMessage>
	</cffunction>

	<cffunction name="optimiseCollection" returnType="struct" output="no" hint="Optimises a verity collection">
		<cfargument name="collection" required="yes" hint="Name of collection to be optimised">

		<cfset var stMessage = structNew()>

		<cftry>
			<cfcollection action="optimize" collection="#arguments.collection#">
			<cfset stMessage.bSuccess = 1>
			<cfset stMessage.message = "#arguments.collection# has been optimised">

			<cfcatch>
				<cfset stMessage.bSuccess = 0>
				<cfset stMessage.message = "There was an error trying to optimise #arguments.collection#.">
			</cfcatch>
		</cftry>

		<cfreturn stMessage>
	</cffunction>

	<cffunction name="updateCollection" output="yes" hint="Updates a verity collection">
		<cfargument name="collection" required="yes" hint="Name of collection to be optimised">

		<cfinclude template="_verity/verityUpdate.cfm">
	</cffunction>

	<cffunction name="listCollections" output="no" returntype="query" hint="Lists active collections for farcry site">
		<cfset var qVerity="">
		<cfset var temp="">
		<cfset var qCollectionList = queryNew("name,lastUpdated")>

		<!--- get system Verity information --->
		<cfcollection action="LIST" name="qVerity">

		<!--- Loop over Verity Collections and act on collections prefixed with this site's name --->
		<cfloop query="qVerity">
			<cfif find(application.applicationName, qVerity.name) eq 1>
				<!--- Figure and add lastupdated time to returned query --->
				<cfif structKeyExists(application.config.verity.contenttype,"#replaceNoCase(qVerity.name,'#application.applicationName#_','')#") and structKeyExists(application.config.verity.contenttype[replaceNoCase(qVerity.name,"#application.applicationName#_","")],"lastUpdated")>
					<cfset lastUpdated = "#dateFormat(application.config.verity.contenttype[replaceNoCase(qVerity.name,"#application.applicationName#_","")].lastUpdated,"dd-mmm-yyyy")# #timeFormat(application.config.verity.contenttype[replaceNoCase(qVerity.name,"#application.applicationName#_","")].lastUpdated,"hh:mm")#">
				<cfelse>
					<cfset lastUpdated = "n/a">
				</cfif>
			
				<cfset temp = queryAddRow(qCollectionList, 1)>
				<cfset temp = querySetCell(qCollectionList, "name", qVerity.name)>
				<cfset temp = querySetCell(qCollectionList, "lastUpdated", lastUpdated)>
			</cfif>
		</cfloop>

		<cfreturn qCollectionList>
	</cffunction>

	<cffunction name="htmlStripper" output="no" returnType="string" hint="Strips any html tags from search results">
		<cfargument name="content" type="string" requried="yes" hint="Content that needs to have html stripped from it">

		<cfinclude template="_verity/htmlStripper.cfm">

		<cfreturn modsummary>
	</cffunction>

	<cffunction name="textHighlight" output="no" returnType="string" hint="Highlights search text in result">
		<cfargument name="content" type="string" requried="yes" hint="Content that needs to have html stripped from it">
		<cfargument name="word" type="string" requried="yes" hint="Content that needs to have html stripped from it">

		<cfinclude template="_verity/textHighlight.cfm">

		<cfreturn returnString>
	</cffunction>

	<cffunction name="search" output="no" returnType="query" hint="Searches against colletions, logs search, prepares results and returns.">
		<cfargument name="lCollections" type="string" requried="yes" hint="List of collections to search against">
		<cfargument name="searchString" type="string" requried="yes" hint="User search string">
		<cfargument name="maxRows" type="numeric" requried="yes" default="100" hint="Maximum number of results to return">

		<cfinclude template="_verity/search.cfm">

		<cfreturn qResults>
	</cffunction>

	<cffunction name="deleteFromCollection" output="no" hint="deletes an object form a verity collection">
		<cfargument name="collection" required="yes" type="string" hint="Name of collection to be created">
		<cfargument name="objectid" required="yes" type="uuid" hint="Object to be removed from collection">

		<cfinclude template="_verity/deleteFromCollection.cfm">

	</cffunction>
</cfcomponent>	