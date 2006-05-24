<!--- 
/** 
* Copyright 2004 massimocorner.com
* tmt_file_io ColdFusion Component 
* A stateless CFC that support different kind of file I/O tasks. 
  The main goal here is making the code easy to read/understand/maintain, 
  ensure proper locking and exceptions handling and, more in general, provide a rich set of APIs. 
  Performances optimisation was not considered a top priority.
  Since I was frustrated by the inconsistencies in the way cfdirectory handles the datelastmodified field, 
  the methods that return a query object use ISO 8601 as date format. 
  I also added four additional fields: fullpath, pathfrombase, canread and canwrite. 
  The first two are especially handy whenever you use recursive directory lists.
  ColdFusion 6.1 or above required
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     1.2, 2005-04-05
 */
--->
<cfcomponent output="no" hint="
	A stateless CFC that support different kind of file I/O tasks. 
	The main goal here is making the code easy to read/understand/maintain, 
	ensure proper locking and exceptions handling and, more in general, provide a rich set of APIs. 
	Performances optimisation was not considered a top priority.
	Since I was frustrated by the inconsistencies in the way cfdirectory handles the datelastmodified field, 
	the methods that return a query object use ISO 8601 as date format. 
	I also added four additional fields: fullpath, pathfrombase, canread and canwrite. 
	The first two are especially handy whenever you use recursive directory lists.
	ColdFusion 6.1 or above required">

	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">
	<!--- Set instance variables --->
	<cfscript>
	variables.charset = "iso-8859-1";
	variables.separator = getPathSeparator();
	</cfscript>
	
	<!--- 
	/** 
	* Pseudo-constructor, it ensure settings are properly loaded inside the CFC. 
	  There no need to call it, since the CFC is stateless, 
	  but it can be handy if you want to set a character encoding inside the CFC other than the default
	* @access      public
	* @output      suppressed 
	* @param       charset (string)              Required. Default to #variables.charset#. Character encoding used by the current instance of the CFC
	 */
	--->
	<cffunction name="init" access="public" output="false" hint="
	Pseudo-constructor, it ensure settings are properly loaded inside the CFC. 
	There no need to call it, since the CFC is stateless, 
	but it can be handy if you want to set a character encoding inside the CFC other than the default">
		<cfargument name="charset" type="string" default="#variables.charset#" hint="Character encoding used by the current instance of the CFC">
		<!--- Overwrite the charset instance variable --->
		<cfset variables.charset = arguments.charset>
		<cfreturn this>
	</cffunction>
	
	<!--- Recursive paths listing methods  --->
	
	<!--- 
	/** 
	* Get an array of file and/or directory paths contained inside a given directory
	* @access      private
	* @output      suppressed 
	* @param       path (string)                 Required. Absolute directory path
	* @param       type (string)                 Required. Either File, Dir or an empty string (if you want both). Default to an empty string
	* @param       recursive (boolean)           Required. Default to true. Recursively list nested directories. Default to true
	* @return      array
	 */
	--->
	<cffunction name="getPaths" access="private" output="false" returntype="array" hint="Get an array of file and/or directory paths contained inside a given directory">
		<cfargument name="path" type="string" required="yes" hint="Absolute directory path">
		<cfargument name="type" type="string" default="" hint="Either File, Dir or an empty string (if you want both). Default to an empty string">
		<cfargument name="recursive" type="boolean" default="true" hint="Recursively list nested directories. Default to true">
		<cfset var listDir="">
		<cfset var tmpArray="">
		<cfset var f="">
		<cfset var filesArray=ArrayNew(1)>
		<cfif NOT arguments.path.endsWith(variables.separator)>
			<cfset arguments.path=arguments.path & variables.separator>
		</cfif>
		<cfdirectory action="list" directory="#arguments.path#" name="listDir">
		<cfloop query="listDir">
			<cfif listDir.type EQ "File">
				<cfif arguments.type NEQ "Dir">
					<!--- Get the files --->
					<cfset ArrayAppend(filesArray, arguments.path & listDir.name)>
				</cfif>
				<cfelse>
				<cfif arguments.type NEQ "File">
					<!--- Get the directories --->
					<cfset ArrayAppend(filesArray, arguments.path & listDir.name)>
				</cfif>
				<!--- Recursively list nested directories --->
				<cfif arguments.recursive EQ true>
					<cfset tmpArray=getPaths(arguments.path & listDir.name, arguments.type, arguments.recursive)>
					<cfloop index="f" from="1" to="#ArrayLen(tmpArray)#">
						<cfset ArrayAppend(filesArray, tmpArray[f])>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn filesArray>
	</cffunction>
	
	<!--- 
	/** 
	* Get an array of directory paths contained inside a given directory
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to true. Recursively list nested directories. Default to true
	* @return      array
	 */
	--->
	<cffunction name="getDirectoryPaths" access="public" output="false" returntype="array" hint="Get an array of directory paths contained inside a given directory">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="true" hint="Recursively list nested directories. Default to true">
		<cfreturn getPaths(arguments.directoryPath, "Dir", arguments.recursive)>
	</cffunction>
	
	<!--- 
	/** 
	* Get an array of files paths contained inside a given directory
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to true. Recursively list nested directories. Default to true
	* @return      array
	 */
	--->
	<cffunction name="getFilePaths" access="public" output="false" returntype="array" hint="Get an array of files paths contained inside a given directory">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="true" hint="Recursively list nested directories. Default to true">
		<cfreturn getPaths(arguments.directoryPath, "File", arguments.recursive)>
	</cffunction>
	
	<!--- 
	/** 
	* Get an array of paths contained inside a given directory, both files and directories
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to true. Recursively list nested directories. Default to true
	* @return      array
	 */
	--->
	<cffunction name="getFullPaths" access="public" output="false" returntype="array" hint="Get an array of paths contained inside a given directory, both files and directories">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="true" hint="Recursively list nested directories. Default to true">
		<cfreturn getPaths(arguments.directoryPath, "", arguments.recursive)>
	</cffunction>
	
	<!--- Directory listings methods  --->
	
	<!--- 
	/** 
	* Get a file and/or directory listing
	* @access      private
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @param       type (string)                 Required. Either File or Dir
	* @param       recursive (boolean)           Required. Default to false. Recursively list nested directories. Default to false
	* @return      query
	 */
	--->
	<cffunction name="getList" access="private" output="false" returntype="query" hint="Get a file and/or directory listing">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfargument name="type" type="string" default="" hint="Either File or Dir">
		<cfargument name="recursive" type="boolean" default="false" hint="Recursively list nested directories. Default to false">
		<cfscript>
		var jDir = "";
		var dirList = "";
		var dirQuery = "";
		var f = "";
		// Be sure the directory exists
		checkDirectoryPath(arguments.path);
		// Create and initialize a Java File object
		jDir = CreateObject("java", "java.io.File");
		jDir.init(arguments.path);
		// Get a list of paths contained inside the directory
		dirList = getPaths(arguments.path, arguments.type, arguments.recursive);
		// Build a query to hold the data in a native CFML format
		dirQuery = QueryNew("name, size, type, datelastmodified, attributes, mode, directory, fullpath, pathfrombase, canread, canwrite");
		// Loop over the paths
		for(f = 1; f LTE ArrayLen(dirList); f = f + 1){   
			// Reinitialise Java File object for current iteration
			jDir.init(dirList[f]);
			// Append data to the query object
			QueryAddRow(dirQuery);
			QuerySetCell(dirQuery, "name", GetFileFromPath(dirList[f]));
			QuerySetCell(dirQuery, "attributes", "");
			QuerySetCell(dirQuery, "datelastmodified", createObject("java","java.util.Date").init(jDir.lastModified()));
			QuerySetCell(dirQuery, "mode", "");
			QuerySetCell(dirQuery, "size", jDir.length());
			QuerySetCell(dirQuery, "type", IIF(jDir.isFile(), DE("File"), DE("Dir")));
			// This cell was introduced by ColdFusion 7
			QuerySetCell(dirQuery, "directory", GetDirectoryFromPath(dirList[f]));
			// Additional cells, not used by <cfdirectory>
			QuerySetCell(dirQuery, "fullpath", dirList[f]);
			QuerySetCell(dirQuery, "pathfrombase", Replace(dirList[f], arguments.path & variables.separator, ""));
			QuerySetCell(dirQuery, "canread", jDir.canRead());
			QuerySetCell(dirQuery, "canwrite", jDir.canWrite());
		}
		// Return a copy of the query (to ensure thread safety)
		return dirQuery;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Get a directory listing, directories only
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to false. Recursively list nested directories. Default to false
	* @return      query
	 */
	--->
	<cffunction name="getDirectoryList" access="public" output="false" returntype="query" hint="Get a directory listing, directories only">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="false" hint="Recursively list nested directories. Default to false">
		<cfreturn getList(arguments.directoryPath, "Dir", arguments.recursive)>
	</cffunction>
	
	<!--- 
	/** 
	* Get a directory listing, files only
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to false. Recursively list nested directories. Default to false
	* @return      query
	 */
	--->
	<cffunction name="getFileList" access="public" output="false" returntype="query" hint="Get a directory listing, files only">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="false" hint="Recursively list nested directories. Default to false">
		<cfreturn getList(arguments.directoryPath, "File", arguments.recursive)>
	</cffunction>
	
	<!--- 
	/** 
	* Get a full directory listing, both files and directories
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       recursive (boolean)           Required. Default to false. Recursively list nested directories. Default to false
	* @return      query
	 */
	--->
	<cffunction name="getFullList" access="public" output="false" returntype="query" hint="Get a full directory listing, both files and directories">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="recursive" type="boolean" default="false" hint="Recursively list nested directories. Default to false">
		<cfreturn getList(arguments.directoryPath, "", arguments.recursive)>
	</cffunction>
	
	<!--- Generic methods  --->
	
	<!--- 
	/** 
	* Tests whether the application can read the given abstract pathname
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="canRead" access="public" output="false" returntype="boolean" hint="Tests whether the application can read the given abstract pathname">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).canRead>
	</cffunction>
	
	<!--- 
	/** 
	* Tests whether the application can modify the given abstract pathname
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="canWrite" access="public" output="false" returntype="boolean" hint="Tests whether the application can modify the given abstract pathname">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).canWrite>
	</cffunction>
	
	<!--- 
	/** 
	* Tests whether the given abstract pathname is a directory
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="isDirectory" access="public" output="false" returntype="boolean" hint="Tests whether the given abstract pathname is a directory">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).isDirectory>
	</cffunction>
	
	<!--- 
	/** 
	* Returns the time that the file or directory denoted by this abstract pathname was last modified
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      date
	 */
	--->
	<cffunction name="getLastModified" access="public" output="false" returntype="date" hint="Returns the time that the file or directory denoted by this abstract pathname was last modified">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).lastModified>
	</cffunction>
	
	<!--- 
	/** 
	* Tests whether the given abstract pathname is a file
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="isFile" access="public" output="false" returntype="boolean" hint="Tests whether the given abstract pathname is a file">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).isFile>
	</cffunction>
	
	<!--- 
	/** 
	* Tests whether the given abstract pathname is hidden
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="isHidden" access="public" output="false" returntype="boolean" hint="Tests whether the given abstract pathname is hidden">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfreturn getInfo(arguments.path).isHidden>
	</cffunction>
	
	<!--- 
	/** 
	* Return a structure containing information about the given abstract pathname
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      struct
	 */
	--->
	<cffunction name="getInfo" access="public" output="false" returntype="struct" hint="Return a structure containing information about the given abstract pathname">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfscript>
		var infoStruct = StructNew();
		var jFile = urlToJavaFile(arguments.path);
		infoStruct["canRead"] = jFile.canRead();
		infoStruct["canWrite"] = jFile.canWrite();
		infoStruct["exists"] = jFile.exists();
		infoStruct["isDirectory"] = jFile.isDirectory();
		infoStruct["isFile"] = jFile.isFile();
		infoStruct["isHidden"] = jFile.isHidden();
		infoStruct["length"] = jFile.length();
		infoStruct["lastModified"] = createObject("java","java.util.Date").init(jFile.lastModified());
		return infoStruct;
		</cfscript>
	</cffunction>
	¨
	<!--- 
	/** 
	* Marks given abstract pathname so that only read operations are allowed
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      boolean
	 */
	--->
	<cffunction name="setReadOnly" access="public" output="false" returntype="boolean" hint="Marks given abstract pathname so that only read operations are allowed">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfscript>
		var jFile = urlToJavaFile(arguments.path);
		return jFile.setReadOnly();
		</cfscript>
	</cffunction>
	
	<!--- Directory methods  --->
	
	<!--- 
	/** 
	* Copy a directory, including all its contents
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Absolute directory path
	* @param       destination (string)          Required. Absolute directory path of a directory where the contents will be moved
	 */
	--->
	<cffunction name="copyDirectory" access="public" output="false" hint="Copy a directory, including all its contents">
		<cfargument name="source" type="string" required="true" hint="Absolute directory path">
		<cfargument name="destination" type="string" required="true" hint="Absolute directory path of a directory where the contents will be moved">
		<cfscript>
		// The information contained inside the file and directory lists make the copy operation simpler
		var dirQuery = getDirectoryList(arguments.source, true);
		var filesQuery = getFileList(arguments.source, true);
		// Throw an error if the source directory doesn't exist
		checkDirectoryPath(arguments.source);
		// Create the destination directory
		createDirectory(arguments.destination);
		</cfscript>
		<!--- Create all the directories first --->
		<cfloop query="dirQuery">
			<cfset createDirectory(arguments.destination & variables.separator & dirQuery.pathfrombase)>
		</cfloop>
		<!--- Copy the files --->
		<cfloop query="filesQuery">
			<cfset copyFile(filesQuery.fullpath, GetDirectoryFromPath(arguments.destination & variables.separator & filesQuery.pathfrombase))>
		</cfloop>
	</cffunction>
	
	<!--- 
	/** 
	* Creates a directory, including any necessary but nonexistent parent directories. 
	Note that if this operation fails it may have succeeded in creating some of the necessary parent directories
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @exception   tmt_file_io
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="createDirectory" access="public" output="false" hint="Creates a directory, including any necessary but nonexistent parent directories. 
Note that if this operation fails it may have succeeded in creating some of the necessary parent directories">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfset var jDir=urlToJavaFile(arguments.directoryPath)>
		<cfset var created=false>
		<cfif NOT DirectoryExists(arguments.directoryPath)>
			<cftry>
				<!--- Lock on creation. In order to have a unique name for the lock we use the dir url --->
				<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.directoryPath#">
					<cfset created=jDir.mkdirs()>
				</cflock>
				<cfcatch type="any">
					<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
					<cfthrow message="tmt_file_io: Error creating directory: #arguments.directoryPath# and/or all necessary parent directories" detail="#cfcatch.detail#" type="tmt_file_io">
				</cfcatch>
			</cftry>
			<cfif created EQ false>
				<cfthrow message="tmt_file_io: Error creating directory: #arguments.directoryPath# and/or all necessary parent directories" type="tmt_file_io">
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- 
	/** 
	* Delete a directory, including all its contents
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       throwIfMissing (boolean)      Optional. Default to false. Raise an exception if the directory doesn’t exists. Default to false
	 */
	--->
	<cffunction name="deleteDirectory" access="public" output="false" hint="Delete a directory, including all its contents">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="throwIfMissing" type="boolean" required="false" default="false" hint="Raise an exception if the directory doesn’t exists. Default to false">
		<cfscript>
		var filePaths = getFilePaths(arguments.directoryPath);
		var dirPaths = getDirectoryPaths(arguments.directoryPath);
		var jDir = CreateObject("java", "java.io.File");
		var f = "";
		var d = "";
		if (arguments.throwIfMissing){
			// Throw an error if the directory doesn't exist
			checkDirectoryPath(arguments.directoryPath);
		}
		// Sorting by pathname allows to delete the child directories first
		ArraySort(dirPaths, "text", "desc");
		// Delete the files first
		for(f = 1; f LTE ArrayLen(filePaths); f = f + 1){   
			deleteFile(filePaths[f]);
		}
		// Delete the directories too
		for(d = 1; d LTE ArrayLen(dirPaths); d = d + 1){   
			jDir.init(dirPaths[d]).delete();
		}
		// Delete the main directory itself
		jDir.init(arguments.directoryPath).delete();
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Get the size of a given directory
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @return      numeric
	 */
	--->
	<cffunction name="getDirectorySize" access="public" output="false" returntype="numeric" hint="Get the size of a given directory">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfscript>
		var dirSize = 0;
		// Create and initialize a Java File object
		var jFile = CreateObject("java", "java.io.File");
		// Get an array of file paths
		var pathsArray = getPaths(arguments.directoryPath, "File", true);
		// Loop over the directory listing
		for(f = 1; f LTE ArrayLen(pathsArray); f = f + 1){   
			// Reinitialise Java File object for current iteration
			jFile.init(pathsArray[f]);
			dirSize = dirSize + jFile.length();
		}
		</cfscript>
		<cfreturn dirSize>
	</cffunction>
	
	<!--- 
	/** 
	* Move a directory, including all its contents
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Absolute directory path
	* @param       destination (string)          Required. Absolute directory path of a directory where the contents will be moved
	 */
	--->
	<cffunction name="moveDirectory" access="public" output="false" hint="Move a directory, including all its contents">
		<cfargument name="source" type="string" required="true" hint="Absolute directory path">
		<cfargument name="destination" type="string" required="true" hint="Absolute directory path of a directory where the contents will be moved">
		<cfscript>
		copyDirectory(arguments.source, arguments.destination);
		deleteDirectory(arguments.source);
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Rename a directory
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @param       newDirectory (string)         Required. New name
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="renameDirectory" access="public" output="false" hint="Rename a directory">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfargument name="newDirectory" type="string" required="true" hint="New name">
		<cfset checkDirectoryPath(arguments.directoryPath)>
		<cftry>
			<!--- Lock on rename. In order to have a unique name for the lock we use the dir url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.directoryPath#">
				<cfdirectory directory="#arguments.directoryPath#" action="rename" newdirectory="#arguments.newDirectory#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error renaming directory: #arguments.directoryPath#. It may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- File methods  --->
	
	<!--- 
	/** 
	* Appends text to a file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       fileContent (string)          Required. Content of the file to be created
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="appendFile" access="public" output="false" hint="Appends text to a file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="fileContent" type="string" required="true" hint="Content of the file to be created">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<!--- Throw an error if the file doesn't exist --->
		<cfset checkFilePath(arguments.filePath)>
		<cftry>
			<!--- Lock file on write. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.filePath#">
				<cffile action="append" file="#arguments.filePath#" output="#arguments.fileContent#" charset="#arguments.fileCharset#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error writing to file: #arguments.filePath#. File may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- 
	/** 
	* Copy a file
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Absolute file path of the file to copy
	* @param       destination (string)          Required. Pathname of a directory where the file will be copied. If not an absolute path, it is relative to the source directory
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="copyFile" access="public" output="false" hint="Copy a file">
		<cfargument name="source" type="string" required="true" hint="Absolute file path of the file to copy">
		<cfargument name="destination" type="string" required="true" hint="Pathname of a directory where the file will be copied. If not an absolute path, it is relative to the source directory">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfset checkFilePath(arguments.source)>
		<cfset checkDirectoryPath(arguments.destination)>
		<cftry>
			<!--- Lock on copy. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.source#">
				<cffile action="copy" source="#arguments.source#" destination="#arguments.destination#" charset="#arguments.fileCharset#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error coping file: #arguments.source#. It may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- 
	/** 
	* Delete a file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       throwIfMissing (boolean)      Optional. Default to false. Raise an exception if the file doesn’t exists. Default to false
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="deleteFile" access="public" output="false" hint="Delete a file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="throwIfMissing" type="boolean" required="false" default="false" hint="Raise an exception if the file doesn’t exists. Default to false">
		<cfif arguments.throwIfMissing>
			<!--- Throw an error if the file doesn't exist --->
			<cfset checkFilePath(arguments.filePath)>
		</cfif>
		<cfif FileExists(arguments.filePath)>
			<cftry>
				<!--- Lock file on delete. In order to have a unique name for the lock we use the file url --->
				<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.filePath#">
					<cffile action="delete" file="#arguments.filePath#">
				</cflock>
				<cfcatch type="any">
					<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
					<cfthrow message="tmt_file_io: Error deleting file: #arguments.filePath#. File may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	
	<!--- 
	/** 
	* Returns the size of the file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @return      boolean
	 */
	--->
	<cffunction name="getFileSize" access="public" output="false" returntype="numeric" hint="Returns the size of the file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfreturn getInfo(arguments.filePath).length>
	</cffunction>
	
	<!--- 
	/** 
	* Move a file
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Absolute file path of the file to copy
	* @param       destination (string)          Required. Pathname of a directory where the file will be moved. If not an absolute path, it is relative to the source directory
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="moveFile" access="public" output="false" hint="Move a file">
		<cfargument name="source" type="string" required="true" hint="Absolute file path of the file to copy">
		<cfargument name="destination" type="string" required="true" hint="Pathname of a directory where the file will be moved. If not an absolute path, it is relative to the source directory">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfset checkFilePath(arguments.source)>
		<cfset checkDirectoryPath(arguments.destination)>
		<cftry>
			<!--- Lock on move. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.source#">
				<cffile action="move" source="#arguments.source#" destination="#arguments.destination#" charset="#arguments.fileCharset#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error moving file: #arguments.source#. It may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- 
	/** 
	* Read a text file and return a string
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	* @return      string
	 */
	--->
	<cffunction name="readFile" access="public" output="false" returntype="string" hint="Read a text file and return a string">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfset var fileContent="">
		<!--- Throw an error if the file doesn't exist --->
		<cfset checkFilePath(arguments.filePath)>
		<cftry>
			<!--- Lock file on read. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.filePath#">
				<cffile action="read" file="#arguments.filePath#" variable="fileContent" charset="#arguments.fileCharset#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error reading file: #arguments.filePath#. File may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
		<cfreturn fileContent>
	</cffunction>
	
	<!--- 
	/** 
	* Rename a file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       newFile (string)              Required. New name
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="renameFile" access="public" output="false" hint="Rename a file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="newFile" type="string" required="true" hint="New name">
		<cfset checkFilePath(arguments.filePath)>
		<cftry>
			<!--- Lock on rename. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.filePath#">
				<cffile action="rename" destination="#arguments.newFile#" source="#arguments.filePath#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error renaming file: #arguments.filePath#. It may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- 
	/** 
	* Write to a text file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       fileContent (string)          Required. Content of the file to be created
	* @param       throwIfMissing (boolean)      Optional. Default to false. Raise an exception if the file doesn’t exists. Default to false
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="writeFile" access="public" output="false" hint="Write to a text file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="fileContent" type="string" required="true" hint="Content of the file to be created">
		<cfargument name="throwIfMissing" type="boolean" required="false" default="false" hint="Raise an exception if the file doesn’t exists. Default to false">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfif arguments.throwIfMissing>
			<!--- Throw an error if the file doesn't exist --->
			<cfset checkFilePath(arguments.filePath)>
		</cfif>
		<cftry>
			<!--- Lock file on write. In order to have a unique name for the lock we use the file url --->
			<cflock timeout="10" throwontimeout="yes" type="readonly" name="#arguments.filePath#">
				<cffile action="write" charset="#arguments.fileCharset#" file="#arguments.filePath#" output="#arguments.fileContent#">
			</cflock>
			<cfcatch type="any">
				<!--- Throw an error if something went wrong (read permissions, locks or the like) --->
				<cfthrow message="tmt_file_io: Error writing to file: #arguments.filePath#. File may be locked or read-only" detail="#cfcatch.detail#" type="tmt_file_io">
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- Lines reading methods  --->
	
	<!--- 
	/** 
	* Counts the lines of text contained inside a file
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @return      numeric
	 */
	--->
	<cffunction name="countFileLines" access="public" output="false" returntype="numeric" hint="Counts the lines of text contained inside a file">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfreturn ArrayLen(readFileLines(arguments.filePath, arguments.fileCharset))>
	</cffunction>
	
	<!--- 
	/** 
	* Read a file and return its content as an array of lines
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @param       fileCharset (string)          Optional. Default to #variables.charset#. Charset used. Default to a predefined value
	* @exception   tmt_file_io
	* @return      array
	 */
	--->
	<cffunction name="readFileLines" access="public" output="false" returntype="array" hint="Read a file and return its content as an array of lines">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfargument name="fileCharset" type="string" required="false" default="#variables.charset#" hint="Charset used. Default to a predefined value">
		<cfscript>
		/*
		Throw an error if the file doesn't exist.
		Since ColdFusion requires all the var declaration to be at the very top of the UDF, 
		we use a dummy var to perform this operation before we even get started with the job
		*/
		var fileExist = checkFilePath(arguments.filePath);
		var linesArray = ArrayNew(1);
		var jReader = createObject("java","java.io.FileReader").init(arguments.filePath);
		var jBuffer = createObject("java","java.io.BufferedReader").init(jReader);
		var line = jBuffer.readLine();
		</cfscript>
		<cftry>
		<!--- 
		Unlike Java, CFML has no notion of null, but this is quite a special case. 
		Whenever readLine() reach the end of the file, it return a Java null, 
		as soon as the BufferedReader return null, ColdFusion "erase" the line variable, making it undefined. 
		Here we leverage this somewhat weird behavior by using it as test condition for the loop
		 --->
			<cfloop condition="#IsDefined("line")#">
				<cfset ArrayAppend(linesArray, line)>
				<cfset line=jBuffer.readLine()>
			</cfloop>
			<cfset jBuffer.close()>
			<cfcatch type="any">
				<!--- Something went wrong; we better close the stream anyway, just to be safe and leave no garbage behind --->
				<cfset jBuffer.close()>
				<cfthrow message="tmt_file_io: Failed to read lines from: #arguments.filePath#" type="tmt_file_io">
			</cfcatch>
		</cftry>
		<cfreturn linesArray>
	</cffunction>
	
	<!--- Path related methods  --->
	
	<!--- 
	/** 
	* Throw an exception if directory path does not exist
	* @access      public
	* @output      suppressed 
	* @param       directoryPath (string)        Required. Absolute directory path
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="checkDirectoryPath" access="public" output="false" hint="Throw an exception if directory path does not exist">
		<cfargument name="directoryPath" type="string" required="true" hint="Absolute directory path">
		<cfif DirectoryExists(arguments.directoryPath)>
			<cfreturn true>
			<cfelse>
			<cfthrow message="tmt_file_io: Unable to find directory #arguments.directoryPath#" type="tmt_file_io">
		</cfif>
	</cffunction>
	
	<!--- 
	/** 
	* Throw an exception if file path does not exist
	* @access      public
	* @output      suppressed 
	* @param       filePath (string)             Required. Absolute file path
	* @exception   tmt_file_io
	 */
	--->
	<cffunction name="checkFilePath" access="public" output="false" hint="Throw an exception if file path does not exist">
		<cfargument name="filePath" type="string" required="true" hint="Absolute file path">
		<cfif FileExists(arguments.filePath)>
			<cfreturn true>
			<cfelse>
			<cfthrow message="tmt_file_io: Unable to find file #arguments.filePath#" type="tmt_file_io">
		</cfif>
	</cffunction>
	
	<!--- 
	/** 
	* Turn any system path, either local or absolute, into a fully qualified one
	* @access      public
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      string
	 */
	--->
	<cffunction name="getAbsolutePath" access="public" output="false" returntype="string" hint="Turn any system path, either local or absolute, into a fully qualified one">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfscript>
		var jFile = urlToJavaFile(arguments.path);
		if(jFile.isAbsolute()){
			return arguments.path;
		}
		else{
			return ExpandPath(arguments.path);
		}
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* 
	Return the relative path from startPath to destinationPath.
	Paths can be system paths (C:\myroot\mydir\myfile.cfm) or url (http://www.mydomain/myfile.cfm).
	Different kinds of paths (system and url) can't be mixed
	* @access      public
	* @output      suppressed 
	* @param       startPath (string)            Required. Full starting path
	* @param       destinationPath (string)      Required. Full destination path
	* @return      string
	* @author      Massimo Foti (massimo@massimocorner.com)
	* @version     2.1, 2005-04-05
	 */
	  --->
	<cffunction name="getRelativePath" access="public" output="false" returntype="string" hint="
	Return the relative path from startPath to destinationPath.
	Paths can be system paths (C:\myroot\mydir\myfile.cfm) or url (http://www.mydomain/myfile.cfm).
	Different kinds of paths (system and url) can't be mixed">
		<cfargument name="startingPath" type="string" required="true" hint="Full starting path">
		<cfargument name="destinationPath" type="string" required="true" hint="Full destination path">
		<cfscript>
		// In case we have absolute local paths, turn backward to forward slashes
		var startPath = Replace(arguments.startingPath, "\","/", "ALL"); 
		var endPath = Replace(arguments.destinationPath, "\","/", "ALL"); 
		// Declare variables
		var i = 1;
		var j = 1;
		var endStr = "";
		var endBase = "";
		var commonStr = "";
		var retVal = "";
		var whatsLeft = "";
		var slashPos = "";
		var slashCount = 0;
		var dotDotSlash = "";
		// Be sure the paths aren't equal
		if(startPath NEQ endPath){
			// If the files are both inside the same base directory
			if(GetDirectoryFromPath(startPath) EQ GetDirectoryFromPath(endPath)){
				// It's a special case, we are done already
				return GetFileFromPath(endPath);
			}
			// If the starting path is longer, the destination path is our starting point
			if(Len(startPath) GT Len(endPath)){
				endStr = Len(endPath);
				endBase = GetDirectoryFromPath(endPath);
			}
			// Else the start path is the starting point
			else{
				endStr = Len(startPath);
				endBase = GetDirectoryFromPath(startPath);
			}
			// Check if the two paths share a base path and store it into the commonStr variable
			for(i;i LT endBase; i=i+1){
				// Compare one character at time
				if(Mid(startPath, i, 1) EQ Mid(endPath, i, 1)){
					commonStr = commonStr & Mid(startPath, i, 1);
				}
				else{
					break;
				}
			}
			// We just need the common base directory
			commonStr = GetDirectoryFromPath(commonStr);	
			// If there is a common base path, remove it
			if(Len(commonStr) GT 0){
				whatsLeft = Mid(startPath, Len(commonStr)+1, Len(startPath));
			}
			else{
				whatsLeft = startPath;
			}
			slashPos = Find("/", whatsLeft);
			// Count how many directories we have to climb
			while(slashPos NEQ 0){
				slashCount = slashCount + 1;
				slashPos = Find("/", whatsLeft, slashPos+1);
			}
			// Append "../" for each directory we have to climb
			for(j;j LTE slashCount; j=j+1){
				dotDotSlash = dotDotSlash & "../";
			}
			// Assemble the final path
			retVal = dotDotSlash & Mid(endPath, Len(commonStr)+1, Len(endPath));
		}
		// Paths are the same
		else{
			retVal = "";
		}
		return retVal;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Return The system-dependent default name-separator character
	* @access      public
	* @output      suppressed 
	* @return      string
	 */
	--->
	<cffunction name="getPathSeparator" access="public" output="false" returntype="string" hint="Return The system-dependent default name-separator character">
		<cfreturn urlToJavaFile("").separator>
	</cffunction>
	
	<!--- Utility methods  --->
	
	<!--- 
	/** 
	* Turn a file path into a java.io.File object
	* @access      private
	* @output      suppressed 
	* @param       fileURL (string)              Required. File path
	 */
	--->
	<cffunction name="urlToJavaFile" access="private" output="false" hint="Turn a file path into a java.io.File object">
		<cfargument name="fileURL" type="string" required="true" hint="File path">
		<cfreturn createObject("java","java.io.File").init(arguments.fileURL)>
	</cffunction>
	
</cfcomponent>