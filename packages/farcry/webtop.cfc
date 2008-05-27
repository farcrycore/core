<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: Webtop component. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au)$
--->
<cfcomponent>
	
	<cfset this.stWebtop = structnew() />

	<cffunction name="init" access="public" output="true" returntype="any" hint="Initialise component with XML configs from core and custom admin.">
		<cfset var plugin = "" /><!--- Used in the loop of plugins --->
		<cfset var dirlist = "" /><!--- List of directories to check --->
		<cfset var thisdir = "" /><!--- Used in loop of directories --->
		
		<!--- Put together a list of customadmin directories --->
		<cfset dirlist = listappend(dirlist,"#application.path.core#/config") />
		<cfloop list="#application.plugins#" index="plugin">
			<cfset dirlist = listappend(dirlist,"#application.path.plugins#/#plugin#/customadmin") />
		</cfloop>
		<cfset dirlist = listappend(dirlist,"#application.path.project#/customadmin") />
		
		<!--- Look for custom admin files in each directory --->
		<cfloop list="#dirlist#" index="thisdir">
			<!--- If any custom admin xml files exist, we need to add them to our custom admin XML array --->
			<cfif directoryExists("#thisdir#")>
				<cfdirectory action="list" directory="#thisdir#" filter="*.xml" name="qCustomAdmin" />
				
				<cfloop query="qCustomAdmin">
					<!--- For each custom admin --->
					<cfset mergeWebtopStruct(this.stWebtop,convertToStruct(loadWebtopFile("#thisdir#/#name#").webtop)) />
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- Update the rb keys --->
		<cfset updateDerivedAttributes(this.stWebtop) />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="loadWebtopFile" access="private" output="false" returntype="xml" hint="Loads a webtop xml file and returns is">
		<cfargument name="file" type="string" required="true" hint="The file to load" />
		
		<cfset var xmlResult = xmlnew() />
		
		<!--- Load the file --->
		<cffile action="read" file="#arguments.file#" variable="xmlResult">
		
		<cftry>
			<!--- validate custom admin xml --->
			<cfset xmlResult = xmlParse(xmlResult) />
			
			<!--- If the file is using the DEPRECIATED version --->
			<cfif arraylen(xmlsearch(xmlResult, "/customtabs"))>
				<!--- process old-style custom admin --->
				<cffile action="read" file="#application.path.core#/config/transform.xsl" variable="xslt" />
				
				<!--- XSLT transform customadmin --->
				<cfset xmlResult=xmlTransform(xmlResult,xslt) />
				<cfset xmlResult=xmlParse(xmlResult) />
				
				<!--- log deprecated approach --->
				<cftrace type="warning" category="farcry.webtop" text="../customadmin/customadmin.xml is using an old format.  This was updated to a more modern format with the release of FarCry 2.4." />
				<cflog application="true" file="deprecated" type="warning" text="../customadmin/customadmin.xml initialised using an old xml format.  This was updated to a more modern format with the release of FarCry 2.4." />
			</cfif>
			
			<cfcatch>
				<cfthrow type="warning" message="#arguments.file# was not parsed successfully." detail="#cfcatch.Detail#" extendedinfo="#cfcatch.ExtendedInfo#" />
			</cfcatch>
		</cftry>
		
		<cfreturn xmlResult />
	</cffunction>
	
	<cffunction name="defaultStruct" access="private" output="false" returntype="struct" hint="Returns a struct containing the default attributes">
		<cfset var stResult = structnew() />
		
		<cfset stResult.itemtype = "unknown" />
		<cfset stResult.mergeType = "" />
		<cfset stResult.childorder = "" />
		<cfset stResult.children = structnew() />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="convertToStruct" access="private" output="false" returntype="struct" hint="Converts a webtop XML file to a struct">
		<cfargument name="xml" type="string" required="true" hint="The XML to be converted" />
		
		<cfset var stResult = defaultStruct() /><!--- Will have structure of item[itemtype='section|subsection|menu|menuitem',attribute*,aChildren] --->
		<cfset var i = 0 />
		<cfset var key = "" />
		<cfset var stChild = structnew() />
		
		<!--- Item type --->
		<cfset stResult.itemtype = arguments.xml.xmlname />
		
		<!--- Item attributes --->
		<cfif structkeyexists(arguments.xml,"xmlAttributes")>
			<cfloop collection="#arguments.xml.xmlAttributes#" item="key">
				<cfset stResult[key] = arguments.xml.xmlAttributes[key] />
			</cfloop>
		</cfif>
		
		<!--- Get label from xmlText if necessary --->
		<cfif not structkeyexists(stResult,"label") and structkeyexists(arguments.xml,"xmlText") and len(trim(arguments.xml.xmlText))>
			<cfset stResult.label = trim(arguments.xml.xmlText) />
		</cfif>
		
		<!--- Item children --->
		<cfif structkeyexists(arguments.xml,"xmlChildren")>
			<cfloop from="1" to="#arraylen(arguments.xml.xmlChildren)#" index="i">
				<cfset stChild = convertToStruct(arguments.xml.xmlChildren[i]) />
				
				<!--- Make sure the children have ids --->
				<cfif not structkeyexists(stChild,"id")>
					<cfset stChild.id = "item#i#" />
				</cfif>
				
				<cfset stResult.children[stChild.id] = stChild />
			</cfloop>
		</cfif>
		
		<!--- Item type specific defaults --->
		<cfswitch expression="#stResult.itemtype#">
			<cfcase value="section">
				
			</cfcase>
			<cfcase value="subsection">
				
			</cfcase>
			<cfcase value="menu">
				
			</cfcase>
			<cfcase value="menuitem">
				
			</cfcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="mergeWebtopStruct" access="private" output="false" returntype="struct" hint="Merges two webtop structs together">
		<cfargument name="struct1" type="struct" required="true" hint="The current struct" />
		<cfargument name="struct2" type="struct" required="true" hint="The struct to be merged" />
		
		<cfset var stResult = arguments.struct1 />
		<cfset var key = "" />
		<cfset var id = "" />
		
		<cfparam name="stResult.children" default="#structnew()#" />
		<cfparam name="stResult.mergeType" default="" />
		
		<!--- If mergetype is "none" it can't be changed --->
		<cfif stResult.mergeType eq "none">
			<cfreturn stResult />
		</cfif>
		
		<cfswitch expression="#arguments.struct2.mergeType#">
			<cfcase value="replace">
				<!--- replace ALL data in struct1 with that in struct2 --->
				<cfset structclear(stResult) />
				<cfloop collection="#arguments.struct2#" item="key">
					<cfset stResult[key] = duplicate(arguments.struct2[key]) />
				</cfloop>
			</cfcase>
			
			<cfcase value="mergeNoReplace">
				<!--- append root2.stAttributes to root1.stAttributes --->
				<!--- do not replace duplicate keys --->
				<!--- normal merge/replace operation on children --->
				<cfloop collection="#arguments.struct2#" item="key">
					<cfif key eq "children">
						<!--- Merge children --->
						<cfloop collection="#arguments.struct2[key]#" item="id">
							<cfif not structkeyexists(stResult.children,id)>
								<cfset stResult.children[id] = duplicate(arguments.struct2.children[id]) />
							</cfif>
						</cfloop>
					<cfelse>
						<!--- Copy attributes --->
						<cfif not structkeyexists(stResult,key)>
							<cfset stResult[key] = arguments.struct2[key] />
						</cfif>
					</cfif>
				</cfloop>
			</cfcase>
			
			<cfdefaultcase><!--- Default case is "merge" --->
				<!--- append root2.stAttributes to root1.stAttributes --->
				<!--- replace if duplicate keys --->
				<!--- normal merge/replace operation on children --->
				<cfloop collection="#arguments.struct2#" item="key">
					<cfif key eq "children">
						<!--- Merge children --->
						<cfloop collection="#arguments.struct2[key]#" item="id">
							<cfif structkeyexists(stResult.children,id)>
								<cfset stResult.children[id] = mergeWebtopStruct(stResult.children[id],arguments.struct2.children[id]) />
							<cfelse>
								<cfset stResult.children[id] = duplicate(arguments.struct2.children[id]) />
							</cfif>
						</cfloop>
					<cfelse>
						<!--- Copy attributes --->
						<cfset stResult[key] = arguments.struct2[key] />
					</cfif>
				</cfloop>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="updateDerivedAttributes" access="private" output="false" returntype="struct" hint="Adds an rbkey attribute to each item">
		<cfargument name="item" type="struct" required="false" default="#this.stWebtop#" hint="The webtop struct to update" />
		<cfargument name="basekey" type="string" required="false" default="webtop" hint="The base key to build the rest on" />
		
		<cfset var id = "" />
		
		<!--- Only the webtop element doesn't have an id --->
		<cfif not structkeyexists(arguments.item,"id")>
			<cfparam name="arguments.item.id" default="#arguments.basekey#" />
			
			<!--- Define default rbkey --->
			<cfparam name="arguments.item.rbkey" default="#arguments.basekey#" />
		<cfelse>
			<!--- Define default rbkey --->
			<cfparam name="arguments.item.rbkey" default="#arguments.basekey#.#arguments.item.id#" />
		</cfif>
		
		<!--- Default sequence position is last --->
		<cfparam name="arguments.item.sequence" default="100000" />
		
		<!--- Define default label --->
		<cfparam name="arguments.item.label" default="[add label]" />
		
		<!--- Define default label type --->
		<cfparam name="arguments.item.labelType" default="" />
		
		<!--- Default sidebar expander behaviour --->
		<cfparam name="arguments.item.altexpansion" default="0" />
		
		<!--- Update children --->
		<cfloop collection="#arguments.item.children#" item="id">
			<cfset updateDerivedAttributes(arguments.item.children[id],arguments.item.rbkey) />
		</cfloop>
		
		<!--- Update child order based on sequence values --->
		<cfset arguments.item.childorder = arraytolist(structsort(arguments.item.children,"numeric","asc","sequence")) />
		
		<!--- Tag specfic defaults --->
		<cfswitch expression="#arguments.item.itemtype#">
			<cfcase value="section">
				<cfparam name="arguments.item.description" default="" />
				<cfparam name="arguments.item.icon" default="" />
				<cfparam name="arguments.item.relatedType" default="" />
			</cfcase>
			<cfcase value="subsection">
				<cfparam name="arguments.item.description" default="" />
				<cfparam name="arguments.item.icon" default="" />
				<cfparam name="arguments.item.relatedType" default="" />
			</cfcase>
			<cfcase value="menu">
				<cfparam name="arguments.item.description" default="" />
			</cfcase>
			<cfcase value="menuitem">
				<cfparam name="arguments.item.linkType" default="" />
				<cfparam name="arguments.item.description" default="" />
				<cfparam name="arguments.item.icon" default="" />
				<cfparam name="arguments.item.relatedType" default="" />
			</cfcase>
		</cfswitch>
		
		<cfreturn arguments.item />
	</cffunction>
	
	<cffunction name="getItem" access="public" output="false" returntype="struct" hint="Returns a translated webtop struct with all restricted items filtered out">
		<cfargument name="parent" type="any" required="false" default="#this.stWebtop#" hint="The parent item to retrieve" />
		<cfargument name="honoursecurity" type="boolean" required="false" default="true" hint="Set to false to ignore security" />
		<cfargument name="duplicated" type="boolean" required="false" default="false" hint="Used to ensure the struct is only duplicated once" />
		
		<cfset var stResult = this.stWebtop />
		<cfset var id = "" />
		<cfset var stTempResult = structnew() />
		
		<cfif isstruct(arguments.parent)>
			<!--- Use that as stResult --->
			<cfset stResult = arguments.parent />
			
			<cfif structkeyexists(stResult,"dynamicmenu") and len(stResult.dynamicmenu) and structkeyexists(application.stCOAPI,listfirst(stResult.dynamicmenu,"."))>
				<!--- If this is a dynamic menu, get the data --->
				<cfinvoke component="#application.stCOAPI[listfirst(stResult.dynamicmenu,'.')].packagepath#" method="#listlast(stResult.dynamicmenu,'.')#" returnvariable="stTempResult" />
				<cfset structappend(stResult,stTempResult,true) />
				<cfset structdelete(stResult,"dynamicmenu") />
			</cfif>
		<cfelseif issimplevalue(arguments.parent)>
			<!--- Traverse the webtop struct using the ids specified --->
			<cfloop list="#arguments.parent#" delimiters="." index="id">
				<cfif structkeyexists(stResult.children,id)>
					<cfset stResult = stResult.children[id] />
					
					<cfif structkeyexists(stResult,"dynamicmenu") and len(stResult.dynamicmenu) and structkeyexists(application.stCOAPI,listfirst(stResult.dynamicmenu,"."))>
						<!--- If this is a dynamic menu, get the data --->
						<cfinvoke component="#application.stCOAPI[listfirst(stResult.dynamicmenu,'.')].packagepath#" method="#listlast(stResult.dynamicmenu,'.')#" returnvariable="stTempResult" />
						<cfset structappend(stResult,stTempResult,true) />
						<cfset structdelete(stResult,"dynamicmenu") />
					</cfif>
				<cfelse>
					<cfthrow message="The parent argument must be a webtop struct or an id path specifying an existing webtop struct" />
				</cfif>
			</cfloop>
		<cfelse>
			<!--- The parent argument was not valid --->
			<cfthrow message="The parent argument must be a webtop struct or an id path specifying an existing webtop struct" />
		</cfif>
		
		<!--- If the struct has not been duplicated, then do so --->
		<cfif not arguments.duplicated>
			<cfset stResult = duplicate(stResult) />
		</cfif>
		
		<!--- Remove children that the user doesn't have permission for --->
		<cfloop collection="#stResult.children#" item="id">
			<cfif not arguments.honoursecurity or not structkeyexists(stResult.children[id],"permission") or application.security.checkPermission(permission=stResult.children[id].permission)>
				<!--- Perform same process on allowed child --->
				<cfset getItem(stResult.children[id],arguments.honoursecurity,true) />
			<cfelse>
				<!--- Remove restricted child --->
				<cfset structdelete(stResult.children,id) />
			</cfif>
		</cfloop>
		
		<!--- Update child order based on sequence values of filtered children --->
		<cfset stResult.childorder = arraytolist(structsort(stResult.children,"numeric","asc","sequence")) />
				
		<!--- If this is the first (root) call, i.e. it hadn't been duplicated yet, translate the struct --->
		<cfset translateWebtop(stResult,true) />
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="translateWebtop" access="public" output="false" returntype="struct" hint="Returns a translated version of the specified webtop struct">
		<cfargument name="webtop" type="struct" required="true" hint="The webtop struct to translate" />
		<cfargument name="duplicated" type="boolean" required="false" default="false" hint="Used to ensure a struct is only duplicated the first time" />
		
		<cfset var stResult = arguments.webtop />
		<cfset var attributes = "label,description" />
		<cfset var attr = "" />
		<cfset var id = "" />
		
		<cfif not arguments.duplicated>
			<cfset stResult = duplicate(stResult) />
		</cfif>
		
		<cfif not structkeyexists(stResult,"translated")>
			<!--- For each attribute that needs to be translated --->
			<cfloop list="#attributes#" index="attr">
				<!--- Process dynamic labels - pass through result as default value for resource --->
				<!--- Use the rbkey - this is automatically generated on load if it isn't explicitly defined --->
				<cfif structkeyexists(stResult,attr)>
					<cftry>
						<cfif attr eq "label" and len(stResult.labelType) and listcontains("evaluate,expression",stResult.labelType)>
							<cfset stResult[attr] = application.rb.getResource("#stResult.rbkey#@#attr#",Evaluate(stResult[attr])) />
						</cfif>
						
						<cfset stResult[attr] = application.rb.getResource("#stResult.rbkey#@#attr#",stResult[attr]) />
						
						<cfcatch type="any">
							<cfset stResult[attr] = "<font color='red'>#stResult[attr]#</font>" />
						</cfcatch>
					</cftry>
				</cfif>
			</cfloop>
			
			<cfloop collection="#arguments.webtop.children#" item="id">
				<cfset translateWebtop(arguments.webtop.children[id],true) />
			</cfloop>
			
			<cfset stResult.translated = true />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="getAttributeUrl" access="public" output="false" returntype="string" hint="Takes the webtop struct of a subsection, returns the string of a url to use for the sidebar.">
		<cfargument name="item" type="any" required="true" hint="The item being queried" />
		<cfargument name="attr" type="string" required="false" default="sidebar" hint="The attribute that contains the url" />
		<cfargument name="params" type="struct" required="false" default="#structnew()#" hint="Parameters to add to the query string" />
	
		<cfset var sReturn = "custom/#arguments.attr#.cfm" />  <!--- this seems like a good default url --->
		<cfset var urlUtil = createobject("component","UrlUtility") />
		<cfset var stParams = StructNew() />
		<cfset var id = "" />
		<cfset var stItem = getItem(arguments.item) />
		
		<!--- Item attribute may be webtop struct or an id path to the webtop struct --->
		<!--- <cfif isstruct(arguments.item)>
			<!--- Use that struct --->
			<cfset stItem = arguments.item />
		<cfelseif issimplevalue(arguments.item)>
			<!--- Retrieve item --->
			<cfloop list="#arguments.item#" delimiters="." index="id">
				<cfif structkeyexists(stItem.children,id)>
					<cfset stItem = stItem.children[id] />
				<cfelse>
					<!--- Item doesn't exist --->
					<cfthrow message="The item argument must be a webtop struct or an id path specifying a webtop struct" />
				</cfif>
			</cfloop>
		</cfif> --->
		
		<!--- if the 'sidebar' attribute exists, make it the base url --->
		<cfif StructKeyExists(stItem, arguments.attr)>
			<cfset sReturn = stItem[arguments.attr] />
		</cfif>
		
		<!--- add anything in our query_string to the url params --->
		<!--- getUrlParamStruct looks for the '?' --->
		<cfset stParams = urlUtil.getURLParamStruct("?" & CGI.QUERY_STRING) />
		
		<!--- if 'id' attribute exists, REPLACE any 'sub' url param with this value --->
		<cfif StructKeyExists(stItem, "id")>
			<cfset stParams.sub = stItem.id />
		</cfif>
		
		<!--- Add passed in params --->
		<cfloop collection="#arguments.params#" item="id">
			<cfset stParams[id] = arguments.params[id] />
		</cfloop>
		
		<!--- generate the sidebar url by appending the params we've accumulated --->
		<cfset sReturn = urlUtil.appendURLParams(address=sReturn, paramStruct=stParams, replaceExisting=false) />
		
		<cfreturn sReturn />
	</cffunction>

</cfcomponent>