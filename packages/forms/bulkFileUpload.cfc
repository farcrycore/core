<cfcomponent displayname="Bulk File Upload" hint="Form for uploading zip packages of files" extends="forms" output="false">
	<cfproperty name="lSelectedCategoryID" type="string" default="" hint="The categories to assign the files" ftSeq="1" ftFieldset="" ftLabel="Categories" ftType="category" />
	<cfproperty name="zipFile" type="string" default="" hint="The zip file to process" ftSeq="2" ftFieldset="" ftLabel="File" ftType="file" ftMimeTypes="application/x-zip-compressed" ftDestination="/bulkFileUpload" />
	<cfproperty name="bLibrary" type="boolean" default="1" hint="Should these files be added to the library" ftSeq="3" ftFieldset="" ftLabel="Add to file library" ftType="boolean" />
	
	<cffunction name="process" access="public" output="false" returntype="struct" hint="Process form">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<cfset var zipFile = createObject("java", "java.util.zip.ZipFile") />
		<cfset var entries = "" /><!--- Will be an iteration object --->
		<cfset var qStartingPointData = "" />
		<cfset var iBaseLevel = 0 />
		<cfset var qStartPointDescendants = "" />
		<cfset var objCategory = CreateObject("component","#application.packagepath#.farcry.category") />
		<cfset var entry = "" /><!--- Zip file entry --->
		<cfset var navigationParentId = "" />
		<cfset var folderName = "" />
		<cfset var q = "" /><!--- Used to store  --->
		<cfset var stProps = structnew() />
		<cfset var stNewObj = structnew() />
		<cfset var oNav = createobject("component", application.stCOAPI.dmNavigation.packagepath) />
		<cfset var oTree = createObject("component", "#application.packagepath#.farcry.tree") />
		<cfset var sFileName = "" />
		<cfset var sFilePath = "" />
		<cfset var oFile = createObject("component", "#application.packagepath#.farcry.file") />
		<cfset var sAbsolutePath = "" /><!--- placeholder for the original filename --->
		<cfset var filOutStream = createObject("java","java.io.FileOutputStream") />
		<cfset var bufOutStream = createObject("java","java.io.BufferedOutputStream") />
		<cfset var inStream = "" />
		<cfset var buffer = "" />
		<cfset var l = "" />
		<cfset var stFileProps = structnew() />
		<cfset var coFile = createobject("component", application.stCOAPI.dmFile.packagepath) />
		<cfset var stParent = "" />
		<cfset var sFileMimetype = "" />
		
		<cfset arguments.fields.result = "" /><!--- Hold output of processing --->
		
		<cfset zipFile.init("#application.path.defaultFilePath##arguments.fields.zipFile#") />
		<cfset entries = zipFile.entries() />
		
		<!--- Get the data on the starting point in the tree --->
		<cfset qStartingPointData = createObject("component", "#application.packagepath#.farcry.tree").getNode(objectid=application.fapi.getNavID("fileroot")) />
		
		<!--- Set the floor for adding folders and files --->
		<cfset iBaseLevel = qStartingPointData.nLevel />
		
		<!--- 
			Get a query object containing all descendants of the starting point. This query will be used as
			a lookup table for folders. If the folder exists at the correct level than nothing will be done.
			Otherwise the new folder will be created and the lookup table updated
		 ---> 
		<cfset qStartPointDescendants = createObject("component", "#application.packagepath#.farcry.tree").getDescendants(objectid=qStartingPointData.objectId) />
		
		<!--- Loop through all entries in the zip file --->
		<cfloop condition="entries.hasMoreElements()">
			<cfset entry = entries.nextElement() />
			<cfset navigationParentId = qStartingPointData.objectId />
			
			<!--- create the directories --->
			<cfif not structKeyExists(form,"bCreateDirectories") and listLen(entry.getName(), "/")>
				<!--- Loop over all directories in the path and make sure  they exist --->
				<!--- If they don't exist create them. --->
				<cfloop list="#entry.getName()#" index="folderName" delimiters="/">
					<!--- If it's a filename then don't make a folder out of it --->
					<cfif not REFind("\....",folderName)>
						<cfquery dbtype="query" name="q">
							select		objectId
							from		qStartPointDescendants
							where		objectName = '#folderName#' 
										and nLevel = #iBaseLevel+listfind(entry.getName(),folderName,"/")#
										and parentId = '#navigationParentId#'
						</cfquery>
						
						<cfif not q.recordcount>
							<!--- Setup the struct of properties for the new dmNavigation node --->
							<cfset arguments.fields.result = "<em>Creating dmNavigation Node (#folderName#)</em><br>" />
							
							<!--- Construct navigation object --->
							<cfset stProps=structNew() />
							<cfset stProps.objectid = application.fc.utils.createJavaUUID() />
							<cfset stProps.label = folderName />
							<cfset stProps.title = folderName />
							<cfset stProps.lastupdatedby = application.security.getCurrentUserID() />
							<cfset stProps.datetimelastupdated = Now() />
							<cfset stProps.createdby = application.security.getCurrentUserID() />
							<cfset stProps.datetimecreated = Now() />
							
							<!--- create the new dmNavigation object --->
							<cfset stNewObj = oNav.createData(stProperties=stProps) />
							
							<!--- Add the new object into the tree --->
							<cfset oTree.setYoungest(parentID=navigationParentID,objectID=stProps.objectID,objectName=stProps.label,typeName='dmNavigation') />
							
							<!--- set the navigationParentId for the next folder in the list --->
							<cfset navigationParentId = stNewObj.objectid />
							
							<!--- Now update the query with this new descendant info --->
							<cfset qStartPointDescendants = oTree.getDescendants(objectid=qStartingPointData.objectId) />
						<cfelse>
							<cfset navigationParentId = q.objectId />
						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<!--- Now create the file --->
			<cftry>
				<cfif not entry.isDirectory()>
					<cfset sFileName = getFileFromPath(entry.getName()) />
					<cfset sFilePath = application.defaultfilepath />
					
					<!--- do we have a mime type match? --->
					<!--- If the MIME Type of the file matches any list item in the file accept list --->
					<!--- if accept list not specified in config, accept everything --->
					<cfset sFileMimetype = oFile.getMimeType(sFileName) />
					<cfif listFindNoCase(application.config.file.filetype, sFileMimetype) OR NOT Len(Trim(application.config.file.filetype))>
						<!--- placeholder for the original filename --->
						<cfset sAbsolutePath = sFilePath & "/" & sFileName />
						
						<!--- Write the file to disk --->
						<cfset filOutStream.init(sAbsolutePath) />
						<cfset bufOutStream.init(filOutStream) />
						<cfset inStream = zipFile.getInputStream(entry) />
						<cfset buffer = repeatString(" ",1024).getBytes() />
						<cfset l = inStream.read(buffer) />
						<cfloop condition="l gte 0">
							<cfset bufOutStream.write(buffer, 0, l) />
							<cfset l = inStream.read(buffer) />
						</cfloop>
						
						<!--- cleanup --->
						<cfset inStream.close() />
						<cfset bufOutStream.close() />
						<cfset filOutStream.close() />
						
						<!--- Create structure with new file properties --->
						<cfset arguments.fields.result = arguments.fields.result & "Creating dmFile (#sFileName#)<br>" />
						
						<cfset stFileProps = structNew() />
						<cfset stFileProps.objectID = application.fc.utils.createJavaUUID() />
						<cfset stFileProps.fileName = createObject("component","#application.packagepath#.farcry.form").sanitiseFileName(sFileName,listFirst(sFileName,"."),sFilePath) />
						<cfset stFileProps.title = listFirst(stFileProps.fileName,".") />
						<cfset stFileProps.label = listFirst(stFileProps.fileName,".") />
						<cfset stFileProps.filePath = sFilePath />
						<cfset stFileProps.fileType = listFirst(sFileMimetype,"/") />
						<cfset stFileProps.fileSubType = listLast(sFileMimetype,"/") />
						<cfset stFileProps.fileExt = listLast(stFileProps.fileName,".") />
						<cfset stFileProps.filesize = entry.getSize() />
						<cfset stFileProps.datetimecreated = Now() />
						<cfset stFileProps.documentDate = createODBCDate(now()) />
						<cfset stFileProps.createdby = application.security.getCurrentUserID() />
						<cfset stFileProps.datetimelastupdated = Now() />
						<cfset stFileProps.lastupdatedby = application.security.getCurrentUserID() />
						<cfset stFileProps.bLibrary = arguments.fields.bLibrary />
						
						<!--- Create the file object --->
						<cfset coFile.createData(stProperties=stFileProps) />
						
						<!--- assign category --->
						<cfset objCategory.assignCategories(objectid=stFileProps.objectID,lCategoryIDs=arguments.fields.lSelectedCategoryID) />
						
						<!--- Add the new file under it's nav parent --->
						<cfset stParent = oNav.getData(navigationParentID) />
						<cfset arrayAppend(stParent.aObjectIds, stFileProps.objectId) />
						<cfset stParent.dateTimeCreated =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#") />
						<cfset stParent.dateTimeLastUpdated = createODBCDate(now()) />
						<cfset oNav.setData(stProperties=stParent) />
					<cfelse>
						<cfset arguments.fields.result = arguments.fields.result & "<span class=""fail"">Skipping &quot;#entry.getName()#&quot;. NOT an acceptable file MIME type (#sFileMimeType#)</span><br>" />
					</cfif>
				</cfif>
				
				<cfcatch type="any">
					<cfset arguments.fields.result = arguments.fields.result & "<span class=""fail"">Error: &quot;#entry.getName()#&quot; could not be uploaded to the server (#cfcatch.Message#)</span><br>">
				</cfcatch>
			</cftry>
			
		</cfloop>
		
		<cfset zipFile.close() />
		
		<cfreturn arguments.fields />
	</cffunction>
	
</cfcomponent>