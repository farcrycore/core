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
$Header: /cvs/farcry/core/packages/types/versions.cfc,v 1.4.2.2 2006/01/23 22:30:32 geoff Exp $
$Author: geoff $
$Date: 2006/01/23 22:30:32 $
$Name: milestone_3-0-1 $
$Revision: 1.4.2.2 $

|| DESCRIPTION || 
$Description: Component Versions Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
--->
<cfcomponent extends="farcry.core.packages.types.types" bAbstract="true" displayname="Versions Abstract Class" hint="Provides default properties and handlers for content object types using farcry versioning.  This component should never be instantiated directly -- it should only be inherited.">
<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="" />
<cfproperty name="status" type="string" hint=" Status of the object (draft, pending, approved)." required="yes" default="draft" ftLabel="Status" />
<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	

	<!--- // STATUS: versions status changing methods --->
	<cffunction name="statustodraft" access="public" returntype="struct" hint="Sends object to draft state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- delete underlying draft if it exists
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustodraft()>
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustopending" access="public" returntype="struct" hint="Sends object to pending state." output="false">
	<!--- 	
	// TODO: 
		probably nothing to do here but super
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustopending()>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustoapproved" access="public" returntype="struct" hint="Sends object to approved state." output="false">
	<!--- 	
	// TODO: 
		Versioning (via versions.cfc)
			- archive current live
			- set appropriate friendly url as required
	 --->		
		<cfset var stresult=structnew()>
		<cfset stresult=super.statustoapproved()>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to approved.">
 		<cfreturn stResult>
	</cffunction>

	<cffunction name="delete" access="public" hint="Basic delete method for all objects. Deletes content item and removes Verity entries." returntype="struct" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<!--- get the data for this instance --->
		<cfset var stObj = getData(arguments.objectID)>
		<cfset var stResult = StructNew()>
		<cfset var stReturn = StructNew()>
		<cfset var qVersionedObjects	= '' />

		<cfif not len(arguments.user)>
			<cfif application.security.isLoggedIn()>
				<cfset arguments.user = application.security.getCurrentUserID() />
			<cfelse>
				<cfset arguments.user = 'anonymous' />
			</cfif>
		</cfif>
		
		<cfif structisempty(stobj)>
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = "Content item (#arguments.objectid#) does not exsit.">
			<cfreturn stReturn>
		</cfif>

		<!--- Find any draft objects of this object and delete them first. --->
		<cfquery datasource="#application.dsn#" name="qVersionedObjects">
		SELECT objectid
		FROM #stobj.typename#
		WHERE versionid = '#stobj.objectid#'
		</cfquery>
		<cfif qVersionedObjects.recordcount>
			<cfloop query="qVersionedObjects">
				<cfset stResult = delete(objectid="#qVersionedObjects.objectid#", user="#arguments.user#", auditNote="#arguments.auditNote#") />
				
			</cfloop>
		</cfif>
				
		<cfset stReturn = super.delete(objectid="#arguments.objectid#", user="#arguments.user#", auditNote="#arguments.auditNote#") />
		<cfreturn stReturn />
		
	</cffunction>
</cfcomponent>

