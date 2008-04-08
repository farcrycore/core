<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
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
	<cfset stProperties.objectid = "#createUUID()#" />
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

