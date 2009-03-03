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


	<cffunction name="init" access="public" output="false" returntype="dmWebskinAncestor" hint="initialises the ancestor records currently assigned to the object that is passed in.">
		<cfargument name="webskinObjectID" type="UUID" required="false" hint="the objectid that you wish to retrieve the ancestors of." />
		<cfargument name="webskinTypename" type="string" required="false" hint="the type of the template you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" required="false" hint="The template you wish to retreive the ancestors of" />
	
		<cfif not structkeyexists(arguments,"webskinObjectID") and not (structkeyexists(arguments,"webskinTypename") and structkeyexists(arguments,"webskinTemplate"))>
			<cfthrow message="init requires webskinObjectID or webskinTypename and webskinTemplate" />
		</cfif>
		
		<cfif structkeyexists(arguments,"webskinObjectID")>
			<cfif not structKeyExists(variables, "webskinObjectID") OR variables.webskinObjectID NEQ arguments.webskinObjectID>
				
				<cfset variables.webskinObjectID = arguments.webskinObjectID />
				
				<cfquery datasource="#application.dsn#" name="variables.qCurrentAncestors">
					SELECT 	objectid,ancestorID,ancestorTemplate,ancestorTypename
					FROM 	dmWebskinAncestor
					WHERE 	webskinObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.webskinObjectID#">
				</cfquery>			
			</cfif>
		<cfelse>
			<cfif not structkeyexists(variables,"webskinTypename") or variables.webskinTypename neq arguments.webskinTypename or variables.webskinTemplate neq arguments.webskinTemplate>
				
				<cfset variables.webskinTypename = arguments.webskinTypename />
				<cfset variables.webskinTemplate = arguments.webskinTemplate />
				
				<cfquery datasource="#application.dsn#" name="variables.qCurrentAncestors">
					SELECT 	objectid,ancestorID,ancestorTemplate,ancestorTypename
					FROM 	dmWebskinAncestor
					WHERE 	webskinObjectID = ''
							and webskinTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.webskinTypename#">
							and webskinTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.webskinTemplate#">
				</cfquery>	
			</cfif>
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getAncestorWebskins" access="public" output="true" returntype="query" hint="Returns query containing all ancestor templates currently exists in the webskinAncestor table for the current webskinID">
		<cfargument name="webskinObjectID" type="UUID" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" required="false" hint="the type of the template you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" required="false" hint="The template you wish to retreive the ancestors of" />
	
		<cfif not structkeyexists(arguments,"webskinObjectID") and not (structkeyexists(arguments,"webskinTypename") and structkeyexists(arguments,"webskinTemplate"))>
			<cfthrow message="getAncestorWebskins requires webskinObjectID or webskinTypename and webskinTemplate" />
		</cfif>
		
		<cfif structkeyexists(arguments,"webskinObjectID")>
			<cfset init(webskinObjectID=arguments.webskinObjectID) />
		<cfelse>
			<cfset init(webskinTypename=arguments.webskinTypename,webskinTemplate=arguments.webskinTemplate) />
		</cfif>
		
		<cfreturn variables.qCurrentAncestors />
	</cffunction>
		
	
	<cffunction name="checkAncestorExists" access="public" output="true" returntype="boolean" hint="Returns boolean as to whether the ancestor template currently exists in the webskinAncestor table.">
		<cfargument name="webskinObjectID" type="UUID" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" required="false" hint="the type of the template you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" required="false" hint="The template you wish to retreive the ancestors of" />
		<cfargument name="ancestorID" type="UUID" required="false" hint="the objectid of the ancestor." />
		<cfargument name="ancestorTypename" type="string" required="false" hint="The type of the ancestor" />
		<cfargument name="ancestorTemplate" type="string" required="true" hint="The ancestor webskin template name." />
		
		<cfset var qExists = queryNew("blah") />
		<cfset var bExists = false />		
		
		<cfif not structkeyexists(arguments,"webskinObjectID") and not (structkeyexists(arguments,"webskinTypename") and structkeyexists(arguments,"webskinTemplate"))>
			<cfthrow message="checkAncestorExists requires webskinObjectID or webskinTypename and webskinTemplate" />
		</cfif>
		
		<cfif not structkeyexists(arguments,"ancestorID") and not structkeyexists(arguments,"ancestorTypename")>
			<cfthrow message="Either ancestorID or ancestorTypename and ancestorTemplate are required for checkAncestorExists" />
		</cfif>
		
		<cfif structkeyexists(arguments,"webskinObjectID")>
			<cfset init(webskinObjectID=arguments.webskinObjectID) />
		<cfelse>
			<cfset init(webskinTypename=arguments.webskinTypename,webskinTemplate=arguments.webskinTemplate) />
		</cfif>

		<cfquery dbtype="query" name="qExists">
			SELECT 	objectid 
			FROM 	variables.qCurrentAncestors
			WHERE 	
			<cfif structkeyexists(arguments,"webskinObjectID")>
				ancestorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorID#">
				AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
			<cfelse>
				ancestorID = ''
				AND ancestorTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTypename#">
				AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
			</cfif>
		</cfquery>
		
		<cfif qExists.recordCount>
			<cfset bExists = true />
		</cfif>
		
		<cfreturn bExists />
	</cffunction>
	
		
</cfcomponent>