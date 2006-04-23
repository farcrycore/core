<cfcomponent displayname="Zip" hint="Function for handling zip files">

	<cffunction name="createZip" access="public" returntype="struct" hint="Adds any number of files to a zip file">
		<cfargument name="srcFileNames" type="string" required="true" hint="Absolute Path to the file. May contain multiple files seperated by a comma">
		<cfargument name="destZipName" type="string" required="true" hint="The absolute path of the destination ZIP file">
		
		<cfscript>
			// based on udf by Nathan Dintenfass (nathan@changemedia.com) 
		 
			//make a fileOutputStream object to put the ZipOutputStream into
			var output = createObject("java","java.io.FileOutputStream").init(destZipName);
			//make a ZipOutputStream object to create the zip file
			var zipOutput = createObject("java","java.util.zip.ZipOutputStream").init(output);
			//make a byte array to use when creating the zip
			//yes, this is a bit of hack, but it works
			var byteArray = repeatString(" ",1024).getBytes();
			//we'll need to create an inputStream below for writing out to the zip file
			var input = "";
			//we'll be making zipEntries below, so make a variable to hold them
			var zipEntry = "";
			var zipEntryPath = "";
			//we'll use this while reading each file
			var len = 0;
			//a var for looping below
			var ii = 1;
			//a an array of the files we'll put into the zip
			var fileArray = arrayNew(1);
			
			//add files to file array object
			fileArray = listToArray(arguments.srcFileNames);
			
			//
			// And now, on to the zip file
			//
			
			//let's use the maximum compression
			zipOutput.setLevel(9);
			//loop over the array of files we are going to zip, adding each to the zipOutput
			for(ii = 1; ii LTE arrayLen(fileArray); ii = ii + 1){
				//make a fileInputStream object to read the file into
				input = createObject("java","java.io.FileInputStream").init(fileArray[ii]);
				//make an entry for this file
				zipEntryPath = listLast(fileArray[ii],"\");
				zipEntry = createObject("java","java.util.zip.ZipEntry").init(zipEntryPath);
				//put the entry into the zipOutput stream
				zipOutput.putNextEntry(zipEntry);
				// Transfer bytes from the file to the ZIP file
				len = input.read(byteArray);
				while (len GT 0) {
					zipOutput.write(byteArray, 0, len);
					len = input.read(byteArray);
				}
				//close out this entry
				zipOutput.closeEntry();
				input.close();
			}
			//close the zipOutput
			zipOutput.close();
		</cfscript>
		
		<cfset stReturn = structNew()>
		<cfset stReturn.bSuccess = true>
		<cfset stReturn.msg = "All is well">
		<cfset stReturn.srcFileNames = listToArray(arguments.srcFileNames)>
		<cfset stReturn.destZipName = arguments.destZipName>
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="unzip" access="public" hint="Unzips a file to a specfied location">
		<cfargument name="zipFilePath" type="string" required="Yes" hint="Path to zip file">
		<cfargument name="outputPath" type="string" required="Yes" hint="Ouput path">
		
		<cfscript>
			/**
			 * Unzips a file to the specified directory.
			 * 
			 * @param zipFilePath 	 Path to the zip file (Required)
			 * @param outputPath 	 Path where the unzipped file(s) should go (Required)
			 * @return void 
			 * @author Samuel Neff (sam@serndesign.com) 
			 * @version 1, September 1, 2003 
			 */
			
			var zipFile = ""; // ZipFile
			var entries = ""; // Enumeration of ZipEntry
			var entry = ""; // ZipEntry
			var fil = ""; //File
			var inStream = "";
			var filOutStream = "";
			var bufOutStream = "";
			var nm = "";
			var pth = "";
			var lenPth = "";
			var buffer = "";
			var l = 0;
		     
			zipFile = createObject("java", "java.util.zip.ZipFile");
			zipFile.init(zipFilePath);
			
			entries = zipFile.entries();
			
			while(entries.hasMoreElements()) {
				entry = entries.nextElement();
				if(NOT entry.isDirectory()) {
					nm = entry.getName(); 
					
					lenPth = len(nm) - len(getFileFromPath(nm));
					
					if (lenPth) {
					pth = outputPath & left(nm, lenPth);
				} else {
					pth = outputPath;
				}
				if (NOT directoryExists(pth)) {
					fil = createObject("java", "java.io.File");
					fil.init(pth);
					fil.mkdirs();
				}
				filOutStream = createObject(
					"java", 
					"java.io.FileOutputStream");
				
				filOutStream.init(outputPath & nm);
				
				bufOutStream = createObject(
					"java", 
					"java.io.BufferedOutputStream");
				
				bufOutStream.init(filOutStream);
				
				inStream = zipFile.getInputStream(entry);
				buffer = repeatString(" ",1024).getBytes(); 
				
				l = inStream.read(buffer);
				while(l GTE 0) {
					bufOutStream.write(buffer, 0, l);
					l = inStream.read(buffer);
				}
				inStream.close();
				bufOutStream.close();
				}
			}
			zipFile.close();
		</cfscript>

	</cffunction>
	
</cfcomponent>