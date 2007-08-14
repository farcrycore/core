
<cfif not StructIsEmpty(form)>
	<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
	<cfset oImage = createObject("component", application.stCoapi.dmImage.packagePath) />
	<cfset oFormTools = createObject("component", "farcry.core.packages.farcry.formtools") />
	
	<cfset physicalPath = "#application.path.imageRoot#/#application.stCoapi.dmImage.STPROPS.SourceImage.METADATA.FTDESTINATION#">
	<cfif not directoryExists("#physicalPath#")>
		<cfset b = createFolderPath("#physicalPath#")>
	</cfif>
	
<cftry>
	<cffile action="UPLOAD" filefield="FILEDATA" destination="#physicalPath#/#form.FILENAME#" nameconflict="MAKEUNIQUE" />
		
	<cfcatch>
		<cflog file="cflog.log" type="information" text="#form.fieldNames# #cfcatch.Message# #cfcatch.Detail#">
		<cfabort>		
	</cfcatch>

</cftry>		
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = "#createUUID()#" />
	<cfset stProperties.label = "#file.serverFile#" />
	<cfset stProperties.title = "#file.serverFile#" />
	<cfset stProperties.alt = "#file.serverFile#" />
	<cfif isdefined("form.categoryID")>
		<cfset stProperties.catImage = form.categoryID />
		<cfset objCategory = CreateObject("component","#application.packagepath#.farcry.category") />
		<cfset objCategory.assignCategories(objectid=stProperties.objectid,lCategoryIDs=form.categoryID)>
	</cfif>
	<cfset stProperties.sourceimage = "#application.stCoapi.dmImage.STPROPS.SourceImage.METADATA.FTDESTINATION#/#file.serverFile#" />

	<!--- SETUP AUTO GENERATE INFORMATION --->
	<cfset stFormPost = structNew() />
	<cfset stFormPost.StandardImage.stSupporting.CreateFromSource = true />
	<cfset stFormPost.ThumbnailImage.stSupporting.CreateFromSource = true />
	
	
	<cflock name="MultipleImageUpload" timeout="10" throwontimeout="false">
		<cfset stProperties = oFormTools.ImageAutoGenerateBeforeSave(stProperties=stProperties, stFields=application.stCoapi.dmImage.stProps,stFormPost=stFormPost) />	
		<cfset stResult = oImage.createData(stProperties=stProperties,user="multiupload") />
	</cflock>
	
</cfif>

