<cfcomponent displayname="FarCry API" hint="The API for all things FarCry" output="false" bDocument="true" scopelocation="application.fapi">

	<cffunction name="init" access="public" returntype="fapi" output="false" hint="FAPI Constructor">
		
		<cfreturn this />
	</cffunction>
	
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
	
	
	<cffunction name="throw" access="public" returntype="void" output="false" hint="Provides similar functionality to the cfthrow tag but is automatically incorporated to use the resource bundles.">
		
		<cfargument name="errorcode" type="string" required="false" default="" />
		<cfargument name="message" type="string" required="false" default="" />
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
	
	
	<cffunction name="getResource" access="public" output="false" returntype="string" hint="Returns the resource string" bDocument="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="default" type="string" required="false" default="#arguments.key#" />
		<cfargument name="locale" type="string" required="false" default="" />		
		<cfargument name="substituteValues" required="no" default="#arrayNew(1)#" />
		
		<cfset arguments.rbString = arguments.key />
		
		<cfreturn application.rb.formatRBString(argumentCollection="#arguments#") />
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
	
	

	
	<cffunction name="array">
		
		<cfset var aResult = arrayNew(1) />
		<cfset var i = "" />
		
		<cfloop from="1" to="#arrayLen(arguments)#" index="i">
			<cfset arrayAppend(aResult, arguments[i]) />
		</cfloop> 
		
		<cfreturn aResult />
	</cffunction>

	<cffunction name="getUUID" access="public" returntype="uuid" output="false" hint="">
		
		<cfreturn application.fc.utils.createJavaUUID() />
		
	</cffunction>
	
	<!--- ARRAY utilities --->
	<cffunction name="arrayFind" access="public" output="false" returntype="numeric" hint="Returns the index of the first element that matches the specified value. 0 if not found." bDocument="true">
		<cfargument name="ar" type="array" required="true" hint="The array to search" />
		<cfargument name="value" type="Any" required="true" hint="The value to find" />
		
		<cfreturn application.fc.utils.arrayFind(argumentCollection="#arguments#") />
	</cffunction>

	<!--- LIST utilities --->
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

	<!--- STRUCT ulilities --->
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

	<!--- PACKAGE utilities --->
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

	<cffunction name="listExtends" access="public" returntype="string" description="Returns a list of the components the specified one extends (inclusive)" output="true">
		<cfargument name="path" type="string" required="true" hint="The package path of the component" />
		
		<cfreturn application.fc.utils.listExtends(argumentCollection="#arguments#") />
	</cffunction>

	<!--- MISCELLANEOUS utilities --->
	<cffunction name="fixURL" returntype="string" output="true" access="public" hint="Refreshes the page with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments." bDocument="true">
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
	
</cfcomponent>