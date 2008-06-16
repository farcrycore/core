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

<cfcomponent extends="types" displayname="dmArchive handler" hint="archive objects">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="archiveID" type="UUID" hint="ID of archived entry" required="no" default=""> 
<cfproperty name="objectWDDX" type="longchar" hint="WDDX packet that defines the object being archived" required="no" default="">  

<!--- Object Methods --->
<cffunction name="fArchiveObject" access="public" hint="archiving of related items to content types (eg. files and images)" returntype="struct">
	<cfargument name="stObj" required="yes" type="struct">

	<cfset var stLocal = StructNew()>
	<cfset var pathSep = "\"><!--- default is windows path separator --->
	<cfset var archiveDirectory = application.config.general.archivedirectory><!--- archive directory from config --->
	
	<cfif not directoryExists("#archiveDirectory#")>
		<cfset archiveDirectory = "#application.path.project#/archive" />
	</cfif>
	
	<cfset stlocal.returnStruct = StructNew()>
	<cfset stLocal.stObj = StructCopy(arguments.stObj)>
	
	<cfif left(archiveDirectory,1) neq "/"><!--- not *nix path --->
		<cfset archiveDirectory = replaceNoCase("#archiveDirectory#","/","\","all")>
	<cfelse>
		<cfset archiveDirectory = replaceNoCase("#archiveDirectory#","\","/","all")>
		<cfset pathSep = "/">
	</cfif>
	
	<cfif Right(archiveDirectory,1) NEQ pathSep>
		<cfset archiveDirectory= "#archiveDirectory##pathSep#">
	</cfif>

		<cfset stLocal.directoryToCheck = ListDeleteAt(archiveDirectory,ListLen(archiveDirectory,pathSep),pathSep)>
		<cfset stLocal.directoryNameToCheck = ListLast(archiveDirectory,pathSep)>
	
	<!--- create archive directorys if needed --->
	<cfdirectory action="list" directory="#stLocal.directoryToCheck#" name="stLocal.qDirectory" filter="#stLocal.directoryNameToCheck#">

	<!--- create a files directory --->
	<cfif stLocal.qDirectory.recordcount EQ 0>
		<cfdirectory action="create" directory="#archiveDirectory#">
	</cfif>
		
	<cfwddx input="#stLocal.stObj#" output="stLocal.stLiveWDDX"  action="cfml2wddx">

	<!--- set up the dmArchive structure to save --->
	<cfset stLocal.stProps = structNew()>
	<cfset stLocal.stProps.objectID = createUUID()>
	<cfset stLocal.stProps.archiveID = stLocal.stObj.objectID>
	<cfset stLocal.stProps.objectWDDX = stLocal.stLiveWDDX>
	<cfset stLocal.stProps.label = stLocal.stObj.label>
	<!--- //end dmArchive struct --->  

	<cfset createData(stProperties=stLocal.stProps)>
	<cfif stLocal.stObj.typename EQ "dmFile" OR stLocal.stObj.typename EQ "dmImage">

		<!--- struct to hold the information on where to move files to --->
		<cfset stLocal.stFile = StructNew()>

		<cfdirectory action="list" directory="#archiveDirectory#" name="stLocal.qDirectory" filter="#stLocal.stObj.typename#">
		<!--- create a files directory --->
		<cfif stLocal.qDirectory.recordcount EQ 0>
			<cfdirectory action="create" directory="#archiveDirectory##pathSep##stLocal.stObj.typename#">
		</cfif>

		<cfset stLocal.stFile.destinationDir = "#archiveDirectory##stLocal.stObj.typename##pathSep#">
				
		<!--- check if item is part of library, if so then move a copy as others may reference it --->
		<cfif structKeyExists(stLocal.stObj,"bLibrary") AND stLocal.stObj.bLibrary EQ 1>
			<cfset stLocal.stFile.action = "copy">
		<cfelse>
			<cfset stLocal.stFile.action = "move">
		</cfif>

		<cfswitch expression="#stLocal.stObj.typename#">
			<!--- archive file --->
			<cfcase value="dmFile">
				<cfif StructKeyExists(application.config.file,"archivefiles") AND application.config.file.archivefiles EQ "true">
					<cfset stLocal.stFile.sourceDir = "#application.path.project##pathSep#www#pathSep#files#pathSep#">
					<cfset stLocal.stFile.sourceFileName = "#stLocal.stObj.fileName#">
					<cfset stLocal.stFile.destinationFileName = "#stLocal.stProps.archiveID#.#ListLast(stLocal.stFile.sourceFileName,'.')#">
					<cfset stLocal.fReturnStruct = fMoveFile(stLocal.stFile)>
				</cfif>
			</cfcase>
	
			<!--- archive image --->
			<cfcase value="dmimage">
				<cfif StructKeyExists(application.config.image,"archivefiles") AND application.config.file.archivefiles EQ "true">
					<!--- default image --->
					<cfset stLocal.stFile.sourceDir = "#stLocal.stObj.originalImagePath##pathSep#">
					<cfset stLocal.stFile.sourceFileName = "#stLocal.stObj.imageFile#">
					<cfset stLocal.stFile.destinationFileName = "#stLocal.stProps.archiveID#_default.#ListLast(stLocal.stFile.sourceFileName,'.')#">
					<cfset stLocal.fReturnStruct = fMoveFile(stLocal.stFile)>
		
					<!--- thumbnail image --->
					<cfset stLocal.stFile.sourceDir = "#stLocal.stObj.thumbnailImagePath##pathSep#">
					<cfset stLocal.stFile.sourceFileName = "#stLocal.stObj.thumbnail#">
					<cfset stLocal.stFile.destinationFileName = "#stLocal.stProps.archiveID#_thumb.#ListLast(stLocal.stFile.sourceFileName,'.')#">
					<cfset stLocal.fReturnStruct = fMoveFile(stLocal.stFile)>
		
					<!--- optimised image --->				
					<cfset stLocal.stFile.sourceDir = "#stLocal.stObj.optimisedImagePath##pathSep#">
					<cfset stLocal.stFile.sourceFileName = "#stLocal.stObj.optimisedImage#">
					<cfset stLocal.stFile.destinationFileName = "#stLocal.stProps.archiveID#_optimised.#ListLast(stLocal.stFile.sourceFileName,'.')#">
					<cfset stLocal.fReturnStruct = fMoveFile(stLocal.stFile)>
				</cfif>
			</cfcase>
			
			<cfdefaultcase>
				<!--- dont do anything --->
			</cfdefaultcase>
		</cfswitch>
	</cfif>

	<cfset fArchiveRelatedObject(stLocal.stObj)>
	<cfreturn stlocal.returnStruct>
</cffunction>	

<cffunction name="fArchiveRelatedObject" access="public" hint="archiving of related items to content types (eg. files and images)">
	<cfargument name="stObj" required="yes" type="struct">

	<cfset var stLocal = StructNew()>
	<cfset var archiveDirectory = application.config.general.archivedirectory><!--- archive directory from config --->
	
	<cfif not directoryExists("#archiveDirectory#")>
		<cfset archiveDirectory = "#application.path.project#/archive" />
	</cfif>
	
	<cfset stLocal.stObj = StructCopy(arguments.stObj)>

	<cfif StructKeyExists(stLocal.stObj,"aObjectIDs")>
		<cfloop index="stLocal.i" from="1" to="#ArrayLen(stLocal.stObj.aObjectIDs)#">
	
			<cfset stLocal.archiveType = findType(stLocal.stObj.aObjectIDs[stLocal.i])>

			<!--- create files directorys if needed --->
			<cfdirectory action="list" directory="#archiveDirectory#" name="qDirectory" filter="#stLocal.archiveType#">
			<!--- create a files directory --->
			<cfif qDirectory.recordCount EQ 0>
				<cfdirectory action="create" directory="#archiveDirectory#/#stLocal.archiveType#">
			</cfif>

			<cfset stLocal.archiveObjectId = createUUID()>

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
	
				<!--- struct to hold the information on where to move files to --->
				<cfset stLocal.stFile = StructNew()>
				<cfif (Right(archiveDirectory,1) NEQ "\") AND (Right(archiveDirectory,1) NEQ "/")>
					<cfset stLocal.stFile.destinationDir = "#archiveDirectory#/#stLocal.archiveType#/">
				<cfelse>
					<cfset stLocal.stFile.destinationDir = "#archiveDirectory##stLocal.archiveType#/">
				</cfif>
	
				<!--- check if item is part of library, if so then move a copy as others may reference it --->
				<cfif structKeyExists(stLocal.stInstance,"bLibrary") AND stLocal.stInstance.bLibrary EQ 1>
					<cfset stLocal.stFile.action = "copy">
				<cfelse>
					<cfset stLocal.stFile.action = "move">
				</cfif>

				<cfswitch expression="#stLocal.archiveType#">
					<!--- archive file --->
					<cfcase value="dmFile">
						<cfset stLocal.stFile.sourceDir = "#application.path.project#/www/files/">
						<cfset stLocal.stFile.sourceFileName = "#stLocal.stInstance.fileName#">
						<cfset stLocal.stFile.destinationFileName = "#stLocal.archiveObjectId#.#ListLast(stLocal.stFile.sourceFileName,'.')#">
						<cfset stLocal.returnStruct = fMoveFile(stLocal.stFile)>
					</cfcase>
		
					<!--- archive image --->
					<cfcase value="dmImage">
						<!--- default image --->
						<cfset stLocal.stFile.sourceDir = "#stLocal.stInstance.originalImagePath#/">
						<cfset stLocal.stFile.sourceFileName = "#stLocal.stInstance.imageFile#">
						<cfset stLocal.stFile.destinationFileName = "#stLocal.archiveObjectId#_default.#ListLast(stLocal.stFile.sourceFileName,'.')#">
						<cfset stLocal.returnStruct = fMoveFile(stLocal.stFile)>
		
						<!--- thumbnail image --->
						<cfset stLocal.stFile.sourceDir = "#stLocal.stInstance.thumbnailImagePath#/">
						<cfset stLocal.stFile.sourceFileName = "#stLocal.stInstance.thumbnail#">
						<cfset stLocal.stFile.destinationFileName = "#stLocal.archiveObjectId#_thumb.#ListLast(stLocal.stFile.sourceFileName,'.')#">
						<cfset stLocal.returnStruct = fMoveFile(stLocal.stFile)>
		
						<!--- optimised image --->				
						<cfset stLocal.stFile.sourceDir = "#stLocal.stInstance.optimisedImagePath#/">
						<cfset stLocal.stFile.sourceFileName = "#stLocal.stInstance.optimisedImage#">
						<cfset stLocal.stFile.destinationFileName = "#stLocal.archiveObjectId#_optimised.#ListLast(stLocal.stFile.sourceFileName,'.')#">
						<cfset stLocal.returnStruct = fMoveFile(stLocal.stFile)>
					</cfcase>
					
					<cfdefaultcase>
						<!--- dont do anything --->
					</cfdefaultcase>
				</cfswitch>
			</cfif>	
		</cfloop>
	</cfif>
</cffunction>
	
<cffunction name="fMoveFile" access="public" hint="move file from one location to another">
	<cfargument name="stFile" required="yes" type="struct">

	<cfset var stLocal = StructNew()>
	<cfset var pathSep = "\"><!--- windows by default --->
	<cfset stLocal.stFile = StructCopy(arguments.stFile)>

	<!---
	stFile needs:	sourcedir 			=	source directory
					destinationdir		=	destination directory
					sourceFilename		=	file to copy
					destinationFilename	=	file name which to rename it to
					
	TODO: need to be reviewed originally with nothing in the catch block - pt
	--->

	<cftry>
		<!--- extra precautions to check that directory is correct --->
		<cfif left(stLocal.stFile.sourceDir,1) neq "/"><!--- not *nix path --->
			<cfset stLocal.stFile.sourceDir = replaceNoCase("#stLocal.stFile.sourceDir#","/","\","all")>
			<cfset stLocal.stFile.destinationdir = replaceNoCase("#stLocal.stFile.destinationdir#","/","\","all")>
		<cfelse>
			<cfset stLocal.stFile.sourceDir = replaceNoCase("#stLocal.stFile.sourceDir#","\","/","all")>
			<cfset stLocal.stFile.destinationdir = replaceNoCase("#stLocal.stFile.destinationdir#","\","/","all")>
			<cfset pathSep = "/">
		</cfif>

		<cfif right(stLocal.stFile.sourceDir,1) NEQ pathSep>
			<cfset stLocal.stFile.sourceDir = stLocal.stFile.sourceDir & pathSep>
		</cfif>
		<cfif right(stLocal.stFile.destinationdir,1) NEQ pathSep>
			<cfset stLocal.stFile.destinationdir = stLocal.stFile.destinationdir & pathSep>
		</cfif>

		<cfif fileExists("#stLocal.stFile.sourceDir##stLocal.stFile.sourceFilename#")>
			<cfif stLocal.stFile.action EQ "move">			
				<cffile action="move" source="#stLocal.stFile.sourceDir##stLocal.stFile.sourceFilename#" destination="#stLocal.stFile.destinationdir##stLocal.stFile.destinationFilename#">
			<cfelse>
				<cffile action="copy" source="#stLocal.stFile.sourceDir##stLocal.stFile.sourceFilename#" destination="#stLocal.stFile.destinationdir#">
				<cffile action="rename" source="#stLocal.stFile.destinationdir##stLocal.stFile.sourceFilename#" destination="#stLocal.stFile.destinationdir##stLocal.stFile.destinationFilename#">
			</cfif>			
		</cfif>

		<cfcatch type="any">
			<cfoutput>dmArchive: Error in fMoveFile method call </cfoutput>
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>

</cffunction>

</cfcomponent>
