<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/genericAdmin.cfc,v 1.11.2.2 2005/04/29 03:15:08 guy Exp $
$Author: guy $
$Date: 2005/04/29 03:15:08 $
$Name: milestone_2-1-2 $
$Revision: 1.11.2.2 $

|| DESCRIPTION || 
$Description: generic admin cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="farcry.farcry_core.packages.types.types" displayname="Generic Admin" hint="Functions used to display the Generic Admin section of Farcry. Any types that use the farcry generic admin facility MUST extend this component">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cffunction name="renderSearchFields" hint="Returns HTML for seach fields in generic Admin" returntype="string">
	<cfargument name="criteria" required="Yes">
	<cfargument name="typename" required="Yes">
	<cfset var key = ''>
	
	<cfparam name="arguments.criteria.filter" default="">		
	<cfparam name="arguments.criteria.filterType" default="exactly">
	<cfparam name="arguments.criteria.searchText" default="">
	<cfparam name="arguments.criteria.currentStatus" default="All">
	<cfparam name="arguments.criteria.order" default="datetimecreated">
	<cfparam name="arguments.criteria.orderDirection" default="desc">
	<cfparam name="arguments.criteria.customfilter" default="">

	<!--- default vals --->
	<!--- If they arrive at the page having not clicked filter - check for existance fo session filter vars and init arg vals --->
	<cfif not isDefined("arguments.criteria.refine") AND sessionNameSpaceExists(arguments.typename)>
		<cfloop collection="#session.genericAdmin[arguments.typename].filter#" item="key">
			<cfif NOT key IS "clear">
				 <cfif structKeyExists(arguments.criteria,key)>
				 	<cfif arguments.criteria[key] IS session.genericAdmin[arguments.typename].filter[key]>
				 		<cfset arguments.criteria[key] = session.genericAdmin[arguments.typename].filter[key]> 
				 	</cfif>
				 <cfelse>			 
					 <cfset arguments.criteria[key] = session.genericAdmin[arguments.typename].filter[key]> 
				 </cfif>					
			</cfif>
		</cfloop>
	</cfif>
	<!--- Init session vars --->
	<cfif NOT sessionNameSpaceExists(arguments.typename)>
		<cfset initNameSpace(arguments.typename)>
	</cfif>
	<cfloop collection="#arguments.criteria#" item="key">
		<cfset session.genericAdmin[arguments.typename].filter[key] = arguments.criteria[key]>
	</cfloop>	
	
	<cfif NOT isDefined("url.objectid") OR isDefined("arguments.criteria.refine")>
		<cfset structDelete(session.genericAdmin[arguments.typename].filter,'objectid')>
	</cfif>
	
	<cfif isdefined("arguments.criteria.clear")>
		<cfset arguments.criteria.filter = "">
		<cfset arguments.criteria.searchText = "">
	</cfif>
	<!--- Save output to a variable --->
	<cfsavecontent variable="html">
	<cfoutput>
		<cfif structKeyExists(application.types['#arguments.typename#'].stProps,"status")>
		<!--- show drop down to restrict by status --->
		<div class="FormTableClear" style="margin-left:0;">
			Object Status &nbsp; 
			<select class="text-cellheader" name="currentStatus" onChange="this.form.submit();">
				<option value="draft" <cfif arguments.criteria.currentStatus IS "draft">selected</cfif>>draft
				<option value="pending" <cfif arguments.criteria.currentStatus IS "pending">selected</cfif>>pending
				<option value="approved" <cfif arguments.criteria.currentStatus IS "approved">selected</cfif>>approved
				<option value="All" <cfif arguments.criteria.currentStatus IS "all">selected</cfif>>All
			</select>
			</div>
		</cfif>
	
		Filter: 
		<select name="filter">
			<!--- field types that can be filtered --->
			<cfset fieldType = "string,nstring">
			<!--- sort structure by Key name --->
			<cfset listofKeys = listsort(structKeyList(application.types[arguments.typename].stProps),"textnocase")>	
			<!--- loop over type properties --->
			<cfloop list="#listOfKeys#" index="property">
				<!--- check if property is string --->
				<cfif listFind(fieldType,application.types[arguments.typename].stProps[property].metadata.type)>
					<option value="#property#" <cfif arguments.criteria.filter eq property>selected</cfif>>#property#
				</cfif>
			</cfloop>
		</select>
		<!--- filter type exact match search or like --->
		<select name="filterType">
			<option value="exactly" <cfif arguments.criteria.filterType eq "exactly">selected</cfif>>Matches Exactly
			<option value="contains" <cfif arguments.criteria.filterType eq "contains">selected</cfif>>Contains
		</select>
		<!--- free text field --->
		<input type="text" name="searchText" value="#arguments.criteria.searchText#">
		<input type="hidden" name="customfilter" value="#arguments.criteria.customfilter#" >
		<!--- submit buttons --->
		<input type="submit" name="refine" value="Filter" class="normalbttnstyle" >
		<input type="submit" name="clear" value="Clear" class="normalbttnstyle">
	</cfoutput>
	</cfsavecontent>
	<cfreturn html>
</cffunction>


<cffunction name="permissionCheck" access="remote" returntype="string" hint="Checks if user has a permission to perform select action">
    <cfargument name="permission" type="string" required="true" hint="name of permission">
	    
		<cfscript>
			permissionReturn = request.dmSec.oAuthorisation.checkPermission(permissionName="#arguments.permission#",reference="PolicyGroup");
		</cfscript>
	
	<cfreturn permissionReturn>
</cffunction>

<cffunction name="changeStatus" access="remote" returntype="struct" hint="Changes status of selected object(s)">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
    	
	<cfinclude template="_genericAdmin/changeStatus.cfm">
	
	<cfreturn stStatus>
</cffunction>

<cffunction name="sessionNameSpaceExists">
	<cfargument name="typename" required="true">
	<cfset bExists = false>
	
	<cfif structKeyExists(session,'genericAdmin')>
		<cfif structKeyExists(session.genericAdmin,'#arguments.typename#')>
			<cfif structKeyExists(session.genericAdmin[arguments.typename],'filter')>
				<cfset bExists = true>
			</cfif>
		</cfif>
	</cfif>
		<cfreturn bExists>

</cffunction>

<cffunction name="initNameSpace">
	<cfargument name="typename">
	
	<cfif not structKeyExists(session,'genericAdmin')>
		<cfset session.genericAdmin = structNew()>
	</cfif>
	<cfif not structKeyExists(session.genericAdmin,arguments.typename)>
		<cfset session.genericAdmin[arguments.typename] = structNew()>
	</cfif>
	<cfif not structKeyExists(session.genericAdmin[arguments.typename],'filter')>
		<cfset session.genericAdmin[arguments.typename].filter = structNew()>
	</cfif>
	
</cffunction>

<cffunction name="getObjects" access="remote" returntype="query" hint="Returns a query of objects to be displayed">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
	<cfargument name="typename" type="string" required="true" hint="Object type of objects to be displayed">
	<cfargument name="criteria" type="struct" required="Yes">
	
	<cfif isdefined("arguments.criteria.clear")>
		<cfset arguments.criteria.filter = "">
		<cfset arguments.criteria.searchText = "">
	</cfif>
		
	<cfif not isDefined("arguments.criteria.refine") AND sessionNameSpaceExists(arguments.typename)>
		<cfif NOT isDefined("url.objectid") OR isDefined("arguments.criteria.refine")>
			<cfset structDelete(session.genericAdmin[arguments.typename].filter,'objectid')>
		</cfif>
		<cfloop collection="#session.genericAdmin[arguments.typename].filter#" item="key">
			<cfif NOT key IS "clear">
				 <cfif structKeyExists(arguments.criteria,key)>
				 	<cfif arguments.criteria[key] IS session.genericAdmin[arguments.typename].filter[key]>
				 		<cfset arguments.criteria[key] = session.genericAdmin[arguments.typename].filter[key]> 
				 	</cfif>
				 <cfelse>			 
					 <cfset arguments.criteria[key] = session.genericAdmin[arguments.typename].filter[key]> 
				 </cfif>					
			</cfif>
		</cfloop>
	</cfif>
	
		
	<cfif NOT sessionNameSpaceExists(arguments.typename)>
		<cfset initNameSpace(arguments.typename)>
	</cfif>
	
    	
	<cfinclude template="_genericAdmin/getObjects.cfm">
	
	<cfreturn qGetObjects>
</cffunction>

</cfcomponent>