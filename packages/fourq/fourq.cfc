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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
fourQ COAPI
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/fourq.cfc,v 1.43 2005/10/04 01:17:44 guy Exp $
$Author: guy $
$Date: 2005/10/04 01:17:44 $
$Name:  $
$Revision: 1.43 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Introspects current object invocation and determines appropriate table 
structure etc based on the CFC and its extensions, then uses getMetadta()
to build the four queries 
 - SELECT getData()
 - UPDATE setData()
 - INSERT createData()
 - DELETE deleteData()
 
 External Variables :
 FourQ currently depends on the presence of three external variables. These are :
 
 application.dsn -  The applications datasource.
 application.dbtype - Currently supports either 'ora' (oracle 8i++) or 'odbc' (default).
 application.dbowner - This is of most importance if the application is running on
 an Oracle database and the user specified in the applications datasource is not that of the target schemas.  All table names will be preceeded with this variable.

 For example - If the datasource user connects as 'blogmx' - but the target database is actually fourq - then the application.dbowner
 variable should be "fourq."   This means that all queries will actually look in the fourq users schema as opposed to the blogmx schema.

If the application.dbtype is odbc - you may specify application.dbowner as a blank string : '', or alternatively : "<databasename>.dbo. ".
So in the case of a database called 'fourq' - the correct application.dbowner variable would be "fourq.dbo." 
------------------------------------------------------------------------->

<cfcomponent displayname="FourQ COAPI" extends="farcry.core.packages.schema.schema" bAbstract="true">

	<cffunction name="getView" access="public" output="false" returntype="string" hint="Returns the HTML of a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="string" default="" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="no" type="string" default="" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="webskin" required="no" type="string" default="" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="onExitProcess" required="no" type="any" default="" hint="A url string to redirect to if a processForm exit='true' is called within the webskin">
		<cfargument name="alternateHTML" required="no" type="string" hint="If the webskin template does not exist, if this argument is sent in, its value will be passed back as the result.">
		<cfargument name="hashKey" required="no" default="" type="string" hint="Pass in a key to be used to hash the objectBroker webskin cache">
		<cfargument name="bAjax" required="no" default="0" type="boolean" hint="Flag to determine whether to render an ajax call to load the webskin instead of inline." />
		<cfargument name="ajaxID" required="no" default="" type="string" hint="The id to give the div that will call the ajaxed webskin" />
		<cfargument name="ajaxShowloadIndicator" required="no" default="false" type="boolean" hint="Should the ajax loading indicator be shown" />
		<cfargument name="ajaxindicatorText" required="no" default="loading..." type="string" hint="What should be text of the loading indicator" />		
		<cfargument name="ajaxURLParameters" required="no" default="" type="string" hint="parameters to pass for ajax call" />
		<cfargument name="ajaxTimeout" required="no" default="30" type="numeric" hint="ajax timeout" />
		<cfargument name="bIgnoreSecurity" required="false" type="boolean" default="false" hint="Should the getView() ignore webskin security" />	
		<cfargument name="bAllowTrace" required="false" type="boolean" default="true" hint="Sometimes having webskin trace information can break the integrity of a page. This allows you to turn it off." />
			
		<cfset var stResult = structNew() />
		<cfset var stObj = StructNew() />
		<cfset var WebskinPath = "" />
		<cfset var stWebskin = structNew() />
		<cfset var stCurrentView = structNew() />
		<cfset var stArgs = structnew() />
		<cfset var i = 0 />
		<cfset var stLocal = structNew() /><!--- A local scope that can be used in webskins to ensure against race conditions. --->
		<cfset var webskinTypename = "" /><!--- This will store the typename of the webskin to be called. Required in the case of Type Webskins. --->
		<cfset var iViewState = "" /><!--- iterator used when adding to ancestor cacheBySessionVar lists --->
		<cfset var lAttributes = "stobject,typename,objectid,key,template,webskin,stprops,stparam,r_html,r_objectid,hashKey,alternateHTML,onExitProcess,dsn,bAjax,ajaxID,ajaxShowloadIndicator,ajaxindicatorText,ajaxURLParameters,bIgnoreSecurity,bAllowTrace" />
		<cfset var attrib = "" />
		<cfset var lHashKeys = "" />
		<cfset var iHashKey = "" />
		<cfset var urlAjaxLoader = '' />
		<cfset var stCoapi = '' />

		
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
		
		<!--- Initialise webskin trace array --->
		<cfparam name="request.aAncestorWebskinsTrace" default="#arrayNew(1)#" /><!--- To Be Used for Trace Tree --->
		
		<!--- Setup the current request.aAncestorWebskins in case this does not yet exist --->
		<cfif not structKeyExists(request, "aAncestorWebskins")>
			<cfset request.aAncestorWebskins = arrayNew(1) />
		</cfif>	
		
		<!--- init fourq --->
		<cfset webskinTypename = getTypeName() /><!--- Set the typename to the typename of this object instance --->
		
		
		<cfif len(arguments.webskin)>
			<cfset arguments.template = arguments.webskin />
		<cfelseif not len(arguments.template)>
			<cfthrow message="The getView function requires the template or webskin argument.">
		</cfif>

		<!--- make sure that .cfm isn't passed to this method in the template argument --->
		<cfif listLast(arguments.template,".") EQ "cfm">
			<cfset arguments.template = ReplaceNoCase(arguments.template,".cfm", "", "all") />
		</cfif>
		
		
		<cfif isDefined("arguments.stobject") and not structIsEmpty(arguments.stObject)>
			<cfset stobj=arguments.stobject />
		<cfelse>
			<cfif not len(arguments.objectid)>
				<!--- 
				WE WANT TO CALL A TYPE WEBSKIN
				THIS MEANS THAT THE OBJECT THAT WE ARE PASSING TO THE WEBSKIN IS ACTUALLY THE farCOAPI object.
				THE WEBSKIN CACHING IS ALSO DONE AGAINST THE farCOAPI object.
				 --->
				<cfset stObj = application.fc.factory['farCoapi'].getCoapiObject(name="#webskinTypename#") />
	
			<cfelse>			
				<!--- get the data for this instance --->
				<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>
			</cfif>		

			
		</cfif>

		<cfif arguments.bAjax>
			<cfif not len(arguments.ajaxID)>
				<cfset arguments.ajaxID = "#stobj.typename#_#stobj.objectid#_#arguments.template#" />
			</cfif>
			
			<skin:loadJS id="jquery" />
			
			<skin:loadJS id="webskinAjaxLoader">
			<cfoutput>		
				$j.fn.loadAjaxWebskin = function (config){
					var self = this;
					config = config || self.data("loadWebskinAjax") || {};
				
					// action is required
					config.showIndicator = config.showIndicator || false;
					config.indicatorText = config.indicatorText || 'loading...';
					config.timeout = config.timeout || 30;
				
					self.data("loadWebskinAjax",config);
					
					if (config.showIndicator == true) {
						self.html('<div class="loading-indicator">' + config.indicatorText + '</div>');
				}
				
				$j.ajax({
						type		: "GET",
						url			: config.action,
						cache		: false,
						timeout		: config.timeout*1000,
						success		: function(msg){
							if (config.showIndicator == true) {
								self.html('');
						},
						cache		: true
							self.html(msg);
				   }
				 });
					
					return self;
				}
			</cfoutput>
			</skin:loadJS>
			
			<!--- Get the url for the ajax webskin loader --->			
			<!--- TODO: The ampDelim variable causes the link to be in the & 
				instead of &amp; form.  This is a bit of a hack as &amp;
				should work but currently causes an error.  It will take some
				digging into why that is; however, for now this will validate 
				and work. --->
			<cfif len(arguments.objectid)>
				<cfset urlAjaxLoader = application.fapi.getLink(
					type="#stobj.typename#", 
					objectid="#stobj.objectid#", 
					view="#arguments.template#",
					urlParameters="#arguments.ajaxURLParameters#&ajaxmode=1",
					ampDelim="&"
				) />
			<cfelse>
				<cfset urlAjaxLoader = application.fapi.getLink(
					type="#webskinTypename#",
					view="#arguments.template#",
					urlParameters="#arguments.ajaxURLParameters#&ajaxmode=1",
					ampDelim="&"
				) />
			</cfif> 
			<cfsavecontent variable="stWebskin.webskinHTML">
				
				<farcry:traceWebskin 
							objectid="#stobj.objectid#" 
							typename="#stobj.typename#" 
							template="#arguments.template#">
				
					<cfoutput><div id="#arguments.ajaxID#"></div></cfoutput>
				
				</farcry:traceWebskin>
				
				<skin:onReady><cfoutput>
					$j('###arguments.ajaxID#').loadAjaxWebskin({
						action			: '#urlAjaxLoader#', 
						timeout			: #ARGUMENTS.ajaxTimeout#, 
						showIndicator	: #arguments.ajaxShowLoadIndicator#,
						indicatorText	: '#arguments.ajaxIndicatorText#'
					});
				</cfoutput></skin:onReady>
				
			</cfsavecontent>
		<cfelse>
			
	
		
			<!--- Setup custom attributes passed into getView in stParam structure --->
			<cfloop collection="#arguments#" item="attrib">
				<cfif not listFindNoCase(lAttributes, attrib)>
					<cfset arguments.stParam[attrib] = arguments[attrib] />
				</cfif>
			</cfloop>
			
			<!--- If we are potentially caching this webskin, and we have passed in parameters, we need to create a hash key that uniquely identifies these parameters and cache agains them --->
			<cfif application.bObjectBroker AND application.stcoapi[webskinTypename].bObjectBroker AND len(arguments.template) AND structKeyExists(application.stcoapi[webskinTypename].stWebskins, arguments.template) AND application.stcoapi[webskinTypename].stWebskins[arguments.template].cacheStatus EQ 1>
				<cfif not structIsEmpty(arguments.stParam)>
					<cfset lHashKeys = listSort(structKeyList(arguments.stParam),"text", "asc") />
					<cfloop list="#lHashKeys#" index="iHashKey">
						<cfif IsSimpleValue(arguments.stParam[iHashKey])>
							<cfset arguments.hashKey = listAppend(arguments.hashKey, "stParam[#iHashKey#]:#arguments.stParam[iHashKey]#") />
						<cfelse>
							<cfset arguments.hashKey = listAppend(arguments.hashKey, "stParam[#iHashKey#]:{complex}") />
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
	
			
			<!--- Check permissions on this webskin --->
			<cfif not bIgnoreSecurity>
				<cfif arguments.template eq "deniedaccess" or not application.security.checkPermission(type=webskinTypename,webskin=arguments.template)>
					<!--- Make sure this page doesn't get cached --->
					<cfif structKeyExists(request, "aAncestorWebskins")>
						<cfloop from="1" to="#arraylen(request.aAncestorWebskins)#" index="i">
							<cfset request.aAncestorWebskins[i].okToCache = 0 />
							<cfif structKeyExists(stCurrentView, "cacheTimeout")>
								<cfset request.aAncestorWebskins[i].cacheTimeout = stCurrentView.cacheTimeout />
							</cfif>
						</cfloop>
					</cfif>

					<cfsavecontent variable="stWebskin.webskinHTML"><cfinclude template="#getWebskinPath(webskinTypename,'deniedaccess')#" /></cfsavecontent>
					<cfreturn stWebskin.webskinHTML />
				</cfif>
			</cfif>
				
			<cfif NOT structIsEmpty(stObj)>	
	
				<cfset stWebskin = application.fc.lib.objectbroker.getWebskin(objectid=stobj.objectid, typename=stobj.typename, template=arguments.template, hashKey="#arguments.hashKey#") />		
				
				<cfif len(stWebskin.webskinHTML)>			
					<cfset application.fapi.addRequestLog("Retrieved webskin from cache [#stobj.objectid#, #stobj.typename#, #arguments.template#, #stWebskin.webskinCacheID#]") />
	
					<!--- ONLY KEEP TRACK OF THE ANCESTRY IF SET TO FLUSHONOBJECTCHANGE OR TYPEWATCH --->
					<cfif application.coapi.coapiadmin.getWebskinCacheFlushOnObjectChange(typename=stobj.typename, template=arguments.template) 
						OR len(application.coapi.coapiadmin.getWebskinCacheTypeWatch(typename=stobj.typename, template=arguments.template))>
						
						<!--- 
						Loop through ancestors to determine whether to add to dmWebskinAncestor Table
						Only webskins that are cached are added to the table.
						 --->
						<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
							<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
							<cfif structKeyExists(application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins, request.aAncestorWebskins[i].template)>
								<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins[request.aAncestorWebskins[i].template].cacheStatus GT 0>
										
									<cfset stArgs = structnew() />
								
									<cfset stArgs.webskinObjectID = stobj.objectid />
									<cfset stArgs.webskinTypename = stobj.typename />
									<cfset stArgs.webskinRefTypename = stobj.typename />
									<cfset stArgs.webskinTemplate = arguments.template />
									<cfset stArgs.ancestorID = request.aAncestorWebskins[i].objectID />
									<cfset stArgs.ancestorTypename = request.aAncestorWebskins[i].typename />
									<cfset stArgs.ancestorRefTypename = request.aAncestorWebskins[i].refTypename />
									<cfset stArgs.ancestorTemplate = request.aAncestorWebskins[i].template />
							
									<cfset application.fapi.getContentType("dmWebskinAncestor").checkAncestorExists(argumentCollection=stArgs) />
								
								</cfif>
							</cfif>
						</cfloop>
					
					</cfif>
				<cfelse>
					<cfset application.fapi.addRequestLog("Webskin not in cache [#stobj.objectid#, #stobj.typename#, #arguments.template#, #stWebskin.webskinCacheID#]") />
					
					<cfif stobj.typename EQ "farCoapi">
						<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->			
						<cfset stCoapi = application.fc.factory['farCoapi'].getData(objectid="#stobj.objectid#") />
						<cfset webskinTypename = stCoapi.name />
					</cfif>
					<cfset webskinPath = application.coapi.coapiadmin.getWebskinPath(typename=webskinTypename, template=arguments.template) />
							
					<cfif len(webskinPath)>
						
						<cfset stWebskin.webskinHTML = runView(
															argumentCollection="#arguments#",
															stobj="#stobj#", 
															webskinTypename="#webskinTypename#", 
															webskinTemplate="#arguments.template#", 
															webskinPath="#webskinPath#", 
															webskinCacheID="#stWebskin.webskinCacheID#", 
															hashKey="#arguments.hashKey#", 
															stParam="#arguments.stParam#", 
															onExitProcess="#arguments.onExitProcess#",
															dsn="#arguments.dsn#",
															bAllowTrace="#arguments.bAllowTrace#") />
						
					<cfelseif structKeyExists(arguments, "alternateHTML")>
						<cfset stWebskin.webskinHTML = arguments.alternateHTML />
					<cfelse>
						<cfthrow type="Application" 
								message="Error: Template not found [/webskin/#webskinTypename#/#arguments.template#.cfm] and no alternate html provided."
								detail="Error: Template not found [/webskin/#webskinTypename#/#arguments.template#.cfm] and no alternate html provided. typename: #stobj.typename#. objectid: #stobj.objectid#." />
					</cfif>	
				</cfif>		
			<cfelse>
				<cfthrow type="Application" detail="Error: When trying to render [/webskin/#webskinTypename#/#arguments.template#.cfm] the object was not created correctly." />	
			</cfif>
			
			<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
				<cfset request.currentViewTypename = request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].typename />
				<cfset request.currentViewTemplate = request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].template />
			</cfif>
		
		</cfif>
		
		
		
		<cfreturn stWebskin.webskinHTML />
	</cffunction>
	
	<cffunction name="runView" access="private" output="false" returntype="string" hint="Calls the current view and returns the generated content. Used by getView on types, forms and rules.">
	
		<cfargument name="stobj" required="true" />
		<cfargument name="webskinTypename" required="true" />
		<cfargument name="webskinTemplate" required="true" />
		<cfargument name="webskinPath" required="true" />
		<cfargument name="webskinCacheID" required="true" />
		<cfargument name="hashKey" required="true" />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />	
		<cfargument name="onExitProcess" required="false" type="any" default="" hint="A url string to redirect to if a processForm exit='true' is called within the webskin" />
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="bAllowTrace" required="false" type="boolean" default="true" hint="Sometimes having webskin trace information can break the integrity of a page. This allows you to turn it off." />
		
		<cfset var stCurrentView = structNew() />
		<cfset var webskinHTML = "" />
		<cfset var stTrace = "" />
		<cfset var bAdded = "" />
		<cfset var i = "" />
		<cfset var stArgs = "" />
		<cfset var stProperties = "" />
		<cfset var stResult = "" />
		<cfset var bAncestorExists = "" />

		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
		
		
		<!--- Setup the current request.aAncestorWebskins in case this does not yet exist --->
		<cfif not structKeyExists(request, "aAncestorWebskins")>
			<cfset request.aAncestorWebskins = arrayNew(1) />
		</cfif>	
		
		<!--- Add the current view to the array --->
		<cfset stCurrentView.objectid = arguments.stobj.objectid />
		<cfset stCurrentView.refTypename = arguments.stobj.typename />
		<cfset stCurrentView.typename = arguments.webskinTypename />
		<cfset stCurrentView.template = arguments.webskinTemplate />
		<cfset stCurrentView.hashKey = arguments.hashKey />
		
		<cfset stCurrentView.cacheStatus = application.coapi.coapiadmin.getWebskinCacheStatus(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheTimeout = application.coapi.coapiadmin.getWebskinCacheTimeOut(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.browserCacheTimeout = application.coapi.coapiadmin.getBrowserCacheTimeOut(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.proxyCacheTimeout = application.coapi.coapiadmin.getProxyCacheTimeOut(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByURL = application.coapi.coapiadmin.getWebskincacheByURL(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheFlushOnFormPost = application.coapi.coapiadmin.getWebskincacheFlushOnFormPost(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByForm = application.coapi.coapiadmin.getWebskincacheByForm(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByRoles = application.coapi.coapiadmin.getWebskincacheByRoles(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByVars = application.coapi.coapiadmin.getWebskincacheByVars(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheTypeWatch = application.coapi.coapiadmin.getWebskinCacheTypeWatch(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheFlushOnObjectChange = application.coapi.coapiadmin.getWebskinCacheFlushOnObjectChange(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.lFarcryViewStates = "" />
		<cfset stCurrentView.okToCache = 1 />
		<cfset stCurrentView.inHead = structNew() />
		<cfset stCurrentView.inHead.stCustom = structNew() />
		<cfset stCurrentView.inHead.aCustomIDs = arrayNew(1) />
		<cfset stCurrentView.inHead.stOnReady = structNew() />
		<cfset stCurrentView.inHead.aOnReadyIDs = arrayNew(1) />
		
		<cfset stCurrentView.inHead.stCSSLibraries = structNew() />
		<cfset stCurrentView.inHead.aCSSLibraries = arrayNew(1) />
		
		<cfset stCurrentView.inHead.stJSLibraries = structNew() />
		<cfset stCurrentView.inHead.aJSLibraries = arrayNew(1) />
		
		
		<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />					
		
		<!--- Here we are initialising the viewStates. After the call to the webskin, we will know which view states were used  --->
		<cfset request.currentViewTypename = "#stCurrentView.typename#" />
		<cfset request.currentViewTemplate = "#stCurrentView.template#" />
		
		<cfset application.fapi.addProfilePoint("View","#stCurrentView.template# [#stCurrentView.typename#:#stObj.objectid#]") />
		
		<!--- Include the View --->
		<cfsavecontent variable="webskinHTML">
			
			<farcry:traceWebskin 
						objectid="#arguments.stobj.objectid#"
						typename="#stCurrentView.typename#"
						template="#stCurrentView.template#"
						bAllowTrace="#arguments.bAllowTrace#"
			>
						
			<!--- INCLUDE THE WEBSKIN --->
			<cfinclude template="#arguments.WebskinPath#">
			
			</farcry:traceWebskin>
		</cfsavecontent>	
		
		<cfif structKeyExists(request,"mode") AND (request.mode.flushcache EQ 1 OR request.mode.showdraft EQ 1 OR request.mode.tracewebskins eq 1 OR request.mode.design eq 1 OR request.mode.lvalidstatus NEQ "approved" OR (structKeyExists(url, "updateapp") AND url.updateapp EQ 1))>
			<!--- NOT CACHING SO IGNORE --->
		<cfelse>
			<cfif arrayLen(request.aAncestorWebskins)>
				
				<!--- ONLY KEEP TRACK OF THE ANCESTRY IF SET TO FLUSHONOBJECTCHANGE OR TYPEWATCH --->
				<cfif stCurrentView.cacheFlushOnObjectChange or len(stCurrentView.cacheTypeWatch)>
				
				<!--- 
				Loop through ancestors to determine whether to add to dmWebskinAncestor Table
				Only webskins that are cached are added to the table.
				 --->
				<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
					
					<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
					<cfif structKeyExists(application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins, request.aAncestorWebskins[i].template)>
						<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins[request.aAncestorWebskins[i].template].cacheStatus GT 0>
								
							<cfset stArgs = structnew() />
						
							<cfset stArgs.webskinObjectID = arguments.stobj.objectid />
								<cfset stArgs.webskinTypename = arguments.webskinTypename />
								<cfset stArgs.webskinRefTypename = arguments.stobj.typename />
								<cfset stArgs.webskinTemplate = arguments.webskinTemplate />
								<cfset stArgs.ancestorID = request.aAncestorWebskins[i].objectID />
								<cfset stArgs.ancestorTypename = request.aAncestorWebskins[i].typename />
								<cfset stArgs.ancestorRefTypename = request.aAncestorWebskins[i].refTypename />
							<cfset stArgs.ancestorTemplate = request.aAncestorWebskins[i].template />
						
								<cfset application.fapi.getContentType("dmWebskinAncestor").checkAncestorExists(argumentCollection=stArgs) />
							
								</cfif>
							</cfif>
					</cfloop>
						</cfif>
					
				<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">	
					<!--- If this webskin is to never cache, make sure all ancestors also never cache --->
					<cfif stCurrentView.cacheStatus EQ -1>
						<cfset request.aAncestorWebskins[i].okToCache = 0 />
					</cfif>
					
					<!--- If the timeout of this webskin is less than its parents, reset the parents timeout so timeout propogates upwards --->
					<cfif stCurrentView.cacheTimeout LT request.aAncestorWebskins[i].cacheTimeout>
						<cfset request.aAncestorWebskins[i].cacheTimeout = stCurrentView.cacheTimeout />
					</cfif>
					
					<!--- If the browser timeout of this webskin is less than its parent's, update the parent's timeout --->
					<cfif stCurrentView.browserCacheTimeout gt -1 and (request.aAncestorWebskins[i].browserCacheTimeout eq -1 or stCurrentView.browserCacheTimeout lt request.aAncestorWebskins[i].browserCacheTimeout)>
						<cfset request.aAncestorWebskins[i].browserCacheTimeout = stCurrentView.browserCacheTimeout />
					</cfif>
					
					<!--- If the proxy timeout of this webskin is less than its parent's, update the parent's timeout --->
					<cfif stCurrentView.proxyCacheTimeout gt -1 and (request.aAncestorWebskins[i].proxyCacheTimeout eq -1 or stCurrentView.proxyCacheTimeout lt request.aAncestorWebskins[i].proxyCacheTimeout)>
						<cfset request.aAncestorWebskins[i].proxyCacheTimeout = stCurrentView.proxyCacheTimeout />
					</cfif>
				</cfloop>
				
				<!--- WE NEED TO CASCADE UP THE ANCESTRY PATH SOME OF THE CACHE SETTINGS OF DESCENDENT WEBSKINS --->
				<cfif listLen(stCurrentView.cacheByVars)>
					<cfset application.fapi.setAncestorsCacheByVars(stCurrentView.cacheByVars) />
				</cfif>
				
				<cfif stCurrentView.cacheFlushOnFormPost>
					<cfset application.fapi.setAncestorsCacheFlushOnFormPost() />
				</cfif>
				
				<cfif stCurrentView.cacheByForm>
					<cfset application.fapi.setAncestorsCacheByForm() />
				</cfif>
				
				<cfif stCurrentView.cacheByURL>
					<cfset application.fapi.setAncestorsCacheByURL() />
				</cfif>
				
				<cfif stCurrentView.cacheByRoles>
					<cfset application.fapi.setAncestorsCacheByRoles() />
				</cfif>
				
				<!--- Update request browser timeout --->
				<cfif stCurrentView.browserCacheTimeout neq -1 and (not structkeyexists(request.fc,"browserCacheTimeout") or stCurrentView.browserCacheTimeout lt request.fc.browserCacheTimeout)>
					<cfset request.fc.browserCacheTimeout = stCurrentView.browserCacheTimeout />
				</cfif>
				
				<!--- Update request proxy timeout --->
				<cfif stCurrentView.proxyCacheTimeout neq -1 and (not structkeyexists(request.fc,"proxyCacheTimeout") or stCurrentView.proxyCacheTimeout lt request.fc.proxyCacheTimeout)>
					<cfset request.fc.proxyCacheTimeout = stCurrentView.proxyCacheTimeout />
				</cfif>
			</cfif>
			
			<!--- If the current view (Last Item In the array) is still OkToCache --->
			<cfif request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].okToCache>
				<!--- Add the webskin to the object broker if required --->
				<cfset application.fapi.addRequestLog("Caching webskin [#arguments.stobj.objectid#, #arguments.stobj.typename#, #arguments.webskinTemplate#, #arguments.webskinCacheID#]") />
				<cfset bAdded = application.fc.lib.objectbroker.addWebskin(objectid=arguments.stobj.objectid, typename=arguments.stobj.typename, template=arguments.webskinTemplate, webskinCacheID=arguments.webskinCacheID, html=webskinHTML, stCurrentView=stCurrentView) />
			</cfif>
		</cfif>
		
		<cfset request.fc.okToCache = request.aAncestorWebskins[1].okToCache />
		
		<!--- Remove the current view (last item in the array) from the Ancestor Webskins array --->
		<cfset ArrayDeleteAt(request.aAncestorWebskins, arrayLen(request.aAncestorWebskins)) />
		
		<cfreturn webskinHTML />
	
	</cffunction>
	
	<cffunction name="getNavID" access="public" output="false" returntype="string" hint="Returns the default Navigation objectID for the objectID passed in. Empty if it cant find anything applicable.">
		<cfargument name="objectid" required="no" type="string" default="" hint="The objectid for which the navigation objectid is to be found." />
		<cfargument name="typename" required="no" type="string" default="" hint="The typename of the object for which the navigation objectid is to be found." />
		
		<cfset var stNav = structNew() />
		<cfset var navID = "" />	

		<!--- TODO: replace this tag call with a FAPI function (or equivalent) --->
		<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />

		<!--- assign typename if only objectid passed in --->
		<cfif NOT len(arguments.typename)>
			<cfset arguments.typename = application.coapi.coapiUtilities.findType(objectid="#arguments.objectid#") />
			<!--- <cfif NOT len(arguments.typename)><cfthrow /></cfif> --->
		</cfif>
	
		<!--- URL: check the URL for navigation context --->
		<cfif structkeyexists(url, "navid")>		
			<!--- ie. this is a dynamic object looking for context, passing nav on the URL --->
			<cfset navID = url.navid />
		
		<cfelseif structkeyexists(url, "navAlias") AND structKeyExists(application.navid, "#url.navAlias#")>		
			<!--- ie. this is a dynamic object looking for context, passing nav on the URL --->
			<cfset navID = listFirst(application.navid["#url.navAlias#"]) />
		
		</cfif>
		
		<!--- OBJECT: check the content item for a natural navigation context ie. it sits in the site tree --->
		<cfif NOT len(navID)>
			<!--- NEED TO CHECK VERSION ID FIRST INCASE DEVELOPER HAS ADDED VERSION ID TO dmNavigation --->
			<cfif len(arguments.objectid) AND structKeyExists(application.stCoapi["#arguments.typename#"], "bUseInTree") AND application.stCoapi["#arguments.typename#"].bUseInTree>
				<!--- look up the object's parent navigaion node --->
				<!--- TODO: replace this tag call with a FAPI function (or equivalent) --->
				<nj:getNavigation objectId="#arguments.objectId#" r_stobject="stNav" />
				
				<!--- if the object is in the tree this will give us the node --->
				<cfif isStruct(stNav) and structKeyExists(stNav, "objectid") AND len(stNav.objectid)>
					<cfset navID = stNav.objectID>
				</cfif>
			
			<cfelseif arguments.typename eq "dmNavigation" AND len(arguments.objectid)>
				<!--- Use the navigation objectid if its a navigation object --->
				<cfset navID = arguments.objectid />
			</cfif>
		</cfif>

		<!--- ALIAS: check for a nav alias in the site tree matching the typename --->
		<cfif not len(navID)>
			<!--- TODO: replace navid lookup with a FAPI call --->
			<cfif structKeyExists(application.navid, "#arguments.typename#")>
				<cfset navID = listFirst(application.navid["#arguments.typename#"]) />
			</cfif>
		</cfif>
		
		<cfreturn navID />
	
	</cffunction>
	
  	<cffunction name="getDefaultObject" access="public" output="true" returntype="struct">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="yes" type="string" default="#getTypeName()#">
		
		<cfset var stDefaultProperties = structNew() />
		<cfset var qRefDataDupe = queryNew("blah") />
		<cfset var qRefData = queryNew("blah") />
		<cfset var qObjectDupe = queryNew("blah") />
		<cfset var userlogin = "" />
		<cfset var dmProfileID = "" />
		<cfset var stProps = structNew() />
		<cfset var PrimaryPackage = "" />
		<cfset var PrimaryPackagePath = "" />
		<cfset var propertie = "" />
		<cfset var bRefCreated = "" />
		
		
		
		<cfif application.security.isLoggedIn()>
			<cfset userlogin = application.security.getCurrentUserID()>
		<cfelse>
			<cfset userlogin = "Unknown">
		</cfif>
		<cfif isDefined("session.dmProfile.objectid")>
			<cfset dmProfileID = session.dmProfile.objectid>
		<cfelse>
			<cfset dmProfileID = "">
		</cfif>
		
		<cfset stProps=structNew()>
		
		<cfif isDefined("arguments.ObjectID") and len(arguments.ObjectID)>		
			<cfset stProps.objectid = arguments.ObjectID>		
		<cfelse>
			<cfset stProps.objectid = application.fc.utils.createJavaUUID()>
			<cfset arguments.objectid = stProps.objectid />
		</cfif>
		
		<!--- Create a Reference in the RefObjects Table --->
		<cfset bRefCreated = application.coapi.coapiutilities.createRefObjectID(argumentCollection="#arguments#") />
		<cfif not bRefCreated>
			<cfabort showerror="Error Executing Database Query. Duplicate ObjectID #arguments.objectid#" />
		</cfif>
		
		<cfset stProps.typename = arguments.typename>
		
		<cfset stProps.label = "(incomplete)">
		<cfset stProps.lastupdatedby = userlogin>
		<cfset stProps.datetimelastupdated = Now()>
		<cfset stProps.createdby = userlogin>
		<cfset stProps.datetimecreated = Now()>
		<cfset stProps.ownedby = dmProfileID>
		
		
		<cfif structKeyExists(application.types, arguments.typename)>
			<cfset PrimaryPackage = application.types[arguments.typename] />
			<cfset PrimaryPackagePath = application.types[arguments.typename].typepath />
		<cfelseif structKeyExists(application.rules, arguments.typename)>
			<cfset PrimaryPackage = application.rules[arguments.typename] />
			<cfset PrimaryPackagePath = application.rules[arguments.typename].rulepath />
		<cfelse>
			<!--- ie component is not a content type but still extends fourq.. eg. container.cfc --->
			<cfreturn structNew() />
		</cfif>
		
			
		
		<cfset stDefaultProperties = PrimaryPackage.stProps>
		

		<!--- loop through the default content type properties --->
		<cfloop collection="#stDefaultProperties#" item="propertie">
			<!--- check if date type, and set default to the default assigned OR to now() --->
			
			<cfif NOT StructKeyExists(stProps, propertie)>
						
				<cfparam name="stDefaultProperties[propertie].metadata.Default" default="">
				<cfparam name="stDefaultProperties[propertie].metadata.ftDefaultType" default="value">
				<cfparam name="stDefaultProperties[propertie].metadata.ftDefault" default="#stDefaultProperties[propertie].metadata.Default#">
				
						
				
				<cfif stDefaultProperties[propertie].metadata.type eq "array"> 
					<!--- set to the default if it is not already defined above --->
					<cfset stProps[propertie] = arrayNew(1)>
				<cfelse>
					
					<cfswitch expression="#stDefaultProperties[propertie].metadata.ftDefaultType#">
						<cfcase value="Evaluate">
							<cfset stProps[propertie] = Evaluate(stDefaultProperties[propertie].metadata.ftDefault)>
						</cfcase>
						<cfcase value="Expression">
							<cfset stProps[propertie] = Evaluate(DE(stDefaultProperties[propertie].metadata.ftDefault))>
						</cfcase>
						<cfdefaultcase>
							<cfset stProps[propertie] = stDefaultProperties[propertie].metadata.ftDefault>
						</cfdefaultcase>
					</cfswitch>
					
				</cfif>
				
				
			</cfif>
		</cfloop>
				
		<cfreturn stProps>
	</cffunction>
	
	<!---***********  DEPLOYMENT METHODS  ***********--->
	<cffunction name="deployType" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
    	
		<cfset var typename = getTypePath() />
    	<cfset var stResult = structNew()>
		<cfset var stClass = structnew() />
    	
		<cfset stResult = application.fc.lib.db.deployType(typename=typename,bDropTable=arguments.bDropTable,dsn=application.dsn) />
		
		<cfif stResult.bSuccess AND bDeployCoapiRecord>
			<!--- MAKE SURE THAT THE farCOAPI record exists for this type. --->
			<cfset stClass = createObject("component", application.stcoapi.farCoapi.packagepath).getCoapiObject(name=listlast(typename,'.')) />
		</cfif>
		
		<cfreturn stResult>
	</cffunction>
	
 	<cffunction name="isDeployed" access="public" returntype="boolean" output="false" hint="Returns True if the table is already deployed">
		
		<cfreturn application.fc.lib.db.isDeployed(typename=getTypePath(),dsn=application.dsn) />
	</cffunction>
	
	<!---****************  CRUD METHODS  ****************--->
	

	<cffunction name="createData" access="public" output="true" returntype="struct" hint="Create an object including array properties.  Pass in a structure of property values; arrays should be passed as an array. The objectID can be ommitted and one will be created, passed in as an argument or passed in as a key of stProperties argument.">
		<cfargument name="stProperties" type="struct" required="true">
		<cfargument name="objectid" type="UUID" required="false" default="#application.fc.utils.createJavaUUID()#">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		
    	<cfset stReturn = application.fc.lib.db.createData(typename=getTypePath(),stProperties=arguments.stProperties,objectid=arguments.objectid,dsn=arguments.dsn) />
		
		<!--- only create a record in refObjects if one doesnt already exist --->
		<cfif len(application.fapi.findType(objectId = stReturn.objectId)) eq 0>
			<cfset bRefCreated = application.coapi.coapiutilities.createRefObjectID(objectID="#stReturn.objectid#", typename=getTypeName(), dsn=arguments.dsn, dbowner=arguments.dbowner, dbtype=arguments.dbtype) />
		</cfif>
		
		<cfif NOT stReturn.bSuccess>
			<cflog text="#stReturn.message# #stReturn.results[arraylen(stReturn.results)].detail# [SQL: #stReturn.results[arraylen(stReturn.results)].sql#]" file="coapi" type="error" application="yes">
		</cfif>

		<cfset application.fc.lib.objectbroker.flushTypeWatchWebskins(objectid=stReturn.objectid,typename=getTypeName()) />
		
    	<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="getData" access="public" output="true" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="bShallow" type="boolean" required="false" default="false" hint="Setting to true filters all longchar property types from record.">
		<cfargument name="bFullArrayProps" type="boolean" required="false" default="true" hint="Setting to true returns array properties as an array of structs instead of an array of strings IF IT IS AN EXTENDED ARRAY.">
		<cfargument name="bUseInstanceCache" type="boolean" required="false" default="true" hint="setting to use instance cache if one exists">
		<cfargument name="bArraysAsStructs" type="boolean" required="false" default="false" hint="Setting to true returns array properties as an array of structs instead of an array of strings.">
		
		<cfset var stobj=structnew()>
		<cfset var aprops="">
		<cfset var sqlSelect="">
		<cfset var i=0>
		<cfset var qgetData="">
		<cfset var key="">
		<cfset var qArrayData="">
		<cfset var aTmp=arraynew(1)>
		<cfset var stArrayProp=structnew()>
		<cfset var col=0>
		<cfset var j=0>
		<cfset var stPackage = structNew() />
		<cfset var fieldname = "" />
		<cfset var stobjDisplay = structNew() />
		<cfset var oType = "" />
		<cfset var addedtoBroker = "" />
		<cfset var tempObjectStore = structNew() />
		
		<!---------------------------------------------------------------
		Create a reference to the tempObjectStore in the session.
		This is done so that if the session doesn't exist yet (in the case of application.cfc applicationStart), we can trap the error and continue on our merry way.
		 --------------------------------------------------------------->
		<cftry>
			<cfif structKeyExists(session, "TempObjectStore")>
				<cfset tempObjectStore = Session.TempObjectStore />
			</cfif>
			<cfcatch type="any">
				<!--- ignore the error and assume it just doesnt exist yet.  --->
			</cfcatch>
		</cftry>
		
		
		<!--- Check to see if the object is in the temporary object store --->
		<cfif arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs AND structKeyExists(tempObjectStore,arguments.objectid)>
			<!--- get from the temp object stroe --->
			<cfset stObj = tempObjectStore[arguments.objectid] />

		<cfelse>
			<cfif isdefined("request.mode.rebuild") and request.mode.rebuild eq "page">
				<cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(arguments.objectid,getTypeName()) />
			</cfif>
			
			<cfif arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
				<!--- Attempt to get the object from the ObjectBroker --->
				<!--- getFromObjectBroker returns an empty struct if the object is not in the broker --->
				<cfset stobj = application.fc.lib.objectbroker.getFromObjectBroker(ObjectID=arguments.objectid,typename=getTypeName())>
			</cfif>

			<cfif structisEmpty(stObj)>
				
				<cfif arguments.bArraysAsStructs><!--- Normal arrays as structs --->
					<cfset stObj = application.fc.lib.db.getData(typename=getTypePath(),objectid=arguments.objectid,bDepth=0,dsn=arguments.dsn) />
				<cfelseif arguments.bShallow><!--- No longchars --->
					<cfset stObj = application.fc.lib.db.getData(typename=getTypePath(),objectid=arguments.objectid,bDepth=3,dsn=arguments.dsn) />
				<cfelse><!--- Normal get --->
					<cfset stObj = application.fc.lib.db.getData(typename=getTypePath(),objectid=arguments.objectid,bDepth=1,dsn=arguments.dsn) />
				</cfif>
				
				<!--- Attempt to add the object to the broker --->
				<cfif NOT arguments.bArraysAsStructs AND NOT arguments.bShallow>
					<cfset addedtoBroker = application.fc.lib.objectbroker.AddToObjectBroker(stobj=stobj,typename=getTypeName())>
				</cfif>
			</cfif>	

		</cfif>
		
		<!--- 
		The object has not been found anywhere (Instance, Temporary Object Store, Object Broker, Database)
		We therefore need to return a default object of this typename.
		 --->
		<cfif NOT structKeyExists(stObj,'objectID')>
			
			<cfset stObj = getDefaultObject(argumentCollection=arguments)>	
			
			
			<cfset stObj.bDefaultObject = true />
		</cfif>
		

		<cfreturn stObj>
	</cffunction>
	
	<cffunction name="setData" access="public" output="false" returntype="struct" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="bSessionOnly" type="string" required="false" default="false">
		
	    <cfset var stResult = StructNew() />
	    <cfset var stDefaultProperties = "" />
	    <cfset var lockName = "SetData" />

	    
		
		<!--- Make sure that the temporary object store exists in the session scope. --->
		<cfparam name="Session.TempObjectStore" default="#structNew()#" />

		
		<!--- 
		NAMED LOCK
		Set data does a get then set to make sure the entire object is correctly populated. 
		Simultaneous sets under load may lead to conditions where objects are not correctly updated. 
		setdata() uses this named lock (named by objectid) to ensure internal processing within setdata() is sequential rather than parallel.
		 --->
		<cfif structkeyexists(arguments.stProperties, "objectid")>
			<cfset lockName = "LockData_#arguments.stProperties.objectid#" />
		<cfelse>
			<cfset lockName = "LockData_#application.fc.utils.createJavaUUID()#">
		</cfif>
		
		<cflock name="#lockName#" timeout="10" throwontimeout="true">
		
			
			<!--------------------------------------- 
			If the object is to be stored in the session scope only.
			----------------------------------------->		
			<cfif arguments.bSessionOnly>
				<!--- Make sure an object id exists. --->
				<cfparam name="arguments.stProperties.ObjectID" default="#application.fc.utils.createJavaUUID()#" />				
				
				<!--- Get the default properties for this object --->
				<cfset stDefaultProperties = this.getData(objectid=arguments.stProperties.ObjectID,typename=getTypeName()) />
			  	
				<!--- 
				Append the default properties of this object into the properties that have been passed.
				The overwrite flag is set to false so that the default properties do not overwrite the ones passed in.
				 --->
				<cfset StructAppend(arguments.stProperties,stDefaultProperties,false)>	
							
				<!--- Add object to temporary object store --->
				<cfset Session.TempObjectStore[arguments.stProperties.ObjectID] = arguments.stProperties />
				
				<cfset stResult.bSuccess = true />
				<cfset stResult.message = "Object Saved to the Temporary Object Store." />
				<cfset stResult.ObjectID = arguments.stProperties.ObjectID />
				
				
				
			<!--------------------------------------- 
			If the object is to be stored in the Database then run the appropriate gateway
			----------------------------------------->	
		   	<cfelse>
				<!--- Make sure we remove the object from the objectBroker if we update something --->
			    <cfif structkeyexists(arguments.stProperties, "objectid")>
				    <cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs=arguments.stProperties.ObjectID,typename=getTypeName())>
			    </cfif>	    
		   		
		   		<cfset stResult = application.fc.lib.db.setData(stProperties=arguments.stProperties,typename=getTypePath(),dsn=arguments.dsn) />	   	
		   		<cfif not stResult.bSuccess and stResult.message eq "Object does not exist">
			   		<cfset structappend(arguments.stProperties,getDefaultObject(arguments.stProperties.objectid,arguments.stProperties.typename),false) />
					<cfset stResult = application.fc.lib.db.createData(stProperties=arguments.stProperties,typename=getTypePath(),dsn=arguments.dsn) />	   	
					<cfset stProperties.objectid = stResult.objectid />
				</cfif>
		   		
			   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
		   		<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.stProperties.ObjectID)>
			   		<cfset structdelete(Session.TempObjectStore, arguments.stProperties.ObjectID) />
			   	</cfif>
			   		   	 
		   	</cfif>		   	
	   	</cflock>
		
		<cfreturn stResult />
		
	</cffunction>



	<cffunction name="AfterSave" access="public" output="false" returntype="struct" hint="Called from setData and createData and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">

		<cfset var stObject = structNew() />
		<cfset var lRelatedTypenames = "" />
		<cfset var lArrayTables = "" />
		<cfset var iArrayTables = 0 />
		<cfset var lUUIDTables = "" />
		<cfset var iUUIDTables = 0 />
		<cfset var oType = "" />
		<cfset var iField = "" />
		<cfset var iJoinTypename = "" />
		<cfset var iArrayItem = "" />
		<cfset var iTypename = "" />
		<cfset var qRelated = queryNew("blah") />
		<cfset var stProps = structNew() />
		<cfset var aAllRelated = arrayNew(1) />
		<cfset var changeStatus = "" >
		<cfset var stVersionRules = structNew() />	


		<cfset application.fc.lib.objectbroker.flushTypeWatchWebskins(objectid=arguments.stProperties.objectid,typename=arguments.stProperties.typename) />
		
		<!------------------------------------------------------------------ 
		IF THIS OBJECT HAS A STATUS PROPERTY SUBMITTED THEN CHANGE STATUS 
		--------------------------------------------------------------->
		<cfif structKeyExists(arguments.stProperties, "status") AND structKeyExists(application.stcoapi[stProperties.typename].stprops, "status")>
						
			<cfif arguments.stProperties.status EQ "approved">
				<!--- IF CHANGING TO APPROVED, THEN WE WANT TO APPROVE ALL RELATED CONTENT --->
				<cfset changeStatus = "approved" />
			<cfelseif arguments.stProperties.status EQ "draft">
				<!--- IF CHANGING TO DRAFT AND NO LIVE VERSION EXISTS THEN SEND RELATED CONTENT TO DRAFT --->
				<cfset stVersionRules = createObject("component", "#application.packagepath#.farcry.versioning").getVersioningRules(objectID=arguments.stProperties.objectid) />
				<cfif NOT stVersionRules.bLiveVersionExists>
					<cfset changeStatus = "draft" />
	   	</cfif>
			</cfif>
			<cfif len(changeStatus)>
				<cfset stObject = getData(objectid=arguments.stProperties.objectid) />
		
				<!--- LOOP TRHOUGH ALL THE FIELDS IN THIS OBJECT SEARCHING FOR ARRAY OR UUID PROPERTIES --->
				<cfloop list="#structKeyList(application.stcoapi[stProperties.typename].stprops)#" index="iField">
		
					<!--- ADD ARRAY PROPERTIES AND THEIR VALUES TO THE LIST --->
					<cfif application.stcoapi[stProperties.typename].stprops[iField].metadata.type EQ "array"
						AND structKeyExists(application.stcoapi[stProperties.typename].stprops[iField].metadata, "bSyncStatus")
						AND application.stcoapi[stProperties.typename].stprops[iField].metadata.bSyncStatus>
																		
						<cfif arrayLen(stObject[iField]) AND structKeyExists(application.stcoapi[stProperties.typename].stprops[iField].metadata, "ftJoin")>
						
						

							<cfloop list="#application.stcoapi[stProperties.typename].stprops[iField].metadata.ftJoin#" index="iJoinTypename">
								
								<!--- LOOP THROUGH ENTIRE APPLICATION STCOAPI FOR EACH KEY (TYPENAME) --->
								<cfloop collection="#application.stcoapi#" item="dTypeName">									
									
									<!--- LOOP THROUGH TYPENAME PROPERTIES --->
									<cfloop collection="#application.stCOAPI[dtypeName].stProps#" item="dPropertyName">
										
										<!--- FOR EACH CHECK IF TYPE EQ ARRAY AND HAS FTJOIN AND FTJOIN MATCHES iJoinTypename --->
										<cfif application.stCOAPI[dtypeName].stProps[dPropertyName].metadata.type EQ "array" AND structKeyExists(application.stcoapi[dtypeName].stprops[dPropertyName].metadata, "ftJoin") AND listFindNoCase(application.stcoapi[dtypeName].stProps[dPropertyName].metadata.ftJoin, iJoinTypename)>
											
											<!--- CREATE LIST OF TYPES AND THEIR PROPERTIES THAT NEED TO BE CHECKED --->
											<cfif not listFindNoCase(lArrayTables, "#dtypeName#_#dPropertyName#") AND structKeyExists(application.stcoapi[iJoinTypename].stprops, "status")>
												<cfset lArrayTables = listAppend(lArrayTables, "#dtypeName#_#dPropertyName#")>
											</cfif>
											
											<cfif not listFindNoCase(lRelatedTypenames, iJoinTypename) AND structKeyExists(application.stcoapi[iJoinTypename].stprops, "status")>
												<cfset lRelatedTypenames = listAppend(lRelatedTypenames, iJoinTypename)>
											</cfif>
									
										</cfif>
										
									</cfloop>
								
								</cfloop>
								
							</cfloop>
																					
							<cfloop from="1" to="#arrayLen(stObject[iField])#" index="iArrayItem">
								
								<cfset iArrayTables = 0 />
								
								<cfloop list="#lArrayTables#" index="iArrayTable">
									<!--- WE ARE ONLY GOING TO CHANGE THE STATUS IF THIS IS THE ONLY CONTENT ITEM THE RELATED OBJECT IS RELATED TO --->
									<cfquery datasource="#application.dsn#" name="qDuplicate">
										SELECT count(parentID) as counter
										FROM #iArrayTable#
										WHERE data = '#stObject[iField][iArrayItem]#'
									</cfquery>
								
									<cfif qDuplicate.counter>
										<cfset iArrayTables = iArrayTables + qDuplicate.counter>
									</cfif>
									
								</cfloop>
								
								<cfif iArrayTables LTE 1>
									<cfset arrayAppend(aAllRelated, stObject[iField][iArrayItem]) />								
								</cfif>
								
							</cfloop>
								
						</cfif>
						
					</cfif>
					
					<!--- ADD UUID PROPERTIES AND THEIR VALUES TO THE LIST --->
					<cfif application.stcoapi[stProperties.typename].stprops[iField].metadata.type EQ "UUID"
						AND structKeyExists(application.stcoapi[stProperties.typename].stprops[iField].metadata, "bSyncStatus")
						AND application.stcoapi[stProperties.typename].stprops[iField].metadata.bSyncStatus>
						<cfif len(stObject[iField]) AND structKeyExists(application.stcoapi[stProperties.typename].stprops[iField].metadata, "ftJoin")>
							
							<cfloop list="#application.stcoapi[stProperties.typename].stprops[iField].metadata.ftJoin#" index="iJoinTypename">
								
								<!--- loop through entire application.stcoapi for each key (typename) --->
								<cfloop collection="#application.stcoapi#" item="dTypeName">									
									
									<!--- loop through typenames properties --->
									<cfloop collection="#application.stCOAPI[dtypeName].stProps#" item="dPropertyName">
										
										<!--- for each, check if type eq array and exists(application.stcoapi[typename].qmetadata.ftJoin) and listFindNoCase(application.stcoapi[typename].qmetadata.ftJoin, iJoinTypename --->
										<cfif application.stCOAPI[dtypeName].stProps[dPropertyName].metadata.type EQ "UUID" AND structKeyExists(application.stcoapi[dtypeName].stprops[dPropertyName].metadata, "ftJoin") AND listFindNoCase(application.stcoapi[dtypeName].stProps[dPropertyName].metadata.ftJoin, iJoinTypename)>
											
											<cfif not listFindNoCase(lUUIDTables, "#dtypeName#:#dPropertyName#") AND structKeyExists(application.stcoapi[iJoinTypename].stprops, "status")>
												<cfset lUUIDTables = listAppend(lUUIDTables,"#dtypeName#:#dPropertyName#") />
											</cfif>
											
											<!--- If the array properties have a status add to the list --->
											<cfif not listFindNoCase(lRelatedTypenames, iJoinTypename) AND structKeyExists(application.stcoapi[iJoinTypename].stprops, "status")>
												<cfset lRelatedTypenames = listAppend(lRelatedTypenames, iJoinTypename)>
											</cfif>
										
										</cfif>
										
									</cfloop>
									
								</cfloop>
								
							</cfloop>
							
							<cfloop list="#lUUIDTables#" index="UUID">

								<!--- WE ARE ONLY GOING TO CHANGE THE STATUS IF THIS IS THE ONLY CONTENT ITEM THE RELATED OBJECT IS RELATED TO --->
								<cfquery datasource="#application.dsn#" name="qDuplicate">
									SELECT count(objectid) as counter
									FROM #listFirst(UUID,":")#
									WHERE #listLast(UUID,":")# = '#stObject[iField]#'
								</cfquery>

								<cfif qDuplicate.counter>
									<cfset iUUIDTables = iUUIDTables + qDuplicate.counter>
								</cfif>
								
							</cfloop>
							
							<cfif iArrayTables LTE 1 AND iUUIDTables LTE 1>
								<cfset arrayAppend(aAllRelated, stObject[iField]) />
							</cfif>
							
						</cfif>
						
					</cfif>
					
				</cfloop>
				
				<!--- LOOP THROUGH THE ARRAY OF RELATED OBJECTS TO FIND ALL OBJECTS NOT APPROVED AND APPROVE THEM --->
				<cfif arrayLen(aAllRelated)>			
					
					<cfloop list="#lRelatedTypenames#" index="iTypename">					
					
						<cfquery datasource="#application.dsn#" name="qRelated">
							SELECT objectid, status
							FROM #iTypename# 
							WHERE objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arrayToList(aAllRelated)#" />)
							AND status <> '#changeStatus#'
						</cfquery>
	
						<cfset oType = createobject("component", application.types[iTypename].typePath) />
						
						<cfif qRelated.recordCount>
							<cfloop query="qRelated">
								<cfset stProps = structNew() />
								<cfset stProps.objectid = qRelated.objectid />
								<cfset stProps.status = changeStatus />
								
								<cfset stResult = oType.setData(stProperties=stProps,auditNote="Status changed to #changeStatus#") />
							</cfloop>
						</cfif>
		
					</cfloop>
		
				</cfif>
				
			</cfif>
			
		</cfif>
		

		<cfreturn stProperties />
	</cffunction>

	
	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		
		<!--- set status here... if something goes wrong expect a thrown error --->
		<cfset var stResult = structNew()>
		<cfset var stobj = structNew() />
		<cfset var stProps = structNew() />
		<cfset var prop = "" />
		<cfset var tablename = "" />
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.message = "Object deleted successfully">
		
		<cfset stobj = getData(objectid=arguments.objectid)>
		
			
	   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
	   	<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.ObjectID)>	
	   		<cfset structdelete(Session.TempObjectStore, arguments.ObjectID) />
	   	</cfif>
	   				
	    <!--- Make sure we remove the object from the objectBroker if we update something --->
	    <cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs=arguments.ObjectID,typename=getTypeName())>
	    
		<cfset application.fc.lib.db.deleteData(typename=getTypePath(),objectid=arguments.objectid,dsn=arguments.dsn) />
		
		<!--- TODO: convert this to use gateways --->
		<cfquery datasource="#arguments.dsn#" name="qdeleteRefData">
		DELETE FROM #arguments.dbowner#refObjects
		WHERE objectID = '#arguments.objectID#'
		</cfquery>
		
		<cfquery datasource="#arguments.dsn#" name="qdeleteFUs">
		DELETE FROM #arguments.dbowner#farFU
		WHERE refObjectID = '#arguments.objectID#'
		</cfquery>
		
		<cfset application.fc.lib.objectbroker.flushTypeWatchWebskins(objectid=arguments.objectid,typename=getTypeName()) />
		
		<cfreturn stResult>
	</cffunction>
	
	<!---********  NON CRUD DB ACCESS METHODS  **********--->
	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID.">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var result = application.coapi.coapiUtilities.findType(argumentCollection=arguments) />

		<cfreturn result />
	</cffunction>
	
	<!---*************  METADATA METHODS  *************--->
	<cffunction name="getTypePath" access="public" returntype="string" output="false">
		<cfset var stMD = getMetadata(this) />
		
		<cfreturn stMD.fullname />
	</cffunction>
	
	<cffunction name="getTypeName" access="public" returntype="string" output="false">
		<cfset var stMD = getMetadata(this) />
		
		<cfreturn listlast(stMD.fullname,'.') />
	</cffunction>
	
	<!--- private functions --->
	<cffunction name="mergeWebskins" access="private" hint="Merge webskin result queries, skipping duplicates. Non destructive." output="false" returntype="query">
		<cfargument name="query1" type="query" required="true" />
		<cfargument name="query2" type="query" required="true" />
		
		<cfset var qDupe = "" />
		<cfset var qResult = duplicate(arguments.query1)>
		<cfset var col = "" />

		<cfloop query="arguments.query2">

			<!--- Check to see if query1 already contains this webskin --->
			<cfquery dbtype="query" name="qDupe">
				SELECT	*
				FROM	qResult
				WHERE	name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.query2.name[currentrow]#" />
			</cfquery>
			
			<!--- If it doesn't, add it --->
			<cfif NOT qDupe.Recordcount>
				<cfset queryaddrow(qResult,1) />
				<cfloop list="#arguments.query2.columnlist#" index="col">
					<cfset querysetcell(qResult, col, arguments.query2[col][currentrow]) />
				</cfloop>
			</cfif>
			
		</cfloop>
		
		<cfreturn qResult>
	</cffunction>
	
	<cffunction name="paramMetaData" access="private" hint="Set up default values for missing meta data attributes. Non destructive." output="false" returntype="struct">
		<cfargument name="stProps" type="struct" required="true" />
		<cfargument name="lAttributes" type="string" required="true" />
		<cfargument name="default" type="string" />
		
		<cfset var stResult = duplicate(arguments.stProps)>
		<cfset var prop = "" />
		<cfset var att = "" />
		
		<cfloop collection="#stResult#" item="prop">
			<cfloop list="#arguments.lAttributes#" index="att">
				<!--- If the attribute does not exist, then set its default --->
				<cfif not structkeyexists(stResult[prop].metadata,att)>
					<cfif structkeyexists(arguments,"default")>
						<cfset stResult[prop].metadata[att] = arguments.default />
					<cfelseif att eq "ftType">
						<cfif structKeyExists(application.formtools, stResult[prop].metadata.type)>
							<cfset stResult[prop].metadata[att] = stResult[prop].metadata.type />
						<cfelse>
							<cfset stResult[prop].metadata[att] = "string" />
						</cfif>
					<cfelseif att eq "ftLabel">
						<cfset stResult[prop].metadata[att] = stResult[prop].metadata.name />
					<cfelse>
						<cfset stResult[prop].metadata[att] = "" />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="initMetaData" access="public" hint="Extract all component metadata in a flat format for loading into a shared scope." output="true" returntype="struct">
		<cfargument name="stMetaData" type="struct" required="false" default="#structNew()#" hint="Structure to which this cfc's parameters are appended" />
		
		<cfset var stReturnMetadata = super.initMetaData(argumentCollection=arguments) />
		<cfset var componentname = getTypeName() />
		<cfset var filteredWebskins = "" />
		<cfset var filterWebskinName = "" />
		<cfset var filterWebskinTimeout = "" />
		<cfset var col = "">
		<cfset var ixFilter = "">
		<cfset var qDupe = queryNew("blah") />
		<cfset var qFilter = queryNew("blah") />
		<cfset var qExtendedWebskin = queryNew("blah") />
		<cfset var extendedWebskinName = "">
		<cfset var stFilterDetails = structNew() />
		<cfset var ixCol = "">
		<cfset var defaultWebskinCacheStatus = 0 />
		<cfset var webskinCacheStatus = 0 />
		<cfset var stFilteredWebskins = structNew() />
		<cfset var stFormtoolDefaults = structNew() />
		<cfset var prop = '' />
		<cfset var webskinToCache = '' />
		<cfset var res = '' />
		
		
		<!--- Make sure ALL properties have an ftType, ftLabel,ftStyle and ftClass set. If not explicitly set then use defaults. --->
		<cfset stReturnMetadata.stProps = paramMetaData(stReturnMetadata.stProps,"ftType,ftLabel,ftStyle,ftClass,ftValidation") />
		
		<!--- Make sure all required  the defaults are in place --->
		<cfloop collection="#stReturnMetadata.stProps#" item="prop">
			<cfset stFormtoolDefaults = application.coapi.coapiAdmin.getFormtoolDefaults(formtool=stReturnMetadata.stProps[prop].metadata.ftType) />

			<cfset structAppend(stReturnMetadata.stProps[prop].metadata,stFormtoolDefaults,false) />
		</cfloop>
		
		<!--- Set up default attributes --->
		<cfparam name="stReturnMetadata.bAutoSetLabel" default="true" />
		<cfparam name="stReturnMetadata.bObjectBroker" default="false" />
		<cfparam name="stReturnMetadata.lObjectBrokerWebskins" default="" />
		<cfparam name="stReturnMetadata.objectBrokerWebskinCacheTimeout" default="1400" /> <!--- This a value in minutes (ie. 1 day) --->
 		<cfparam name="stReturnMetadata.excludeWebskins" default="" /> <!--- This enables projects to exclude webskins that may be contained in plugins. ---> 
 		<cfparam name="stReturnMetadata.fuAlias" default="#lcase(rereplace(stReturnMetadata.displayname,'[^\w]+','-','ALL'))#" /> <!--- This will store the alias of the typename that can be used by Friendly URLS ---> 

		<!--- Get webkins: webskins for this type, then webskins for extends types --->
		<cfset stReturnMetadata.qWebskins = application.coapi.coapiAdmin.getWebskins(typename="#componentname#", bForceRefresh="true", excludeWebskins="#stReturnMetadata.excludeWebskins#",packagepath=stReturnMetadata.packagepath,aExtends=stReturnMetadata.aExtends) />


		<cfset stReturnMetadata.stWebskins = structNew() />
		<cfloop query="stReturnMetadata.qWebskins">
			<cfset stReturnMetadata.stWebskins[stReturnMetadata.qWebskins.METHODNAME[currentRow]] = structNew() />
			<cfloop list="#stReturnMetadata.qWebskins.columnList#" index="ixCol">
				<cfset stReturnMetadata.stWebskins[stReturnMetadata.qWebskins.METHODNAME[currentRow]][ixCol] = stReturnMetadata.qWebskins[ixCol][currentRow] />
			</cfloop>
		</cfloop>
	
	
		<!--- Setup a location to store all the webskins that need to be watched for CRUD changes --->
		<cfset stReturnMetadata.stTypeWatchWebskins = structNew() />
		
		<!--- 
		NEED TO LOOP THROUGH ALL THE WEBSKINS AND CHECK EACH ONE FOR WILDCARDS.
		IF WILD CARDS EXIST, FIND ALL WEBSKINS THAT MATCH AND ADD THEM TO THE LIST
		THIS WILL OVERRIDE ANY METADATA SPECIFIED IN THE ACTUAL WEBSKIN
		 --->		
		<cfloop list="#stReturnMetadata.lObjectBrokerWebskins#" index="ixFilter">
		
			<cfset filterWebskinName = replaceNoCase(listFirst(ixFilter,":"),"*", "%", "all") />
			<cfif listLast(ixFilter,":") NEQ listFirst(ixFilter,":") AND isNumeric(listLast(ixFilter,":")) AND listLast(ixFilter,":") GTE 0>
				<cfset filterWebskinTimeout = listLast(ixFilter,":")>
			<cfelse>
				<cfset filterWebskinTimeout = stReturnMetadata.objectBrokerWebskinCacheTimeout />
			</cfif>
			
			<cfquery dbtype="query" name="qFilter" result="res">
			SELECT * 
			FROM stReturnMetadata.qWebskins
			<cfif FindNoCase("%", filterWebskinName)>
				WHERE methodname like '#filterWebskinName#'
			<cfelse>
				WHERE methodname = '#filterWebskinName#'			
			</cfif>
			</cfquery>
			
			<cfloop query="qFilter">
				<cfset stFilteredWebskins[qFilter.methodname] = filterWebskinTimeout />
			</cfloop>
		</cfloop>
	
		<!--- Initialize lObjectBrokerWebskins because we are going to re-add them without any timeout values in the list --->
		<cfset stReturnMetadata.lObjectBrokerWebskins = "" />
		
		
		<cfloop collection="#stFilteredWebskins#" item="webskinToCache">
			<cfif stFilteredWebskins[webskinToCache] EQ 0><!--- ie. if the timeout is set to 0 --->
				<cfset stReturnMetadata.stWebskins[webskinToCache].cacheStatus = -1 />
				<cfset stReturnMetadata.stWebskins[webskinToCache].cacheTimeout = 0 />
			<cfelse>
				<cfset stReturnMetadata.stWebskins[webskinToCache].cacheStatus = 1 />
				<cfset stReturnMetadata.stWebskins[webskinToCache].cacheTimeout = stFilteredWebskins[webskinToCache] />
			</cfif>
			<cfset stReturnMetadata.lObjectBrokerWebskins = listAppend(stReturnMetadata.lObjectBrokerWebskins, webskinToCache) />
		</cfloop>

		<cfif stReturnMetadata.bObjectBroker>
			<cfparam name="stReturnMetadata.ObjectBrokerMaxObjects" default="#application.ObjectBrokerMaxObjectsDefault#" />
		<cfelse>
			<cfset stReturnMetadata.ObjectBrokerMaxObjects = 0 />
		</cfif>	
		
		<cfreturn stReturnMetadata />
		
	</cffunction> 
	
	<cffunction name="getI18Property" access="public" output="false" returntype="string" hint="Provides access to I18 values for properties">
		<cfargument name="property" type="string" required="true" hint="The property being queried" default="" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />

		<cfset var meta = "" />
		<cfset var prop = arguments.value />
		
		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfif len(application.stCOAPI[getTypeName()].stProps[arguments.property].metadata["ftLabel"])>
					<cfreturn application.fapi.getResource(key="coapi.#getTypeName()#.properties.#arguments.property#@label",default=application.stCOAPI[getTypeName()].stProps[arguments.property].metadata["ftLabel"]) />
				<cfelse>
					<cfreturn application.fapi.getResource(key="coapi.#getTypeName()#.properties.#arguments.property#@label",default=application.stCOAPI[getTypeName()].stProps[arguments.property].metadata["name"]) />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn application.rb.getResource("coapi.#getTypeName()#.properties.#arguments.property#@#arguments.value#","") />
	</cffunction>

	<cffunction name="getI18Step" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="true" hint="The step being queried" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var prop = arguments.value />
		
		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftWizardStep" />
			</cfcase>
		</cfswitch>
		
		<cfquery dbtype="query" name="qSteps">
			select		ftWizardStep
			from		application.stCOAPI.#getTypeName()#.qMetadata
			where		ftWizardStep <> '#getTypeName()#'
			group by 	ftWizardStep
			order by	ftSeq
		</cfquery>
		
		<cfreturn application.rb.getResource("coapi.#getTypeName()#.steps.#arguments.step#@#arguments.value#",qSteps[prop][arguments.step]) />
	</cffunction>

	<cffunction name="getI18Fieldset" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="false" hint="The step being queried" default="0" />
		<cfargument name="fieldset" type="numeric" required="true" hint="The fieldset being queried" default="0" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var qFieldsets = "" />
		<cfset var prop = arguments.value />
		
		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftFieldset" />
			</cfcase>
			<cfcase value="helptitle">
				<cfset prop = "fthelptitle" />
			</cfcase>
			<cfcase value="helpsection">
				<cfset prop = "fthelpsection" />
			</cfcase>
		</cfswitch>
		
		<cfif arguments.step>
			<cfquery dbtype="query" name="qSteps">
				select		ftWizardStep
				from		application.stCOAPI.#getTypeName()#.qMetadata
				where		ftWizardStep <> '#getTypeName()#'
				group by 	ftWizardStep
				order by	ftSeq
			</cfquery>
		</cfif>
		
		<cfquery dbtype="query" name="qFieldsets">
			select		ftFieldset, ftHelpTitle, ftHelpSection
			from		application.stCOAPI.#getTypeName()#.qMetadata
			<cfif arguments.step>
				where		ftWizardStep = '#qSteps.ftWizardStep[arguments.step]#'
			</cfif>
			group by	ftFieldSet, ftHelpTitle, ftHelpSection
			order by	ftSeq
		</cfquery>
		
		<cfif arguments.step>
			<cfreturn application.rb.getResource("coapi.#getTypeName()#.steps.#arguments.step#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		<cfelse>
			<cfreturn application.rb.getResource("coapi.#getTypeName()#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		</cfif>
	</cffunction>
	
</cfcomponent>