<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Autoimport files from drop folder --->

<cfset qFiles = application.fc.lib.cdn.ioGetDirectoryListing(location="drop") />
<cfset jobID = application.fapi.getUUID() />

<cfloop query="qFiles">
	<cfset parts= listtoarray(qFiles.file,"/") />
	<cfset ownedby = "" />
	<cfset typename = "" />
	<cfset filename = "" />
	<cfset allowedExtensions = "" />
	<cfset sizeLimit = 0 />
	<cfset qMetadata = "" />
	<cfset uploadTarget = "" />
	
	<cfswitch expression="#arraylen(parts)#">
		<cfcase value="1">
			<!--- this case is not handled atm --->
		</cfcase>
		<cfcase value="2">
			<!--- 'anonymous':username, 1:contenttype, 2:filename --->
			<cfset typename = parts[1] />
			<cfset filename = "/" & parts[2] />
		</cfcase>
		<cfcase value="3">
			<!--- 1:username, 2:contenttype, 3:filename --->
			<cfset ownedby = parts[1] />
			<cfset typename = parts[2] />
			<cfset filename = "/" & parts[3] />
		</cfcase>
	</cfswitch>
	
	<cfif len(typename) and application.stCOAPI[typename].bBulkUpload and right(filename,4) neq ".log">
		<cftry>
			<cfset uploadTarget = application.stCOAPI[typename].bulkUploadTarget />
			
			<cfif structkeyexists(application.stCOAPI[typename].stProps[uploadTarget].metadata,"ftAllowedExtensions")>
				<cfset allowedExtensions = application.stCOAPI[typename].stProps[uploadTarget].metadata.ftAllowedExtensions />
			<cfelseif structkeyexists(application.stCOAPI[typename].stProps[uploadTarget].metadata,"ftAllowedFileExtensions")>
				<cfset allowedExtensions = application.stCOAPI[typename].stProps[uploadTarget].metadata.ftAllowedFileExtensions />
			</cfif>
			
			<cfif structkeyexists(application.stCOAPI[typename].stProps[uploadTarget].metadata,"ftSizeLimit")>
				<cfset sizeLimit = application.stCOAPI[typename].stProps[uploadTarget].metadata.ftSizeLimit />
			<cfelseif structkeyexists(application.stCOAPI[typename].stProps[uploadTarget].metadata,"ftMaxSize")>
				<cfset sizeLimit = application.stCOAPI[typename].stProps[uploadTarget].metadata.ftMaxSize />
			</cfif>
			
			<cfset fileProblem = application.fc.lib.cdn.ioValidateFile(location="drop",file=qFiles.file,acceptextensions=allowedExtensions,sizeLimit=sizeLimit) />
			
			<cfif len(fileProblem)>
				
				<cfset application.fc.lib.cdn.ioWriteFile(location="drop",file=rereplace(qFiles.file,"\.\w+$",".log"),data=fileProblem,datatype="text") />
				
			<cfelse>
				
				<cfset filename = application.fc.lib.cdn.ioMoveFile(source_location="drop",source_file=qFiles.file,dest_location="temp",dest_file=filename,nameconflict="makeunique") />
				
				<cfset stTask = {
					objectid : application.fapi.getUUID(),
					tempfile : filename,
					typename : typename,
					targetfield : uploadTarget,
					defaults : structnew()
				} />
				<cfset application.fc.lib.tasks.addTask(jobID=jobID,ownedBy=ownedBy,action="bulkupload.upload",details=stTask) />
				
			</cfif>
			
			<cfcatch>
				<cfsavecontent variable="html"><cfdump var="#application.fc.lib.error.normalizeError(cfcatch)#"></cfsavecontent>
				
				<cfset application.fc.lib.cdn.ioWriteFile(location="drop",file=rereplace(qFiles.file,"\.\w+$",".html"),data="<html><body>" & html & "</body></html>",datatype="text") />
			</cfcatch>
		</cftry>
	</cfif>
</cfloop>

<cfsetting enablecfoutputonly="false" />