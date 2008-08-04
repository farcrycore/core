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

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cffunction name="getDataType">
	<cfargument name="cfctype" required="true" />
	<cfargument name="bReturnTypeOnly" required="No" default="false" />

	<cfscript>
		stDefaultTypes = getTypeDefaults();
		type = stDefaultTypes[arguments.cfctype].type;
		length = stDefaultTypes[arguments.cfctype].length;
		switch (type){
			case "varchar":case "varchar2":case "nvarchar":
			{
				datatype=type;
				if (not arguments.bReturnTypeOnly)
					datatype = datatype & '(#length#)';
				break;
			}

			default:{
			datatype = type;
			}
		}
	</cfscript>
	<cfreturn datatype />
</cffunction>

<cffunction name="dropArrayTable">
	<cfargument name="typename" required="true" />
	<cfargument name="property" required="true" />
	<cfargument name="dsn" default="#application.dsn#" required="false" />

	<cfquery datasource="#arguments.dsn#">
	DROP TABLE #application.dbowner##arguments.typename#_#arguments.property#
	</cfquery>
</cffunction>

<cffunction name="deployArrayProperty">
	<cfargument name="typename" required="true">
	<cfargument name="property" required="true">


	<cfif not structKeyExists(application.stCoapi,arguments.typeName)>
		<cfthrow type="AlterType" message="Type does not exists"  >
	</cfif>

	<cfset createObject("component", "#application.stCoapi[arguments.typename].packagePath#").deployArrayTable(bTestRun='0',parent='#application.dbowner##arguments.typename#',property=arguments.property)>

</cffunction>

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
	
	<cfset arguments.iconname = lcase(arguments.iconname) />
	<cfif not find(".",arguments.iconname)>
		<cfset arguments.iconname = "#arguments.iconname#.png" />
	</cfif>

	<cfif fileexists("#application.path.project#/www/wsimages/icons/#arguments.size#/#arguments.iconname#")>
		<cfreturn "#application.url.webroot#/wsimages/icons/#arguments.size#/#arguments.iconname#" />
	</cfif>
	<cfif fileexists("#application.path.project#/www/images/icons/#arguments.iconname#")>
		<cfreturn "#application.url.webroot#/images/icons/#arguments.size#/#arguments.iconname#" />
	</cfif>
	
	<cfloop list="#application.factory.oUtils.listReverse(application.plugins)#" index="thisplugin">
		<cfif fileexists("#application.path.project#/www/#thisplugin#/wsimages/icons/#arguments.size#/#arguments.iconname#")>
			<cfreturn "#application.url.webroot#/#thisplugin#/wsimages/icons/#arguments.size#/#arguments.iconname#" />
		</cfif>
		<cfif fileexists("#application.path.plugins#/#thisplugin#/www/wsimages/icons/#arguments.size#/#arguments.iconname#")>
			<cfreturn "#application.url.webroot#/#thisplugin#/wsimages/icons/#arguments.size#/#arguments.iconname#" />
		</cfif>
	</cfloop>
	
	<cfif fileexists("#application.path.core#/webtop/icons/#arguments.size#/#arguments.iconname#")>
		<cfreturn "#application.url.webtop#/icons/#arguments.size#/#arguments.iconname#" />
	</cfif>
	
	<cfreturn "#application.url.webtop#/icons/#arguments.size#/#arguments.default#" />
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
		<cfif structKeyExists(arguments.stProps[i].METADATA, "ftType")>
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


<cffunction name="refreshAllCFCAppData" output="true" hint="Inserts the metadata information for each cfc into the application scope.">
	<cfargument name="dsn" required="No" default="#application.dsn#">
	<cfargument name="dbowner" required="No" default="#application.dbowner#">
	
	<cfset var o = "" /><!--- This will contain the object as we iterate through each cfc --->
	<cfset var typename = "" /><!--- this will contain the typename as we iterate through each cfc  --->	
	<cfset var qDir = queryNew("name") /><!--- This will contain the directory listing --->
	<cfset var qExtendedTypesDir = queryNew("name") /><!--- This will contain the directory listing --->
	<cfset var qCustomTypesDir = queryNew("name") /><!--- This will contain the directory listing --->
	<cfset var qCustomFormToolsTypesDir = queryNew("name") /><!--- This will contain the directory listing --->
	<cfset var qFormsDir = queryNew("name") /><!--- This will contain the directory listing --->
	<cfset var qCustomFormsTypesDir = queryNew("name") /><!--- This will contain the directory listing --->

	<cfset var stTypeMD = structNew() />
	
	<cfset application.types = structNew() />
	<cfset application.formtools = structNew() />
	<cfset application.rules = structNew() />	
	<cfset application.forms = structNew() />	
	<cfset application.stcoapi = structNew() />
	 
	<!--- Find all types, base, extended & custom --->
	<cfif directoryExists("#application.path.core#/packages/types")>
		<cfdirectory action="list" directory="#application.path.core#/packages/types" name="qDir" filter="*.cfc" sort="name" />
	</cfif>
	<cfif directoryExists("#application.path.project#/packages/system")>
		<cfdirectory action="list" directory="#application.path.project#/packages/system" name="qExtendedTypesDir" filter="*.cfc" sort="name" />
	</cfif>
	<cfif directoryExists("#application.path.project#/packages/types")>
		<cfdirectory action="list" directory="#application.path.project#/packages/types" name="qCustomTypesDir" filter="*.cfc" sort="name" />
	</cfif>
	

	<!--------------------------------------------
	// Init all CORE types 
	---------------------------------------------->
	<cfloop query="qDir">
			
		<cftry>
			<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
			<cfset o = createObject("Component", "#application.packagepath#.types.#typeName#") />		
			<cfset stMetaData = getMetaData(o) />
	
			<cfif not structKeyExists(stMetaData,"bAbstract") or stMetaData.bAbstract EQ "False">
				<cfset stTypeMD = structNew() />
				<cfparam name="application.types.#typename#" default="#structNew()#" />
				
				<cfset stTypeMD = o.initmetadata(application.types[typename]) />
				<cfset stTypeMD.bCustomType = 0 />
				<cfset stTypeMD.bLibraryType = 0 />
				<cfset stTypeMD.typePath = "#application.packagepath#.types.#typename#" />
				<cfset stTypeMD.packagePath = "#application.packagepath#.types.#typename#" />
				
				<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
				<cfif not find(".",stTypeMD.icon)>
					<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
				</cfif>
				
				<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
				<cfset application.types[typename]=duplicate(stTypeMD) />
	
			<cfelse>
				<!--- Remove typename if it is an abstract class. --->
				<cfset structDelete(application.types, typename) />
			</cfif>
		
		<cfcatch>
			<cfoutput><h2>Failed to initialise core type: #qDir.name#</h2></cfoutput>
			<cfdump var="#cfcatch#" expand="false" label="Init Error" />
			<cfabort>
		</cfcatch>
		</cftry>
		
	</cfloop>
	
	<!--------------------------------------------
	// Init all PLUGIN types 
	---------------------------------------------->
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>

		<cfloop list="#application.plugins#" index="plugin">
			
			<cfif directoryExists("#application.path.plugins#/#plugin#/packages/types")>
			
				<cfdirectory directory="#application.path.plugins#/#plugin#/packages/types" name="qDir" filter="*.cfc" sort="name">
					
				<cfloop query="qDir">
					<cftry>
						<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
						<cfset o = createObject("Component", "farcry.plugins.#plugin#.packages.types.#typename#") />			
						<cfset stMetaData = getMetaData(o) />
						<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">
							
							<cfset stTypeMD = structNew() />
							<cfparam name="application.types.#typename#" default="#structNew()#" />
							
							<cfset stTypeMD = o.initmetadata(application.types[typename]) />
							<cfset stTypeMD.bCustomType = 1 />
							<cfset stTypeMD.bLibraryType = 1 />
							<cfset stTypeMD.typePath = "farcry.plugins.#plugin#.packages.types.#typename#" />							
							<cfset stTypeMD.packagePath = "farcry.plugins.#plugin#.packages.types.#typename#" />
				
							<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
							<cfif not find(".",stTypeMD.icon)>
								<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
							</cfif>
				
							<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
							<cfset application.types[typename]=duplicate(stTypeMD) />
						</cfif>	
					
					<cfcatch>
						<cflog application="true" log="Application" type="warning" text="Failed to initialise #plugin# component #qDir.name#; #cfcatch.message# (#cfcatch.detail#).">
					</cfcatch>
					</cftry>
				</cfloop>
				
			</cfif>
			
		</cfloop>	
		
	</cfif>

	
	<!--------------------------------------------
	// Init all EXTENDED CORE types 
	---------------------------------------------->
	<cfloop query="qExtendedTypesDir">

		<cftry>
			<cfset typename = left(qExtendedTypesDir.name, len(qExtendedTypesDir.name)-4) /> <!---remove the .cfc from the filename --->
			<cfset o = createObject("Component", "#application.custompackagepath#.system.#typename#") />			
			<cfset stMetaData = getMetaData(o) />
			<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
			
				<cfset stTypeMD = structNew() />
				<cfparam name="application.types.#typename#" default="#structNew()#" />
				
				<cfset stTypeMD = o.initMetaData(application.types[typename]) />
				<cfset stTypeMD.bCustomType = 0 />
				<cfset stTypeMD.bLibraryType = 0 />
				<cfset stTypeMD.typePath = "#application.custompackagepath#.system.#typename#" />				
				<cfset stTypeMD.packagePath = "#application.custompackagepath#.system.#typename#" />
				
				<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
				<cfif not find(".",stTypeMD.icon)>
					<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
				</cfif>
				
				<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
				<cfset application.types[typename]=duplicate(stTypeMD) />
			</cfif>

		<cfcatch>
			<cflog application="true" log="Application" type="warning" text="Failed to initialise extended component #qExtendedTypesDir.name#; #cfcatch.message# (#cfcatch.detail#).">
		</cfcatch>
		</cftry>
				
	</cfloop>
	
	
	<!--------------------------------------------
	// Init all Project Custom Types 
	---------------------------------------------->
	<cfloop query="qCustomTypesDir">

		<cftry>
			<cfset typename = left(qCustomTypesDir.name, len(qCustomTypesDir.name)-4)> <!---//remove the .cfc from the filename --->
			<cfset o = createObject("Component", "#application.custompackagepath#.types.#typename#") />			
			<cfset stMetaData = getMetaData(o) />
			<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			

				<cfset stTypeMD = structNew() />
				<cfparam name="application.types.#typename#" default="#structNew()#" />
				
				<cfset stTypeMD = o.initMetaData(application.types[typename]) />
				<cfset stTypeMD.bCustomType = 1 />
				<cfset stTypeMD.bLibraryType = 0 />
				<cfset stTypeMD.typePath = "#application.custompackagepath#.types.#typename#" />
				<cfset stTypeMD.packagePath = "#application.custompackagepath#.types.#typename#" />
				
				<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
				<cfif not find(".",stTypeMD.icon)>
					<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
				</cfif>
				
				<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
				<cfset application.types[typename]=duplicate(stTypeMD) />
			</cfif>
		
		<cfcatch>
			<cflog application="true" log="Application" type="warning" text="Failed to initialise custom component #qCustomTypesDir.name#; #cfcatch.message# (#cfcatch.detail#).">
		</cfcatch>
		</cftry>
		
	</cfloop>
	
	

	<!--- FormTools specific Types --->
	<cfif directoryExists("#application.path.core#/packages/formtools")>
		<cfdirectory directory="#application.path.core#/packages/formtools" name="qFormToolsTypesDir" filter="*.cfc" sort="name">
	</cfif>
	
	<!--- Init all CORE FormTools Types --->
	<cfloop query="qFormToolsTypesDir">

			<cfset formtoolname = left(qFormToolsTypesDir.name, len(qFormToolsTypesDir.name)-4) /><!--- //remove the .cfc from the filename --->			
			<cfset oFactory = createObject("Component", "#application.packagepath#.formtools.#formtoolname#").init() />

			<cfset stMetaData = getMetaData(oFactory) />
			<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
				
				<cfset stTypeMD = structNew() />
				<cfparam name="application.formtools.#formtoolname#" default="#structNew()#" />
				
				<cfset stTypeMD.bCustomformtool = 0 />
				<cfset stTypeMD.bLibraryformtool = 0 />
				<cfset stTypeMD.formtoolPath = "#application.packagepath#.formtools.#formtoolname#" />
				<cfset stTypeMD.packagePath = "#application.packagepath#.formtools.#formtoolname#" />
				
				<cfparam name="stTypeMD.icon" default="#LCase(formtoolname)#" />
				<cfif not find(".",stTypeMD.icon)>
					<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
				</cfif>
				
				<cfset application.formtools[formtoolname] = duplicate(stTypeMD) />
				<cfset application.formtools[formtoolname].oFactory = oFactory /><!--- you can't duplicate an object --->
			</cfif>
	</cfloop>	
	
	
	
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>

		<cfloop list="#application.plugins#" index="plugin">
			
			<cfif directoryExists("#application.path.plugins#/#plugin#/packages/formtools")>
			
				<cfdirectory directory="#application.path.plugins#/#plugin#/packages/formtools" name="qDir" filter="*.cfc" sort="name">
				
				<!--- Init all PLUGIN types --->
				<cfloop query="qDir">

						
						<cfset formtoolname = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
						
							<cfset oFactory = createObject("Component", "farcry.plugins.#plugin#.packages.formtools.#formtoolname#").init() />
							<cfset stMetaData = getMetaData(oFactory) />
							<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
								<cfset stTypeMD = structNew() />
								<cfparam name="application.formtools.#formtoolname#" default="#structNew()#" />

								<cfset stTypeMD.bCustomformtool = 1 />
								<cfset stTypeMD.bLibraryformtool = 1 />
								<cfset stTypeMD.formtoolPath = "farcry.plugins.#plugin#.packages.formtools.#formtoolname#" />
								<cfset stTypeMD.packagePath = "farcry.plugins.#plugin#.packages.formtools.#formtoolname#" />
				
								<cfparam name="stTypeMD.icon" default="#LCase(formtoolname)#" />
								<cfif not find(".",stTypeMD.icon)>
									<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
								</cfif>
				
								<cfset application.formtools[formtoolname] = duplicate(stTypeMD) />
								<cfset application.formtools[formtoolname].oFactory = oFactory /><!--- you can't duplicate an object --->
							</cfif>

				</cfloop>
				
			</cfif>
			
		</cfloop>	
		
	</cfif>	
	
	
	<!--- Init all PROJECCT FORMTOOL types --->
	<cfif directoryExists("#application.path.project#/packages/formtools")>
		<cfdirectory directory="#application.path.project#/packages/formtools" name="qCustomFormToolsTypesDir" filter="*.cfc" sort="name">
	</cfif>
	
	<cfloop query="qCustomFormToolsTypesDir">

			<cfset formtoolname = left(qCustomFormToolsTypesDir.name, len(qCustomFormToolsTypesDir.name)-4) /><!--- //remove the .cfc from the filename --->	
			<cfset oFactory = createObject("Component", "#application.custompackagepath#.formtools.#formtoolname#")>	
			<cfset stMetaData = getMetaData(o) />
			<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
				<cfset stTypeMD = structNew() />
				<cfparam name="application.formtools.#formtoolname#" default="#structNew()#" />			
				
				<cfset stTypeMD.bCustomformtool = 1 />
				<cfset stTypeMD.bLibraryformtool = 0 />
				<cfset stTypeMD.formtoolPath = "#application.custompackagepath#.formtools.#formtoolname#" />
				<cfset stTypeMD.packagePath = "#application.custompackagepath#.formtools.#formtoolname#" />
				
				<cfparam name="stTypeMD.icon" default="#LCase(formtoolname)#" />
				<cfif not find(".",stTypeMD.icon)>
					<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
				</cfif>
				
				<cfset application.formtools[formtoolname] = duplicate(stTypeMD) />
				<cfset application.formtools[formtoolname].oFactory = oFactory /><!--- you can't duplicate an object --->
			</cfif>
	</cfloop>
	

	<!--- 
	 FORMS
	 --->
	<cfif directoryExists("#application.path.core#/packages/forms")>
		<cfdirectory directory="#application.path.core#/packages/forms" name="qFormsDir" filter="*.cfc" sort="name">
	
		<!--- Init all CORE FORMS --->
		<cfloop query="qFormsDir">
	
				<cfset formname = left(qFormsDir.name, len(qFormsDir.name)-4) /><!--- //remove the .cfc from the filename --->			
				<cfset oFactory = createObject("Component", "#application.packagepath#.forms.#formname#").init() />
	
				<cfset stMetaData = getMetaData(oFactory) />
				<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">
					<cfset stTypeMD = structnew() />
					<cfparam name="application.forms.#formname#" default="#structNew()#" />
					<cfset stTypeMD = oFactory.initmetadata(application.forms[formname]) />
					<cfset stTypeMD.bCustomForm = 0 />
					<cfset stTypeMD.bLibraryForm = 0 />
					<cfset stTypeMD.formPath = "#application.packagepath#.forms.#formname#" />
					<cfset stTypeMD.packagePath = "#application.packagepath#.forms.#formname#" />
					<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=formname,stProps=stTypeMD.stProps) />
					<cfset application.forms[formname] = duplicate(stTypeMD) />
				</cfif>
		</cfloop>	
	</cfif>
	
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>

		<cfloop list="#application.plugins#" index="plugin">
			
			<cfif directoryExists("#application.path.plugins#/#plugin#/packages/forms")>
			
				<cfdirectory directory="#application.path.plugins#/#plugin#/packages/forms" name="qDir" filter="*.cfc" sort="name">
				
				<!--- Init all PLUGIN types --->
				<cfloop query="qDir">

					<cfset formname = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
					
					<cfset oFactory = createObject("Component", "farcry.plugins.#plugin#.packages.forms.#formname#").init() />
					<cfset stMetaData = getMetaData(oFactory) />
					<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">
						<cfset stTypeMD = structnew() />
						<cfparam name="application.forms.#formname#" default="#structNew()#" />
						<cfset stTypeMD = oFactory.initmetadata(application.forms[formname]) />
						<cfset stTypeMD.bCustomForm = 1 />
						<cfset stTypeMD.bLibraryForm = 1 />
						<cfset stTypeMD.formPath = "farcry.plugins.#plugin#.packages.forms.#formname#" />
						<cfset stTypeMD.packagePath = "farcry.plugins.#plugin#.packages.forms.#formname#" />
						<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=formname,stProps=stTypeMD.stProps) />
						
						<cfset application.forms[formname] = duplicate(stTypeMD) />
					</cfif>

				</cfloop>
				
			</cfif>
			
		</cfloop>	
		
	</cfif>	
	
	
	<!--- Init all PROJECT FORMS --->
	
	<cfif directoryExists("#application.path.project#/packages/forms")>
		<cfdirectory directory="#application.path.project#/packages/forms" name="qCustomFormsTypesDir" filter="*.cfc" sort="name">
	
	
		<cfloop query="qCustomFormsTypesDir">
	
			<cfset formname = left(qCustomFormsTypesDir.name, len(qCustomFormsTypesDir.name)-4) /><!--- //remove the .cfc from the filename --->	
			<cfset oFactory = createObject("Component", "#application.custompackagepath#.forms.#formname#")>	
			<cfset stMetaData = getMetaData(o) />
			<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">
				<cfset stTypeMD = structnew() />
				<cfparam name="application.forms.#formname#" default="#structNew()#" />
				<cfset stTypeMD = oFactory.initmetadata(application.forms[formname]) />
				<cfset stTypeMD.bCustomForm = 1 />
				<cfset stTypeMD.bLibraryForm = 0 />
				<cfset stTypeMD.formPath = "#application.custompackagepath#.forms.#formname#" />
				<cfset stTypeMD.packagePath = "#application.custompackagepath#.forms.#formname#" />
				<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=formname,stProps=stTypeMD.stProps) />
				<cfset application.forms[formname] = duplicate(stTypeMD) />
			</cfif>
		</cfloop>		
	</cfif>	
	
	<!---
	RULES
	 --->
	 
	<!--- INIT THE CONTAINER OBJECT ---> 
	<cfif directoryExists("#application.path.core#/packages/rules")>
		<cfdirectory directory="#application.path.core#/packages/rules" name="qDir" filter="container.cfc" sort="name">
	
		
		<cfloop query="qDir">
			<cfif qDir.name NEQ "rules.cfc">
	
					
					<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
					<cfset o = createObject("Component", "#application.packagepath#.rules.#typename#") />			
					<cfset stMetaData = getMetaData(o) />
					<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
					
						<cfset stTypeMD = structNew() />
						<cfparam name="application.rules.#typename#" default="#structNew()#" />
						<cfset stTypeMD = o.initmetadata(application.rules[typename]) />
						<cfset stTypeMD.bCustomRule = 0 />
						<cfset stTypeMD.bLibraryRule = 0 />
						<cfset stTypeMD.rulePath = "#application.packagepath#.rules.#typename#" />					
						<cfset stTypeMD.packagePath = "#application.packagepath#.rules.#typename#" />
					
						<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
						<cfif not find(".",stTypeMD.icon)>
							<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
						</cfif>
					
						<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
						<cfset application.rules[typename] = duplicate(stTypeMD) />
					</cfif>
	
			</cfif>
		</cfloop>
	</cfif>


	 
	 
	<!--- Init all CORE RULES --->
	<cfif directoryExists("#application.path.core#/packages/rules")>
		<cfdirectory directory="#application.path.core#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">
		
		<cfloop query="qDir">
			<cfif qDir.name NEQ "rules.cfc">
	
					
					<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
					<cfset o = createObject("Component", "#application.packagepath#.rules.#typename#") />			
					<cfset stMetaData = getMetaData(o) />
					<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
					
						<cfset stTypeMD = structNew() />
						<cfparam name="application.rules.#typename#" default="#structNew()#" />
						<cfset stTypeMD = o.initmetadata(application.rules[typename]) />
						<cfset stTypeMD.bCustomRule = 0 />
						<cfset stTypeMD.bLibraryRule = 0 />
						<cfset stTypeMD.rulePath = "#application.packagepath#.rules.#typename#" />					
						<cfset stTypeMD.packagePath = "#application.packagepath#.rules.#typename#" />
					
						<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
						<cfif not find(".",stTypeMD.icon)>
							<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
						</cfif>
					
						<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
						<cfset application.rules[typename] = duplicate(stTypeMD) />
					</cfif>
	
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- Init all PLUGIN RULES --->	
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>

		<cfloop list="#application.plugins#" index="plugin">
			
			<cfif directoryExists("#application.path.plugins#/#plugin#/packages/rules")>
			
				<cfdirectory directory="#application.path.plugins#/#plugin#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">
				
				<!--- Init all PLUGIN types --->
				<cfloop query="qDir">

						
						<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
						<cfset o = createObject("Component", "farcry.plugins.#plugin#.packages.rules.#typename#") />			
						<cfset stMetaData = getMetaData(o) />
						<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
							<cfset stTypeMD = structNew() />
							<cfparam name="application.rules.#typename#" default="#structNew()#" />
							<cfset stTypeMD = o.initmetadata(application.rules[typename]) />
							<cfset stTypeMD.bCustomRule = 1 />
							<cfset stTypeMD.bLibraryRule = 1 />
							<cfset stTypeMD.rulePath = "farcry.plugins.#plugin#.packages.rules.#typename#" />							
							<cfset stTypeMD.packagePath = "farcry.plugins.#plugin#.packages.rules.#typename#" />
						
							<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
							<cfif not find(".",stTypeMD.icon)>
								<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
							</cfif>
						
							<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
							<cfset application.rules[typename] = duplicate(stTypeMD) />
						</cfif>

				</cfloop>
				
			</cfif>
			
		</cfloop>	
		
	</cfif>


	<!--- Init all PROJECT RULES --->
	<cfif directoryExists("#application.path.project#/packages/rules")>
		<cfdirectory directory="#application.path.project#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">
	
	
		<cfloop query="qDir">
	
				
				<cfset typename = left(qDir.name, len(qDir.name)-4) /> <!---remove the .cfc from the filename --->
				<cfset o = createObject("Component", "#application.custompackagepath#.rules.#typename#") />			
				<cfset stMetaData = getMetaData(o) />
				<cfif not structKeyExists(stMetadata,"bAbstract") or stMetadata.bAbstract EQ "False">			
					<cfset stTypeMD = structNew() />
					<cfparam name="application.rules.#typename#" default="#structNew()#" />
					<cfset stTypeMD = createObject("Component", "#application.custompackagepath#.rules.#typename#").initmetadata(application.rules[typename]) />
					<cfset stTypeMD.bCustomRule = 1 />
					<cfset stTypeMD.bLibraryRule = 0 />
					<cfset stTypeMD.rulePath = "#application.custompackagepath#.rules.#typename#" />
					<cfset stTypeMD.packagePath = "#application.custompackagepath#.rules.#typename#" />
					
					<cfparam name="stTypeMD.icon" default="#LCase(typename)#" />
					<cfif not find(".",stTypeMD.icon)>
						<cfset stTypeMD.icon = "#stTypeMD.icon#.png" />
					</cfif>
					
					<cfset stTypeMD.qMetadata = setupMetadataQuery(typename=typename,stProps=stTypeMD.stProps) />
					<cfset application.rules[typename] = duplicate(stTypeMD) />
				</cfif>
		</cfloop>
	</cfif>
	
	<cfset application.stcoapi = structNew() />
	<cfloop list="#structKeyList(application.types)#" index="i">
		<cfset application.stcoapi[i] = duplicate(application.types[i]) />
	</cfloop>
	<cfloop list="#structKeyList(application.rules)#" index="i">
		<cfset application.stcoapi[i] = duplicate(application.rules[i]) />
	</cfloop>
	<cfloop list="#structKeyList(application.forms)#" index="i">
		<cfset application.stcoapi[i] = duplicate(application.forms[i]) />
	</cfloop>
	
	<cfloop list="#structKeyList(application.stcoapi)#" index="i">	
		<cfset o = createObject("Component", "#application.stcoapi[i].packagePath#") />	
		<cfset variables.tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
		<cfset variables.tableMetadata.parseMetadata(getMetadata(o)) />
		<cfset application.stcoapi[i].tableDefinition = variables.tableMetadata.getTableDefinition() />
	</cfloop>
	

</cffunction>

<cffunction name="getTypeDefaults" hint="Initialises a reference structure that can be looked up to get default types/lengths for respective DB columns">
	<cfargument name="dbtype" required="false" default="#application.dbtype#">
	<cfscript>
		stPropTypes = structNew();
		switch(arguments.dbtype){
		case "ora":
		{   //todo
			db.type = 'number';
			db.length = 1;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'date';
			db.length = 7;
			stPropTypes['date'] = duplicate(db);
			//integer
			db.type = 'integer';
			db.length = 4;//?
			stPropTypes['integer'] = duplicate(db);
			//numeric
			db.type = 'number';
			db.length = 22;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar2';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'nvarchar2';
			db.length = 255;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar2';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar2';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar2';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar2';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);
			//longchar
			db.type = 'nclob';
			db.length = 32760;
			stPropTypes['longchar'] = duplicate(db);
			break;

		}

		case "mysql":
		{
			//boolean
			db.type = 'tinyint';
			db.length = 1;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'datetime';
			db.length = 8;
			stPropTypes['date'] = duplicate(db);
			//integer
			db.type = 'int';
			db.length = 4;//?
			stPropTypes['integer'] = duplicate(db);
			//numeric
			db.type = 'decimal';
			db.length = '(10,2)';
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);
			//longchar
			db.type = 'longtext';
			db.length = 16;
			stPropTypes['longchar'] = duplicate(db);						
			//int
			db.type = 'int';
			db.length = 11;
			stPropTypes['int'] = duplicate(db);			
			//smallint
			db.type = 'smallint';
			db.length = 6;
			stPropTypes['smallint'] = duplicate(db);			
			//decimal
			db.type = 'decimal';
			db.length = '(10,2)';
			stPropTypes['decimal'] = duplicate(db);			
			//text
			db.type = 'text';
			db.length = 16;
			stPropTypes['text'] = duplicate(db);			
			//varchar
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['varchar'] = duplicate(db);			
			//varchar
			db.type = 'datetime';
			db.length = 8;
			stPropTypes['datetime'] = duplicate(db);	
			break;
		}

		case "postgresql":
		{
			//boolean
			db.type = 'int';
			db.length = 4;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'timestamp';
			db.length = 8;
			stPropTypes['date'] = duplicate(db);
			//integer
			db.type = 'integer';
			db.length = 4;//?
			stPropTypes['integer'] = duplicate(db);			
			//numeric
			db.type = 'numeric';
			db.length = 4;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);
			//longchar
			db.type = 'text';
			db.length = 16;
			stPropTypes['longchar'] = duplicate(db);
			break;
		}

		default:
		{	//boolean
			db.type = 'int';
			db.length = 4;
			stPropTypes['boolean'] = duplicate(db);
			//date
			db.type = 'datetime';
			db.length = 8;
			stPropTypes['date'] = duplicate(db);
			//integer
			db.type = 'int';
			db.length = 4;//?
			stPropTypes['integer'] = duplicate(db);			
			//numeric
			db.type = 'numeric';
			db.length = 4;
			stPropTypes['numeric'] = duplicate(db);
			//string
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['string'] = duplicate(db);
			//nstring
			db.type = 'nvarchar';
			db.length = 512;
			stPropTypes['nstring'] = duplicate(db);
			//uuid
			db.type = 'varchar';
			db.length = 50;
			stPropTypes['uuid'] = duplicate(db);
			//variablename
			db.type = 'varchar';
			db.length = 64;
			stPropTypes['variablename'] = duplicate(db);
			//color
			db.type = 'varchar';
			db.length = 20;
			stPropTypes['color'] = duplicate(db);
			//email
			db.type = 'varchar';
			db.length = 255;
			stPropTypes['email'] = duplicate(db);
			//longchar
			db.type = 'NTEXT';
			db.length = 16;
			stPropTypes['longchar'] = duplicate(db);
			break;
		}
		}
	</cfscript>
	<cfreturn stPropTypes>
</cffunction>

<cffunction name="getArrayTables" hint="Checks to see what array tables exists for a given type">
	<cfargument name="typename" type="string">
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#application.dsn#" name="qArrayTables">
		SELECT 	TABLE_NAME AS name
		FROM USER_TABLES
		WHERE UPPER(TABLE_NAME) LIKE '#ucase(arguments.typename)#@_A%' escape '@'
		</cfquery>
	</cfcase>

	<cfcase value="mysql,mysql5">
		<cfquery datasource="#application.dsn#" name="qArrayTables1">
		show tables
		</cfquery>

		<cfquery dbtype="query" name="qArrayTables">
		select #qArrayTables1.columnlist# as name
		from qArrayTables1
		where upper(#qArrayTables1.columnlist#) like '#ucase(arguments.typename)#@_A%' escape '@'
		</cfquery>
	</cfcase>

	<cfcase value="postgresql">
		<cfquery datasource="#application.dsn#" name="qArrayTables">
		select tablename as name
      from pg_tables
      where upper(tablename) like '#ucase(arguments.typename)#@_A%' escape '@'
		</cfquery>
	</cfcase>

	<cfdefaultcase>
		<cfquery datasource="#application.dsn#" name="qArrayTables">
		SELECT 	dbo.sysobjects.name
		FROM dbo.sysobjects
		WHERE dbo.sysobjects.name LIKE '#arguments.typename#@_a%' escape '@'
		</cfquery>
	</cfdefaultcase>

	</cfswitch>

	<cfreturn qArrayTables>
</cffunction>

<cffunction name="arrayTableExists" hint="Checks to see what array tables exists for a given type">
	<cfargument name="tablename" type="string">
	<cfquery datasource="#application.dsn#" name="qArrayTables">
	SELECT 	dbo.sysobjects.name
	FROM dbo.sysobjects
	WHERE dbo.sysobjects.name = '#arguments.tablename#'
	</cfquery>

	<cfscript>
	bTableExists = false;
	if (qArrayTables.recordCount) bTableExists = true;
	</cfscript>

	<cfreturn bTableExists>
</cffunction>


<cffunction name="compareDBToCFCMetadata" hint="Compares database metadata to CFC metadata">
	<cfargument name="typename" required="true">
	<cfargument name="stDB" required="true" hint="Structure containing current database metadata">
	<cfargument name="scope" required="No" default="types" hint="types or rules are valid options.  Referes to application.types or application.rules">
	<cfparam name="stCFCConflicts" default="#structNew()#"	>
	<!--- Generate a structure that compares the database structure to the cfc structure --->
	<cfset stTypeDefaults = getTypeDefaults()>

	<cfloop collection="#arguments.stDB#" item="key">
		<cfscript>
		stPropReport = structNew();

		//init struct - just checking for type/name discrepencies for the time being.
		stPropReport.bPropertyExists = true;
		stPropReport.bTypeConflict = false;
		bConflict = false;

		if(NOT structKeyExists(application[arguments.scope][arguments.typename].stProps,key))
		{
			stPropReport.bPropertyExists = false;
			bConflict = true; //flag that an error has occured
		}
		else
		{
			if (NOT application[arguments.scope][arguments.typename].stProps[key].metadata.type IS "array")
			{
				CFCType = stTypeDefaults[application[arguments.scope][arguments.typename].stProps[key].metadata.type].type;
				if(NOT arguments.stDB[key].type IS CFCType)
				{
					stPropReport.bTypeConflict = true;
					bConflict = true;
				}
			}
		}
		if (bConflict)
			stCFCConflicts['database']['#arguments.typename#']['#key#'] = duplicate(stPropReport);
		</cfscript>

	</cfloop>

	<!---  Now we are doing the opposite - generate a structure that compares the CFC structure to the database structure --->
	<cfloop collection="#application[arguments.scope][arguments.typename].stProps#" item="key">
		<cfscript>
		stPropReport = structNew();
		//init struct - just checking for type/name discrepencies for the time being.
		stPropReport.bPropertyExists = true;
		stPropReport.bTypeConflict = false;
		bConflict = false;
		if(NOT structKeyExists(arguments.stDB,key))
		{
			stPropReport.bPropertyExists = false;
			bConflict = true; //flag that an error has occured
		}
		else
		{
			if (NOT application[arguments.scope][arguments.typename].stProps[key].metadata.type IS "array")
				CFCType = stTypeDefaults[application[arguments.scope][arguments.typename].stProps[key].metadata.type].type;
			else
				CFCType = "array";
			if(NOT arguments.stDB[key].type IS CFCType)
			{
				stPropReport.bTypeConflict = true;
				bConflict = true;
			}
		}
		if(bConflict)
			stCFCConflicts['cfc']['#arguments.typename#']['#key#'] = duplicate(stPropReport);
		</cfscript>

	</cfloop>

	<cfreturn stCFCConflicts>
</cffunction>

<cffunction name="renderCFCReport" hint="displays the table outlining the descrepencies in each CFCs integrity">
	<cfargument name="typename" default="string" required="true">
	<cfargument name="stCFC" type="struct" required="true">
	<cfargument name="scope" type="string" required="false" default="types">

	<cfif structCount(arguments.stCFC)>
	<cfoutput>
	<table class="dataEvenRow table-6" cellspacing="0">
	<tr>
		<td>
			<strong>The following CFC properties conflicts exist :</strong>
		</td>
	</tr>
	<tr>
		<td>
			<table cellspacing="0">
				<tr>
					<th>Property</th>
					<th>Deployed</th>
					<th>Type</th>
					<th>Action</th>
					<th>&nbsp;</th>
				</tr>
				<cfloop collection="#arguments.stCFC#" item="key">
				<ft:form name="CFCForm" action="#cgi.SCRIPT_NAME#" method="post">
				<tr>
				<cfif NOT arguments.stCFC[key].bPropertyExists>
					<td>
						#key#
					</td>
					<td>
						<img src="#application.url.farcry#/images/no.gif" alt="Property not deployed" />
					</td>
					<td>
						#application[arguments.scope][typename].stProps[key].metadata.type#
					</td>
					<td>
						<select name="action">
							<option selected="selected" value="">Do Nothing</option>
							<cfif application[arguments.scope][typename].stProps[key].metadata.type IS "array">
							<option value="deployarrayproperty">Deploy Array Table</option>
							<cfelse>
							<option value="deployproperty">Deploy Property</option>
							</cfif>
						</select>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#" />
						<input type="hidden" name="typename" value="#arguments.typename#" />
						<ft:farcryButton value="Go" />
						
					</td>
				<cfelseif arguments.stCFC[key].bTypeConflict>
					<td>
					#key#
					</td>
					<td>

						<img src="#application.url.farcry#/images/yes.gif" alt="Property deployed" />

					</td>
					<td colspan="3">
						<strong>TYPE CONFLICT EXISTS</strong>:	Choose repair type below
					</td>

				</cfif>
				</tr>
				</ft:form>
				</cfloop>
			</table>
		</td>
	</tr>
	</table>
	<br>
	</cfoutput>
	</cfif>
</cffunction>

<cffunction name="renderDBReport" hint="">
	<cfargument name="typename" default="string" required="true">
	<cfargument name="stDB" type="struct" required="true">
	<cfargument name="scope" type="string" default="types" required="false">
	
	<cfscript>
	stTypes = buildDBStructure(scope='#arguments.scope#');
	</cfscript>

	<cfif structCount(arguments.stDB)>
	<cfoutput>
	<table class="dataEvenRow table-6" cellspacing="0">
	<tr>
		<td>
			<strong>The following database discrepencies exist : </strong>
		</td>
	</tr>
	<tr>
		<td>
			<table cellspacing="0">
				<tr>
					<th>Property</th>
					<th>Exists In CFC</th>
					<th>Type</th>
					<th>Action</th>
					<th>&nbsp;</th>
				</tr>
				<script>
				function showRename(theForm,divID){
					em = document.getElementById(divID);
					if(eval('document.'+theForm+'.action.value')=="renameproperty")
					{
						if (em.style.display=='none')
							em.style.display='inline';
						else
							em.style.display='none';
						}
						else
							em.style.display='none';
					}
				</script>

				<cfloop collection="#arguments.stDB#" item="key">
				<ft:form name="#arguments.typename#_#key#_DBForm" action="#cgi.SCRIPT_NAME#" method="post">
				<tr>
				<cfif NOT arguments.stDB[key].bPropertyExists>
					<td>
						#key#
					</td>
					<td>
						<img src="#application.url.farcry#/images/no.gif" />
					</td>
					<td>
						<cftry>
						#stTypes[arguments.typename][key].type#
						<cfcatch type="any"><cfdump var="#cfcatch#"><cfabort></cfcatch>
						</cftry>	
						
					</td>
					<td>

						<select name="action" onchange="showRename('#arguments.typename#_#key#_DBForm','#arguments.typename#_#key#_renameto');">
							<option selected="selected" value="">Do Nothing</option>
							<cfif stTypes[arguments.typename][key].type IS "array">
								<option value="droparraytable">Drop Array Table</option>
							<cfelse>
								<option value="deleteproperty">Delete Column</option>
								<option value="renameproperty">Rename Column</option>
							</cfif>
						</select>
						<div id="#arguments.typename#_#key#_renameto" style="display:none;">
							to :
							<input type="text" size="15" name="renameto">
							<input type="hidden" name="colType" value="#stTypes[arguments.typename][key].type#">
							<input type="hidden" name="colLength" value="#stTypes[arguments.typename][key].length#">
						</div>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#" />
						<input type="hidden" name="typename" value="#arguments.typename#" />
						<!--- <input type="submit" value="Go" class="f-submit" /> --->
						<ft:farcryButton value="Go" />
					</td>
				<cfelseif arguments.stDB[key].bTypeConflict>
					<td>
						#key#
					</td>
					<td>

						<img src="#application.url.farcry#/images/yes.gif" alt="Property deployed" />
						Property has been deployed
					</td>
					<td><strong>TYPE CONFLICT</strong>
						<!--- #stTypes[arguments.typename][key].type# --->
					</td>
					<td>
						<select name="action">
							<option selected="selected">Do Nothing</option>
							<option value="repairproperty">Repair Type</option>
						</select>
					</td>
					<td>
						<input type="hidden" name="property" value="#key#" />
						<input type="hidden" name="typename" value="#arguments.typename#" />
						<!--- <input type="submit" value="Go" class="f-submit" /> --->
						<ft:farcryButton value="Go" />
					</td>
				</cfif>
				</tr>
				</ft:form>
				</cfloop>
			</table>
		</td>
	</tr>
	</table>

	</cfoutput>
	</cfif>
</cffunction>

<cffunction name="alterPropertyName">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="destColumn" required="true">
	<cfargument name="colType" required="false">
	<cfargument name="colLength" required="false">
	<cfargument name="dsn" default="#application.dsn#" required="false">

	<cfswitch expression="#application.dbtype#">
		<cfcase value="postgresql">
		  <cfquery datasource="#arguments.dsn#">
			ALTER TABLE #arguments.typename#
			RENAME #arguments.srcColumn# TO #arguments.destColumn#
		  </cfquery>
		</cfcase>
		<cfcase value="ora">
		  <cfquery datasource="#arguments.dsn#">
			ALTER TABLE #arguments.typename#
			RENAME COLUMN #arguments.srcColumn# TO #arguments.destColumn#
		  </cfquery>
		</cfcase>
		<cfcase value="mysql,mysql5">
		  <cfquery datasource="#arguments.dsn#">
			ALTER TABLE #arguments.typename#
			CHANGE #arguments.srcColumn# #arguments.destColumn# #arguments.colType# <cfif arguments.colType eq 'varchar'>(#arguments.colLength#)</cfif>
		  </cfquery>
		</cfcase>
		<cfdefaultcase>
		  <cfset srcObject = "#application.dbowner##arguments.typename#.[#arguments.srcColumn#]">
		  <cftry>
		  <cfstoredproc procedure="sp_rename" datasource="#arguments.dsn#">
			  <cfprocparam cfsqltype="cf_sql_varchar" type="in" value="#srcObject#">
			  <cfprocparam cfsqltype="cf_sql_varchar" type="in" value="#arguments.destColumn#">
			  <cfprocparam cfsqltype="cf_sql_varchar" type="in" value="COLUMN">
		  </cfstoredproc>
		  <cfcatch>
			<cflog type="information" text="srcObject=#srcObject# destColumn=#arguments.destColumn#">  
			<cfthrow type="Application" detail="#cfcatch.Detail# #cfcatch.Message#">
		  </cfcatch>
		  </cftry>
		</cfdefaultcase>
	</cfswitch>


</cffunction>

<cffunction name="deleteProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">

	<cfswitch expression="#application.dbtype#">
		<cfcase value="mssql,odbc">
			<!--- check for constraint --->
			<cfquery NAME="qCheck" DATASOURCE="#application.dsn#">
				SELECT c_obj.name as CONSTRAINT_NAME, col.name	as COLUMN_NAME, com.text as DEFAULT_CLAUSE
				FROM	sysobjects	c_obj
				JOIN 	syscomments	com on 	c_obj.id = com.id
				JOIN 	sysobjects	t_obj on c_obj.parent_obj = t_obj.id
				JOIN    sysconstraints con on c_obj.id	= con.constid
				JOIN 	syscolumns	col on t_obj.id = col.id
							AND con.colid = col.colid
				WHERE c_obj.xtype	= 'D'
					AND t_obj.name = '#arguments.typename#'
					AND (col.name = '#arguments.srcColumn#')
			</cfquery>
			<cfset defaultL = len(qCheck.Default_Clause)-2>

			<cfif qCheck.recordcount GT 0>
				<cfquery NAME="qDrop" DATASOURCE="#application.dsn#">
					ALTER TABLE #application.dbowner##arguments.typename# DROP CONSTRAINT #qCheck.Constraint_Name#
				</cfquery>
			</cfif>
			<!--- drop column --->
			<cfquery NAME="qDrop" DATASOURCE="#application.dsn#">
				ALTER TABLE #application.dbowner##arguments.typename# DROP COLUMN [#arguments.srcColumn#]
			</cfquery>
		</cfcase>

		<cfdefaultcase>
			<cfquery NAME="qDrop" DATASOURCE="#application.dsn#">
				ALTER TABLE #application.dbowner##arguments.typename# DROP COLUMN #arguments.srcColumn#
			</cfquery>
		</cfdefaultcase>
	</cfswitch>

</cffunction>

<cffunction name="addProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="srcColumnType" required="true">
	<cfargument name="bNull" required="false" default="true">
	<cfargument name="stDefault" required="false" default="">
	<cfargument name="dsn" default="#application.dsn#" required="false">
	<cfargument name="dbtype" default="#application.dbtype#" required="false">

	<cfscript>
	switch(arguments.dbtype){
		case "ora":
		{
			sql = "ALTER TABLE #application.dbowner##arguments.typename# ADD (#arguments.srcColumn# #arguments.srcColumnType# ";
			if (Len(arguments.stDefault)) sql = sql & "DEFAULT '#stDefault#'";
 			if (arguments.bNull) sql = sql & "NULL";
 			else sql = sql & "NOT NULL";
 			sql = sql & ")";
 			break;
		}
		case "postgresql":
		{
			sql = "ALTER TABLE #application.dbowner##arguments.typename#	ADD #arguments.srcColumn# #arguments.srcColumnType# ";
			if (Len(arguments.stDefault)) sql = sql & "; ALTER TABLE #application.dbowner##arguments.typename# ALTER COLUMN #arguments.srcColumn# set default '#stDefault#'; UPDATE #application.dbowner##arguments.typename# SET #arguments.srcColumn# = '#stDefault#'";
			if (not arguments.bNull) sql = sql & "; ALTER TABLE #application.dbowner##arguments.typename# ALTER COLUMN #arguments.srcColumn# set NOT NULL";
			break;
		}
		case "mysql":
		{
			sql = "ALTER TABLE #application.dbowner##arguments.typename# ADD #arguments.srcColumn# #arguments.srcColumnType# ";
			if (arguments.bNull) sql = sql & "NULL";

			else sql = sql & "NOT NULL";

			if (Len(arguments.stDefault) OR NOT arguments.bNull) sql = sql & " DEFAULT '#stDefault#'";
			break;
		}
		default:
		{
			sql = "ALTER TABLE #application.dbowner##arguments.typename#	ADD [#arguments.srcColumn#] #arguments.srcColumnType# ";
			if (arguments.bNull) sql = sql & "NULL";

			else sql = sql & "NOT NULL";

			if (Len(arguments.stDefault) OR NOT arguments.bNull) sql = sql & " DEFAULT '#stDefault#'";
			break;
		}
	}
	</cfscript>

	<cfquery datasource="#arguments.dsn#">#preserveSingleQuotes(sql)#</cfquery>
</cffunction>

<cffunction name="repairProperty">
	<cfargument name="typename" required="true">
	<cfargument name="srcColumn" required="true">
	<cfargument name="srcColumnType" required="true">
	<cfargument name="dsn" default="#application.dsn#" required="false">

	<!--- work out default field length --->
	<cfset length = getTypeDefaults()>
	<cfset length = length[application.stCoapi[arguments.typename].stProps[arguments.srcColumn].metadata.type].length>

	<cftransaction>
		<cftry>
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql,mysql5">
					<!--- alter column --->
					<cfquery NAME="qAlter" DATASOURCE="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename#
						CHANGE #arguments.srcColumn# #arguments.srcColumn# #arguments.srcColumnType#
					</cfquery>
				</cfcase>

				<cfcase value="postgresql">
					<cfoutput><p class="error">This functionality is currently not available for PostgreSQL</p></cfoutput>
				</cfcase>

				<!--- TODO: these repair type functions can be improved and refactored .: need mpre research into how differnt databases work so can support it --->
				<cfcase value="ora">
					<!--- alter column --->
					<!--- convert a clob field to another field type --->
					<cfif FindNoCase("lob",originalDataType)>
						<cftry>
						<!--- create temp field --->
						<cfquery name="qTemp" datasource="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename# ADD #arguments.srcColumn#_temp #arguments.srcColumnType#
						</cfquery>

						<!--- copy clob data --->
						<cfquery name="qTemp" datasource="#application.dsn#">
						UPDATE #application.dbowner##arguments.typename# SET #arguments.srcColumn#_temp = SUBSTR(#arguments.srcColumn#,1,#length#)
						</cfquery>

						<!--- drop original field --->
						<cfquery name="qTemp" datasource="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename# DROP (#arguments.srcColumn#)
						</cfquery>

						<!--- rename temp field to original field --->
						<cfquery name="qTemp" datasource="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename# RENAME COLUMN #arguments.srcColumn#_temp TO #arguments.srcColumn#
						</cfquery>

							<cfcatch>
								<cfdump var="#cfcatch.Message#">
								<cfdump var="#cfcatch.sql#">
							</cfcatch>
						</cftry>

					<cfelseif FindNoCase("lob",arguments.srcColumnType)>
						<!--- change filed type to a clob field type --->
						<!--- create temp field --->
						<cftry>
							<cfquery name="qTemp" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##arguments.typename# ADD #arguments.srcColumn#_temp #arguments.srcColumnType#
							</cfquery>

							<!--- copy data to clob --->
							<cfquery name="qTemp" datasource="#application.dsn#">
							UPDATE #application.dbowner##arguments.typename# SET #arguments.srcColumn#_temp = #arguments.srcColumn#
							</cfquery>

							<!--- drop original field --->
							<cfquery name="qTemp" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##arguments.typename# DROP (#arguments.srcColumn#)
							</cfquery>

							<!--- rename temp field to original field --->
							<cfquery name="qTemp" datasource="#application.dsn#">
							ALTER TABLE #application.dbowner##arguments.typename# RENAME COLUMN #arguments.srcColumn#_temp TO #arguments.srcColumn#
							</cfquery>

							<cfcatch>
								<cfdump var="#cfcatch.Message#">
								<cfdump var="#cfcatch.sql#">
							</cfcatch>
						</cftry>

					<cfelse>
						<cfquery NAME="qAlter" DATASOURCE="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename#
						MODIFY #arguments.srcColumn# #arguments.srcColumnType#
						</cfquery>
					</cfif>
				</cfcase>

				<cfdefaultcase>
					<!--- check for constraint --->
					<cfquery NAME="qCheck" DATASOURCE="#application.dsn#">
						SELECT c_obj.name as CONSTRAINT_NAME, col.name	as COLUMN_NAME, com.text as DEFAULT_CLAUSE
						FROM	sysobjects	c_obj
						JOIN 	syscomments	com on 	c_obj.id = com.id
						JOIN 	sysobjects	t_obj on c_obj.parent_obj = t_obj.id
						JOIN    sysconstraints con on c_obj.id	= con.constid
						JOIN 	syscolumns	col on t_obj.id = col.id
									AND con.colid = col.colid
						WHERE c_obj.xtype	= 'D'
							AND t_obj.name = '#arguments.typename#'
							AND col.name = '#arguments.srcColumn#'
					</cfquery>
					<cfset defaultL = len(qCheck.Default_Clause)-2>

					<!--- drop constraint --->
					<cfif qCheck.recordcount>
						<cfquery NAME="qDrop" DATASOURCE="#application.dsn#">
							ALTER TABLE #application.dbowner##arguments.typename# DROP CONSTRAINT #qCheck.Constraint_Name#
						</cfquery>
					</cfif>

					<!--- alter column --->
					<cfquery NAME="qAlter" DATASOURCE="#application.dsn#">
						ALTER TABLE #application.dbowner##arguments.typename#
						ALTER COLUMN #arguments.srcColumn# #arguments.srcColumnType# <cfif NOT listContainsNoCase("NTEXT,INT,INTEGER,NUMBER",arguments.srcColumnType)>(#length#)</cfif>
					</cfquery>

					<!--- add constraint --->
					<cfif qCheck.recordcount>
						<cfoutput></cfoutput>
						<cfset sql  = 	"ALTER TABLE #application.dbowner##arguments.typename# WITH NOCHECK ADD	CONSTRAINT #qCheck.Constraint_Name# DEFAULT #qCheck.Default_Clause# FOR #arguments.srcColumn#">
						<cfquery NAME="qAdd" DATASOURCE="#application.dsn#">

							#preserveSingleQuotes(sql)#
						</cfquery>

					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfcatch>
			<cfoutput>
			<cfdump var="#cfcatch#">
			<cflog file="coapi" text="repair on property failed: #cfcatch.message# #cfcatch.detail#" >
			#cfcatch.message#<p></p>#cfcatch.detail#<p></p></cfoutput>
		</cfcatch>
		</cftry>
	</cftransaction>
</cffunction>

<cffunction name="queryTableInfo" returntype="query">
	<cfargument name="typename" type="string">
	<cfset var TableId="" />
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
	        <!--- Changed by bowden to use (+) syntax rather than inner join.
    	    Oracle didn't support the join syntax until version 9 --->
			<CFQUERY NAME="GetTables" DATASOURCE="#application.dsn#">
			SELECT ut.TABLE_NAME AS TableName,
					    uc.COLUMN_NAME AS ColumnName,
    					uc.DATA_LENGTH AS length,
	    				uc.NULLABLE AS isnullable,
		    			uc.DATA_TYPE AS Type
			FROM USER_TABLES ut
			    , USER_TAB_COLUMNS uc
			WHERE ut.TABLE_NAME = '#ucase(arguments.typename)#'
			and   (ut.TABLE_NAME = uc.TABLE_NAME (+))
			GROUP BY ut.TABLE_NAME,
        					uc.COLUMN_NAME,
    		    			uc.DATA_LENGTH,
			        		uc.NULLABLE,
    	    				uc.DATA_TYPE
			</cfquery>
		</cfcase>
		<cfcase value="mysql,mysql5">
			<!--- Get all tables in database--->
			<cfquery name="getMySQLTables" datasource="#application.dsn#">
				SHOW TABLES like '#arguments.typename#'
			</cfquery>
			<!--- Create new query to be filled with db metadata--->
			<cfset GetTables = queryNew("TableName,ColumnName,length,isnullable,Type")>
			<cfloop query="getMySQLTables">
				<!--- Get tablename --->
				<cfset myTable = GetMySQLTables[columnlist][currentrow]>
				<!--- Get column details of each table--->
				<cfquery name="GetMySQLColumns" datasource="#application.dsn#">
					SHOW COLUMNS FROM #myTable#
				</cfquery>
				<!--- Loop thru columns --->
				<cfloop query="GetMySQLColumns">
					<cfif find("(",type)>
						<cfset openbracket = find("(",GetMySQLColumns.type)>
						<cfset closebracket = find(")",GetMySQLColumns.type)>
						<cfset myLength = mid(GetMySQLColumns.type,openbracket+1,closebracket-(openbracket+1))>
						<cfset myType = left(GetMySQLColumns.type,openbracket-1)>
					<cfelse>
						<cfset myType = GetMySQLColumns.type>
						<cfif GetMySQLColumns.type eq "datetime">
							<cfset myLength=8>
						<cfelseif GetMySQLColumns.type is "text">
							<cfset myLength=16>
						<cfelse>
							<cfset myLength=4>
						</cfif>
					</cfif>
					<!--- Fill column details into created query--->
					<cfset temp = queryAddRow(GetTables)>
					<cfset temp = QuerySetCell(GetTables, "TableName", myTable)>
					<cfset temp = QuerySetCell(GetTables, "ColumnName", GetMySQLColumns.field)>
					<cfset temp = QuerySetCell(GetTables, "length", myLength)>
					<cfset temp = QuerySetCell(GetTables, "isnullable", yesnoformat(GetMySQLColumns.null))>
					<cfset temp = QuerySetCell(GetTables, "Type", myType)>
				</cfloop>
			</cfloop>
		</cfcase>

		<cfcase value="postgresql">
         <cfquery name="getTableId" datasource="#application.dsn#">
         SELECT cast(c.oid as bigint) as oid,
           n.nspname,
           c.relname
         FROM pg_catalog.pg_class c
              LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
         WHERE pg_catalog.pg_table_is_visible(c.oid)
               AND upper(c.relname) ~ upper('^#arguments.typename#$')
         ORDER BY 2, 3;
         </cfquery>

		<!--- if table doesn't exist then set tableid to 0, to ignore --->
		<cfif gettableid.recordcount>
			<cfset tableid= getTableID.oid />
		<cfelse>
			<cfset tableid="0" />
		</cfif>

         <cfquery name="getColumns" datasource="#application.dsn#">
         SELECT a.attname,
           pg_catalog.format_type(a.atttypid, a.atttypmod) as thetype,
           not a.attnotnull as isnullable
         FROM pg_catalog.pg_attribute a
         WHERE a.attrelid = '#TableId#' AND a.attnum > 0 AND NOT a.attisdropped
         ORDER BY a.attnum
         </cfquery>

         <cfset GetTables = queryNew("TableName,ColumnName,length,isnullable,type")>
         <cfloop query="getColumns">
            <cfset truelen = reReplaceNoCase(thetype, ".*\(([^\)]*)\).*", "\1")>
            <cfif thetype contains "character varying">
               <cfset truetype = "varchar">
            <cfelseif thetype contains "text">
               <cfset truetype = "text">
               <cfset truelen = "16">
            <cfelseif thetype contains "int">
               <cfset truetype = "int">
               <cfset truelen = "4">
            <cfelseif thetype contains "timestamp">
               <cfset truetype = "timestamp">
               <cfset truelen = "8">
            <cfelseif thetype contains "numeric">
               <cfset truetype = "numeric">
               <cfset truelen = "4">
            <cfelse>
               <cfset truetype = "varchar">
            </cfif>

            <cfset temp = queryAddRow(GetTables)>
            <cfset temp = querySetCell(GetTables, "TableName", arguments.typename)>
            <cfset temp = querySetCell(GetTables, "ColumnName", attname)>
            <cfset temp = querySetCell(GetTables, "length", truelen)>
            <cfset temp = querySetCell(GetTables, "isnullable", yesnoformat(isnullable))>
            <cfset temp = querySetCell(GetTables, "type", truetype)>
         </cfloop>

		</cfcase>

		<cfdefaultcase>
			<CFQUERY NAME="GetTables" DATASOURCE="#application.dsn#">
			SELECT dbo.sysobjects.name AS TableName,
						dbo.syscolumns.Name AS ColumnName,
						dbo.syscolumns.length,
						dbo.syscolumns.isnullable,
						dbo.systypes.name AS Type
			FROM dbo.sysobjects
			INNER JOIN dbo.syscolumns ON (dbo.sysobjects.id = dbo.syscolumns.id)
			INNER JOIN 	dbo.systypes ON (dbo.syscolumns.xtype = dbo.systypes.xusertype)
			WHERE dbo.sysobjects.xtype = 'U'
			AND	dbo.sysobjects.name = '#arguments.typename#'
			AND dbo.sysobjects.name <> 'dtproperties'
			GROUP BY dbo.sysobjects.name,
        					dbo.syscolumns.name,
	        				dbo.syscolumns.length,
		        			dbo.syscolumns.isnullable,
			        		dbo.systypes.name
			</CFQUERY>
		</cfdefaultcase>
		</cfswitch>

	<cfreturn GetTables>
</cffunction>

<cffunction name="buildDBTableStructure">
	<cfargument name="typeName" required="yes">
	<cfset var stType = structNew() />

		<cfset getTables=queryTableInfo('#arguments.typeName#') />

		<cfscript>
		qArrayTables = getArrayTables(typename='#arguments.typeName#');
		for(i = 1;i LTE qArrayTables.recordCount;i=i+1)
		{
			queryAddRow(getTables,1);
			querySetCell(getTables,'columnname',replacenocase(qArrayTables.name[i],"#arguments.typeName#_",""));
			querySetCell(getTables,'type','array');
		}

		for(i = 1;i LTE getTables.recordCount;i = i+1){
			stThisRow = structNew();
			stThisRow.length = getTables.length[i];
			stThisRow.isNullable = getTables.isNullable[i];
			stThisRow.type = getTables.type[i];
			stType['#getTables.columnname[i]#'] = Duplicate(stThisRow);
		}
		</cfscript>

	<cfreturn stType>
</cffunction>



<cffunction name="buildDBStructure">
	<cfargument name="scope" default="types" required="No">
	<cfset var stTypes = structNew() />

	<cfloop collection="#application[arguments.scope]#" item="typename">
		<cfset getTables=queryTableInfo('#typename#') />

		<cfscript>
		qArrayTables = getArrayTables(typename='#typename#');
		for(i = 1;i LTE qArrayTables.recordCount;i=i+1)
		{
			queryAddRow(getTables,1);
			querySetCell(getTables,'columnname',replacenocase(qArrayTables.name[i],"#typename#_",""));
			querySetCell(getTables,'type','array');
		}

		for(i = 1;i LTE getTables.recordCount;i = i+1){
			stThisRow = structNew();
			stThisRow.length = getTables.length[i];
			stThisRow.isNullable = getTables.isNullable[i];
			stThisRow.type = getTables.type[i];
			stTypes['#typename#']['#getTables.columnname[i]#'] = Duplicate(stThisRow);
		}
		</cfscript>
		<!--- <cfdump var="#qArrayTables#">
		<cfdump var="#getTables#"> --->
		 <!--- <cfdump var="#getTables#">
		 <cfdump var="#stTypes#">
		 <cfdump var="#application.types[typename].stprops#">  --->
		<!---  <cfdump var="#stTypes#">  --->
	</cfloop>

	<cfreturn stTypes>
</cffunction>

<cffunction name="deployCFC">
	<cfargument name="typename" required="true">
	<cfargument name="scope" required="false" default="types">
	
	<cfset var o = "" />
	<cfset var result = "" />
	
	<cfset o = createObject("component", application.stCoapi[arguments.typename].packagePath) />
	
	<cfset result = o.deployType(btestRun="false") />

</cffunction>

<cffunction name="isCFCDeployed">
	<cfargument name="typename" required="true">
	<cfargument name="dsn" required="false" default="#application.dsn#">

	<cfswitch expression="#application.dbtype#">

	<cfcase value="ora">
		<cfquery name="qTableExists" datasource="#application.dsn#">
		SELECT TABLE_NAME FROM USER_TABLES
		WHERE TABLE_NAME = '#ucase(arguments.typename)#'
		</cfquery>
	</cfcase>

	<cfcase value="mysql,mysql5">
		<cfquery name="qTableExists" datasource="#application.dsn#">
			SHOW TABLES LIKE '#arguments.typename#'
		</cfquery>
	</cfcase>

	<cfcase value="postgresql">
      <cfquery name="qTableExists" datasource="#application.dsn#">
         select tablename from pg_tables
         where  schemaname = 'public'
         and    upper(tablename) = upper('#arguments.typename#')
      </cfquery>
   </cfcase>

	<cfdefaultcase>
		<cfquery name="qTableExists" datasource="#application.dsn#">
		SELECT 	dbo.sysobjects.name FROM dbo.sysobjects
		WHERE dbo.sysobjects.name = '#arguments.typename#'
		</cfquery>
	</cfdefaultcase>

	</cfswitch>

	<cfscript>
	bTableExists = false;
	if (qTableExists.recordcount) bTableExists = true;
	</cfscript>
	<cfreturn bTableExists>
</cffunction>

<cffunction name="isCFCConflict" hint="Determines whether or not a CFCs integrity has been compromised" returntype="boolean">
	<cfargument name="stConflicts" type="struct" required="true">
	<cfargument name="typename" type="string" required="true" hint="CFC name eg dmNew, ruleNews etc">

	<cfscript>
	bConflict = false;
	if((structKeyExists(stConflicts,'cfc') AND structKeyExists(stConflicts['cfc'],arguments.typeName)) OR (structKeyExists(stConflicts,'database') AND structKeyExists(stConflicts['database'],arguments.typeName)))
        bConflict = true;
	</cfscript>
	<cfreturn bConflict>
</cffunction>

</cfcomponent>
