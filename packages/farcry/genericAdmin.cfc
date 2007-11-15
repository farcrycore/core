<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/genericAdmin.cfc,v 1.18 2005/06/03 09:51:50 geoff Exp $
$Author: geoff $
$Date: 2005/06/03 09:51:50 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: generic admin cfc $
$TODO: DEPRECATE this component and replace with something more suitable$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="farcry.core.packages.types.types" displayname="Generic Admin" hint="Functions used to display the Generic Admin section of Farcry. Any types that use the farcry generic admin facility MUST extend this component">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">

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
			#application.adminBundle[session.dmProfile.locale].objStatus# &nbsp; 
			<select class="text-cellheader" name="currentStatus" onChange="this.form.submit();">
				<option value="draft" <cfif arguments.criteria.currentStatus IS "draft">selected</cfif>>#application.adminBundle[session.dmProfile.locale].draftLC#</option>
				<option value="pending" <cfif arguments.criteria.currentStatus IS "pending">selected</cfif>>#application.adminBundle[session.dmProfile.locale].pendingLC#</option>
				<option value="approved" <cfif arguments.criteria.currentStatus IS "approved">selected</cfif>>#application.adminBundle[session.dmProfile.locale].approvedLC#</option>
				<option value="All" <cfif arguments.criteria.currentStatus IS "all">selected</cfif>>#application.adminBundle[session.dmProfile.locale].all#</option>
			</select>
			</div>
		</cfif>
	
		#application.adminBundle[session.dmProfile.locale].filterLabel# 
		<select name="filter">
			<!--- field types that can be filtered --->
			<cfset fieldType = "string,nstring,date,UUID">
			<!--- sort structure by Key name --->
			<cfset listofKeys = listsort(structKeyList(application.types[arguments.typename].stProps),"textnocase")>	
			<!--- loop over type properties --->
			<cfloop list="#listOfKeys#" index="property">
				<!--- check if property is string --->
				<cfif listFind(fieldType,application.types[arguments.typename].stProps[property].metadata.type)>
					<option value="#property#" <cfif arguments.criteria.filter IS property>selected</cfif>>#property#</option>
				</cfif>
			</cfloop>
		</select>
		<!--- filter type exact match search or like --->
		<select name="filterType">
			<option value="exactly" <cfif arguments.criteria.filterType IS "exactly">selected</cfif>>#application.adminBundle[session.dmProfile.locale].matchesExactly#</option>
			<option value="contains" <cfif arguments.criteria.filterType IS "contains">selected</cfif>>#application.adminBundle[session.dmProfile.locale].containsLabel#</option>
		</select>
		<!--- free text field --->
		<input type="text" name="searchText" value="#arguments.criteria.searchText#">
		
		#application.adminBundle[session.dmProfile.locale].orderLabel#
		<select name="order">
		<!--- field types that can be filtered --->
		<cfloop list="#listOfKeys#" index="property">
			<!--- check if property is string --->
			<cfif listFind(fieldType,application.types[arguments.typename].stProps[property].metadata.type)>
				<option <cfif arguments.criteria.order IS "#property#">selected</cfif>  value="#property#" <cfif arguments.criteria.filter eq property>selected</cfif>>#property#
			</cfif>
		</cfloop>
		</select>
		<select name="orderDirection">
			<option <cfif arguments.criteria.orderDirection IS "asc">selected</cfif> value="asc">#application.adminBundle[session.dmProfile.locale].ascending#</option>
			<option <cfif arguments.criteria.orderDirection IS "desc">selected</cfif> value="desc">#application.adminBundle[session.dmProfile.locale].descending#</option>
		</select>
		<input type="hidden" name="customfilter" value="#arguments.criteria.customfilter#" >
		<!--- submit buttons --->
		<input type="submit" name="refine" value="#application.adminBundle[session.dmProfile.locale].filter#" class="normalbttnstyle" >
		<input type="submit" name="clear" value="#application.adminBundle[session.dmProfile.locale].clear#" class="normalbttnstyle">
	</cfoutput>
	</cfsavecontent>
	<cfreturn html>
</cffunction>

<cffunction name="permissionCheck" access="remote" returntype="string" hint="Checks if user has a permission to perform select action">
    <cfargument name="permission" type="string" required="true" hint="name of permission">
	    
		<cfscript>
			permissionReturn = application.security.checkPermission(permission=arguments.permission);
		</cfscript>
	
	<cfreturn permissionReturn>
</cffunction>

<!--- 
Doesn't appear to be used: _genericAdmin/changeStatus.cfm not in code base!
<cffunction name="changeStatus" access="remote" returntype="struct" hint="Changes status of selected object(s)">
    <cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
    	
	<cfinclude template="_genericAdmin/changeStatus.cfm">
	
	<cfreturn stStatus>
</cffunction>
 --->
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

<cffunction name="deployPermissions" hint="Creates default permissions for a given type">
	<cfargument name="typename" required="Yes">
	<cfargument name="permissionType" required="No" default="PolicyGroup">
	
	<cfscript>
		lPerms = 'Approve,CanApproveOwnContent,Create,delete,Edit,RequestApproval';
		for (i = 1;i LTE listLen(lPerms);i=i+1)
		{
			permissionName = "#arguments.typename##listGetAt(lPerms,i)#";
			
			st = application.factory.oAuthorisation.getPermission(permissionName=permissionName,permissionType='#arguments.permissionType#');
			//create permission if it doesn't exist
			dump(st);
			if (structIsEmpty(st))
			{	
				application.factory.oAuthorisation.createPermission(permissionName=permissionName, permissionType=arguments.permissionType, permissionNotes=""); 
			}
		}
	</cfscript>
</cffunction>

</cfcomponent>
