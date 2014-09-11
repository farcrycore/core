<cfcomponent displayname="FTP" hint="Provides all necessary functionality to run a CDN accessed via FTP" output="false">
	
	<cffunction name="init" returntype="any">
		
		<cfset var qLeftovers = "" />
		
		<cfset this.cacheMap = structnew() />
		
		<cfif directoryExists(getTempDirectory() & application.applicationname)>
			<cfdirectory action="list" directory="#getTempDirectory()##application.applicationname#/ftpcache" recurse="true" type="file" name="qLeftovers" />
			
			<cfloop query="qLeftovers">
				<cffile action="delete" file="#qLeftovers.Directory#/#qLeftovers.name#" />
			</cfloop>
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="validateConfig" output="false" access="public" returntype="struct" hint="Returns an array of errors. An empty array means there are no no errors">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var st = duplicate(arguments.config) />
		
		<cfif not structkeyexists(st,"server")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'server' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"username")>
			<cfset st["username"] = "" />
		</cfif>
		
		<cfif not structkeyexists(st,"password")>
			<cfset st["password"] = "" />
		</cfif>
		
		<cfif not structkeyexists(st,"port")>
			<cfset st["port"] = "21" />
		</cfif>
		
		<cfif not structkeyexists(st,"proxyServer")>
			<cfset st["proxyServer"] = "" />
		</cfif>
		
		<cfif not structkeyexists(st,"retryCount")>
			<cfset st["retryCount"] = 1 />
		</cfif>
		
		<cfif not structkeyexists(st,"timeout")>
			<cfset st["timeout"] = 30 />
		</cfif>
		
		<cfif not structkeyexists(st,"fingerprint")>
			<cfset st["fingerprint"] = "" />
		</cfif>
		
		<cfif not structkeyexists(st,"key")>
			<cfset st["key"] = "" />
		</cfif>
		
		<cfif not structkeyexists(st,"secure")>
			<cfset st["secure"] = false />
		</cfif>
		
		<cfif not structkeyexists(st,"passive")>
			<cfset st["passive"] = false />
		</cfif>
		
		<cfif not structkeyexists(st,"localCacheSize")>
			<cfset st["localCacheSize"] = 20 />
		</cfif>
		
		<cfif structkeyexists(st,"ftpPathPrefix")>
			<cfif not left(st.ftpPathPrefix,1) eq "/">
				<cfset st.ftpPathPrefix = "/" & st.ftpPathPrefix />
			</cfif>
			<cfif right(st.ftpPathPrefix,1) eq "/">
				<cfset st.ftpPathPrefix = left(st.ftpPathPrefix,len(st.ftpPathPrefix)-1) />
			</cfif>
		<cfelse>
			<cfset st.ftpPathPrefix = "" />
		</cfif>
		
		<cfif structkeyexists(st,"urlPathPrefix")>
			<cfif right(st.urlPathPrefix,1) eq "/">
				<cfset st.urlPathPrefix = left(st.urlPathPrefix,len(st.urlPathPrefix)-1) />
			</cfif>
			<cfif refindnocase("^https?:",st.urlPathPrefix)>
				<cfset st.urlPathPrefix = rereplacenocase(st.urlPathPrefix,"^https?:","") />
			</cfif>
		<cfelse>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'urlPathPrefix' ]) />
		</cfif>
		
		<cfreturn st />
	</cffunction>
	
	<cffunction name="openConnection" output="false" access="public" returntype="string" hint="Opens a connection with the specified config and returns the connection name">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var key = "" />
		<cfset var stAttributes = "" />
		
		<cfif not isdefined("request.ftpconnections.#arguments.config.name#")>
			<cfset request.ftpconnections[arguments.config.name] = "#dateformat(now(),'yyyymmdd')##timeformat(now(),'hhmmss')#_#replace(createuuid(),'-','','ALL')#" />
			
			<cfset stAttributes = structnew() />
			<cfset stAttributes.action = "open" />
			<cfset stAttributes.stopOnError = true />
			<cfset stAttributes.connection = request.ftpconnections[arguments.config.name] />
			<cfset stAttributes.username = arguments.config.username />
			<cfset stAttributes.server = arguments.config.server />
			<cfset stAttributes.port = arguments.config.port />
			<cfset stAttributes.retryCount = arguments.config.retryCount />
			<cfset stAttributes.timeout = arguments.config.timeout />
			<cfset stAttributes.secure = arguments.config.secure />
			<cfset stAttributes.passive = arguments.config.passive />
			
			<cfloop list="password,proxyServer,fingerprint,key" index="key">
				<cfif len(arguments.config[key])>
					<cfset stAttributes[key] = arguments.config[key] />
				</cfif>
			</cfloop>
			
			<cfftp attributeCollection="#stAttributes#" />
		</cfif>
		
		<cfreturn request.ftpconnections[arguments.config.name] />
	</cffunction>
	
	<cffunction name="closeConnection" output="false" access="public" returntype="void" hint="Closes the specified connection">
		<cfargument name="config" type="struct" required="true" />
		
		<!--- Connection will be closed automatically at end of request --->
	</cffunction>
	
	<cffunction name="isSameServer" output="false" access="public" returntype="boolean" hint="Returns true if the two configs refer to the same server">
		<cfargument name="configA" type="struct" required="true" />
		<cfargument name="configB" type="struct" required="true" />
		
		<cfreturn arguments.configA.server eq arguments.configB.server
				AND arguments.configA.username eq arguments.configB.username
				AND arguments.configA.password eq arguments.configB.password
				AND arguments.configA.port eq arguments.configB.port
				AND arguments.configA.proxyServer eq arguments.configB.proxyServer
				AND arguments.configA.fingerprint eq arguments.configB.fingerprint
				AND arguments.configA.key eq arguments.configB.key
				AND arguments.configA.secure eq arguments.configB.secure />
	</cffunction>
	
	<cffunction name="recursiveListDir" returntype="query" access="public" output="false" hint="A recursive wrapper for cfftp listDir">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		<cfargument name="qResult" type="query" required="false" />
		
		<cfset var connectionname = openConnection(config=arguments.config) />
		<cfset var qThisDir = "" />
		
		<cfif not structkeyexists(arguments,"qResult")>
			<cfset arguments.qResult = querynew("file") />
		</cfif>
		
		<cfftp	connection="#connectionname#" 
				action="listDir" 
				stopOnError="Yes" 
				name="qThisDir" 
				directory="#getFTPPath(config=arguments.config,file=arguments.dir)#" />
		
		<cfloop query="qThisDir">
			<cfif qThisDir.isDirectory>
				<cfset recursiveListDir(config=arguments.config,dir=arguments.dir & "/" & qThisDir.name,qResult=arguments.qResult) />
			<cfelse>
				<cfset queryaddrow(arguments.qResult) />
				<cfset querysetcell(arguments.qResult,"file",arguments.dir & "/" & qThisDir.name) />
			</cfif>
		</cfloop>
		
		<cfset closeConnection(config=arguments.config) />
		
		<cfreturn arguments.qResult />
	</cffunction>
	
	<cffunction name="getCachedFile" returntype="string" access="public" output="false" hint="Returns the local cache path of a file if available">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfif not arguments.config.localCacheSize 
			or not structkeyexists(this.cacheMap,arguments.config.name)
			or not structkeyexists(this.cacheMap[arguments.config.name],arguments.file)>
			
			<cfreturn "" />
		</cfif>
		
		<cfif fileExists(this.cacheMap[arguments.config.name][arguments.file].path)>
			<cfset this.cacheMap[arguments.config.name][arguments.file].touch = now() />
			<cfreturn this.cacheMap[arguments.config.name][arguments.file].path />
		<cfelse>
			<cfset structdelete(this.cacheMap[arguments.config.name],arguments.file)>
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="addCachedFile" returntype="void" access="public" output="false" hint="Adds a temporary file to the local cache">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		
		<cfset var oldest = "" />
		<cfset var oldesttouch = now() />
		<cfset var thisfile = "" />
		
		<cfif not structkeyexists(this.cacheMap,arguments.config.name)>
			<cfset this.cacheMap[arguments.config.name] = structnew() />
		</cfif>
		
		<cfif structkeyexists(this.cacheMap[arguments.config.name],arguments.file) 
			and this.cacheMap[arguments.config.name][arguments.file].path neq arguments.path
			and fileexists(this.cacheMap[arguments.config.name][arguments.file].path)>
			
			<cfset removeCachedFile(config=arguments.config,file=arguments.file) />
		</cfif>
		
		<cfset this.cacheMap[arguments.config.name][arguments.file] = structnew() />
		<cfset this.cacheMap[arguments.config.name][arguments.file].touch = now() />
		<cfset this.cacheMap[arguments.config.name][arguments.file].path = arguments.path />
		
		<!--- Remove old files --->
		<cfif structcount(this.cacheMap[arguments.config.name]) gte arguments.config.localCacheSize>
			<cfloop collection="#this.cacheMap[arguments.config.name]#" item="thisfile">
				<cfif this.cacheMap[arguments.config.name][thisfile].touch lt oldesttouch>
					<cfset oldest = thisfile />
				</cfif>
			</cfloop>
			
			<cfset removeCachedFile(config=arguments.config,file=oldest) />
		</cfif>
	</cffunction>
	
	<cffunction name="removeCachedFile" returntype="void" access="public" output="false" hint="Removes a file from the local cache">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfif structkeyexists(this.cacheMap,arguments.config.name)
			and structkeyexists(this.cacheMap[arguments.config.name],arguments.file)>
			
			<cfif fileexists(this.cacheMap[arguments.config.name][arguments.file].path)>
				<cffile action="delete" file="#this.cacheMap[arguments.config.name][arguments.file].path#" />
			</cfif>
			
			<cfset structdelete(this.cacheMap[arguments.config.name],arguments.file) />
		</cfif>
	</cffunction>
	
	<cffunction name="getTemporaryFile" returntype="string" access="public" output="false" hint="Returns a path for a new temporary file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var tmpfile = "#getTempDirectory()##application.applicationname#/ftpcache/#arguments.config.name#/#createuuid()#.#listlast(arguments.file,'.')#" />
		
		<cfif not directoryExists(getDirectoryFromPath(tmpfile))>
			<cfdirectory action="create" directory="#getDirectoryFromPath(tmpfile)#" mode="774" />
		</cfif>
		
		<cfreturn tmpfile />
	</cffunction>
	
	
	<cffunction name="getFTPPath" output="false" access="public" returntype="string" hint="Returns path to use for all S3 requests">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var fullpath = arguments.file />
		
		<cfif not left(fullpath,1) eq "/">
			<cfset fullpath = "/" & fullpath />
		</cfif>
		
		<cfset fullpath = arguments.config.ftpPathPrefix & fullpath />
		
		<cfreturn fullpath />
	</cffunction>
	
	<cffunction name="getURLPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var urlpath = arguments.file />
		
		<cfif not left(urlpath,1) eq "/">
			<cfset urlpath = "/" & urlpath />
		</cfif>
		
		<cfset urlpath = arguments.config.urlPathPrefix & urlpath />
		
		<cfif structkeyexists(arguments,"protocol") and refind("^//",urlpath)>
			<cfset urlpath = arguments.protocol & ":" & urlpath />
		</cfif>

		<cfreturn urlpath />
	</cffunction>
	
	
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var cfhttp = structnew() />
		
		<cfhttp url="http:#getURLPath(config=arguments.config,file=arguments.file)#" method="HEAD" />
		
		<cfif cfhttp.StatusCode eq "200 OK">
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="ioGetFileSize" returntype="numeric" output="false" hint="Returns the size of the file in bytes">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var connectionname = "" />
		<cfset var qDir = structnew() />
		<cfset var stInfo = "" />
		<cfset var cachePath = getCachedFile(config=arguments.config,file=arguments.file) />
		
		<cfif len(cachePath)>
			
			<cfset stInfo = getFileInfo(cachePath) />
			
			<cfreturn stInfo.size />
		
		<cfelse>
		
			<cfset connectionname = openConnection(config=arguments.config) />
			
			<cfftp	connection="#connectionname#" 
					action="listDir" 
					stopOnError="Yes" 
					name="qDir" 
					directory="#getDirectoryFromPath(getFTPPath(config=arguments.config,file=arguments.file))#" />
			
			<cfset closeConnection(config=arguments.config) />
			
			<cfquery dbtype="query" name="qDir">
				SELECT		length
				FROM		qDir
				WHERE		lower(name)=<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(getFilefrompath(arguments.file))#" />
			</cfquery>
			
			<cfreturn qDir.length />
		</cfif>
	</cffunction>
	
	<cffunction name="ioGetFileLocation" returntype="struct" output="false" hint="Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult["method"] = "redirect" />
		<cfset stResult["path"] = getURLPath(argumentCollection=arguments) />
		<cfset stResult["mimetype"] = getPageContext().getServletContext().getMimeType(arguments.file) />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="ioWriteFile" returntype="void" access="public" output="false" hint="Writes the specified data to a file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		<cfargument name="quality" type="numeric" required="false" default="1" hint="This is only required for image writes" />
		
		<cfset var connectionname = "" />
		<cfset var cfftp = structnew() />
		<cfset var tmpfile = getCachedFile(config=arguments.config,file=arguments.file) />
		
		<cfif not len(tmpfile)>
			<cfset tmpfile = getTemporaryFile(config=arguments.config,file=arguments.file) />
		</cfif>
		
		<!--- Write data to a temporary file --->
		<cfswitch expression="#arguments.datatype#">
			<cfcase value="text">
				<cffile action="write" file="#tmpfile#" output="#arguments.data#" mode="664" />
			</cfcase>
			
			<cfcase value="binary">
				<cffile action="write" file="#tmpfile#" output="#arguments.data#" mode="664" />
			</cfcase>
			
			<cfcase value="image">
				<cfset imageWrite(arguments.data,tmpfile,arguments.quality,true) />
			</cfcase>
		</cfswitch>
		
		<!--- Put file onto FTP server --->
		<cfset connectionname = openConnection(config=arguments.config) />
		
		<cfif not ioDirectoryExists(config=arguments.config,dir=getDirectoryFromPath(arguments.file))>
			<cfset ioCreateDirectory(config=arguments.config,dir=getDirectoryFromPath(arguments.file)) />
		</cfif>
		
		<cfswitch expression="#arguments.datatype#">
			<cfcase value="text">
				<cfftp	connection="#connectionname#" 
						action="putFile" 
						transferMode="ascii" 
						localFile="#tmpfile#" 
						remoteFile="#getFTPPath(config=arguments.config,file=arguments.file)#" />
				
			</cfcase>
			
			<cfcase value="binary,image" delimiters=",">
				
				<cfftp	connection="#connectionname#" 
						action="putFile" 
						transferMode="binary" 
						localFile="#tmpfile#"  
						remoteFile="#getFTPPath(config=arguments.config,file=arguments.file)#" />
				
			</cfcase>
		</cfswitch>
		
		<cfset closeConnection(config=arguments.config) />
		
		<cfif arguments.config.localCacheSize>
			<cfset addCachedFile(config=arguments.config,file=arguments.file,path=tmpfile) />
		<cfelse>
			<!--- Delete temporary file --->
			<cffile action="delete" file="#tmpfile#" />
		</cfif>
		
	</cffunction>
	
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
		<cfset var connectionname = "" />
		<cfset var cfftp = structnew() />
		<cfset var data = "" />
		<cfset var tmpfile = getCachedFile(config=arguments.config,file=arguments.file) />
		
		<cfif len(tmpfile)>
			
			<!--- Read cache file --->
			<cfswitch expression="#arguments.datatype#">
				<cfcase value="text">
					<cffile action="read" file="#tmpfile#" variable="data" />
				</cfcase>
				
				<cfcase value="binary">
					<cffile action="readBinary" file="#tmpfile#" variable="data" />
				</cfcase>
				
				<cfcase value="image">
					<cfset data = imageread(tmpfile) />
				</cfcase>
			</cfswitch>
			
		<cfelse>
			
			<cfset tmpfile = getTemporaryFile(config=arguments.config,file=arguments.file) />
			
			<!--- Get file from FTP server --->
			<cfset connectionname = openConnection(config=arguments.config) />
			
			<cfswitch expression="#arguments.datatype#">
				<cfcase value="text">
					
					<cfftp	connection="#connectionname#" 
							action="getFile" 
							transferMode="ascii" 
							localFile="#tmpfile#"  
							remoteFile="#getFTPPath(config=arguments.config,file=arguments.file)#" />
					
				</cfcase>
				
				<cfcase value="binary,image" delimiters=",">
					
					<cfftp	connection="#connectionname#" 
							action="getFile" 
							transferMode="binary" 
							localFile="#tmpfile#"  
							remoteFile="#getFTPPath(config=arguments.config,file=arguments.file)#" />
					
				</cfcase>
			</cfswitch>
			
			<cfset closeConnection(config=arguments.config) />
			
			<!--- Read temporary file --->
			<cfswitch expression="#arguments.datatype#">
				<cfcase value="text">
					<cffile action="read" file="#tmpfile#" variable="data" />
				</cfcase>
				
				<cfcase value="binary">
					<cffile action="readBinary" file="#tmpfile#" variable="data" />
				</cfcase>
				
				<cfcase value="image">
					<cfset data = imageread(tmpfile) />
				</cfcase>
			</cfswitch>
			
			<cfif arguments.config.localCacheSize>
				<cfset addCachedFile(config=arguments.config,file=arguments.file,path=tmpfile) />
			<cfelse>
				<!--- Delete temporary file --->
				<cffile action="delete" file="#tmpfile#" />
			</cfif>
			
		</cfif>
		
		<cfreturn data />
	</cffunction>
	
	<cffunction name="ioMoveFile" returntype="void" access="public" output="false" hint="Moves the specified file between locations on a specific CDN, or between the CDN and the local filesystem">
		<cfargument name="source_config" type="struct" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		<cfargument name="dest_config" type="struct" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfset var connectionname = "" />
		<cfset var cfftp = structnew() />
		<cfset var tmpfile = "" />
		<cfset var cachePath = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config") and not isSameServer(arguments.source_config,arguments.dest_config)>
		
			<!--- Inter-FTP move --->
			<cfset tmpfile = getTempDirectory() & createuuid() & "." & listlast(arguments.source_file,".") />
			<cfset ioMoveFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments.dest_file) />
			
		<cfelseif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config") and isSameServer(arguments.source_config,arguments.dest_config)>
			
			<!--- Intra-FTP move --->
			<cfset connectionname = openConnection(config=arguments.source_config) />
			
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cfftp	connection="#connectionname#" 
					action="rename" 
					existing="#getFTPPath(config=arguments.source_config,file=arguments.source_file)#"  
					new="#getFTPPath(config=arguments.dest_config,file=arguments.dest_file)#" />
			
			<cfset closeConnection(config=arguments.dest_config) />
			
			<cfif arguments.config.localCacheSize>
				<cfset removeCachedFile(config=arguments.source_config,file=arguments.source_file) />
			</cfif>
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfif not directoryExists(getDirectoryFromPath(arguments.dest_localpath))>
				<cfdirectory action="create" directory="#getDirectoryFromPath(arguments.dest_localpath)#" mode="774" />
			</cfif>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="move" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<!--- Delete from FTP --->
				<cfset connectionname = openConnection(config=arguments.source_config) />
				
				<cfftp	connection="#connectionname#" 
						action="remove" 
						item="#getFTPPath(config=arguments.source_config,file=arguments.source_file)#" />
				
				<cfset closeConnection(config=arguments.source_config) />
				
				<cfset removeCachedFile(config=arguments.source_config,file=arguments.source_file) />
				
			<cfelse>
			
				<!--- Get local from FTP --->
				<cfset connectionname = openConnection(config=arguments.source_config) />
				
				<cfftp	connection="#connectionname#" 
						action="getFile" 
						transferMode="auto" 
						localFile="#arguments.dest_localpath#"  
						remoteFile="#getFTPPath(config=arguments.source_config,file=arguments.source_file)#" />
				
				<cfftp	connection="#connectionname#" 
						action="remove" 
						item="#getFTPPath(config=arguments.source_config,file=arguments.source_file)#" />
				
				<cfset closeConnection(config=arguments.source_config) />
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
			
			<!--- Put local file on FTP --->
			<cfset connectionname = openConnection(config=arguments.dest_config) />
			
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cfftp	connection="#connectionname#" 
					action="putFile" 
					transferMode="auto" 
					localFile="#arguments.source_localpath#"  
					remoteFile="#getFTPPath(config=arguments.dest_config,file=arguments.dest_file)#" />
			
			<cfset closeConnection(config=arguments.dest_config) />
			
			<cfif arguments.dest_config.localCacheSize>
				<cfset tmpfile = getTemporaryFile(config=arguments.dest_config,file=arguments.dest_file) />
				
				<cffile action="move" source="#arguments.source_localpath#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
				
				<cfset addCachedFile(config=arguments.dest_config,file=arguments.dest_file,path=tmpfile) />
			<cfelse>
				<cffile action="delete" file="#arguments.source_localpath#" />
			</cfif>
			
		</cfif>
		
	</cffunction>
	
	<cffunction name="ioCopyFile" returntype="void" access="public" output="false" hint="Copies the specified file between locations on a specific CDN, or between the CDN and the local filesystem">
		<cfargument name="source_config" type="struct" required="false" />
		<cfargument name="source_file" type="string" required="false" />
		<cfargument name="source_localpath" type="string" required="false" />
		<cfargument name="dest_config" type="struct" required="false" />
		<cfargument name="dest_file" type="string" required="false" />
		<cfargument name="dest_localpath" type="string" required="false" />
		
		<cfset var connectionname = "" />
		<cfset var cfftp = structnew() />
		<cfset var tmpfile = "" />
		<cfset var cachePath = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config")>
		
			<!--- FTP copy --->
			<cfset tmpfile = getTempDirectory() & createuuid() & "." & listlast(arguments.source_file,".") />
			<cfset ioCopyFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments.dest_file) />
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfif not directoryExists(getDirectoryFromPath(arguments.dest_localpath))>
				<cfdirectory action="create" directory="#getDirectoryFromPath(arguments.dest_localpath)#" mode="774" />
			</cfif>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="copy" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
			<cfelse>
			
				<!--- Get local from FTP --->
				<cfset tmpfile = getTemporaryFile(config=arguments.source_config,file=arguments.source_file) />
				
				<cfset connectionname = openConnection(config=arguments.source_config) />
				
				<cfftp	connection="#connectionname#" 
						action="getFile" 
						transferMode="auto" 
						localFile="#tmpfile#"  
						remoteFile="#getFTPPath(config=arguments.source_config,file=arguments.source_file)#" />
				
				<cfset closeConnection(config=arguments.source_config) />
				
				<cffile action="copy" source="#tmpfile#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<cfif arguments.source_config.localCacheSize>
					<cfset addCachedFile(config=arguments.source_config,file=arguments.source_file,path=tmpfile) />
				<cfelse>
					<cffile action="delete" file="#tmpfile#" />
				</cfif>
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
		
			<!--- Put local file on FTP --->
			<cfset connectionname = openConnection(config=arguments.dest_config) />
			
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cfftp	connection="#connectionname#" 
					action="putFile" 
					transferMode="auto" 
					localFile="#arguments.source_localpath#"  
					remoteFile="#getFTPPath(config=arguments.dest_config,file=arguments.dest_file)#" />
			
			<cfset closeConnection(config=arguments.dest_config) />
			
			<cfif arguments.dest_config.localCacheSize>
				<cfset tmpfile = getTemporaryFile(config=arguments.config,file=arguments.file) />
				
				<cffile action="copy" source="#arguments.source_localpath#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
				
				<cfset addCachedFile(config=arguments.dest_config,file=arguments.dest_file,path=tmpfile) />
			</cfif>
			
		</cfif>
		
	</cffunction>
	
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file. Does not check that the file exists first.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var connectionname = openConnection(config=arguments.config) />
		<cfset var cfftp = structnew() />
		
		<cfftp	connection="#connectionname#" 
				action="remove" 
				item="#getFTPPath(config=arguments.config,file=arguments.file)#" />
		
		<cfset closeConnection(config=arguments.config) />
		
		<cfif arguments.config.localCacheSize>
			<cfset removeCachedFile(config=arguments.config,file=arguments.file) />
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="ioDirectoryExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var connectionname = openConnection(config=arguments.config) />
		<cfset var cfftp = structnew() />
		
		<cfif len(arguments.dir) and right(arguments.dir,1) eq "/">
			<cfset arguments.dir = mid(arguments.dir,1,len(arguments.dir)-1) />
		</cfif>
		
		<cfftp 	connection="#connectionname#" 
				action="existsDir" 
				stopOnError="Yes" 
				directory="#getFTPPath(config=arguments.config,file=arguments.dir)#" />
		
		<cfset closeConnection(config=arguments.config) />
		
		<cfreturn cfftp.returnValue />
	</cffunction>
	
	<cffunction name="ioCreateDirectory" returntype="void" access="public" output="false" hint="Creates the specified directory. It assumes that it does not already exist, and will create all missing directories">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var connectionname = openConnection(config=arguments.config) />
		<cfset var cfftp = structnew() />
		<cfset var thispart = "" />
		<cfset var dirsofar = "" />
		
		<cfif len(arguments.dir) and right(arguments.dir,1) eq "/">
			<cfset arguments.dir = mid(arguments.dir,1,len(arguments.dir)-1) />
		</cfif>
		
		<cfset arguments.dir = getFTPPath(config=arguments.config,file=arguments.dir) />
		
		<cfloop list="#arguments.dir#" index="thispart" delimiters="/">
			<cfset dirsofar = dirsofar & "/" & thispart />
			
			<cfftp 	connection="#connectionname#" 
					action="existsDir" 
					stopOnError="Yes" 
					directory="#dirsofar#" />
			
			<cfif not cfftp.returnValue>
				<cfftp 	connection="#connectionname#" 
						action="createDir" 
						stopOnError="Yes" 
						directory="#dirsofar#" />
			</cfif>
		</cfloop>
		
		<cfset closeConnection(config=arguments.config) />
	</cffunction>
	
	<cffunction name="ioGetDirectoryListing" returntype="query" access="public" output="false" hint="Returns a query of the directory containing a 'file' column only. This filename will be equivilent to what is passed into other CDN functions.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var qDir = "" />
		
		<cfif len(arguments.dir) and right(arguments.dir,1) eq "/">
			<cfset arguments.dir = mid(arguments.dir,1,len(arguments.dir)-1) />
		</cfif>
		
		<cfset qDir = recursiveListDir(config=arguments.config,dir=arguments.dir) />
		
		<cfreturn qDir />
	</cffunction>
	
</cfcomponent>