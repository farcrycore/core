<cfcomponent>
<!--- TODO : IMPLEMENT ALL INTERFACES TO JCompress

ACTION - Action to be performed. NEW/ADD/EXTRACT/EXTRACTALL, Required.

  -NEW - Create a new zip file. 
   <CFX_JCompress ACTION="NEW" FILEIN="d:\myFile.txt,d:\myFile2.txt" FILEOUT="d:\ZippedFile.zip">
   FILEIN - Comma delimited list of the name(s) and path(s) of the file(s) or directory(ies) to be compressed. Required.
   FILEOUT - Name and path of compressed file to be returned. Required.    DEBUGGING - Returns debugging information to the screen.

  -ADD - Add file to an existing zip file. 
   <CFX_JCompress ACTION="ADD" FILEIN="d:\myFile.txt,d:\myFile2.txt" FILEOUT="d:\ZippedFile.zip">
   FILEIN - Comma delimited list of the name(s) and path(s) of the file(s) or directory(ies)to be compressed. Required.
   FILEOUT - Name and path of compressed file to be returned. Required.   DEBUGGING - Returns debugging information to the screen.

  -EXTRACT - Extract select files from a zip file. 
   <CFX_JCompress ACTION="EXTRACT" FILEIN="d:\ZippedFile.zip" FILEOUT="d:\myFile.txt,d:\myFile2.txt">
   FILEIN - Name and path of compressed file. Required.
   FILEOUT - Comma delimited list of the name(s) and path(s) of the file(s) to be de-compressed. Required.    DEBUGGING - Returns debugging information to the screen.

  -EXTRACTALL - Extract all files from a zip file. 
   <CFX_JCompress ACTION="EXTRACTALL" FILETOEXTRACT="d:\ZippedFile.zip" [FILEOUT]>
   FILETOEXTRACT - Name and path of the file to be de-compressed. Required.
   FILEOUT - Name and path of directory the contents of the zip file will be extracted to. Optional.    DEBUGGING - Returns debugging information to the screen. --->


	<cffunction name="createZip" access="public" returntype="struct" hint="Adds any number of files to a zip file">
		<cfargument name="srcFileNames" type="string" required="true" hint="Absolute Path to the file. May contain multiple files seperated by a comma">
		<cfargument name="destZipName" type="string" required="true" hint="The absolute path of the destination ZIP file">
		
		<!--- clean up the list in case there are invalid file names --->
		<cfscript>
			stReturn = structNew();
			aFiles = listToArray(arguments.srcFileNames);
			stReturn.aInvalidFilenames = arrayNew(1);
			for(i = arrayLen(aFiles);i EQ 1; i = i - 1)
			{
				
				if (NOT fileExists(afiles[i]))
				{	
					arrayAppend(stReturn.aInvalidFilenames,aFiles[i]); //add to the error log
					arrayDeleteAt(aFiles,i);//get rid of this filename 
				
				}	
			}
			//This will be the new list we process 
			arguments.srcFileNames = arrayToList(aFiles);
		</cfscript>	
		
		<!--- Now add to Zip --->
		<cftry>
			<CFX_JCompress ACTION="NEW" FILEIN="#arguments.srcFileNames#" FILEOUT="#arguments.destZipName#" >
			<cfset stReturn.bSuccess = true>
			<cfset stReturn.msg = "All is well">
			<cfset stReturn.srcFileNames = listToArray(arguments.srcFileNames)>
			<cfset stReturn.destZipName = arguments.destZipName>
			
			<cfcatch>
				<cfset stReturn.bSucess = false>
				<cfset stReturn.msg = cfcatch.message>
			</cfcatch>
		</cftry>	
				
		<cfreturn stReturn>
	</cffunction>
	
</cfcomponent>