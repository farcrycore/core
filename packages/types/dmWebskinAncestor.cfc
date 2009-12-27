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
$Header: /cvs/farcry/core/packages/types/dmProfile.cfc,v 1.20.2.1 2006/01/09 09:34:59 geoff Exp $
$Author: geoff $
$Date: 2006/01/09 09:34:59 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: Webskin Ancestors $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->
<cfcomponent extends="types" displayName="Webskin Ancestors" hint="Holds all the ancestor webskins of each webskin."
	bAudit="false"
	bRefObjects="false">

    <!--- required properties --->	
    <cfproperty name="webskinObjectID" type="uuid" hint="The objectid of the webskin id we are defining the ancestor of" required="yes">
	<cfproperty name="webskinTypename" type="string" hint="The type of the webskin we are defining the ancestor of" required="yes">
	<cfproperty name="webskinTemplate" type="string" hint="The webskin template we are defining the ancestor of" required="yes">
    <cfproperty name="ancestorTypename" type="string" hint="The typename of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorID" type="uuid" hint="The objectid of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorTemplate" type="string" hint="The webskin template name of the ancestor webskin" required="yes">

	<cffunction name="getAncestorWebskins" access="public" output="true" returntype="query" hint="Returns query containing all ancestor templates currently exists in the webskinAncestor table for the current webskinID">
		<cfargument name="webskinObjectID" type="string" default="" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" default="" required="false" hint="the type of the template you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" default="" required="false" hint="The template you wish to retreive the ancestors of" />
	
		<cfset var q = "" />
		
		<cfif not len(arguments.webskinObjectID) and not (len(arguments.webskinTypename) and len(arguments.webskinTemplate))>
			<cfthrow message="getAncestorWebskins requires webskinObjectID or webskinTypename and webskinTemplate" />
		</cfif>
		
		
		<cfif len(arguments.webskinObjectID)>			
			<cfquery datasource="#application.dsn#" name="q">
				SELECT 	a.objectid,a.ancestorID,a.ancestorTemplate,a.ancestorTypename, ref.typename as ancestorBindingTypename
				FROM 	dmWebskinAncestor as a
				LEFT JOIN refObjects as ref
				ON a.ancestorID = ref.objectid
				WHERE 	webskinObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.webskinObjectID#">
			</cfquery>				
		<cfelse>
			<cfquery datasource="#application.dsn#" name="q">
				SELECT 	a.objectid,a.ancestorID,a.ancestorTemplate,a.ancestorTypename, ref.typename as ancestorBindingTypename
				FROM 	dmWebskinAncestor as a
				LEFT JOIN refObjects as ref
				ON a.ancestorID = ref.objectid
				WHERE 	webskinObjectID = ''
						and webskinTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.webskinTypename#">
						and webskinTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.webskinTemplate#">
			</cfquery>				
		</cfif>
		
		<cfreturn q />
	</cffunction>
		
	
	<cffunction name="checkAncestorExists" access="public" output="false" returntype="boolean" hint="Returns false if it is not already in the webskinAncestor table.">
		<cfargument name="webskinObjectID" type="string" default="" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" default="" required="false" hint="the type of the template you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" default="" required="false" hint="The template you wish to retreive the ancestors of" />
		<cfargument name="ancestorID" type="UUID" default="" required="false" hint="the objectid of the ancestor." />
		<cfargument name="ancestorTypename" type="string" default="" required="false" hint="The type of the ancestor" />
		<cfargument name="ancestorTemplate" type="string" default="" required="true" hint="The ancestor webskin template name." />
		
		<cfset var q = "" />
		<cfset var qExists = "" />
		<cfset var bExists = false />		
		
		<cfif not len(arguments.ancestorID) and not len(arguments.ancestorTypename)>
			<cfthrow message="Either ancestorID or ancestorTypename and ancestorTemplate are required for checkAncestorExists" />
		</cfif>
		
		<!--- Not checked so go check the database. --->
		<cfset q = getAncestorWebskins(webskinObjectID=arguments.webskinObjectID, webskinTypename=arguments.webskinTypename, webskinTemplate=arguments.webskinTemplate ) />
	
		<cfquery dbtype="query" name="qExists">
		SELECT 	objectid 
		FROM 	q
		WHERE 	
		<cfif len(arguments.ancestorID)>
			ancestorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorID#">
			AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
		<cfelse>
			ancestorID = ''
			AND ancestorTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTypename#">
			AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
		</cfif>
		</cfquery>
			
		<!--- IF the details of this cached webskin are not in the db, then we need to create it now. --->
		<cfif qExists.recordCount>
			<cfset bExists = true />
		</cfif>
		
		<cfreturn bExists />
	</cffunction>
	
		
</cfcomponent>