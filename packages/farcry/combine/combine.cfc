<cfcomponent displayname="Combine" output="false" hint="provides javascript and css file merge and compress functionality, to reduce the overhead caused by file sizes & multiple requests">
	
	<cffunction name="init" access="public" returntype="Combine" output="false">
		<cfargument name="enableCache" type="boolean" required="true" hint="When enabled, the content we generate by combining multiple files is stored locally, so we don't have to regenerate on each request." />
		<cfargument name="cachePath" type="string" required="true" hint="Where to store the local cache of combined files" />
		<cfargument name="enableETags" type="boolean" required="true" hint="Etags are a 'hash' which represents what is in the response. These allow the browser to perform conditional requests, i.e. only give me the content if your Etag is different to my Etag." />
		<cfargument name="enableJSMin" type="boolean" required="true" hint="compress JS using JSMin?" />
		<cfargument name="enableYuiCSS" type="boolean" required="true" hint="compress CSS using the YUI css compressor?" />
		<!--- optional args --->
		<cfargument name="outputSeperator" type="string" required="false" default="#chr(13)#" hint="seperates the output of different file content" />
		<cfargument name="skipMissingFiles" type="boolean" required="false" default="true" hint="skip files that don't exists? If false, non-existent files will cause an error" />
		<cfargument name="getFileModifiedMethod" type="string" required="false" default="java" hint="java or com. Which technique to use to get the last modified times for files." />
		<!--- experimental - use with care! You may want to tweak these values if your webserver has a caching layer that either causes problems, or adds potential performance gains. Disabling 304s will let the caching layer handle the caching according to its configuration. Setting cache-control to 'private' will bypass the caching layer and put the responsibility in the hands of Combine. --->
		<cfargument name="enable304s" type="boolean" required="false" default="true" hint="304 (not-modified) is returned when the request's etag matches the current response, so we return a 304 instead of the content, instructing the browser to use it's cache. A valid reason for disabling this would be if you have an effective caching layer on your web server, which handles 304s more efficiently. However, unlike Combine the caching layer will not check the modified state of each individual css/js file. Note that to enable 304s, you must also enable eTags." />
		<cfargument name="cacheControl" type="string" required="false" default="" hint="specify an optional cache-control header, which will be returned in each response. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html. An example use is to specify 'private' which will disable proxy caching, only allowing browser caching." />

		<cfscript>
		variables.sCachePath = arguments.cachePath;
		// enable caching
		variables.bCache = arguments.enableCache;
		// enable etags - browsers use this hash to decide if their cached version is up to date
		variables.bEtags = arguments.enableETags;
		// enable jsmin compression of javascript
		variables.bJsMin = arguments.enableJSMin;
		// enable yui css compression
		variables.bYuiCss = arguments.enableYuiCSS;
		// text used to delimit the merged files in the final output
		variables.sOutputDelimiter = arguments.outputSeperator;
		// skip files that don't exists? If false, non-existent files will cause an error
		variables.bSkipMissingFiles = arguments.skipMissingFiles;
		
		// configure the content-types that are returned
		variables.stContentTypes = structNew();
		variables.stContentTypes.css = 'text/css';
		variables.stContentTypes.js = 'application/javascript';
		
		// cache-control header
		variables.sCacheControl = arguments.cacheControl;
		// return 304s when conditional requests are made with matching Etags?
		variables.bEnable304s = arguments.enable304s;
		
		variables.jOutputStream = createObject("java","java.io.ByteArrayOutputStream");
		variables.jStringReader = createObject("java","java.io.StringReader");
		
		// If using jsMin, we need to load the required Java objects
		if(variables.bJsMin)
		{
			variables.jJSMin = createObject("java","com.magnoliabox.jsmin.JSMin");
		}
		// If using the YUI CSS Compressor, we need to load the required Java objects
		if(variables.bYuiCss)
		{
			variables.jStringWriter = createObject("java","java.io.StringWriter");
			variables.jYuiCssCompressor = createObject("java","com.yahoo.platform.yui.compressor.CssCompressor");
		}
		
		// determine which method to use for getting the file last modified dates
		if(arguments.getFileModifiedMethod eq 'com')
		{
			variables.fso = CreateObject("COM", "Scripting.FileSystemObject");
			// calls to getFileDateLastModified() are handled by getFileDateLastModified_com()
			variables.getFileDateLastModified = variables.getFileDateLastModified_com;
		}
		else
		{
			variables.jFile = CreateObject("java", "java.io.File");
			// calls to getFileDateLastModified() are handled by getFileDateLastModified_java()
			variables.getFileDateLastModified = variables.getFileDateLastModified_java;
		}
		</cfscript>		

		<cfif not directoryExists(variables.sCachePath)>
			<cfdirectory action="create" directory="#variables.sCachePath#" mode="777" />
		</cfif>
		
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="combine" access="public" returntype="string" output="false" hint="combines a list js or css files into a single file, which is output, and cached if caching is enabled. Returns the path to the cached file.">
		<cfargument name="id" type="string" required="false" default="noIDea" hint="an id that is used to prefix the combine file" />
		<cfargument name="files" type="string" required="true" hint="a delimited list of jss or css paths to combine" />
		<cfargument name="type" type="string" required="false" hint="js,css" />
		<cfargument name="delimiter" type="string" required="false" default="," hint="the delimiter used in the provided paths string" />
		<cfargument name="prepend" type="string" required="false" default="" hint="Content to be placed BEFORE all the included files" />
		<cfargument name="append" type="string" required="false" default="" hint="Content to be placed AFTER all the included files" />
				
		<cfscript>
		var sType = '';
		var lastModified = 0;
		var sFilePath = '';
		var sCorrectedFiles = '';
		var sExpandedFilePath = '';
		var i = 0;
		var sDelimiter = arguments.delimiter;
		
		var etag = '';
		var sCacheFile = '';
		var sCacheFileName = '';
		var sOutput = '';
		var fileDir = '';
		var sFileContent = '';
		
		var filePaths = convertToAbsolutePaths(files, delimiter);
		
		// determine what file type we are dealing with
		if( structkeyExists(arguments, 'type') )
		{
			sType = arguments.type;
		}
		else
		{
			sType = listLast( listFirst(filePaths, sDelimiter) , '.');
		}
		</cfscript>
		
		<!--- security check --->
		<!--- <cfif not listFindNoCase('js,css', sType)>
			<!--- don't go any further, we only return the contents of JS or CSS files! --->
			<cfheader statuscode="400" statustext="Bad Request">
			<cfreturn />
		</cfif> --->

		<!--- get the latest last modified date --->
		<cfset sCorrectedFiles = '' />
		<cfloop list="#arguments.files#" delimiters="#sDelimiter#" index="sFilePath">
			
			<cfset sExpandedFilePath = expandPath("#sFilePath#") />
			
			<!--- check it is a valid JS or CSS file. Don't allow mixed content (all JS or all CSS only) --->
			<cfif fileExists( sExpandedFilePath ) and (listLast(sExpandedFilePath, '.') eq sType OR listLast(sExpandedFilePath, '.') eq "cfm")>
			
				<cfset lastModified = numberformat(max(lastModified, getFileDateLastModified( sExpandedFilePath )),"999999999999999") />
				
				<cfset sCorrectedFiles = listAppend(sCorrectedFiles, sFilePath, sDelimiter) />
				
			<cfelseif not variables.bSkipMissingFiles>
				<cfthrow type="combine.missingFileException" message="A file specified in the combine (#sType#) path doesn't exist." detail="file: #sFilePath#" extendedinfo="full combine path list: #filePaths#" />
			</cfif>
			
		</cfloop>
		
		<!--- combine the file contents into 1 string --->
		<cfset sOutput = '' />
		<cfloop list="#arguments.files#" delimiters="#sDelimiter#" index="sFilePath">
		
			<cfset sExpandedFilePath = expandPath(sFilePath) />
		
			<cfif listLast(sFilePath,".") EQ "cfm">
				<cfsavecontent variable="sFileContent">
					<cfinclude template="#sFilePath#" />
				</cfsavecontent>
			<cfelse>
				<cffile action="read" variable="sFileContent" file="#sExpandedFilePath#" />
			</cfif>
			
			
			
			<!--- CHANGE URL PATHS IN CSS FILES --->
			<cfif sType EQ "CSS">
				
				<cfset fileDir = application.factory.oUtils.listSlice(sFilePath,1,-2,"/") />
				<cfset sFileContent = rereplace(rereplace(sFileContent,"url\(['""]?([^/""'][^'""\)]+)['""]?\)","url('#fileDir#/\1')","ALL"),"/[^/]+/\.\./","/","ALL") />
				
			 </cfif>
			 
			<cfset sOutput = sOutput & variables.sOutputDelimiter & sFileContent />
		</cfloop>
		
		<cfif len(trim(arguments.prepend))>
			<cfset sOutput = trim(arguments.prepend) & sOutput />
		</cfif>
		<cfif len(trim(arguments.append))>
			<cfset sOutput = sOutput & trim(arguments.append) />
		</cfif>
		<cftry>
		<cfscript>
		// 'Minify' the javascript with jsmin
		if(variables.bJsMin and sType eq 'js')
		{
			sOutput = compressJsWithJSMin(sOutput);
		}
		else if(variables.bYuiCss and sType eq 'css')
		{
			sOutput = compressCssWithYUI(sOutput);
		}
		
		//output contents
		//outputContent(sOutput, sType, variables.sCacheControl);
		</cfscript><cfcatch><cfdump var="#arguments#"><cfabort></cfcatch></cftry>
		
		<!--- create a string to be used as an Etag - in the response header --->
		<cfset etag = arguments.id & '-' & hash(sOutput) />
		
		<cfif variables.bCache>
			
			<!--- try to return a cached version of the file --->		
			<cfset sCacheFileName = etag & '.' & sType />
			<cfif application.fc.lib.cdn.ioFileExists(location="cache",file=sCacheFileName)>
				<cfreturn sCacheFileName />
			</cfif>
			
		</cfif>
		
		<!--- write the cache file and cleanup (delete) any older cache files --->
		<cfif variables.bCache>
			<cflock name="#application.applicationname#-#arguments.id#-write-combine" throwontimeout="false" timeout="2">
				<cfif application.fc.lib.cdn.getLocation("cache").cdn neq "local">
					<cfsetting requesttimeout="300">
					<cfset sOutput = moveCSSImages(sOutput) />
				</cfif>
				
				<cfset sCacheFileName = application.fc.lib.cdn.ioWriteFile(location="cache",file=sCacheFileName,data=sOutput) />
			</cflock>
		</cfif>
		
		<cfreturn sCacheFileName />
		
	</cffunction>
	
	<cffunction name="moveCSSImages" access="private" output="false" returntype="string">
		<cfargument name="css" type="string" required="true" />
		
		<cfset var st = structnew() />
		<cfset var imageURL = "" />
		<cfset var imagePath = "" />
		<cfset var newImagePath = "" />
		
		<cfloop condition="structisempty(st) or (arraylen(st.pos) and st.pos[1])">
			<cfset st = refindnocase("url\([""']?(/\w[^)""']+)[""']?\)",arguments.css,1,true) />
			
			<cfif arraylen(st.pos) and st.pos[1]>
				<cfset imageURL = mid(arguments.css,st.pos[2],st.len[2]) />
				<cfset imageURL = rereplace(imageURL,"/\w+/\.\.","","ALL") />
				<cfset imagePath = expandPath(imageURL) />
				
				<cfif fileexists(imagePath) and not application.fc.lib.cdn.ioFileExists(location="cache",file=imageURL)>
					<cfset imageURL = application.fc.lib.cdn.ioCopyFile(source_localpath=imagePath,dest_location="cache",dest_file=imageURL) />
				</cfif>
				
				<cfset arguments.css = left(arguments.css,st.pos[1]-1) & "url('" & mid(imageURL,2,len(imageURL)) & "')" & mid(arguments.css,st.pos[1]+st.len[1],len(arguments.css)) />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.css />
	</cffunction>
	
	<cffunction name="outputContent" access="private" returnType="void" output="true">
		<cfargument name="sOut" type="string" required="true" />
		<cfargument name="sType" type="string" required="true" />
		<cfargument name="sCacheControl" type="string" required="false" default="" />
		
		<!--- content-type (e.g. text/css) --->
		<cfcontent type="#variables.stContentTypes[arguments.sType]#">
		
		<!--- specific Cache-Control header? --->
		<cfif len(arguments.sCacheControl)>
			<cfheader name="Cache-Control" value="#arguments.sCacheControl#">
		</cfif>

		<cfoutput>#arguments.sOut#</cfoutput>
		
	</cffunction>
	
	
	<!--- uses 'Scripting.FileSystemObject' com object --->
	<cffunction name="getFileDateLastModified_com" access="private" returnType="string">
		<cfargument name="path" type="string" required="true" />
		<cfset var file = variables.fso.GetFile(arguments.path) />
		<cfreturn file.DateLastModified />
	</cffunction>
	<!--- uses 'java.io.file'. Recommended --->
	<cffunction name="getFileDateLastModified_java" access="private" returnType="string">
		<cfargument name="path" type="string" required="true" />
		<cfset var file = variables.jFile.init(arguments.path) />
		<cfreturn file.lastModified() />
	</cffunction>
	
	
	<cffunction name="compressJsWithJSMin" access="private" returnType="string" hint="takes a javascript string and returns a compressed version, using JSMin">
		<cfargument name="sInput" type="string" required="true" />
		<cfscript>
		var sOut = arguments.sInput;
			
		var joOutput = variables.jOutputStream.init();
		var joInput = variables.jStringReader.init(sOut);
		var joJSMin = variables.jJSMin.init(joInput, joOutput);
		
		joJSMin.jsmin();
		joInput.close();
		sOut = joOutput.toString();
		joOutput.close();
		
		return sOut;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="compressCssWithYUI" access="private" returnType="string" hint="takes a css string and returns a compressed version, using the YUI css compressor">
		<cfargument name="sInput" type="string" required="true" />
		<cfscript>
		var sOut = arguments.sInput;
			
		var joInput = variables.jStringReader.init(sOut);
		var joOutput = variables.jStringWriter.init();
		var joYUI = variables.jYuiCssCompressor.init(joInput);
		
		joYUI.compress(joOutput, javaCast('int',-1));
		joInput.close();
		sOut = joOutput.toString();
		joOutput.close();
		
		return sOut;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="convertToAbsolutePaths" access="private" returnType="string"output="false" hint="takes a list of relative paths and makes them absolute, using expandPath">
		<cfargument name="relativePaths" type="string" required="true" hint="delimited list of relative paths" />
		<cfargument name="delimiter" type="string" required="false" default="," hint="the delimiter used in the provided paths string" />
		
		<cfset var filePaths = '' />
		<cfset var path = '' />
		
		<cfloop list="#arguments.relativePaths#" delimiters="#arguments.delimiter#" index="path">
			<cfset filePaths = listAppend(filePaths, expandPath(path), arguments.delimiter) />
		</cfloop>

		<cfreturn filePaths />
		
	</cffunction>
	
</cfcomponent>
