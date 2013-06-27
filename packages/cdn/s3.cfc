<cfcomponent displayname="S3" hint="Encapsulates file persistence functionality" output="false" persistent="false">
	
	<cffunction name="init" returntype="any">
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="validateConfig" output="false" access="public" returntype="struct" hint="Returns an array of errors. An empty array means there are no no errors">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var st = duplicate(arguments.config) />
		
		<cfif not structkeyexists(st,"accessKeyId")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'accessKeyId' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"awsSecretKey")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'awsSecretKey' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"bucket")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'bucket' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"region")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'region' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"domain")>
			<cfset st.domain = "s3-#st.region#.amazonaws.com" />
		</cfif>
		
		<cfif structkeyexists(st,"security") and not listfindnocase("public,private",arguments.config.security)>
			<cfset application.fapi.throw(message="the '{1}' value must be one of ({2})",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'security', 'public|private' ]) />
		<cfelseif not structkeyexists(st,"security")>
			<cfset st.security = "public" />
		</cfif>
		
		<cfif structkeyexists(st,"pathPrefix")>
			<cfif not left(st.pathPrefix,1) eq "/">
				<cfset st.pathPrefix = "/" & st.pathPrefix />
			</cfif>
			<cfif right(st.pathPrefix,1) eq "/">
				<cfset st.pathPrefix = left(st.pathPrefix,len(st.pathPrefix)-1) />
			</cfif>
		<cfelse>
			<cfset st.pathPrefix = "" />
		</cfif>
		
		<cfif st.security eq "private" and not structkeyexists(st,"urlExpiry")>
			<cfset application.fapi.throw(message="no 'urlExpiry' value defined for private location",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		<cfelseif structkeyexists(st,"urlExpiry") and (not isnumeric(st.urlExpiry) or st.urlExpiry lt 0)>
			<cfset application.fapi.throw(message="the 'urlExpiry' value must be a positive integer",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		</cfif>
		
		<cfif structkeyexists(st,"admins") and not isarray(arguments.config.admins)>
			<cfset application.fapi.throw(message="the 'admins' value must be an array of canonical user ids and email addresses",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		<cfelseif not structkeyexists(st,"admins")>
			<cfset st.admins = arraynew(1) />
		</cfif>
		
		<cfreturn st />
	</cffunction>
	
	
	<cffunction name="HMAC_SHA1" returntype="string" access="public" output="no">
		<cfargument name="signMessage" type="string" required="true" />
		<cfargument name="signKey" type="string" required="true" />
		
		<cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
		<cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
		<cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
		<cfset var mac = createObject("java","javax.crypto.Mac") />
		
		<cfset key = key.init(jKey,"HmacSHA1") />
		<cfset mac = mac.getInstance(key.getAlgorithm()) />
		<cfset mac.init(key) />
		<cfset mac.update(jMsg) />
		
		<cfreturn toBase64(mac.doFinal()) />
	</cffunction>

	
	<cffunction name="getS3Path" output="false" access="public" returntype="string" hint="Returns path to use for all S3 requests">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var fullpath = arguments.file />
		
		<cfif not left(fullpath,1) eq "/">
			<cfset fullpath = "/" & fullpath />
		</cfif>
		
		<cfset fullpath = arguments.config.pathPrefix & fullpath />
		
		<!--- URL encode the filename --->
		<cfset fullpath = rereplace(fullpath,"[^/]+\.\w+$",replacelist(urlencodedformat(listlast(fullpath,"/")),"%2D,%2E,%5F","-,.,_"))>
		
		<cfset fullpath = "s3://#arguments.config.accessKeyId#:#arguments.config.awsSecretKey#@#arguments.config.bucket##fullpath#" />
		
		<cfreturn fullpath />
	</cffunction>
	
	<cffunction name="getURLPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="method" type="string" required="false" default="GET" />
		
		<cfset var urlpath = arguments.file />
		<cfset var epochTime = 0 />
		<cfset var signature = "" />
		
		<cfif not left(urlpath,1) eq "/">
			<cfset urlpath = "/" & urlpath />
		</cfif>
		
		<!--- Prepend bucket and pathPrefix --->
		<cfset urlpath = "/#arguments.config.bucket##arguments.config.pathPrefix##urlpath#">
		
		<!--- URL encode the filename --->
		<cfset urlpath = rereplace(urlpath,"[^/]+\.\w+$",replacelist(urlencodedformat(listlast(urlpath,"/")),"%2D,%2E,%5F","-,.,_"))>
		
		<cfif structkeyexists(arguments.config,"security") and arguments.config.security eq "private">
			<cfset epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + arguments.config.urlExpiry />
			
			<!--- Create a canonical string to send --->
			<cfset signature = "#arguments.method#\n\n\n#epochTime#\n#urlpath#" />
			
			<!--- Replace "\n" with "chr(10) to get a correct digest --->
			<cfset signature = replace(signature,"\n","#chr(10)#","all") />
			
			<cfset urlpath = "//" & arguments.config.domain & urlpath & "?AWSAccessKeyId=#arguments.config.accessKeyId#&Expires=#epochTime#&Signature=#urlencodedformat(HMAC_SHA1(signature,arguments.config.awsSecretKey))#" />
		<cfelse>
			<cfset urlpath = "//" & arguments.config.domain & urlpath />
		</cfif>
		
		<cfreturn urlpath />
	</cffunction>
	
	<cffunction name="getMeta" output="false" access="public" returntype="struct" hint="Returns a metadata struct for setting S3 metadata">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult["content_type"] = getPageContext().getServletContext().getMimeType(arguments.file) />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="getACL" returntype="array" access="public" output="false">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var aACL = arraynew(1) />
		<cfset var stACL = "" />
		<cfset var i = 0 />
		
		<cfif arguments.config.security eq "public">
			<cfset stACL = structnew() />
			<cfset stACL["group"] = "all" />
			<cfset stACL["permission"] = "read" />
			<cfset arrayappend(aACL,stACL) />
		</cfif>
		
		<cfloop from="1" to="#arraylen(arguments.config.admins)#" index="i">
			<cfset stACL = structnew() />
			<cfif isvalid("email",arguments.config.admins[i])>
				<cfset stACL["email"] = arguments.config.admins[i] />
			<cfelse>
				<cfset stACL["id"] = arguments.config.admins[i] />
			</cfif>
			<cfset stACL["permission"] = "full_control" />
			<cfset arrayappend(aACL,stACL) />
		</cfloop>
		
		<cfreturn aACL />
	</cffunction>
	
	
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var cfhttp = structnew() />
		
		<cfhttp url="http:#getURLPath(config=arguments.config,file=arguments.file,method='HEAD')#" method="HEAD" />
		
		<cfif cfhttp.StatusCode eq "200 OK">
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="ioGetFileSize" returntype="numeric" output="false" hint="Returns the size of the file in bytes">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var stInfo = getFileInfo(getS3Path(config=arguments.config,file=arguments.file)) />
		
		<cfreturn stInfo.size />
	</cffunction>
	
	<cffunction name="ioGetFileLocation" returntype="struct" output="false" hint="Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult["method"] = "redirect" />
		<cfset stResult["path"] = getURLPath(config=arguments.config,file=arguments.file) />
		<cfset stResult["mimetype"] = getPageContext().getServletContext().getMimeType(arguments.file) />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="ioWriteFile" returntype="void" access="public" output="false" hint="Writes the specified data to a file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="data" type="any" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		<cfargument name="quality" type="numeric" required="false" default="1" hint="This is only required for image writes" />
		
		<cfset var fullpath = getS3Path(config=arguments.config,file=arguments.file) />
		<cfset var filedir = getDirectoryFromPath(arguments.file) />
		
		<cfif structkeyexists(application,"fapi")>
			<cfset application.fapi.addRequestLog("Writing S3 file [#arguments.file#]") />
		</cfif>
		
		<cfswitch expression="#arguments.datatype#">
			<cfcase value="text">
				<cffile action="write" file="#fullpath#" output="#arguments.data#" />
			</cfcase>
			
			<cfcase value="binary">
				<cffile action="write" file="#fullpath#" output="#arguments.data#" />
			</cfcase>
			
			<cfcase value="image">
				<cfset imageWrite(arguments.data,fullpath,arguments.quality,true) />
			</cfcase>
		</cfswitch>
		
		<cfset storeSetMetadata(fullpath, getMeta(config=arguments.config,file=arguments.file)) />
		<cfset storeSetACL(fullpath, getACL(config=arguments.config)) />
	</cffunction>
	
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
		<cfset var fullpath = getS3Path(config=arguments.config,file=arguments.file) />
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
		<cfset var acl = "" />
		<cfset var tmpfile = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config") and arguments.source_config.server neq arguments.dest_config.bucket>
		
			<!--- Inter-bucket move --->
			<cfset tmpfile = getTempDirectory() & createuuid() & ".tmp" />
			<cfset ioMoveFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments_dest_file) />
			
		<cfelse>
			
			<!--- Intra-bucket move --->
			<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"source_file")>
				<cfparam name="arguments.dest_file" default="#arguments.source_file#" />
				<cfset sourcefile = getS3Path(config=arguments.source_config,file=arguments.source_file) />
			<cfelseif structkeyexists(arguments,"source_localpath")>
				<cfset sourcefile = arguments.source_localpath />
			</cfif>
			
			<cfif structkeyexists(arguments,"dest_config") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
				<cfset destfile = getS3Path(config=arguments.dest_config,file=arguments.dest_file) />
				
				<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"source_file")>
					<cffile action="move" source="#sourcefile#" destination="#destfile#" nameconflict="overwrite" />
				<cfelse>
					<cffile action="copy" source="#sourcefile#" destination="#destfile#" nameconflict="overwrite" />
					<cffile action="delete" file="#sourcefile#" />
				</cfif>
				
				<cfset storeSetMetadata(destfile, getMeta(config=arguments.dest_config,file=arguments.dest_file)) />
				<cfset storeSetACL(destfile, getACL(arguments.dest_config)) />
			<cfelseif structkeyexists(arguments,"dest_localpath")>
				<cfset destfile = arguments.dest_localpath />
				
				<cfif not directoryExists(getDirectoryFromPath(destfile))>
					<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
				</cfif>
				
				<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
				<cffile action="delete" file="#sourcefile#" />
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
		
		<cfset var sourcefile = "" />
		<cfset var destfile = "">
		<cfset var acl = "" />
		<cfset var tmpfile = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config") and arguments.source_config.bucket neq arguments.dest_config.bucket>
		
			<!--- Inter-bucket copy --->
			<cfset tmpfile = getTempDirectory() & createuuid() & ".tmp" />
			<cfset ioCopyFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments_dest_file) />
			
		<cfelse>
			
			<!--- Intra-bucket copy --->
			<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"source_file")>
				<cfparam name="arguments.dest_file" default="#arguments.source_file#" />
				<cfset sourcefile = getS3Path(config=arguments.source_config,file=arguments.source_file) />
			<cfelseif structkeyexists(arguments,"source_localpath")>
				<cfset sourcefile = arguments.source_localpath />
			</cfif>
			
			<cfif structkeyexists(arguments,"dest_config") and (structkeyexists(arguments,"dest_file") or structkeyexists(arguments,"source_file"))>
				<cfset destfile = getS3Path(config=arguments.dest_config,file=arguments.dest_file) />
				
				<cffile action="copy" source="#sourcefile#" destination="#destfile#" nameconflict="overwrite" />
				
				<cfset storeSetMetadata(destfile, getMeta(config=arguments.dest_config,file=arguments.dest_file)) />
				<cfset storeSetACL(destfile, getACL(arguments.dest_config)) />
			<cfelseif structkeyexists(arguments,"dest_localpath")>
				<cfset destfile = arguments.dest_localpath />
				
				<cfif not directoryExists(getDirectoryFromPath(destfile))>
					<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
				</cfif>
				
				<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
			</cfif>
		
		</cfif>
	</cffunction>
	
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file. Does not check that the file exists first.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cffile action="delete" file="#getS3Path(config=arguments.config,file=arguments.file)#" />
	</cffunction>
	
	
	<cffunction name="ioDirectoryExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<!--- in S3 all directories are implied by the keys of files (this plugin assumes the bucket already exists) --->
		<cfreturn true />
	</cffunction>
	
	<cffunction name="ioCreateDirectory" returntype="void" access="public" output="false" hint="Creates the specified directory. It assumes that it does not already exist, and will create all missing directories">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<!--- in S3 all directories are implied by the keys of files (this plugin assumes the bucket already exists) --->
	</cffunction>
	
	<cffunction name="ioGetDirectoryListing" returntype="query" access="public" output="false" hint="Returns a query of the directory containing a 'file' column only. This filename will be equivilent to what is passed into other CDN functions.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var qDir = "" />
		<cfset var s3path = "s3://#arguments.config.accessKeyId#:#arguments.config.awsSecretKey#@#arguments.config.bucket#/" />
		
		<cfdirectory action="list" directory="#s3path#" listinfo="name" name="qDir" />
		
		<cfquery dbtype="query" name="qDir">
			SELECT 		'/' + name AS file
			FROM 		qDir 
			WHERE		lower('/' + name) like '#lcase(arguments.config.pathPrefix)##lcase(arguments.dir)#%'
			ORDER BY 	name
		</cfquery>
		
		<cfif len(arguments.config.pathPrefix)>
			<cfloop query="qDir">
				<cfset querysetcell(qDir,"file",rereplacenocase(qDir.file,"^#arguments.config.pathPrefix#",""),qDir.currentrow) />
			</cfloop>
		</cfif>
		
		<cfreturn qDir />
	</cffunction>
	
</cfcomponent>