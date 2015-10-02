<cfcomponent displayname="FarCry API" hint="The API for all things FarCry" output="false" 
	bDocument="true" scopelocation="application.fapi">
<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->

	<cffunction name="init" access="public" returntype="fapi" output="false" hint="FAPI Constructor" bDocument="false">
		<cfreturn this />
	</cffunction>
	
	<!--- COAPI //////////////////////////////////////////// --->
	
	<!--- @@description: 
		<p>The following snippet shows how to get the type of a related content item in a webskin:</p>
		
		@@examples:
		<code>
			<cfset othertype = application.fapi.findType(stObj.aObjectIDs[1]) />
		</code>
	 --->
	<cffunction name="findType" access="public" output="false" returntype="string" hint="Returns the typename for an objectID. Returns empty string if objectid is not found." bDocument="true">
		<cfargument name="objectid" required="true" />
		
		<cfreturn application.coapi.coapiUtilities.findType(argumentCollection=arguments) />
	</cffunction>
	
	<!--- @@description: 
		<p>Returns an instantiated content type that is not populated with any data.</p>
		
		@@examples:
		<p>Instantiate a dmFile component:</p>
		<code>
			<cfset oFile = application.fapi.getContentType("dmFile") />
		</code>
	 --->
	<cffunction name="getContentType" access="public" output="false" returntype="any" hint="Returns the an instantiated content type" bDocument="true">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="singleton" type="boolean" required="false" default="false" />
		
		<cfset var oResult = "" />
		<cfset var message	= '' />
		
		<cfif structKeyExists(application.stCoapi, arguments.typename) and (arguments.singleton or isdefined("request.inthread"))>
			<cfset oResult = application.stcoapi["#arguments.typename#"].oFactory />
		<cfelseif structKeyExists(application.stCoapi, arguments.typename)>
			<cfset oResult = createObject("component", application.stcoapi["#arguments.typename#"].packagePath) />
		<cfelse>
			<cfset message = getResource(key="FAPI.messages.contentTypeNotFound@text", default="The content type [{1}] is not available",locale="", substituteValues=array(arguments.typename)) />
			<cfthrow message="#message#" />
		</cfif>		
		
		<cfreturn oResult />
	</cffunction>
		
	<!--- @@description: 
		<p>Allows you to fetch a ContentObject.  This is functionally the same as
			doing: getContentType("mytype").getData(objectid); however, using this
			method allows you to get the ContentObject structure without having to
			know the type.
		</p>
		<p>
			There is some performace overhead when you get a ContentObject without
			knowing the type (requires more database lookups). So, if possible, it 
			is better to use getContentType("type").getData(objectid).
		</p>
		
		@@examples:
		<p>Retrieve the properties of the selected object after an objectadmin action:</p>
		<code>
			<cfset stObj = application.fapi.getContentObject(form.selectedobjectid,"thistype") />
		</code>
	 --->
	<cffunction name="getContentObject" access="public" output="false" returnType="struct" hint="Allows you to fetch a content object with only the objectID" bDocument="true">
		<cfargument name="objectid" type="UUID" required="true" hint="The objectid for which object is to be found" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
		
		<cfreturn application.coapi.coapiutilities.getContentObject(argumentCollection="#arguments#") />
	</cffunction>	
	
	<!--- @@description: 
		<p>Allows you to fetch a set of content types by specifying filters, status and order.</p>
		
		@@examples:
		<p>Retrive the objectids of all visible news, ordered by published date:</p>
		<code>
			<cfset qNews = application.fapi.getContentObjects(typename="dmNews",publishdate_lt=now(),expirydate_gt=now(),orderby="publishdate desc") />
		</code>
	 --->
	<cffunction name="getContentObjects" access="public" output="false" returntype="query" hint="Returns a query of objects matching the specified parameters">
		<cfargument name="typename" type="string" required="true" hint="The name of the content type" />
		<cfargument name="lProperties" type="string" required="false" default="objectid" hint="The properties to return" />
		<cfargument name="status" type="string" required="false" default="" hint="Filter by object status. Only used for content types that support it." />
		<!--- Optional filter arguments --->
		<cfargument name="orderBy" type="string" required="false" default="" hint="Order by clause" />
		<cfargument name="maxRows" type="numeric" required="false" default="-1" hint="Number of records to return" />
				
		<cfset var q = "" />
		<cfset var thisargument = "" />
		<cfset var propertytypemap = structnew() />
		<cfset var comparisonmap = structnew() />
		<cfset var thisproperty = "" />
		<cfset var thisfilter = "" />
		<cfset var i = 0 />
		<cfset var f = "" />
		<cfset var dsn_read = getContentTypeMetadata(arguments.typename, "dsn", application.dsn_read) />
		
		<!--- set requestmode here; allows getContentObjects() to run when request scope is blank eg. during init --->
		<cfif NOT len(arguments.status) AND structKeyExists(request, "mode") AND structKeyExists(request.mode, "lValidStatus")>
			<cfset arguments.status = request.mode.lValidStatus>
		</cfif>

		<cfset propertytypemap["string"] = "cf_sql_varchar" />
		<cfset propertytypemap["varchar"] = "cf_sql_varchar" />
		<cfset propertytypemap["longchar"] = "cf_sql_varchar" />
		<cfset propertytypemap["nstring"] = "cf_sql_varchar" />
		<cfset propertytypemap["uuid"] = "cf_sql_varchar" />
		<cfset propertytypemap["date"] = "cf_sql_timestamp" />
		<cfset propertytypemap["datetime"] = "cf_sql_timestamp" />
		<cfset propertytypemap["numeric"] = "cf_sql_numeric" />
		<cfset propertytypemap["integer"] = "cf_sql_numeric" />
		<cfset propertytypemap["boolean"] = "cf_sql_numeric" />
		<cfset propertytypemap["array"] = "cf_sql_varchar" />
		<cfset propertytypemap["category"] = "cf_sql_varchar" />
		
		<cfset comparisonmap["lt"] = "<" />
		<cfset comparisonmap["lte"] = "<=" />
		<cfset comparisonmap["gt"] = ">" />
		<cfset comparisonmap["gte"] = ">=" />
		
		
		<!--- Add argument based filters to filter array --->
		<cfparam name="arguments.aFilters" default="#arraynew(1)#" />
		<cfloop collection="#arguments#" item="thisargument">
			<cfif refindnocase("_(eq|neq|gt|gte|lt|lte|in|notin|like|isnull)$",thisargument)>
				<cfif listcontainsnocase("categories_in,categories_eq",thisargument) and not structkeyexists(application.stCOAPI[arguments.typename].stProps,"categories")>
					<!--- Convert generic category filters (categories_eq, categories_in) to specific filters --->
					<cfloop collection="#application.stCOAPI[arguments.typename].stProps#" item="thisproperty">
						<cfif application.stCOAPI[arguments.typename].stProps[thisproperty].metadata.fttype eq "category">
							<cfset arrayappend(arguments.aFilters,struct(
									property=thisproperty,
									filter=listlast(thisargument,'_'),
									value=arguments[thisargument])
							) />
							<cfbreak />
						</cfif>
					</cfloop>
				<cfelse>
					<cfset arrayappend(arguments.aFilters,struct(
							property=listdeleteat(thisargument,listlen(thisargument,'_'),'_'),
							filter=listlast(thisargument,'_'),
							value=arguments[thisargument])
					) />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- Get some extra info for the filters in the array --->
		<cfloop from="1" to="#arraylen(arguments.aFilters)#" index="i">
			<!--- The category formtool is treated differently to normal strings. All other ftTypes are ignored. --->
			<cfif application.stCOAPI[arguments.typename].stProps[arguments.aFilters[i].property].metadata.fttype eq "category">
				<cfset arguments.aFilters[i].type = "category" />
			<cfelse>
				<cfset arguments.aFilters[i].type = application.stCOAPI[arguments.typename].stProps[arguments.aFilters[i].property].metadata.type />
			</cfif>
			<cfset arguments.aFilters[i].property = application.stCOAPI[arguments.typename].stProps[arguments.aFilters[i].property].metadata.name />
			<cfset arguments.aFilters[i].sqltype = propertytypemap[arguments.aFilters[i].type] />
		</cfloop>


		<cfquery datasource="#dsn_read#" name="q" maxrows="#arguments.maxRows#">
			select		#preserveSingleQuotes(arguments.lProperties)#, '#arguments.typename#' as typename
			from		#application.dbowner##arguments.typename#
			where		1=1
						<cfif structkeyexists(application.stCOAPI[arguments.typename].stProps,"status")>
							AND status in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.status#" />)
						</cfif>
						<cfloop from="1" to="#arraylen(arguments.aFilters)#" index="i">
							<cfset f = arguments.aFilters[i] /><!--- Shortcut variable --->
							
							<!--- Property comparison --->
							AND
							<cfswitch expression="#f.filter#"><!--- Comparison (lt,lte,gt,gte are a special case handled later) --->
								<cfcase value="eq">
									<cfif f.type eq "array"><!--- Special case for join properties --->
										objectid in (
											select		parentid
											from		#application.dbowner##arguments.typename#_#f.property#
											where		data in (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
											group by	parentid
											having		count(parentid)=<cfqueryparam cfsqltype="cf_sql_integer" value="#listlen(f.value)#" />
										)
									<cfelseif f.type eq "category"><!--- Special case for category searches --->
										<cfif len(trim(f.value))><!--- Category filtering is permissive - empty = any --->
											objectid in (
												select		objectid
												from		#application.dbowner#refCategories
												where		categoryid in (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
												group by	objectid
												having		count(objectid)=<cfqueryparam cfsqltype="cf_sql_integer" value="#listlen(f.value)#" />
											)
										<cfelse>
											1=1
										</cfif>
									<cfelse>
										#f.property# = <cfqueryparam cfsqltype="#f.sqltype#" value="#f.value#" />
									</cfif>
								</cfcase>
								<cfcase value="neq">
									NOT #f.property# = <cfqueryparam cfsqltype="#f.sqltype#" value="#f.value#" />
								</cfcase>
								<cfcase value="in">
									<cfif f.type eq "array"><!--- Special case for join properties --->
										objectid in (
											select		parentid
											from		#application.dbowner##arguments.typename#_#f.property#
											where		data in (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
										)
									<cfelseif f.type eq "category"><!--- Special case for category searches --->
										<cfif len(trim(f.value))><!--- Category filtering is permissive - empty = any --->
											objectid in (
												select		objectid
												from		#application.dbowner#refCategories
												where		categoryid in (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
											)
										<cfelse>
											1=1
										</cfif>
									<cfelse>
										#f.property# IN (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
									</cfif>									
								</cfcase>
								<cfcase value="notin">
									NOT #f.property# IN (<cfqueryparam cfsqltype="#f.sqltype#" list="true" value="#f.value#" />)
								</cfcase>
								<cfcase value="like">
									#f.property# LIKE <cfqueryparam cfsqltype="#f.sqltype#" value="#f.value#" />
								</cfcase>
								<cfcase value="isnull">
									(
										<cfif f.value>
											#f.property# IS NULL
											<cfif f.sqltype eq "cf_sql_timestamp"><!--- Special case to handle the various null date formats --->
												OR #f.property# = <cfqueryparam cfsqltype="#f.sqltype#" value="1 January 2050" />
												OR #f.property# > <cfqueryparam cfsqltype="#f.sqltype#" value="#dateadd('yyyy',100,now())#" />
											</cfif>
										<cfelse>
											#f.property# IS NOT NULL
											<cfif propertytypemap[f.type] eq "cf_sql_timestamp"><!--- Special case to handle the various null date formats --->
												AND NOT #f.property# = <cfqueryparam cfsqltype="#f.sqltype#" value="1 January 2050" />
												AND #f.property# < <cfqueryparam cfsqltype="#f.sqltype#" value="#dateadd('yyyy',100,now())#" />
											</cfif>
										</cfif>
									)
								</cfcase>
								<cfcase value="lt,lte,gt,gte" delimiters=",">
									<cfif f.sqltype eq "cf_sql_timestamp"><!--- Special case to handle the various null date formats --->
										<!--- LTE and GT filters with a date but no time need to be increased by a day, to imitate a date comparison using a timestamp --->
										<cfif hour(f.value) eq 0 and minute(f.value) eq 0 and second(f.value) eq 0 and (f.filter eq "lte" or f.filter eq "gt")>
											<cfset f.value = dateadd("d",1,f.value) />
										</cfif>
										
										(
											#f.property# is null
											OR #f.property# = <cfqueryparam cfsqltype="#f.sqltype#" value="1 January 2050" />
											OR #f.property# > <cfqueryparam cfsqltype="#f.sqltype#" value="#dateadd('yyyy',100,now())#" />
											OR #f.property# #comparisonmap[f.filter]# <cfqueryparam cfsqltype="#f.sqltype#" value="#f.value#" />
										)
									<cfelse>
										#f.property# #comparisonmap[f.filter]# <cfqueryparam cfsqltype="#f.sqltype#" value="#f.value#" />
									</cfif>
								</cfcase>
							</cfswitch>
						</cfloop>
			<cfif len(arguments.orderBy)>
				ORDER BY #preserveSingleQuotes(arguments.orderBy)#
			</cfif>
		</cfquery>
		
		<cfreturn q />
	</cffunction>
	
	<!--- @@description: 
		<p>Returns true if the object has not yet been stored in the database</p>
		<p>If you know what the type is, pass it in to avoid an unnecessary database calls.</p>
		
		@@examples:
		<p>Returns true if the object has not yet been stored in the database:</p>
		<code>
			<cfset bDefaultObject = application.fapi.isDefaultObject(form.selectedobjectid,"thistype") />
		</code>
		
	 --->
	<cffunction name="isDefaultObject" access="public" output="false" returnType="boolean" hint="Returns true if the object has not yet been stored in the database" bDocument="true">
		<cfargument name="objectid" type="UUID" required="true" hint="The objectid for which object is to be found" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
		
		<cfset var stTemp = getContentObject(argumentCollection="#arguments#") />
		<cfset var bDefaultObject = false />
		
		<cfif structKeyExists(stTemp, "bDefaultObject") AND isBoolean(stTemp.bDefaultObject)>
			<cfset bDefaultObject = stTemp.bDefaultObject />
		</cfif>
		
		<cfreturn bDefaultObject />
	</cffunction>
				
	<!--- @@description: 
		<p>
			Retrieve the properties of the selected object after an objectadmin action.
		</p>
		
		@@examples:
		<code>
			<cfif application.fapi.hasWebskin("dmHTML", "displayPage1Col")>
				<skin:view typename="dmHTML" objectid="#q.objectid#" webskin="displayPage1Col" />
			</cfif>
		</code>
	 --->
	<cffunction name="hasWebskin" access="public" output="false" returnType="boolean" hint="Returns true if the content type has the webskin name passed in available." bDocument="true">
		<cfargument name="typename" type="string" required="true" hint="The typename of the webskin to be found." />
		<cfargument name="webskin" required="true" />
		
		<cfset var bHasWebskin = false />
		
		<cfif len(arguments.typename) 
				AND len(arguments.webskin) 
				AND isDefined("application.stcoapi.#arguments.typename#.stWebskins") 
				AND structKeyExists(application.stcoapi[arguments.typename].stWebskins, arguments.webskin)>
			<cfset bHasWebskin = true />
		</cfif>			
		
		<cfreturn bHasWebskin />
	</cffunction>
		
	<!--- @@examples:
		<p>Retrieve a new content object:</p>
		<code>
			<cfset stObj = application.fapi.getNewContentObject("thistype","key") />
		</code>
		<p>If you want to make sure you keep retrieving the same new object each time until you end up saving to the database, pass in a key.</p>
	 --->
	<cffunction name="getNewContentObject" access="public" output="false" returnType="struct" hint="Allows you to fetch a content object with only the objectID" bDocument="true">
		<cfargument name="typename" type="string" required="true" hint="The typename of the new object to be created." />
		<cfargument name="key" type="string" required="false" default="" hint="The key for the new object. Subsequent calls for a new object of the same type will return the same object until it is saved to the database." />
		<cfargument name="stProperties" required="false" default="#structNew()#" hint="A structure containing default values for the new object.">
		
		<cfset var lReserved = "typename,key,stProperties" />
		<cfset var i = "" />
		<cfset var newObjectID = "" />
		<cfset var stNewObject = "" />
		<cfset var stResult = "" />
		<cfset var o = application.fapi.getContentType("#arguments.typename#") />

		<cfparam name="session.stTempObjectStoreKeys" default="#structNew()#" />
		<cfparam name="session.stTempObjectStoreKeys[arguments.typename]" default="#structNew()#" />
		
		
		<cfloop collection="#arguments#" item="i">
			<cfif NOT listFindNoCase(lReserved, i)>
				<cfset arguments.stProperties[i] = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfif len(arguments.key)>
			<cfif structKeyExists(session.stTempObjectStoreKeys[arguments.typename], arguments.key)>
				<cfif structKeyExists(Session.TempObjectStore, session.stTempObjectStoreKeys[arguments.typename][arguments.key])>
					<cfset newObjectID = session.stTempObjectStoreKeys[arguments.typename][arguments.key] />
				</cfif>
			</cfif>	
			
			<cfif not len(newObjectID)>				
				<cfset newObjectID = application.fc.utils.createJavaUUID() />
				<cfset session.stTempObjectStoreKeys[arguments.typename][arguments.key] = newObjectID>
			</cfif>	
			
			<cfset stNewObject = o.getData(objectID = newObjectID) />
			
			<!--- Save it to the session --->
			<cfset stResult = o.setData(stProperties=stNewObject, bSessionOnly="true") />	
			
		<cfelse>
			<cfset stNewObject = o.getData(objectID=application.fc.utils.createJavaUUID()) />	
		</cfif>
			
			
		<cfif not structIsEmpty(arguments.stProperties)>
			<cfset stNewObject = structMerge(stNewObject,arguments.stProperties,true) />			
			<!--- Save it to the session --->
			<cfset stResult = o.setData(stProperties=stNewObject, bSessionOnly="true") />		
		</cfif>
		
		<cfreturn stNewObject />
	</cffunction>
		
	<!--- @@examples:
	<p>Register a CSS library into the application:</p>
	<code>
		<cfset application.fapi.registerCSS(	id="jquery-ui",
												baseHREF="#application.url.webtop#/thirdparty/jquery/css/base",
												lFiles="ui.core.css,ui.resizable.css,ui.accordion.css,ui.dialog.css,ui.slider.css,ui.tabs.css,ui.datepicker.css,ui.progressbar.css,ui.theme.css") />
	</code>
	 --->	
	<cffunction name="registerCSS" returntype="struct" hint="Adds CSS files to the farcry css library to be used by your application.">
		<cfargument name="id" required="true" />
		<cfargument name="lCombineIDs" default="" />
		<cfargument name="baseHREF" default="" />
		<cfargument name="lFiles" default="" />
		<cfargument name="media" default="all" />
		<cfargument name="condition" default="" hint="Used to wrap a conditional statement around the link tag." />
		<cfargument name="prepend" default="" hint="Any CSS code you wish to have placed before the library." />
		<cfargument name="append" default="" hint="Any CSS code you wish to have placed after the library." />
		<cfargument name="bCombine" default="true" hint="Should the files be combined into a single cached js file.">
		
		<cfset var thisid = "" />
		
		<cfparam name="application.fc.stCSSLibraries" default="#structNew()#" />
		
		<!--- Normalise files --->
		<cfset arguments.lFullFilebaseHREFs = "" />
		<cfif len(arguments.lFiles)>
			<cfset arguments.lFullFilebaseHREFs = application.fc.utils.normaliseFileList(arguments.baseHREF,arguments.lFiles) />
		</cfif>
		
		<cfset application.fc.stCSSLibraries[arguments.id] = duplicate(arguments) />
		
		<cfreturn success("CSS library added") />
	</cffunction>		
	
	<!--- @@examples:
	<p>Register a JS library into the application:</p>
	<code>
		<cfset application.fapi.registerJS(	id="jquery",
											baseHREF="#application.url.webtop#/thirdparty/jquery/js",
											lFiles="jquery-1.3.2.min.js,ui.core.js,ui.accordion.js,ui.datepicker.js,ui.dialog.js,ui.draggable.js,ui.droppable.js,ui.progressbar.js,ui.resizable.js,ui.selectable.js,ui.slider.js,ui.sortable.js,ui.tabs.js,effects.core.js,effects.blind.js,effects.bounce.js,effects.clip.js,effects.drop.js,effects.explode.js,effects.fold.js,effects.highlight.js,effects.pulsate.js,effects.scale.js,effects.shake.js,effects.slide.js,effects.transfer.js") />
	</code>
	 --->	
	<cffunction name="registerJS" returntype="struct" hint="Adds JS files to the farcry js library to be used by your application.">
		<cfargument name="id" required="true" />
		<cfargument name="lCombineIDs" default="" />
		<cfargument name="baseHREF" default="" />
		<cfargument name="lFiles" default="" />
		<cfargument name="condition" default="" hint="Used to wrap a conditional statement around the script tag." />
		<cfargument name="prepend" default="" hint="Any JS code you wish to have placed before the library." />
		<cfargument name="append" default="" hint="Any JS code you wish to have placed after the library." />
		<cfargument name="bCombine" default="true" hint="Should the files be combined into a single cached js file.">
		<cfargument name="aliasof" default="" hint="Flags this library as an alias of an existing one. The original library must already have been registered.">
		<cfargument name="core" default="false" hint="Flags this library as being a core library. This library should only be directly referenced by core.">
		
		<cfparam name="application.fc.stJSLibraries" default="#structNew()#" />
		
		<!--- Normalise files --->
		<cfset arguments.lFullFilebaseHREFs = "" />
		<cfif len(arguments.lFiles)>
			<cfset arguments.lFullFilebaseHREFs = application.fc.utils.normaliseFileList(arguments.baseHREF,arguments.lFiles) />
		</cfif>
		
		<cfset application.fc.stJSLibraries[arguments.id] = duplicate(arguments) />
		
		<cfreturn success("JS library added") />
	</cffunction>		
	
	<!--- @@examples:
		<p>Instantiate a list formtool component:</p>
		<code>
			<cfset oList = application.fapi.getFormtool("list") />
		</code>
	 --->
	<cffunction name="getFormtool" access="public" output="false" returntype="any" hint="Returns the an instantiated formtool" bDocument="true">
		<cfargument name="formtool" type="string" required="true" />
		
		<cfset var oResult = "" />
		
		<cfif structKeyExists(application.formtools, arguments.formtool)>
			<cfset oResult = createObject("component", application.formtools["#arguments.formtool#"].packagePath).init() />
		<cfelse>
			<!--- USE THE DEFAULT IF REQUESTED FORMTOOL DOES NOT EXIST --->
			<cfset oResult = createObject("component", application.formtools["field"].packagePath).init() />
		</cfif>		

		<cfreturn oResult />
	</cffunction>
				
	<!--- @@examples:
		<p>Save changes to an object:</p>
		<code>
			<cfset application.fapi.setData(stProperties=stObj) />
		</code>
	 --->
	<cffunction name="setData" access="public" output="false" returnType="struct" hint="Allows you to run setData() on a type for an objectID" bDocument="true">
		<cfargument name="objectid" type="string" required="false" default="" hint="The objectid for which object is to be set" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />

		<cfargument name="stProperties" required="false" default="#structNew()#">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		<cfargument name="bSessionOnly" type="string" required="false" default="false">
		<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		
		<cfset var o = "" />
		<cfset var lReserved = "objectid,typename,stProperties,dsn,dbtype,dbowner,auditNote,bAudit,bSessionOnly,bAfterSave" />
		<cfset var i	= '' />
	
		<cfif not structKeyExists(arguments.stProperties, "objectid")>
			<cfset arguments.stProperties.objectid = arguments.objectid />
		</cfif>
		<cfif not structKeyExists(arguments.stProperties, "typename")>
			<cfset arguments.stProperties.typename = arguments.typename />
		</cfif>
		
		<cfloop collection="#arguments#" item="i">
			<cfif NOT listFindNoCase(lReserved, i)>
				<cfset arguments.stProperties[i] = arguments[i] />
			</cfif>
		</cfloop>

		<cfif not len(arguments.stProperties.typename)>
			<cfset arguments.stProperties.typename = findType(objectid="#arguments.stProperties.objectid#") />
		</cfif>		
		
		<cfset o = getContentType(arguments.stProperties.typename) />
		
		<cfreturn o.setData(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="setAncestorsCacheByVars" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheByVar's to the webskin that called it and its ancestors.">
		<cfargument name="keys" required="true" hint="This is a list of setCacheVar names to be dynamically assigned." />
		
		<cfset var i = "" />
		<cfset var currentTypename = "" />
		<cfset var currentTemplate = "" />
		<cfset var currentCacheStatus = "" />
		<cfset var currentVars = "" />
		<cfset var iKey = "" />
	
		<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">

				<cfset currentTypename = request.aAncestorWebskins[i].typename />
				<cfset currentTemplate = request.aAncestorWebskins[i].template />
				<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
				
				<cfif currentCacheStatus EQ 1>
						
					<cfparam name="application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByVars" default="" />
								
					<cfset currentVars = application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByVars />
					
					<cfloop list="#arguments.keys#" index="iKey">	
						<cfif not listFindNoCase(request.aAncestorWebskins[i].cacheByVars,iKey)>
							<cfset request.aAncestorWebskins[i].cacheByVars = listAppend(request.aAncestorWebskins[i].cacheByVars, iKey) />
						</cfif>	
						
						<cfif not listFindNoCase(currentVars, iKey)>
							<cfset currentVars = listAppend(currentVars, iKey) />
						</cfif>
					</cfloop>
			
					<cfset application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByVars = currentVars />
					
				</cfif>	

			</cfloop>
		</cfif>
	</cffunction>
		
	<cffunction name="setAncestorsCacheFlushOnFormPost" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheFlushOnFormPost to the webskin that called it and its ancestors.">
		
		<cfset var i = "" />
		<cfset var currentTypename = "" />
		<cfset var currentTemplate = "" />
		<cfset var currentCacheStatus = "" />
		<cfset var currentVars = "" />
		<cfset var iKey = "" />
	
		<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">

				<cfset currentTypename = request.aAncestorWebskins[i].typename />
				<cfset currentTemplate = request.aAncestorWebskins[i].template />
				<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
				
				<cfif currentCacheStatus EQ 1>
					<cfset request.aAncestorWebskins[i].cacheFlushOnFormPost = true />
					<cfset application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheFlushOnFormPost = true />
				</cfif>	

			</cfloop>
		</cfif>
	</cffunction>
		
	<cffunction name="setAncestorsCacheByForm" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheByForm to the webskin that called it and its ancestors.">
		
		<cfset var i = "" />
		<cfset var currentTypename = "" />
		<cfset var currentTemplate = "" />
		<cfset var currentCacheStatus = "" />
		<cfset var currentVars = "" />
		<cfset var iKey = "" />
	
		<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">

				<cfset currentTypename = request.aAncestorWebskins[i].typename />
				<cfset currentTemplate = request.aAncestorWebskins[i].template />
				<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
				
				<cfif currentCacheStatus EQ 1>
					<cfset request.aAncestorWebskins[i].cacheByForm = true />
					<cfset application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByForm = true />
				</cfif>	

			</cfloop>
		</cfif>
	</cffunction>
		
	<cffunction name="setAncestorsCacheByURL" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheByURL to the webskin that called it and its ancestors.">
		
		<cfset var i = "" />
		<cfset var currentTypename = "" />
		<cfset var currentTemplate = "" />
		<cfset var currentCacheStatus = "" />
		<cfset var currentVars = "" />
		<cfset var iKey = "" />
	
		<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">

				<cfset currentTypename = request.aAncestorWebskins[i].typename />
				<cfset currentTemplate = request.aAncestorWebskins[i].template />
				<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
				
				<cfif currentCacheStatus EQ 1>
					<cfset request.aAncestorWebskins[i].cacheByURL = true />
					<cfset application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByURL = true />
				</cfif>	

			</cfloop>
		</cfif>
	</cffunction>
			
	
	<cffunction name="setAncestorsCacheByRoles" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheByRoles to the webskin that called it and its ancestors.">
		
		<cfset var i = "" />
		<cfset var currentTypename = "" />
		<cfset var currentTemplate = "" />
		<cfset var currentCacheStatus = "" />
		<cfset var currentVars = "" />
		<cfset var iKey = "" />
	
		<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
		<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">

				<cfset currentTypename = request.aAncestorWebskins[i].typename />
				<cfset currentTemplate = request.aAncestorWebskins[i].template />
				<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
				
				<cfif currentCacheStatus EQ 1>
					<cfset request.aAncestorWebskins[i].cacheByRoles = true />
					<cfset application.stcoapi['#currentTypename#'].stWebskins['#currentTemplate#'].cacheByRoles = true />
				</cfif>	

			</cfloop>
		</cfif>
	</cffunction>
		
	<cffunction name="getWebskinCacheStatus" returntype="string" access="public" output="false" hint="Returns the objectbroker cache status of a webskin. Status can be -1:force ancestors to not cache, 0:do not cache, 1:cache">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="defaultStatus" type="numeric" default="0" required="false" />
		
		<cfreturn application.coapi.coapiadmin.getWebskinCacheStatus(argumentCollection="#arguments#") />
	</cffunction>
		
	
	<!--- @@examples:
		<p>Returns the display name defined in the webskin:</p>
		<code>
			<cfset application.fapi.getWebskinDisplayName('dmNews', 'displayTeaserStandard') />
		</code>
	 --->
	<cffunction name="getWebskinDisplayName" returntype="string" access="public" output="false" hint="Returns the displayname of a webskin.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		
		<cfreturn application.coapi.coapiadmin.getWebskinDisplayName(argumentCollection="#arguments#") />
	</cffunction>
		
	<!--- @@examples:
		<p>Clear the object and it's webskins from the cache:</p>
		<code>
			<cfset application.fapi.removeFromObjectBroker(stObj.objectid) />
		</code>
	 --->
	<cffunction name="removeFromObjectBroker" access="public" output="false" returntype="struct" hint="Removes a list of objectids with their webskins from the object broker" bDocument="true">
		<cfargument name="lObjectIDs" required="true" type="string">
		<cfargument name="typename" required="true" type="string" default="">
		
		<cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(argumentCollection="#arguments#") />
		
		<cfreturn success("objectids successfully removed from objectbroker") />
	</cffunction>
	
		
	<cffunction name="getContentTypeMetadata" access="public" output="false" returntype="any" hint="Returns the value of the metadata for a typename passed in. Omitting the md name, all metadata for the property will be returned.">
		<cfargument name="typename" required="true" type="string" hint="The typename for which we want metadata for" />
		<cfargument name="md" required="false" type="string" default="" hint="The name of the piece of metadata we want (optional)" />
		<cfargument name="default" required="false" default="" type="string" hint="The default value if the metadata does not exist" />
		
		<cfset var result = arguments.default />
		
		<cfif structKeyExists(application.stCoapi, "#arguments.typename#")>
			<cfif len(arguments.md)>
				<cfif structKeyExists(application.stCoapi['#arguments.typename#'], arguments.md)>
					<cfset result = application.stCoapi['#arguments.typename#']['#arguments.md#'] />
				</cfif>
			<cfelse>
				<cfset result = application.stCoapi['#arguments.typename#'] />
			</cfif>
		</cfif>

		<cfreturn duplicate(result) />
	</cffunction>
			
	<cffunction name="getPropertyMetadata" access="public" output="false" returntype="any" hint="Returns the value of the metadata for a typename/property passed in. Omitting the md name, all metadata for the property will be returned.">
		<cfargument name="typename" required="true" type="string" hint="The typename containing the property" />
		<cfargument name="property" required="true" type="string" hint="The property for which we want metadata for" />
		<cfargument name="md" required="false" type="string" default="" hint="The name of the piece of metadata we want (optional)" />
		<cfargument name="default" required="false" default="" type="string" hint="The default value if the metadata does not exist" />
		
		<cfset var result = arguments.default />
		
		<cfif isDefined("application.stCoapi.#arguments.typename#.stProps.#arguments.property#.METADATA")>
			<cfif len(arguments.md)>
				<cfif structKeyExists(application.stCoapi['#arguments.typename#'].stProps['#arguments.property#'].METADATA, arguments.md)>
					<cfset result = application.stCoapi['#arguments.typename#'].stProps['#arguments.property#'].METADATA['#arguments.md#'] />
				</cfif>
			<cfelse>
				<cfset result = duplicate(application.stCoapi['#arguments.typename#'].stProps['#arguments.property#'].METADATA) />
			</cfif>
		</cfif>

		<cfreturn duplicate(result) />
	</cffunction>
	
	<cffunction name="stream" access="public" output="false" returntype="void" hint="Stream content to the user with the specified mime type">
		<cfargument name="content" type="any" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="filename" type="string" required="false" />
		<cfargument name="ccToWords" type="boolean" required="false" default="false" hint="Used for csv types. If set to true, column names in camel case are converted to separate words. e.g. SomeCol => Some Col" />
		<cfargument name="status" type="string" required="false" default="200 OK" hint="Use to override response status code." />

		<cfset var tmp = "" />
		<cfset var field = "" />
		<cfset var fields = "" />
		<cfset var i = "" />
		
		<cfif structkeyexists(arguments,"filename") and len(arguments.filename)>
			<cfheader name="Content-Disposition" value="attachment; filename=#arguments.filename#" />
		</cfif>
		
		<!--- handle different versions of the type argument, and check the type of content against them --->
		<cfswitch expression="#arguments.type#">
			<cfcase value="html,htmlfragment" delimiters=",">
				<cfset arguments.type = "text/html" />
				<cfif not issimplevalue(arguments.content)>
					<cfthrow message="Content must be a string when streaming HTML" />
				</cfif>
			</cfcase>
			<cfcase value="text">
				<cfset arguments.type = "text/plain" />
				<cfif not issimplevalue(arguments.content)>
					<cfthrow message="Content must be a string when streaming text" />
				</cfif>
			</cfcase>
			<cfcase value="json">
				<cfset arguments.type = "text/json" />
				<cfif not issimplevalue(arguments.content)>
					<cfset arguments.content = serializeJSON(arguments.content) />
				</cfif>
			</cfcase>
			<cfcase value="xml">
				<cfset arguments.type = "text/xml" />
				<cfif isxml(arguments.content)>
					<cfset arguments.content = arguments.content.toString() />
				<cfelseif not issimplevalue(arguments.content)>
					<cfwddx action="cfml2wddx" input="#arguments.content#" output="arguments.content" />
				</cfif>
			</cfcase>
			<cfcase value="csv,text/csv" delimiters=",">
				<cfset arguments.type = "text/csv" />
				<cfif isquery(arguments.content)>
					<cfset tmp = createObject("java","java.lang.StringBuffer").init() />
					<cfloop list="#arguments.content.columnlist#" index="field">
						<cfif field neq listfirst(arguments.content.columnlist)>
							<cfset tmp.append(",") />
						</cfif>
						<cfset tmp.append('"') />
						<cfif structKeyExists(arguments,"ccToWords") and arguments.ccToWords>
							<cfset tmp.append(rereplace(file,"(\w)([A-Z])","$1 $2","ALL")) />
						<cfelse>
							<cfset tmp.append(field) />
						</cfif>
						<cfset tmp.append('"') />
					</cfloop>
					<cfloop query="arguments.content">
						<cfset tmp.append("
") />
						<cfloop list="#arguments.content.columnlist#" index="field">
							<cfif field neq listfirst(arguments.content.columnlist)>
								<cfset tmp.append(",") />
							</cfif>
							<cfif isnumeric(arguments.content[field][arguments.content.currentrow]) or isboolean(arguments.content[field][arguments.content.currentrow])>
								<cfset tmp.append(arguments.content[field][arguments.content.currentrow]) />
							<cfelse>
								<cfset tmp.append('"') />
								<cfset tmp.append(arguments.content[field][arguments.content.currentrow]) />
								<cfset tmp.append('"') />
							</cfif>
						</cfloop>
					</cfloop>
					<cfset arguments.content = tmp.toString() />
				<cfelseif isarray(arguments.content) and arraylen(arguments.content) and isstruct(arguments.content[1])>
					<cfset tmp = createObject("java","java.lang.StringBuffer").init() />
					<cfif structkeyexists(arguments.content[1],"columnlist")>
						<cfset fields = arguments.content[1].columnlist />
					<cfelse>
						<cfset fields = structkeylist(arguments.content[1]) />
					</cfif>
					<cfloop from="1" to="#arraylen(arguments.content)#" index="i">
						<cfloop list="#fields#" index="field">
							<cfif field neq listfirst(fields)>
								<cfset tmp.append(",") />
							</cfif>
							<cfif isnumeric(arguments.content[i][field]) or isboolean(arguments.content[i][field])>
								<cfset tmp.append(arguments.content[i][field]) />
							<cfelse>
								<cfset tmp.append('"') />
								<cfset tmp.append(arguments.content[i][field]) />
								<cfset tmp.append('"') />
							</cfif>
						</cfloop>
						<cfset tmp.append("
") />
					</cfloop>
					<cfset arguments.content = tmp.toString() />
				<cfelseif not issimplevalue(arguments.content)>
					<cfthrow message="Content must be a string or a query or an array of structs when streaming a CSV" />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<!--- add browser and proxy cache information, if it isn't too late' --->
		<cfif not GetPageContext().GetResponse().IsCommitted()>
			<cfimport taglib="/farcry/core/tags/misc" prefix="misc" />
			
			<cfif isdefined("request.fc.okToCache") and request.fc.okToCache>
				<!--- Page ok to cache, a webskin has specified a cache timeout --->
				<cfif not isdefined("request.fc.browserCacheTimeout") or request.fc.browserCacheTimeout eq -1>
					<cfset request.fc.browserCacheTimeout = application.defaultBrowserCacheTimeout />
				</cfif>
				<cfif not isdefined("request.fc.proxyCacheTimeout") or request.fc.proxyCacheTimeout eq -1>
					<cfset request.fc.proxyCacheTimeout = application.defaultProxyCacheTimeout />
				</cfif>
			<cfelse>
				<cfset request.fc.browserCacheTimeout = 0 />
				<cfset request.fc.proxyCacheTimeout = 0 />
			</cfif>
			
			<misc:cacheControl browserSeconds="#request.fc.browserCacheTimeout#" proxySeconds="#request.fc.proxyCacheTimeout#" />
		</cfif>
		
		<!--- stream the content --->
		<cfheader statuscode="#listfirst(arguments.status,' ')#" statustext="#listrest(arguments.status,' ')#" />
		<cfif isSimpleValue(arguments.content)>
			<cfcontent type="#arguments.type#" variable="#ToBinary( ToBase64( trim(arguments.content) ) )#" reset="Yes" />
		<cfelse>
			<cfcontent type="#arguments.type#" variable="#arguments.content#" reset="Yes" />
		</cfif>
	</cffunction>
	
	
	<!--- @@examples:
		<p>Fetch all the related image records attached to the current stObj:</p>
		<code>
			<cfset qContent = application.fapi.getRelatedContent(objectid=stobj.objectid, filter='dmImage') />
			
			<cfloop query="qContent">
				<skin:view objectid=qContent.objectid webskin="displayTeaserStandard" />
			</cfloop>
		</code>
	 --->
	<cffunction name="getRelatedContent" access="public" output="false" returntype="query" hint="Returns a query containing all the objects related to the objectid passed in.">
		<cfargument name="objectid" type="uuID" required="true" hint="The object for which related objects are to be found" />
		<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
		<cfargument name="filter" type="string" required="false" default="" hint="The typename of related objects to find. Empty for ALL typenames." />
		<cfargument name="arrayType" type="string" required="false" default="" hint="The typename containing the property that defines the relationship we are looking for" />
		<cfargument name="arrayProperty" type="string" required="false" default="" hint="The property that defines the relationship we are looking for" />
				
		<cfset var qRelatedContent = application.coapi.coapiutilities.getRelatedContent(objectid="#arguments.objectid#", typename="#arguments.typename#", filter="#arguments.filter#", arrayType="#arguments.arrayType#", arrayProperty="#arguments.arrayProperty#") />
		
		<cfreturn qRelatedContent />
	</cffunction>			
					
	<!--- SECURITY ////////////////////////////////////////  --->
	
	<!--- @@examples:
		<p>Show a link to the webtop if the current user has permission to access it:</p>
		<code>
			<cfif application.fapi.checkPermission("Admin")>
				<a href="#application.url.webtop#/">Webtop</a>
			</cfif>
		</code>
	 --->
	<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Checks the permission against a role. The roles defaults to the currently logged in users assigned roles." bDocument="true">
		<cfargument name="permission" required="true" />
		<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
		
		<cfreturn application.security.checkPermission(permission=arguments.permission, role=arguments.role) />

	</cffunction>
		
	<!--- @@examples:
		<p>Only show a link if the user has permission to view the webskin:</p>
		<code>
			<cfif application.fapi.checkWebskinPermission("dmProfile", "displaySensitiveDetails")>
				<skin:buildLink type="dmProfile" view="displaySensitiveDetails">Show me everything</a>
			</cfif>
		</code>
	 --->
	<cffunction name="checkWebskinPermission" access="public" output="false" returntype="boolean" hint="Checks the view can be accessed by the role. The roles defaults to the currently logged in users assigned roles." bDocument="true">
		<cfargument name="type" required="true" />
		<cfargument name="webskin" required="true" />
		<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
		
		<cfreturn application.security.checkPermission(type=arguments.type,webskin=arguments.webskin, role=arguments.role) />
		</cffunction>
		
		<!--- @@examples:
			<p>Include a webskin if the user has permission to add a news item:</p>
			<code>
				<cfif application.fapi.checkTypePermission("dmNews","Create")>
					<skin:view typename="dmNews" webskin="displayAddNewsForm" />
				</cfif>
			</code>
		 --->
		<cffunction name="checkTypePermission" access="public" output="false" returntype="boolean" hint="Checks the permission against the type for a given role. The roles defaults to the currently logged in users assigned roles." bDocument="true">
			<cfargument name="typename" required="true" />
			<cfargument name="permission" required="true" /><!--- create,edit,delete,approve,canapproveowncontent,requestapproval,view --->
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(typename=arguments.typename, permission=arguments.permission, role=arguments.role) />
		</cffunction>
		
		<!--- @@examples:
			<p>If the user can access a node, show a link to it:</p>
			<code>
				<cfif application.fapi.checkObjectPermission(application.fapi.getNavID("archives","home"),"View")>
					<skin:buildLink objectid="#application.fapi.getNavID("archives","home")#">Archives</skin:buildLink>
				</cfif>
			</code>
		 --->
		<cffunction name="checkObjectPermission" access="public" output="false" returntype="boolean" hint="Checks the permission against the objectid for a given role. The roles defaults to the currently logged in users assigned roles." bDocument="true">
			<cfargument name="objectid" required="true" />
			<cfargument name="permission" required="true"><!--- Approve,CanApproveOwnContent,ContainerManagement,Create,delete,edit RequestApproval,SendToTrash,view --->
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(object=arguments.objectid, permission=arguments.permission, role=arguments.role) />
		</cffunction>
	
		<!--- Current user queries --->
		<!--- @@examples:
			<p>Show a profile webskin if a user is logged in:</p>
			<code>
				<cfif application.fapi.isloggedIn()>
					<skin:view stObject="#application.fapi.getCurrentUser()#" webskin="displayProfilePod" />
				</cfif>
			</code>
		 --->
		<cffunction name="isLoggedIn" access="public" output="false" returntype="boolean" hint="Returns true if a user has logged in." bDocument="true">
			
			<cfreturn application.security.isLoggedIn() />
		</cffunction>
			
		<!--- @@examples:
			<p>Show a block of content if the current user has a specified role. As seen in the 
			example the "Welcome Back" message is only displayed if the current, view user has been 
			assigned the role of "Member". The "Member" part gets defined in the webtop under "roles" and
			the value you pass to this function is the Title of the role.  In other words, the role
			you are checking for needs to be setup per installation and is completely user defined.</p>
			<code>
				<cfif application.fapi.hasRole("Member")>
					<p>Welcome back!</p>
				</cfif>
			</code>
		 --->
		<cffunction name="hasRole" returntype="boolean" output="false" access="public" hint="Returns true if the current user has ANY of the roles passed in. This function should be used sparingly - adding and using permissions instead can make debugging security functionality much easier." bDocument="true">
			<cfargument name="role" type="string" required="false" default="" hint="Roles to check" />
			
			<cfset var permitted = false />
			<cfset var i = "" />
			
			<cfloop list="#arguments.role#" index="i">
				<cfif application.security.hasRole(role="#i#")>
					<cfset permitted = true />
				</cfif>
			</cfloop>
			
			<cfreturn permitted />
		</cffunction>
		

		<!--- @@examples:
			<p>Show content if the current user has a specified permission:</p>
			<code>
				<cfif application.fapi.hasPermission("welcomemessage")>
					<p>Welcome back!</p>
				</cfif>
			</code>
		 --->
		<cffunction name="hasPermission" returntype="boolean" output="false" access="public" hint="Returns true if the current user has ANY of the permissions passed in." bDocument="true">
			<cfargument name="permission" type="string" required="false" default="" hint="permissions to check" />
			
			<cfset var permitted = false />
			<cfset var i = "" />
			
			<cfloop list="#arguments.permission#" index="i">
				<cfif application.security.checkPermission(permission="#i#")>
					<cfset permitted = true />
				</cfif>
			</cfloop>
			
			<cfreturn permitted />
		</cffunction>
		
				
		<!--- @@examples:
			<p>Get the current user:</p>
			<code>
				<cfset stProfile = application.fapi.getCurrentUser() />
				<cfif not isstructempty(stProfile)>
					<cfoutput>Hello #stProfile.firstname#</cfoutput>
				</cfif>
			</code>
		 --->
		<cffunction name="getCurrentUser" access="public" returntype="struct" hint="Gets the currently logged in user's dmProfile or a blank structure if the user is not logged in." bDocument="true">
			<cfreturn getCurrentUsersProfile() />
		</cffunction>
			
			
		<!--- @@examples:
			<p>Get the current logged in users profile:</p>
			<code>
				<cfset stProfile = application.fapi.getCurrentUsersProfile() />
				<cfif not isstructempty(stProfile)>
					<cfoutput>Hello #stProfile.firstname#</cfoutput>
				</cfif>
			</code>
		 --->
		<cffunction name="getCurrentUsersProfile" access="public" returntype="struct" hint="Gets the currently logged in user's dmProfile or a blank structure if the user is not logged in." bDocument="true">
			<cfif structKeyExists(session, "dmProfile")>
				<cfreturn session.dmProfile />
			<cfelse>
				<cfreturn structNew() />
			</cfif>
		</cffunction>
		
		<!--- @@examples:
			<p>Get the current user's favourites:</p>
			<code>
				<cfset aFavourites = application.fapi.getPersonalConfig("favourites",arraynew(1)) />
			</code>
		 --->
		<cffunction name="getPersonalConfig" access="public" returntype="any" output="false" hint="Returns the personalisation value requested">
			<cfargument name="key" type="string" required="true" />
			<cfargument name="default" type="any" required="true" />
			
			<cfif not application.security.isLoggedIn()>
				<cfreturn arguments.default />
			</cfif>
			
			<cfif not structkeyexists(session.dmProfile,"wddxPersonalisation") or not len(session.dmProfile.wddxPersonalisation)>
				<cfreturn arguments.default />
			</cfif>
			
			<cfif not structkeyexists(session.dmProfile,"personalisation")>
				<cfwddx action="wddx2cfml" input="#session.dmProfile.wddxPersonalisation#" output="session.dmProfile.personalisation" />
			</cfif>
			
			<cfif structkeyexists(session.dmProfile.personalisation,arguments.key)>
				<cfreturn session.dmProfile.personalisation[arguments.key] />
			<cfelse>
				<cfreturn arguments.default />
			</cfif>
		</cffunction>
		
		<!--- @@examples:
			<p>Add a bookmark to the current user's favourites:</p>
			<code>
				<cfset aFavourites = application.fapi.getPersonalConfig("favourites",arraynew(1)) />
				<cfset arrayappend(aFavourites,{ url:"http://twitter.com", label:"Twitter" }) />
				<cfset application.fapi.setPersonalConfig("favourites",aFavourites) />
			</code>
		 --->
		<cffunction name="setPersonalConfig" access="public" returntype="void" output="false" hint="Returns the personalisation value requested">
			<cfargument name="key" type="string" required="true" />
			<cfargument name="value" type="any" required="true" />
			
			<cfif not application.security.isLoggedIn()>
				<cfreturn />
			</cfif>
			
			<cfif not structkeyexists(session.dmProfile,"wddxPersonalisation") or not len(session.dmProfile.wddxPersonalisation)>
				<cfset session.dmProfile.personalisation = structnew() />
			</cfif>
			
			<cfset session.dmProfile.personalisation[arguments.key] = arguments.value />
			
			<cfwddx action="cfml2wddx" input="#session.dmProfile.personalisation#" output="session.dmProfile.wddxPersonalisation" />
			
			<cfset setData(stProperties=session.dmProfile) />
		</cffunction>
		
		
	<!--- GENERAL FARCRY --->
	
	
		
		<!--- @@description:
			<p>Ability to save a date from the offset to the local server time. This feature would be especially useful for those people hosting their application on servers where they do not have the ability to change the server clock (e.g shared hosting etc).</p>
			
			@@examples:
			<p>Convert the date relevent to the user into the date offset to the local server time:</p>
			<code>
				#application.fapi.castSystemDateTime(stobj.dateTimeLastUpdated)#
			</code>
		 --->
		<cffunction name="convertToSystemTimezone" access="public" output="false" returntype="date" hint="Convert the date relevent to the user into the date offset to the local server time." bDocumented="true">
			<cfargument name="date" required="true" hint="The date to convert to the standard system time" />
			
			<cfset var applicationTimezone = application.fapi.getConfig('general','applicationTimezone', '#application.fc.serverTimezone#') /><!--- "Australia/Sydney" --->			
			<cfset var UTC = "" /><!--- This will store the UTC Date --->
			<cfset var result = arguments.date /><!--- This will store the offset date --->
			
			<cfif applicationTimezone neq application.fc.serverTimezone>
				<cfset UTC = application.fc.LIB.TIMEZONE.castToUTC(arguments.date, applicationTimezone) /><!--- This will store the UTC Date --->
				<cfset result = application.fc.LIB.TIMEZONE.castFromUTC(UTC, application.fc.serverTimezone) /><!--- This will store the offset date --->
			</cfif>
			
			<cfreturn result />
		</cffunction>

		<!--- @@description:
			<p>Ability to display a date with the offset against local server time. This feature would be especially useful for those people hosting their application on servers where they do not have the ability to change the server clock (e.g shared hosting etc).</p>
			
			@@examples:
			<p>Convert the date stored in the DB to a date that is relevent to the user:</p>
			<code>
				#application.fapi.castOffSetDateTime(stobj.dateTimeLastUpdated)#
			</code>
		 --->
		<cffunction name="convertToApplicationTimezone" access="public" output="false" returntype="date" hint="Convert the date stored in the DB to a date that is relevent to the user" bDocumented="true">
			<cfargument name="date" required="true" hint="The date cast offset from system date" />
			
			<cfset var applicationTimezone = application.fapi.getConfig('general','applicationTimezone', '#application.fc.serverTimezone#') /><!--- "Australia/Sydney" --->			
			<cfset var UTC = "" /><!--- This will store the UTC Date --->
			<cfset var result = arguments.date /><!--- This will store the offset date --->
			
			<cfif applicationTimezone neq application.fc.serverTimezone>
				<cfset UTC = application.fc.LIB.TIMEZONE.castToUTC(arguments.date, application.fc.serverTimezone) /><!--- This will store the UTC Date --->
				<cfset result = application.fc.LIB.TIMEZONE.castFromUTC(UTC, applicationTimezone) /><!--- This will store the offset date --->
			</cfif>
			
			<cfreturn result />
		</cffunction>
		
		<!--- @@description:
			<p>Due to restrictions across the various databases FarCry supports, null dates are NOT supported. To deal with this the formtools have been designed to use certain dates as null. Pass a date into this function to determine if it is a FarCry null date.</p>
			
			@@examples:
			<p>In a news webskin check to see if it should still be published:</p>
			<code>
				<cfif not application.fapi.showFarcryDate(stObj.expirydate) or stObj.expirydate() gt now()>
					<cfoutput>
						<h2>#stObj.title#</h2>
						<p>#stObj.teaser#</p>
					</cfoutput>
				</cfif>
			</code>
		 --->
		<cffunction name="showFarcryDate" access="public" output="false" returntype="boolean" hint="Returns boolean as to whether to show the date based on how farcry stores dates. ie, 2050 or +200 years." bDocumented="true">
			<cfargument name="date" required="true" hint="The date to check" />
			
			<cfset var bShowDate = true />
			
			<cfif isSimpleValue(date) and not len(date)>
				<cfreturn false />
			</cfif>
			
			<!--- Check for old method using 2050 or 4.0 method of adding 200 years allowing you to check for GT 100 years --->
			<cfif year(arguments.date) EQ 2050 OR dateDiff("yyyy", now(), arguments.date) GT 100>
				<cfset bShowDate = false />
			</cfif>
			
			<cfreturn bShowDate>
		</cffunction>
		
		<!--- @@examples:
			<p>Retrieve a config value:</p>
			<code>
				<cfmail to="abc@def.com" to="#application.fapi.getConfig('admin','adminemail')#" subject="Hello">
					Hello world.
				</cfmail>
			</code>
		 --->
		<cffunction name="getConfig" access="public" returntype="any" output="false" hint="Returns the value of any config item. If no default is sent and the property is not found, an error is thrown." bDocument="true">
			<cfargument name="key" required="true" hint="The Config Key identifying the config form the property is located in." />
			<cfargument name="name" required="true" hint="The name of the config property you wish to retrieve a value for." />
			<cfargument name="default" required="false" hint="If the config item is not found, use this as the default." />
			
			<cfset var result = "" />
			
			<cfif not isdefined("request.cache.config.#arguments.key#") AND isDefined("application.stCOAPI.farConfig")>
				<cfset request.cache.config[arguments.key] = application.fapi.getContentType("farConfig").getConfig(arguments.key) />
			</cfif>

			<cfif isdefined("application.config_readonly.#arguments.key#.#arguments.name#")>
				<cfset result = application.config_readonly[arguments.key][arguments.name] />
			<cfelseif isDefined("request.cache.config.#arguments.key#.#arguments.name#")>
				<cfset result = request.cache.config[arguments.key][arguments.name] />
			<cfelseif structKeyExists(arguments, "default")>
				<cfset result = arguments.default />
			<cfelse>
				<cfthrow message="The config item [#arguments.key#:#arguments.name#] was not found and no default value was passed." />
			</cfif>
			
			<cfreturn result />
		</cffunction>
		

		<!--- @@examples:
			<p>Set a config value:</p>
			<code>
				<cfset application.fapi.setConfig('admin','adminemail', 'info@daemon.com.au') />
			</code>
		 --->
		<cffunction name="setConfig" access="public" returntype="void" output="false" hint="Returns the value of any config item. If no default is sent and the property is not found, an error is thrown." bDocument="true">
			<cfargument name="key" required="true" hint="The Config Key identifying the config form the property is located in." />
			<cfargument name="name" required="true" hint="The name of the config property you wish to retrieve a value for." />
			<cfargument name="value" required="true" hint="The value to set the config item to." />
			<cfargument name="bReadOnly" required="false" default="false" hint="Flag this config item as read only so that it cannot be edited via the webtop." />

			<cfif isDefined("application.config.#arguments.key#.#arguments.name#")>
				<cfset application.config[arguments.key][arguments.name] = arguments.value />
			</cfif>

			<cfif arguments.bReadOnly>
				<cfparam name="application.config_readonly" default="#structNew()#">
				<cfparam name="application.config_readonly.#arguments.key#" default="#structNew()#">
				<cfset application.config_readonly[arguments.key][arguments.name] = arguments.value>
			</cfif>
			
			<cfreturn />
		</cffunction>

		<!--- @@examples:
			<p>Link to the archive navigation node if it has been defined:</p>
			<code>
				<cfif not application.fapi.checkNavID("archive")>
					<skin:buildLink objectid="#application.fapi.getNavID("archive")#">Archive</skin:buildLink>
				</cfif>
			</code>
		 --->
		<cffunction name="checkNavID" access="public" returntype="boolean" output="false" hint="Returns true if the navigation alias is found." bDocument="true">
			<cfargument name="alias" required="true" hint="The navigation alias" />
	
			<cfset var result = "" />
			
			<cfif not isdefined("request.cache.navid")>
				<cfset request.cache.navid = application.fapi.getContentType("dmNavigation").getNavAlias() />
			</cfif>

			<cfif len(arguments.alias)>
				<cfset result = structKeyExists(request.cache.navid, arguments.alias) />
			<cfelse>
				<cfset result = false />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<!--- @@examples:
			<p>Link to the archive navigation node if it has been defined:</p>
			<code>
				<cfif not application.fapi.checkNavID("archive")>
					<skin:buildLink objectid="#application.fapi.getNavID("archive")#">Archive</skin:buildLink>
				</cfif>
			</code>
		 --->
		<cffunction name="getNavID" access="public" returntype="string" output="false" hint="Returns the objectID of the dmNavigation record for the passed alias. If the alias does not exist, the alternate alias will be used." bDocument="true">
			<cfargument name="alias" required="true" hint="The navigation alias" />
			<cfargument name="alternateAlias" required="false" default="home" />
			
			<cfset var result = "" />
			<cfset var message	= '' />
			
			<cfif not isdefined("request.cache.navid")>
				<cfset request.cache.navid = application.fapi.getContentType("dmNavigation").getNavAlias() />
			</cfif>

			<cfif CheckNavID(arguments.alias)>
				<cfset result = request.cache.navid[arguments.alias] />
			<cfelseif CheckNavID(arguments.alternateAlias)>
				<cfset result = request.cache.navid[arguments.alternateAlias] />
			<cfelse>
				<cfset message = getResource(key="FAPI.messages.NavigationAliasNotFound@text", default="The Navigation alias [{1}] and alternate alias [{2}] was not found", substituteValues=array(arguments.alias, arguments.alternateAlias)) />
				<cfthrow message="#message#" />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<cffunction name="checkCatID" access="public" returntype="boolean" output="false" hint="Returns true if the category alias is found.">
			<cfargument name="alias" required="true" hint="The category alias" />
	
			<cfset var result = "" />
			
			<cfif not isdefined("request.cache.catid")>
				<cfset request.cache.catid = application.fapi.getContentType("dmCategory").getCatAliases() />
			</cfif>

			<cfif len(arguments.alias)>
				<cfset result = structKeyExists(request.cache.catid, arguments.alias) />
			<cfelse>
				<cfset result = false />
			</cfif>
			
			<cfreturn result />
		</cffunction>		
	
		<cffunction name="getCatID" access="public" returntype="string" output="false" hint="Returns the objectID of the dmCategory record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
			<cfargument name="alias" required="true" hint="The navigation alias" />
			<cfargument name="alternateAlias" required="false" default="root" />
			
			<cfset var result = "" />
			<cfset var message = "" />
			
			<cfif not isdefined("request.cache.catid")>
				<cfset request.cache.catid = application.fapi.getContentType("dmCategory").getCatAliases() />
			</cfif>

			<cfif CheckCatID(arguments.alias)>
				<cfset result = request.cache.catid[arguments.alias] />
			<cfelseif CheckCatID(arguments.alternateAlias)>
				<cfset result = request.cache.catid[arguments.alternateAlias] />
			<cfelse>			
				<cfset message = getResource(key="FAPI.messages.CategoryAliasNotFound@text", 
					default="The category alias [{1}] and alternate alias [{2}] was not found",
					locale="", 
					substituteValues=array(arguments.alias, arguments.alternateAlias)) />
				
				<cfthrow message="#message#" />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<!--- @@examples:
			<p>Home:</p>
			<code>
				<cfset urlHome = application.fapi.getLink(alias="home") />
			</code>
			
			<p>A related object:</p>
			<code>
				<cfset urlRelated = application.fapi.getLink(objectid=stObj.relatedIDs[1]) />
			</code>
			
			<p>An alternative page view of a related object:</p>
			<code>
				<cfset urlRelatedAlternate = application.fapi.getLink(objectid=stObj.aRelatedIDs[2],view="displayPageXML") />
			</code>
			
			<p>An alternate body of a related object:</p>
			<code>
				<cfset urlRelatedSwitchBody = application.fapi.getLink(objectid=stObj.aRelatedIDs[3],bodyview="displayBodyFullDetail") />
			</code>
			
			<p>Get a link to a type webskin:</p>
			<code>
				<cfset urlListing = application.fapi.getLink(type="dmNews",bodyview="displayTypeLatest") />
			</code>
		 --->
		<cffunction name="getLink" access="public" returntype="string" output="false" hint="Returns the href of a link based on the arguments passed in. Acts as a facade call to build link with r_url." bDocument="true">
			<cfargument name="href" default=""><!--- the actual href to link to --->
			<cfargument name="objectid" default=""><!--- Added to url parameters; navigation obj id --->
			<cfargument name="alias" default=""><!--- Navigation alias to use to find the objectid --->
			<cfargument name="type" default=""><!--- Added to url parameters: Typename used with type webskin views --->
			<cfargument name="view" default=""><!--- Added to url parameters: Webskin name used to render the page layout --->
			<cfargument name="bodyView" default=""><!--- Added to url parameters: Webskin name used to render the body content --->
			<cfargument name="linktext" default=""><!--- Text used for the link --->
			<cfargument name="target" default="_self"><!--- target window for link --->
			<cfargument name="bShowTarget" default="false"><!--- @@attrhint: Show the target link in the anchor tag  @@options: false,true --->
			<cfargument name="bWebtop" default="false">
			<cfargument name="externallink" default="">
			<cfargument name="id" default=""><!--- Anchor tag ID --->
			<cfargument name="class" default=""><!--- Anchor tag classes --->
			<cfargument name="style" default=""><!--- Anchor tag styles --->
			<cfargument name="title" default=""><!--- Anchor tag title text --->
			<cfargument name="urlOnly" default="false">
			<cfargument name="r_url" default=""><!--- Define a variable to pass the link back (instead of writing out via the tag). Note setting urlOnly invalidates this setting --->
			<cfargument name="xCode" default=""><!--- eXtra code to be placed inside the anchor tag --->
			<cfargument name="includeDomain" default="false">
			<cfargument name="bSecure" default="false"><!--- Return a secure link - ignored when href used --->
			<cfargument name="Domain" default="#cgi.http_host#">
			<cfargument name="stParameters" default="#StructNew()#">
			<cfargument name="urlParameters" default="">
			<cfargument name="JSWindow" default="0"><!--- Default to not using a Javascript Window popup --->
			<cfargument name="stJSParameters" default="#StructNew()#">
			<cfargument name="anchor" default=""><!--- Anchor to place at the end of the URL string. --->
			<cfargument name="ampDelim" type="string" required="false" default="" hint="Delimiter to use for ampersands. Defaults to &amp; except where parameters include ajaxmode" />
			
			
			<cfset var returnURL = "" />
			<cfset var linkID = "" />
			<cfset var stLocal = StructNew()>
			<cfset var jsParameters = "">
			<cfset var i	= '' />
			
			<!--- Setup URL Parameters --->
			<cfif listLen(arguments.urlParameters, "&")>
				<cfloop list="#arguments.urlParameters#" delimiters="&" index="i">
					<cfset arguments.stParameters[listFirst(i, "=")] = listLast(i, "=") />
				</cfloop>
				
				<cfset arguments.urlParameters = "" />
			</cfif>
			
			<!--- ENSURE WE SELECT THE RIGHT DELIMETER --->
			<cfif not len(arguments.ampDelim)>
				<cfif structKeyExists(arguments.stParameters, "ajaxmode")>
					<cfset arguments.ampDelim = "&" />
				<cfelse>
					<cfset arguments.ampDelim = "&amp;" />
				</cfif>
			</cfif>
			
			<cfif len(arguments.target) AND arguments.target NEQ "_self" AND arguments.urlOnly> <!--- If target is defined and the user wants the URL then it is a popup window and must therefore have the following parameters --->		
				<cfset arguments.JSWindow = 1>
				
				<cfparam name="arguments.stJSParameters.Toolbar" default="0">
				<cfparam name="arguments.stJSParameters.Status" default="1">
				<cfparam name="arguments.stJSParameters.Location" default="0">
				<cfparam name="arguments.stJSParameters.Menubar" default="0">
				<cfparam name="arguments.stJSParameters.Directories" default="0">
				<cfparam name="arguments.stJSParameters.Scrollbars" default="1">
				<cfparam name="arguments.stJSParameters.Resizable" default="1">
				<cfparam name="arguments.stJSParameters.Top" default="0">
				<cfparam name="arguments.stJSParameters.Left" default="0">
				<cfparam name="arguments.stJSParameters.Width" default="700">
				<cfparam name="arguments.stJSParameters.Height" default="700">
			</cfif>
			
		
			<!--- If they passed in an href, just use that as the base return url --->
			<cfif len(arguments.href)>
				<cfset returnURL = arguments.href>
		
				<cfif NOT FindNoCase("?", arguments.href)>
					<cfset returnURL = "#returnURL#?">
				</cfif>
			<cfelse>
				<cfif arguments.includeDomain or arguments.bSecure>
					<cfif not listfindnocase("80,443",CGI.SERVER_PORT)>
						<cfset arguments.Domain = "#arguments.domain#:#CGI.SERVER_PORT#" />
					</cfif>

					<cfif CGI.SERVER_PORT_SECURE or arguments.bSecure>
						<cfset returnURL = "https://#arguments.Domain##application.url.webroot#">
					<cfelse>
						<cfset returnURL = "http://#arguments.Domain##application.url.webroot#">
					</cfif>
				<cfelseif arguments.bWebtop>
					<cfset returnURL = application.url.webtop />
				<cfelse>
					<cfset returnURL = application.url.webroot />
				</cfif>
		
				<cfset linkID = "" />
			    
				<cfif len(arguments.externallink)>
					<cfset linkID = arguments.externallink />
				<cfelseif len(arguments.objectid)>
					<cfset linkID = arguments.objectid />
				<cfelseif len(arguments.alias)>
					<cfset linkID = getNavID(alias="#arguments.alias#") />
				</cfif>
		
				<cfif arguments.bWebtop>
					<cfset returnURL = fixURL(url=returnURL,ampDelim=arguments.ampDelim,addValues="objectid=#linkID#&typename=#arguments.type#&view=#arguments.view#&bodyView=#arguments.bodyview#")>
				<cfelse>
					<cfset returnURL = returnURL & application.fc.factory.farFU.getFU(objectid="#linkID#", type="#arguments.type#", view="#arguments.view#", bodyView="#arguments.bodyView#", ampDelim=arguments.ampDelim)>
				</cfif>

			</cfif>

			<!--- Add missing URL --->			
			<cfif not len(returnURL) and isdefined("url.furl")>
				<cfset returnURL = url.furl />
			<cfelseif not len(returnURL)>
				<cfset returnURL = "#cgi.script_name#?#cgi.query_string#" />
			</cfif>
			
			<cfset returnURL = fixURL(url=returnURL,ampDelim=arguments.ampDelim,addValues="#arguments.stParameters#") />

			
			<!--- Append the anchor to the end of the URL. --->
			<cfif len(arguments.anchor)>
				<cfif left(arguments.anchor,1) NEQ "##">
					<cfset arguments.anchor = "###arguments.anchor#">
				</cfif>
				<cfset returnURL = "#returnURL##arguments.anchor#" />		
			</cfif>
			
			<!--- Are we meant to use the Javascript Popup Window? --->
			<cfif arguments.JSWindow>
				
				<cfset jsParameters = "">
				<cfloop list="#structKeyList(arguments.stJSParameters)#" index="i">
					<cfset jsParameters = ListAppend(jsParameters, "#i#=#arguments.stJSParameters[i]#")>
				</cfloop>
				<cfset returnURL = "javascript:win=window.open('#returnURL#', '#arguments.Target#', '#jsParameters#'); win.focus();">
				
			</cfif>
			
			<cfreturn returnURL />
			
		</cffunction>
		
		<!--- @@examples:
			<p>Redirect to the project webroot:</p>
			<code>
				<cflocation url="#application.fapi.getWebRoot()#" />
			</code>
		 --->
		<cffunction name="getWebRoot" access="public" returntype="string" output="false" hint="Returns the url path to the webroot." bDocument="true">
		
			<cfreturn application.url.webroot />
		</cffunction>	
		
		<!--- @@examples:
			<p>In a webskin output an image tag for an image property:</p>
			<code>
				<cfif len(stObj.logo)>
					<cfoutput><img src="#application.fapi.getImageWebRoot()##stObj.logo#" alt="#stObj.title#" /></cfoutput>
				</cfif>
			</code>
		 --->
		<cffunction name="getImageWebRoot" access="public" returntype="string" output="false" hint="Returns the path inside the webroot where all image property paths are relative to. By default, this is the webroot of the project." bDocument="true">
			<cfset var stLoc = application.fc.lib.cdn.ioGetFileLocation(location="images",file="") />
			
			<cfif stLoc.path eq "/">
				<cfreturn "" />
			<cfelse>
				<cfreturn left(stLoc.path,len(stLoc.path)-1) />
			</cfif>
		</cffunction>
			
		<!--- @@examples:
			<p>In a webskin output a link for a file property:</p>
			<code>
				<cfif len(stObj.brochure)>
					<cfoutput><a href="#application.fapi.getFileWebRoot()##stObj.brochure#">Brochure</a></cfoutput>
				</cfif>
			</code>
		 --->
		<cffunction name="getFileWebRoot" access="public" returntype="string" output="false" hint="Returns the path inside the webroot where all file property paths are relative to. By default, this is /files insite the webroot of the project." bDocument="true" bDeprecated="true">
			<cfset deprecated("This function [application.fapi.getFileWebroot] has been deprecated since the implementation of core CDN functionality") />
			
			<cfreturn application.url.fileRoot />
		</cffunction>
	

		<!--- @@examples:
			<p>Use to find the absolute filepath of a file property:</p>
			<code>
				<cfif len(stObj.brochureFile)>
					<cfset absolutePath = application.fapi.getAbsoluteFilePath(typename='myType', property='brochureFile', relativePath="#stObj.brochureFile#")>
					<cfcontent file="#absolutePath#" deletefile="No" reset="Yes" />
				</cfif>
			</code>
		 --->	
	<cffunction name="getAbsoluteFilePath" hint="Returns the absolute filepath by determining value of ftSecure attribute of the property">
		<cfargument name="typename" required="true" />
		<cfargument name="property" required="true" />
		<cfargument name="relativePath" required="true" />
		
		<cfset var bSecure = application.fapi.getPropertyMetadata(typename="#arguments.typename#", property="#arguments.property#", md="ftSecure", default="false")>
		<cfset var ftType = application.fapi.getPropertyMetadata(typename="#arguments.typename#", property="#arguments.property#", md="ftType", default="file")>
		<cfset var filePath = "">
		
		<cfif bSecure>
			<cfset filePath = application.path.secureFilePath />
		<cfelse>
			<cfif ftType EQ "image">
				<cfset filePath = application.path.imageRoot />
			<cfelse>
				<cfset filePath = application.path.defaultFilePath />
			</cfif>
			
		</cfif>
		
		<cfreturn "#filePath##trim(relativePath)#">
	</cffunction>
	

	
		
	<!--- MISCELLANEOUS //////////////////////////////////// --->
	
	<cffunction name="throw" access="public" returntype="void" output="false" hint="Provides similar functionality to the cfthrow tag but is automatically incorporated to use the resource bundles.">
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorcode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedinfo" type="string" required="false" default="" />
		<cfargument name="object" type="object" required="false" />
		<cfargument name="type" type="string" required="false" default="" />
		
		<cfreturn application.fc.lib.error.throw(argumentCollection=arguments) />
	</cffunction>
		
	<!--- @@description:
		<p>The native createUUID is very usefull - unfortunately it always takes 10-15ms to run. This is fine for once off calls, but not for the frequent usage that might happen during an import.</p>
		<p>This function bypasses that problem by accessing the Java equivilent directly.</p>
		
		@@examples:
		<p>Generating many UUIDs:</p>
		<code>
			<cftimer label="createUUID()" type="inline">
				<cfloop from="1" to="10000" index="i">
					<cfset anotheruuid = createuuid() />
				</cfloop>
			</cftimer>
			
			<cftimer label="application.fapi.getUUID()" type="inline">
				<cfloop from="1" to="10000" index="i">
					<cfset anotheruuid = application.fapi.getUUID() />
				</cfloop>
			</cftimer>
		</code>
	 --->
	<cffunction name="getUUID" access="public" returntype="uuid" output="false" hint="A fast createUUID alternative." bDocument="true">
		
		<cfreturn application.fc.utils.createJavaUUID() />
	</cffunction>
		
	<!--- @@description: 
		<p>
			Corrects a URL with the specified query string values removed, replaced, or added.  
			New values can be specified with a query string, struct, or named arguments. 
			Also fixes friendly url query variables.
		</p>
		
		@@examples:
		<p>Refresh the current FarCry page:</p>
		<code>
			<cflocation url="#application.fapi.fixURL()#" />
		</code>
		
		<p>Remove a query variable from a custom URL:</p>
		<code>
			<cfset formurl = application.fapi.fixURL(removevalues="searchstring") />
		</code>
		
		<p>Remove your own query variables as well as FarCry query variables:</p>
		<code>
			<cfset docs = application.fapi.fixURL(removevalues="+searchstring") />
		</code>
		
		<p>Replace or add query variables by specifying a query string:</p>
		<code>
			<cfset nextpage = application.fapi.fixURL(addvalues="page=#url.page+1#") />
		</code>
		
		<p>Replace or add query variables by specifying a struct:</p>
		<code>
			<cfset st = structnew() />
			<cfset st.a = 1 />
			<cfset st.b = black />
			<cfset newpage = application.fapi.fixURL("/otherpage.cfm?a=9",addvalues=st) />
		</code>
	 --->
	<cffunction name="fixURL" returntype="string" output="false" access="public" hint="Corrects a URL with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments. Also fixes friendly url query variables." bDocument="true">
		<cfargument name="url" type="string" required="false" default="#cgi.script_name#?#cgi.query_string#" hint="The url to use" />
		<cfargument name="removevalues" type="string" required="false" hint="List of values to remove from the query string. Prefix with '+' to remove these values in addition to the defaults." />
		<cfargument name="addvalues" type="any" required="false" hint="A query string or a struct of values, to add to the query string" />
		<cfargument name="ampDelim" type="string" required="false" default="&" hint="Delimiter to use for ampersands" />
		<cfargument name="charset" type="string" required="false" default="utf-8" hint="The character encoding in which the url values are encoded." />
		
		<cfreturn application.fc.utils.fixURL(argumentCollection="#arguments#") />
	</cffunction>
		
	<cffunction name="insertQueryVariable" returntype="string" output="false" access="public" hint="Inserts the specified key and value, replacing the existing value for that key">
		<cfargument name="url" type="string" required="true" hint="The url to modify" />
		<cfargument name="key" type="string" required="true" hint="The key to insert" />
		<cfargument name="value" type="string" required="true" hint="The value to insert" />
		<cfargument name="ampDelim" type="string" required="false" default="&" hint="Delimiter to use for ampersands" />
		<cfargument name="charset" type="string" required="false" default="utf-8" hint="The character encoding in which the url values are encoded." />
		
		<cfreturn application.fc.utils.insertQueryVariable(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="success" returntype="struct" output="false" hint="Returns a standard return structure from a function when it is successfull">
		<cfargument name="message" type="string" default="" />
		<cfargument name="detail" type="string" default="" />
		<cfargument name="type" type="string" default="" />
		<cfargument name="name" type="string" default="" />
		<cfargument name="errNumber" type="string" default="" />
		<cfargument name="stackTrace" type="string" default="" />
		<cfargument name="tagContext" type="array" default="#arrayNew(1)#" />
		
		<cfset var stResult = structNew() />
		<cfset var lReserved = "message,detail,type,name,errNumber,stackTrace,tagContext" />
		<cfset var i	= '' />
		

		<cfset stResult.bSuccess = true />
		<cfset stResult.message = arguments.message />
		<cfset stResult.detail = arguments.detail />
		<cfset stResult.type = arguments.type />
		<cfset stResult.name = arguments.name />
		<cfset stResult.errNumber = arguments.errNumber />
		<cfset stResult.stackTrace = arguments.stackTrace />
		<cfset stResult.tagContext = arguments.tagContext />
		
		<cfloop collection="#arguments#" item="i">
			<cfif NOT listFindNoCase(lReserved, i)>
				<cfset stResult[i] = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	
	</cffunction>	
			
	<cffunction name="fail" returntype="struct" output="false" hint="Returns a standard return structure from a function when it fails">
		<cfargument name="message" type="string" default="" />
		<cfargument name="detail" type="string" default="" />
		<cfargument name="type" type="string" default="" />
		<cfargument name="name" type="string" default="" />
		<cfargument name="errNumber" type="string" default="" />
		<cfargument name="stackTrace" type="string" default="" />
		<cfargument name="tagContext" type="array" default="#arrayNew(1)#" />
		
		<cfset var stResult = structNew() />
		<cfset var lReserved = "message,detail,type,name,errNumber,stackTrace,tagContext" />
		<cfset var i	= '' />
		
		<cfset stResult.bSuccess = false />
		<cfset stResult.message = arguments.message />
		<cfset stResult.detail = arguments.detail />
		<cfset stResult.type = arguments.type />
		<cfset stResult.name = arguments.name />
		<cfset stResult.errNumber = arguments.errNumber />
		<cfset stResult.stackTrace = arguments.stackTrace />
		<cfset stResult.tagContext = arguments.tagContext />
		
		<cfloop collection="#arguments#" item="i">
			<cfif NOT listFindNoCase(lReserved, i)>
				<cfset stResult[i] = arguments[i] />
			</cfif>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>	
		
	<cffunction name="deprecated" returntype="string" output="false" hint="As a core developer you can flag deprecated code by using this function to pass in a depricated message">
		<cfargument name="message" default="" required="false" hint="The message to be logged.  Should include instructions for the appropriate best practice to replace the deprecated code.">
			
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
	
		<cfif isdefined("application.log.bDeprecated") AND application.log.bDeprecated>		
			<cftrace type="warning" inline="false" text="#GetBaseTemplatePath()# - #arguments.message#" abort="false" />
			<cflog file="deprecated" application="true" type="warning" text="#GetBaseTemplatePath()# - #arguments.message#" />
			<farcry:logevent location="#getPageContext().getPage().getCurrentTemplatePath()#" type="application" event="deprecated" notes="#arguments.message#" />
		</cfif>
			
		<cfif isdefined("application.log.bDeprecatedBubble") AND application.log.bDeprecatedBubble>	
			<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
			<skin:bubble title="Deprecated" message="#message#" tags="deprecated,warning" />
		</cfif>
		
	</cffunction>	

	<!--- I18N ///////////////////////////////////////////// --->
		
	<!--- @@examples:
		<p>Get a translated string:</p>
		<code>
			<cfoutput>#application.fapi.getResource("project.homepage.welcome","Welcome!")#</cfoutput>
		</code>
		
		<p>Get a simple translated message:</p>
		<code>
			<cfoutput>#application.fapi.getResource("project.homepage.newmessages","You have {1} new messages",5)#</cfoutput>
		</code>
		
		<p>Get a complex translated message:</p>
		<code>
			<cfoutput>#application.fapi.getResource("project.news.currentpage","Page {1} of {2}",application.fapi.array(3,5))#</cfoutput>
		</code>
	 --->
	<cffunction name="getResource" access="public" output="false" returntype="string" hint="Returns the resource string" bDocument="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="default" type="string" required="false" default="#arguments.key#" />
		<cfargument name="substituteValues" required="no" default="#arrayNew(1)#" />
		<cfargument name="locale" type="string" required="false" default="" />
		
		<cfset arguments.rbString = arguments.key />
		
		<cfreturn application.rb.formatRBString(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="getCurrentLocale" access="public" output="false" returntype="string" hint="Returns the current locale string based on if the client is logged in or not">
		<cfreturn application.rb.getCurrentLocale() />
	</cffunction>
	
	<!--- ARRAY FUNCTIONS ////////////////////////////////// --->
	
	<!--- @@examples:
		<p>Create and populate an array:</p>
		<code>
			<cfdump var="#application.fapi.array(5,"How now brown cow",url)#" />
		</code>
	 --->
	<cffunction name="array" access="public" output="false" returntype="array" hint="Creates an array from the passed in arguments" bDocument="true">
		<cfset var aResult = arrayNew(1) />
		<cfset var i = "" />
		
		<cfloop from="1" to="#arrayLen(arguments)#" index="i">
			<cfset arrayAppend(aResult, arguments[i]) />
		</cfloop> 
		
		<cfreturn aResult />
	</cffunction>
	
	<!--- @@examples:
		<p>Search an array:</p>
		<code>
			<cfset a = application.fapi.array(4,3,2,1) />
			<cfdump var="#application.fapi.arrayFind(a,2)#" />
		</code>
	 --->
	<cffunction name="arrayFind" access="public" output="false" returntype="numeric" hint="Returns the index of the first element that matches the specified value. 0 if not found." bDocument="true">
		<cfargument name="ar" type="array" required="true" hint="The array to search" />
		<cfargument name="value" type="Any" required="true" hint="The value to find" />
		
		<cfreturn application.fc.utils.arrayFind(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@examples:
		<p>remove items from an array:</p>
		<code>
			<cfset a = application.fapi.array(4,3,2,1) />
			<cfdump var="#application.fapi.arrayRemove(a,'2,3')#" />
		</code>
	 --->
	<cffunction name="arrayRemove" access="public" output="false" returntype="array" hint="Returns the array with the elements passed in removed." bDocument="true" >
		<cfargument name="array" type="array" required="true" hint="The array to remove elements from" />
		<cfargument name="elements" type="Any" required="true" hint="The elements in the array to remove. Can be an array or a list." />
		
		<cfset var oCaster = "" /><!--- Used in case of Railo --->
		<cfset var x	= '' />
		<cfset var i	= '' />

		<cfif isSimpleValue(arguments.elements)>
			<cfset arguments.elements = listToArray(arguments.elements) />
		</cfif>

		<cfswitch expression="#server.coldfusion.productname#">
			<cfcase value="Railo">
				<cfset oCaster = createObject('java','railo.runtime.op.Caster') />
				<cfset arguments.array.removeAll(oCaster.toList(arguments.elements)) />
			</cfcase>
			<cfdefaultcase>
				<!--- if extended array then manually delete --->
				<cfif arraylen(arguments.array) and isStruct(arguments.array[1])>
					<cfloop from="1" to="#arraylen(arguments.elements)#" index="x">
						<cfloop from="1" to="#arraylen(arguments.array)#" index="i">
							<cfif arguments.array[i].data eq arguments.elements[x]>
								<cfset arrayDeleteAt(arguments.array,i)>
								<cfbreak>
							</cfif>
						</cfloop>									
					</cfloop>

				<cfelse>
					<cfset arguments.array.removeAll(arguments.elements) >
				</cfif>
			</cfdefaultcase>
		</cfswitch>		
		
		<cfreturn arguments.array />
	</cffunction>
		
	<!--- LIST UTILITIES /////////////////////////////////// --->
	
	<!--- @@examples:
		<p>Put the list of plugins in order of greatest precendence:</p>
		<code>
			<cfdump var="#application.fapi.listReverse(application.plugins)#" />
		</code>
	 --->
	<cffunction name="listReverse" access="public" output="false" returntype="string" hint="Reverses a list" bDocument="true">
		<cfargument name="list" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfreturn application.fc.utils.listReverse(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="listDiff" access="public" output="false" returntype="string" hint="Returns the items in list2 that aren't in list2" bDocument="true">
		<cfargument name="list1" type="string" required="true" />
		<cfargument name="list2" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfreturn application.fc.utils.listDiff(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="listIntersection" access="public" output="false" returntype="string" hint="Returns the items in list2 that are also in list2" bDocument="true">
		<cfargument name="list1" type="string" required="true" />
		<cfargument name="list2" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfreturn application.fc.utils.listIntersection(argumentCollection="#arguments#") />
	</cffunction>

	<cffunction name="listMerge" access="public" output="false" returntype="string" hint="Adds items from the second list to the first, where they aren't already present" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being built on" />
		<cfargument name="list2" type="string" required="true" hint="The list being added" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="The delimiters used the lists" />
		
		<cfreturn application.fc.utils.listMerge(argumentCollection="#arguments#") />
	</cffunction>
	
	<!--- @@examples:
		<p>Get the first two, last three, and second through forth items in a list:</p>
		<code>
			<cfset colours = "blue,green,yellow,orange,red,purple" />
			<cfoutput>
				#application.fapi.listSlice(list=colours,end=2)#<br />
				#application.fapi.listSlice(list=colours,start=-3)#<br />
				#application.fapi.listSlice(list=colours,start=2,end=4)#<br />
			</cfoutput>
		</code>
	 --->
	<cffunction name="listSlice" access="public" output="false" returntype="string" hint="Returns the specified elements of the list" bDocument="true">
		<cfargument name="list" type="string" required="true" hint="The list being sliced" />
		<cfargument name="start" type="numeric" required="false" default="1" hint="The start index of the slice. Negative numbers are reverse indexes: -1 is last item." />
		<cfargument name="end" type="numeric" required="false" default="-1" hint="The end index of the slice. Negative values are reverse indexes: -1 is last item." />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
		
		<cfreturn application.fc.utils.listSlice(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@description: 
		<p>
			Filters the items in a list though a regular expression, and returns a new list
			of items that match the regular expression.
		</p>
		
		@@examples: 
		<code>
			var newList = application.fapi.listFilter("one,two,three,four", "^[ot]", ",")
			//newList = "one,two,three"
		</code>
	--->
	<cffunction name="listFilter" access="public" output="false" returntype="string" hint="Filters the items in a list though a regular expression" bDocument="true">
		<cfargument name="list" type="string" required="true" hint="The list being filtered" />
		<cfargument name="filter" type="string" required="true" hint="The regular expression to filter by" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
		
		<cfreturn application.fc.utils.listFilter(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@description: 
		<p>
		Returns true if the first list contains any of the items in the second list. This method
		is case sensitive. See listContainsAnyNoCase if you need case insensitve search.
		</p>
	--->
	<cffunction name="listContainsAny" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being searched" />
		<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
		
		<cfreturn application.fc.utils.listContainsAny(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@description: 
		<p>
		   Returns true if the first list contains any of the items in the second list in any case.
			The third, optional parameter, is the list delimiter - comma by default.
		</p>
		
		@@examples: 
		<code>
			var doesIt = application.fapi.listContainsAnyNoCase("This,will,BE,TRUE","TRUE,Fred,larry,joe",",")
		</code>
	--->
	<cffunction name="listContainsAnyNoCase" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being searched" />
		<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
	
		<cfreturn application.fc.utils.listContainsAnyNoCase(argumentCollection="#arguments#") />
	</cffunction>

	<!--- STRUCT UTILITIES ///////////////////////////////// --->
		
	<!--- @@description: 
		<p>Performs a deep merge on two structs.</p>
				
		@@examples: 
		<code>
			var stNewOne = application.fapi.structMerge(stOne, stTwo, true)
		</code>
	--->
	<cffunction name="structMerge" access="public" output="false" returntype="struct" hint="Performs a deep merge on two structs" bDocument="true">
		<cfargument name="struct1" type="struct" required="true" /><!--- @@attrhint: First struct in the merge --->
		<cfargument name="struct2" type="struct" required="true" /><!--- @@attrhint: Second struct in the merge --->
		<cfargument name="replace" type="boolean" required="false" default="true" /><!--- @@attrhint: replace matching keys.  If true, any key that matches in both struct one and struct two will have the end value of struct two. --->
		
		<cfreturn application.fc.utils.structMerge(argumentCollection="#arguments#") />
	</cffunction>
	
	<!--- @@description: 
		<p>Create and populate a struct.  With newer versions of Coldfusion this method is
			a bit less useful since you can often create structs using the {} notation. For
			example {a=5,b="How now brown cow",c=url}.</p>
		
		@@examples:
		<code>
			<cfdump var="#application.fapi.struct(a=5,b="How now brown cow",c=url)#" />
		</code>
	---> 
	<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments" bDeprecated="true">
		
		<cfreturn application.fc.utils.structCreate(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@description: 
		<p>Create and populate a struct.  With newer versions of Coldfusion this method is
			a bit less useful since you can often create structs using the {} notation. For
			example {a=5,b="How now brown cow",c=url}.</p>
		
		@@examples:
		<code>
			<cfdump var="#application.fapi.struct(a=5,b="How now brown cow",c=url)#" />
		</code>
	 --->
	<cffunction name="struct" returntype="struct" output="false" access="public" hint="Shortcut for creating structs" bDocument="true" bDeprecated="true">
		
		<cfreturn application.fc.utils.struct(argumentCollection="#arguments#") />
	</cffunction>
	
	<cffunction name="filterStructure" returntype="struct" output="false" hint="Removes specified structure elements">
		<cfargument name="st" required="Yes" hint="The structure to parse">
		<cfargument name="lKeys" required="Yes" hint="A list of structure keys to delete">
		
		<cfset var i = 1>
		<cfset var aKeys = "" />
		
		<cfscript>
			aKeys = listToArray(arguments.lKeys);	
			for(i = 1;i LTE arrayLen(aKeys);i=i+1)
			{
				if(structKeyExists(arguments.st,aKeys[i]))
					structDelete(arguments.st,aKeys[i]);
			}
		</cfscript>
		
		<cfreturn arguments.st>
	</cffunction>
		
	<cffunction name="structToNamePairs" returntype="string" output="false" hint="Builds a named pair string from a structure">
		<cfargument name="st" type="struct" required="true">
		<cfargument name="delimiter" default="&" required="false">
		<cfargument name="Quotes" default="" required="false">
		<cfset var keyindex = 1 />
		<cfset var namepair = "" />
		<cfset var keyCount = 0 />
		<cfset var key = "" />

		<cfscript>
			namepair = '';
			keyCount = structCount(arguments.st);
			for(key in arguments.st)
			{	
				namepair = namepair & "#key#=#arguments.quotes##arguments.st[key]##arguments.quotes#";
				if(keyIndex LT keyCount)
					namepair = namepair & "#arguments.delimiter#";
				keyIndex = keyIndex + 1;		
			}
		</cfscript>

		<cfreturn trim(namepair)>
	</cffunction>	
	
	<!--- PACKAGE UTILITIES //////////////////////////////// --->
	
	<!--- @@description: 
		<p>Find the version of a custom component with the most precedence:</p>
		
		@@examples:
		<code>
			<cfoutput>#application.fapi.getPackagePath("custom","myfactory")#</cfoutput>
		</code>
	 --->
	<cffunction name="getPackagePath" access="public" output="false" returntype="string" hint="Finds the component in core/plugins/project, and returns its path" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="component" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />
		
		<cfreturn application.fc.utils.getPath(argumentCollection="#arguments#") />
	</cffunction>

	<!--- @@description:  
		<p>Get a list of all the components in types:</p>
		
		@@examples:
		<code>
			<cfoutput>#application.fapi.getComponents("types")#</cfoutput>
		</code>
	 --->
	<cffunction name="getComponents" access="public" output="false" returntype="string" hint="Returns a list of components for a package" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />
		
		<cfreturn application.fc.utils.getComponents(argumentCollection="#arguments#") />
	</cffunction>
	
	<!--- @@description: 
		<p>Find out if a component is a FarCry content type:</p>
		
		@@examples: 
		<code>
			<cfdump var="#application.fapi.extends(mycomponent path,'farcry.core.packages.types.types')#" />
		</code>
	 --->
	<cffunction name="extends" access="public" output="false" returntype="boolean" hint="Returns true if the specified component extends another" bDocument="true">
		<cfargument name="desc" type="string" required="true" hint="The component to test" />
		<cfargument name="anc" type="string" required="true" hint="The ancestor to check for" />
		
		<cfreturn application.fc.utils.extends(argumentCollection="#arguments#") />
	</cffunction>
	
	<!--- @@description: 
		<p>Returns a list of the components the specified one extends (inclusive)</p>
	--->
	<cffunction name="listExtends" access="public" returntype="string" description="Returns a list of the components the specified one extends (inclusive)" output="false">
		<cfargument name="path" type="string" required="true" hint="The package path of the component" />
	
		<cfreturn application.fc.utils.listExtends(argumentCollection="#arguments#") />
	</cffunction>
	
	<!--- DOCTYPE / VALIDATION ///////////////////////////// --->
	
	<!--- @@description: 
		<p> 
		This function is used to get information about the doctype your application should be
		generating. This value, by default, uses the application.fc.doctype variable.
		</p>
		<p>
		The default variable is set in core and is by default the latest version of html
		(html 4.01 at the time of this writing.).  You can change this by setting the
		application.fc.doctype variable value in your _serverSpecificVars.cfm file.
		</p>
		
		<p>
		This turns the doctype tag contents into a struct.  The parts you'll likely use,
		and will be there for sure are:
		</p>
		
		<table>
			<tr>
				<td>doctype.type</td><td>html, xhtml</td>
			</tr>
			<tr>
				<td>doctype.version</td><td>1.0, 1.1, 3.2, blank</td>
			</tr>
			<tr>
				<td>doctype.subtype</td><td>Frameset, Transitional, blank</td>
			</tr>
			<tr>
				<td>doctype.uri</td><td>dtd, blank</td>
			</tr>
			<tr>
				<td>doctype.tagending</td><td>/, blank</td>
			</tr>
		</table>
		
		<p>
		Example struct output:
		</p>
		<pre>
		AVAILABILITY     | PUBLIC
		PUBLICIDENTIFIER |
		       | LABEL        | XHTML 1.0 Frameset
		       | LANGUAGE     | EN
		       | ORGANIZATION | W3C
		       | RAW          | -//W3C//DTD XHTML 1.0 Frameset//EN
		       | REGISTRATION | -
		       | TYPE         | DTD
		RAW              | html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
		SUBTYPE          | Frameset
		TOPLEVEL         | html
		TYPE             | XHTML
		URI              | http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd
		VERSION          | 1.0
		TAGENDING		 |	/
		</pre>
	--->
	<cffunction name="getDocType" access="public" returntype="struct" output="false">
		<cfargument name="docTypeString" type="string" required="no" default="#application.fc.doctype#" />
		
		<!---
			Example of what we are parsing here: 
			
			html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
			
			Pretty good easy to follow explaination of what these parts mean: 
			http://webdesign.about.com/od/dtds/qt/tipdoctype.htm
		--->
		<cfset var doctype = structNew() />
		
		<cfset var spaceParts = listToArray(arguments.docTypeString, ' ') />
		<cfset var topLevelElement = spaceParts[1] />
		<cfset var availability = "" />
		<!--- formal Public Identifier --->
		<cfset var FPI = "" />
		<cfset var URI = "" />
		<!---  --->
		<cfset var endpart = "" />
		<cfset var registration = "" />
		<cfset var organization = "" />
		<cfset var type = "" />
		<cfset var label = "" />
		<cfset var language = "" />
		
		<cfset doctype.type = topLevelElement />
		<cfset doctype.topLevel = topLevelElement />
		<cfset doctype.subtype = "" />
		<cfset doctype.version = "" />
		<cfset doctype.raw = "#arguments.docTypeString#" />
		
		<!--- HTML5 is going to change the doctype to just be "html" so we wont
			need the rest of this logic for html5 docs --->
		<cfif arrayLen(spaceParts) gt 1>
			<!--- remove the "html" / "xhtml" or whatever string --->
			<cfset arrayDeleteAt(spaceParts, 1) />
			<!--- remove The Availability part (we don't really care about this) PUBLIC or SYSTEM part --->
			<cfset availability = spaceParts[1] />
			<cfset arrayDeleteAt(spaceParts, 1) />
			
			<cfset doctype.availability = availability />
			
			<!--- make sure single quotes are double quotes --->
			<cfset endpart = arrayToList(spaceParts, " ") />
			<cfset endpart = replace(endpart, "'", """", "ALL") />
			
			<!--- Now, split the identifier and dtd into thier own bits, and remove the blank item --->
			<cfset spaceParts = listToArray(endpart, """") />
			
			<!--- The second item will be blank because it's the space between the ident and URI. 
				Sometimes no URI is defined.--->
			<cfif arraylen(spaceParts) gt 1>
				<cfif trim(spaceParts[2]) EQ "">
					<cfset arrayDeleteAt(spaceParts, 2) />
				</cfif>
				<cfset doctype.uri = spaceParts[arraylen(spaceParts)] />
			<cfelse>
				<cfset doctype.uri = "" />
			</cfif>
			
			<cfset FPI = spaceParts[1] />
			<cfset doctype.publicidentifier.raw = FPI />
			
			<!--- Almost done, now we need to check if we are doing strict, loose, etc --->
			<cfset spaceParts = listToArray(FPI, "//") />
			
			<cfset registration = spaceParts[1] />
			<cfset organization = spaceParts[2] />
			<cfset type = listFirst(spaceParts[3], " ") />
			<cfset label = replace(spaceParts[3], type, "") />
			<cfset language = spaceParts[4] />
			
			<cfset doctype.publicidentifier.registration = registration />
			<cfset doctype.publicidentifier.organization = organization />
			<cfset doctype.publicidentifier.type = type />
			<cfset doctype.publicidentifier.label = label />
			<cfset doctype.publicidentifier.language = language />
			
			<cfset spaceParts = listToArray(label, " ") />
			
			<cfset doctype.type = spaceParts[1] />
			<cfset doctype.version = spaceParts[2] />
			<cfif arrayLen(spaceParts) gte 3>
				<cfset doctype.subtype = spaceParts[3] />
			</cfif>
		</cfif>
		
		<cfif doctype.type eq "xhtml">
			<cfset doctype.tagEnding = "/" />
		<cfelse>
			<cfset doctype.tagEnding = "" />
		</cfif>
		
		<cfreturn doctype />
	</cffunction>
	
	<!--- @@description: 
		Valid RSS feeds will have the date displayed in RFC 822 format which looks like:
		Tue, 07 Jul 2009 10:35:38 +0800 This function is used to parse that information 
		into a coldfusion datetime.
		
		If you do not pass in the date string it uses getHttpTimeString() by default which
		will be the current date time.
		
		@@examples: 
		<code>
			var mydate = application.fapi.RFC822ToDate("Tue, 07 Jul 2009 10:35:38 +0800")
		</code>
	--->
	<cffunction name="RFC822ToDate" access="public" returntype="string" output="false">
		<cfargument name="dt" type="string" required="yes" default="#GetHttpTimeString()#" /><!--- @@attrhint: the RFC 822 date string --->
		
		<cfset var sdf = "" />
		<cfset var pos = "" />
		<cfset var rdate = "" />
		
		<cfset sdf = CreateObject("java", "java.text.SimpleDateFormat").init("EEE, dd MMM yyyy HH:mm:ss Z") />
		<cfset pos = CreateObject("java", "java.text.ParsePosition").init(0) />
		<cfset rdate = sdf.parse(dt, pos) />
		
		<cfreturn rdate />
	</cffunction>
	
	<!--- @@description:
		Things like RSS feeds need to have the date displayed in RFC 822 format:
		Tue, 07 Jul 2009 10:35:38 +0800	This funciton takes a coldfusion date and 
		formats it properly. Note you need to pass in the Timezone either as an offset 
		like "+0800", "-0700", etc or as a string like "EST", "PDT", etc.
		
		@@examples: 
		<code>
			//Current RFC 822 date for Sydney
			var mystring = application.fapi.dateToRFC822(now(), "+1000")
		</code>
	--->
	<cffunction name="dateToRFC822" access="public" returntype="string" output="false">
		<cfargument name="dt" type="date" required="yes" default="#now()#" />
		<cfargument name="timezone" type="string" required="yes" default="+0800" />
		
		<cfset var rdate = DateFormat(dt, "ddd, dd mmm yyyy") & " " & TimeFormat(dt, "HH:mm:ss") & " " & timezone />
		
		<cfreturn rdate />
	</cffunction>
	
	<!--- @@description: 
		<p>
		Attempts to strip out all MS Word chars that tend to mess up html display and cause
		xhtml validation to fail.  This also attempts to maintain compatibility with languages
		other than English. If you modify this method, please run the unit tests.
		</p>
		
		@@examples: 
		<code>
			var clean = application.fapi.removeMSWordChars("my possible bad thing")
		</code>
	--->
	<cffunction name="removeMSWordChars" access="public" returntype="string" output="false">
		<cfargument name="dirtyText" required="true" type="string" default="" /><!--- @@attrhint: the text that might have MS word chars --->
		
		<cfset var cleanText = arguments.dirtyText />
		
		<cfset cleanText = replace(cleanText, chr(8220), chr(34), "all") />
		<cfset cleanText = replace(cleanText, chr(8221), chr(34), "all") />
		<cfset cleanText = replace(cleanText, chr(8216), chr(39), "all") />
		<cfset cleanText = replace(cleanText, chr(96),   chr(39), "all") />
		<cfset cleanText = replace(cleanText, chr(8217), chr(39), "all") />
		<cfset cleanText = replace(cleanText, chr(8230), '...',   "all") />
		<cfset cleanText = replace(cleanText, chr(8211), '-',     "all") />
		
		<cfreturn cleanText />
	</cffunction>
	
	<!--- @@description: 
		<p>Provides date formatting in the style of Twitter's timeline: "just now", 
			"5 minutes ago", "yesterday", "2 weeks ago".</p>
		
		@@examples:
		<code>
			#application.fapi.prettyDate(myUglyDate)# 
		</code>
	 --->
	<cffunction name="prettyDate" access="public" returntype="string" output="false">
		<cfargument name="uglyDate" required="true" type="string" default="" />
		<cfargument name="bUseTime" required="false" type="boolean" default="true" hint="Should the comparison include the time part in its equation." />
		
		<cfreturn application.fc.utils.prettyDate(arguments.uglyDate, bUseTime) />
	</cffunction>
	
	<!--- @@examples:
		<p>DEPRECATED: Searches project, plugins and core and returns the url for the best matching icon.</p>
		<code>
			#application.fapi.getIconURL(icon='dmHTML', size=16)# 
		</code>
	 --->	
	<cffunction name="getIconURL" access="public" output="false" returntype="string" hint="Returns the path for the specified icon." bDeprecated="true">
		<cfargument name="icon" type="string" required="true" hint="The name of the icon to retrieve" />
		<cfargument name="size" type="string" required="true" default="48" hint="The size of the icon required" />
		<cfargument name="default" type="string" required="false" default="blank.png" hint="The fallback icon to use" />
		<cfargument name="bPhysicalPath" type="boolean" required="false" default="false" hint="Use of this argument is usually only for the system to stream the file if outside of the webroot." />

		<cfset deprecated("This function [application.fapi.getIconURL] has been deprecated because icon images are no longer used from FarCry 7.0 onwards") />

		<cfreturn "" />
	</cffunction>	
	
	<!--- @@examples:
		<p>Flushes cache on the list of typenames passed in.</p>
		<code>
			#application.fapi.flushCache(lTypes='dmNavigation,dmHTML')# 
		</code>
	 --->	
	<cffunction name="flushCache" access="public" output="false" returnType="void" hint="Flushes cache of passed in typename">
		<cfargument name="lTypes" type="string" default="#structKeyList(application.stCoapi)#" required="true" hint="typenames to flush" />
	
		<cfset var typeName = "" />
	
		<cfloop list="#arguments.lTypes#" index="typeName">
			
			<cfif structkeyexists(application.stCOAPI,typename) AND structKeyExists(application.stCoapi[typeName],"bObjectBroker") AND application.stCoapi[typeName].bObjectBroker>
			
				<cfset application.objectbroker[typeName] = structNew() />
				<cfset application.objectbroker[typeName].aObjects = arrayNew(1) />
				<cfset application.objectbroker[typeName].maxObjects = application.stCoapi[typeName].objectBrokerMaxObjects />

			</cfif>
			
		</cfloop>

		<cfreturn />
	</cffunction>	
	
	<cffunction name="formatJSON" access="public" returntype="string">
		<cfargument name="str" type="string" required="true" />
		
		<cfset var fjson = '' />
		<cfset var pos = 0 />
		<cfset var strLen = len(replace(arguments.str,"\/","/","ALL")) />
		<cfset var indentStr = "    " /><!--- Adjust Indent Token If you Like --->
		<cfset var newLine = chr(10) /><!--- Adjust New Line Token If you Like <BR> --->
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var char = "" />
		
		<cfset arguments.str = replace(arguments.str,"\/","/","ALL") />
		
		<cfloop from="1" to="#strLen#" index="i">
			<cfset char = mid(arguments.str,i,1) />
			
			<cfif char eq '}' or char eq ']'>
				<cfset fjson &= newLine />
				<cfset pos = pos - 1 />
				
				<cfloop from="1" to="#pos#" index="j">
					<cfset fjson = fjson & indentStr />
				</cfloop>
			</cfif>
			
			<cfset fjson &= char />
			
			<cfif char eq '{' or char eq '[' or char eq ','>
				<cfset fjson = fjson & newLine />
				
				<cfif char eq '{' or char eq '['>
					<cfset pos = pos + 1 />
				</cfif>
				
				<cfloop from="1" to="#pos#" index="j">
					<cfset fjson = fjson & indentStr />
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn fjson />
	</cffunction>
	
	
	
	<cffunction name="addProfilePoint" access="public" output="false" returnType="numeric" hint="If profiling is enabled, adds a point to the request profile">
		<cfargument name="section" type="string" required="true" hint="The name of point grouping" />
		<cfargument name="label" type="string" required="true" hint="The name of the profile point" />
		
		<cfif structkeyexists(url,"profile") and (url.profile eq "1" or url.profile eq application.updateappkey)>
			<cfparam name="request.fc.trayData" default="#structnew()#" />
			<cfif not isdefined("request.fc.trayData.profile")>
				<cfset request.fc.trayData.profile = querynew("section,label,tick","varchar,varchar,bigint") />
			</cfif>
			
			<cfset queryaddrow(request.fc.trayData.profile) />
			<cfset querysetcell(request.fc.trayData.profile,"label",arguments.label) />
			<cfset querysetcell(request.fc.trayData.profile,"section",arguments.section) />
			<cfset querysetcell(request.fc.trayData.profile,"tick",getTickCount()) />
			
			<cfreturn request.fc.trayData.profile.recordcount />
		</cfif>
		
		<cfreturn 0 />
	</cffunction>
	
	<cffunction name="getProfileHTML" access="public" output="false" returnType="string" hint="Returns HTML for displaying the profile">
		<cfargument name="profile" type="query" required="true" hint="The chart that we want to chart" />
		<cfargument name="bLongForm" type="boolean" required="false" default="false" />
		
		<cfset var html = "" />
		<cfset var seriesdata = "" />
		<cfset var seriestotal = 0 />
		<cfset var seriesscale = "" />
		<cfset var seriescolours = "" />
		<cfset var thisdata = 0 />
		<cfset var availablecolours = "E41A1C,377EB8,4DAF4A,984EA3,FF7F00,A65628,F781BF,999999" />
		<cfset var stJSON = "" />
		<cfset var i = 0 />
		<cfset var width = 400 />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfloop query="arguments.profile">
			<cfif arguments.profile.section neq "End">
				<cfset thisdata = arguments.profile.tick[arguments.profile.currentrow+1]-arguments.profile.tick />
				<cfset seriesdata = listappend(seriesdata,thisdata,"|") />
				<cfset seriescolours = listappend(seriescolours,listgetat(availablecolours,arguments.profile.currentrow mod listlen(availablecolours) + 1)) />
				<cfset seriestotal = seriestotal + thisdata />
			</cfif>
		</cfloop>
		
		<cfloop list="#seriesdata#" index="thisdata">
			<cfset seriesscale = listappend(seriesscale,"0,#seriestotal#") />
		</cfloop>
		
		<cfif arguments.bLongForm>
			<cfset width = 670 />
		</cfif>
		
		<!--- Get image map info --->
		<skin:onReady><cfoutput>
			var profile = #serializeJSON(arguments.profile,true)#;
			
			$j("area").on("click",function(){
				$j("div.request-profile-details-selected").css("font-weight","normal").removeClass("request-profile-details-selected");
				$j("##"+this.href.split("##")[1]).css("font-weight","bold").addClass("request-profile-details-selected");
				$j("##request-profile-deatils").scrollTop($j(this.href).position.top);
				return false;
			});
			
			$j.getJSON("http://chart.apis.google.com/chart?chbh=23,0,0&chs=#width#x23&cht=bhs&chco=#seriescolours#&chds=#seriesscale#&chd=t:#seriesdata#&chdlp=b&chof=json",function(data){
				var html = [ '<map name="request-profile">' ];
				var visibleindex = -1;
				
				for (var i=0; i<data.chartshape.length; i++){
					visibleindex = visibleindex + 1;
					
					for (; profile.DATA.tick[visibleindex+1]-profile.DATA.tick[visibleindex]==0; visibleindex++);
					
					html.push("<area name='"+data.chartshape[i].name+"' shape='"+data.chartshape[i].type+"' coords='"+data.chartshape[i].coords.join(",")+"' href='##request-profile-details-"+(visibleindex+1)+"' rel='##request-profile-details-"+(visibleindex+1)+"'>");
				}
				
				html.push('</map>');
				
				$j("##profile-chart").after(html.join("")).attr("usemap","##request-profile");
			});
		</cfoutput></skin:onReady>
		
		<!--- Generate HTML --->
		<cfsavecontent variable="html"><cfoutput>
			<img src="http://chart.apis.google.com/chart?chbh=23,0,0&chs=#width#x23&cht=bhs&chco=#seriescolours#&chds=#seriesscale#&chd=t:#seriesdata#&chdlp=b" width="#width#" height="23" alt="" id="profile-chart" />
			<div id='request-profile-details' style='<cfif arguments.bLongForm>height:350px<cfelse>height:65px</cfif>;overflow:scroll;'>
			<cfloop query="arguments.profile">
				<cfif arguments.profile.section neq "End">
					<div id="request-profile-details-#arguments.profile.currentrow#" style="color:###listgetat(availablecolours,arguments.profile.currentrow mod listlen(availablecolours) + 1)#;"><span class="ticks" style="width:35px;display:inline-block;">#arguments.profile.tick[arguments.profile.currentrow+1]-arguments.profile.tick#</span> #jsstringformat(arguments.profile.section)# - #jsstringformat(arguments.profile.label)#</div>
				</cfif>
			</cfloop>
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<!--- @@examples:
		<p>Adds "hello world" to the log displayed when profile=[updateappkey]:</p>
		<code>
			<cfset application.fapi.addRequestLog('hello world') /> 
		</code>
	 --->
	<cffunction name="addRequestLog" access="public" output="false" returnType="numeric" hint="Adds an item to the request log">
		<cfargument name="text" type="string" required="true" hint="The text of the log line" />
		
		<cfif structkeyexists(url,"profile") and (url.profile eq "1" or url.profile eq application.updateappkey)>
			<cfparam name="request.fc.trayData" default="#structnew()#" />
			<cfif not isdefined("request.fc.trayData.log")>
				<cfset request.fc.trayData.log = querynew("when,text","time,varchar") />
			</cfif>
			
			<cfset queryaddrow(request.fc.trayData.log) />
			<cfset querysetcell(request.fc.trayData.log,"when",now()) />
			<cfset querysetcell(request.fc.trayData.log,"text",arguments.text) />
			
			<cfreturn request.fc.trayData.log.recordcount />
		</cfif>
		
		<cfreturn 0 />
	</cffunction>
	
	<cffunction name="getRequestLogHTML" access="public" output="false" returnType="string" hint="Returns display for the log">
		<cfargument name="log" type="query" required="true" hint="The log query to output" />
		<cfargument name="bLongForm" type="boolean" required="false" default="false" />
		
		<cfset var html = "" />
		
		<cfsavecontent variable="html"><cfoutput>
			<textarea cols="80" rows="5" wrap="off"<cfif arguments.bLongForm> style="width:670px;height:373px;"</cfif>><cfloop query="arguments.log">#arguments.log.text##chr(13)##chr(10)#</cfloop></textarea>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>

	
	<!--- @@examples:
		<p>Returns true if the current request was made within the webtop, based on request.fc.inWebtop.</p>
		<code>
			#application.fapi.isInWebtop()# 
		</code>
	 --->	
	<cffunction name="isInWebtop" access="public" output="false" returnType="string" hint="Returns true if the current request was made within the webtop, based on request.fc.inWebtop">
		<cfset var bWebtop = false>
	
		<cfif structKeyExists(request.fc, "inWebtop")>
			<cfset bWebtop = true>
		</cfif>

		<cfreturn bWebtop />
	</cffunction>	

	
	<!--- @@examples:
		<p>Returns the current form theme based on request.fc.inWebtop.</p>
		<code>
			#application.fapi.getDefaultFormTheme()# 
		</code>
	 --->	
	<cffunction name="getDefaultFormTheme" access="public" output="false" returnType="string" hint="Returns the current form theme based on request.fc.inWebtop">
		<cfset var defaultFormTheme = "" />
	
		<cfif structKeyExists(request.fc, "inWebtop")>
			<cfset defaultFormTheme = application.fapi.getConfig('formTheme','webtop') />
		<cfelse>
			<cfset defaultFormTheme = application.fapi.getConfig('formTheme','site') />
		</cfif>

		<cfreturn defaultFormTheme />
	</cffunction>	


</cfcomponent>
