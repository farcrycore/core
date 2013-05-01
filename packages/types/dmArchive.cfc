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
$Header: /cvs/farcry/core/packages/types/dmArchive.cfc,v 1.10 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: dmArchive type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="dmArchive handler" hint="archive objects" bRefObjects="false">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="archiveID" type="UUID" hint="ID of archived entry" required="no" default=""> 
<cfproperty name="objectWDDX" type="longchar" hint="WDDX packet that defines the object being archived" required="no" default="">  

<!--- Object Methods --->
<cffunction name="fArchiveObject" access="public" hint="archiving of related items to content types (eg. files and images)" returntype="struct">
	<cfargument name="stObj" required="yes" type="struct">

	<cfset var stLocal = StructNew()>
	<cfset var location = "" />
	
	<cfset stlocal.returnStruct = StructNew()>
	<cfset stLocal.stObj = StructCopy(arguments.stObj)>
	
	<cfwddx input="#stLocal.stObj#" output="stLocal.stLiveWDDX"  action="cfml2wddx">

	<!--- set up the dmArchive structure to save --->
	<cfset stLocal.stProps = structNew()>
	<cfset stLocal.stProps.objectID = application.fc.utils.createJavaUUID()>
	<cfset stLocal.stProps.archiveID = stLocal.stObj.objectID>
	<cfset stLocal.stProps.objectWDDX = stLocal.stLiveWDDX>
	<cfset stLocal.stProps.label = stLocal.stObj.label>
	<!--- //end dmArchive struct --->  
	
	<cfif structKeyExists(stLocal.stObj,"bLibrary") AND stLocal.stObj.bLibrary EQ 1>
		<cfset stLocal.method = "ioCopyFile" />
	<cfelse>
		<cfset stLocal.method = "ioMoveFile" />
	</cfif>
	
	<cfset createData(stProperties=stLocal.stProps)>
	<cfif stLocal.stObj.typename EQ "dmFile" OR stLocal.stObj.typename EQ "dmImage">
		
		<cfif StructKeyExists(application.config.general,"bdoarchive") AND application.config.general.bdoarchive EQ "true">
			<cfswitch expression="#stLocal.stObj.typename#">
				<!--- archive file --->
				<cfcase value="dmFile">
					<cfset location = appliation.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=stLocal.stObj.fileName) />
					<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="#location#" source_file="#stLocal.stObj.filename#" dest_location="archive" dest_file="/#stLocal.stObj.typename#/#stLocal.stProps.archiveID#.#ListLast(stLocal.stObj.filename,'.')#" />
				</cfcase>
				<!--- archive image --->
				<cfcase value="dmimage">
					<!--- default image --->
					<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stObj.imageFile#" dest_location="archive" dest_file="/#stLocal.stObj.typename#/#stLocal.stProps.archiveID#_default.#ListLast(stLocal.stObj.imageFile,'.')#" />
					
					<!--- thumbnail image --->
					<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stObj.thumbnail#" dest_location="archive" dest_file="/#stLocal.stObj.typename#/#stLocal.stProps.archiveID#_thumb.#ListLast(stLocal.stObj.thumbnail,'.')#" />
					
					<!--- optimised image --->
					<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stObj.optimisedImage#" dest_location="archive" dest_file="/#stLocal.stObj.typename#/#stLocal.stProps.archiveID#_optimised.#ListLast(stLocal.stObj.optimisedImage,'.')#" />
				</cfcase>
				
				<cfdefaultcase>
					<!--- dont do anything --->
				</cfdefaultcase>
			</cfswitch>
		</cfif>
	</cfif>

	<cfset fArchiveRelatedObject(stLocal.stObj)>
	<cfreturn stlocal.returnStruct>
</cffunction>	

<cffunction name="fArchiveRelatedObject" access="public" hint="archiving of related items to content types (eg. files and images)">
	<cfargument name="stObj" required="yes" type="struct">

	<cfset var stLocal = StructNew()>
	
	<cfset stLocal.stObj = StructCopy(arguments.stObj)>

	<cfif StructKeyExists(stLocal.stObj,"aObjectIDs")>
		<cfloop index="stLocal.i" from="1" to="#ArrayLen(stLocal.stObj.aObjectIDs)#">
	
			<cfset stLocal.archiveType = findType(stLocal.stObj.aObjectIDs[stLocal.i])>

			<cfset stLocal.archiveObjectId = application.fc.utils.createJavaUUID()>

			<!--- create object specific object content type and then get data --->
			<cfset stLocal.instanceObject = createobject("component",application.types[stLocal.archiveType].typepath)>
			<cfset stLocal.stInstance = stLocal.instanceObject.getData(stLocal.stObj.aObjectIDs[stLocal.i])>
	
			<cfif StructKeyExists(stLocal.stInstance,"ObjectID")>
				<!--- Convert current object to WDDX for archive --->
				<cfwddx input="#stLocal.stInstance#" output="stLocal.stInstanceWDDX"  action="cfml2wddx">
				<!--- archive object into database --->
				<cfset stLocal.stProps = StructNew()>
				<cfset stLocal.stProps.objectID = stLocal.archiveObjectId>
				<cfset stLocal.stProps.archiveID = stLocal.stInstance.objectID>
				<cfset stLocal.stProps.objectWDDX = stLocal.stInstanceWDDX>
				<cfset stLocal.stProps.label = stLocal.stInstance.title>
				<cfset stLocal.returnStruct = createData(stProperties=stLocal.stProps)>
	
				<!--- check if item is part of library, if so then move a copy as others may reference it --->
				<cfif structKeyExists(stLocal.stInstance,"bLibrary") AND stLocal.stInstance.bLibrary EQ 1>
					<cfset stLocal.method = "ioCopyFile">
				<cfelse>
					<cfset stLocal.method = "ioMoveFile">
				</cfif>
				
				<cfswitch expression="#stLocal.archiveType#">
					<!--- archive file --->
					<cfcase value="dmFile">
						<cfset location = appliation.fc.lib.cdn.ioFindFile(locations="privatefiles,publicfiles",file=stLocal.stInstance.fileName) />
					<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="#location#" source_file="#stLocal.stInstance.fileName#" dest_location="archive" dest_file="/#stLocal.stInstance.typename#/#stLocal.stProps.archiveID#.#ListLast(stLocal.stInstance.filename,'.')#" />
					</cfcase>
		
					<!--- archive image --->
					<cfcase value="dmImage">
						<!--- default image --->
						<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stInstance.imageFile#" dest_location="archive" dest_file="/#stLocal.stInstance.typename#/#stLocal.stProps.archiveID#_default.#ListLast(stLocal.stInstance.imageFile,'.')#" />
						
						<!--- thumbnail image --->
						<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stInstance.thumbnail#" dest_location="archive" dest_file="/#stLocal.stInstance.typename#/#stLocal.stProps.archiveID#_thumb.#ListLast(stLocal.stInstance.thumbnail,'.')#" />
						
						<!--- optimised image --->
						<cfinvoke component="#application.fc.lib.cdn#" method="#stLocal.method#" source_location="images" source_file="#stLocal.stInstance.optimisedImage#" dest_location="archive" dest_file="/#stLocal.stInstance.typename#/#stLocal.stProps.archiveID#_optimised.#ListLast(stLocal.stInstance.optimisedImage,'.')#" />
					</cfcase>
					
					<cfdefaultcase>
						<!--- dont do anything --->
					</cfdefaultcase>
				</cfswitch>
			</cfif>	
		</cfloop>
	</cfif>
</cffunction>
	
</cfcomponent>
