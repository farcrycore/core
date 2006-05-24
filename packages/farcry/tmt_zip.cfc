<!--- 
/** 
* Copyright 2004 massimocorner.com
* tmt_zip ColdFusion Component 
* 	A stateless CFC that support different kind of tasks related to zip files. 
	The main goal here is making the code easy to read/understand/maintain and, more in general, provide a rich set of APIs. 
	Performances optimisation was not considered a top priority.
	This component requires having tmt_file_io.cfc located inside the same directory since it use it internally for file I/O tasks. 
	Special thanks to Nathan Dintenfass for pioneering a few techniques used here. 
	ColdFusion 6.1 or above required
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     1.2, 2005-04-05
 */
--->
<cfcomponent output="false" hint="
	A stateless CFC that support different kind of tasks related to zip files. 
	The main goal here is making the code easy to read/understand/maintain and, more in general, provide a rich set of APIs. 
	Performances optimisation was not considered a top priority.
	This component requires having tmt_file_io.cfc located inside the same directory since it use it internally for file I/O tasks. 
	Special thanks to Nathan Dintenfass for pioneering a few techniques used here. 
	ColdFusion 6.1 or above required">

	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">
	<!--- Set instance variables --->
	<cfscript>
	// Store the file I/O cfc as an instance variable
	variables.ioObj = CreateObject("component", "tmt_file_io").init("utf-8");
	variables.separator = variables.ioObj.getPathSeparator();
	// By default the maximum compression level is used
	variables.compressionLevel = 9;
	</cfscript>
	
	<!--- 
	/** 
	* 	Pseudo-constructor, it ensure settings are properly loaded inside the CFC. 
		There is no need to call it, since the CFC is stateless, but it can be handy if you want to set a compression level other than the default
	* @access      public
	* @output      suppressed 
	* @param       compressionLevel (numeric)    Required. Default to #variables.compressionLevel#. 
			Compression level used by the current instance of the CFC (an integer between 0 and 9). Default to 9
	 */
	  --->
	<cffunction name="init" access="public" output="false" hint="
	Pseudo-constructor, it ensure settings are properly loaded inside the CFC. 
	There is no need to call it, since the CFC is stateless, but it can be handy if you want to set a compression level other than the default">
		<cfargument name="compressionLevel" type="numeric" default="#variables.compressionLevel#" hint="
		Compression level used by the current instance of the CFC (an integer between 0 and 9). Default to 9">
		<!--- Overwrite the compression level instance variable --->
		<cfset variables.compressionLevel = arguments.compressionLevel>
		<cfreturn this>
	</cffunction>
	
	<!--- 
	/** 
	* Check if a file/directory is contained inside a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @param       filePath (string)             Required. File path, it must be relative to the zip root
	* @return      boolean
	 */
	  --->
	<cffunction name="entryExists" access="public" output="false" returntype="boolean" hint="Check if a file/directory is contained inside a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfargument name="filePath" type="string" required="true" hint="File path, it must be relative to the zip root">
		<cfset var retVal=true>
		<cftry>
			<cfset getJavaEntry(arguments.zipFilePath, arguments.filePath)>
			<cfcatch type="any">
				<cfset retVal=false>
			</cfcatch>
		</cftry>
		<cfreturn retVal>
	</cffunction>
	
	<!--- 
	/** 
	* Return a structure containing information about an entry inside a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @param       filePath (string)             Required. File path, it must be relative to the zip root
	* @return      struct
	 */
	  --->
	<cffunction name="getEntryInfo" access="public" output="false" returntype="struct" hint="Return a structure containing information about an entry inside a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfargument name="filePath" type="string" required="true" hint="File path, it must be relative to the zip root">
		<cfscript>
		var infoStruct = StructNew();
		var jZipEntry = getJavaEntry(arguments.zipFilePath, arguments.filePath);
		infoStruct["name"] = GetFileFromPath(jZipEntry.getName());
		infoStruct["datelastmodified"] = createObject("java","java.util.Date").init(jZipEntry.getTime());
		infoStruct["size"] = jZipEntry.getSize();
		infoStruct["type"] = IIF(jZipEntry.isDirectory(), DE("Dir"), DE("File"));
		infoStruct["compressedsize"] = jZipEntry.getCompressedSize();
		infoStruct["pathfrombase"] = jZipEntry.getName();
		return infoStruct;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Get a directory listing from a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @return      query
	 */
	  --->
	<cffunction name="getEntryList" access="public" output="false" returntype="query" hint="Get a directory listing from a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfscript>
		var jEntries = getJavaEntries(arguments.zipFilePath);
		var jCurrentEntry = "";
		// Build a query to hold the data in a native CFML format
		var dirQuery = QueryNew("name, size, type, datelastmodified, attributes, mode, directory, compressedsize, pathfrombase");
		while(jEntries.hasMoreElements()){
			jCurrentEntry = jEntries.nextElement();
			// Append data to the query object
			QueryAddRow(dirQuery);
			QuerySetCell(dirQuery, "name", GetFileFromPath(jCurrentEntry.getName()));
			QuerySetCell(dirQuery, "attributes", "");
			QuerySetCell(dirQuery, "datelastmodified", createObject("java","java.util.Date").init(jCurrentEntry.getTime()));
			QuerySetCell(dirQuery, "mode", "");
			QuerySetCell(dirQuery, "size", jCurrentEntry.getSize());
			QuerySetCell(dirQuery, "type", IIF(jCurrentEntry.isDirectory(), DE("Dir"), DE("File")));
			// This cell was introduced by ColdFusion 7
			QuerySetCell(dirQuery, "directory", GetDirectoryFromPath(jCurrentEntry.getName()));
			// Additional cells, not used by <cfdirectory>
			QuerySetCell(dirQuery, "compressedsize", jCurrentEntry.getCompressedSize());
			QuerySetCell(dirQuery, "pathfrombase", jCurrentEntry.getName());
		}	
		return dirQuery;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Get an array of file and directory paths contained inside a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @return      array
	 */
	  --->
	<cffunction name="getEntryPaths" access="public" output="false" returntype="array" hint="Get an array of file and directory paths contained inside a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfscript>
		var jEntries = getJavaEntries(arguments.zipFilePath);
		var filesArray = ArrayNew(1);
		while(jEntries.hasMoreElements()){
			ArrayAppend(filesArray, jEntries.nextElement().getName());
		}
		return filesArray;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Extract all the contents from a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @param       destination (string)          Required. Default to #getDirectoryFromPath(arguments.zipFilePath)#. 
				Absolute path of a directory where the contents will be extracted.
				Default to the directory where the zip file is located
	* @return      void
	 */
	  --->
	<cffunction name="unZip" access="public" output="false" returntype="void" hint="Extract all the contents from a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfargument name="destination" type="string" default="#getDirectoryFromPath(arguments.zipFilePath)#" hint="
			Absolute path of a directory where the contents will be extracted.
			Default to the directory where the zip file is located">
		<cfscript>
		var jZip = urlToJavaZip(arguments.zipFilePath);
		var jEntries = getJavaEntries(arguments.zipFilePath);
		while(jEntries.hasMoreElements()){
			extractJavaEntry(jZip, jEntries.nextElement(), arguments.destination);
		}
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Extract a single file/directory entry from a given zip file
	* @access      public
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @param       filePath (string)             Required. File path, it must be relative to the zip root
	* @param       destination (string)          Required. Default to #getDirectoryFromPath(arguments.zipFilePath)#. 
				Absolute path of a directory where the contents will be extracted.
				Default to the directory where the zip file is located
	* @return      void
	 */
	  --->
	<cffunction name="unZipEntry" access="public" output="false" returntype="void" hint="Extract a single file/directory entry from a given zip file">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfargument name="filePath" type="string" required="true" hint="File path, it must be relative to the zip root">
		<cfargument name="destination" type="string" default="#getDirectoryFromPath(arguments.zipFilePath)#" hint="
			Absolute path of a directory where the contents will be extracted.
			Default to the directory where the zip file is located">
		<cfscript>
		var jZipEntry = getJavaEntry(arguments.zipFilePath, arguments.filePath);
		extractJavaEntry(urlToJavaZip(arguments.zipFilePath), jZipEntry, arguments.destination);
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Zip a single file or an entire directory
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname (file or directory)
	* @param       destination (string)          Required. Absolute file path of the newly created zip file
	* @return      void
	 */
	  --->
	<cffunction name="zip" access="public" output="false" returntype="void" hint="Zip a single file or an entire directory">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname (file or directory)">
		<cfargument name="destination" type="string" required="true" hint="Absolute file path of the newly created zip file">
		<cfscript>
		// CFML doesn't support method overloading; we sort of simulate it :-)
		if(variables.ioObj.isDirectory(arguments.path)){
			zipDirectory(arguments.path, arguments.destination);
		}
		else{
			zipFile(arguments.path, arguments.destination);
		}
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Zip a set of files
	* @access      public
	* @output      suppressed 
	* @param       filesArray (array)            Required. Array of file paths
	* @param       destination (string)          Required. Absolute file path of the newly created zip file
	* @return      void
	 */
	  --->
	<cffunction name="zipAll" access="public" output="false" returntype="void" hint="Zip a set of files">
		<cfargument name="filesArray" type="array" required="yes" hint="Array of file paths">
		<cfargument name="destination" type="string" required="true" hint="Absolute file path of the newly created zip file">
		<cfscript>
		var jZipStream = "";
		// If the destination directory doesn't exists, create it
		variables.ioObj.createDirectory(getDirectoryFromPath(arguments.destination));
		jZipStream = urlToZipOutput(arguments.destination);
		for(i=1; i LTE ArrayLen(arguments.filesArray); i=i+1){
			// We handle only files
			if(NOT variables.ioObj.isDirectory(arguments.filesArray[i])){
				addToZipStream(arguments.filesArray[i], getFileFromPath(arguments.filesArray[i]), jZipStream);
			}
		}
		jZipStream.close();
		</cfscript>
	</cffunction>
	
	<!--- Private methods  --->
	
	<!--- 
	/** 
	* Zip an entire directory and its contents
	* @access      private
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       destination (string)          Required. Absolute file path of the newly created zip file
	* @return      void
	 */
	  --->
	<cffunction name="zipDirectory" access="private" output="false" returntype="void" hint="Zip an entire directory and its contents">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="destination" type="string" required="true" hint="Absolute file path of the newly created zip file">
		<cfscript>
		var jZipStream = "";
		// Get all the directory's content, recursively
		var dirQuery = variables.ioObj.getFileList(arguments.directoryPath, true);
		// If the destination directory doesn't exists, create it
		variables.ioObj.createDirectory(getDirectoryFromPath(arguments.destination));
		jZipStream = urlToZipOutput(arguments.destination);
		</cfscript>
		<!--- Loop over the directory listing adding each file to the zip stream --->
		<cfloop query="dirQuery">
			<cfset jZipStream = addToZipStream(dirQuery.fullpath, dirQuery.pathfrombase, jZipStream)>
		</cfloop>
		<cfset jZipStream.close()>
	</cffunction>
	
	<!--- 
	/** 
	* Zip a single file
	* @access      private
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       destination (string)          Required. Absolute file path of the newly created zip file
	* @return      void
	 */
	  --->
	<cffunction name="zipFile" access="private" output="false" returntype="void" hint="Zip a single file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="destination" type="string" required="true" hint="Absolute file path of the newly created zip file">
		<cfscript>
		var jZipStream = "";
		// Be sure the file exists
		variables.ioObj.checkFilePath(arguments.filePath);
		// If the destination directory doesn't exists, create it
		variables.ioObj.createDirectory(getDirectoryFromPath(arguments.destination));
		jZipStream = urlToZipOutput(arguments.destination);
		jZipStream = addToZipStream(arguments.filePath, getFileFromPath(arguments.filePath), jZipStream);
		jZipStream.close();
		</cfscript>
	</cffunction>
	
	<!--- Utility methods  --->
	
	<!--- 
	/** 
	* Add a file to a given Java java.util.zip.ZipOutputStream object (remember to close the zip stream after calling this method!)
	* @access      private
	* @output      suppressed 
	* @param       fileSourcePath (string)       Required. Absolute file path
	* @param       pathFromZipBase (string)      Required. Destination path for the file, relative to the zip root
	* @param       zipStream                     Required. Java java.util.zip.ZipOutputStream object
	 */
	  --->
	<cffunction name="addToZipStream" access="private" output="false" hint="Add a file to a given Java java.util.zip.ZipOutputStream object (remember to close the zip stream after calling this method!)">
		<cfargument name="fileSourcePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="pathFromZipBase" type="string" required="true" hint="Destination path for the file, relative to the zip root">
		<cfargument name="zipStream" required="true" hint="Java java.util.zip.ZipOutputStream object">
		<cfscript>
		var jZip = arguments.zipStream;
		var jInputStream = createObject("java","java.io.FileInputStream").init(arguments.fileSourcePath);
		var jZipEntry = createObject("java","java.util.zip.ZipEntry").init(arguments.pathFromZipBase);
		var buffer = repeatString(" ", 1024).getBytes();
		var fileData = "";
		jZip.setLevel(variables.compressionLevel);
		// Add the entry
		jZip.putNextEntry(jZipEntry);
		fileData = jInputStream.read(buffer);
		// Write data
		while(fileData GTE 0){
			jZip.write(buffer, 0, fileData);
			fileData = jInputStream.read(buffer);
		}
		jInputStream.close();
		jZip.closeEntry();
		return jZip;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Extract a single Java entry object to a destination directory
	* @access      private
	* @output      suppressed 
	* @param       jZip                          Required. Java zip object
	* @param       jZipEntry                     Required. Java entry object
	* @param       destination (string)          Required. Absolute path of a directory where the contents will be extracted
	* @return      void
	 */
	  --->
	<cffunction name="extractJavaEntry" access="private" output="false"	returntype="void" hint="Extract a single Java entry object to a destination directory">
		<cfargument name="jZip" required="true" hint="Java zip object">
		<cfargument name="jZipEntry" required="true" hint="Java entry object">
		<cfargument name="destination" type="string" required="true" hint="Absolute path of a directory where the contents will be extracted">
		<cfscript>
		var jInputStream = arguments.jZip.getInputStream(arguments.jZipEntry);
		var buffer = repeatString(" ", 1024).getBytes();
		var fileData = "";
		var jOutputStream = "";
		var jBufferedStream = "";
		var destinationFile = "";
		// In case the destination path is missing the trailing slash, add it
		if(NOT arguments.destination.endsWith(variables.separator)){
			arguments.destination = arguments.destination & variables.separator;
		}
		// Full destination path for the file
		destinationFile = arguments.destination & arguments.jZipEntry.getName();
		// If the destination directory doesn't exists, create it
		variables.ioObj.createDirectory(getDirectoryFromPath(destinationFile));
		</cfscript>
		<cftry>
			<!--- 
			Sometimes we may fail to read data out of a file (for many reasons, including weird characters inside its name). 
			So it's better to silently fail and move to next file, in order to manage to extract from the zip as many data as possible
			 --->
			<cfset fileData = jInputStream.read(buffer)>
			<!--- Better to lock since we write on the file system --->
			<cflock timeout="30" throwontimeout="yes" name="#destinationFile#" type="exclusive">
				<cfscript>
				// Extract data only if the entry is a file
				if(NOT arguments.jZipEntry.isDirectory()){
					jOutputStream = createObject("java","java.io.FileOutputStream").init(destinationFile);
					jBufferedStream = createObject("java","java.io.BufferedOutputStream").init(jOutputStream);
					while(fileData GTE 0){
						jBufferedStream.write(buffer, 0, fileData);
						fileData = jInputStream.read(buffer);
					}
					jInputStream.close();
					jBufferedStream.close();
				}
				</cfscript>
			</cflock>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cffunction>
	
	<!--- 
	/** 
	* Extract a single Java entry object from a given zip file path
	* @access      private
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	* @param       filePath (string)             Required. File path, it must be relative to the zip root
	* @exception   tmt_zip
	 */
	  --->
	<cffunction name="getJavaEntry" access="private" output="false" hint="Extract a single Java entry object from a given zip file path">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfargument name="filePath" type="string" required="true" hint="File path, it must be relative to the zip root">
		<cfset var jZipEntry="">
		<!--- Be sure the zip file exists --->
		<cfset variables.ioObj.checkFilePath(arguments.zipFilePath)>
		<cfset jZipEntry=urlToJavaZip(arguments.zipFilePath).getEntry(arguments.filePath)>
		<!--- If the file isn't contained inside the zip, Java returns a null, making the variable undefined in CFML --->
		<cfif NOT IsDefined("jZipEntry")>
			<cfthrow message="tmt_zip: File #arguments.zipFilePath# does not contains #arguments.filePath#" type="tmt_zip">
		</cfif>
		<cfreturn jZipEntry>
	</cffunction>
	
	<!--- 
	/** 
	* Extract a collection of Java entry objects from a given zip file path
	* @access      private
	* @output      suppressed 
	* @param       zipFilePath (string)          Required. Absolute file path of the zip file
	 */
	  --->
	<cffunction name="getJavaEntries" access="private" output="false" hint="Extract a collection of Java entry objects from a given zip file path">
		<cfargument name="zipFilePath" type="string" required="true" hint="Absolute file path of the zip file">
		<cfscript>
		// Be sure the zip file exists
		variables.ioObj.checkFilePath(arguments.zipFilePath);
		return urlToJavaZip(arguments.zipFilePath).entries();
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a file path into a java.util.zip.ZipFile object
	* @access      private
	* @output      suppressed 
	* @param       filePath (string)             Required. File path
	 */
	  --->
	<cffunction name="urlToJavaZip" access="private" output="false" hint="Turn a file path into a java.util.zip.ZipFile object">
		<cfargument name="filePath" type="string" required="true" hint="File path">
		<cfreturn createObject("java","java.util.zip.ZipFile").init(arguments.filePath)>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a file path into a java.util.zip.ZipOutputStream object
	* @access      private
	* @output      suppressed 
	* @param       filePath (string)             Required. File path
	 */
	  --->
	<cffunction name="urlToZipOutput" access="private" output="false" hint="Turn a file path into a java.util.zip.ZipOutputStream object">
		<cfargument name="filePath" type="string" required="true" hint="File path">
		<cfscript>
		var jOutputStream = createObject("java","java.io.FileOutputStream").init(arguments.filePath);
		return createObject("java","java.util.zip.ZipOutputStream").init(jOutputStream);
		</cfscript>
	</cffunction>
	
</cfcomponent>