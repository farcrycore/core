<cfcomponent hint="Post processing functionality" output="false">

	<cfset variables.regexLineStart = "(<p>|<br ?/?>|^|\n)\s*(?:<a [^>]+>)?">
	<cfset variables.regexLineEnd = "(?:</a>)?\s*(</p>|<br ?/?>|$|\n)">

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
	
	<cffunction name="regexLineMatch" access="public" output="false" returntype="array" hint="Creates a Java regular expression match object">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="search" type="string" required="true" />
		
		<cfreturn regexMatch(arguments.input, variables.regexLineStart & arguments.search & variables.regexLineEnd) />
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

	<cffunction name="regexLineReplace" access="public" output="false" returntype="string" hint="Uses Java regular expressions to replace">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="search" type="string" required="true" />
		<cfargument name="replace" type="string" required="true" />
			
		<cfreturn regexReplace(arguments.input, variables.regexLineStart & arguments.search & variables.regexLineEnd, arguments.replace) />
	</cffunction>	


	<cffunction name="youtube" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out youtube links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="560" />
		<cfargument name="height" type="numeric" required="false" default="315" />
		
		<cfset var replacement = '<iframe width="#arguments.width#" height="#arguments.height#" src="$2://www.youtube.com/embed/$4?wmode=transparent" frameborder="0" allowfullscreen></iframe>' />

		<!---  http://www.youtube.com/watch?v=yLeNvCJbM90&version=3&hl=en_US&rel=0 --->
		<!---  https://www.youtube.com/watch?v=yLeNvCJbM90&version=3&hl=en_US&rel=0 --->
		<!---  http://www.youtube.com/watch?v=x-rG8p7-A74  --->
		<!---  https://www.youtube.com/watch?v=x-rG8p7-A74  --->
		<!---  http://www.youtube.com/watch?v=_SkcrPsLc1M --->
		<!---  https://www.youtube.com/watch?v=_SkcrPsLc1M --->
		<cfset var match1 = "(http|https):\/\/(?:www\.)?(youtube\.com\/watch\?v=)([-\w_]+)[^\s]*?">

		<!---  http://www.youtube.com/v/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  https://www.youtube.com/v/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  http://youtu.be/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<!---  https://youtu.be/yLeNvCJbM90?version=3&hl=en_US&rel=0 --->
		<cfset var match2 = "(http|https):\/\/(?:www\.)?(youtube\.com\/v\/|youtu\.be\/)\s*([-\w_]+)[^\s]*">
		
		<!--- match1 --->
		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement) />
		<!--- match2 --->
		<cfset arguments.input = regexLineReplace(arguments.input, match2, replacement) />
		
		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="vimeo" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out vimeo links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="500" />
		<cfargument name="height" type="numeric" required="false" default="281" />
		
		<cfset var replacement = '<iframe src="$2://player.vimeo.com/video/$3" width="#arguments.width#" height="#arguments.height#" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>' />
		
		<!--- http://vimeo.com/50351080 --->
		<!--- https://vimeo.com/50351080 --->
		<cfset var match1 = "(http|https):\/\/vimeo\.com\/(\w+)[^\s]*?">
		
		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement) />
		
		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="twitter" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out twitter status links and uses the twitter api to replace them with embeds">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var aMatches = "" />
		<cfset var i = 0 />
		<cfset var offset = 0 />
		<cfset var stResult = "" />

		<!--- https://twitter.com/twitterapi/statuses/133640144317198338 --->
		<!--- https://twitter.com/twitterapi/status/133640144317198338 --->
		<cfset var match1 = "https?:\/\/twitter\.com\/(\w+)/status(?:es)?/(\w+)">

		<cfset aMatches = regexLineMatch(arguments.input, match1) />
		
		<cfparam name="this.twitterstatus" default="#structnew()#" />
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


	<cffunction name="gist" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out gist links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var replacement = '<script src="$2.js"> </script>' />

		<!--- https://gist.github.com/1018281 --->
		<cfset var match1 = "(https:\/\/gist\.github\.com(\/\w+)+)" />

		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement) />
		
		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="vine" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out vine links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="500" />
		<!--- <cfargument name="height" type="numeric" required="false" default="500" /> --->
		<cfargument name="type" type="string" required="false" default="simple" hint="The embed style: simple, postcard" />

		<cfset var match1 = '' />
		<cfset var replacement = '' />

		<cfset var height = width>
		<cfif arguments.type eq "postcard">
			<cfset height = height + 89>
		</cfif>

		<cfset replacement = '<iframe class="vine-embed" src="$2/embed/#arguments.type#" width="#arguments.width#" height="#height#" frameborder="0"></iframe>' />

		<!--- https://vine.co/v/hBFxTlV36Tg --->
		<cfset match1 = "(https:\/\/vine\.co\/v\/\w+)" />

		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement) />
		
		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="polldaddy" access="public" output="false" returntype="string" postprocesser="true" hint="Inserts PollDaddy embed">
		<cfargument name="input" type="string" required="true">

		<!--- POLL: http://polldaddy.com/poll/8096287/ --->
		<cfset var match1 = "http:\/\/polldaddy\.com\/poll\/(\d+)+\/" />
		<cfset var replacement1 = '<script type="text/javascript" charset="utf-8" src="http://static.polldaddy.com/p/$2.js"></script><noscript><a href="http://polldaddy.com/poll/$2/">Take poll</a></noscript>' />

		<!--- SURVEY: http://blairdaemon.polldaddy.com/s/flang --->
		<!--- QUIZ: http://blairdaemon.polldaddy.com/s/guess --->
		<cfset var match2 = "http:\/\/([^\/]+\.polldaddy\.com\/s\/)([^\/]+)" />
		<cfset var replacement2 = "" />
		<cfset var tmpid = "pd" />

		<cfsavecontent variable="replacement2"><cfoutput>
			<div class="pd-embed" id="#tmpid#_$3"></div>
			<script type="text/javascript">
			  var _polldaddy = [] || _polldaddy;

			  _polldaddy.push( {
			    type: "iframe",
			    auto: "1",
			    domain: "$2",
			    id: "$3",
			    placeholder: "#tmpid#_$3"
			  } );

			  (function(d,c,j){if(!document.getElementById(j)){var pd=d.createElement(c),s;pd.id=j;pd.src='http://i0.poll.fm/survey.js';s=document.getElementsByTagName(c)[0];s.parentNode.insertBefore(pd,s);}}(document,'script','pd-embed'));
			</script>
		</cfoutput></cfsavecontent>

		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement1) />
		<cfset arguments.input = regexLineReplace(arguments.input, match2, replacement2) />

		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="storify" access="public" output="false" returntype="string" postprocesser="true" hint="Embed Storify articles">
		<cfargument name="input" type="string" required="true" />

		<!--- https://storify.com/blair123/vermicious-knids --->
		<cfset var match1 = "https?:(\/\/storify\.com\/[^\/]+\/[^\/]+)" />
		<cfset var replacement1 = '<div class="storify"><iframe src="$2/embed?border=false" width="100%" height=750 frameborder=no allowtransparency=true></iframe><script src="$2.js?border=false"></script><noscript>[<a href="$2" target="_blank">View the story on Storify</a>]</noscript></div>' />

		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement1) />

		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="googlecalendar" access="public" output="false" returntype="string" postprocesser="true" hint="Parses out google calendar links and replaces them with embeds">
		<cfargument name="input" type="string" required="true" />
		<cfargument name="width" type="numeric" required="false" default="600" />
		<cfargument name="height" type="numeric" required="false" default="400" />
		<cfargument name="firstDayOfWeek" type="numeric" required="false" default="2" hint="1:sundag,2:monday,7:saturday" />
		
		<!--- https://www.google.com/calendar/embed?src=no.norwegian%23holiday%40group.v.calendar.google.com&ctz=Europe/Oslo --->
		<!--- https://www.google.com/calendar/ical/no.norwegian%23holiday%40group.v.calendar.google.com/public/basic.ics --->
		<!--- https://www.google.com/calendar/feeds/no.norwegian%23holiday%40group.v.calendar.google.com/public/basic --->
		<!--- https://www.google.com/calendar/embed?src=kristiansund.com_g2ovp94q7bmqutlfh2f1m5auk4%40group.calendar.google.com&ctz=Europe/Oslo --->
		
		<cfset var replacement = '<iframe src="https://www.google.com/calendar/embed?height=#arguments.height#&amp;wkst=#arguments.firstDayOfWeek#&amp;src=$5" width="#arguments.width#" height="#arguments.height#" frameborder="0" scrolling="no"></iframe>' />
		
		<cfset var match1 = "(http|https)?:\/\/?(?:www\.)?(google\.com\/calendar\/(feeds\/|ical\/|embed\?src\=|htmlembed\?src\=))?([-_a-zA-Z0-9\.\%]+%40(group\.calendar\.google\.com|group\.v\.calendar\.google\.com))[^\s]*">
		<cfset arguments.input = regexLineReplace(arguments.input, match1, replacement) />
		
		<cfreturn arguments.input />
	</cffunction>


	<cffunction name="removewhitespace" access="public" output="false" returntype="string" hint="Replace all consecutive spaces with one space">
		<cfargument name="input" type="string" required="true" />
		
		<cfreturn rereplace(arguments.input,"(\s)\s+","\1","ALL") />
	</cffunction>

	<cffunction name="unescapeUnicode" access="public" output="false" returntype="string" hint="Replaces unicode escape sequences with actual characters">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var st = structnew() />
		
		<cfloop condition="structisempty(st) or arraylen(st.pos) gte 2">
			<cfset st = REFindNoCase("\\u([a-f0-9]{1,4})",arguments.input,1,true) />
			<cfif arraylen(st.pos) gte 2>
				<cfset arguments.input = mid(arguments.input,1,st.pos[1]-1) & chr(inputBaseN(mid(arguments.input,st.pos[2],st.len[2]),16)) & mid(arguments.input,st.pos[1]+st.len[1],10000) />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.input />
	</cffunction>

	<cffunction name="rewriteImages" access="public" output="false" returntype="string" postprocesser="true" hint="Updates /images src and links to point to the CDN URLs">
		<cfargument name="input" type="string" required="true" />
		
		<cfset var st = structnew() />
		
		<cfloop condition="structisempty(st) or arraylen(st.pos) gte 2">
			<cfset st = REFindNoCase("((?:src|href)=['""])(/images/[^'""]+)(['""])",arguments.input,1,true) />
			
			<cfif arraylen(st.pos) gte 2>
				<cfset arguments.input = mid(arguments.input,1,st.pos[1]-1) & mid(arguments.input,st.pos[2],st.len[2]) & application.fc.lib.cdn.ioGetFileLocation(location="images",file=mid(arguments.input,st.pos[3],st.len[3])).path & mid(arguments.input,st.pos[4],st.len[4]) & mid(arguments.input,st.pos[1]+st.len[1],10000) />
			</cfif>
		</cfloop>
		
		<cfreturn arguments.input />
	</cffunction>

</cfcomponent>