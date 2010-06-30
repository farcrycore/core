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
$Header: /cvs/farcry/core/packages/types/dmXMLExport.cfc,v 1.6 2003/09/22 07:04:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 07:04:33 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: dmXMLExport Type $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

--->
<cfcomponent extends="types" displayname="XML Export" hint="RSS 2.0 Feeds" bRefObjects="false">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="title" type="nstring" hint="Title of the feed" required="no" default="">
<cfproperty name="description" type="longchar" hint="Description of the feed" required="no" default="">
<cfproperty name="language" type="string" hint="Language of the feed" required="no" default="en-us">
<cfproperty name="creator" type="string" hint="Email address of the feed creator" required="no" default="">
<cfproperty name="rights" type="string" hint="Copyright notices etc" required="no" default="Copyright">
<cfproperty name="generatorAgent" type="string" hint="URL of the feed generator" required="no" default="http://farcry.daemon.com.au/?v=1.31">
<cfproperty name="errorReportsTo" type="string" hint="Email address for errors to be sent to" required="no" default="">
<cfproperty name="updatePeriod" type="string" hint="Period for updates, eg hourly, daily" required="no" default="">
<cfproperty name="updateFrequency" type="numeric" hint="Feed updated x updatePeriods" required="no" default="1">
<cfproperty name="updateBase" type="string" hint="Base date for feed updates" required="no" default="2000-01-01T12:00+00:00">
<cfproperty name="contentType" type="string" hint="FarCry object type being exported" required="no" default="">
<cfproperty name="numberOfItems" type="numeric" hint="Maximum number of items for export" required="no" default="10">
<cfproperty name="xmlFile" type="string" hint="file path to the exported feed document (should be under webroot for external access)" required="no" default="export.xml">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmXMLExport/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfparam name="url.mode" default="preview">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	
	<cfswitch expression="#url.mode#">
		<cfcase value="preview">
			<cfinclude template="_dmXMLExport/preview.cfm">	
		</cfcase>
		
		<cfcase value="validate">
			<cfinclude template="_dmXMLExport/validate.cfm">
		</cfcase>
		
		<cfcase value="export">
			<cfset generate(stObj.objectid)>
		</cfcase>
	</cfswitch>
</cffunction>

<cffunction name="generate" access="public" hint="generates xml for feed to be used in export or preview" returntype="any">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	
	<cfinclude template="_dmXMLExport/generate.cfm">
</cffunction>

<cffunction name="getAll" access="public" output="false" returnType="query">
	<cfquery name="qGetAll" datasource="#application.dsn#">
		Select *
		From #application.dbowner#dmXMLExport
	</cfquery>
	
	<cfreturn qGetAll>
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmXMLExport. Removes physical files from ther server.">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmXMLExport/delete.cfm">
</cffunction>	

</cfcomponent>

