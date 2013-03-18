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
	bRefObjects="false"
	bSystem="true">

    <!--- required properties --->	
    <cfproperty name="webskinObjectID" type="uuid" hint="The objectid of the webskin id we are defining the ancestor of" required="yes">
	<cfproperty name="webskinTypename" type="string" hint="The type of the webskin we are defining the ancestor of" required="no">
	<cfproperty name="webskinTemplate" type="string" hint="The webskin template we are defining the ancestor of" required="no">
    <cfproperty name="ancestorTypename" type="string" hint="The typename of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorID" type="uuid" hint="The objectid of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorTemplate" type="string" hint="The webskin template name of the ancestor webskin" required="yes">

	<cffunction name="getAncestorWebskins" access="public" output="true" returntype="query" hint="Returns query containing all ancestor templates currently exists in the webskinAncestor table for the current webskinID">
		<cfargument name="webskinObjectID" type="string" default="" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" default="" required="false" hint="the type of the template you wish to retrieve the ancestors of" />

		<cfset var qWebskinAncestors = "" />
		<cfset var qResult = "" />
	
		<cfif not structKeyExists(application.fc.webskinAncestors, arguments.webskinTypename)>
			<cfset application.fc.webskinAncestors[arguments.webskinTypename] = queryNew( 'webskinObjectID,webskinTypename,webskinRefTypename,webskinTemplate,ancestorID,ancestorTypename,ancestorTemplate,ancestorRefTypename', 'VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar' ) />
		</cfif>
		
		
		<cfset qWebskinAncestors = application.fc.webskinAncestors['#arguments.webskinTypename#'] />
		
		<cfquery dbtype="query" name="qResult">
			SELECT 	*
			FROM 	qWebskinAncestors
				WHERE 	webskinObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.webskinObjectID#">
			</cfquery>				
		
		
		<cfreturn qResult />
	</cffunction>
		
	
	<cffunction name="checkAncestorExists" access="public" output="false" returntype="void" hint="checks webskinAncestor cache and adds if not already in.">
		<cfargument name="webskinObjectID" type="string" default="" required="false" hint="the objectid of the webskin" />
		<cfargument name="webskinTypename" type="string" default="" required="false" hint="the type of the object you wish to retrieve the ancestors of" />
		<cfargument name="webskinRefTypename" type="string" default="" required="false" hint="the type of the object you wish to retrieve the ancestors of" />
		<cfargument name="webskinTemplate" type="string" default="" required="false" hint="The template you wish to retreive the ancestors of" />
		<cfargument name="ancestorID" type="UUID" default="" required="false" hint="the objectid of the ancestor." />
		<cfargument name="ancestorTypename" type="string" default="" required="false" hint="The type of the ancestor" />
		<cfargument name="ancestorRefTypename" type="string" default="" required="false" hint="The type of the ancestor" />
		<cfargument name="ancestorTemplate" type="string" default="" required="true" hint="The ancestor webskin template name." />
		
		<cfset var qWebskinAncestors = getAncestorWebskins(webskinObjectID=arguments.webskinObjectID, webskinTypename=arguments.webskinTypename ) />
		<cfset var qWebskinAncestorExists = "" />		
		<cfset var qResult = "" />		
		
		<cfquery dbtype="query" name="qWebskinAncestorExists">
		SELECT 	webskinObjectID 
		FROM 	qWebskinAncestors
		WHERE	ancestorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorID#">
			AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
		</cfquery>

		<!--- IF the details of this cached webskin are not in the db, then we need to create it now. --->
		<cfif NOT qWebskinAncestorExists.recordCount>
			<cflock name="webskinAncestor_#arguments.webskinTypename#" type="exclusive" timeout="5" >
				<cfset queryaddrow( application.fc.webskinAncestors[arguments.webskinTypename] ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'webskinObjectID', arguments.webskinObjectID ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'webskinTypename', arguments.webskinTypename ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'webskinRefTypename', arguments.webskinRefTypename ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'webskinTemplate', arguments.webskinTemplate ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'ancestorID', arguments.ancestorID ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'ancestorTypename', arguments.ancestorTypename ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'ancestorRefTypename', arguments.ancestorRefTypename ) >
				<cfset querysetcell( application.fc.webskinAncestors[arguments.webskinTypename], 'ancestorTemplate', arguments.ancestorTemplate ) >
			</cflock>
		</cfif>
		
	</cffunction>
	
		
</cfcomponent>