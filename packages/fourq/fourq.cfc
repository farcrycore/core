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

<cfcomponent displayname="FourQ COAPI" bAbstract="true">



	<cffunction name="fourqInit" access="public" returntype="fourq" output="false" hint="Initializes the component instance data">
		<cfif not structKeyExists(variables,'dbFactory')>
			<cfset variables.dbFactory = createObject('component','DBGatewayFactory').init() />
			<cfset variables.gateways = structNew() />
			<cfset variables.tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
			<cfset tableMetadata.parseMetadata(getMetadata(this)) />	
			
			<cfset variables.typename = variables.tableMetadata.getTableName() />
		
		</cfif>
		

		<cfreturn this />
	</cffunction>


	<cffunction name="getView" access="public" output="true" returntype="string" hint="Returns the HTML of a view from the webskin content type folder.">
		<cfargument name="objectid" required="no" type="string" default="" hint="ObjectID of the object that is to be rendered by the webskin view." />
		<cfargument name="template" required="no" type="string" default="" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="webskin" required="no" type="string" default="" hint="Name of the template in the corresponding content type webskin folder, without the .cfm extension." />
		<cfargument name="stparam" required="false" type="struct" default="#structNew()#" hint="Structure of parameters to be passed into the display handler." />
		<cfargument name="stobject" required="no" type="struct" hint="Property structure to render in view.  Overrides any property structure mapped to arguments.objectid. Useful if you want to render a view with a modified content item.">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="OnExit" required="no" type="any" default="">
		<cfargument name="alternateHTML" required="no" type="string" hint="If the webskin template does not exist, if this argument is sent in, its value will be passed back as the result.">
		<cfargument name="hashKey" required="no" default="" type="string" hint="Pass in a key to be used to hash the objectBroker webskin cache">
		<cfargument name="bAjax" required="no" default="0" type="boolean" hint="Flag to determine whether to render an ajax call to load the webskin instead of inline." />
		<cfargument name="ajaxID" required="no" default="" type="string" hint="The id to give the div that will call the ajaxed webskin" />
		<cfargument name="ajaxShowloadIndicator" required="no" default="false" type="boolean" hint="Should the ajax loading indicator be shown" />
		<cfargument name="ajaxindicatorText" required="no" default="loading..." type="string" hint="What should be text of the loading indicator" />		
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
		<cfset var lAttributes = "stobject,typename,objectid,key,template,webskin,stprops,stparam,r_html,r_objectid,hashKey,alternateHTML,OnExit,dsn,bAjax,ajaxID,ajaxShowloadIndicator,ajaxindicatorText,bIgnoreSecurity" />
		<cfset var attrib = "" />
		<cfset var lHashKeys = "" />
		<cfset var iHashKey = "" />
		
		<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
		
		<!--- Initialise webskin trace array --->
		<cfparam name="request.aAncestorWebskinsTrace" default="#arrayNew(1)#" /><!--- To Be Used for Trace Tree --->
		
		<!--- init fourq --->
		<cfset fourqInit() />	
		<cfset webskinTypename = "#variables.typename#" /><!--- Set the typename to the typename of this object instance --->
		
		
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
			<skin:htmlHead library="extjsCore" />
			<skin:htmlHead id="webskinAjaxLoader">
			<cfoutput>		
			<script type="text/javascript">
			function webskinAjaxLoader(divID,action,timeout,showLoadIndicator,indicatorText){
				if (timeout == undefined){var timeout = 30};
				if (showLoadIndicator == undefined){var showLoadIndicator = false};
				if (indicatorText == undefined){var indicatorText = 'loading...'};
				
				var el = Ext.get(divID);
				
				if(el) {
					var mgr = el.getUpdater();
					
					mgr.showLoadIndicator = showLoadIndicator;
					if (showLoadIndicator==true){
						mgr.indicatorText = indicatorText;
					}					
					mgr.update(
					{
						url: action,
						nocache: true,
						scripts: true,
						timeout: timeout						
					});
				}
			}
			</script>
			</cfoutput>
			</skin:htmlHead>
			
			<!--- Get the url for the ajax webskin loader --->
			<cfset urlAjaxLoader = application.fapi.getLink(type="#stobj.typename#", objectid="#stobj.objectid#", urlParameters="view=#arguments.template#&ajaxmode=1") />,
				
			<cfsavecontent variable="stWebskin.webskinHTML">
				<cfoutput>
				<farcry:traceWebskin 
							objectid="#stobj.objectid#" 
							typename="#stobj.typename#" 
							template="#arguments.template#">
				
					<div id="#arguments.ajaxID#"></div>
				
				</farcry:traceWebskin>
				
				<extjs:onReady>
					<cfoutput>
						webskinAjaxLoader('#arguments.ajaxID#', '#urlAjaxLoader#', 30, #arguments.ajaxShowLoadIndicator#, '#arguments.ajaxIndicatorText#');
					</cfoutput>
				</extjs:onReady>
				</cfoutput>
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
				
				<cfif not len(stWebskin.webskinHTML)>			
	
					<cfif stobj.typename EQ "farCoapi">
						<!--- This means its a type webskin and we need to look for the timeout value on the related type. --->			
						<cfset stCoapi = application.fc.factory['farCoapi'].getData(objectid="#stobj.objectid#") />
						<cfset webskinTypename = stCoapi.name />
					</cfif>
					<cfset webskinPath = application.coapi.coapiadmin.getWebskinPath(typename=webskinTypename, template=arguments.template) />
							
					<cfif len(webskinPath)>
	
						<cfset stWebskin.webskinHTML = runView(
															stobj="#stobj#", 
															webskinTypename="#webskinTypename#", 
															webskinTemplate="#arguments.template#", 
															webskinPath="#webskinPath#", 
															webskinCacheID="#stWebskin.webskinCacheID#", 
															hashKey="#arguments.hashKey#", 
															stParam="#arguments.stParam#", 
															OnExit="#arguments.onExit#",
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
		<cfargument name="OnExit" required="false" type="any" default="" />
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<cfargument name="bAllowTrace" required="false" type="boolean" default="true" hint="Sometimes having webskin trace information can break the integrity of a page. This allows you to turn it off." />
		
		<cfset var stCurrentView = structNew() />
		<cfset var webskinHTML = "" />
		<cfset var stTrace = "" />
				
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
		
		<!--- Setup the current request.aAncestorWebskins in case this does not yet exist --->
		<cfif not structKeyExists(request, "aAncestorWebskins")>
			<cfset request.aAncestorWebskins = arrayNew(1) />
		</cfif>	
		
		<!--- Add the current view to the array --->
		<cfset stCurrentView.objectid = arguments.stobj.objectid />
		<cfset stCurrentView.typename = arguments.webskinTypename />
		<cfset stCurrentView.template = arguments.webskinTemplate />
		<cfset stCurrentView.hashKey = arguments.hashKey />
		<cfset stCurrentView.cacheStatus = application.coapi.coapiadmin.getWebskinCacheStatus(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheTimeout = application.coapi.coapiadmin.getWebskinCacheTimeOut(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByURL = application.coapi.coapiadmin.getWebskincacheByURL(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByForm = application.coapi.coapiadmin.getWebskincacheByForm(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByRoles = application.coapi.coapiadmin.getWebskincacheByRoles(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.cacheByVars = application.coapi.coapiadmin.getWebskincacheByVars(typename=arguments.webskinTypename, template=arguments.webskinTemplate) />
		<cfset stCurrentView.lFarcryViewStates = "" />
		<cfset stCurrentView.okToCache = 1 />
		<cfset stCurrentView.inHead = structNew() />
		<cfset stCurrentView.inHead.stCustom = structNew() />
		<cfset stCurrentView.inHead.aCustomIDs = arrayNew(1) />
		<cfset stCurrentView.inHead.stOnReady = structNew() />
		<cfset stCurrentView.inHead.aOnReadyIDs = arrayNew(1) />
		
		<cfset stCurrentView.inHead.stCSSLibraries = structNew() />
		<cfset stCurrentView.inHead.aCSSLibraries = arrayNew(1) />
		
		<cfset arrayAppend(request.aAncestorWebskins, stCurrentView) />					
		
		<!--- Here we are initialising the viewStates. After the call to the webskin, we will know which view states were used  --->
		<cfset request.currentViewTypename = "#stCurrentView.typename#" />
		<cfset request.currentViewTemplate = "#stCurrentView.template#" />
		
		
	
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
	
		
		<!--- If the current view (Last Item In the array) is still OkToCache --->
		<cfif request.aAncestorWebskins[arrayLen(request.aAncestorWebskins)].okToCache>
			<!--- Add the webskin to the object broker if required --->
			<cfset bAdded = application.fc.lib.objectbroker.addWebskin(objectid=arguments.stobj.objectid, typename=arguments.stobj.typename, template=arguments.webskinTemplate, webskinCacheID=arguments.webskinCacheID, html=webskinHTML, stCurrentView=stCurrentView) />
		</cfif>
		
		<cfif arrayLen(request.aAncestorWebskins)>
			
			<cfset oWebskinAncestor = createObject("component", application.stcoapi.dmWebskinAncestor.packagePath) />						
			
			<!--- 
			Loop through ancestors to determine whether to add to dmWebskinAncestor Table
			Only webskins that are cached are added to the table.
			 --->
			<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
				
				<!--- Add the ancestor records so we know where this webskin is located throughout the site. --->
				<cfif not structkeyexists(request.aAncestorWebskins[i],"objectid") or arguments.stobj.objectid NEQ request.aAncestorWebskins[i].objectID>
					
					<cfif structKeyExists(application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins, request.aAncestorWebskins[i].template)>
						<cfif application.stcoapi[request.aAncestorWebskins[i].typename].stWebskins[request.aAncestorWebskins[i].template].cacheStatus GT 0>
							
							<cfset stArgs = structnew() />
	
							<cfset stArgs.webskinObjectID = arguments.stobj.objectid />
							<cfif structkeyexists(request.aAncestorWebskins[i],"objectid")>
								<cfset stArgs.ancestorID = request.aAncestorWebskins[i].objectID />
							<cfelse>
								<cfset stArgs.ancestorTypename = request.aAncestorWebskins[i].typename />
							</cfif>
							<cfset stArgs.ancestorTemplate = request.aAncestorWebskins[i].template />
							<cfset bAncestorExists = oWebskinAncestor.checkAncestorExists(argumentCollection=stArgs) />
								
							<cfif not bAncestorExists>
								<cfset stProperties = structNew() />
								<cfset stProperties.webskinObjectID = arguments.stobj.objectid />
								<cfset stProperties.webskinTypename = arguments.stobj.typename />
								<cfset stProperties.webskinTemplate = arguments.webskinTemplate />
								<cfif structkeyexists(request.aAncestorWebskins[i],"objectid")>
									<cfset stProperties.ancestorID = request.aAncestorWebskins[i].objectID />
								</cfif>
								<cfset stProperties.ancestorTypename = request.aAncestorWebskins[i].typename />
								<cfset stProperties.ancestorTemplate = request.aAncestorWebskins[i].template />
								
								<cfset stResult = oWebskinAncestor.createData(stProperties=stProperties) />
							</cfif>
						</cfif>
					</cfif>
				</cfif>
				
				<!--- If this webskin is to never cache, make sure all ancestors also never cache --->
				<cfif stCurrentView.cacheStatus EQ -1>
					<cfset request.aAncestorWebskins[i].okToCache = 0 />
				</cfif>
				
				<!--- If the timeout of this webskin is less than its parents, reset the parents timeout so timeout propogates upwards --->
				<cfif stCurrentView.cacheTimeout LT request.aAncestorWebskins[i].cacheTimeout>
					<cfset request.aAncestorWebskins[i].cacheTimeout = stCurrentView.cacheTimeout />
				</cfif>
				
				<!--- If this webskin is to have its url hashed, make sure all ancestors also have their webskins hashed --->
				<cfif stCurrentView.cacheByURL>
					<cfset request.aAncestorWebskins[i].cacheByURL = true />
				</cfif>
				<cfif stCurrentView.cacheByForm>
					<cfset request.aAncestorWebskins[i].cacheByForm = true />
				</cfif>
				<cfif stCurrentView.cacheByRoles>
					<cfset request.aAncestorWebskins[i].cacheByRoles = true />
				</cfif>
				
				<cfif listLen(stCurrentView.cacheByVars)>
					<cfloop list="#stCurrentView.cacheByVars#" index="iViewState">
						<cfif not listFindNoCase(request.aAncestorWebskins[i].cacheByVars,iViewState)>
							<cfset request.aAncestorWebskins[i].cacheByVars = listAppend(request.aAncestorWebskins[i].cacheByVars, iViewState)	/>
						</cfif>								
					</cfloop>
				</cfif>
	
			</cfloop>
		</cfif>
		
		<!--- Remove the current view (last item in the array) from the Ancestor Webskins array --->
		<cfset ArrayDeleteAt(request.aAncestorWebskins, arrayLen(request.aAncestorWebskins)) />
	
		<cfreturn webskinHTML />
	
	</cffunction>

	<cffunction name="getNavID" access="public" output="false" returntype="string" hint="Returns the default Navigation objectID for the objectID passed in. Empty if it cant find anything applicable.">
		<cfargument name="objectid" required="no" type="string" default="" hint="The objectid for which the navigation objectid is to be found." />
		<cfargument name="typename" required="no" type="string" default="" hint="The typename of the object for which the navigation objectid is to be found." />
		<cfargument name="stObject" required="no" type="struct" default="#structNew()#"  hint="The object for which the navigation objectid is to be found." />
		
		<cfset var stNav = structNew() />
		<cfset var navID = "" />	
		
		<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />

		<cfif len(arguments.objectid)>
			<cfif not len(arguments.typename)>
				<cfset arguments.typename = application.coapi.utilities.findType(objectid="#arguments.objectid#") />
			</cfif>
			<cfif structIsEmpty(arguments.stObject)>
				<cfset arguments.stObject = createObject("component", application.stcoapi["#arguments.typename#"].packagePath).getData(objectid="#arguments.objectid#") />
			</cfif>
		</cfif>
	
		
		<cfif structkeyexists(url, "navid")>		
			<!--- ie. this is a dynamic object looking for context, passing nav on the URL --->
			<cfset navID = url.navid />
		
		<cfelseif structkeyexists(url, "navAlias") AND structKeyExists(application.navid, "#url.navAlias#")>		
			<!--- ie. this is a dynamic object looking for context, passing nav on the URL --->
			<cfset navID = listFirst(application.navid["#url.navAlias#"]) />
		
		</cfif>
		
		<!--- If we still havnt found the navid and we actually have an object --->
		<cfif NOT len(navID) AND structKeyExists(arguments.stObject, "typename")>
			<cfif arguments.stObject.typename eq "dmNavigation">
				<!--- Use the navigation objectid if its a navigation object --->
				<cfset navID = arguments.stObject.objectid />
	
			<cfelseif structKeyExists(application.stCoapi["#arguments.stObject.typename#"], "bUseInTree") AND application.stCoapi["#arguments.stObject.typename#"].bUseInTree>
			
				<nj:getNavigation objectId="#arguments.stObject.objectId#" r_stobject="stNav" />
				
				<!--- if the object is in the tree this will give us the node --->
				<cfif isStruct(stNav) and structKeyExists(stNav, "objectid") AND len(stNav.objectid)>
					<cfset navID = stNav.objectID>
				</cfif>
			</cfif>
		</cfif>

		<cfif structKeyExists(arguments.stObject, "typename")>
			<cfset arguments.typename = arguments.stObject.typename />
		</cfif>
		<!--- If we still havnt found the navID, see if we can find a nav alias matching the typename --->
		<cfif not len(navID) and len(arguments.typename)>
			<cfif structKeyExists(application.navid, "#arguments.typename#")>
				<cfset navID = listFirst(application.navid["#arguments.typename#"]) />
			</cfif>
		</cfif>
		
		<cfreturn navID />
	
	</cffunction>
  

  	<cffunction name="getDefaultObject" access="public" output="true" returntype="struct">
		<cfargument name="ObjectID" required="false" type="UUID">
		<cfargument name="typename" required="yes" type="string" default="#getTablename()#">	
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	   	<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
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
	
	
	
	<cffunction name="getGateway" access="private" output="false" returntype="farcry.core.packages.fourq.gateway.DBGateway" hint="Gets the gateway for the given db connection parameters">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		
		<cfif not structKeyExists(variables.gateways,arguments.dsn)>
			<cfset variables.gateways[arguments.dsn] = variables.dbFactory.getGateway(arguments.dsn,arguments.dbowner,arguments.dbtype) />
		</cfif>
		
		<cfreturn variables.gateways[arguments.dsn] />
	</cffunction>
	

	
	<!---
	 ************************************************************
	 *                                                          *
	 *                DEPLOYMENT METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
 
 
 	<cffunction name="deployType" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
    	<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="bDeployCoapiRecord" type="boolean" required="false" default="true">
    
    	<cfset var stResult = structNew()>
		<cfset var gateway = "" />
		<cfset var stClass = "" />
    
    	<cfset fourqInit() />
    
		<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		<cfset stResult = gateway.deployType(variables.tableMetaData,arguments.bDropTable,arguments.bTestRun) />
		
		<cfif stResult.bSuccess AND bDeployCoapiRecord>
			<!--- MAKE SURE THAT THE farCOAPI record exists for this type. --->
			<cfset stClass = createObject("component", application.stcoapi.farCoapi.packagepath).getCoapiObject(name="#variables.typename#") />
		</cfif>
		
		<cfreturn stResult>
	</cffunction>
	
 	<cffunction name="isDeployed" access="public" returntype="boolean" output="false" hint="Returns True if the table is already deployed">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
    	<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
    
    	<cfset var stLocal = structNew()>
    
    	<cfset fourqInit() />
    
		<cfset stLocal.gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		<cfset stLocal.bDeployed = stLocal.gateway.isDeployed(metadata=variables.tableMetaData, dsn=arguments.dsn, dbowner=arguments.dbowner) />
		
		<cfreturn stLocal.bDeployed>
	</cffunction>
	

 	<cffunction name="deployRefObjects" access="public" returntype="struct" output="false">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stResult = structNew()>
		<cfset var gateway = "" />
     
	    <cfset fourqInit() />
	    
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner)  />
		
		<cfset stResult = gateway.deployRefObjects(arguments.bDropTable) />
		
		<cfreturn stResult>
	</cffunction>

 	<cffunction name="deployArrayTable" access="public" returntype="struct" output="false">
		<cfargument name="bDropTable" type="boolean" required="false" default="false">
		<cfargument name="bTestRun" type="boolean" required="false" default="true">
		<cfargument name="parent" type="string" required="true">
		<cfargument name="property" type="string" required="true">
		<cfargument name="datatype" type="string" required="false" default="String">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var stResult = structNew()>
		<cfset var gateway = "" />
	    <cfset var fields = "" />
		<cfset var md = structNew() />
	
	    <cfset fourqInit() />
	    
	    <cfset md = getMetaData()>
	    
	    <cfset fields = variables.tableMetaData.getTableDefinition() />
	    
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		
		<cfset stResult = gateway.deployArrayTable(fields[arguments.property].fields,variables.tableMetaData.getTablename()&"_"&arguments.property,arguments.bDropTable,arguments.bTestRun) />
		
		<cfreturn stResult>
	</cffunction>


	<!---
	 ************************************************************
	 *                                                          *
	 *                     CRUD METHODS                         *
	 *                                                          *
	 ************************************************************
	 --->
 
	<cffunction name="createData" access="public" output="true" returntype="struct" hint="Create an object including array properties.  Pass in a structure of property values; arrays should be passed as an array. The objectID can be ommitted and one will be created, passed in as an argument or passed in as a key of stProperties argument.">
		<cfargument name="stProperties" type="struct" required="true">
		<cfargument name="objectid" type="UUID" required="false" default="#application.fc.utils.createJavaUUID()#">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">

    	<cfset var gateway = "" />
		<cfset var stReturn = StructNew()>
    	<cfset fourqInit() />
    	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		<cfset stReturn = gateway.createData(stProperties,objectid,variables.tableMetadata)>
		<cfif NOT stReturn.bSuccess>
			<cflog text="#stReturn.message# #stReturn.detail# [SQL: #stReturn.sql#]" file="coapi" type="error" application="yes">
		</cfif>
    	<cfreturn  stReturn />
	</cffunction>


	<cffunction name="getData" access="public" output="true" returntype="struct" hint="Get data for a specific objectid and return as a structure, including array properties and typename.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
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
				
		<!--- init fourq --->
		<cfset fourqInit() />	
		
		
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
			<cfif arguments.bUseInstanceCache AND NOT arguments.bArraysAsStructs>
				<!--- Attempt to get the object from the ObjectBroker --->
				<!--- getFromObjectBroker returns an empty struct if the object is not in the broker --->
				<cfset stobj = application.fc.lib.objectbroker.getFromObjectBroker(ObjectID=arguments.objectid,typename=variables.typename)>
			</cfif>

			<cfif structisEmpty(stObj)>
				
				<cflock name="LockData_#arguments.objectid#" timeout="10" throwontimeout="true">
					<!--- Didn't find the object in the objectBroker --->
					<!--- build a local instance cache --->
					<cfinclude template="_fourq/getData.cfm">	
				</cflock>
				
				<!--- MJB TODO: This piece of code needs to be added somewhere to allow the access to any field that has been run through the relevent display function of its formtool cfc  --->
				<!--- 
				<cfset stobjDisplay = structNew() />
				<cfif structKeyExists(application.stcoapi, stobj.typename)>
					
					<cfif structKeyExists(application.stcoapi[stobj.typename], "stMethods") AND structKeyExists(application.stcoapi[stobj.typename].stMethods, "getField")>						
						<cfloop list="#structKeyList(stobj)#" index="fieldname">
							<cfif NOT listFindNoCase("ftDisplayFields,typename",fieldname)>
								
								<cfset oType = createObject("component", application.stcoapi[stobj.typename].packagePath) />
								<cfset stobjDisplay[fieldname] = oType.getField(stobject=stobj, fieldname=fieldname) />
							</cfif>
						</cfloop>
					<cfelse>
						<cfloop list="#structKeyList(stobj)#" index="fieldname">
							<cfif NOT listFindNoCase("ftDisplayFields,typename",fieldname)>
								<cfset stobjDisplay[fieldname] = stobj[fieldname] />
							</cfif>
						</cfloop>		
					</cfif>	
					
								
				</cfif> --->
			
				
				<!--- <cftrace type="information" category="coapi" var="stobj.typename" text="getData() used database."> --->
			
				<!--- Attempt to add the object to the broker --->
				<cfif NOT arguments.bArraysAsStructs AND NOT arguments.bShallow>
					<cfset addedtoBroker = application.fc.lib.objectbroker.AddToObjectBroker(stobj=stobj,typename=variables.typename)>
	
					
					<!--- <cfif addedToBroker> --->
						<!--- Successfully added object to the broker --->
						<!--- <cftrace type="information" category="coapi" var="arguments.objectid" text="getData() added object to Broker.">
					</cfif>
					 --->
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
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		<cfargument name="bSessionOnly" type="string" required="false" default="false">
		
	    <cfset var stResult = StructNew() />
	    <cfset var gateway = "" />
	    <cfset var stDefaultProperties = "" />
	    <cfset var lockName = "SetData" />

	    
	    <cfset fourqInit() />
	    <cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
	    	    
		
		<!--- Make sure that the temporary object store exists in the session scope. --->
		<cfparam name="Session.TempObjectStore" default="#structNew()#" />

		
		<!--- 
		NAMED LOCK
		Set data does a get then set to make sure the entire object is correctly populated. 
		Simultaneous sets under load may lead to conditions where objects are not correctly updated. 
		setdata() uses this named lock (named by objectid) to ensure internal processing within setdata() is sequential rather than parallel.
		 --->
		<cfif structkeyexists(stProperties, "objectid")>
			<cfset lockName = "LockData_#stProperties.objectid#" />
		<cfelse>
			<cfset lockName = "LockData_#application.fc.utils.createJavaUUID()#">
		</cfif>
		
		<cflock name="#lockName#" timeout="10" throwontimeout="true">
		
			
			<!--------------------------------------- 
			If the object is to be stored in the session scope only.
			----------------------------------------->		
			<cfif arguments.bSessionOnly>
			
				<!--- Make sure an object id exists. --->
				<cfparam name="stProperties.ObjectID" default="#application.fc.utils.createJavaUUID()#" />				
				
				<!--- Get the default properties for this object --->
				<cfset stDefaultProperties = this.getData(objectid=arguments.stProperties.ObjectID,typename=variables.typename) />
			  	
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
			    <cfif structkeyexists(stProperties, "objectid")>
				    <cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs=arguments.stProperties.ObjectID,typename=variables.typename)>
			    </cfif>	    
		   		
		   		<cfset stResult = gateway.setData(stProperties=arguments.stProperties,metadata=variables.tableMetadata,dsn=arguments.dsn) />	   	
		   	 
		    
			   	<!--- Make sure we remove the object from the TempObjectStore if we update something --->
		   		<cfif structKeyExists(session, "TempObjectStore") AND structKeyExists(Session.TempObjectStore,arguments.stProperties.ObjectID)>
			   		<cfset structdelete(Session.TempObjectStore, arguments.stProperties.ObjectID) />
			   	</cfif>
			   		   	 
		   	</cfif>		   	
	   	</cflock>
	   	
		<cfreturn stResult />
		
	</cffunction>
		
	<cffunction name="deleteData" access="public" output="false" returntype="struct" hint="Delete the specified objectid and corresponding data, including array properties and refObjects.">
		<cfargument name="objectid" type="uuid" required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
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
	    <cfset application.fc.lib.objectbroker.RemoveFromObjectBroker(lObjectIDs=arguments.ObjectID,typename=variables.typename)>
	    
		<cfinclude template="_fourq/deleteData.cfm">
		
		
		<cfreturn stResult>
	</cffunction>
	
	
	
	
	<!---
	 ************************************************************
	 *                                                          *
	 *             NON CRUD DB ACCESS METHODS                   *
	 *                                                          *
	 ************************************************************
	 --->
	
	
		
	<cffunction name="getMultiple" access="public" hint="Get multpile objects of a particular type" ouput="false" returntype="struct">
		<cfargument name="dsn" type="string" required="yes" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="asc" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false" default="">
		
		<cfset var tn = getTableName()>
		<cfset var stProps = getPropsAsStruct()>
		<cfset var gateway = "" />
		<cfset fourqInit() />
		
  	  	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		<cftrace inline="false" type="warning" text="The use of getMultiple is not encouraged. This method will probably be deprecated in future revisions of farcry. It is recommended to use getMultipleByQuery instead">
		<cfreturn gateway.getMultiple(tn,stProps,arguments.lObjectIDs,arguments.orderBy,arguments.sortOrder,arguments.conditions,arguments.whereClause) />
		
	</cffunction>
	
	<cffunction name="getMultipleByQuery" access="public" hint="Get multpile records of a paticular type" ouput="false" returntype="query">
		<cfargument name="dsn" type="string" required="yes" default="#application.dsn#">
		<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		<cfargument name="lObjectIDs" type="string" required="false" default="" hint="Restrict resultset to a comma delimited list of objectids.">
		<cfargument name="OrderBy" type="string" required="false" default="" hint="Comma delimited list of properties to order by. Known issue: method returns a struct which randomises sort order :(">
		<cfargument name="SortOrder" type="string" required="false" default="" hint="asc or desc options.">
		<cfargument name="conditions" type="struct" required="false" default="#structNew()#" hint="Query filter; pass in structure keyed by property and with a value equal to the desired filter.">
		<cfargument name="whereclause" type="string" required="false" default="">
		<cfargument name ="maxRows" required="false" type="numeric" default="-1">
		
		<cfset var tn = getTableName()>
		<cfset var stProps = getPropsAsStruct()>
		<cfset var gateway = "" />
		<cfset fourqInit() />
		
    	<cfset gateway = getGateway(arguments.dsn,arguments.dbtype,arguments.dbowner) />
		
		<cfreturn gateway.getMultipleByQuery(tn,stProps,arguments.lObjectIDs,arguments.orderBy,arguments.sortOrder,arguments.conditions,arguments.whereClause,arguments.maxRows) />
		
	</cffunction>
	

	
	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID.">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var result = application.coapi.coapiUtilities.findType(argumentCollection=arguments) />

		<cfreturn result />
	</cffunction>
	
	
	<cffunction name="setMultiple" access="public" hint="Set a single property for multpile objects of a particular type" ouput="false" returntype="boolean">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="dbowner" type="string" required="yes">
		<cfargument name="prop" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="whereclause" type="string" required="false" default="WHERE 0=1">
		
		<cfset var tn = this.getTableName()>
		<cfset var stProps = this.getPropsAsStruct()>
		<cfset var gateway = "" />
		
		<cftrace inline="false" type="warning" text="The use of setMultiple is not encouraged. This method will probably be deprecated in future revisions of farcry.">
		
		<cfset fourqInit() />
		<cfset gateway = getGateway(arguments.dsn,application.dbtype,applicaiton.dbowner) />
		
		<cfset gateway.setMultiple(tn,stProps,arguments.prop,arguments.value,arguments.whereClause) />
		
		<cfreturn true>
	</cffunction>
	
	
	
	
	<!---
	 ************************************************************
	 *                                                          *
	 *                  METADATA METHODS                        *
	 *                                                          *
	 ************************************************************
	 --->
	
	

	<cffunction name="getTablename" access="public" returntype="string" output="false">
		
		<cfset fourqInit() />
    
		<cfreturn variables.tableMetadata.getTableName() />
		
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="array" output="false">
		<!--- 
		we need to get an array of all the properties for this instance 
		*including* inherited properties that have not been overloaded
		20020518 GB
		 --->
		 <cfset var stExtends = structNew()>		 
		<cfset var md=getMetaData(this)>
		<!--- container for processed propertynames --->
		<cfset var lPropsProcessed = "">
		<cfset var aProps = ArrayNew(1)>
		<cfset var prop = "">
		<cfset var thisprop = "">
		
		<cftrace inline="false" type="warning" text="The getProperties() method in fourq is deprecated. Use variables.tableMetadata.getTableDefinition() instead.">
		
		<!--- build props for object type. Note that its possible that a component doesn't have any properties PH--->
		<cfif structKeyExists(md,"properties")>
			<cfloop from=1 to="#arraylen(md.properties)#" index="prop">
				<cfset thisprop = md.properties[prop]>
				<cfset ArrayAppend(aProps, md.properties[prop])>
				<cfset lPropsProcessed = ListAppend(lPropsProcessed, thisprop.name)>
			</cfloop>
		</cfif>
			
		<cfscript>
			finished = false;
			if(isStruct(md.extends))
				stExtends = md.extends;
			else
				stExtends = structNew();	
			while(NOT finished)
			{								
				if (structKeyExists(stExtends,'properties'))
				{					
					for (prop = 1;prop LTE arraylen(stExtends.properties);prop=prop+1)
					{
						thisprop = stExtends.properties[prop];
						// check for overloading 
						if (NOT ListFindNoCase(lPropsProcessed, thisprop.name))
						{
							  ArrayAppend(aProps, stExtends.properties[prop]);
							  ListAppend(lPropsProcessed, thisprop.name);
						}
						
					}
					
				}
				if (structKeyExists(stExtends,'extends') AND NOT structIsEmpty(stExtends.extends))
				{			
					
					stExtends = stExtends.extends;
				}
				else
				{
					finished=true;
				}	
			}
		</cfscript>
		
		<cfreturn aProps />
	</cffunction>
	
	<!--- private functions --->
	<cffunction name="getAncestors" hint="Get all the extended components as an array of isolated component metadata." returntype="array" access="private" output="false">
		<cfargument name="md" required="Yes" type="struct">
			<cfset var aAncestors = arrayNew(1)>
			<cfscript>	
				if (structKeyExists(md, 'extends'))
					aAncestors = getAncestors(md.extends);
				arrayAppend(aAncestors, md);
			</cfscript>
		<cfreturn aAncestors>
	</cffunction>

	<cffunction name="getMethods" access="public" hint="Get a structure of all methods, including extended, for this component" returntype="struct" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var methods = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curMethod = "">
		
		<cfscript>
		for ( i=1; i lte ArrayLen(aAncestors); i=i+1 ) {
			curAncestor = aAncestors[i] ;
			
			if ( StructKeyExists( curAncestor, 'functions' ) )
				for ( j=1; j lte ArrayLen( curAncestor.functions ); j=j+1 ) {
					curMethod = StructNew() ;
					curMethod.metadata = curAncestor.functions[j] ;
					curMethod.Origin = curAncestor.name ;
					if ( i eq ArrayLen(aAncestors)
					// don't exclude any method 1)from this
						or not StructKeyExists( curMethod.metadata, 'access' )
					// 2)that does not have 'access' attribute
						or curMethod.metadata.access neq 'private' ) {
					// 3)that does not have access='private'
						methods[curmethod.metadata.name] = curMethod ;
					}
				}
		
		}
		</cfscript>
		<cfreturn methods>
	</cffunction>
	
	<cffunction name="getPropsAsStruct" returntype="struct" hint="Get all extended properties and return as a flattened structure." access="public" output="false">
		<cfset var aAncestors = getAncestors(getMetaData(this))>
		<cfset var stProperties = StructNew()>
		<cfset var curAncestor = "">
		<cfset var curProperty = "">
		<cfset var i = "">
		<cfset var j = "">
		<cfset var prop = "">
		<cfset var success = "">
		
		<cfloop index="i" from="1" to="#ArrayLen(aAncestors)#">
			<cfset curAncestor = duplicate(aAncestors[i])>
			
			<cfif StructKeyExists(curAncestor,"properties")>
				<cfloop index="j" from="1" to="#ArrayLen(curAncestor.properties)#">
					<cfif not structKeyExists(stProperties, curAncestor.properties[j].name)>
						<cfset stProperties[curAncestor.properties[j].name] = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].metadata = structNew() />
						<cfset stProperties[curAncestor.properties[j].name].origin = "" />
					</cfif>
					<cfset stProperties[curAncestor.properties[j].name].origin = curAncestor.name />
					<cfset success = structAppend(stProperties[curAncestor.properties[j].name].metadata, curAncestor.properties[j]) />
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop collection="#stProperties#" item="prop">
			<!--- make sure all metadata has a default and required --->
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"required")>
				<cfset stProperties[prop].metadata.required = "no">
			</cfif>
			
			<cfif NOT StructKeyExists(stProperties[prop].metadata,"default")>
				<cfset stProperties[prop].metadata.default = "">
			</cfif>
		</cfloop>

		<cfreturn stProperties>
	</cffunction>
	
	<cffunction name="mergeWebskins" access="private" hint="Merge webskin result queries, skipping duplicates. Non destructive." output="false" returntype="query">
		<cfargument name="query1" type="query" required="true" />
		<cfargument name="query2" type="query" required="true" />
		
		<cfset var qDupe = "" />
		<cfset var qResult = duplicate(arguments.query1)>

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
		
		<cfloop collection="#stResult#" item="prop">
			<cfloop list="#arguments.lAttributes#" index="att">
				<cfif not structkeyexists(stResult[prop].metadata,att)>
					<cfif structkeyexists(arguments,"default")>
						<cfset stResult[prop].metadata[att] = arguments.default />
					<cfelseif prop eq "ftType">
						<cfset stResult[prop].metadata[att] = stResult[prop].metadata.type />
					<cfelseif prop eq "ftLabel">
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
	
		<cfset var stReturnMetadata = arguments.stMetaData />
		<cfset var stNewProps = getPropsAsStruct() />
		<cfset var md = getMetaData(this) />		
		<cfset var componentname = getTablename() />
		<cfset var key="" />
		<cfset var i=0 />
		<cfset var j=0 />
		<cfset var k=0 />		
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
		<cfset var mdExtend = structnew() />
		
		<!--- If we are updating a type that already exists then we need to update only the metadata that has changed. --->
		<cfparam name="stReturnMetadata.stProps" default="#structnew()#" />
		<cfset stReturnMetadata.stProps = application.factory.oUtils.structMerge(stReturnMetadata.stProps,stNewProps) />

		<!--- Make sure ALL properties have an ftType, ftLabel,ftStyle and ftClass set. If not explicitly set then use defaults. --->
		<cfset stReturnMetadata.stProps = paramMetaData(stReturnMetadata.stProps,"ftType,ftLabel,ftStyle,ftClass,ftValidation") />

		<!--- This will get the components methods and any methods that are from super cfc's --->
		<cfset stReturnMetadata.stMethods = getMethods()>	
		
		<!--- add any extended component metadata --->
		<cfset mdExtend = md />
		<cfloop condition="not structisempty(mdExtend)">
			<cfloop collection="#md#" item="key">
				<cfif key neq "PROPERTIES" AND key neq "EXTENDS" AND key neq "FUNCTIONS" AND key neq "TYPE">
					<cfparam name="stReturnMetadata.#key#" default="#md[key]#" />				
				</cfif>
			</cfloop>
			<cfif structkeyexists(mdExtend,"extends") and not findnocase(mdExtend.extends.name,"fourq")>
				<cfset mdExtend = mdExtend.extends />
			<cfelse>
				<cfset mdExtend = structnew() />
			</cfif>
		</cfloop>
		
		<!--- Param component metadata --->
		<cfparam name="stReturnMetadata.displayname" default="#listlast(stReturnMetadata.name,'.')#" />
		
		<!--- This sets up the array which will contain the name of all types this type extends --->
		<cfset stReturnMetadata.aExtends = application.coapi.coapiadmin.getExtendedTypeArray(packagePath=md.name)>
		
		<!--- Set up default attributes --->
		<cfparam name="stReturnMetadata.bAutoSetLabel" default="true" />
		<cfparam name="stReturnMetadata.bObjectBroker" default="false" />
		<cfparam name="stReturnMetadata.lObjectBrokerWebskins" default="" />
		<cfparam name="stReturnMetadata.objectBrokerWebskinCacheTimeout" default="1400" /> <!--- This a value in minutes (ie. 1 day) --->
 		<cfparam name="stReturnMetadata.excludeWebskins" default="" /> <!--- This enables projects to exclude webskins that may be contained in plugins. ---> 
 		<cfparam name="stReturnMetadata.fuAlias" default="#stReturnMetadata.displayname#" /> <!--- This will store the alias of the typename that can be used by Friendly URLS ---> 

		<!--- Get webkins: webskins for this type, then webskins for extends types --->
		<cfset stReturnMetadata.qWebskins = application.coapi.coapiAdmin.getWebskins(typename="#componentname#", bForceRefresh="true", excludeWebskins="#stReturnMetadata.excludeWebskins#",packagepath=stReturnMetadata.packagepath,aExtends=stReturnMetadata.aExtends) />

		<!--- Setup a struct to store all the webskins --->
		<cfset stReturnMetadata.stWebskins = structNew() />
		<cfloop query="stReturnMetadata.qWebskins">
			<cfset stReturnMetadata.stWebskins[stReturnMetadata.qWebskins.METHODNAME[currentRow]] = structNew() />
			<cfloop list="#stReturnMetadata.qWebskins.columnList#" index="ixCol">
				<cfset stReturnMetadata.stWebskins[stReturnMetadata.qWebskins.METHODNAME[currentRow]][ixCol] = stReturnMetadata.qWebskins[ixCol][currentRow] />
			</cfloop>
		</cfloop>
		
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
	
	<cffunction name="createArrayTableData" access="public" returntype="array" output="true" hint="Inserts the array table data for the given property data and returns the Array Table data as a list of objectids">
	    <cfargument name="tableName" type="string" required="true" />
	    <cfargument name="objectid" type="uuid" required="true" />
	    <cfargument name="tabledef" type="struct" required="true" />
	    <cfargument name="aProps" type="array" required="true" />
	
		<cfset var gateway =  "" />
		<cfset var stResult =  structNew() />
		
    	<cfset fourqInit() />
    
		<cfset gateway = getGateway()  />
		<cfset stResult = gateway.createArrayTableData(arguments.tablename,arguments.objectid,arguments.tabledef,arguments.aProps) />
		
		<cfreturn stResult>
	</cffunction>

	<cffunction name="getI18Property" access="public" output="false" returntype="string" hint="Provides access to I18 values for properties">
		<cfargument name="property" type="string" required="true" hint="The property being queried" default="" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />

		<cfset var meta = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfif len(application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"])>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"]#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["ftLabel"]) />
				<cfelse>
					<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#",application.stCOAPI[variables.typename].stProps[arguments.property].metadata["name"]) />
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.properties.#arguments.property#@#arguments.value#","") />
	</cffunction>

	<cffunction name="getI18Step" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="true" hint="The step being queried" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

		<cfswitch expression="#arguments.value#">
			<cfcase value="label">
				<cfset prop = "ftWizardStep" />
			</cfcase>
		</cfswitch>
		
		<cfquery dbtype="query" name="qSteps">
			select		ftWizardStep
			from		application.stCOAPI.#variables.typename#.qMetadata
			where		ftWizardStep <> '#variables.typename#'
			group by 	ftWizardStep
			order by	ftSeq
		</cfquery>
		
		<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#@#arguments.value#",qSteps[prop][arguments.step]) />
	</cffunction>

	<cffunction name="getI18Fieldset" access="public" output="false" returntype="string" hint="Provides access to I18 values for labels etc">
		<cfargument name="step" type="numeric" required="false" hint="The step being queried" default="0" />
		<cfargument name="fieldset" type="numeric" required="true" hint="The fieldset being queried" default="0" />
		<cfargument name="value" type="string" required="false" hint="The value required i.e. label, helptitle, helpsection" default="label" />
		
		<cfset var qSteps = "" />
		<cfset var qFieldsets = "" />
		<cfset var prop = arguments.value />

		<cfset fourqInit() />

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
				from		application.stCOAPI.#variables.typename#.qMetadata
				where		ftWizardStep <> '#variables.typename#'
				group by 	ftWizardStep
				order by	ftSeq
			</cfquery>
		</cfif>
		
		<cfquery dbtype="query" name="qFieldsets">
			select		ftFieldset, ftHelpTitle, ftHelpSection
			from		application.stCOAPI.#variables.typename#.qMetadata
			<cfif arguments.step>
				where		ftWizardStep = '#qSteps.ftWizardStep[arguments.step]#'
			</cfif>
			group by	ftFieldSet, ftHelpTitle, ftHelpSection
			order by	ftSeq
		</cfquery>
		
		<cfif arguments.step>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.steps.#arguments.step#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		<cfelse>
			<cfreturn application.rb.getResource("coapi.#variables.typename#.fieldsets.#arguments.fieldset#@#arguments.value#",qFieldsets[prop][arguments.fieldset]) />
		</cfif>
	</cffunction>
	
</cfcomponent>
