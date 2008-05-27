<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/verity.cfc,v 1.6.2.3 2006/04/26 21:23:24 geoff Exp $
$Author: geoff $
$Date: 2006/04/26 21:23:24 $
$Name: p300_b113 $
$Revision: 1.6.2.3 $

|| DESCRIPTION ||
$Description: verity search cfc $

$todo: have started refactoring this component to allow for veritycf7 to extend for 
CF7 functionality.  Stable but should be considered a WIP to try and achieve some 
semblance of current best practice GB 20060405 

Plus we have the crazy use of collection name with and without the application name 
prefix -- this needs to be standardised on one or the other.. probably best to be on 
the ACTUAL collection name according to CF. GB 20060405yet another cf is thread 
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent displayName="Verity Search" hint="CFC based around verity search engine">
	
	<cffunction name="init" access="public" output="false" returntype="verity" hint="Ini pseudo constructor.">
		<cfset variables.stconfig = application.factory.oconfig.getconfig("verity")>
		<cfreturn this />
	</cffunction>

	<cffunction name="buildCollection" output="no" hint="creates new verity collection" returntype="void" access="public">
		<cfargument name="collection" required="yes" hint="Name of collection to be created">
		<cfargument name="path" required="false" default="" hint="Name of collection to be created">
		<cfargument name="language" required="false" default="English" hint="Language of collection to be created">
		
		<!--- using application.path.veritystoragepath as path, backward compatability for config --->
		<cfif NOT len(arguments.path)>
			<cfif structkeyexists(application.path, "verityStoragePath")>
				<cfset arguments.path=application.path.verityStoragePath>
			<cfelse>
				<cfset arguments.path=application.config.general.verityStoragePath>
			</cfif>
		</cfif>
		<!--- create collection --->
		<cfcollection action="CREATE" collection="#arguments.collection#" path="#arguments.path#" language="#arguments.language#" />
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
		<cfargument name="collection" required="yes" hint="Name of collection to be optimised; including application name prefix.">

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
		<cfargument name="collection" required="yes" hint="Name of collection to be updated; minus the application name prefix.">

		<cfinclude template="_verity/verityUpdate.cfm">
	</cffunction>

<cffunction name="updateTypeCollection" access="public" hint="Update a Verity database collection based on a FarCry content type." output="false" returntype="struct">
	<cfargument name="collection" required="yes" hint="Name of type based collection to be updated; without application name prefix." type="string" />
	<cfargument name="lExcludeObjectID" required="false" hint="List of object IDs to be excluded from the collection." type="string" default="">
	<cfargument name="maxRows" required="false" hint="The maximum rows to update." type="numeric" default="99999999">
	<cfset var stResult = structNew()>
	<cfset var key = arguments.collection>
	<cfset var rpt1 = "">
	<cfset var rpt2 = "">
	<cfset var q = getCollectionData(typename=arguments.collection,maxrows=arguments.maxrows)>
	<cfset var builstatusid=createUUID()>
	<cfset var typename=arguments.collection />
	<cfset stresult.bsuccess="true">

	<!--- trace build status into app scope --->
	<cfset application.verity.buildstatus[builstatusid]=structnew() />
	<cfset application.verity.buildstatus[builstatusid].collectioname=application.applicationname & "_" & typename />
	<cfset application.verity.buildstatus[builstatusid].config=application.config.verity.contenttype[typename] />
	<cfset application.verity.buildstatus[builstatusid].collectiondata=q.recordcount />
	<cfset application.verity.buildstatus[builstatusid].aStatus=arrayNew(1) />
	<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Begin collection build") />

	<cfset subS=listToArray("#q.recordCount#, #key#")>
	<cfset arrayappend(subS, arrayToList(application.config.verity.contenttype[key].aprops))>
	
	<cfsavecontent variable="rpt1">
	<cfoutput>
		<span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString("updatingRecsFor",subS)#<br>
		<cfif structKeyExists(application.config.verity.contenttype[key], "custom3") AND  structKeyExists(application.config.verity.contenttype[key], "custom4")>
			<cfif len(application.config.verity.contenttype[key].custom3) OR len(application.config.verity.contenttype[key].custom4)>
			<span class="frameMenuBullet">&raquo;</span> Including Custom Fields (custom3: #application.config.verity.contenttype[key].custom3#, custom4:#application.config.verity.contenttype[key].custom4#)<br>
			</cfif>
		</cfif>
	</cfoutput>
	</cfsavecontent>
	
	<!--- update collection --->	
	<cfif q.recordcount>
		<!--- ensure CUSTOM fields have defaults --->
		<cfset setCustomFieldDefaults(key)>
		<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Begin collection update complete.") />
				

<cfindex 
			action="UPDATE" 
			query="q" 
			body="#arrayToList(application.config.verity.contenttype[key].aprops)#" 
			custom1="#key#" 
			custom2=""
			custom3="#application.config.verity.contenttype[key].custom3#"
			custom4="#application.config.verity.contenttype[key].custom4#"
			key="objectid" 
			title="label" 
			collection="#application.applicationname#_#key#">
			
		<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Collection update complete.") />
	</cfif>
	
	<!--- set builttodate on completion to last record --->
	<cfif q.recordcount>
		<cfset lastbuilttodate=q.datetimelastupdated[q.recordcount] />
		<cfset setBuiltToDate(typename, lastbuilttodate) />
	</cfif>	

	<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated") and structKeyExists(application.types[key].stProps, "status")>
		<!--- remove any objects that may have been sent back to draft or pending --->
		<cfquery datasource="#application.dsn#" name="q">
			SELECT objectid,DATETIMELASTUPDATED
			FROM #key#
			WHERE <!--- datetimelastupdated > #application.config.verity.contenttype[key].lastupdated# --->
				upper(status) IN ('DRAFT','PENDING')
			<cfif arguments.lExcludeObjectID NEQ "">
				OR objectid IN (#preserveSingleQuotes(lExcludeObjectID)#)
			</cfif>					
		</cfquery>
		
		<cfset subS=listToArray("#q.recordCount#, #key#")>
		<cfset arrayappend(subS, arrayToList(application.config.verity.contenttype[key].aprops))>

		<cfsavecontent variable="rpt2">
		<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rb.formatRBString("purgingDeadRecsFor",subS)#<p></cfoutput>
		</cfsavecontent>
		
		<!--- todo: verity bug.. passing blank collection to index kills thread and requires CF restart to recover --->
		<cfif q.recordcount>
			<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Remove draft/pending (#q.recordcount#).") />
			<!--- <cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid"> --->
			<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Remove draft/pending complete.") />
		</cfif>
	</cfif>
	
	<!--- final catchall to ensure any deleted items are also removed from archive --->
	<cfquery datasource="#application.dsn#" name="qDelete">
	SELECT DISTINCT archiveID AS objectid
	FROM         dmArchive
	WHERE     (archiveID NOT IN
                         (SELECT     objectid
                           FROM          refObjects))
	</cfquery>
	
	<cfif qDelete.recordcount>
		<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Remove deleted/archived (#qDelete.recordcount#).") />
		<!--- <cfindex 
			collection="#application.applicationname#_#key#" 
	    	action="delete"
			type="custom"
			query="qDelete"
	  			key="objectid"> --->
		<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Remove deleted/archived complete.") />
	</cfif>
	
	<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: All done.") />
	

	
	<!--- return reult --->
	<cfset stresult.report=rpt1 & rpt2 >
	<cfreturn stresult />
</cffunction>

<cffunction name="updateCustomCollection" access="public" hint="Update a custom Verity database based collection." output="false" returntype="struct">
	<cfthrow message="updateCustomCollection: method not implemented!">
</cffunction>

<cffunction name="updateFileCollection" access="public" hint="Update a Verity file based collection." output="false" returntype="struct">
	<cfargument name="collection" required="yes" hint="Name of type based collection to be updated; without application name prefix and having the _files suffix." type="string" />
	<cfargument name="filesbuilttodate" required="false" hint="Files built to date; restricts files to index from this date." type="date" />
	<cfset var stResult = structNew()>
	<cfset var typename = replacenocase(arguments.collection,"_files","") />
	<cfset var qCollectionData="" />
	<cfset var filelibrarypath=application.path.defaultfilepath />
	<cfset var filecollectionproperty=application.config.verity.contenttype[typename].filecollectionproperty />
	<cfset var custom3=application.config.verity.contenttype[typename].custom3 />
	<cfset var custom4=application.config.verity.contenttype[typename].custom4 />
	<cfset var title="">
	<cfset var builstatusid=createUUID()>
	<cfset var filecounter=1 />
	
	<!--- determine files built to date --->
	<cfif isDefined("arguments.filesbuilttodate")>
		<cfset qCollectionData=getCollectionData(typename, arguments.filesbuilttodate) />
	<cfelseif structkeyexists(application.config.verity.contenttype[typename], "filesbuilttodate") AND isDate(application.config.verity.contenttype[typename].filesbuilttodate)>
		<cfset qCollectionData=getCollectionData(typename, application.config.verity.contenttype[typename].filesbuilttodate) />
	<cfelse>
		<cfset qCollectionData=getCollectionData(typename) />
	</cfif>
	
	<cfif qCollectionData.recordcount eq 0>
		<cfset stresult.bsuccess=true />
		<cfset stresult.recordcount=0 />
		<cfreturn stresult />
	</cfif>
	
	<!--- trace build status into app scope --->
	<cfset application.verity.buildstatus[builstatusid]=structnew() />
	<cfset application.verity.buildstatus[builstatusid].collectioname=application.applicationname & "_" & typename & "_files" />
	<cfset application.verity.buildstatus[builstatusid].config=application.config.verity.contenttype[typename] />
	<cfset application.verity.buildstatus[builstatusid].collectiondata=qCollectionData.recordcount />
	<cfset application.verity.buildstatus[builstatusid].aStatus=arrayNew(1) />
	<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Begin collection build") />
	
	<!--- todo: requires title as indexed property to function! Should be able to select for title property in config --->

	<cfloop query="qCollectionData">
		<cfif NOT isDefined("qCollectionData.title")>
			<cfset title=qCollectionData.label />
		</cfif>
		<cfset filename=evaluate("qCollectionData.#filecollectionproperty#") />
		<!--- todo: implement lcategories --->
		<cfset custom3value=evaluate("qCollectionData.#custom3#") />
		<cfset custom4value=evaluate("qCollectionData.#custom4#") />
		
		<cfif len(trim(filename)) AND fileexists("#filelibrarypath##filename#")>
			<cftry>
				<cfindex
					action="update"
					collection="#application.applicationname#_#typename#_files"
					key="#filelibrarypath##filename#"
					type="file"
					title="#title#" 
					urlpath="#qCollectionData.objectID#" 
					custom1="#typename#" 
					custom2="" 
					custom3="#custom3value#"
					custom4="#custom4value#">

				<cfset filecounter=filecounter+1 />
				<cfcatch>
					<!--- log errors to verity.log --->
					<cflog application="true" file="verity" type="warning" 
						text="#typename#_files: Error indexing #filelibrarypath##filename#. #cfcatch.message#(dt: #dateformat(qCollectionData.datetimelastupdated)#)" />
				</cfcatch>
			</cftry>
		
		<!--- log missing files only --->
		<cfelseif len(trim(filename))>
			<cflog application="true" file="verity" type="warning" 
				text="#typename#_files: #filelibrarypath##filename# does not exist. (dt: #dateformat(qCollectionData.datetimelastupdated)#)" />
			<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: #filelibrarypath##filename# does not exist.") />
		</cfif>
		
	<!--- every 100 file indexes and optimise & update filesbuilttodate --->
	<cfif filecounter MOD 100 eq 0>
		<!--- update timestamp --->
		<cfset setFilesBuiltToDate(typename, qcollectiondata.datetimelastupdated) />
		
		<!--- optimise collection --->
		<cfset tickstart=gettickcount() />
		<cfset optimiseCollection(application.applicationname & "_" & typename) />
		<cfset tickend=gettickcount() />
		<!--- log progress of update --->
		<cflog application="true" file="verity" type="information" 
			text="#typename#_files: Interim optimise complete (#numberformat(tickend-tickstart)#ms); #qcollectiondata.currentrow# of #qcollectiondata.recordcount#. (btd: #dateformat(application.config.verity.contenttype[typename].filesbuilttodate)#)" />
		<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Interim optimise complete (#numberformat(tickend-tickstart)#ms); #qcollectiondata.currentrow# of #qcollectiondata.recordcount#.") />
	</cfif>
	<cfset lastbuilttodate=qcollectiondata.datetimelastupdated>
	</cfloop>
	
	<!--- set filesbuilttodate on completion to last record --->
	<cfset setFilesBuiltToDate(typename, lastbuilttodate) />
	<!--- optimise collection --->
	<!--- <cfset optimiseCollection(application.applicationname & "_" & typename) /> --->
	
	<cflog application="true" file="verity" type="information" 
		text="#typename#_files: Index completed (#qcollectiondata.recordcount#). (btd: #dateformat(application.config.verity.contenttype[typename].filesbuilttodate)#)" />
	<cfset arrayAppend(application.verity.buildstatus[builstatusid].aStatus, "#timeformat(now())#: Index completed (#filecounter-1# files) (btd: #dateformat(application.config.verity.contenttype[typename].filesbuilttodate)#).") />
	
	<cfreturn stResult />
</cffunction>

<cffunction name="getCollectionData" access="private" output="false" returntype="query" hint="Return query of type collection data for indexing.">
	<cfargument name="typename" required="true" hint="Content type name for the collection you are building." type="string" />
	<cfargument name="builttodate" required="false" hint="Date to which the collection has been previously built." type="date" />
	<cfargument name="lExcludeObjectID" required="false" hint="List of objectids to exclude from the collection." type="string" />
	<cfargument name="bBuildFromScratch" required="false" default="false" hint="Flag to override builttodate setting." type="boolean" />
	<cfargument name="maxRows" required="false" default="99999999" hint="Number of records to update." type="numeric" />
	<cfset var lSelectColumns=getSelectColumns(arguments.typename)>
	<cfset var qContent=queryNew(lSelectColumns) />
	
	<cfif NOT isDefined("arguments.builttodate") AND structKeyExists(application.config.verity.contenttype[arguments.typename], "builttodate") AND isDate(application.config.verity.contenttype[arguments.typename].builttodate)>
		<cfset arguments.builttodate=application.config.verity.contenttype[arguments.typename].builttodate />
	</cfif>
	
	<!--- todo: lExcludeObjectID not yet implemented --->
	<cfif isDefined("arguments.lExcludeObjectID")>
		<cfthrow message="lExcludeObjectID not yet implemented.">
	</cfif>
	
	<!--- <cfdump var="#arguments#"> --->

	<cfquery datasource="#application.dsn#" name="qContent" result="res">
		
		<cfif application.dbtype EQ "mssql">
			SELECT TOP #arguments.maxRows# #lSelectColumns#
		<cfelse>
			SELECT #lSelectColumns#
		</cfif>	
			
		FROM #arguments.typename#
		WHERE 1 = 1
		
		<cfif  isDefined("arguments.builttodate") AND NOT arguments.bBuildFromScratch>
			AND datetimelastupdated > #createODBCDate(arguments.builttodate)#
			AND datetimelastupdated < #createODBCDate(arguments.builttodate+365)#
		</cfif>
		
		<cfif structKeyExists(application.types[arguments.typename].stProps, "status")>
			AND upper(status) = 'APPROVED'
		</cfif>
		
		ORDER BY datetimelastupdated
		
		<cfif listcontainsNoCase("mysql,mysql5,postgresql", application.dbtype)>
			LIMIT #arguments.maxRows#
		</cfif>		
	</cfquery>



	<cfreturn qContent />

</cffunction>

<cffunction name="getSelectColumns" access="private" output="false" returntype="string">
	<cfargument name="typename" required="true" hint="Content type name for the collection you are building." type="string" />
	<cfset var aSelectColumns=arrayNew(1) />
	
	<cfset aSelectColumns=duplicate(application.config.verity.contenttype[arguments.typename].aprops) />
	<cfif NOT ArrayFindNoCase(aSelectColumns, "objectid")>
		<cfset arrayAppend(aSelectColumns, "objectid") />
	</cfif>
	<cfif NOT ArrayFindNoCase(aSelectColumns, "label")>
		<cfset arrayAppend(aSelectColumns, "label") />
	</cfif>
	<cfif NOT ArrayFindNoCase(aSelectColumns, "DATETIMELASTUPDATED")>
		<cfset arrayAppend(aSelectColumns, "DATETIMELASTUPDATED") />
	</cfif>
	
	<cfif structkeyexists(application.config.verity.contenttype[arguments.typename], "custom3") AND len(application.config.verity.contenttype[arguments.typename].custom3) AND NOT ArrayFindNoCase(aSelectColumns, application.config.verity.contenttype[arguments.typename].custom3)>
		<cfset arrayAppend(aSelectColumns,application.config.verity.contenttype[arguments.typename].custom3) />
	</cfif>
	<cfif structkeyexists(application.config.verity.contenttype[arguments.typename], "custom4") AND len(application.config.verity.contenttype[arguments.typename].custom4) AND NOT ArrayFindNoCase(aSelectColumns, application.config.verity.contenttype[arguments.typename].custom4)>
		<cfset arrayAppend(aSelectColumns,application.config.verity.contenttype[arguments.typename].custom4) />
	</cfif>
	<cfif structkeyexists(application.config.verity.contenttype[arguments.typename], "fileCollectionProperty") AND len(application.config.verity.contenttype[arguments.typename].fileCollectionProperty) AND NOT ArrayFindNoCase(aSelectColumns, application.config.verity.contenttype[arguments.typename].filecollectionproperty)>
		<cfset arrayAppend(aSelectColumns,application.config.verity.contenttype[arguments.typename].fileCollectionProperty) />
	</cfif>
	
	<cfreturn arraytolist(aSelectColumns) />
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

	<cffunction name="search" output="false" returnType="query" hint="Searches against collections, logs search, prepares results and returns." access="public">
		<cfargument name="lCollections" type="string" requried="yes" hint="List of collections to search against">
		<cfargument name="searchString" type="string" requried="yes" hint="User search string">
		<cfargument name="maxRows" type="numeric" requried="yes" default="250" hint="Maximum number of results to return.">

		<!--- create return query; should replicate CFMX 6.1 Verity query --->
		<cfset var qResults = queryNew("title,key,score,summary,custom1,custom2,custom3,custom4")>
		<cfset var qFirstResults = queryNew("title,key,score,summary,custom1,custom2,custom3,custom4")>
		
		<!--- perform search --->
		<cftry>
			<cfsearch collection="#arguments.lCollections#" criteria="#arguments.searchString#" name="qFirstResults" maxrows="#arguments.maxRows#">
			<!--- log search --->
			<cfif not isdefined("url.startRow")>
				<cfset application.factory.oStats.logSearch(searchString=arguments.searchString,lcollections=arguments.lCollections,results=qFirstResults.recordcount)>
			</cfif>
			
			<!--- loop over results and prepare for display --->
			<cfloop query="qFirstResults">
				<!--- add row to query --->
				<cfset queryAddRow(qResults, 1)>
				<cfif trim(qFirstResults.title) eq "">
					<cfset querySetCell(qResults, "title", "(no title available)")>
				<cfelse>
					<cfset querySetCell(qResults, "title", trim(qFirstResults.title))>	
				</cfif>
				<cfset querySetCell(qResults, "key", qFirstResults.key)>
				<cfset querySetCell(qResults, "score", "#NumberFormat(qFirstResults.score*100)#%")>
				<cfset querySetCell(qResults, "summary", "#textHighlight(htmleditformat(HTMLStripper(qFirstResults.summary)), arguments.searchString)#")>
				<cfset querySetCell(qResults, "custom1", qFirstResults.custom1)>
				<cfset querySetCell(qResults, "custom2", qFirstResults.custom2)>
				<cfif isDefined("qFirstResults.custom3")>
					<cfset querySetCell(qResults, "custom3", qFirstResults.custom3)>
				</cfif>
				<cfif isDefined("qFirstResults.custom4")>
					<cfset querySetCell(qResults, "custom4", qFirstResults.custom4)>
				</cfif>
			</cfloop>
			<cfcatch>
				<cftrace category="farcry.verity" type="warning" text="Verity result error; #cfcatch.message#">
			</cfcatch>
		</cftry>

		<cfreturn qResults>
	</cffunction>

	<cffunction name="deleteFromCollection" output="no" hint="deletes an object form a verity collection">
		<cfargument name="collection" required="yes" type="string" hint="Name of collection to be created">
		<cfargument name="objectid" required="yes" type="uuid" hint="Object to be removed from collection">

		<cfinclude template="_verity/deleteFromCollection.cfm">

	</cffunction>
	
<cffunction name="setLastupdated" access="public" hint="Update the timestamp for the verity config." output="false" returntype="void">
	<cfargument name="collection" required="yes" hint="Name of collection to be updated; minus the application name prefix." type="string" />
	<cfargument name="timestamp" hint="Timestamp; defaults to now()" default="#now()#" type="date">
	<!--- reset lastupdated timestamp --->
	<cfset application.config.verity.contenttype[replaceNoCase(arguments.collection,"#application.applicationName#_","")].lastUpdated = arguments.timestamp />
</cffunction>

<cffunction name="setBuiltToDate" access="public" hint="Update the timestamp for the verity config for builttodate." output="false" returntype="void">
	<cfargument name="typename" required="yes" hint="Name of type to be updated; minus the application name prefix." type="string" />
	<cfargument name="timestamp" required="true" hint="date time the collection has been builtto" type="date" />
	<!--- reset lastupdated timestamp --->
	<cfset application.config.verity.contenttype[typename].builttodate = arguments.timestamp />
	<!--- write the config back to the database --->
	<cfset stResult=createObject("component", "#application.packagepath#.farcry.config").setConfig("verity", application.config.verity)>
</cffunction>

<cffunction name="setFilesBuiltToDate" access="public" hint="Update the timestamp for the verity config for builttodate." output="false" returntype="void">
	<cfargument name="typename" required="yes" hint="Name of type to be updated; minus the application name prefix." type="string" />
	<cfargument name="timestamp" required="true" hint="date time the collection has been builtto" type="date" />
	<!--- reset lastupdated timestamp --->
	<cfset application.config.verity.contenttype[typename].filesbuilttodate = arguments.timestamp />
	<!--- write the config back to the database --->
	<cfset stResult=createObject("component", "#application.packagepath#.farcry.config").setConfig("verity", application.config.verity)>
</cffunction>

<cffunction name="setContentType" access="public" output="false" returntype="struct" hint="Update config details for a specific content type.">
	<cfargument name="typename" required="true" type="string" hint="Typename of the config you want to update." />
	<cfargument name="contenttype" required="true" type="struct" hint="Structure of properties for the config." />
	<cfset var stConfig = duplicate(application.config.verity) />
	<cfset var stResult = structNew() />
	
	<!--- update contenttype config --->
	<cfset stConfig.contenttype[arguments.typename] = arguments.contenttype />
	
	<!--- rebuild aIndices and aFileIndices --->
	<cfset stconfig.aIndices=arrayNew(1) />
	<cfset stconfig.aFileIndices=arrayNew(1) />
	<cfloop collection="#stconfig.contenttype#" item="collection">
		<cfset arrayAppend(stconfig.aIndices, "#application.applicationname#_#collection#") />
		<cfif structkeyExists(stconfig.contenttype[collection], "filecollectionproperty") AND len(stconfig.contenttype[collection].filecollectionproperty)>
			<cfset arrayAppend(stconfig.aFileIndices, "#application.applicationname#_#collection#_files") />
		</cfif>
	</cfloop>

	<!--- write the config back to the database --->
	<cfset stResult=createObject("component", "#application.packagepath#.farcry.config").setConfig("verity", stConfig) />
	<!--- update app scope cache --->
	<cfset application.config.verity=duplicate(stconfig) />
	<cfreturn stResult />
</cffunction>

<cffunction name="deleteContenttype" access="public" output="false" returntype="struct" hint="Removes the config entry for a specified content type.">
	<cfargument name="typename" required="true" hint="typename to be removed from config." />
	<cfset var stConfig = duplicate(application.config.verity) />
	<cfset var stResult = structNew() />
	
	<cfset structdelete(stconfig.contenttype, arguments.typename) />
	<!--- write the config back to the database --->
	<cfset stResult=createObject("component", "#application.packagepath#.farcry.config").setConfig("verity", stConfig) />
	<!--- update app scope cache --->
	<cfset application.config.verity=duplicate(stconfig) />
	<cfreturn stResult />
</cffunction>

<cffunction name="getConfig" access="public" output="false" returntype="struct" hint="Returns the complete verity config as a structure.">
	<cfreturn duplicate(application.config.verity) />
</cffunction>

<cffunction name="setCustomFieldDefaults" access="private" output="false" returntype="void" hint="Sets custom values for custom verity index fields.  Backward compatability only.">
	<cfargument name="typename" required="true" type="string" hint="Typename for collection config to update.">
	<!--- check for custom fields; default values for lcategories, custom3, custom4 --->
	<cfif NOT structkeyexists(application.config.verity.contenttype[arguments.typename], "lproperties")>
		<cfset application.config.verity.contenttype[arguments.typename].lproperties="false">
	</cfif>
	<cfif NOT structkeyexists(application.config.verity.contenttype[arguments.typename], "custom3")>
		<cfset application.config.verity.contenttype[arguments.typename].custom3="">
	</cfif>
	<cfif NOT structkeyexists(application.config.verity.contenttype[arguments.typename], "custom4")>
		<cfset application.config.verity.contenttype[arguments.typename].custom4="">
	</cfif>
</cffunction>

<cfscript>
/**
 * Like listFindNoCase(), but for arrays.
 * 
 * @param arrayToSearch 	 The array to search. (Required)
 * @param valueToFind 	 The value to look for. (Required)
 * @return Returns a number. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, September 6, 2002 
 */
function ArrayFindNoCase(arrayToSearch,valueToFind){
	//a variable for looping
	var ii = 0;
	//loop through the array, looking for the value
	for(ii = 1; ii LTE arrayLen(arrayToSearch); ii = ii + 1){
		//if this is the value, return the index
		if(NOT compareNoCase(arrayToSearch[ii],valueToFind))
			return ii;
	}
	//if we've gotten this far, it means the value was not found, so return 0
	return 0;
}
</cfscript>


</cfcomponent>	