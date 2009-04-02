<cfcomponent displayname="FarCry API" hint="The API for all things FarCry" output="false" bDocument="true" scopelocation="application.fapi">

	<cffunction name="init" access="public" returntype="fapi" output="false" hint="FAPI Constructor">
		
		<!--- INITIALISE GLOBAL OBJECTS --->
		<cfset variables.oObjectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker") />
		
		<cfreturn this />
	</cffunction>
	
	<!--- COAPI --->
		<cffunction name="findType" access="public" output="false" returntype="string" hint="Returns the typename for an objectID. Returns empty string if objectid is not found.">
			<cfargument name="objectid" required="true" />
			
			<cfreturn application.coapi.coapiUtilities.findType(argumentCollection=arguments) />
		</cffunction>
		
		<cffunction name="getContentType" access="public" output="false" returntype="any" hint="Returns the an instantiated content type" bDocument="true">
			<cfargument name="typename" type="string" required="true" />
			
			<cfset var oResult = "" />
			
			<cfif structKeyExists(application.stCoapi, arguments.typename)>
				<cfset oResult = createObject("component", application.stcoapi["#arguments.typename#"].packagePath) />
			<cfelse>
				<cfset message = getResource("FAPI.messages.contentTypeNotFound@text", "The content type [{1}] is not available","", array(arguments.typename)) />
				<cfthrow message="#message#" />
			</cfif>		
	
			<cfreturn oResult />
		</cffunction>
		
		<cffunction name="getContentObject" access="public" output="false" returnType="struct" hint="Allows you to fetch a content object with only the objectID">
			<cfargument name="objectid" type="UUID" required="true" hint="The objectid for which object is to be found" />
			<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
			
			<cfreturn application.coapi.coapiutilities.getContentObject(argumentCollection="#arguments#") />
		</cffunction>
		
		<cffunction name="setData" access="public" output="false" returnType="struct" hint="Allows you to run setData() on a type for an objectID">
			<cfargument name="objectid" type="string" required="false" default="" hint="The objectid for which object is to be set" />
			<cfargument name="typename" type="string" required="false" default="" hint="The typename of the objectid. Pass in to avoid having to lookup the type." />
	
			<cfargument name="stProperties" required="false" default="#structNew()#">
			<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
			<cfargument name="dbtype" type="string" required="false" default="#application.dbtype#">
			<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
			<cfargument name="bSessionOnly" type="string" required="false" default="false">
			
			<cfset var o = "" />
			<cfset var lReserved = "objectid,typename,stProperties,dsn,dbtype,dbowner,bSessionOnly" />
		
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
			
			<cfreturn o.setData(stProperties=arguments.stProperties,dsn=arguments.dsn,dbtype=arguments.dbtype,dbowner=arguments.dbowner,bSessionOnly=arguments.bSessionOnly) />
		</cffunction>
	
		<cffunction name="setCacheByVar" access="public" returntype="void" output="false" hint="This is generally used by tags to dynamically assign cacheByVar's to the webskin that called it and its ancestors.">
			<cfargument name="keys" required="true" hint="This is a list of setCacheVar names to be dynamically assigned." />
			
			<cfset var i = "" />
			<cfset var currentTypename = "" />
			<cfset var currentTemplate = "" />
			<cfset var currentCacheStatus = "" />
			<cfset var currentViewStates = "" />
			<cfset var iKeys = "" />
		
			<!--- LOOP THROUGH ALL THE CURRENT ANCESTOR WEBSKINS AND ADD THE CURRENT VIEW STATE KEY TO EACH --->
			<cfif structKeyExists(request, "aAncestorWebskins") AND arrayLen(request.aAncestorWebskins)>
				<cfloop from="1" to="#arrayLen(request.aAncestorWebskins)#" index="i">
	
					<cfloop list="#arguments.keys#" index="iKey">	
						<cfif not listFindNoCase(request.aAncestorWebskins[i].cacheByVars,iKey)>
							<cfset request.aAncestorWebskins[i].cacheByVars = listAppend(request.aAncestorWebskins[i].cacheByVars, iKey)	/>
						</cfif>	
					</cfloop>
					
					<cfset currentTypename = request.aAncestorWebskins[i].typename />
					<cfset currentTemplate = request.aAncestorWebskins[i].template />
					<cfset currentCacheStatus = getWebskinCacheStatus(typename="#currentTypename#", template="#currentTemplate#") />
	
					<cfif currentCacheStatus EQ 1>
						<cflock name="cacheByViewStates_#currentTypename#_#currentTemplate#" timeout="1" throwontimeout="false" type="exclusive">	
							
							<cfparam name="application.fc.cacheByViewStates" default="#structNew()#" />
							<cfparam name="application.fc.cacheByViewStates['#currentTypename#']" default="#structNew()#" />
							<cfparam name="application.fc.cacheByViewStates['#currentTypename#']['#currentTemplate#']" default="" />
										
							<cfset currentViewStates = application.fc.cacheByViewStates['#currentTypename#']['#currentTemplate#'] />
	
							<cfloop list="#arguments.keys#" index="iKey">	
								<cfif not listFindNoCase(currentViewStates, iKey)>
									<cfset currentViewStates = listAppend(currentViewStates, iKey) />
								</cfif>
							</cfloop>
							
							<cfset application.fc.cacheByViewStates['#currentTypename#']['#currentTemplate#'] = currentViewStates />
						</cflock>	
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
		
		<cffunction name="RemoveFromObjectBroker" access="public" output="false" returntype="struct" hint="Removes a list of objectids with their webskins from the object broker">
			<cfargument name="lObjectIDs" required="true" type="string">
			<cfargument name="typename" required="true" type="string" default="">
			
			<cfset variables.oObjectBroker.RemoveFromObjectBroker(argumentCollection="#arguments#") />
			
			<cfreturn success("objectids successfully removed from objectbroker") />
		</cffunction>
		
		<cffunction name="getPropertyMetadata" access="public" output="false" returntype="string" hint="Returns the value of the metadata for a typename/property passed in">
		<cfargument name="typename" required="true" type="string" hint="The typename containing the property" />
		<cfargument name="property" required="true" type="string" hint="The property for which we want metadata for" />
		<cfargument name="md" required="true" type="string" hint="The name of the piece of metadata we want" />
		<cfargument name="default" required="false" default="" type="string" hint="The default value if the metadata does not exist" />
		
		<cfset var result = arguments.default />
		
		<cfif isDefined("application.stCoapi.#arguments.typename#.stProps.#arguments.property#.METADATA")>
			<cfif structKeyExists(application.stCoapi['#arguments.typename#'].stProps['#arguments.property#'].METADATA, arguments.md)>
				<cfset result = application.stCoapi['#arguments.typename#'].stProps['#arguments.property#'].METADATA['#arguments.md#'] />
			</cfif>
		</cfif>

		<cfreturn result />
	</cffunction>
	
	<!--- SECURITY --->
		<cffunction name="checkPermission" access="public" output="false" returntype="boolean" hint="Checks the permission against a role. The roles defaults to the currently logged in users assigned roles.">
			<cfargument name="permission" required="true" />
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(permission=arguments.permission, role=arguments.role) />
	
		</cffunction>
		
		<cffunction name="CheckWebskinPermission" access="public" output="false" returntype="boolean" hint="Checks the view can be accessed by the role. The roles defaults to the currently logged in users assigned roles.">
			<cfargument name="webkskin" required="true" />
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(webkskin=arguments.webkskin, role=arguments.role) />
		</cffunction>
		
		<cffunction name="checkTypePermission" access="public" output="false" returntype="boolean" hint="Checks the permission against the type for a given role. The roles defaults to the currently logged in users assigned roles.">
			<cfargument name="typename" required="true" />
			<cfargument name="permission" required="true" /><!--- create,edit,delete,approve,canapproveowncontent,requestapproval,view --->
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(typename=arguments.typename, permission=arguments.permission, role=arguments.role) />
		</cffunction>
		
		<cffunction name="checkObjectPermission" access="public" output="false" returntype="boolean" hint="Checks the permission against the objectid for a given role. The roles defaults to the currently logged in users assigned roles.">
			<cfargument name="objectid" required="true" />
			<cfargument name="permission" required="true"><!--- Approve,CanApproveOwnContent,ContainerManagement,Create,delete,edit RequestApproval,SendToTrash,view --->
			<cfargument name="role" required="false" default="" hint="Defaults to the currently logged in users assigned roles" />
			
			<cfreturn application.security.checkPermission(objectid=arguments.objectid, permission=arguments.permission, role=arguments.role) />
		</cffunction>
	
		<!--- Current user queries --->
		<cffunction name="isLoggedIn" access="public" output="false" returntype="boolean" hint="Returns true if a user has logged in." bDocument="true">
			
			<cfreturn application.security.isLoggedIn() />
		</cffunction>
			
		<cffunction name="hasRole" returntype="boolean" output="false" access="public" hint="Returns true if the current user has the specified role">
			<cfargument name="role" type="string" required="false" default="" hint="Roles to check" />
			
			<cfreturn application.security.hasRole(argumentCollection="#arguments#") />
		
		</cffunction>
		
		<cffunction name="getCurrentUser" access="public" returntype="struct" hint="Gets the currently logged in user's dmProfile or a blank structure if the user is not logged in.">
		<cfif structKeyExists(session, "dmProfile")>
			<cfreturn session.dmProfile />
		<cfelse>
			<cfreturn structNew() />
		</cfif>
	</cffunction>
	
	<!--- GENERAL FARCRY --->
		<cffunction name="showFarcryDate" access="public" output="false" returntype="boolean" hint="Returns boolean as to whether to show the date based on how farcry stores dates. ie, 2050 or +200 years.">
			<cfargument name="date" required="true" hint="The date to check" />
	
			<cfreturn createObject("component", "farcry.core.packages.types.types").showFarcryDate(argumentCollection="#arguments#") />
		</cffunction>
		
		<cffunction name="getConfig" access="public" returntype="any" output="false" hint="Returns the value of any config item. If no default is sent and the property is not found, an error is thrown.">
			<cfargument name="key" required="true" hint="The Config Key identifying the config form the property is located in." />
			<cfargument name="name" required="true" hint="The name of the config property you wish to retrieve a value for." />
			<cfargument name="default" required="false" hint="If the config item is not found, use this as the default." />
			
			<cfset var result = "" />
			
			<cfif isDefined("application.config.#arguments.key#.#arguments.name#")>
				<cfset result = application.config[arguments.key][arguments.name] />
			<cfelseif structKeyExists(arguments, "default")>
				<cfset result = arguments.default />
			<cfelse>
				<cfthrow message="The config item [#arguments.key#:#arguments.name#] was not found and no default value was passed." />
			</cfif>
			
			<cfreturn result />
			
		</cffunction>
		
		<cffunction name="CheckNavID" access="public" returntype="boolean" output="false" hint="Returns true if the navigation alias is found.">
			<cfargument name="alias" required="true" hint="The navigation alias" />
	
			<cfset result = "" />
			
			<cfif structKeyExists(application, "navID") AND len(arguments.alias)>
				<cfset result = structKeyExists(application.navid, arguments.alias) />
			<cfelse>
				<cfset result = false />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<cffunction name="getNavID" access="public" returntype="string" output="false" hint="Returns the objectID of the dmNavigation record for the passed alias. If the alias does not exist, the alternate alias will be used. ">
			<cfargument name="alias" required="true" hint="The navigation alias" />
			<cfargument name="alternateAlias" required="false" default="home" />
			
			<cfset var result = "" />
			
			<cfif CheckNavID(arguments.alias)>
				<cfset result = application.navid[arguments.alias] />
			<cfelseif CheckNavID(arguments.alternateAlias)>
				<cfset result = application.navid[arguments.alternateAlias] />
			<cfelse>
				<cfset message = getResource("FAPI.messages.NavigationAliasNotFound@text", "The Navigation alias [{1}] and alternate alias [{2}] was not found", array(arguments.alias, arguments.alternateAlias)) />
				<cfthrow message="#message#" />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<cffunction name="CheckCatID" access="public" returntype="boolean" output="false" hint="Returns true if the category alias is found.">
			<cfargument name="alias" required="true" hint="The category alias" />
	
			<cfset result = "" />
			
			<cfif structKeyExists(application, "catID") AND len(arguments.alias)>
				<cfset result = structKeyExists(application.catID, arguments.alias) />
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
			
			<cfif CheckCatID(arguments.alias)>
				<cfset result = application.catID[arguments.alias] />
			<cfelseif CheckCatID(arguments.alternateAlias)>
				<cfset result = application.catID[arguments.alternateAlias] />
			<cfelse>			
				<cfset message = getResource("FAPI.messages.CategoryAliasNotFound@text", "The category alias [{1}] and alternate alias [{2}] was not found","", array(arguments.alias, arguments.alternateAlias)) />
				<cfthrow message="#message#" />
			</cfif>
			
			<cfreturn result />
		</cffunction>	
		
		<cffunction name="getLink" access="public" returntype="string" output="false" hint="returns the href of a link based on the arguments passed in. Acts as a facade call to build link with r_url.">
		
			<cfargument name="href" default=""><!--- the actual href to link to --->
			<cfargument name="objectid" default=""><!--- Added to url parameters; navigation obj id --->
			<cfargument name="alias" default=""><!--- Navigation alias to use to find the objectid --->
			<cfargument name="type" default=""><!--- Added to url parameters: Typename used with type webskin views --->
			<cfargument name="view" default=""><!--- Added to url parameters: Webskin name used to render the page layout --->
			<cfargument name="bodyView" default=""><!--- Added to url parameters: Webskin name used to render the body content --->
			<cfargument name="linktext" default=""><!--- Text used for the link --->
			<cfargument name="target" default="_self"><!--- target window for link --->
			<cfargument name="bShowTarget" default="false"><!--- @@attrhint: Show the target link in the anchor tag  @@options: false,true --->
			<cfargument name="externallink" default="">
			<cfargument name="id" default=""><!--- Anchor tag ID --->
			<cfargument name="class" default=""><!--- Anchor tag classes --->
			<cfargument name="style" default=""><!--- Anchor tag styles --->
			<cfargument name="title" default=""><!--- Anchor tag title text --->
			<cfargument name="urlOnly" default="false">
			<cfargument name="r_url" default=""><!--- Define a variable to pass the link back (instead of writting out via the tag). Note setting urlOnly invalidates this setting --->
			<cfargument name="xCode" default=""><!--- eXtra code to be placed inside the anchor tag --->
			<cfargument name="includeDomain" default="false">
			<cfargument name="Domain" default="#cgi.http_host#">
			<cfargument name="stParameters" default="#StructNew()#">
			<cfargument name="urlParameters" default="">
			<cfargument name="JSWindow" default="0"><!--- Default to not using a Javascript Window popup --->
			<cfargument name="stJSParameters" default="#StructNew()#">
			<cfargument name="anchor" default=""><!--- Anchor to place at the end of the URL string. --->
			
			<cfset var returnURL = "" />
			<cfset var linkID = "" />
			<cfset var stLocal = StructNew()>
			<cfset var jsParameters = "">
			
			<!--- Setup URL Parameters --->
			<cfif listLen(arguments.urlParameters, "&")>
				<cfloop list="#arguments.urlParameters#" delimiters="&" index="i">
					<cfset arguments.stParameters[listFirst(i, "=")] = listLast(i, "=") />
				</cfloop>
			</cfif>
			
			<cfif arguments.target NEQ "_self" AND NOT arguments.urlOnly> <!--- If target is defined and the user doesn't just want the URL then it is a popup window and must therefore have the following parameters --->		
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
			
		
			<cfif len(arguments.href)>
				<cfset returnURL = arguments.href>
		
				<cfif NOT FindNoCase("?", arguments.href)>
					<cfset returnURL = "#returnURL#?">
				</cfif>
			<cfelse>
				<cfif arguments.includeDomain>
					<cfset returnURL = "http://#arguments.Domain#">
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
		
				<cfset returnURL = returnURL & application.fc.factory.farFU.getFU(objectid="#linkID#", type="#arguments.type#", view="#arguments.view#", bodyView="#arguments.bodyView#")>
		
			</cfif>
			
			<!--- check for extra URL parameters --->
			<cfif NOT StructIsEmpty(arguments.stParameters)>
				<cfset stLocal = StructNew()>
				<cfset stLocal.parameters = "">
				<cfset stLocal.iCount = 0>
				<cfloop collection="#arguments.stParameters#" item="stLocal.key">
					<cfif stLocal.iCount GT 0>
						<cfset stLocal.parameters = stLocal.parameters & "&">
					</cfif>
					<cfset stLocal.parameters = stLocal.parameters & stLocal.key & "=" & URLEncodedFormat(arguments.stParameters[stLocal.key])>
					<cfset stLocal.iCount = stLocal.iCount + 1>
				</cfloop>
		
			
				<cfif ListFind("&,?",Right(returnURL,1))><!--- check to see if the last character is a ? or & and don't append one between the params and the returnURL --->
					<cfset returnURL=returnURL&stLocal.parameters>
				<cfelseif Find("?",returnURL)> <!--- If there is already a ? in the returnURL, just concat the params with & --->
					<cfset returnURL=returnURL&"&"&stLocal.parameters>
				<cfelse> <!--- No query string on the returnURL, so add a new one using ? and the params --->
					<cfset returnURL=returnURL&"?"&stLocal.parameters>		
				</cfif>
			</cfif>
			
			<!--- Append the anchor to the end of the URL. --->
			<cfif len(arguments.anchor)>
				<cfif left(arguments.anchor,1) NEQ "##">
					<cfset arguments.anchor = "###arguments.anchor#">
				</cfif>
				<cfset returnURL = "#returnURL##arguments.anchor#" />		
			</cfif>
			
			<!--- Are we meant to use the Javascript Popup Window? --->
			<cfif arguments.JSWindow>
			
				<cfset arguments.bShowTarget = 0><!--- No need to add the target to the <a returnURL> as it is handled in the javascript --->
				
				<cfset jsParameters = "">
				<cfloop list="#structKeyList(arguments.stJSParameters)#" index="i">
					<cfset jsParameters = ListAppend(jsParameters, "#i#=#arguments.stJSParameters[i]#")>
				</cfloop>
				<cfset returnURL = "javascript:win=window.open('#returnURL#', '#arguments.Target#', '#jsParameters#'); win.focus();">
				
			</cfif>
			
			<cfset returnURL = fixURL(returnURL) />
		
				
				
			<cfreturn returnURL />
			
		</cffunction>
		
		<cffunction name="getWebRoot" access="public" returntype="string" output="false" hint="Returns the url path to the webroot.">
		
			<cfreturn application.url.webroot />
		</cffunction>	
		
		<cffunction name="getImageWebRoot" access="public" returntype="string" output="false" hint="Returns the path inside the webroot where all image property paths are relative to. By default, this is the webroot of the project.">
		
			<cfreturn application.url.imageRoot />
		</cffunction>
			
		<cffunction name="getFileWebRoot" access="public" returntype="string" output="false" hint="Returns the path inside the webroot where all file property paths are relative to. By default, this is /files insite the webroot of the project.">
	
		<cfreturn application.url.fileRoot />
	</cffunction>
	
	<!--- MISCELLANEOUS --->
		<cffunction name="throw" access="public" returntype="void" output="false" hint="Provides similar functionality to the cfthrow tag but is automatically incorporated to use the resource bundles.">
			
			<cfargument name="message" type="string" required="false" default="" />
			<cfargument name="errorcode" type="string" required="false" default="" />
			<cfargument name="detail" type="string" required="false" default="" />
			<cfargument name="extendedinfo" type="string" required="false" default="" />
			<cfargument name="object" type="object" required="false" />
			<cfargument name="type" type="string" required="false" default="" />
			
			<!--- Resource Bundle Options --->
			<cfargument name="key" type="string" required="false" default="" /><!--- Resource Bundle Key --->
			<cfargument name="locale" type="string" required="false" default="" /><!--- Locale --->		
			<cfargument name="substituteValues" type="array" required="false" default="#arrayNew(1)#" /><!--- Array of substitue values used by the resource bundle text --->
			
			<!--- This little chestnut will automatically setup the message and detail strings in the resource bundle and provide translations --->
			<cfif len(arguments.message)>
				<cfif not len(arguments.key)>
					<cfset arguments.key = "FAPI.throw.#rereplaceNoCase(arguments.message, '[^/w]+', '_', 'all')#" />
				</cfif>
				
				<cfset arguments.message = getResource("#arguments.key#@message", arguments.message, arguments.locale, arguments.substituteValues) />
				
				<cfif len(arguments.detail)>
					<cfset arguments.detail = getResource("#arguments.key#@detail", arguments.detail, arguments.locale, arguments.substituteValues) />
				</cfif>
			</cfif>
			
			<!--- THE FOLLOWING LIST PROVIDES THE DIFFERENT WAYS cfthrow CAN BE CALLED:
		 	Required attributes: 'type'. Optional attributes: 'detail,errorcode,extendedinfo,message'.
			Required attributes: 'message'. Optional attributes: 'detail,errorcode,extendedinfo'.
			Required attributes: 'extendedinfo'. Optional attributes: 'detail,errorcode'.
			Required attributes: 'errorcode'. Optional attributes: 'detail'.  
			Required attributes: 'detail'. Optional attributes: None.
			Required attributes: 'object'. Optional attributes: None.
			  --->
			
			<cfif len(arguments.type)>
				<cfthrow 
					type="#arguments.type#"
					message="#arguments.message#" 
					detail="#arguments.detail#" 
					errorcode="#arguments.errorcode#" 
					extendedinfo="#arguments.extendedinfo#"  
				 />
				
			<cfelseif len(arguments.message)>
	
				<cfthrow 
					message="#arguments.message#" 
					detail="#arguments.detail#" 
					errorcode="#arguments.errorcode#" 
					extendedinfo="#arguments.extendedinfo#"  
				 />			
			<cfelseif len(arguments.extendedinfo)>
				<cfthrow 
					extendedinfo="#arguments.extendedinfo#"
					detail="#arguments.detail#" 
					errorcode="#arguments.errorcode#" 
				 />				
			<cfelseif len(arguments.errorcode)>
				<cfthrow 
					errorcode="#arguments.errorcode#" 
					detail="#arguments.detail#" 
				 />				
			<cfelseif len(arguments.errorcode)>
				<cfthrow 
					errorcode="#arguments.errorcode#" 
					detail="#arguments.detail#" 
				 />			
			<cfelseif len(arguments.detail)>
				<cfthrow
					detail="#arguments.detail#" 
				 />			
			<cfelseif structKeyExists(arguments, "object")>
				<cfthrow
					object="#arguments.object#" 
				 />		
			<cfelse>
				<cfthrow 
					message="Attribute validation error for the CFTHROW tag."
					detail="The tag has an invalid attribute combination: detail,errorcode,extendedinfo,message,object,type. Possible combinations are:<li>Required attributes: 'type'. Optional attributes: 'detail,errorcode,extendedinfo,message'. <li>Required attributes: 'message'. Optional attributes: 'detail,errorcode,extendedinfo'. <li>Required attributes: 'extendedinfo'. Optional attributes: 'detail,errorcode'. <li>Required attributes: 'errorcode'. Optional attributes: 'detail'. <li>Required attributes: None. Optional attributes: None. <li>Required attributes: 'detail'. Optional attributes: None. <li>Required attributes: 'object'. Optional attributes: None."
				/>	 
			</cfif>
		
		</cffunction>
		
		<cffunction name="getUUID" access="public" returntype="uuid" output="false" hint="">
			
			<cfreturn application.fc.utils.createJavaUUID() />
		</cffunction>
		
		<cffunction name="fixURL" returntype="string" output="false" access="public" hint="Refreshes the page with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments." bDocument="true">
			<cfargument name="url" type="string" required="false" default="#cgi.script_name#?#cgi.query_string#" hint="The url to use" />
			<cfargument name="removevalues" type="string" required="false" hint="List of values to remove from the query string. Prefix with '+' to remove these values in addition to the defaults." />
			<cfargument name="addvalues" type="any" required="false" hint="A query string or a struct of values, to add to the query string" />
			
			<cfreturn application.fc.utils.fixURL(argumentCollection="#arguments#") />
		</cffunction>
		
		<cffunction name="insertQueryVariable" returntype="string" output="false" access="public" hint="Inserts the specified key and value, replacing the existing value for that key">
			<cfargument name="url" type="string" required="true" hint="The url to modify" />
			<cfargument name="key" type="string" required="true" hint="The key to insert" />
			<cfargument name="value" type="string" required="true" hint="The value to insert" />
			
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
		<cfargument name="message" default="" required="false">
	
		<cfif isdefined("application.log.bDeprecated") AND application.log.bDeprecated>		
			<cftrace type="warning" inline="false" text="#GetBaseTemplatePath()# - #arguments.message#" abort="false" />
			<cflog file="deprecated" application="true" type="warning" text="#GetBaseTemplatePath()# - #arguments.message#" />
			<cf_logevent location="#getPageContext().getPage().getCurrentTemplatePath()#" type="application" event="deprecated" notes="#arguments.message#" />
		</cfif>	
		
	</cffunction>	

	<!--- I18N --->
		<cffunction name="getResource" access="public" output="false" returntype="string" hint="Returns the resource string" bDocument="true">
			<cfargument name="key" type="string" required="true" />
			<cfargument name="default" type="string" required="false" default="#arguments.key#" />
			<cfargument name="locale" type="string" required="false" default="" />
			<cfargument name="substituteValues" required="no" default="#arrayNew(1)#" />
			
			<cfset arguments.rbString = arguments.key />
			
			<cfreturn application.rb.formatRBString(argumentCollection="#arguments#") />
		</cffunction>
		
		<cffunction name="getCurrentLocale" access="public" output="false" returntype="string" hint="Returns the current locale string based on if the client is logged in or not">
		
		<cfreturn application.rb.getCurrentLocale() />
	</cffunction>
	
	<!--- ARRAY FUNCTIONS --->
		<cffunction name="array" access="public" output="false" returntype="array" hint="Creates an array from the passed in arguments">
			
			<cfset var aResult = arrayNew(1) />
			<cfset var i = "" />
			
			<cfloop from="1" to="#arrayLen(arguments)#" index="i">
				<cfset arrayAppend(aResult, arguments[i]) />
			</cfloop> 
			
			<cfreturn aResult />
		</cffunction>
	
		<cffunction name="arrayFind" access="public" output="false" returntype="numeric" hint="Returns the index of the first element that matches the specified value. 0 if not found." bDocument="true">
		<cfargument name="ar" type="array" required="true" hint="The array to search" />
		<cfargument name="value" type="Any" required="true" hint="The value to find" />
		
		<cfreturn application.fc.utils.arrayFind(argumentCollection="#arguments#") />
	</cffunction>

	<!--- LIST UTILITIES --->
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
	
		<cffunction name="listSlice" access="public" output="false" returntype="string" hint="Returns the specified elements of the list" bDocument="true">
			<cfargument name="list" type="string" required="true" hint="The list being sliced" />
			<cfargument name="start" type="numeric" required="false" default="1" hint="The start index of the slice. Negative numbers are reverse indexes: -1 is last item." />
			<cfargument name="end" type="numeric" required="false" default="-1" hint="The end index of the slice. Negative values are reverse indexes: -1 is last item." />
			<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
			
			<cfreturn application.fc.utils.listSlice(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="listFilter" access="public" output="false" returntype="string" hint="Filters the items in a list though a regular expression" bDocument="true">
			<cfargument name="list" type="string" required="true" hint="The list being filtered" />
			<cfargument name="filter" type="string" required="true" hint="The regular expression to filter by" />
			<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
			
			<cfreturn application.fc.utils.listFilter(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="listContainsAny" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
			<cfargument name="list1" type="string" required="true" hint="The list being searched" />
			<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
			<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
			
			<cfreturn application.fc.utils.listContainsAny(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="listContainsAnyNoCase" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being searched" />
		<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
		
		<cfreturn application.fc.utils.listContainsAnyNoCase(argumentCollection="#arguments#") />
	</cffunction>

	<!--- STRUCT UTILITIES --->
		<cffunction name="structMerge" access="public" output="false" returntype="struct" hint="Performs a deep merge on two structs" bDocument="true">
			<cfargument name="struct1" type="struct" required="true" />
			<cfargument name="struct2" type="struct" required="true" />
			<cfargument name="replace" type="boolean" required="false" default="true" />
			
			<cfreturn application.fc.utils.listDiff(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments" bDocument="true">
			
			<cfreturn application.fc.utils.structCreate(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="struct" returntype="struct" output="false" access="public" hint="Shortcut for creating structs">
			
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
	
	<!--- PACKAGE UTILITIES --->
		<cffunction name="getPath" access="public" output="false" returntype="string" hint="Finds the component in core/plugins/project, and returns its path" bDocument="true">
			<cfargument name="package" type="string" required="true" />
			<cfargument name="component" type="string" required="true" />
			<cfargument name="locations" type="string" required="false" default="" />
			
			<cfreturn application.fc.utils.getPath(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="getComponents" access="public" output="false" returntype="string" hint="Returns a list of components for a package" bDocument="true">
			<cfargument name="package" type="string" required="true" />
			<cfargument name="locations" type="string" required="false" default="" />
			
			<cfreturn application.fc.utils.getComponents(argumentCollection="#arguments#") />
		</cffunction>
	
		<cffunction name="extends" access="public" output="false" returntype="boolean" hint="Returns true if the specified component extends another" bDocument="true">
			<cfargument name="desc" type="string" required="true" hint="The component to test" />
			<cfargument name="anc" type="string" required="true" hint="The ancestor to check for" />
			
			<cfreturn application.fc.utils.extends(argumentCollection="#arguments#") />
		</cffunction>
		
		<cffunction name="listExtends" access="public" returntype="string" description="Returns a list of the components the specified one extends (inclusive)" output="false">
		<cfargument name="path" type="string" required="true" hint="The package path of the component" />
		
		<cfreturn application.fc.utils.listExtends(argumentCollection="#arguments#") />
	</cffunction>
	
</cfcomponent>