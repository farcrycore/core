<cfcomponent displayname="S3" hint="Encapsulates file persistence functionality" output="false" persistent="false">
	
	<cffunction name="init" returntype="any">
		<cfargument name="cdn" type="any" required="true" />
		<cfargument name="engine" type="string" required="true" />

		<cfset var qLeftovers = queryNew("")>

		<cfset this.cdn = arguments.cdn />
		<cfset this.engine = arguments.engine />
		
		<cfset this.cacheMap = structnew() />
		
		<cfif directoryExists(getTempDirectory() & application.applicationname)>
			<cfdirectory action="list" directory="#getTempDirectory()##application.applicationname#/s3cache" recurse="true" type="file" name="qLeftovers" />
			
			<cfloop query="qLeftovers">
				<cffile action="delete" file="#qLeftovers.Directory#/#qLeftovers.name#" />
				<cflog file="s3" text="Init: removed cached file #qLeftovers.Directory#/#qLeftovers.name#">
			</cfloop>
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="validateConfig" output="false" access="public" returntype="struct" hint="Returns an array of errors. An empty array means there are no no errors">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var st = duplicate(arguments.config) />
		<cfset var stACL = structnew() />
		<cfset var i = 0 />
		
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
			<cfif not structkeyexists(arguments.config,"region") or not len(arguments.config.region) or arguments.config.region eq "us-east-1">
				<cfset st.domain = "s3.amazonaws.com" />
			<cfelse>
				<cfset st.domain = "s3-#st.region#.amazonaws.com" />
			</cfif>
			<cfset st.domainType = "s3" />
		<cfelse>
			<cfset st.domainType = "custom" />
		</cfif>
		
		<cfif structkeyexists(st,"acl") and not isarray(arguments.config.acl)>
			<cfset application.fapi.throw(message="the 'acl' value must be an array of ACL structs - group | email | id + permission and ",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		<cfelseif not structkeyexists(st,"acl")>
			<cfset st.acl = arraynew(1) />
		</cfif>
		
		<cfif structkeyexists(st,"security") and not listfindnocase("public,private",arguments.config.security)>
			<cfset application.fapi.throw(message="the '{1}' value must be one of ({2})",type="cdnconfigerror",detail=serializeJSON(arguments.config),substituteValues=[ 'security', 'public|private' ]) />
		<cfelseif not structkeyexists(st,"security") or st.security eq "public">
			<cfset st.security = "public" />

			<cfset stACL = structnew() />
			<cfset stACL["group"] = "all" />
			<cfset stACL["permission"] = "read" />
			<cfset arrayappend(st.acl,stACL) />
		</cfif>
		
		<cfif structkeyexists(st,"pathPrefix")>
			<cfif len(st.pathPrefix) and not left(st.pathPrefix,1) eq "/">
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
		
		<cfif structkeyexists(st,"readers") and not isarray(st.readers)>
			<cfset application.fapi.throw(message="the 'readers' value must be an array of canonical user ids or email addresses or ACL structs",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		<cfelseif not structkeyexists(st,"readers")>
			<cfset st.readers = arraynew(1) />
		<cfelse>
			<cfloop from="1" to="#arraylen(st.readers)#" index="i">
				<cfif isStruct(st.readers[i])>
					<cfset stACL = duplicate(st.readers[i]) />
				<cfelseif isvalid("email",st.readers[i])>
					<cfset stACL = { "email" = st.readers[i] } />
				<cfelse>
					<cfset stACL = { "id" = st.readers[i] } />
				</cfif>
				<cfset stACL["permission"] = "read" />
				<cfset arrayappend(st.acl,stACL) />
			</cfloop>
		</cfif>

		<cfif structkeyexists(st,"admins") and not isarray(st.admins)>
			<cfset application.fapi.throw(message="the 'admins' value must be an array of canonical user ids or email addresses or ACL structs",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		<cfelseif not structkeyexists(st,"admins")>
			<cfset st.admins = arraynew(1) />
		<cfelse>
			<cfloop from="1" to="#arraylen(st.admins)#" index="i">
				<cfif isStruct(st.admins[i])>
					<cfset stACL = duplicate(st.admins[i]) />
				<cfelseif isvalid("email",st.admins[i])>
					<cfset stACL = { "email" = st.admins[i] } />
				<cfelse>
					<cfset stACL = { "id" = st.admins[i] } />
				</cfif>
				<cfset stACL["permission"] = "full_control" />
				<cfset arrayappend(st.acl,stACL) />
			</cfloop>
		</cfif>
		
		<cfif not structkeyexists(st,"localCacheSize")>
			<cfset st["localCacheSize"] = 50 />
		</cfif>
		
		<cfif structkeyexists(st,"maxAge") and not refind("^\d+$",st.maxAge)>
			<cfset application.fapi.throw(message="the 'maxAge' value must be an integer",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		</cfif>
		
		<cfif structkeyexists(st,"sMaxAge") and not refind("^\d+$",st.sMaxAge)>
			<cfset application.fapi.throw(message="the 'sMaxAge' value must be an integer",type="cdnconfigerror",detail=serializeJSON(arguments.config)) />
		</cfif>
		
		<cfreturn st />
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
		
		<cflog file="#application.applicationname#_s3" text="Added [#arguments.config.name#] #arguments.file# to local cache" />
		
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
				<cftry>
					<cffile action="delete" file="#this.cacheMap[arguments.config.name][arguments.file].path#" />
					<cfcatch>
					</cfcatch>
				</cftry>
			</cfif>
			
			<cfset structdelete(this.cacheMap[arguments.config.name],arguments.file) />
			
			<cflog file="#application.applicationname#_s3" text="Removed [#arguments.config.name#] #arguments.file# from local cache" />
		</cfif>
	</cffunction>
	
	<cffunction name="getTemporaryFile" returntype="string" access="public" output="false" hint="Returns a path for a new temporary file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var tmpfile = "#getTempDirectory()##application.applicationname#/s3cache/#arguments.config.name#/#createuuid()#.#listlast(arguments.file,'.')#" />
		
		<cfif not directoryExists(getDirectoryFromPath(tmpfile))>
			<cfdirectory action="create" directory="#getDirectoryFromPath(tmpfile)#" mode="774" />
		</cfif>
		
		<cfreturn tmpfile />
	</cffunction>
	
	<cffunction name="deleteTemporaryFile" returntype="void" access="public" output="false" hint="Removes the specified temporary file">
		<cfargument name="file" type="string" required="true" />
		
		<cffile action="delete" file="#arguments.file#" />
		<cflog file="debug" text="deleting #arguments.file# #serializeJSON(appliation.fc.lib.error.getStack(bIgnoreJava=true))#">
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

	<cffunction name="HMAC_SHA256" access="public" returntype="binary" output="false">
	    <cfargument name="signMessage" type="string" required="true" />
	    <cfargument name="signKey" type="binary" required="true" />
	    
	    <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("UTF8") /> 
	    <cfset var jKey = arguments.signKey />
	    
	    <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") /> 
	    <cfset var mac = createObject("java","javax.crypto.Mac") /> 
	    
	    <cfset key = key.init(jKey,"HmacSHA256") /> 
	    
	    <cfset mac = mac.getInstance(key.getAlgorithm()) /> 
	    <cfset mac.init(key) /> 
	    <cfset mac.update(jMsg) /> 
	    
	    <cfreturn mac.doFinal() />
	</cffunction>

	<cffunction name="getSigningKey" access="public" returntype="binary" output="false">
		<cfargument name="secret" type="string" required="true" />
		<cfargument name="date" type="datetime" required="true" />
		<cfargument name="region" type="string" required="true" />
		<cfargument name="service" type="string" required="true" />
		<cfargument name="validate" type="struct" required="false" />

		<cfset var k_secret = JavaCast("string","AWS4" & arguments.secret).getBytes("UTF8") />
	    <cfset var k_key = "" />

	    <cfif isdefined("arguments.validate.secret") and lcase(binaryEncode(k_secret, 'hex')) neq arguments.validate.secret>
		    <cfthrow message="Secret stage did not match" detail='{ "expected":"#arguments.validate.secret#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256(dateformat(arguments.date,"YYYYmmdd"), k_secret) />
	    <cfif isdefined("arguments.validate.date") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.date>
		    <cfthrow message="Date stage [#dateformat(arguments.date,"YYYYmmdd")#] did not match" detail='{ "expected":"#arguments.validate.secret#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256(arguments.region, k_key) />
	    <cfif isdefined("arguments.validate.region") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.region>
		    <cfthrow message="Region stage [#arguments.region#] did not match" detail='{ "expected":"#arguments.validate.region#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256(arguments.service, k_key) />
	    <cfif isdefined("arguments.validate.service") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.service>
		    <cfthrow message="Region stage [#arguments.service#] did not match" detail='{ "expected":"#arguments.validate.service#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256("aws4_request", k_key) />
	    <cfif isdefined("arguments.validate.signing") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.signing>
		    <cfthrow message="Signing stage [#aws4_request#] did not match" detail='{ "expected":"#arguments.validate.signing#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfreturn k_key />
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
		<cfset fullpath = replacelist(urlencodedformat(fullpath),"%2F,%20,%2D,%2E,%5F,%27,%28,%29,%26,%5B,%5D,%21,%25,%40","/, ,-,.,_,',(,),&,[,],!,%,@")>
		<cfset fullpath = replaceNoCase(fullpath, "%2C", ",", "all")>

		<cfset fullpath = "s3://#arguments.config.accessKeyId#:#arguments.config.awsSecretKey#@#arguments.config.bucket##fullpath#" />
		
		<cfreturn fullpath />
	</cffunction>
	
	<cffunction name="getURLPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="method" type="string" required="false" default="GET" />
		<cfargument name="s3Path" type="boolean" required="false" default="false" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var urlpath = arguments.file />
		<cfset var epochTime = 0 />
		<cfset var signature = "" />
		
		<cfif not left(urlpath,1) eq "/">
			<cfset urlpath = "/" & urlpath />
		</cfif>
		
		<cfif NOT left(urlpath,2) eq "//">
	
			<!--- Prepend bucket and pathPrefix --->
			<cfset urlpath = "#arguments.config.pathPrefix##urlpath#" />
		
			<!--- URL encode the filename --->
			<cfset urlpath = replacelist(urlencodedformat(urlpath),"%2F,%20,%2D,%2E,%5F,%27","/, ,-,.,_,'")>
			
			<cfif structkeyexists(arguments.config,"security") and arguments.config.security eq "private">
				<cfset epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + arguments.config.urlExpiry />
				
				<!--- Create a canonical string to send --->
				<cfset signature = "#arguments.method#\n\n\n#epochTime#\n/#arguments.config.bucket##urlpath#" />
				
				<!--- Replace "\n" with "chr(10) to get a correct digest --->
				<cfset signature = replace(signature,"\n","#chr(10)#","all") />
				
				<cfset urlpath = urlpath & "?AWSAccessKeyId=#arguments.config.accessKeyId#&Expires=#epochTime#&Signature=#urlencodedformat(HMAC_SHA1(signature,arguments.config.awsSecretKey))#" />
			</cfif>
			
			<cfif arguments.config.domainType eq "s3" or arguments.s3Path>
				<cfset urlpath = "//#arguments.config.bucket#.s3.amazonaws.com" & urlpath />
			<cfelse>
				<cfset urlpath = "//" & arguments.config.domain & urlpath />
			</cfif>

		</cfif>
			
		<cfif structkeyexists(arguments,"protocol")>
			<cfset urlpath = arguments.protocol & ":" & urlpath />
		</cfif>

		<cfreturn urlpath />
	</cffunction>

	<cffunction name="getMeta" output="false" access="public" returntype="struct" hint="Returns a metadata struct for setting S3 metadata">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult["content_type"] = this.cdn.getMimeType(arguments.file) />
		
		<cfif structkeyexists(arguments.config,"maxAge")>
			<cfparam name="stResult.cache_control" default="" />
			<cfset stResult.cache_control = rereplace(listappend(stResult.cache_control,"max-age=#arguments.config.maxAge#"),",([^ ])",", \1","ALL") />
		</cfif>
		
		<cfif structkeyexists(arguments.config,"sMaxAge")>
			<cfparam name="stResult.cache_control" default="" />
			<cfset stResult.cache_control = rereplace(listappend(stResult.cache_control,"s-maxage=#arguments.config.maxAge#"),",([^ ])",", \1","ALL") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfreturn fileExists(getS3Path(config=arguments.config,file=arguments.file)) />
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
		<cfargument name="admin" type="boolean" required="false" default="false" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var stResult = structnew() />
		
		<cfset arguments.s3path = arguments.admin />

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
		
		<cfset var stAttrs = structnew() />
		<cfset var tmpfile = getTemporaryFile(config=arguments.config,file=arguments.file) />
		
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
		<cflog file="#application.applicationname#_s3" text="Wrote [#arguments.config.name#] #arguments.file# to temporary file #tmpfile#" />
		
		<!--- Move file to S3 --->
		<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.config,dest_file=arguments.file) />
		<cflog file="#application.applicationname#_s3" text="Wrote [#arguments.config.name#] #arguments.file# to S3" />
	</cffunction>
	
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
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
			
			<cflog file="#application.applicationname#_s3" text="Read [#arguments.config.name#] #arguments.file# from local cache" />
			
		<cfelse>

			<cfset tmpfile = getTemporaryFile(config=arguments.config,file=arguments.file) />
			
			<cfset ioCopyFile(source_config=arguments.config,source_file=arguments.file,dest_localpath=tmpfile) />
			
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
			
			<cfif arguments.config.localCacheSize>
				<cfset addCachedFile(config=arguments.config,file=arguments.file,path=tmpfile) />
			<cfelse>
				<!--- Delete temporary file --->
				<cfset deleteTemporaryFile(tmpfile) />
			</cfif>
			
			<cflog file="#application.applicationname#_s3" text="Read [#arguments.config.name#] #arguments.file# from S3" />
			
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
		
		<cfset var sourcefile = "" />
		<cfset var destfile = "" />
		<cfset var acl = "" />
		<cfset var tmpfile = "" />
		<cfset var stAttrs = structnew() />
		<cfset var cachePath = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config")>
			
			<!--- Inter-bucket move --->
			<cfif not structkeyexists(arguments,"dest_file")>
				<cfset arguments.dest_file = arguments.source_file />
			</cfif>
			
			<cfset tmpfile = getTempDirectory() & createuuid() & ".tmp" />
			<cfset ioMoveFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments.dest_file) />
			
			<cflog file="#application.applicationname#_s3" text="Moved [#arguments.source_config.name#] #arguments.source_file# to [#arguments.dest_config.name#] #arguments.dest_file#" />
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="move" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<cfset ioDeleteFile(config=arguments.source_config,file=arguments.source_file) />
				
				<cflog file="#application.applicationname#_s3" text="Moved [#arguments.source_config.name#] #arguments.source_file# from cache to #arguments.dest_localpath#" />
				
			<cfelse>
			
				<!--- move from S3 source to local destination --->
				<cfset sourcefile = getS3Path(config=arguments.source_config,file=arguments.source_file) />
				<cfset destfile = arguments.dest_localpath />
				
				<cfif not directoryExists(getDirectoryFromPath(destfile))>
					<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
				</cfif>
				
				<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
				<cffile action="delete" file="#sourcefile#" />
				
				<cflog file="#application.applicationname#_s3" text="Moved [#arguments.source_config.name#] #arguments.source_file# from S3 to #destfile#" />
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
			
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cftry>
				<cfset putObject(config=arguments.dest_config,file=dest_file,localfile=arguments.source_localpath) />
				<cfset updateACL(config=arguments.dest_config,file=dest_file) />
				
				<cfcatch>
					<cflog file="#application.applicationname#_s3" text="Error moving #arguments.source_localpath# to [#arguments.dest_config.name#] #arguments.dest_file#: #cfcatch.message#" />
					<cfrethrow>
				</cfcatch>
			</cftry>
			
			<cfif arguments.dest_config.localCacheSize>
				<cfset tmpfile = getTemporaryFile(config=arguments.dest_config,file=arguments.dest_file) />
				
				<cffile action="move" source="#arguments.source_localpath#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
				
				<cfset addCachedFile(config=arguments.dest_config,file=arguments.dest_file,path=tmpfile) />
			<cfelse>
				<cffile action="delete" file="#arguments.source_localpath#" />
			</cfif>
			
			<cflog file="#application.applicationname#_s3" text="Moved #arguments.source_localpath# to [#arguments.dest_config.name#] #arguments.dest_file#" />
			
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
		<cfset var stAttrs = structnew() />
		<cfset var cachePath = "" />
		
		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config")>
		
			<!--- Inter-bucket copy --->
			<cfif not structkeyexists(arguments,"dest_file")>
				<cfset arguments.dest_file = arguments.source_file />
			</cfif>
			
			<cfset tmpfile = getTempDirectory() & createuuid() & ".tmp" />
			<cfset ioCopyFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments.dest_file) />
			
			<cflog file="#application.applicationname#_s3" text="Copied [#arguments.source_config.name#] #arguments.source_file# to [#arguments.dest_config.name#] #arguments.dest_file#" />
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="copy" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<cflog file="#application.applicationname#_s3" text="Copied [#arguments.source_config.name#] #arguments.source_file# from cache to #arguments.dest_localpath#" />
				
			<cfelse>
			
				<!--- copy from S3 source to local destination --->
				<cfset sourcefile = getS3Path(config=arguments.source_config,file=arguments.source_file) />
				<cfset destfile = arguments.dest_localpath />
				
				<cfif not directoryExists(getDirectoryFromPath(destfile))>
					<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
				</cfif>
				
				<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
				
				<cfif arguments.source_config.localCacheSize>
					<cfset tmpfile = getTemporaryFile(config=arguments.source_config,file=arguments.source_file) />
					<cffile action="copy" source="#destfile#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
					<cfset addCachedFile(config=arguments.source_config,file=arguments.source_file,path=tmpfile) />
				</cfif>
				
				<cflog file="#application.applicationname#_s3" text="Copied [#arguments.source_config.name#] #arguments.source_file# from S3 to #destfile#" />
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cftry>
				<cfset putObject(config=arguments.dest_config,file=dest_file,localfile=arguments.source_localpath) />
				<cfset updateACL(config=arguments.dest_config,file=dest_file) />
				
				<cfcatch>
					<cflog file="#application.applicationname#_s3" text="Error copying #arguments.source_localpath# to [#arguments.dest_config.name#] #arguments.source_file#: #cfcatch.message#" />
					<cfrethrow>
				</cfcatch>
			</cftry>
			
			<cfif arguments.dest_config.localCacheSize>
				<cfset tmpfile = getTemporaryFile(config=arguments.dest_config,file=arguments.dest_file) />
				<cffile action="copy" source="#arguments.source_localpath#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
				<cfset addCachedFile(config=arguments.dest_config,file=arguments.dest_file,path=tmpfile) />
			</cfif>
			
			<cflog file="#application.applicationname#_s3" text="Copied #arguments.source_localpath# to [#arguments.dest_config.name#] #arguments.dest_file#" />
			
		</cfif>
	</cffunction>
	
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file. Does not check that the file exists first.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cffile action="delete" file="#getS3Path(config=arguments.config,file=arguments.file)#" />
		
		<cfif arguments.config.localCacheSize>
			<cfset removeCachedFile(config=arguments.config,file=arguments.file) />
		</cfif>
		
		<cflog file="#application.applicationname#_s3" text="Deleted [#arguments.config.name#] #arguments.file#" />
	</cffunction>
	
	
	<cffunction name="ioDirectoryExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfif this.engine eq "railo">
			<cfreturn directoryexists(getS3Path(config=arguments.config,file=arguments.dir)) />
		<cfelse>
			<!--- on ColdFusion directories are implicit --->
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="ioCreateDirectory" returntype="void" access="public" output="false" hint="Creates the specified directory. It assumes that it does not already exist, and will create all missing directories">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var s3path = "" />
		
		<cfif this.engine eq "railo" AND listFirst(server.railo.version, ".") lt 4>
			<cfset s3path = getS3Path(config=arguments.config,file=arguments.dir) />
			<cfdirectory action="create" directory="#s3path#" mode="777" />
			<cfset updateACL(config=arguments.config, file=arguments.dir) />
		</cfif>
	</cffunction>
	
	<cffunction name="ioGetDirectoryListing" returntype="query" access="public" output="false" hint="Returns a query of the directory containing a 'file' column only. This filename will be equivilent to what is passed into other CDN functions.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="true" />
		
		<cfset var qDir = "" />
		<cfset var s3path = "s3://#arguments.config.accessKeyId#:#arguments.config.awsSecretKey#@#arguments.config.bucket##lcase(arguments.config.pathPrefix)##lcase(arguments.dir)#" />
		
		<cfif not directoryExists(s3Path)>
			<cfreturn querynew("file") />
		</cfif>

		<cfdirectory action="list" directory="#s3path#" recurse="true" listinfo="name" name="qDir" />
		
		<cfquery dbtype="query" name="qDir">
			SELECT 		'/' + name AS file
			FROM 		qDir 
			ORDER BY 	name
		</cfquery>
		
		<cfreturn qDir />
	</cffunction>
	

	
	<cffunction name="putObject" access="public" output="false" returntype="string" hint="Uses the S3 rest API to upload data to S3">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="localfile" type="string" required="false" />
		<cfargument name="data" type="any" required="false" />
		
		<cfset var stHeaders = structnew() />
		<cfset var stAMZHeaders = structnew() />
		<cfset var stMeta = getMeta(config=arguments.config,file=arguments.file) />
		<cfset var i = 0 />
		<cfset var sortedAMZ = "" />
		<cfset var amz = "" />
		<cfset var signature = "" />
		<cfset var timestamp = GetHTTPTimeString(Now()) />
		<cfset var cfhttp = "" />
		<cfset var results = "" />
		<cfset var path = "" />
		<cfset var stDetail = structNew() />
		<cfset var substituteValues = arrayNew(1) />


		<cfif structkeyexists(arguments,"localfile")>
			<cfset arguments.data = fileReadBinary(arguments.localfile) />
		</cfif>
		
		<cfif left(arguments.file,1) neq "/">
			<cfset path = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset path = arguments.config.pathPrefix & arguments.file />
		</cfif>
		
		<!--- add ACL --->
		<cfloop from="1" to="#arraylen(arguments.config.admins)#" index="i">
			<cfif NOT structKeyExists(stAMZHeaders, "x-amz-grant-full-control")>
				<cfset stAMZHeaders["x-amz-grant-full-control"] = "" />
			</cfif>
			<cfif isvalid("email",arguments.config.admins[i])>
				<cfset stAMZHeaders["x-amz-grant-full-control"] = listappend(stAMZHeaders["x-amz-grant-full-control"],'emailAddress="#arguments.config.admins[i]#"',', ') />
			<cfelseif isstruct(arguments.config.admins[i]) and structKeyExists(arguments.config.admins[i], "id")>
				<cfset stAMZHeaders["x-amz-grant-full-control"] = listappend(stAMZHeaders["x-amz-grant-full-control"],'id="#arguments.config.admins[i].id#"',', ') />
			<cfelse>
				<cfset stAMZHeaders["x-amz-grant-full-control"] = listappend(stAMZHeaders["x-amz-grant-full-control"],'id="#arguments.config.admins[i]#"',', ') />
			</cfif>
		</cfloop>
		
		<!--- add content type --->
		<cfset stHeaders["content-type"] = stMeta.content_type />
		
		<!--- cache control --->
		<cfif structkeyexists(stMeta,"cache_control")>
			<cfset stHeaders["cache-control"] = stMeta.cache_control />
		</cfif>
		
		<!--- prepare amz headers in sorted order --->
		<cfset sortedAMZ = listToArray(listSort(structKeyList(stAMZHeaders),'textnocase')) />
		<cfloop from="1" to="#arraylen(sortedAMZ)#" index="i">
			<cfset stHeaders[sortedAMZ[i]] = stAMZHeaders[sortedAMZ[i]] />
			<cfset amz = amz & "\n" & sortedAMZ[i] & ":" & stAMZHeaders[sortedAMZ[i]] />
		</cfloop>
		
		<!--- create signature --->
		<cfset signature = replace("PUT\n\n#stHeaders['content-type']#\n#timestamp##amz#\n/#arguments.config.bucket##replacelist(urlencodedformat(path),"%2F,%2D,%2E,%5F","/,-,.,_")#","\n","#chr(10)#","all") />
		
		<!--- REST call --->
		<cfhttp method="PUT" url="https://#arguments.config.bucket#.s3.amazonaws.com#path#" charset="utf-8" result="cfhttp" timeout="1800">
			<!--- Amazon Global Headers --->
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="AWS #arguments.config.accessKeyId#:#hmac_sha1(signature,arguments.config.awsSecretKey)#" />
			
			<!--- Headers --->
			<cfloop collection="#stHeaders#" item="i">
				<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
			</cfloop>
			
			<!--- Body --->
			<cfhttpparam type="body" value="#arguments.data#" />
		</cfhttp>
		
		<!--- check XML parsing --->
		<cfif isXML(cfhttp.fileContent)>
			<cfset results = XMLParse(cfhttp.fileContent) />
			
			<!--- check for errors --->
			<cfif structkeyexists(results,"error")>
				<!--- check error xml --->
				<cfset stDetail = structNew()>
				<cfset stDetail["signature"] = signature>
				<cfset stDetail["result"] = results>
				<cfset substituteValues = arrayNew(1)>
				<cfset substituteValues[1] = results.error.message.XMLText>
				<cfset substituteValues[2] = signature>
				<cfset application.fapi.throw(message="Error accessing S3 API: {1} [signature={2}]",type="s3error",detail=serializeJSON(stDetail),substituteValues=substituteValues) />
			</cfif>
		<cfelseif NOT listFindNoCase("200,204",listfirst(cfhttp.statuscode," "))>
			<cfset substituteValues = arrayNew(1)>
			<cfset substituteValues[1] = cfhttp.statuscode>
			<cfset substituteValues[2] = "https://#arguments.config.bucket#.s3.amazonaws.com#path#">
			<cfset application.fapi.throw(message="Error accessing S3 API: {1} {2}",type="s3error",detail=cfhttp.filecontent,substituteValues=substituteValues) />
		</cfif>
	</cffunction>

	<cffunction name="updateACL" access="public" output="false" returntype="void">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfset storeSetACL(getS3Path(config=arguments.config,file=file), arguments.config.acl) />
	</cffunction>
	
</cfcomponent>