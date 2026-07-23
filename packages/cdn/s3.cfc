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
			</cfloop>
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getS3EndpointHost" output="false" access="private" returntype="string" hint="Returns the AWS regional S3 service host for a region, using the modern dot-style (s3.<region>.amazonaws.com) that AWS recommends for every region - including us-east-1, whose regional endpoint never redirects. The deprecated dash-style (s3-<region>) is never emitted - it does not exist for regions launched after ~2019; the legacy no-region global endpoint (s3.amazonaws.com) is likewise avoided.">
		<cfargument name="region" type="string" required="true" />

		<cfreturn "s3.#arguments.region#.amazonaws.com" />
	</cffunction>

	<cffunction name="validateConfig" output="false" access="public" returntype="struct" hint="Returns an array of errors. An empty array means there are no no errors">
		<cfargument name="config" type="struct" required="true" />
		
		<cfset var st = duplicate(arguments.config) />
		<cfset var stACL = structnew() />
		<cfset var i = 0 />
		<cfset var s3host = "" />
		<cfset var credSource = "" />
		<cfset var setName = "" />
		<cfset var setDef = structnew() />
		<cfset var hasInlineKeys = false />

		<!--- Credential validation is deferred to the credential-source block below (after region
		      normalisation). Static configs still require accessKeyId + awsSecretKey. --->
		<cfif not structkeyexists(st,"bucket")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ 'bucket' ]) />
		</cfif>
		
		<cfif not structkeyexists(st,"region")>
			<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ 'region' ]) />
		</cfif>

		<!--- Normalise region once, at the single source. A blank region means us-east-1 (the
		      canonical value AWS expects in the SigV4 credential scope). Every downstream read of
		      config.region (signatures, signed URLs, presigned POST) inherits this canonical value. --->
		<cfset st.region = len(trim(st.region)) ? trim(st.region) : "us-east-1" />

		<!--- Credential source resolution (backward compatible).
		      - A classic config with explicit accessKeyId + awsSecretKey and no credentialSource is a
		        'static' inline credential set and behaves exactly as before (sessionToken stays empty).
		      - A credentialSource (role / auto / container / instanceProfile / environment) resolves
		        temporary credentials at request time via the provider chain; no static keys required.
		      - A credentialSet references a set registered elsewhere (e.g. registerLocationsFromEnv).
		      The location stores only the credential-set NAME; credentials are resolved per request. --->
		<cfset credSource = structkeyexists(st,"credentialSource") ? lcase(trim(st.credentialSource)) : "" />

		<cfif structkeyexists(st,"credentialSet") and len(trim(st.credentialSet))>
			<cfset st.credentialSet = lcase(trim(st.credentialSet)) />
			<cfif not getAwsCredentials().hasCredentialSet(st.credentialSet)>
				<cfset application.fapi.throw(message="the referenced credential set '{1}' has not been registered",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ st.credentialSet ]) />
			</cfif>

		<cfelseif len(credSource) and credSource neq "static">
			<cfif not getAwsCredentials().isKnownSource(credSource)>
				<cfset application.fapi.throw(message="the credentialSource '{1}' is not a supported credential source in this build",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ credSource ]) />
			</cfif>
			<!--- auto carries any non-empty inline keys onto its set so the chain's first (static)
			      step uses them: existing apps add credentialSource="auto", keep their keys (which win
			      locally), and deployed those keys are empty strings so the static step skips and the
			      chain falls through to the role. role/container/etc never run the static step, so
			      inline keys passed with those sources are intentionally ignored. --->
			<cfset setDef = { "source" = credSource, "region" = st.region } />
			<cfif credSource eq "auto" and structkeyexists(st,"accessKeyId") and len(trim(st.accessKeyId)) and structkeyexists(st,"awsSecretKey") and len(trim(st.awsSecretKey))>
				<cfset hasInlineKeys = true />
				<cfset setDef.accessKeyId = trim(st.accessKeyId) />
				<cfset setDef.secretAccessKey = trim(st.awsSecretKey) />
				<cfset setDef.sessionToken = (structkeyexists(st,"sessionToken") ? st.sessionToken : "") />
			</cfif>
			<cfif structkeyexists(st,"roleArn") and len(trim(st.roleArn))>
				<cfset setDef.roleArn = trim(st.roleArn) />
			</cfif>
			<!--- fold the key id into the set identity (like the static branch) so two locations with
			      different inline keys don't share one cached entry. --->
			<cfset setName = "__inline_" & credSource & "_" & hash(credSource & "|" & (hasInlineKeys ? lcase(trim(st.accessKeyId)) : "") & "|" & (structkeyexists(st,"roleArn") ? lcase(trim(st.roleArn)) : "") & "|" & lcase(st.region)) />
			<cfset getAwsCredentials().registerCredentialSet(setName, setDef) />
			<cfset st.credentialSet = setName />

		<cfelse>
			<!--- static: require the long-lived keys exactly as the legacy code did --->
			<cfif not structkeyexists(st,"accessKeyId")>
				<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ 'accessKeyId' ]) />
			</cfif>
			<cfif not structkeyexists(st,"awsSecretKey")>
				<cfset application.fapi.throw(message="no '{1}' value defined",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ 'awsSecretKey' ]) />
			</cfif>
			<cfset setName = "__inline_static_" & hash(lcase(st.accessKeyId) & "|" & lcase(st.region)) />
			<cfset getAwsCredentials().registerCredentialSet(setName, {
				"source" = "static",
				"region" = st.region,
				"accessKeyId" = st.accessKeyId,
				"secretAccessKey" = st.awsSecretKey,
				"sessionToken" = (structkeyexists(st,"sessionToken") ? st.sessionToken : "")
			}) />
			<cfset st.credentialSet = setName />
		</cfif>

		<cfif structKeyExists(arguments.config, "setACL")>
			<cfif NOT isBoolean(arguments.config.setACL)>
				<cfset application.fapi.throw(message="setACL must be a boolean value",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
			</cfif>
		<cfelse>
			<cfset st.setACL = true />
		</cfif>
		
		<!--- Modern dot-style regional S3 service host, applied uniformly to every region. --->
		<cfset s3host = getS3EndpointHost(st.region) />

		<cfif not structkeyexists(st,"domain")>
			<cfset st.domainType = "s3" />
			<cfset st.domain = s3host />
			<cfif find(".", st.bucket)>
				<!--- Dotted bucket: path-style, bucket goes in the prefix (TLS wildcard cert cannot cover a dotted label). --->
				<cfset st.apiEndpoint = s3host />
				<cfset st.apiEndpointPrefix = "/#st.bucket#">
			<cfelse>
				<!--- Dotless bucket: virtual-hosted, regional host so the bucket is addressed directly and never redirected. --->
				<cfset st.apiEndpoint = "#st.bucket#.#s3host#">
				<cfset st.apiEndpointPrefix = "">
			</cfif>
		<cfelse>
			<cfset st.domainType = "custom" />
			<cfset st.apiEndpoint = s3host />
			<cfset st.apiEndpointPrefix = "/#st.bucket#">
		</cfif>

		<!--- domainHost is the bucket's virtual-hosted S3 host (used to sign custom-domain serving).
		      Dotted buckets cannot be virtual-hosted over HTTPS, so they fall back to the apiEndpoint
		      (path-style) host. Both forms reuse the single regional host from getS3EndpointHost. --->
		<cfif find(".", st.bucket)>
			<cfset st.domainHost = st.apiEndpoint>
		<cfelse>
			<cfset st.domainHost = "#st.bucket#.#s3host#">
		</cfif>
		
		<cfif structkeyexists(st,"acl") and not isarray(arguments.config.acl)>
			<cfset application.fapi.throw(message="the 'acl' value must be an array of ACL structs - group | email | id + permission and ",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		<cfelseif not structkeyexists(st,"acl")>
			<cfset st.acl = arraynew(1) />
		</cfif>
		
		<cfif structkeyexists(st,"security") and not listfindnocase("public,private",arguments.config.security)>
			<cfset application.fapi.throw(message="the '{1}' value must be one of ({2})",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config)),substituteValues=[ 'security', 'public|private' ]) />
		<cfelseif not structkeyexists(st,"security") or st.security eq "public">
			<cfset st.security = "public" />

			<cfif st.setACL>
				<cfset stACL = structnew() />
				<cfset stACL["group"] = "all" />
				<cfset stACL["permission"] = "read" />
				<cfset arrayappend(st.acl,stACL) />
			</cfif>
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
			<cfset application.fapi.throw(message="no 'urlExpiry' value defined for private location",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		<cfelseif structkeyexists(st,"urlExpiry") and (not isnumeric(st.urlExpiry) or st.urlExpiry lt 0)>
			<cfset application.fapi.throw(message="the 'urlExpiry' value must be a positive integer",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		<cfelse>
			<cfparam name="st.urlExpiry" default="60" />
		</cfif>
		
		<cfif structkeyexists(st,"readers") and not isarray(st.readers)>
			<cfset application.fapi.throw(message="the 'readers' value must be an array of canonical user ids or email addresses or ACL structs",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		<cfelseif not structkeyexists(st,"readers")>
			<cfset st.readers = arraynew(1) />
		<cfelseif st.setACL>
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
			<cfset application.fapi.throw(message="the 'admins' value must be an array of canonical user ids or email addresses or ACL structs",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		<cfelseif not structkeyexists(st,"admins")>
			<cfset st.admins = arraynew(1) />
		<cfelseif st.setACL>
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
			<cfset application.fapi.throw(message="the 'maxAge' value must be an integer",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		</cfif>
		
		<cfif structkeyexists(st,"sMaxAge") and not refind("^\d+$",st.sMaxAge)>
			<cfset application.fapi.throw(message="the 'sMaxAge' value must be an integer",type="cdnconfigerror",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		</cfif>
		
		<cfif not structkeyexists(st,"bDebug")>
			<cfset st["bDebug"] = false />
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
		
		<cflock name="s3addCachedFile_#hash(arguments.file)#_#application.applicationname#" type="exclusive" timeout="1">
			<cfset var stFile = {}>
			<cfset stFile.touch = now() />
			<cfset stFile.path = arguments.path />
			<cfset this.cacheMap[arguments.config.name][arguments.file] = stFile>
		</cflock>

		<cfset application.fapi.logEvent("cdn", "debug", "added to local cache", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="cache"}) />
		
		<!--- Remove old files --->
		<cflock name="s3addCachedFile_#application.applicationname#" type="exclusive" timeout="5">
		<cfif structcount(this.cacheMap[arguments.config.name]) gte arguments.config.localCacheSize>
			<cfloop collection="#this.cacheMap[arguments.config.name]#" item="thisfile">
				<cfif this.cacheMap[arguments.config.name][thisfile].touch lt oldesttouch>
					<cfset oldest = thisfile />
					<cfset oldesttouch = this.cacheMap[arguments.config.name][thisfile].touch>
				</cfif>
			</cfloop>
			
			<cfset removeCachedFile(config=arguments.config,file=oldest) />
		</cfif>
		</cflock>
	</cffunction>
	
	<cffunction name="removeCachedFile" returntype="void" access="public" output="false" hint="Removes a file from the local cache">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cflock name="s3addCachedFile_#application.applicationname#" type="exclusive" timeout="5">
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
			
			<cfset application.fapi.logEvent("cdn", "debug", "removed from local cache", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="cache"}) />
		</cfif>
		</cflock>
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
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cffile action="delete" file="#arguments.file#" />
		<cfset application.fapi.logEvent("cdn", "debug", "deleting", {url=sanitiseS3URL(arguments.file)}) />
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
		<cfargument name="date" type="any" required="true" />
		<cfargument name="region" type="string" required="true" />
		<cfargument name="service" type="string" required="true" />
		<cfargument name="validate" type="struct" required="false" />

		<cfset var k_secret = JavaCast("string","AWS4" & arguments.secret).getBytes("UTF8") />
	    <cfset var k_key = "" />

	    <cfif isdefined("arguments.validate.secret") and lcase(binaryEncode(k_secret, 'hex')) neq arguments.validate.secret>
		    <cfthrow message="Secret stage did not match" detail='{ "expected":"#arguments.validate.secret#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfif isDate(arguments.date)>
		    <cfset k_key = HMAC_SHA256(dateformat(arguments.date,"YYYYmmdd"), k_secret) />
		<cfelse>
		    <cfset k_key = HMAC_SHA256(arguments.date, k_secret) />
		</cfif>
	    <cfif isdefined("arguments.validate.date") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.date>
		    <cfthrow message="Date stage [#dateformat(arguments.date,"YYYYmmdd")#] did not match" detail='{ "expected":"#arguments.validate.secret#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256(arguments.region, k_key) />
	    <cfif isdefined("arguments.validate.region") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.region>
		    <cfthrow message="Region stage [#arguments.region#] did not match" detail='{ "expected":"#arguments.validate.region#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256(arguments.service, k_key) />
	    <cfif isdefined("arguments.validate.service") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.service>
		    <cfthrow message="Service stage [#arguments.service#] did not match" detail='{ "expected":"#arguments.validate.service#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfset k_key = HMAC_SHA256("aws4_request", k_key) />
	    <cfif isdefined("arguments.validate.signing") and lcase(binaryEncode(k_key, 'hex')) neq arguments.validate.signing>
		    <cfthrow message="Signing stage [#aws4_request#] did not match" detail='{ "expected":"#arguments.validate.signing#", "got":"#lcase(binaryEncode(k_secret, 'hex'))#" }' />
	    </cfif>

	    <cfreturn k_key />
	</cffunction>

	<cffunction name="getCanonicalRequest" access="public" output="false" returntype="string">
		<cfargument name="method" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfargument name="queryParams" type="any" required="false" default="#structNew()#" />
		<cfargument name="headers" type="struct" required="false" default="#structNew()#" />
		<cfargument name="payload" type="any" required="false" />
		<cfargument name="unsignedPayload" type="boolean" required="false" />
		<cfargument name="s3Path" type="boolean" required="false" default="false" />

		<cfset var result = [
			arguments.method,
			S3URLEncode(arguments.path, false),
			"", <!--- query parameters --->
			"", <!--- canonical headers --->
			"", <!--- header list --->
			"" <!--- payload hash --->
		] />
		<cfset var key = "" />
		<cfset var intermed = [] />

		<cfif arguments.config.domainType eq "s3" or arguments.s3Path>
			<cfset arguments.headers["host"] = arguments.config.apiEndpoint />
		<cfelse>
			<cfset arguments.headers["host"] = arguments.config.domainHost />
		</cfif>


		<!--- Query parameters --->
		<cfif isStruct(arguments.queryParams)>
			<cfloop list="#listSort(structKeyList(arguments.queryParams), 'textnocase')#" index="key">
				<cfset result[3] = listAppend(result[3], S3URLEncode(key) & "=" & S3URLEncode(arguments.queryParams[key]), "&") />
			</cfloop>
		</cfif>

		<!--- Headers --->
		<cfloop list="#listSort(structKeyList(arguments.headers), 'textnocase')#" index="key">
			<cfset result[4] = result[4] & lcase(key) & ":" & trim(arguments.headers[key]) & chr(10) />
			<cfset result[5] = listAppend(result[5], lcase(key), ";") />
		</cfloop>

		<cfif (structKeyExists(arguments, "unsignedPayload") AND arguments.unsignedPayload) OR NOT structKeyExists(arguments, "payload") OR (structKeyExists(arguments.headers, "x-amz-content-sha256") and arguments.headers["x-amz-content-sha256"] eq "UNSIGNED-PAYLOAD")>
			<cfset result[6] = "UNSIGNED-PAYLOAD" />
		<cfelse>
			<cfset result[6] = lcase( hash( arguments.payload, 'SHA-256' ) ) />
		</cfif>

		<cfreturn arrayToList(result, chr(10)) />
	</cffunction>

	<cffunction name="getStringToSign" access="public" output="false" returntype="string">
		<cfargument name="timestamp" type="string" required="true" />
		<cfargument name="scope" type="string" required="true" />
		<cfargument name="canonicalRequest" type="string" required="true" />

		<cfreturn arrayToList([
			"AWS4-HMAC-SHA256",
			arguments.timestamp,
			arguments.scope,
			lcase(hash(arguments.canonicalRequest, "SHA-256"))
		], chr(10)) />
	</cffunction>

	<cffunction name="getAWSSignature" access="public" output="false" returntype="string">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="timestamp" type="string" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfargument name="queryParams" type="struct" required="false" default="#structNew()#" />
		<cfargument name="headers" type="struct" required="false" default="#structNew()#" />
		<cfargument name="payload" type="any" required="false" />
		<cfargument name="unsignedPayload" type="boolean" required="false" />
		<cfargument name="s3Path" type="boolean" required="false" default="false" />

		<cfset var scope = left(arguments.timestamp, 8) & "/" & arguments.config.region & "/s3/aws4_request" />
		<cfset var canonicalRequest = "" />
		<cfset var stringToSign = "" />
		<cfset var signingKey = "" />
		<cfset var signature = "" />

		<cfset canonicalRequest = getCanonicalRequest(argumentCollection=arguments) />
		<cfset stringToSign = getStringToSign(arguments.timestamp, scope, canonicalRequest) />
		<cfset signingKey = getSigningKey(arguments.config.awsSecretKey, left(arguments.timestamp, 8), arguments.config.region, "s3") />
		<cfset signature = HMAC_SHA256(stringToSign, signingKey) />

		<cfreturn lcase(binaryEncode(signature, 'hex')) />
	</cffunction>

	<cffunction name="getAWSAuthorization" access="public" output="false" returntype="string">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="timestamp" type="string" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="path" type="string" required="true" />
		<cfargument name="queryParams" type="struct" required="false" default="#structNew()#" />
		<cfargument name="headers" type="struct" required="false" default="#structNew()#" />
		<cfargument name="payload" type="any" required="false" />
		<cfargument name="unsignedPayload" type="boolean" required="false" />
		<cfargument name="s3Path" type="boolean" required="false" default="false" />

		<cfset var signature = getAWSSignature(argumentCollection=arguments) />
		<cfset var signedHeaders = listSort(structKeyList(arguments.headers, ';'), 'textnocase', 'asc', ';') />

		<cfreturn "AWS4-HMAC-SHA256 Credential=#arguments.config.accessKeyId#/#left(arguments.timestamp, 8)#/#arguments.config.region#/s3/aws4_request,SignedHeaders=#signedHeaders#,Signature=#signature#" />
	</cffunction>

	<cffunction name="S3URLEncode" access="public" output="false" returntype="string">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="encodeSlash" type="boolean" required="false" default="true" />

		<cfset var result = urlEncodedFormat(arguments.input) />

		<cfif arguments.encodeSlash>
			<cfreturn replaceList(result, "%2E,%5F,%2D,%7E", ".,_,-,~") />
		<cfelse>
			<cfreturn replaceList(result, "%2E,%5F,%2D,%7E,%2F", ".,_,-,~,/") />
		</cfif>
	</cffunction>

	<cffunction name="HashSHA256" access="public" output="false" returntype="string">
		<cfargument name="input" type="string" required="true" />

		<cfset var digest = createobject("java", "java.security.MessageDigest").getInstance("SHA-256") />
		<cfset var binaryHash = digest.digest(JavaCast("string",arguments.input).getBytes("UTF8")) />

		<cfreturn lcase(binaryEncode(binaryHash, 'hex')) />
	</cffunction>

	
	<cffunction name="getAwsCredentials" access="private" output="false" returntype="any" hint="Returns the shared AWS credential resolver (application.fc.lib.awscredentials, auto-registered by lib.cfc) so its refresh cache is shared app-wide. Falls back to a private instance only on early-init/test paths where the shared lib isn't built yet.">
		<cfif isDefined("application.fc.lib") and structkeyexists(application.fc.lib,"awscredentials")>
			<cfreturn application.fc.lib.awscredentials />
		</cfif>
		<cfif not structkeyexists(this,"awscreds")>
			<cfset this.awscreds = createobject("component","farcry.core.packages.lib.awscredentials").init() />
		</cfif>
		<cfreturn this.awscreds />
	</cffunction>

	<cffunction name="getActiveCredentials" access="private" output="false" returntype="struct" hint="Resolves the active AWS credentials for a location config. Classic configs (no credentialSet) return their configured keys with an empty sessionToken - identical to legacy behaviour. credentialSet-backed configs resolve (and auto-refresh) credentials via the provider chain.">
		<cfargument name="config" type="struct" required="true" />

		<cfset var creds = "" />

		<cfif not structkeyexists(arguments.config,"credentialSet") or not len(arguments.config.credentialSet)>
			<cfreturn {
				"accessKeyId" = structkeyexists(arguments.config,"accessKeyId") ? arguments.config.accessKeyId : "",
				"awsSecretKey" = structkeyexists(arguments.config,"awsSecretKey") ? arguments.config.awsSecretKey : "",
				"sessionToken" = ""
			} />
		</cfif>

		<cfset creds = getAwsCredentials().getCredentials(arguments.config.credentialSet) />
		<cfreturn {
			"accessKeyId" = creds.accessKeyId,
			"awsSecretKey" = creds.secretAccessKey,
			"sessionToken" = creds.sessionToken
		} />
	</cffunction>

	<cffunction name="resolveSigningConfig" access="private" output="false" returntype="struct" hint="Returns a shallow copy of the location config with accessKeyId / awsSecretKey / sessionToken set to the active (possibly temporary) credentials. The stored config struct is never mutated.">
		<cfargument name="config" type="struct" required="true" />

		<cfset var creds = getActiveCredentials(arguments.config) />
		<cfset var working = structCopy(arguments.config) />

		<cfset working.accessKeyId = creds.accessKeyId />
		<cfset working.awsSecretKey = creds.awsSecretKey />
		<cfset working.sessionToken = creds.sessionToken />

		<cfreturn working />
	</cffunction>

	<cffunction name="isTemporaryCredential" access="private" output="false" returntype="boolean" hint="True when the active credentials for this config carry a session token (i.e. temporary credentials).">
		<cfargument name="config" type="struct" required="true" />
		<cfreturn len(getActiveCredentials(arguments.config).sessionToken) gt 0 />
	</cffunction>

	<cffunction name="getS3Path" output="false" access="public" returntype="string" hint="Returns path to use for all S3 requests">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset var fullpath = arguments.file />
		<cfset var stConfig = resolveSigningConfig(arguments.config) />

		<!--- The native s3:// VFS cannot carry a session token; temporary credentials must use the
		      REST path. Long-lived keys (static config or environment) build the URI from the
		      resolved credentials, which also fixes env-supplied keys whose config.accessKeyId is blank. --->
		<cfif len(stConfig.sessionToken)>
			<cfset application.fapi.throw(message="The native s3:// filesystem cannot be used with temporary credentials (location [{1}]). This operation is served via the S3 REST API in a later phase; for now use the REST-backed operations (upload, serve, delete, setACL, signed URLs).",type="s3tempcredunsupported",detail=serializeJSON(sanitiseS3Config(arguments.config))) />
		</cfif>

		<cfif not left(fullpath,1) eq "/">
			<cfset fullpath = "/" & fullpath />
		</cfif>
		
		<cfset fullpath = arguments.config.pathPrefix & fullpath />
		
		<!--- URL encode the filename --->
		<cfset fullpath = replacelist(urlencodedformat(fullpath),"%2F,%20,%2D,%2E,%5F,%27,%28,%29,%26,%5B,%5D,%21,%25,%40","/, ,-,.,_,',(,),&,[,],!,%,@")>
		<cfset fullpath = replaceNoCase(fullpath, "%2C", ",", "all")>

		<cfset fullpath = "s3://#stConfig.accessKeyId#:#stConfig.awsSecretKey#@#arguments.config.bucket##fullpath#" />
		
		<cfreturn fullpath />
	</cffunction>

	<cffunction name="structToQueryParams" output="false" access="public" returntype="string">
		<cfargument name="queryParams" type="struct" required="true" />

		<cfset var k = "" />
		<cfset var result = "" />

		<cfloop collection="#arguments.queryParams#" item="k">
			<cfset result = listAppend(result, S3URLEncode(k) & "=" & S3URLEncode(arguments.queryParams[k]), "&") />
		</cfloop>

		<cfreturn result />
	</cffunction>
	
	<cffunction name="getURLPath" output="false" access="public" returntype="string" hint="Returns full internal path. Works for files and directories.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="method" type="string" required="false" default="GET" />
		<cfargument name="s3Path" type="boolean" required="false" default="false" />
		<cfargument name="protocol" type="string" required="false" />
		<cfargument name="requireSignedURL" type="boolean" required="false" default="false" />
		
		<cfset var urlpath = arguments.file />
		<cfset var epochTime = 0 />
		<cfset var signature = "" />
		<cfset var timestamp = "" />
		<cfset var scope = "" />
		<cfset var canonicalRequest = [] />
		<cfset var stringToSign = [] />
		<cfset var signingKey = "" />
		<cfset var queryParams = "" />
		<cfset var headers = "" />
		<cfset var stConfig = "" />
		<cfset var signedPath = "" />
		
		<cfif not left(urlpath,1) eq "/">
			<cfset urlpath = "/" & urlpath />
		</cfif>
		
		<cfif NOT left(urlpath,2) eq "//">
			<!--- Prepend bucket and pathPrefix --->
			<cfset urlpath = "#arguments.config.pathPrefix##urlpath#" />

			<cfif (structkeyexists(arguments.config,"security") and arguments.config.security eq "private") or arguments.requireSignedURL>
				<!--- Resolve active credentials (long-lived or auto-refreshed temporary) for signing. --->
				<cfset stConfig = resolveSigningConfig(arguments.config) />

				<!--- Current date --->
				<cfset currentDate = application.fapi.dateToISO8601(now()) />

				<cfset queryParams = {
					"X-Amz-Algorithm"="AWS4-HMAC-SHA256",
					"X-Amz-Credential"="#stConfig.accessKeyId#/#left(currentDate, 8)#/#stConfig.region#/s3/aws4_request",
					"X-Amz-Date"=currentDate,
					"X-Amz-Expires"=numberFormat(arguments.config.urlExpiry*60, "0"),
					"X-Amz-SignedHeaders"="host"
				} />

				<!--- Temporary credentials: the security token is a signed query parameter on presigned URLs. --->
				<cfif len(stConfig.sessionToken)>
					<cfset queryParams["X-Amz-Security-Token"] = stConfig.sessionToken />
				</cfif>

				<!--- sign the path S3 will actually see: path-style (bucket in the path) when the URL
				      targets the S3 API endpoint, bare path when it goes via the custom domain (there
				      the bucket is in the host). Must match the URL-host choice made below. --->
				<cfset signedPath = urlPath />
				<cfif arguments.config.domainType eq "s3" or arguments.s3Path>
					<cfset signedPath = arguments.config.apiEndpointPrefix & urlPath />
				</cfif>
				<cfset signature = getAWSSignature(
					config=stConfig,
					timestamp=currentDate,
					method=arguments.method,
					path=signedPath,
					queryParams=queryParams,
					s3Path=arguments.s3Path
				) />

				<cfset urlpath = urlpath & "?#structToQueryParams(queryParams)#&X-Amz-Signature=#signature#" />
			</cfif>
			
			<cfif arguments.config.domainType eq "s3" or arguments.s3Path>
				<cfset urlpath = "//#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix#" & urlpath />
			<cfelse>
				<cfset urlpath = "//" & arguments.config.domain & urlpath />
			</cfif>

		</cfif>
			
		<cfif structkeyexists(arguments,"protocol")>
			<cfset urlpath = arguments.protocol & ":" & urlpath />
		</cfif>

		<cfreturn urlpath />
	</cffunction>

	<cffunction name="getPresignedPostData" output="false" access="public" returntype="struct" hint="Builds a SigV4 presigned POST policy for direct browser-to-S3 upload. Returns { url, method, fields } shaped for Uppy AwsS3 getUploadParameters. Honours config.setACL.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="value" type="string" required="true" hint="CDN-relative path, e.g. /photos/myfile_1.jpg (no bucket, no pathPrefix). The S3 object key is derived from config.pathPrefix + value." />
		<cfargument name="contentType" type="string" required="false" default="" />
		<cfargument name="maxSize" type="numeric" required="false" default="0" hint="Maximum allowed file size in bytes. 0 means no limit." />

		<!--- The S3 object key = pathPrefix + the CDN-relative value. All knowledge of
		      how a value maps to an object key stays inside this component. --->
		<cfset var key = arguments.config.pathPrefix & arguments.value />
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfset var prefix = "" />
		<cfset var aclPermission = (structKeyExists(arguments.config, "security") and arguments.config.security eq "private") ? "private" : "public-read" />
		<cfset var isoTime = application.fapi.dateToISO8601(now()) />
		<cfset var dateStamp = left(isoTime, 8) />
		<cfset var credential = "#stConfig.accessKeyId#/#dateStamp#/#stConfig.region#/s3/aws4_request" />
		<cfset var expiry = structKeyExists(arguments.config, "urlExpiry") ? arguments.config.urlExpiry : 60 />
		<cfset var expiration = dateConvert("local2utc", dateAdd("s", expiry * 60, now())) />
		<cfset var policy = "" />
		<cfset var serializedPolicy = "" />
		<cfset var base64Policy = "" />
		<cfset var signingKey = "" />
		<cfset var signature = "" />
		<cfset var fields = structnew() />

		<!--- Normalise key (no leading slash); the starts-with prefix is the key's directory --->
		<cfif left(key, 1) eq "/">
			<cfset key = mid(key, 2, len(key) - 1) />
		</cfif>
		<cfset prefix = (find("/", key)) ? left(key, len(key) - len(listLast(key, "/"))) : "" />

		<cfset policy = {
			"expiration" = dateFormat(expiration, "yyyy-mm-dd") & "T" & timeFormat(expiration, "HH:mm:ss") & "Z",
			"conditions" = [
				{ "x-amz-credential" = credential },
				{ "x-amz-algorithm" = "AWS4-HMAC-SHA256" },
				{ "x-amz-date" = isoTime },
				{ "bucket" = arguments.config.bucket },
				[ "starts-with", "$key", prefix ],
				{ "success_action_status" = javaCast("string", "201") },
				[ "starts-with", "$Content-Type", "" ]
			]
		} />

		<!--- Only include the acl condition when the cdn config has setACL enabled (bucket owner enforced buckets reject acl). --->
		<cfif arguments.config.setACL>
			<cfset arrayAppend(policy.conditions, { "acl" = aclPermission }) />
		</cfif>
		<cfif arguments.maxSize gt 0>
			<cfset arrayAppend(policy.conditions, [ "content-length-range", 0, javaCast("long", arguments.maxSize) ]) />
		</cfif>

		<!--- Temporary credentials: the security token must be both a policy condition and a posted field. --->
		<cfif len(stConfig.sessionToken)>
			<cfset arrayAppend(policy.conditions, { "x-amz-security-token" = stConfig.sessionToken }) />
		</cfif>

		<cfset serializedPolicy = serializeJSON(policy) />
		<cfset serializedPolicy = reReplace(serializedPolicy, "[\r\n]+", "", "all") />
		<cfset base64Policy = binaryEncode(charsetDecode(serializedPolicy, "utf-8"), "base64") />

		<cfset signingKey = getSigningKey(stConfig.awsSecretKey, dateStamp, stConfig.region, "s3") />
		<cfset signature = lcase(binaryEncode(HMAC_SHA256(base64Policy, signingKey), "hex")) />

		<cfset fields["key"] = key />
		<cfset fields["success_action_status"] = "201" />
		<cfif len(arguments.contentType)>
			<cfset fields["Content-Type"] = arguments.contentType />
		</cfif>
		<cfif arguments.config.setACL>
			<cfset fields["acl"] = aclPermission />
		</cfif>
		<cfif len(stConfig.sessionToken)>
			<cfset fields["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>
		<cfset fields["X-Amz-Algorithm"] = "AWS4-HMAC-SHA256" />
		<cfset fields["X-Amz-Credential"] = credential />
		<cfset fields["X-Amz-Date"] = isoTime />
		<cfset fields["Policy"] = base64Policy />
		<cfset fields["X-Amz-Signature"] = signature />

		<cfreturn {
			"method" = "POST",
			"url" = "https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix#",
			"fields" = fields,
			"headers" = structnew()
		} />
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
			<cfset stResult.cache_control = rereplace(listappend(stResult.cache_control,"s-maxage=#arguments.config.sMaxAge#"),",([^ ])",", \1","ALL") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="ioFileExists" returntype="boolean" access="public" output="false" hint="Checks that a specified path exists">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="protocol" type="string" require="false" default="https" />

		<cfset var bExists = false />
		<cfset var stResponse = structNew() />
		<cfset var results = "" />
		<cfset var path = "" />
		<cfset var stDetail = structNew() />
		<cfset var substituteValues = arrayNew(1) />
		<cfset var timestamp = application.fapi.dateToISO8601(Now()) />
		<cfset var stHeaders = {
			"x-amz-content-sha256" = "UNSIGNED-PAYLOAD"
		} />
		<cfset var i = "" />
		<cfset var authArgs = {} />

		<cfset var urlPath = arguments.config.pathPrefix & arguments.file />
		<cfif left(arguments.file,1) neq "/">
			<cfset urlPath = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset urlPath = arguments.config.pathPrefix & arguments.file />
		</cfif>

		<!--- resolve active credentials; sign and send the security token when temporary --->
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfif len(stConfig.sessionToken)>
			<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>

		<!--- create signature --->
		<cfset var authArgs = {
			config=stConfig,
			timestamp=timestamp,
			method="HEAD",
			path=arguments.config.apiEndpointPrefix & urlPath,
			headers=stHeaders,
			unsignedPayload=true,
			s3Path=true
		} />
		<cfset var signature = getAWSAuthorization(argumentCollection=authArgs) />

		<!--- REST call --->
		<cfhttp method="HEAD" url="https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##urlPath#" charset="utf-8" result="stResponse" timeout="30">
			<!--- Amazon Global Headers --->
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="#signature#" />

			<!--- Headers --->
			<cfloop collection="#stHeaders#" item="i">
				<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
			</cfloop>
		</cfhttp>

		<cfif listfirst(stResponse.statuscode," ") eq "200">
			<!--- file exists --->
			<cfset bExists = true />
		<cfelseif listfirst(stResponse.statuscode," ") eq "404">
			<!--- file does not exist --->
			<cfset bExists = false />
		<cfelse>
			<!--- API error --->
			<!--- check XML parsing --->
			<cfif isXML(stResponse.fileContent)>
				<cfset results = XMLParse(stResponse.fileContent) />
				<!--- check for errors --->
				<cfif structkeyexists(results,"error")>
					<!--- check error xml --->
					<cfset stDetail = structNew()>
					<cfset stDetail["result"] = results>
					<cfset substituteValues = arrayNew(1)>
					<cfset substituteValues[1] = results.error.message.XMLText>
					<cfset substituteValues[2] = sanitiseCanonicalRequest(getCanonicalRequest(argumentCollection=authArgs))>
					<cfset substituteValues[3] = signature>
					<cfset application.fapi.throw(message="Error accessing S3 API: {1} [canonical request={2}, signature={3}]",type="s3error",detail=serializeJSON(stDetail),substituteValues=substituteValues) />
				</cfif>
			<cfelseif NOT listFindNoCase("200,204",listfirst(stResponse.statuscode," "))>
				<cfset substituteValues = arrayNew(1)>
				<cfset substituteValues[1] = stResponse.statuscode>
				<cfset substituteValues[2] = urlPath>
				<cfset application.fapi.throw(message="Error accessing S3 API: {1} {2}",type="s3error",detail=stResponse.filecontent,substituteValues=substituteValues) />
			</cfif>

		</cfif>

		<cfreturn bExists />
	</cffunction>

	<cffunction name="getObjectSize" returntype="numeric" access="public" output="false" hint="Returns an object's size in bytes via a signed REST HEAD - the temporary-credential equivalent of getFileInfo() on the s3:// path.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfset var stResponse = structNew() />
		<cfset var timestamp = application.fapi.dateToISO8601(Now()) />
		<cfset var stHeaders = { "x-amz-content-sha256" = "UNSIGNED-PAYLOAD" } />
		<cfset var i = "" />
		<cfset var urlPath = "" />
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfset var authArgs = {} />
		<cfset var signature = "" />
		<cfset var clen = 0 />

		<cfif left(arguments.file,1) neq "/">
			<cfset urlPath = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset urlPath = arguments.config.pathPrefix & arguments.file />
		</cfif>

		<cfif len(stConfig.sessionToken)>
			<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>

		<cfset authArgs = {
			config=stConfig,
			timestamp=timestamp,
			method="HEAD",
			path=arguments.config.apiEndpointPrefix & urlPath,
			headers=stHeaders,
			unsignedPayload=true,
			s3Path=true
		} />
		<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

		<cfhttp method="HEAD" url="https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##urlPath#" charset="utf-8" result="stResponse" timeout="30">
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="#signature#" />
			<cfloop collection="#stHeaders#" item="i">
				<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
			</cfloop>
		</cfhttp>

		<cfif NOT listFindNoCase("200,204",listfirst(stResponse.statuscode," "))>
			<cfset application.fapi.throw(message="Error reading S3 object size: {1} {2}",type="s3error",detail=stResponse.filecontent,substituteValues=[ stResponse.statuscode, urlPath ]) />
		</cfif>

		<!--- struct keys are case-insensitive, so this matches Content-Length regardless of casing --->
		<cfif structkeyexists(stResponse,"responseheader") and structkeyexists(stResponse.responseheader,"Content-Length")>
			<cfset clen = stResponse.responseheader["Content-Length"] />
		</cfif>
		<cfreturn val(clen) />
	</cffunction>

	<cffunction name="listObjects" returntype="query" access="public" output="false" hint="Lists objects under a location/dir via the S3 REST ListObjectsV2 API - the temporary-credential equivalent of cfdirectory on the s3:// path. Returns a query with a location-relative 'file' column (plus size / datelastmodified). Follows continuation tokens.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="dir" type="string" required="false" default="" />

		<cfset var qDir = queryNew("file,size,datelastmodified") />
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfset var keyPrefix = reReplaceNoCase(arguments.config.pathPrefix, "^/", "") />
		<cfset var dirpart = reReplaceNoCase(reReplaceNoCase(arguments.dir, "^/+", ""), "/+$", "") />
		<cfset var listPrefix = "" />
		<cfset var listPath = len(arguments.config.apiEndpointPrefix) ? arguments.config.apiEndpointPrefix : "/" />
		<cfset var continuationToken = "" />
		<cfset var bTruncated = true />
		<cfset var queryParams = "" />
		<cfset var timestamp = "" />
		<cfset var stHeaders = "" />
		<cfset var authArgs = {} />
		<cfset var signature = "" />
		<cfset var stResponse = "" />
		<cfset var xml = "" />
		<cfset var aContents = "" />
		<cfset var aKey = "" />
		<cfset var aSize = "" />
		<cfset var aModified = "" />
		<cfset var aFlag = "" />
		<cfset var i = 0 />
		<cfset var thisKey = "" />
		<cfset var rel = "" />

		<!--- Build the S3 key prefix as a directory boundary (trailing slash) from pathPrefix + dir,
		      so it matches only keys under that path, not sibling keys that merely share the string. --->
		<cfif len(keyPrefix) and len(dirpart)>
			<cfset listPrefix = keyPrefix & "/" & dirpart & "/" />
		<cfelseif len(keyPrefix)>
			<cfset listPrefix = keyPrefix & "/" />
		<cfelseif len(dirpart)>
			<cfset listPrefix = dirpart & "/" />
		</cfif>

		<cfloop condition="bTruncated">
			<cfset timestamp = application.fapi.dateToISO8601(Now()) />
			<cfset stHeaders = { "x-amz-content-sha256" = "UNSIGNED-PAYLOAD" } />
			<cfif len(stConfig.sessionToken)>
				<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
			</cfif>

			<cfset queryParams = { "list-type" = "2", "prefix" = listPrefix } />
			<cfif len(continuationToken)>
				<cfset queryParams["continuation-token"] = continuationToken />
			</cfif>

			<cfset authArgs = {
				config=stConfig,
				timestamp=timestamp,
				method="GET",
				path=listPath,
				queryParams=queryParams,
				headers=stHeaders,
				unsignedPayload=true,
				s3Path=true
			} />
			<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

			<cfhttp method="GET" url="https://#arguments.config.apiEndpoint##listPath#?#structToQueryParams(queryParams)#" charset="utf-8" result="stResponse" timeout="30">
				<cfhttpparam type="header" name="Date" value="#timestamp#" />
				<cfhttpparam type="header" name="Authorization" value="#signature#" />
				<cfloop collection="#stHeaders#" item="i">
					<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
				</cfloop>
			</cfhttp>

			<cfif NOT listFindNoCase("200",listfirst(stResponse.statuscode," ")) OR NOT isXML(stResponse.fileContent)>
				<cfset application.fapi.throw(message="Error listing S3 objects: {1} {2}",type="s3error",detail=stResponse.filecontent,substituteValues=[ stResponse.statuscode, listPrefix ]) />
			</cfif>

			<!--- use local-name() XPath so the default S3 namespace doesn't hide the nodes --->
			<cfset xml = xmlParse(stResponse.fileContent) />
			<cfset aContents = xmlSearch(xml, "//*[local-name()='Contents']") />
			<cfloop from="1" to="#arrayLen(aContents)#" index="i">
				<cfset aKey = xmlSearch(aContents[i], "*[local-name()='Key']") />
				<cfif not arrayLen(aKey)>
					<cfcontinue />
				</cfif>
				<cfset thisKey = aKey[1].xmlText />
				<!--- skip folder-marker keys (S3 has no real directories) --->
				<cfif not len(thisKey) or right(thisKey,1) eq "/">
					<cfcontinue />
				</cfif>
				<cfset rel = thisKey />
				<cfif len(keyPrefix) and left(rel, len(keyPrefix)+1) eq keyPrefix & "/">
					<cfset rel = mid(rel, len(keyPrefix)+2, len(rel)) />
				</cfif>
				<cfif left(rel,1) neq "/">
					<cfset rel = "/" & rel />
				</cfif>
				<cfset aSize = xmlSearch(aContents[i], "*[local-name()='Size']") />
				<cfset aModified = xmlSearch(aContents[i], "*[local-name()='LastModified']") />
				<cfset queryAddRow(qDir) />
				<cfset querySetCell(qDir, "file", rel) />
				<cfset querySetCell(qDir, "size", arrayLen(aSize) ? val(aSize[1].xmlText) : 0) />
				<cfset querySetCell(qDir, "datelastmodified", arrayLen(aModified) ? aModified[1].xmlText : "") />
			</cfloop>

			<!--- continuation --->
			<cfset bTruncated = false />
			<cfset aFlag = xmlSearch(xml, "//*[local-name()='IsTruncated']") />
			<cfif arrayLen(aFlag) and aFlag[1].xmlText eq "true">
				<cfset aFlag = xmlSearch(xml, "//*[local-name()='NextContinuationToken']") />
				<cfif arrayLen(aFlag) and len(aFlag[1].xmlText)>
					<cfset continuationToken = aFlag[1].xmlText />
					<cfset bTruncated = true />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn qDir />
	</cffunction>

	<cffunction name="ioGetFileSize" returntype="numeric" output="false" hint="Returns the size of the file in bytes">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfset var cachePath = getCachedFile(config=arguments.config,file=arguments.file) />

		<!--- Read size from the local cache when present: CF's s3:// VFS caches object
		      metadata and doesn't invalidate on in-place overwrite, so it can report a
		      stale size. Fall back to the s3:// path only when uncached. --->
		<cfif len(cachePath)>
			<cfreturn getFileInfo(cachePath).size />
		</cfif>

		<cfif isTemporaryCredential(arguments.config)>
			<cfreturn getObjectSize(config=arguments.config, file=arguments.file) />
		</cfif>

		<cfreturn getFileInfo(getS3Path(config=arguments.config,file=arguments.file)).size />
	</cffunction>
	
	<cffunction name="ioGetFileLocation" returntype="struct" output="false" hint="Returns serving information for the file - either method=redirect + path=URL OR method=stream + path=local path">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="admin" type="boolean" required="false" default="false" />
		<cfargument name="protocol" type="string" require="false" />
		
		<cfset var stResult = structnew() />
		
		<cfset arguments.s3path = arguments.admin />
		<cfif arguments.admin AND arguments.config.setACL eq false>
			<cfset arguments.s3path = false />
		</cfif>

		<cfset stResult["method"] = "redirect" />
		<cfset stResult["path"] = getURLPath(argumentCollection=arguments) />
		<cfset stResult["mimetype"] = getPageContext().getServletContext().getMimeType(arguments.file) />
		<!--- s3Path drives native VFS streaming, which cannot use temporary credentials; omit it then
		      (serving falls back to the signed redirect path above). --->
		<cfset stResult["s3Path"] = "" />
		<cfif not isTemporaryCredential(arguments.config)>
			<cfset stResult["s3Path"] = getS3Path(config=arguments.config,file=arguments.file) />
		</cfif>
		
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
		<cfset application.fapi.logEvent("cdn", "debug", "wrote to temporary file", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="cache"}) />
		
		<!--- Move file to S3 --->
		<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.config,dest_file=arguments.file) />
		<cfset application.fapi.logEvent("cdn", "debug", "wrote to S3", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="s3"}) />
	</cffunction>
	
	<cffunction name="ioReadFile" returntype="any" access="public" output="false" hint="Reads from the specified file">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="datatype" type="string" required="false" default="text" options="text,binary,image" />
		
		<cfset var data = "" />
		<cfset var tmpfile = getCachedFile(config=arguments.config,file=arguments.file) />
		
		<cftry>
			
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
				
				<cfset application.fapi.logEvent("cdn", "debug", "read", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="cache"}) />
				
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
					<cfset deleteTemporaryFile(arguments.config, tmpfile) />
				</cfif>
				
				<cfset application.fapi.logEvent("cdn", "debug", "read", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), source="s3"}) />
				
			</cfif>

			<cfcatch>
				<cfset application.fapi.logEvent("cdn", "error", "read failed", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file), error=cfcatch.message}) />
				<cfrethrow>
			</cfcatch>
		</cftry>
			
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
			
			<cfset application.fapi.logEvent("cdn", "debug", "moved", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.dest_file), source="s3"}) />
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="move" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<cfset ioDeleteFile(config=arguments.source_config,file=arguments.source_file) />
				
				<cfset application.fapi.logEvent("cdn", "debug", "moved from cache", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), desturl=sanitiseS3URL(arguments.dest_localpath), source="cache"}) />
				
			<cfelse>
			
				<cfset destfile = arguments.dest_localpath />

				<cfif isTemporaryCredential(arguments.source_config)>
					<!--- temporary credentials: native s3:// move unavailable; download via signed REST GET, then delete --->
					<cfset ioCopyFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=destfile) />
					<cfset ioDeleteFile(config=arguments.source_config,file=arguments.source_file) />
				<cfelse>
					<!--- move from S3 source to local destination (native s3://) --->
					<cfset sourcefile = getS3Path(config=arguments.source_config,file=arguments.source_file) />

					<cfif not directoryExists(getDirectoryFromPath(destfile))>
						<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
					</cfif>

					<cffile action="copy" source="#sourcefile#" destination="#destfile#" mode="664" nameconflict="overwrite" />
					<cffile action="delete" file="#sourcefile#" />
				</cfif>
				
				<cfset application.fapi.logEvent("cdn", "debug", "moved from S3", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), desturl=sanitiseS3URL(destfile), source="s3"}) />
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
			
			<cftry>
				<cfset putObject(config=arguments.dest_config,file=dest_file,localfile=arguments.source_localpath) />
				<cfset updateACL(config=arguments.dest_config,file=dest_file) />
				
				<cfcatch>
					<cfset application.fapi.logEvent("cdn", "error", "move failed", {url=sanitiseS3URL(arguments.source_localpath), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.dest_file), error=cfcatch.message}) />
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
			
			<cfset application.fapi.logEvent("cdn", "debug", "moved", {url=sanitiseS3URL(arguments.source_localpath), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.dest_file)}) />
			
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
		<cfset var timestamp = "" />
		<cfset var stHeaders = "" />
		<cfset var authArgs = {} />
		<cfset var signature = "" />
		<cfset var stResponse = structNew() />
		<cfset var urlPath = "" />
		<cfset var i = "" />
		<cfset var errorBody = "" />
		<cfset var substituteValues = arrayNew(1) />
		<cfset var stConfig = "" />

		<cfif structkeyexists(arguments,"source_config") and structkeyexists(arguments,"dest_config")>
		
			<!--- Inter-bucket copy --->
			<cfif not structkeyexists(arguments,"dest_file")>
				<cfset arguments.dest_file = arguments.source_file />
			</cfif>
			
			<cfset tmpfile = getTempDirectory() & createuuid() & ".tmp" />
			<cfset ioCopyFile(source_config=arguments.source_config,source_file=arguments.source_file,dest_localpath=tmpfile) />
			<cfset ioMoveFile(source_localpath=tmpfile,dest_config=arguments.dest_config,dest_file=arguments.dest_file) />
			
			<cfset application.fapi.logEvent("cdn", "debug", "copied", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.dest_file)}) />
			
		<cfelseif structkeyexists(arguments,"source_config")>
			
			<cfset cachePath = getCachedFile(config=arguments.source_config,file=arguments.source_file) />
			
			<cfif len(cachePath)>
				
				<cffile action="copy" source="#cachePath#" destination="#arguments.dest_localpath#" mode="664" nameconflict="overwrite" />
				
				<cfset application.fapi.logEvent("cdn", "debug", "copied from cache", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), desturl=sanitiseS3URL(arguments.dest_localpath), source="cache"}) />
				
			<cfelse>
			
				<!--- copy from S3 source to local destination.
				      The read-back is SigV4-signed against the S3 API endpoint (same request shape
				      as ioFileExists) so it never depends on object ACLs, bucket policy or the CDN
				      domain - the app can always read its own objects, including on buckets with
				      public access blocked / ACLs disabled. --->
				<cfset destfile = arguments.dest_localpath />

				<cfif not directoryExists(getDirectoryFromPath(destfile))>
					<cfdirectory action="create" directory="#getDirectoryFromPath(destfile)#" mode="774" />
				</cfif>

				<cfset timestamp = application.fapi.dateToISO8601(Now()) />
				<cfset stHeaders = { "x-amz-content-sha256" = "UNSIGNED-PAYLOAD" } />

				<cfif left(arguments.source_file,1) neq "/">
					<cfset urlPath = arguments.source_config.pathPrefix & "/" & arguments.source_file />
				<cfelse>
					<cfset urlPath = arguments.source_config.pathPrefix & arguments.source_file />
				</cfif>

				<cfif left(arguments.source_file,2) eq "//">
					<!--- already a fully qualified URL: fetch as-is (legacy passthrough) --->
					<cfset sourcefile = getURLPath(config=arguments.source_config,file=arguments.source_file,protocol="https") />
					<cfhttp url="#sourceFile#" method="get" path="#getDirectoryFromPath(destfile)#" file="#getFileFromPath(destfile)#" getAsBinary="yes" timeout="300" result="stResponse" />
				<cfelse>
					<!--- resolve active credentials; sign and send the security token when temporary --->
					<cfset stConfig = resolveSigningConfig(arguments.source_config) />
					<cfif len(stConfig.sessionToken)>
						<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
					</cfif>

					<!--- create signature --->
					<cfset authArgs = {
						config=stConfig,
						timestamp=timestamp,
						method="GET",
						path=arguments.source_config.apiEndpointPrefix & urlPath,
						headers=stHeaders,
						unsignedPayload=true,
						s3Path=true
					} />
					<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

					<cfhttp url="https://#arguments.source_config.apiEndpoint##arguments.source_config.apiEndpointPrefix##urlPath#" method="get" path="#getDirectoryFromPath(destfile)#" file="#getFileFromPath(destfile)#" getAsBinary="yes" timeout="300" result="stResponse">
						<cfhttpparam type="header" name="Date" value="#timestamp#" />
						<cfhttpparam type="header" name="Authorization" value="#signature#" />
						<cfloop collection="#stHeaders#" item="i">
							<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
						</cfloop>
					</cfhttp>
				</cfif>

				<!--- never persist or cache a non-success body (e.g. an S3 error XML) --->
				<cfif NOT listFindNoCase("200,204",listfirst(stResponse.statuscode," "))>
					<cfif fileExists(destfile)>
						<cftry>
							<cfif getFileInfo(destfile).size lte 65536>
								<cffile action="read" file="#destfile#" variable="errorBody" />
							</cfif>
							<cffile action="delete" file="#destfile#" />
							<cfcatch></cfcatch>
						</cftry>
					</cfif>
					<cfset substituteValues = arrayNew(1)>
					<cfset substituteValues[1] = stResponse.statuscode>
					<cfset substituteValues[2] = sanitiseS3URL(urlPath)>
					<cfset application.fapi.throw(message="Error reading S3 object: {1} {2}",type="s3error",detail=errorBody,substituteValues=substituteValues) />
				</cfif>

				<cfif arguments.source_config.localCacheSize>
					<cfset tmpfile = getTemporaryFile(config=arguments.source_config,file=arguments.source_file) />
					<cffile action="copy" source="#destfile#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
					<cfset addCachedFile(config=arguments.source_config,file=arguments.source_file,path=tmpfile) />
				</cfif>
				
				<cfset application.fapi.logEvent("cdn", "debug", "copied from S3", {bucket=arguments.source_config.name, url=sanitiseS3URL(arguments.source_file), desturl=sanitiseS3URL(destfile), source="s3"}) />
				
			</cfif>
			
		<cfelseif structkeyexists(arguments,"dest_config")>
			<cfif not ioDirectoryExists(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file))>
				<cfset ioCreateDirectory(config=arguments.dest_config,dir=getDirectoryFromPath(arguments.dest_file)) />
			</cfif>
			
			<cftry>
				<cfset putObject(config=arguments.dest_config,file=dest_file,localfile=arguments.source_localpath) />
				<cfset updateACL(config=arguments.dest_config,file=dest_file) />
				
				<cfcatch>
					<cfset application.fapi.logEvent("cdn", "error", "copy failed", {url=sanitiseS3URL(arguments.source_localpath), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.source_file), error=cfcatch.message}) />
					<cfrethrow>
				</cfcatch>
			</cftry>

			<cfif arguments.dest_config.localCacheSize>
				<cfset tmpfile = getTemporaryFile(config=arguments.dest_config,file=arguments.dest_file) />
				<cffile action="copy" source="#arguments.source_localpath#" destination="#tmpfile#" mode="664" nameconflict="overwrite" />
				<cfset addCachedFile(config=arguments.dest_config,file=arguments.dest_file,path=tmpfile) />
			</cfif>
			
			<cfset application.fapi.logEvent("cdn", "debug", "copied", {url=sanitiseS3URL(arguments.source_localpath), destbucket=arguments.dest_config.name, desturl=sanitiseS3URL(arguments.dest_file)}) />
			
		</cfif>
	</cffunction>
	
	<cffunction name="ioDeleteFile" returntype="void" output="false" hint="Deletes the specified file. Does not check that the file exists first.">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />
		
		<cfset deleteObject(argumentCollection=arguments) />
		
		<cfif arguments.config.localCacheSize>
			<cfset removeCachedFile(config=arguments.config,file=arguments.file) />
		</cfif>
		
		<cfset application.fapi.logEvent("cdn", "debug", "deleted", {bucket=arguments.config.name, url=sanitiseS3URL(arguments.file)}) />
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
		<cfargument name="listinfo" type="string" required="false" default="name" hint="name or all" />
		
		<cfset var qDir = "" />
		<cfset var s3path = "" />

		<!--- temporary credentials cannot use the native s3:// VFS; list via the REST API instead --->
		<cfif isTemporaryCredential(arguments.config)>
			<cfreturn listObjects(config=arguments.config, dir=arguments.dir) />
		</cfif>

		<cfset s3path = getS3Path(config=arguments.config,file=arguments.dir) />

		<cfif not directoryExists(s3Path)>
			<cfreturn querynew("file") />
		</cfif>

		<cfdirectory action="list" directory="#s3path#" recurse="true" type="file" listinfo="#arguments.listinfo#" name="qDir" sort="name" />
		
		<cfif arguments.listinfo EQ "name">
			<cfset QueryAddColumn( qDir, "file", [])>
			<cfloop query="qDir">
				<cfset querysetcell(qDir,"file","/" & qDir.name, qDir.CurrentRow) />
			</cfloop>
		</cfif>
		
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
		<cfset var timestamp = application.fapi.dateToISO8601(Now()) />
		<cfset var cfhttp = "" />
		<cfset var results = "" />
		<cfset var path = "" />
		<cfset var stDetail = structNew() />
		<cfset var substituteValues = arrayNew(1) />
		<cfset var authArgs = {} />


		<cfif structkeyexists(arguments,"localfile")>
			<cfset arguments.data = fileReadBinary(arguments.localfile) />
		</cfif>
		
		<cfif left(arguments.file,1) neq "/">
			<cfset path = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset path = arguments.config.pathPrefix & arguments.file />
		</cfif>
		
		<!--- add ACL --->
		<cfif arguments.config.setACL>
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
		</cfif>
		
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

		<cfset stHeaders["x-amz-content-sha256"] = "UNSIGNED-PAYLOAD" />

		<!--- resolve active credentials; sign and send the security token when temporary --->
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfif len(stConfig.sessionToken)>
			<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>

		<!--- create signature --->
		<cfset authArgs = {
			config=stConfig,
			timestamp=timestamp,
			method="PUT",
			path=arguments.config.apiEndpointPrefix & path,
			headers=stHeaders,
			unsignedPayload=true,
			s3Path=true
		} />
		<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

		<!--- REST call --->
		<cfhttp method="PUT" url="https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#" charset="utf-8" result="cfhttp" timeout="1800">
			<!--- Amazon Global Headers --->
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="#signature#" />
			
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
				<cfset substituteValues[2] = sanitiseCanonicalRequest(getCanonicalRequest(argumentCollection=authArgs))>
				<cfset substituteValues[3] = signature>
				<cfset application.fapi.throw(message="Error accessing S3 API: {1} [canonical request={2}, signature={3}]",type="s3error",detail=serializeJSON(stDetail),substituteValues=substituteValues) />
			</cfif>
		<cfelseif NOT listFindNoCase("200,204",listfirst(cfhttp.statuscode," "))>
			<cfset substituteValues = arrayNew(1)>
			<cfset substituteValues[1] = cfhttp.statuscode>
			<cfset substituteValues[2] = "https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#">
			<cfset application.fapi.throw(message="Error accessing S3 API: {1} {2}",type="s3error",detail=cfhttp.filecontent,substituteValues=substituteValues) />
		</cfif>
	</cffunction>

	<cffunction name="putACL" access="public" output="false" returntype="string" hint="Uses the S3 rest API to update an object's ACL">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfset var stHeaders = structnew() />
		<cfset var i = 0 />
		<cfset var sortedAMZ = "" />
		<cfset var amz = "" />
		<cfset var signature = "" />
		<cfset var timestamp = application.fapi.dateToISO8601(Now()) />
		<cfset var cfhttp = "" />
		<cfset var results = "" />
		<cfset var path = "" />
		<cfset var stDetail = structNew() />
		<cfset var substituteValues = arrayNew(1) />
		<cfset var header = "" />
		<cfset var authArgs = {} />

		<cfif left(arguments.file,1) neq "/">
			<cfset path = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset path = arguments.config.pathPrefix & arguments.file />
		</cfif>

		<!--- add ACL --->
		<cfloop from="1" to="#arraylen(arguments.config.acl)#" index="i">
			<cfif arguments.config.acl[i].permission eq "read">
				<cfset header = "x-amz-grant-read" />
			<cfelseif arguments.config.acl[i].permission eq "full_control">
				<cfset header = "x-amz-grant-full-control" />
			</cfif>
			<cfif NOT structKeyExists(stHeaders, header)>
				<cfset stHeaders[header] = "" />
			</cfif>
			<cfif isvalid("email",arguments.config.acl[i])>
				<cfset stHeaders[header] = listappend(stHeaders[header],'emailAddress="#arguments.config.acl[i]#"',', ') />
			<cfelseif isstruct(arguments.config.acl[i]) and structKeyExists(arguments.config.acl[i], "id")>
				<cfset stHeaders[header] = listappend(stHeaders[header],'id="#arguments.config.acl[i].id#"',', ') />
			<cfelseif isStruct(arguments.config.acl[i]) and structKeyExists(arguments.config.acl[i], "group") and arguments.config.acl[i].group eq "all">
				<cfset stHeaders[header] = listAppend(stHeaders[header],'uri=http://acs.amazonaws.com/groups/global/AllUsers') />
			<cfelseif isSimpleValue(arguments.config.acl[i])>
				<cfset stHeaders[header] = listappend(stHeaders[header],'id="#arguments.config.acl[i]#"',', ') />
			</cfif>
		</cfloop>

		<cfset stHeaders["x-amz-content-sha256"] = "UNSIGNED-PAYLOAD" />

		<!--- resolve active credentials; sign and send the security token when temporary --->
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfif len(stConfig.sessionToken)>
			<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>

		<!--- create signature --->
		<cfset authArgs = {
			config=stConfig,
			timestamp=timestamp,
			method="PUT",
			path=arguments.config.apiEndpointPrefix & path,
			queryParams={
				"acl"=""
			},
			headers=stHeaders,
			unsignedPayload=true,
			s3Path=true
		} />
		<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

		<!--- REST call --->
		<cfhttp method="PUT" url="https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#?acl" charset="utf-8" result="cfhttp" timeout="30">
			<!--- Amazon Global Headers --->
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="#signature#" />

			<!--- Headers --->
			<cfloop collection="#stHeaders#" item="i">
				<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
			</cfloop>
		</cfhttp>

		<!--- check XML parsing --->
		<cfif isXML(cfhttp.fileContent)>
			<cfset results = XMLParse(cfhttp.fileContent) />

			<!--- check for errors --->
			<cfif structkeyexists(results,"error")>
				<!--- check error xml --->
				<cfset stDetail = structNew()>
				<cfset stDetail["signature"] = replace(signature, chr(10), "\n", "ALL")>
				<cfset stDetail["result"] = results>
				<cfset substituteValues = arrayNew(1)>
				<cfset substituteValues[1] = results.error.message.XMLText>
				<cfset substituteValues[2] = sanitiseCanonicalRequest(getCanonicalRequest(argumentCollection=authArgs))>
				<cfset substituteValues[3] = signature>
				<cfset application.fapi.throw(message="Error accessing S3 API: {1} [canonical request: {2}, signature={3}]",type="s3error",detail=serializeJSON(stDetail),substituteValues=substituteValues) />
			</cfif>
		<cfelseif NOT listFindNoCase("200,204",listfirst(cfhttp.statuscode," "))>
			<cfset substituteValues = arrayNew(1)>
			<cfset substituteValues[1] = cfhttp.statuscode>
			<cfset substituteValues[2] = "https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#">
			<cfset application.fapi.throw(message="Error accessing S3 API: {1} {2}",type="s3error",detail=cfhttp.filecontent,substituteValues=substituteValues) />
		</cfif>
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="string" hint="Uses the S3 rest API to delete an object's ACL">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfset var signature = "" />
		<cfset var timestamp = GetHTTPTimeString(Now()) />
		<cfset var cfhttp = "" />
		<cfset var results = "" />
		<cfset var path = "" />
		<cfset var stDetail = structNew() />
		<cfset var substituteValues = arrayNew(1) />
		<cfset var header = "" />
		<cfset var timestamp = application.fapi.dateToISO8601(Now()) />
		<cfset var stHeaders = {
			"x-amz-content-sha256" = "UNSIGNED-PAYLOAD"
		} />
		<cfset var authArgs = {} />

		<cfif left(arguments.file,1) neq "/">
			<cfset path = arguments.config.pathPrefix & "/" & arguments.file />
		<cfelse>
			<cfset path = arguments.config.pathPrefix & arguments.file />
		</cfif>

		<!--- resolve active credentials; sign and send the security token when temporary --->
		<cfset var stConfig = resolveSigningConfig(arguments.config) />
		<cfif len(stConfig.sessionToken)>
			<cfset stHeaders["x-amz-security-token"] = stConfig.sessionToken />
		</cfif>

		<!--- create signature --->
		<cfset authArgs = {
			config=stConfig,
			timestamp=timestamp,
			method="DELETE",
			path=arguments.config.apiEndpointPrefix & path,
			headers=stHeaders,
			unsignedPayload=true,
			s3Path=true
		} />
		<cfset signature = getAWSAuthorization(argumentCollection=authArgs) />

		<!--- REST call --->
		<cfhttp method="DELETE" url="https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#" result="cfhttp" timeout="30">
			<!--- Amazon Global Headers --->
			<cfhttpparam type="header" name="Date" value="#timestamp#" />
			<cfhttpparam type="header" name="Authorization" value="#signature#" />

			<!--- Headers --->
			<cfloop collection="#stHeaders#" item="i">
				<cfhttpparam type="header" name="#i#" value="#stHeaders[i]#" />
			</cfloop>
		</cfhttp>

		<!--- check XML parsing --->
		<cfif isXML(cfhttp.fileContent)>
			<cfset results = XMLParse(cfhttp.fileContent) />

			<!--- check for errors --->
			<cfif structkeyexists(results,"error")>
				<!--- check error xml --->
				<cfset stDetail = structNew()>
				<cfset stDetail["signature"] = replace(signature, chr(10), "\n", "ALL")>
				<cfset stDetail["result"] = results>
				<cfset substituteValues = arrayNew(1)>
				<cfset substituteValues[1] = results.error.message.XMLText>
				<cfset substituteValues[2] = sanitiseCanonicalRequest(getCanonicalRequest(argumentCollection=authArgs))>
				<cfset substituteValues[3] = signature>
				<cfset application.fapi.throw(message="Error accessing S3 API: {1} [canonical request: {2}, signature={3}]",type="s3error",detail=serializeJSON(stDetail),substituteValues=substituteValues) />
			</cfif>
		<cfelseif NOT listFindNoCase("200,204",listfirst(cfhttp.statuscode," "))>
			<cfset substituteValues = arrayNew(1)>
			<cfset substituteValues[1] = cfhttp.statuscode>
			<cfset substituteValues[2] = "https://#arguments.config.apiEndpoint##arguments.config.apiEndpointPrefix##path#">
			<cfset application.fapi.throw(message="Error accessing S3 API: {1} {2}",type="s3error",detail=cfhttp.filecontent,substituteValues=substituteValues) />
		</cfif>
	</cffunction>

	<cffunction name="updateACL" access="public" output="false" returntype="void">
		<cfargument name="config" type="struct" required="true" />
		<cfargument name="file" type="string" required="true" />

		<cfif arrayLen(arguments.config.acl) AND arguments.config.setACL>
			<cfset putACL(config=arguments.config, file=arguments.file) />
		</cfif>
	</cffunction>

	<cffunction name="sanitiseCanonicalRequest" access="public" output="false" returntype="string" hint="Masks the x-amz-security-token header value in a canonical-request string before it is embedded in error output, so a temporary session token never leaks into logs.">
		<cfargument name="canonicalRequest" type="string" required="true" />
		<cfreturn reReplaceNoCase(arguments.canonicalRequest, "(x-amz-security-token:)[^" & chr(10) & "]*", "\1STRIPPEDSESSIONTOKEN", "all") />
	</cffunction>

	<cffunction name="sanitiseS3URL" access="public" output="false" returntype="string">
		<cfargument name="s3URL" type="string" required="true" />

		<cfset var result = reReplace(arguments.s3URL, "(s3:\/\/)(.*?:.*?)(@.*)", "\1STRIPPEDACCESSKEYID:STRIPPEDAWSSECRETKEY\3")>

		<cfreturn result />
	</cffunction>

	<cffunction name="sanitiseS3Config" access="public" output="false" returntype="struct">
		<cfargument name="config" type="struct" required="true" />

		<cfset var stResult = duplicate(arguments.config)>

		<cfif structKeyExists(stResult, "accessKeyId")>
			<cfset stResult.accessKeyId = "STRIPPEDACCESSKEYID">			
		</cfif>
		<cfif structKeyExists(stResult, "awsSecretKey")>
			<cfset stResult.awsSecretKey = "STRIPPEDAWSSECRETKEY">
		</cfif>
		<cfif structKeyExists(stResult, "sessionToken") and len(stResult.sessionToken)>
			<cfset stResult.sessionToken = "STRIPPEDSESSIONTOKEN">
		</cfif>

		<cfreturn stResult />
	</cffunction>

</cfcomponent>

