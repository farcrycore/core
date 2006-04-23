<!--- 

 FriendlyURL Management Component

 Created: Thu May 1  14:19:20 2003
 $Revision 0.2$
 Modified: $Date: 2005/10/21 07:20:38 $

 Author: Spike
 E-mail: spike@spike@spike.org.uk

 Description: The purpose of this component is to allow for simple management
 							of urls provided by the FriendlyURL servlet. This functionality 
							has been put into a component rather than the servlet itself so
							as to simplify integration into existing ColdFusion applications,
							to limit the security implications of having the management
							functionality in the servlet itself, and to help keep the servlet
							as lightweight as possible.
							
							Use the ColdFusion Component browser to view the methods provided
							by the component.
							
							It is not necessary to restart any part of ColdFusion after making
							changes to the mappings.
--->

<cfcomponent displayname="FriendlyURL" hint="FriendlyURLs manager">
	
	<cfset init()>
	
	<cffunction name="init" hint="Initializes the component.">
		<cfset instance = structNew()>	
		<!--- <cfset dataClass = createObject("java", "FriendlyURLData")>
      	<cfset dataObject = dataClass.getInstance()> --->
	</cffunction>

	<cffunction name="getErrorTemplate" access="public" returntype="string" hint="Returns the value currently used for the error template." output="No">
		<cfreturn dataObject.getErrorURL()>
	</cffunction>

	<!--- <cffunction name="setErrorTemplate" access="public" returntype="boolean" hint="Sets the value for the error template and writes the map file to disk." output="No">
		<cfargument name="errorTemplate" type="string" required="Yes">
		<cfset dataObject.setErrorURL(arguments.errorTemplate)>
		<cfreturn true>
	</cffunction> --->		
	
	<!--- <cffunction name="getURLVar" access="public" returntype="string" hint="Retrieves the name of the url variable that contains the friendly url." output="No">
		<cfreturn dataObject.getURLVar()>
	</cffunction> --->

	<!--- <cffunction name="setURLVar" access="public" returntype="boolean" hint="Sets the name for the url variable and writes the map file to disk" output="No">
		<cfargument name="URLVar" type="string" required="Yes">
		<cfset dataObject.setURLVar(arguments.URLVar)>
		<cfreturn true>
	</cffunction> --->
	
	<cffunction name="setMapping" access="public" returntype="boolean" hint="Sets the value for a mapping and writes the mapfile to disk. This can be a new or existing mapping." output="yes">
		<cfargument name="alias" required="yes" type="string">
		<cfargument name="mapping" required="yes" type="string">
		<cfargument name="querystring" required="no" type="string" default="">
		<cfargument name="bPermantLink" required="no" type="boolean" default="0" hint="used to set the FU to be either 1 or 2">
		
		<cfset var stLocal = StructNew()>
		<cfset stLocal.objectid = CreateUUID()>
		<cfset stLocal.friendlyURL = arguments.alias>
		<cfset stLocal.querystring = arguments.querystring>
		<cfif arguments.bPermantLink>
			<cfset stLocal.status = 2> <!--- permanent --->
		<cfelse>
			<cfset stLocal.status = 1> <!--- active --->
		</cfif>
		
		<!--- parse the mapping variables to get objectid etc --->
		<cfset stLocal.lMapping = ListLast(arguments.mapping,"?")>
		<cfset stLocal.refObjectID = ListLast(stLocal.lMapping,"=")>
		<cfset stLocal.friendlyURL_length = Len(stLocal.friendlyURL) - FindNoCase(application.config.fusettings.urlpattern,stLocal.friendlyURL) + 1>
		<cfset stLocal.friendlyURL = Right(stLocal.friendlyURL,stLocal.friendlyURL_length)>

		<!--- check if friendly url is currently active AND that no change has occured to the friendlyurl --->
		<cfquery name="qCheck" datasource="#application.dsn#">
		SELECT	objectid
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refObjectID = <cfqueryparam value="#stLocal.refObjectID#" cfsqltype="cf_sql_varchar">
				AND friendlyurl = <cfqueryparam value="#stLocal.friendlyURL#" cfsqltype="cf_sql_varchar">
				AND status = <cfqueryparam value="#stLocal.status#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif qCheck.recordCount EQ 0>
			<!--- get exitsing friendly ONLINE urls for the objectid --->
			<cfquery datasource="#application.dsn#" name="qCheckCurrent">
			SELECT	friendlyurl
			FROM	#application.dbowner#reffriendlyURL
			WHERE	refObjectID = <cfqueryparam value="#stLocal.refObjectID#" cfsqltype="cf_sql_varchar">
				AND status = <cfqueryparam value="#stLocal.status#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- remove from app scope --->
			<cfloop query="qCheckCurrent">
				<cfset StructDelete(application.FU.mappings,qCheckCurrent.friendlyurl)>
			</cfloop>

			<!--- retire the existing friendlyurl that is not a permanent redirect {ie status = 2} --->
			<cfquery datasource="#application.dsn#" name="qUpdate">
			UPDATE	#application.dbowner#reffriendlyURL
			SET		status = 0
			WHERE	refObjectID = <cfqueryparam value="#stLocal.refObjectID#" cfsqltype="cf_sql_varchar">
				AND status = <cfqueryparam value="#stLocal.status#" cfsqltype="cf_sql_integer">
			</cfquery>
<!--- 
			<cfquery datasource="#application.dsn#" name="qNoExisting">
			SELECT	objectid
			FROM	#application.dbowner#reffriendlyURL
			WHERE	friendlyurl = <cfqueryparam value="#stLocal.friendlyURL#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			<cfset stLocal.iCounter = 0>
			<cfloop condition="qNoExisting.recordcount NEQ 0">
				<cfset stLocal.iCounter = stLocal.iCounter + 1>
				<cfquery datasource="#application.dsn#" name="qNoExisting">
				SELECT	objectid
				FROM	#application.dbowner#reffriendlyURL
				WHERE	friendlyurl = <cfqueryparam value="#stLocal.friendlyURL#-#stLocal.iCounter#" cfsqltype="cf_sql_varchar">
				</cfquery>			
			</cfloop>

			<cfif stLocal.iCounter>
				<cfset stLocal.friendlyURL = "#stLocal.friendlyURL#-#stLocal.iCounter#">
			</cfif>
 --->
			<!--- create the new friendly url --->
			<cfquery datasource="#application.dsn#" name="qInsert">
			INSERT	INTO #application.dbowner#reffriendlyURL(
				objectid,
				refobjectid,
				friendlyurl,
				query_string,
				datetimelastupdated,
				status)
			VALUES	(
				<cfqueryparam value="#stLocal.objectID#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#stLocal.refObjectID#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#stLocal.friendlyURL#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#stLocal.querystring#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#CreateODBCDatetime(now())#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#stLocal.status#" cfsqltype="cf_sql_integer">)
			</cfquery>

			<!--- add to app scope --->
			<cfset application.FU.mappings[stLocal.friendlyURL] = StructNew()>
			<cfset application.FU.mappings[stLocal.friendlyURL].refobjectid = stLocal.refObjectID>
			<cfset application.FU.mappings[stLocal.friendlyURL].query_string = stLocal.querystring>
		</cfif>

		<cfreturn true>
	</cffunction>		
	
	<cffunction name="deleteMapping" access="public" returntype="boolean" hint="Deletes a mapping and writes the map file to disk" output="No">
		<cfargument name="alias" required="yes" type="string">
		
		<cfquery datasource="#application.dsn#" name="qDelete">
		DELETE	
		FROM	#application.dbowner#reffriendlyURL
		WHERE	friendlyURL = <cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfset StructDelete(application.FU.mappings,arguments.alias)>
		<!--- <cfset dataObject.removeMapping(arguments.alias)> --->
		<cfreturn true>
	</cffunction>
	
	<cffunction name="fGetFUData" access="public" returntype="struct" hint="Sets the name for the url variable and writes the map file to disk" output="yes">
		<cfargument name="friendlyURL" type="string" required="Yes">
		<cfset var stReturn = StructNew()>
		<cfset var stLocal = StructNew()>
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "">
		<cfset stReturn.refObject = "">
		<cfset stReturn.query_string = "">
		<cfset stReturn.redirectFUURL = "">

		<cfif Right(arguments.friendlyURL,1) EQ "/">
			<cfset stLocal.strFriendlyURL_WSlash = arguments.friendlyURL>
			<cfset stLocal.strFriendlyURL = arguments.friendlyURL & Left(arguments.friendlyURL,Len(arguments.friendlyURL)-1)>
		<cfelse>
			<cfset stLocal.strFriendlyURL_WSlash = arguments.friendlyURL & "/">
			<cfset stLocal.strFriendlyURL = arguments.friendlyURL>
		</cfif>
		
		<!--- check if the FU exists inthe applictaion scope [currently active] --->
		<cfif StructKeyExists(application.FU.mappings,stLocal.strFriendlyURL)>
			<cfset stReturn.refObjectID = application.FU.mappings[stLocal.strFriendlyURL].refObjectID>
			<cfset stReturn.query_string = application.FU.mappings[stLocal.strFriendlyURL].query_string>
		<cfelseif StructKeyExists(application.FU.mappings,stLocal.strFriendlyURL_WSlash)>
			<cfset stReturn.refObjectID = application.FU.mappings[stLocal.strFriendlyURL_WSlash].refObjectID>
			<cfset stReturn.query_string = application.FU.mappings[stLocal.strFriendlyURL_WSlash].query_string>
		<cfelse> <!--- check in database [retired] .: redirect --->
			<cfquery datasource="#application.dsn#" name="qGet">
			SELECT	refobjectid
			FROM	#application.dbowner#reffriendlyURL
			WHERE	friendlyURL = <cfqueryparam value="#arguments.friendlyURL#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif qGet.recordCount>
				<!--- get the new friendly url for the retired friendly url --->
				<cfquery datasource="#application.dsn#" name="qGetRedirectFU">
				SELECT	friendlyURL
				FROM	#application.dbowner#reffriendlyURL
				WHERE	refobjectid = <cfqueryparam value="#qGet.refobjectid#" cfsqltype="cf_sql_varchar">
						AND status = 1
				</cfquery>

				<cfif qGetRedirectFU.recordCount>
					<cfset stReturn.redirectFUURL = "http://" & cgi.server_name & qGetRedirectFU.friendlyURL>
				<cfelse>
					<cfset stReturn.bSuccess = 0>
					<cfset stReturn.message = "Sorry your requested page could not be found.">
				</cfif>
			<cfelse>
				<cfset stReturn.bSuccess = 0>
				<cfset stReturn.message = "Sorry your requested page could not be found.">
			</cfif>
		</cfif>

		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="getFUstruct" access="public" returntype="struct" hint="Returns a structure of all friendly URLs, keyed on object id." output="No">
		<cfargument name="domain" required="no" type="string" default="#cgi.server_name#">
		
		<cfset var stMappings = getmappings()>
		<cfset var stFU = structnew()>
		
		<cfloop collection="#stMappings#" item="i">
			<cfif findnocase(domain,i)>
				<cfset stFU[listgetat(stMappings[i],2,"=")] = "/" & listRest(i,'/')>
			</cfif>
		</cfloop>
		
		<cfreturn stFU>
	</cffunction>
	
	
	<!--- <cffunction name="getMappings" access="public" returntype="struct" hint="Retrieves all current mappings" output="No">
		<cfreturn dataObject.getMappings()>
	</cffunction> --->
	
	
	<!--- FarCry Specific Functions --->
	<cffunction name="deleteAll" access="public" returntype="boolean" hint="Deletes all mappings and writes the map file to disk" output="No">
		<!--- <cfset var mappings = getMappings()>
		<cfset var dom = "">
		<cfset var i = ""> --->
		<!--- loop over all entries and delete those that match domain --->
		
		<cfquery datasource="#application.dsn#" name="qDelete">
		DELETE	
		FROM	#application.dbowner#reffriendlyURL
		WHERE	status != 2
		</cfquery>
		
		<!--- loop over all domains --->
		<!--- <cfloop list="#application.config.fusettings.domains#" index="dom">
			<cfloop collection="#mappings#" item="i">
				<cfif reFind('^#dom##application.config.fusettings.urlpattern#',i)>
					<cfset deleteMapping(i)>
				</cfif>
			</cfloop>
		</cfloop> --->
		<!--- <cfset updateAppScope()> --->
		<!--- remove everything from app scope --->
		<cfset application.FU.mappings = StructNew()>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="deleteFU" access="public" returntype="boolean" hint="Deletes a mappings and writes the map file to disk" output="No">
		<cfargument name="alias" required="yes" type="string" hint="old alias of object to delete">
		
		<cfset var mappings = "">
		<cfset var dom = "">
		<cfset var sFUKey = "">
		
		<cfif NOT isDefined("application.FU.mappings")>
			<cfset application.FU.mappings = getMappings()>
		</cfif>
		<cfset mappings = structCopy(application.FU.mappings)>
		<!--- loop over all domains --->
		<cfloop list="#application.config.fusettings.domains#" index="dom">
			<cfset sFUKey = "#dom##arguments.alias#">
			<cfset aFuKey = structFindKey(mappings,sFUKey,"one")>
			<cfif arrayLen(aFuKey)>
				<cfset deleteMapping(sFUKey)>
			</cfif>
		</cfloop>
		<!--- <cfset updateAppScope()> --->
		<cfreturn true>
	</cffunction>
	
   <cffunction name="updateAppScope" access="public" hint="Updates the application scope with the FU mappings" output="yes">

		<cfset var stTemp = StructNew()>

		<!--- retrieve list of all FU that is not retired --->
		<cfquery name="qListFU" datasource="#application.dsn#">
		SELECT	friendlyurl, refobjectid, query_string
		FROM	#application.dbowner#reffriendlyURL
		WHERE	status > 0
		</cfquery>

		<cfset stTemp = QueryToStructOfStructures(qListFU, "friendlyurl")>
		<!--- load mappings to app scope --->
		<cfset application.FU.mappings = stTemp>
	</cffunction>


	<cffunction name="QueryToStructOfStructures" returntype="struct" hint="converts query to a struct">
		<cfargument name="theQuery" required="Yes" type="query">
		<cfargument name="primaryKey" required="Yes" type="string">
		
		<!--- 
		 * Converts a query object into a structure of structures accessible by its primary key.
		 * 
		 * @param theQuery 	 The query you want to convert to a structure of structures. 
		 * @param primaryKey 	 Query column to use as the primary key. 
		 * @return Returns a structure. 
		 * @author Shawn Seley (shawnse@aol.com) 
		 * @version 1, March 27, 2002 
		 --->
		 
		<cfset var theStructure  = structnew()>

		<!--- remove primary key from cols listing --->
		<cfset var cols = ListToArray(ListDeleteAt(arguments.theQuery.columnlist, ListFindNoCase(arguments.theQuery.columnlist, arguments.primaryKey)))>
		<cfset var row = 1>
		<cfset var thisRow = "">
		<cfset var col = 1>

		<cfscript>
		for(row = 1; row LTE arguments.theQuery.recordcount; row = row + 1){
			thisRow = structnew();
		  	for(col = 1; col LTE arraylen(cols); col = col + 1){
		    	thisRow[cols[col]] = arguments.theQuery[cols[col]][row];
		  	}
		  	theStructure[arguments.theQuery[arguments.primaryKey][row]] = duplicate(thisRow);
		}
		</cfscript>

		  <cfreturn theStructure>
	</cffunction>

   <cffunction name="createFUAlias" access="public" returntype="string" hint="Creates the FU Alias for a given objectid" output="yes">
		<cfargument name="objectid" required="Yes">
		<cfargument name="bIncludeSelf" required="no" default="1">
				
		<cfset var stLocal = StructNew()>
		<cfset stLocal.qListAncestors = request.factory.oTree.getAncestors(objectid=arguments.objectid,bIncludeSelf=arguments.bIncludeSelf)>
		<cfset stLocal.returnString = "">
		
		<!--- remove root & home --->
		<cfquery dbtype="query" name="stLocal.qListNav">
		SELECT 	objectID
		FROM 	stLocal.qListAncestors
		WHERE 	nLevel >= 2
		ORDER BY nLevel
		</cfquery>

		<cfset stLocal.lNavID = ValueList(stLocal.qListNav.objectid)>
		<cfset stLocal.lNavID = ListQualify(stLocal.lNavID,"'")>

		<cfif stLocal.lNavID NEQ "" AND arguments.objectid NEQ application.navid.home>
			<!--- optimisation: get all dmnavgiation data to avoid a getData() call --->
			<cfquery name="stLocal.qListNavAlias" datasource="#application.dsn#">
		    SELECT	objectid, label, fu 
		    FROM	#application.dbowner#dmNavigation
		    WHERE	objectid IN (#preserveSingleQuotes(stLocal.lNavID)#)
			</cfquery>
	
			<cfloop query="stLocal.qListNavAlias">
				<cfset stLocal.returnString = ListAppend(stLocal.returnString,trim(stLocal.qListNavAlias.label))>
<!--- 				
TODO: decide where FU's are built up using the dmNavigation FU attribute or dmNavigation label
				<!--- check if has FU if so use it --->
				<cfif trim(stLocal.qListNavAlias.fu) NEQ "">
					<cfset stLocal.returnString = ListAppend(stLocal.returnString,trim(stLocal.qListNavAlias.fu))>
				<cfelse> <!--- no FU so use label --->
					<cfset stLocal.returnString = ListAppend(stLocal.returnString,trim(stLocal.qListNavAlias.label))>
				</cfif>
 --->
			</cfloop>
		</cfif>

		<!--- change delimiter --->
		<cfset stLocal.returnString = listChangeDelims(stLocal.returnString,"/") />
		<!--- remove spaces --->
		<cfset stLocal.returnString = ReReplace(stLocal.returnString,' +','-',"all") />
		<cfif Right(stLocal.returnString,1) NEQ "/">
			<cfset stLocal.returnString = stLocal.returnString & "/">
		</cfif>

   		<cfreturn stLocal.returnString>
	</cffunction>	
	
	<cffunction name="createAndSetFUAlias" access="public" returntype="string" hint="Creates and sets an the FU mapping for a given dmNavigation object. Returns the generated friendly URL." output="No">
		<cfargument name="objectid" required="true" hint="The objectid of the dmNavigation node" />
		<cfset var breadCrumb = "">

		<cfif arguments.objectid eq application.navid.home>
			<cfset breadcrumb = application.config.fusettings.urlpattern />
		<cfelse>
			<cfset breadcrumb = createFUAlias(objectid=arguments.objectid) />
		</cfif>
	
		<cfif breadCrumb neq "">
			<cfset setFU(objectid=arguments.objectid,alias=breadcrumb) />
		</cfif>
		<cfreturn breadCrumb />
	</cffunction>
	
	<cffunction name="createAll" access="public" returntype="boolean" hint="Deletes old mappings and creates new entries for entire tree, and writes the map file to disk" output="No">
		
		<!--- get nav tree --->
		<cfset var qNav = request.factory.oTree.getDescendants(objectid=application.navid.home, depth=50)>
		<cfset var qAncestors = "">
		<cfset var qCrumb = "">
		<cfset var breadCrumb = "">
		<cfset var oNav = createObject("component",application.types.dmNavigation.typepath)>
		<cfset var i = 0>

		<!--- remove existing fu's --->
		<cfset deleteALL()>
		<!--- set error template --->		
		<!--- <cfset setErrorTemplate("#application.url.webroot#")> --->
		<!--- set nav variable --->
		<!--- <cfset setURLVar("nav")> --->
		<!--- loop over nav tree and create friendly urls --->
		<cfloop query="qNav">
			<cfset createAndSetFUAlias(objectid=qNav.objectid) />
		</cfloop>

		<!--- create fu for home--->
		<!--- <cfset createAndSetFUAlias(objectid=application.navid.home) /> --->

		<cfset updateAppScope() />
		<cfreturn true />
	</cffunction>
	
	<cffunction name="setFU" access="public" returntype="string" hint="Sets an fu" output="yes">
		<cfargument name="objectid" required="yes" type="UUID" hint="objectid of object to link to">
		<cfargument name="alias" required="yes" type="string" hint="alias of object to link to">
		<cfargument name="querystring" required="no" type="string" default="" hint="extra querystring parameters">
		<cfargument name="bPermantLink" required="no" type="boolean" default="0" hint="used to set the FU to be either 1 or 2">
		
		<cfset var dom = "">
		<!--- replace spaces in title --->
		<cfset var newAlias = replace(arguments.alias,' ','-',"all")>
		<!--- remove illegal characters in titles --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[,:\?##��]','',"all")>
		<!--- change & to "and" in title --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[&]','and',"all")>
		<!--- prepend fu url pattern and add suffix --->
		<cfset newAlias = application.config.fusettings.urlpattern & newAlias & application.config.fusettings.suffix>
		<cfset newAlias = ReplaceNocase(newAlias,"//","/","All")>
		<cfset newAlias = LCase(newAlias)>
		<cfset newAlias = ReReplaceNoCase(newAlias,"[^a-z0-9/]","-","all")>
		<cfset newAlias = ReReplaceNoCase(newAlias,"--","-","all")>
		
		<!--- loop over domains and set fu ---> 
		<!--- <cfloop list="#application.config.fusettings.domains#" index="dom"> --->
			<cfset setMapping(alias=newAlias,mapping="#application.url.conjurer#?objectid=#arguments.objectid#",querystring=arguments.querystring,bPermantLink=bPermantLink)>
		<!--- </cfloop> --->
		<!--- <cfset updateAppScope()> --->
	</cffunction>
	
	<cffunction name="getFU" access="public" returntype="string" hint="Retrieves fu for a real url, returns original ufu if non existent." output="yes">
		<cfargument name="objectid" required="yes" type="string" hint="objectid of object to link to">
		<cfargument name="dom" required="yes" type="string" default="#cgi.server_name#">
		<cfset var fuURL = "http://#dom##application.url.conjurer#?objectid=#arguments.objectid#">
		
		<cfif NOT isDefined("application.FU.mappings")>
			<cfset updateAppScope()>
		</cfif>
		
		<!--- get friendly url based on the objectid --->
		<cfquery datasource="#application.dsn#" name="qGet">
		SELECT	friendlyURL, refobjectid, query_string
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
			AND status != 0
		</cfquery>

		<cfif qGet.recordCount>
			<cfset fuURL = "http://#dom##qGet.friendlyURL#">
		</cfif>
		
		<cfreturn fuURL>
	</cffunction>
<!--- 
	<cffunction name="hasFU" access="public" returntype="boolean" hint="Returns whether an FU has been set for the given objectid" output="No">
	   <cfargument name="objectid" required="yes" hint="Objectid of object" />
	   <cfset var fu = getFU(objectid=arguments.objectid) />
	   <!--- if getFU() returned a string containing "objectid" then we should return false --->
	   <cfreturn not listContains(fu,"objectid") />
	</cffunction>
 --->

	<cffunction name="fListFriendlyURL" access="public" returntype="struct" hint="returns a query of FU for a particular objectid" output="No">
		<cfargument name="objectid" required="yes" hint="Objectid of object" />
		<cfargument name="status" required="no" default="current" hint="status of friendly you want, [all (0,1,2), current (1,2), active (1), permanent (2), archived (0)]" />
			   
		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">
		<cfset stLocal.friendly_status = "">

		<cfswitch expression="#arguments.status#">
			<cfcase value="current">
				<cfset stLocal.friendly_status = "1,2">
			</cfcase>
		
			<cfcase value="active">
				<cfset stLocal.friendly_status = "1">
			</cfcase>
		
			<cfcase value="permanent">
				<cfset stLocal.friendly_status = "2">
			</cfcase>
		
			<cfcase value="archived">
				<cfset stLocal.friendly_status = "0">
			</cfcase>
					
			<cfdefaultcase>
				<cfset stLocal.friendly_status = "0,1,2">
			</cfdefaultcase>
		</cfswitch>
		
		<cftry>
			<!--- get friendly url based on the objectid --->
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	objectid, friendlyURL, refobjectid, query_string, datetimelastupdated, status
			FROM	#application.dbowner#reffriendlyURL
			WHERE	refobjectid = <cfqueryparam value="#arguments.objectid#" cfsqltype="cf_sql_varchar">
				AND status IN (#stLocal.friendly_status#)
			ORDER BY status DESC
			</cfquery>

			<cfset stLocal.returnstruct.queryObject = stLocal.qList>

			<cfcatch>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "#cfcatch.message# - #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.returnstruct>
	</cffunction>
	
	<cffunction name="fInsert" access="public" returntype="struct" hint="returns a query of FU for a particular objectid" output="No">
		<cfargument name="stForm" required="yes" hint="friendly url struct" type="struct" />

		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cftry>
			<!--- check if that friendly url exists --->
			<cfset arguments.stForm.friendlyUrl = ReplaceNoCase(arguments.stForm.friendlyUrl,application.config.fusettings.urlpattern,"")>
			<cfset arguments.stForm.friendlyUrl = application.config.fusettings.urlpattern & arguments.stForm.friendlyUrl>

			<cfquery datasource="#application.dsn#" name="stLocal.qCheck">
			SELECT	objectid
			FROM	#application.dbowner#reffriendlyURL
			WHERE	lower(friendlyURL) = <cfqueryparam value="#LCase(arguments.stForm.friendlyurl)#" cfsqltype="cf_sql_varchar">
				AND status != 0
			</cfquery>
			
			<cfif stLocal.qCheck.recordcount EQ 0>
				<cfset arguments.stForm.objectID = CreateUUID()>
				<cfquery datasource="#application.dsn#" name="stLocal.qInsert">
				INSERT	INTO #application.dbowner#reffriendlyURL(
					objectid,
					refobjectid,
					friendlyurl,
					query_string,
					datetimelastupdated,
					status)
				VALUES	(
					<cfqueryparam value="#arguments.stForm.objectID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.stForm.refObjectID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.stForm.friendlyURL#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.stForm.querystring#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#CreateODBCDatetime(now())#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.stForm.status#" cfsqltype="cf_sql_integer">)				
				</cfquery>
			
				<!--- add to app scope --->
				<cfif arguments.stForm.status GT 0>
					<cfset application.FU.mappings[arguments.stForm.friendlyURL] = StructNew()>
					<cfset application.FU.mappings[arguments.stForm.friendlyURL].refobjectid = arguments.stForm.refObjectID>
					<cfset application.FU.mappings[arguments.stForm.friendlyURL].query_string = arguments.stForm.querystring>
				</cfif>
			<cfelse>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "Sorry the Friendly URL: #arguments.stForm.friendlyurl# is currently active.<br />">
			</cfif>

			<cfcatch>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "#cfcatch.message# - #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.returnstruct>
	</cffunction>
	
	<cffunction name="fDelete" access="public" returntype="struct" hint="returns a query of FU for a particular objectid" output="No">
		<cfargument name="stForm" required="yes" hint="friendly url struct" type="struct" />

		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cftry>
			<cfset arguments.stForm.lDeleteObjectid = ListQualify(arguments.stForm.lDeleteObjectid,"'")>
			<cfquery datasource="#application.dsn#" name="stLocal.qList">
			SELECT	friendlyurl
			FROM	#application.dbowner#reffriendlyURL
			WHERE	objectid IN (#preservesinglequotes(arguments.stForm.lDeleteObjectid)#)
			</cfquery>

			<cfquery datasource="#application.dsn#" name="stLocal.qDelete">
			DELETE
			FROM	#application.dbowner#reffriendlyURL
			WHERE	objectid IN (#preservesinglequotes(arguments.stForm.lDeleteObjectid)#)
			</cfquery>
			
			<cfloop query="stLocal.qList">
				<!--- delete from app scope --->
				<cfset StructDelete(application.FU.mappings,stLocal.qList.friendlyurl)>
			</cfloop>

			<cfcatch>
				<cfset stLocal.returnstruct.bSuccess = 0>
				<cfset stLocal.returnstruct.message = "#cfcatch.message# - #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<cfreturn stLocal.returnstruct>
	</cffunction>
</cfcomponent>