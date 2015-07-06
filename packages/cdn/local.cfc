<cfcomponent displayname="Local" hint="Encapsulates file persistence functionality" output="false" persistent="false">
	
	<cffunction name="init" returntype="any">
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="validateConfig" output="false" access="public" returntype="struct" hint="Returns an array of errors. An empty array means there are no no errors">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var st = duplicate(arguments.config) />
		
		<cfif not structkeyexists(st,"fullpath")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'fullpath' ]) />
		<cfelse>
			<cfset st.fullpath = replace(st.fullpath,"\","/","ALL") />
			
			<cfif right(st.fullpath,1) eq "/">
				<cfset st.fullpath = left(st.fullpath,len(st.fullpath)-1) />
			</cfif>
		</cfif>
		
		<cfif structkeyexists(st,"urlpath") and right(st.urlpath,1) eq "/">
			<cfset st.urlpath = left(st.urlpath,len(st.urlpath)-1) />
		</cfif>
		<cfif structkeyexists(st,"urlpath") and refindnocase("^https?:",st.urlpath)>
			<cfset st.urlpath = rereplacenocase(st.urlpath,"^https?:","") />
		</cfif>
		
		<cfreturn st />
	</cffunction>
	
	
	<cffunction name="getFullPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var fullpath = "" />
		
		<cfif left(arguments.file,1) eq "/">
			<cfset fullpath = arguments.config.fullpath & arguments.file />
		<cfelse>
			<cfset fullpath = arguments.config.fullpath & "/" & arguments.file />
		</cfif>
		
		<cfreturn fullpath />
	</cffunction>
	
	<cffunction name="getURLPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var urlpath = "" />
		<cfset var filename = listLast(arguments.file, "/") />
		<cfset var fileLastname = "" />
		<cfset var fileFirstname = "" />
		<cfset var filePath = "" />
		<cfset var urlEncodedFilename = "" />
		
		<cfif not structkeyexists(arguments.config,"urlPath")>
			<cfset application.fapi.throw(message="no URL is available for CDN location [{1}]",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ arguments.config.name ]) />
		</cfif>

		<!--- Get filename --->
		<cfif listLen(filename, ".") GTE 2>
			<cfset fileLastname = listLast(filename, ".") />
			<cfset fileFirstname = left(filename, len(filename) - len(fileLastname) - 1) />
			<cfset urlEncodedFilename = urlEncodedFormat(fileFirstname) & "." & urlEncodedFormat(fileLastname) />
		<cfelse>
			<cfset fileFirstname = filename />
			<cfset urlEncodedFilename = urlEncodedFormat(fileFirstname) />
		</cfif>
		
		<!--- Get file path if exist --->
		<cfif find("/", arguments.file) GT 0>
			<cfset filePath = left(arguments.file, len(arguments.file) - len(filename)) />
		</cfif>
		
		<cfif left(arguments.file,1) eq "/">
			<cfset urlpath = arguments.config.urlpath & filePath & urlEncodedFilename />
		<cfelse>
			<cfset urlpath = arguments.config.urlpath & "/" & filePath & urlEncodedFilename />
		</cfif>
		
		<cfif structkeyexists(arguments,"protocol")>
			<cfif refindnocase("^//",urlpath)>
				<cfset urlpath = arguments.protocol & ":" & urlpath />
			<cfelseif refindnocase("^/",urlpath)>
				<cfset urlpath = arguments.protocol & "://" & cgi.http_host & urlpath />
			</cfif>
		</cfif>

		<cfreturn urlpath />
	</cffunction>
	
	
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfreturn fileexists(getFullPath(config=arguments.config,file=arguments.file)) />
	</cffunction>
	
	<cffunction name="ioGetFileSize" returntype="numeric" output="false" hint="Returns the size of the file in bytes">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var stInfo = getFileInfo(getFullPath(config=arguments.config,file=arguments.file)) />
		
		<cfreturn stInfo.size />
	</cffunction>
	
	<cffunction name="ioGetFileLocation" returntype="struct" output="false" hint="Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var stResult = structnew() />
		
		<cfif structkeyexists(arguments.config,"urlpath")>
			<cfset stResult["method"] = "redirect" />
			<cfset stResult["path"] = getURLPath(argumentCollection=arguments) />
		<cfelse>
			<cfset stResult["method"] = "stream" />
			<cfset stResult["path"] = getFullPath(argumentCollection=arguments) />
		</cfif>
		
		<cfset stResult["mimetype"] = getPageContext().getServletContext().getMimeType(getFullPath(config=arguments.config,file=arguments.file)) />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="ioWriteFile" returntype="void" access="public" output="false" hint="Writes the specified data to a file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		<cfargument name="quality" type="numeric" required="false" default="1" hint="This is only required for image writes" />
		
		<cfset var fullpath = getFullPath(config=arguments.config,file=arguments.file) />
		<cfset var fulldir = getDirectoryFromPath(arguments.file) />
		
		<cfif not ioDirectoryExists(config=arguments.config,dir=fulldir)>
			<cfset ioCreateDirectory(config=arguments.config,dir=fulldir) />
		</cfif>
		
		<cfswitch expression="#arguments.datatype#">
			<cfcase value="text">
				<cffile action="write" file="#fullpath#" output="#arguments.data#" mode="664" />
			</cfcase>
			
			<cfcase value="binary">
				<cffile action="write" file="#fullpath#" output="#arguments.data#" mode="664" />
			</cfcase>
			
			<cfcase value="image">
				<cfset imageWrite(arguments.data,fullpath,arguments.quality,true) />
				<cfset fileSetAccessMode(fullpath, "664") />
			</cfcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
		<cfset var fullpath = getFullPath(config=arguments.config,file=arguments.file) />
		<cfset var data = "" />
		
		<cfswitch expression="#arguments.datatype#">
			<cfcase value="text">
				<cffile action="read" file="#fullpath#" variable="data" />
			</cfcase>
			
			<cfcase value="binary">
				<cffile action="readBinary" file="#fullpath#" variable="data" />
			</cfcase>
			
			<cfcase value="image">
				<cfset data = imageread(fullpath) />
			</cfcase>
		</cfswitch>
		
		<cfreturn data />
	</cffunction>
	
	<cffunction name="ioMoveFile" returntype="void" access="public" output="false" hint="Moves the specified file between locations on a specific CDN, or between the CDN and the local filesystem">
		<cfargument name="source_config" type="struct" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		<cfargument name="dest_config" type="struct" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfset var sourcefile = "" />
		<cfset var destfile = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"source_file")>
			<cfparam name="arguments.dest_file" default="#arguments.source_file#" />
			<cfset sourcefile = getFullPath(config=arguments.source_config,file=arguments.source_file) />
		<cfelseif structkeyexists(arguments,"source_localpath")>
			<cfset sourcefile = arguments.source_localpath />
		</cfif>
		
		<cfif structkeyexists(arguments,"dest_config") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
			<cfset destfile = getFullPath(config=arguments.dest_config,file=arguments.dest_file) />
		<cfelseif structkeyexists(arguments,"dest_localpath")>
			<cfset destfile = arguments.dest_localpath />
		</cfif>
		
		<cfif not directoryExists(getDirectoryFromPath(destfile))>
			<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="777" />
			<cfset fileSetAccessMode(getDirectoryFromPath(destfile), "777") />
		</cfif>
		
		<cffile action="move" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
	</cffunction>
	
	<cffunction name="ioCopyFile" returntype="void" access="public" output="false" hint="Copies the specified file between locations on a specific CDN, or between the CDN and the local filesystem">
		<cfargument name="source_config" type="struct" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		<cfargument name="dest_config" type="struct" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfset var sourcefile = "" />
		<cfset var destfile = "">
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"source_file")>
			<cfparam name="arguments.dest_file" default="#arguments.source_file#" />
			<cfset sourcefile = getFullPath(config=arguments.source_config,file=arguments.source_file) />
		<cfelseif structkeyexists(arguments,"source_localpath")>
			<cfset sourcefile = arguments.source_localpath />
		</cfif>
		
		<cfif structkeyexists(arguments,"dest_config") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
			<cfset destfile = getFullPath(config=arguments.dest_config,file=arguments.dest_file) />
		<cfelseif structkeyexists(arguments,"dest_localpath")>
			<cfset destfile = arguments.dest_localpath />
		</cfif>
		
		<cfif not directoryExists(getDirectoryFromPath(destfile))>
			<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="777" />
			<cfset fileSetAccessMode(getDirectoryFromPath(destfile), "777") />
		</cfif>
		
		<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
	</cffunction>
	
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file. Does not check that the file exists first.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cffile action="delete" file="#getFullPath(config=arguments.config,file=arguments.file)#" />
	</cffunction>
	
	
	<cffunction name="ioDirectoryExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfreturn directoryexists(getFullPath(config=arguments.config,file=arguments.dir)) />
	</cffunction>
	
	<cffunction name="ioCreateDirectory" returntype="void" access="public" output="false" hint="Creates the specified directory. It assumes that it does not already exist, and will create all missing directories">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfdirectory action="create" directory="#getFullPath(config=arguments.config,file=arguments.dir)#" mode="777" />
		<cfset fileSetAccessMode(getFullPath(config=arguments.config,file=arguments.dir), "777") />
	</cffunction>
	
	<cffunction name="ioGetDirectoryListing" returntype="query" access="public" output="false" hint="Returns a query of the directory containing a 'file' column only. This filename will be equivilent to what is passed into other CDN functions.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var qDir = "" />
		
		<cfdirectory action="list" directory="#getFullPath(config=arguments.config,file=arguments.dir)#" recurse="true" type="file" listinfo="name" name="qDir" />
		
		<cfquery dbtype="query" name="qDir">
			SELECT 		'#arguments.dir#/' + name AS file 
			FROM 		qDir 
			WHERE		not name like '%/.%'
			ORDER BY 	name
		</cfquery>
		
		<cfreturn qDir />
	</cffunction>
	
</cfcomponent>