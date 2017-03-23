<cfcomponent output="false">
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
<!---
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
	
	<cfset this.stWebtop = structnew() />

	<cffunction name="init" access="public" output="false" returntype="any" hint="Initialise component with XML configs from core and custom admin.">
		<cfset var plugin = "" /><!--- Used in the loop of plugins --->
		<cfset var dirlist = "" /><!--- List of directories to check --->
		<cfset var thisdir = "" /><!--- Used in loop of directories --->
		<cfset var qCustomAdmin = queryNew("") />
		
		<!--- Put together a list of customadmin directories --->
		<cfset dirlist = listappend(dirlist,"#application.path.core#/config") />
		<cfloop list="#application.plugins#" index="plugin">
			<cfset dirlist = listappend(dirlist,expandpath("/farcry/plugins/#plugin#/customadmin")) />
		</cfloop>
		<cfset dirlist = listappend(dirlist,"#application.path.project#/customadmin") />
		
		<!--- Look for custom admin files in each directory --->
		<cfloop list="#dirlist#" index="thisdir">
			<!--- If any custom admin xml files exist, we need to add them to our custom admin XML array --->
			<cfif directoryExists("#thisdir#")>
				<cfdirectory action="list" directory="#thisdir#" filter="*.xml" name="qCustomAdmin" listinfo="name" />
				
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
	
	<cffunction name="fluchCache" access="public" returntype="void" output="false" hint="flush cached webtop setting for roles">

		<cfif structKeyExists(application, 'security') && structKeyExists(application.security, 'stPermissions') >	
			<cfset var currentRoles = application.security.getCurrentRoles()>
			<cfset var rolesHash    = hash("webtop-#currentRoles#")>
		
			<cfif structKeyExists(application.security.stPermissions, rolesHash)>
				<cfset StructDelete(application.security.stPermissions, rolesHash)>	
			</cfif>
		</cfif>	
	</cffunction>
	
	<cffunction name="loadWebtopFile" access="private" output="false" returntype="xml" hint="Loads a webtop xml file and returns is">
		<cfargument name="file" type="string" required="true" hint="The file to load" />
		
		<cfset var xmlResult = xmlnew() />
		<cfset var xslt = "" />
		
		<!--- Load the file --->
		<cffile action="read" file="#arguments.file#" variable="xmlResult" charset="utf-8" />
		
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
		<cfset var stResultTemp = structNew()>
		
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

			<cfcase value="delete">
				<cfset stResult = structNew()>
				<cfset stResult.children = structNew()>
				<cfset stResult.mergeType = "delete">
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
								<cfset stResultTemp = mergeWebtopStruct(stResult.children[id],arguments.struct2.children[id]) />
								<cfif stResultTemp.mergeType eq "delete">
									<cfset structDelete(stResult.children, id)>
								<cfelse>
									<cfset stResult.children[id] = stResultTemp />
								</cfif>
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
		
		<!--- Update children --->
		<cfparam name="arguments.item.children" default="#structNew()#" />
		<cfloop collection="#arguments.item.children#" item="id">
			<cfset updateDerivedAttributes(arguments.item.children[id],arguments.item.rbkey) />
		</cfloop>
		
		<!--- Update child order based on sequence values --->
		<cfset arguments.item.childorder = arraytolist(structsort(arguments.item.children,"numeric","asc","sequence")) />
		
		<!--- Tag specfic defaults --->
		<cfif structKeyExists(arguments.item, "itemtype")>
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
		</cfif>
		
		<cfreturn arguments.item />
	</cffunction>


	<cffunction name="getAllItems" access="public" output="false" returntype="struct" hint="Returns a translated webtop struct with all restricted items filtered out. This is a wrapper for getItem which will cache the resultant webtop structure.">

		<cfset var webtopPermissionID = application.security.factory.permission.getID(name="viewWebtopItem")>
		<cfset var currentRoles = application.security.getCurrentRoles()>
		<cfset var iRole = "">
		<cfset var rolesHash = hash("webtop-#currentRoles#")>
		<cfset var oBarnacle = application.fapi.getContentType("farBarnacle")>
		<cfset var stResult = structNew()>

		<cfif NOT structKeyExists(application.security.stPermissions, rolesHash)>
			<cfloop list="#currentRoles#" index="iRole">
				<cfset stResult = mergeWebtopRoleStruct(stResult, getItem(webtopPermissionID=webtopPermissionID, currentRoles=iRole, oBarnacle=oBarnacle)) />
			</cfloop>
			<cfset application.security.stPermissions[rolesHash] = stResult>
		</cfif>
		<cfset stResult = application.security.stPermissions[rolesHash]>

		<cfreturn stResult>
	</cffunction>

	
	<cffunction name="getItem" access="public" output="false" returntype="struct" hint="Returns a translated webtop struct with all restricted items filtered out">
		<cfargument name="parent" type="any" required="false" default="#this.stWebtop#" hint="The parent item to retrieve" />
		<cfargument name="honoursecurity" type="boolean" required="false" default="true" hint="Set to false to ignore security" />
		<cfargument name="duplicated" type="boolean" required="false" default="false" hint="Used to ensure the struct is only duplicated once" />
		<cfargument name="webtopPermissionID" type="string" required="false" default="" hint="The permission ID to use for determining webtop view permissions" />
		<cfargument name="currentRoles" type="string" required="false" default="" hint="A list of the roles of the current user" />
		<cfargument name="oBarnacle" required="false" default="" hint="A farBarnacle object used for rights lookups" />
		
		<cfset var stResult = this.stWebtop />
		<cfset var id = "" />
		<cfset var stTempResult = structnew() />
		<cfset var iRole = "">
		<cfset var bPermitted = "">
		<cfset var hashKey = "">
		<cfset var bRight = "">
		<cfset var barnacleID = "">
		<cfset var webtopAccessPermissionID = application.fapi.getContentType("farPermission").getID('admin')>
		<cfset var oRole = application.fapi.getContentType("farRole")>
		<cfset var stCurrentRole = "">
		
		<cfif NOT len(arguments.webtopPermissionID)>
			<cfset arguments.webtopPermissionID = application.security.factory.permission.getID(name="viewWebtopItem")>
		</cfif>
		<cfif NOT len(arguments.currentRoles)>
			<cfset arguments.currentRoles = application.security.getCurrentRoles()>
		</cfif>
		<cfif NOT isObject(arguments.oBarnacle)>
			<cfset arguments.oBarnacle = application.fapi.getContentType("farBarnacle")>
		</cfif>
		
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
			
			<cfset bPermitted = -1 />
			<cfset hashKey = hash("#webtopPermissionID#-#currentRoles#-#stResult.children[id].rbKey#") />

			<cfif structKeyExists(application.security.stPermissions, "#hashKey#")>
				<cfset bPermitted = application.security.stPermissions[hashKey] />
			<cfelse>
				<cfset barnacleID = hash(stResult.children[id].rbKey)>
				
				<cfloop list="#currentRoles#" index="iRole">
					
					<cfset stCurrentRole = application.fapi.getContentObject(typename="farRole", objectid="#iRole#")>
					
					<cfif application.fapi.arrayFind(stCurrentRole.aPermissions, webtopAccessPermissionID)>
						<cfset bRight = arguments.oBarnacle.getRight(role="#iRole#", permission="#webtopPermissionID#", object="#barnacleID#", objecttype="webtop")>
						
						<cfif bRight GTE 0>
							<cfset bPermitted = 1>
							<cfbreak>
						</cfif>
					</cfif>
				</cfloop>

				<cfset application.security.stPermissions[hashKey] = bPermitted />

			</cfif>

			
			<cfif not arguments.honoursecurity or bPermitted GTE 0>
				<cfset getItem(parent=stResult.children[id], honoursecurity=arguments.honoursecurity, duplicated=true, webtopPermissionID=arguments.webtopPermissionID, currentRoles=arguments.currentRoles, oBarnacle=arguments.oBarnacle) />
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
						<cfelse>
							<cfset stResult[attr] = application.rb.getResource("#stResult.rbkey#@#attr#",stResult[attr]) />
						</cfif>
						
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

	<cffunction name="getItemByID" output="false" returntype="struct">
		<cfargument name="stWebtop" type="struct" required="true">
		<cfargument name="id" type="string" required="true">

		<cfset var stItem = stWebtop>
		<cfset var item = "">

		<cfloop list="#arguments.id#" delimiters="." index="item">
			<cfset stItem = stItem.children[item]>
		</cfloop>

		<cfreturn stItem>
	</cffunction>

	<cffunction name="getItemDetails" output="false" returntype="struct">
		<cfargument name="stWebtop" type="struct" required="true">
		<cfargument name="id" type="string" required="true">

		<cfset var stItem = getItemByID(stWebtop, arguments.id)>
		<cfset var stParams = structNew()>
		<cfset var itemLink = "">
		<cfset var stResult = structNew()>

		<cfset stResult.bodyInclude = "">

		<cfset var urlUtil = createobject("component","farcry.core.packages.farcry.UrlUtility") />

		<cfif structKeyExists(stItem, "type")>
			<cfset stResult.typename = stItem.type>
		</cfif>
		<cfif structKeyExists(stItem, "typename")>
			<cfset stResult.typename = stItem.typename>
		</cfif>
		<cfif structKeyExists(stItem, "view")>
			<cfset stResult.view = stItem.view>
		</cfif>
		<cfif structKeyExists(stItem, "bodyView")>
			<cfset stResult.bodyView = stItem.bodyView>
		</cfif>
		<cfif structKeyExists(stItem, "alias")>
			<cfset stResult.alias = stItem.alias>
		</cfif>
		<cfif structKeyExists(stItem, "label")>
			<cfset stResult.label = stItem.label>
		</cfif>
		<cfif structKeyExists(stItem, "link")>
			<cfset itemLink = stItem.link>
		<cfelseif structKeyExists(stItem, "content")>
			<cfset itemLink = stItem.content>
		</cfif>

		<cfif len(itemLink)>	
			<cfset stParams = urlUtil.getURLParamStruct("?" & listLast(itemLink, "?")) />
			<cfset structAppend(url, stParams, false)>
			<cfif reFind("^/admin/customadmin.cfm", itemLink)>
				<cfif structKeyExists(stParams, "plugin") AND len(stParams.plugin)>
		 			<cfset stResult.bodyInclude = "/farcry/plugins/" & stParams.plugin & "/customadmin/" & stParams.module>
				<cfelse>
		 			<cfset stResult.bodyInclude = "/farcry/projects/#application.projectDirectoryName#/customadmin/" & stParams.module>
					<cfif NOT fileExists(expandPath(stResult.bodyInclude))>
		 				<cfset stResult.bodyInclude = "/farcry/core/webtop/customadmin/" & stParams.module>
					</cfif>
				</cfif>
			<cfelse>
				<cfset stResult.bodyInclude = "/farcry/core/webtop/" & itemLink>
			</cfif>
		</cfif>

		<cfreturn stResult>
	</cffunction>


	<cffunction name="mergeWebtopRoleStruct" access="public" output="false" returntype="struct" hint="A customised structMerge that will merge two webtop role structs and maintain the webtop childorder key">
		<cfargument name="struct1" type="struct" required="true" />
		<cfargument name="struct2" type="struct" required="true" />
		<cfargument name="overwrite" type="boolean" required="false" default="true" />

		<cfset var key = "">
		
		<!--- Loop Keys --->
		<cfloop collection="#arguments.struct2#" item="key">
			<!--- Find if the new key from struct2 Exists in struct1 --->
			<cfif StructKeyExists(arguments.struct1, key)>
				<!--- If they are both structs, we need to merge those structs, too --->
				<cfif IsStruct(arguments.struct1[key]) AND IsStruct(arguments.struct2[key])>
					<!--- Recursively call mergeWebtopRoleStruct to merge those structs --->
					<cfset mergeWebtopRoleStruct(arguments.struct1[key], arguments.struct2[key], arguments.overwrite) />
				<!--- We already checked that the key existed, now we just check if we can overwrite it --->
				<cfelseif arguments.overwrite>
					<cfset arguments.struct1[key] = arguments.struct2[key] />
				<!--- The unused case here is if overwrite is false, in which case struct1 is not changed --->
				</cfif>
			<!--- If it doesn't exist, you're free to merge --->
			<cfelse>
				<cfset arguments.struct1[key] = arguments.struct2[key] />
			</cfif>
		</cfloop>

		<!--- Update child order based on sequence values of filtered children --->
		<cfif structKeyExists(arguments.struct1, "childorder")>
			<cfset arguments.struct1.childorder = arraytolist(structsort(arguments.struct1.children,"numeric","asc","sequence")) />
		</cfif>

		<cfreturn arguments.struct1 />
	</cffunction>


</cfcomponent>