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
<!--- @@displayname: Bulk Image Uploader --->
<!--- @@Description: Bulk image upload utility. Processes form posts from the bulk file upload flex ui. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->


<cfif not StructIsEmpty(form)>
	<cfset oImage = createObject("component", application.stCoapi.dmImage.packagePath) />
	<cfset oImageFormtool = createObject("component", "farcry.core.packages.formtools.image") />

	<cfset physicalPath = "#application.path.imageRoot#/#application.stCoapi.dmImage.STPROPS.SourceImage.METADATA.FTDESTINATION#" />

	<cftry>
		<cfif not directoryExists("#physicalPath#")>
			<cfset b = oImageFormtool.createFolderPath("#physicalPath#") />
		</cfif>
	
	
		<cffile action="UPLOAD" filefield="FILEDATA" destination="#physicalPath#/#form.FILENAME#" nameconflict="MAKEUNIQUE" />
			
		<cfcatch>
			<cflog log="Application" type="error" text="#form.fieldNames# #cfcatch.Message# #cfcatch.Detail#" />
			<cfabort />
		</cfcatch>
	
	</cftry>
			
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = "#application.fc.utils.createJavaUUID()#" />
	<cfset stProperties.label = "#cffile.serverFile#" />
	<cfset stProperties.title = "#cffile.serverFile#" />
	<cfset stProperties.alt = "#cffile.serverFile#" />
	
	<cfif isdefined("form.categoryID")>
		<cfset stProperties.catImage = form.categoryID />
		<cfset objCategory = CreateObject("component","#application.packagepath#.farcry.category") />
		<cfset objCategory.assignCategories(objectid=stProperties.objectid,lCategoryIDs=form.categoryID)>
	</cfif>
	
	<cfset stProperties.sourceimage = "#application.stCoapi.dmImage.STPROPS.SourceImage.METADATA.FTDESTINATION#/#cffile.serverFile#" />

	<!--- SETUP AUTO GENERATE INFORMATION --->
	<cfset stFormPost = structNew() />
	<cfset stFormPost.StandardImage.stSupporting.CreateFromSource = true />
	<cfset stFormPost.ThumbnailImage.stSupporting.CreateFromSource = true />
	
	
	<cflock name="MultipleImageUpload" timeout="10" throwontimeout="false">
		<cfset stProperties = oImageFormtool.ImageAutoGenerateBeforeSave(stProperties=stProperties, stFields=application.stCoapi.dmImage.stProps,stFormPost=stFormPost) />	
		<cfset stResult = oImage.createData(stProperties=stProperties,user="multiupload") />
	</cflock>
	
	
</cfif>

