<cfcomponent hint="Post processing functionality" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="any">
	
		<cfset this.regexpatterns = structnew() />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="apply" access="public" output="false" returntype="string" hint="Applies a list of post-processing functions">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="functions" type="string" required="true" />
		
		<cfset var thisprocess = "" />
		<cfset var thisfunction = "" />
		<cfset var thislib = "" />
		<cfset var thisarg = "" />
		<cfset var output = arguments.input />
		<cfset var starttime = 0 />
		<cfset var theseargs	= '' />
		
		<cfloop list="#arguments.functions#" delimiters=";" index="thisprocess">
			<cfif refind("^\w+(\.\w+)?(\((\w+=\w+,?)*\))?$",thisprocess)>
				<cfset starttime = getTickCount() />
				<cfset thisfunction = listfirst(thisprocess,"(") />
				<cfset thislib = "postprocess" />
				<cfset theseargs = "" />
				
				<!--- figure out if the post-processing function is in a different lib --->
				<cfif listlen(thisfunction,".") eq 2>
					<cfset thislib = listfirst(thisfunction,".") />
					<cfset thisfunction = listlast(thisfunction,".") />
				</cfif>
				
				<!--- parse out args --->
				<cfif refind("\([^\)]",thisprocess)>
					<cfset theseargs = mid( thisprocess, find("(",thisprocess)+1, find(")",thisprocess)-find("(",thisprocess)-1 ) />
				</cfif>
				
				<cftry>
					<cfinvoke component="#application.fc.lib[thislib]#" method="#thisfunction#" returnvariable="output">
						<cfinvokeargument name="input" value="#output#" />
						<cfloop list="#theseargs#" index="thisarg">
							<cfinvokeargument name="#listfirst(thisarg,'=')#" value="#listrest(thisarg,'=')#" />
						</cfloop>
					</cfinvoke>
					
					<!--- add debug information --->
					<cfif isdefined("request.mode.debug") and request.mode.debug>
						<cfset output = output & "<!-- Applied post-process command: #thisprocess# [#getTickCount()-starttime#ms] -->" />
					</cfif>
					
					<cfcatch>
						<!--- only rethrow in debug mode --->
						<cfif isdefined("request.mode.debug") and request.mode.debug>
							<cfrethrow />
						</cfif>
					</cfcatch>
				</cftry>
			<cfelseif isdefined("request.mode.debug") and request.mode.debug>
				<cfset output = output & "<!-- Invalid post-process command: #thisprocess# -->" />
			</cfif>
		</cfloop>
		
		<cfreturn output />
	</cffunction>
	
	<cffunction name="regexMatch" access="public" output="false" returntype="array" hint="Creates a Java regular expression match object">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="search" type="string" required="true" />
		
		<cfset var patternhash = hash(arguments.search) />
		<cfset var matcher = "" />
		<cfset var i = 0 />
		<cfset var aResult = arraynew(1) />
		<cfset var aMatches = arraynew(1) />
		<cfset var stMatch = structnew() />
		<cfset var stLocal = structnew() />
		
		<cfif not structkeyexists(this.regexpatterns,patternhash)>
			<cfset this.regexpatterns[patternhash] = createObject("java", "java.util.regex.Pattern").compile( javaCast( "string", arguments.search ) ) />
		</cfif>
		
		<cfset matcher = this.regexpatterns[patternhash].matcher( javaCast( "string", arguments.input ) ) />
		
		<cfloop condition="matcher.find()">
			<cfset aMatches = arraynew(1) />
			
			<cfset stMatch = structnew() />
			<cfset stMatch.value = matcher.group() />
			<cfset stMatch.pos   = matcher.start()+1 />
			<cfset stMatch.end   = matcher.end()+1 />
			<cfset stMatch.len   = stMatch.end - stMatch.pos />
			<cfset arrayappend(aMatches,stMatch) />
			
			<cfloop from="0" to="#matcher.groupCount()-1#" index="i">
				<cfset stMatch = structnew() />
				<cfset stMatch.value = matcher.group( javaCast( "int", i+1 ) ) />
				<cfset stMatch.pos   = matcher.start( javaCast( "int", i+1 ) ) + 1 />
				<cfset stMatch.end   = matcher.end( javaCast( "int", i+1 ) ) + 1 />
				<cfset stMatch.len   = stMatch.end - stMatch.pos />
				<cfset arrayappend(aMatches,stMatch) />
			</cfloop>
			<cfset arrayappend(aResult,aMatches) />
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="regexReplace" access="public" output="false" returntype="string" hint="Uses Java regular expressions to replace">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="search" type="string" required="true" />
		<cfargument name="replace" type="string" required="true" />
		
		<cfset var patternhash = hash(arguments.search) />
		<cfset var matcher = "" />
		
		<cfif not structkeyexists(this.regexpatterns,patternhash)>
			<cfset this.regexpatterns[patternhash] = createObject("java", "java.util.regex.Pattern").compile( javaCast( "string", arguments.search ) ) />
		</cfif>
		
		<cfreturn this.regexpatterns[patternhash].matcher( javaCast( "string", arguments.input ) ).replaceAll( javaCast( "string", arguments.replace ) ) />
	</cffunction>
	
	
	
	<cffunction name="youtube" access="public" output="false" returntype="string" hint="Parses out youtube links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="560" />
		<cfargument name="height" type="numeric" required="false" default="315" />
		
		<cfset var replacement = '<iframe width="#arguments.width#" height="#arguments.height#" src="$2://www.youtube.com/embed/$4?wmode=transparent" frameborder="0" allowfullscreen></iframe>' />
		
		<!--- HTTP --->
		<!---  1. http://www.youtube.com/watch?v=yLeNvCJbM90&version=3&hl=en_US&rel=0 --->
		<!---  2. http://youtu.be/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  3. http://www.youtube.com/v/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  4. http://www.youtube.com/watch?v=x-rG8p7-A74  --->
		<!---  5. http://www.youtube.com/watch?v=_SkcrPsLc1M --->
		<!--- HTTPS --->
		<!---  6. https://www.youtube.com/watch?v=yLeNvCJbM90&version=3&hl=en_US&rel=0 --->
		<!---  7. https://youtu.be/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  8. https://www.youtube.com/v/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  9. https://www.youtube.com/watch?v=x-rG8p7-A74  --->
		<!--- 10. https://www.youtube.com/watch?v=_SkcrPsLc1M --->
		
		<!--- This regex matches URLs similar to test case 1,4,5,6,9,10 --->
		<cfset arguments.input = regexReplace(arguments.input,"(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?(http|https):\/\/(?:www\.)?(youtube\.com\/watch\?v=)([\w-_]+)[^\s]*?(?:</a>)?\s*(</p>|<br ?/?>|$|\n)",replacement) />
		
		<!--- This regex matches URLs similar to test cases 2,3,7,8 --->
		<cfset arguments.input = regexReplace(arguments.input,"(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?(http|https):\/\/(?:www\.)?(youtube\.com\/v\/|youtu\.be\/)\s*([\w-_]+)[^\s]*(</p>|<br ?/?>|$|\n)",replacement) />
		
		<cfreturn arguments.input />
	</cffunction>
	
	<cffunction name="vimeo" access="public" output="false" returntype="string" hint="Parses out vimeo links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="500" />
		<cfargument name="height" type="numeric" required="false" default="281" />
		
		<cfset var replacement = '<iframe src="$2://player.vimeo.com/video/$3" width="#arguments.width#" height="#arguments.height#" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>' />
		
		<!--- 1. http://vimeo.com/50351080 --->
		<!--- 2. https://vimeo.com/50351080 --->
		
		<!--- This regex matches URLs similar to test case 1 --->
		<cfset arguments.input = regexReplace(arguments.input,"(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?(http|https):\/\/vimeo\.com\/(\w+)[^\s]*?(?:</a>)?\s*(</p>|<br ?/?>|$|\n)",replacement) />
		
		<cfreturn arguments.input />
	</cffunction>
	
	<cffunction name="twitter" access="public" output="false" returntype="string" hint="Parses out twitter status links and uses the twitter api to replace them with embeds">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var aMatches = "" />
		<cfset var i = 0 />
		<cfset var offset = 0 />
		<cfset var stResult = "" />
		
		<cfparam name="this.twitterstatus" default="#structnew()#" />
		
		<!--- 1. https://twitter.com/twitterapi/statuses/133640144317198338 --->
		<!--- 2. https://twitter.com/twitterapi/status/133640144317198338 --->
		
		<!--- This regex matches URLs similar to test cases 1 and 2 --->
		<cfset aMatches = regexMatch(arguments.input,"(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?https?:\/\/twitter\.com\/(\w+)/status(?:es)?/(\w+)(?:</a>)?\s*(</p>|<br ?/?>|$|\n)") />
		
		<cfloop from="1" to="#arraylen(aMatches)#" index="i">
			<cfif not structkeyexists(this.twitterstatus,hash(aMatches[i][4].value))>
				<cfhttp url="https://api.twitter.com/1/statuses/oembed.json?id=#aMatches[i][4].value#&align=center" result="stResult" />
				<cfset stResult = deserializejson(stResult.filecontent) />
				<cfif structkeyexists(stResult,"errors")>
					<cfset this.twitterstatus[aMatches[i][4].value] = "<a href='https://twitter.com/#aMatches[i][3].value#/status/#aMatches[1][4].value#'>https://twitter.com/#aMatches[i][3].value#/status/#aMatches[1][4].value#</a><!-- #stResult.errors[1].message#: https://api.twitter.com/1/statuses/oembed.json?id=#aMatches[i][4].value#&align=center -->" />
				<cfelse>
					<cfset this.twitterstatus[aMatches[i][4].value] = unescapeUnicode(stResult.html) />
				</cfif>
			</cfif>
			<cfset arguments.input = left(arguments.input,aMatches[i][1].pos+offset-1) & this.twitterstatus[aMatches[i][4].value] & mid(arguments.input,aMatches[i][1].end+offset,len(arguments.input)) />
			<cfset offset = offset + len(this.twitterstatus[aMatches[i][4].value]) - aMatches[i][1].len />
		</cfloop>
		
		<cfreturn arguments.input />
	</cffunction>
	
	<cffunction name="gist" access="public" output="false" returntype="string" hint="Parses out gist links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var replacement = '<script src="$2.js"> </script>' />
		
		<!--- 1. https://gist.github.com/1018281 --->
		
		<!--- This regex matches URLs similar to test case 1 --->
		<cfset arguments.input = regexReplace(arguments.input,"(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?(https:\/\/gist\.github\.com(\/\w+)+)(?:</a>)?\s*(</p>|<br ?/?>|$|\n)",replacement) />
		
		<cfreturn arguments.input />
	</cffunction>
	
	<cffunction name="removewhitespace" access="public" output="false" returntype="string" hint="Replace all consecutive spaces with one space">
		<cfargument name="input" type="string" required="true" />
		
		<cfreturn rereplace(arguments.input,"(\s)\s+","\1","ALL") />
	</cffunction>
	
	
	
	<cffunction name="unescapeUnicode" access="public" output="false" returntype="string" hint="Replaces unicode escape sequences with actual characters">
		<cfargument name="source" type="string" required="true" />
		
		<cfset var st = structnew() />
		
		<cfloop condition="structisempty(st) or arraylen(st.pos) gte 2">
			<cfset st = REFindNoCase("\\u([a-f0-9]{1,4})",arguments.source,1,true) />
			<cfif arraylen(st.pos) gte 2>
				<cfset arguments.source = mid(arguments.source,1,st.pos[1]-1) & chr(inputBaseN(mid(arguments.source,st.pos[2],st.len[2]),16)) & mid(arguments.source,st.pos[1]+st.len[1],10000) />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.source />
	</cffunction>
	
</cfcomponent>