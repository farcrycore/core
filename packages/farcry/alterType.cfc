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
$Header: /cvs/farcry/core/packages/farcry/alterType.cfc,v 1.57.2.2 2005/12/30 01:07:10 paul Exp $
$Author: paul $
$Date: 2005/12/30 01:07:10 $
$Name:  $
$Revision: 1.57.2.2 $

|| DESCRIPTION ||
$Description: alter type/rule cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent>
	<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
	
	<cffunction name="refreshCFCAppData">
		<cfargument name="typename">
		<cfargument name="scope" required="false" default="types">
	
		<cfset var path = "" />
		<cfset var bCustomType = "" />
		<cfset var bCustomRule = "" />
		<cfset var bCustomFormtool = "" />
		<cfset var bLibraryType = "" />
		<cfset var bLibraryRule = "" />
		<cfset var bLibraryFormtool = "" />
		<cfset var o = "" />
		
		
		<!---//this now uses type path --->
		<cfif arguments.scope IS 'types' >
		
			<cfset path = application.types[arguments.typename].typePath />
			<cfset bCustomType = application.types[arguments.typename].bCustomType />
			<cfset bLibraryType = application.types[arguments.typename].bLibraryType />
			
			<cfparam name="application.types.#arguments.typename#" default="#structnew()#" />
			<cfset application.types[arguments.typename] = createObject("component", path).initMetaData(application.types[arguments.typename]) />
			<cfset application.types[arguments.typename].bCustomType = bCustomType />
			<cfset application.types[arguments.typename].bLibraryType = bLibraryType />
			<cfset application.types[arguments.typename].typePath = path />
			<cfset application.types[arguments.typename].packagePath = path />
			<cfset application.stcoapi[arguments.typename] = duplicate(application.types[arguments.typename]) />
		<cfelseif arguments.scope IS 'rules' >
	
			<cfset path = application.rules[arguments.typename].rulePath />
			<cfset bCustomRule = application.rules[arguments.typename].bCustomRule />
			<cfset bLibraryRule = application.rules[arguments.typename].bLibraryRule />
			
			<cfparam name="application.rules.#arguments.typename#" default="#structnew()#" />
			<cfset application.rules[arguments.typename] = createObject("Component", path).initmetadata(application.rules[arguments.typename]) />
			<cfset application.rules[arguments.typename].bCustomRule = bCustomRule />
			<cfset application.rules[arguments.typename].bLibraryRule = bLibraryRule />
			<cfset application.rules[arguments.typename].rulePath = path />
			<cfset application.rules[arguments.typename].packagePath = path />
			<cfset application.stcoapi[arguments.typename] = duplicate(application.rules[arguments.typename]) />
		<cfelseif  arguments.scope IS 'formtools' >
		
			<cfset path = application.formtools[arguments.typename].FormToolPath />
			<cfset bCustomFormTool = application.formtools[arguments.typename].bCustomFormTool />
			<cfset bLibraryFormtool = application.formtools[arguments.typename].bLibraryFormtool />
			
			<cfparam name="application.formtools.#arguments.typename#" default="#structnew()#" />
			<cfset application.formtools[arguments.typename] = createObject("component", path).initMetaData(application.formtools[arguments.typename]) />
			<cfset application.formtools[arguments.typename].bCustomFormTool = bCustomFormTool /> 
			<cfset application.formtools[arguments.typename].bLibraryFormtool = bLibraryFormtool /> 
			<cfset application.formtools[arguments.typename].FormToolPath = path />
			<cfset application.formtools[arguments.typename].packagePath = path />
			
		</cfif>
	</cffunction>
	
	<cffunction name="getIconPath" access="public" output="false" returntype="string" hint="Returns the path for the specified icon.">
		<cfargument name="iconname" type="string" required="true" hint="The name of the icon to retrieve" />
		<cfargument name="size" type="string" required="true" default="48" hint="The size of the icon required" />
		<cfargument name="default" type="string" required="false" default="custom.png" hint="The default icon to use" />
	
		<cfset var thisplugin = "" />
		<cfset var icon = lcase(arguments.iconname) />
		
		<cfif not find(".",icon)>
			<cfset icon = "#icon#.png" />
		</cfif>
	
		<cfif fileexists("#application.path.webroot#/wsimages/icons/#arguments.size#/#icon#")>
			<cfreturn "#application.path.webroot#/wsimages/icons/#arguments.size#/#icon#" />
		</cfif>
		<cfif fileexists("#application.path.webroot#/images/icons/#icon#")>
			<cfreturn "#application.path.webroot#/images/icons/#arguments.size#/#icon#" />
		</cfif>
		
		<cfloop list="#application.factory.oUtils.listReverse(application.plugins)#" index="thisplugin">
			<cfif fileexists("#application.path.project#/www/#thisplugin#/wsimages/icons/#arguments.size#/#icon#")>
				<cfreturn "#application.path.project#/www/#thisplugin#/wsimages/icons/#arguments.size#/#icon#" />
			</cfif>
			<cfif fileexists("#application.path.plugins#/#thisplugin#/www/wsimages/icons/#arguments.size#/#icon#")>
				<cfreturn "#application.path.plugins#/#thisplugin#/www/wsimages/icons/#arguments.size#/#icon#" />
			</cfif>
		</cfloop>
		
		<cfif fileexists("#application.path.core#/webtop/icons/#arguments.size#/#icon#")>
			<cfreturn "#application.path.core#/webtop/icons/#arguments.size#/#icon#" />
		</cfif>	
		
		<!--- If all else fails, check to see if the icon is located under the image root --->
		<cfif fileexists("#application.path.imageRoot##arguments.iconname#")>
			<cfreturn "#application.path.imageRoot##arguments.iconname#" />
		</cfif>
	
		<cfreturn "#application.path.core#/webtop/icons/#arguments.size#/#arguments.default#" />
	</cffunction>
	
	<cffunction name="setupMetadataQuery" output="false" displayname="Sets up the metadata query containing formtool structure information" returntype="query" access="private">
		
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="stProps" type="struct" required="true" />
		
		
		<cfset var qMetadataSetup = queryNew("typename,propertyname,ftSeq,ftFieldset,ftwizardStep,ftType,fthelptitle,fthelpsection","varchar,varchar,Integer,varchar,varchar,varchar,varchar,varchar") /><!--- Prepare a temporary metadata query that will later be sorted and sent into the types metadata structure. --->
		<cfset var qMetadata = queryNew("typename,propertyname,ftSeq,ftFieldset,ftwizardStep,ftType,fthelptitle,fthelpsection","varchar,varchar,Integer,varchar,varchar,varchar,varchar,varchar") /><!--- Prepare a temporary metadata query that will later be sorted and sent into the types metadata structure. --->	
		<cfset var Seq = "" />
		<cfset var Fieldset = "" />
		<cfset var wizardStep = "" />
		<cfset var Type = "" />
		<cfset var helpTitle="" />
		<cfset var helpSection="" />
		<cfset var i = "" />
		
		<!--------------------------------- 
		WE NEED TO SETUP FTSEQ, FTFIELDSET & FTwizardSTEP
		THESE PROPERTIES ARE USED TO AUTOMATICALLY RENDER FORMS (BOTH DISPLAY AND EDIT) BASED ON THE METADATA IF NO EDIT OR DISPLAY METHOD ARE PROVIDED.
		 --------------------------------->
					
		<cfloop list="#structKeyList(arguments.stProps)#" index="i">
			
			<!--- SETUP FTSEQ --->
			<cfif structKeyExists(arguments.stProps[i].METADATA, "ftSeq")>
				<cfset Seq = arguments.stProps[i].METADATA.ftSeq />
			<cfelse>
				<cfif i EQ"label">
					<cfset Seq = 0 /><!--- Label is first unless overridden --->
				<cfelse>
					<cfset Seq = 99999 /><!--- fields without ftSeq metadata are placed last in the form --->
				</cfif>
				
			</cfif>
			
			<!--- SETUP FTFIELDSET --->
			<cfif structKeyExists(arguments.stProps[i].METADATA, "ftFieldset")>
				<cfset Fieldset = arguments.stProps[i].METADATA.ftFieldset />
			<cfelse>
				<cfset Fieldset = typename />
			</cfif>
			
			<!--- SETUP FTwizardSTEP --->
			<cfif structKeyExists(arguments.stProps[i].METADATA, "ftwizardStep")>
				<cfset wizardStep = arguments.stProps[i].METADATA.ftwizardStep />
			<cfelse>
				<cfset wizardStep = typename />
			</cfif>
			
			<!--- SETUP ftType --->
			<cfif structKeyExists(arguments.stProps[i].METADATA, "ftType") AND len(arguments.stProps[i].METADATA.ftType)>
				<cfset Type = arguments.stProps[i].METADATA.ftType />
			<cfelse>
				<cfset Type = arguments.stProps[i].METADATA.type />
			</cfif>
			
			<!--- setup fthelptitle and fthelpsection --->
			<cfif structkeyexists(arguments.stProps[i].METADATA, "ftHelpTitle")>
				<cfset helpTitle = arguments.stProps[i].METADATA.ftHelpTitle />
			<cfelse>
				<cfset helpTitle = "" />
			</cfif>
			<cfif structkeyexists(arguments.stProps[i].METADATA, "ftHelpSection")>
				<cfset helpSection = arguments.stProps[i].METADATA.ftHelpSection />
			<cfelse>
				<cfset helpSection = "" />
			</cfif>
			
		   <cfset temp = QueryAddRow(qMetadataSetup)>
		   <cfset Temp = QuerySetCell(qMetadataSetup,"typename", typename) />
		   <cfset Temp = QuerySetCell(qMetadataSetup,"propertyname", i) />
		   <cfset Temp = QuerySetCell(qMetadataSetup,"ftSeq", val(Seq)) />
		   <cfset Temp = QuerySetCell(qMetadataSetup,"ftFieldset", Fieldset) />
		   <cfset Temp = QuerySetCell(qMetadataSetup,"ftwizardStep", wizardStep) />
		   <cfset Temp = QuerySetCell(qMetadataSetup,"ftType", Type) />
		   <cfset querySetCell(qMetadataSetup,"ftHelpTitle", helpTitle) />
		   <cfset querySetCell(qMetadataSetup,"ftHelpSection", helpSection) />
						
			
		</cfloop>
		
		<!--- Now we have all the metadata in qMetadataSetup, we sort and send into the qMetadata key. --->
		<cfquery dbType="query" name="qMetadata">
		SELECT * FROM qMetadataSetup
		ORDER BY ftSeq
		</cfquery>
		
		<cfreturn qMetadata />
	
	
	</cffunction>
	
	<cffunction name="getCOAPIMetadata" returntype="struct" access="public" output="true" hint="Creates and returns a COAPI metadata struct">
		<cfargument name="package" type="string" required="true" hint="The package the content type is in" />
		<cfargument name="name" type="string" required="true" hint="The name of the content type" />
		
		<cfset var stResult = structnew() /><!--- Metadata struct --->
		<cfset var o = "" /><!--- Instantiated component --->
		<cfset var stMetadata = structnew() /><!--- Component metadata --->
		<cfset var tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() /><!--- Table metadata collection --->
		
		<!--- <cftry> --->
			<cfset stResult.packagepath = application.factory.oUtils.getPath(arguments.package,arguments.name) />
			<cfset stResult.package = arguments.package />
			
			<cfset o = createObject("Component", stResult.packagepath) />		
			<cfset stMetaData = getMetaData(o) />
			
			<cfif structKeyExists(stMetaData,"bAbstract") and stMetaData.bAbstract>
			
				<cfset stResult = structnew() />
				
			<cfelse>
				
				<cfset stResult.bCustom = (refindnocase("farcry\.core",stResult.packagepath)) />
				<cfset stResult.bLibrary = (refindnocase("farcry\.plugins",stResult.packagepath)) />
				
				<cfset stResult = o.initmetadata(stResult) />
				
				<cfparam name="stResult.icon" default="#arguments.name#" />
				
				
				<cfif listcontains("types,rules,forms,schema",arguments.package)>
					
					<!--- Query of metadata used for auto generation of HTML forms --->
					<cfset stResult.qMetadata = setupMetadataQuery(typename=arguments.name,stProps=stResult.stProps) />
				</cfif>
				
				<cfif listcontains("types,rules,schema",arguments.package)>
					
					<!--- Update DB metadata --->
					<cfset application.fc.lib.db.initialiseTableMetadata(stResult.packagepath) />
					
				</cfif>
				
				<cfparam name="stResult.bObjectBroker" default="false" />
				
				<cfswitch expression="#arguments.package#">
					<cfcase value="types">
						<cfset stResult.typepath = stResult.packagepath />
						<cfset stResult.bCustomType = stResult.bCustom />
						<cfset stResult.bLibraryType = stResult.bLibrary />
						<cfset stResult.class = "type" />
					</cfcase>
					<cfcase value="rules">
						<cfset stResult.rulepath = stResult.packagepath />
						<cfset stResult.bCustomRule = stResult.bCustom />
						<cfset stResult.bLibraryRule = stResult.bLibrary />
						<cfset stResult.class = "rule" />
					</cfcase>
					<cfcase value="forms">
						<cfset stResult.formpath = stResult.packagepath />
						<cfset stResult.bCustomForm = stResult.bCustom />
						<cfset stResult.bLibraryForm = stResult.bLibrary />
						<cfset stResult.class = "form" />
					</cfcase>
					<cfcase value="formtools">
						<cfset stResult.formtoolpath = stResult.packagepath />
						<cfset stResult.bCustomFormTool = stResult.bCustom />
						<cfset stResult.bLibraryFormTool = stResult.bLibrary />
						<cfset stResult.fuAlias = arguments.name />
						<cfset stResult.oFactory = o.init() />
						<cfset stResult.class = "formtool" />
					</cfcase>
					<cfcase value="schema">
						<cfset stResult.class = "schema" />
					</cfcase>
				</cfswitch>
				
			</cfif>
		
			<!--- <cfcatch>
				<cflog file="coapi" type="error" text="#application.applicationname#: Failed to initialise core type '#arguments.package#.#arguments.name#'" />
			</cfcatch>
		</cftry> --->
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="updateJoins" output="false" hint="Returns an array of the joins to and from the specified type">
		<cfargument name="stCOAPI" type="struct" required="true" hint="The COAPI metadata struct" />
		
		<cfset var thistype = "" />
		<cfset var thisproperty = "" />
		<cfset var othertype = "" />
		<cfset var stJoin = structnew() />
		
		<cfloop collection="#arguments.stCOAPI#" item="thistype">
			<cfparam name="arguments.stCOAPI.#thistype#.aJoins" default="#arraynew(1)#" />
			
			<cfloop collection="#arguments.stCOAPI[thistype].stProps#" item="thisproperty">
				<cfif listcontainsnocase("array,uuid",arguments.stCOAPI[thistype].stProps[thisproperty].metadata.type) and structkeyexists(arguments.stCOAPI[thistype].stProps[thisproperty].metadata,"ftJoin")>
					<cfloop list="#arguments.stCOAPI[thistype].stProps[thisproperty].metadata.ftJoin#" index="othertype">
						<cfif structkeyexists(arguments.stCOAPI,othertype)>
							<cfset stJoin = structnew() />
							<cfset stJoin.coapitype = othertype />
							<cfset stJoin.coapitypeother = thistype />
							<cfset stJoin.class = arguments.stCOAPI[othertype].class />
							<cfset stJoin.property = thisproperty />
							<cfset stJoin.direction = "to" />
							<cfset stJoin.type = arguments.stCOAPI[thistype].stProps[thisproperty].metadata.type />
							<cfset arrayappend(arguments.stCOAPI[thistype].aJoins,stJoin) />
							
							<cfset stJoin = duplicate(stJoin) />
							<cfset stJoin.coapitype = thistype />
							<cfset stJoin.coapitypeother = othertype />
							<cfset stJoin.class = arguments.stCOAPI[thistype].class />
							<cfset stJoin.direction = "from" />
							<cfset arrayappend(arguments.stCOAPI[othertype].aJoins,stJoin) />
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfloop>
	</cffunction>
	
	<cffunction name="refreshAllCFCAppData" output="true" hint="Inserts the metadata information for each cfc into the application scope.">
		<cfargument name="dsn" required="No" default="#application.dsn#">
		<cfargument name="dbowner" required="No" default="#application.dbowner#">
		
		<cfset var thispackage = "" />
		<cfset var thistype = "" />
		<cfset var stMetadata = structnew() />
		<cfset var i = structnew() />
		<cfset var qTypeWatcherWebskins = "" />
		
		<cfset application.stCOAPI = structnew() />
				
		<cfloop list="formtools,types,rules,forms,schema" index="thispackage">
			<cfset application[thispackage] = structnew() />
			
			<cfloop list="#application.factory.oUtils.getComponents(thispackage)#" index="thistype">
				<cfset stMetadata = getCOAPIMetadata(thispackage,thistype) />
				
				<cfif not structisempty(stMetadata)>
					<cfif listcontains("types,rules,forms",thispackage)>
						<!--- Only FourQ components in stCOAPI --->
						<cfset application.stCOAPI[thistype] = stMetadata />
					</cfif>
					<cfset application[thispackage][thistype] = stMetadata />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfloop list="#structKeyList(application.stCOAPI)#" index="thistype">
			<cfset qTypeWatcherWebskins = application.stCOAPI[thistype].qWebskins />
			<cfquery dbtype="query" name="qTypeWatcherWebskins">
				SELECT *
				FROM qTypeWatcherWebskins
				WHERE cacheTypeWatch <> ''
			</cfquery>
			<cfloop query="qTypeWatcherWebskins">
				<cfloop list="#qTypeWatcherWebskins.cacheTypeWatch#" index="i">
					<cfif not structKeyExists(application.stCOAPI[i].stTypeWatchWebskins, thistype)>
						<cfset application.stCOAPI[i].stTypeWatchWebskins[thisType] = arrayNew(1) />
					</cfif>
					<cfset arrayAppend(application.stCOAPI[i].stTypeWatchWebskins[thisType], qTypeWatcherWebskins.methodname) />
				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfset updateJoins(application.stCOAPI) />
	</cffunction>

</cfcomponent>
