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
<cfcomponent displayname="FarCry COAPI" hint="Contains a record per coapi package" extends="farcry.core.packages.types.types" output="false" bObjectBroker="true" ObjectBrokerMaxObjects="10000" fuAlias="coapi" bRefObjects="false" bSystem="true">
	<cfproperty ftSeq="1" ftFieldset="General Details" name="name" type="string" default="" hint="The name of the coapi class. excludes the extension (.cfc)" ftLabel="Class name" />


	<cffunction name="init" access="public" returntype="farCoapi" output="false" hint="Initializes the component instance data">
		
		<cfif not structKeyExists(application,'coapiID')>
			<cfset application.coapiID = structNew() />
		</cfif>
		
		<cfreturn this />
		
	</cffunction>

	<cffunction name="getCoapiObject" access="public" output="false" hint="Returns the object based on the class name passed in. Creates the object if class name does not exist" returntype="struct" >
		<cfargument name="name" required="true" type="string" />
		
		<cfset var q = queryNew("objectid") />
		<cfset var stResult = structNew() />
		<cfset var stDeployResult = structNew() />
		<cfset var classID =  ""/>
		<cfset var stProperties = structNew() />
		<cfset var stNew = structnew() />
		
		<cfset init() />
		
		<cfif structKeyExists(application.coapiID, "#arguments.name#")>
			<cfset classID = application.coapiID["#arguments.name#"] />
		<cfelse>
			<cfset classID = findCoapiObjectID(name="#arguments.name#") />
		</cfif>
		
		<cfif not len(classID)>
			<cfset stProperties.name = arguments.name />
			<cfset stNew = createData(stProperties="#stProperties#") />
			
			<cfset classID = stNew.objectid />
		</cfif>
		
		<cfset stResult = getData(typename="farCoapi", objectid="#classID#") />		
		
		<cfif not structKeyExists(application.coapiID, "#arguments.name#")>
			<cfset application.coapiID["#arguments.name#"] = stResult.objectid />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	

	<cffunction name="getCoapiObjectID" access="public" output="false" hint="Returns the objectID based on the class name passed in. Returns empty string." returntype="string" >
		<cfargument name="name" required="true" type="string" />
		
		<cfset var stCoapi = getCoapiObject("#arguments.name#") />
		<cfset var coapiID = stCoapi.objectID />
		
		<cfreturn coapiID />
	</cffunction>	
	
	<cffunction name="findCoapiObjectID" access="private" output="false" hint="Returns the objectid of the class name passed in. Returns empty string if class name does not exist." returntype="string" >
		<cfargument name="name" required="true" type="string" />
		
		<cfset var q = queryNew("objectid") />
		<cfset var stDeployResult = structNew() />
		<cfset var result = "" />
		
		<cftry>
			
			<cfquery datasource="#application.dsn#" name="q">
			SELECT objectid
			FROM #application.dbowner#farCoapi
			WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" />
			</cfquery>
			
			<cfcatch type="database">
				<cflock name="deployCoapiTable" timeout="30">
					<!--- The table has not been deployed. We need to deploy it now --->
					<cfset application.fc.lib.db.deployType(typename="farCoapi",bDropTable=true,dsn=application.dsn) />
				</cflock>		
			</cfcatch>
		</cftry>
		
		<cfif q.recordCount>
			<cfset result = q.objectid />
		</cfif>
		
		<cfreturn result />
	</cffunction>
</cfcomponent>