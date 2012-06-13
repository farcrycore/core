<cfcomponent displayname="Error" hint="Error functions" output="false">

	<cfset variables.newline = "
" />
	
	<cffunction name="throw" access="public" returntype="void" output="false" hint="Provides similar functionality to the cfthrow tag but is automatically incorporated to use the resource bundles.">
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="errorcode" type="string" required="false" default="" />
		<cfargument name="detail" type="string" required="false" default="" />
		<cfargument name="extendedinfo" type="string" required="false" default="" />
		<cfargument name="object" type="object" required="false" />
		<cfargument name="type" type="string" required="false" default="" />
		
		<!--- Resource Bundle Options --->
		<cfargument name="key" type="string" required="false" default="" /><!--- Resource Bundle Key --->
		<cfargument name="locale" type="string" required="false" default="" /><!--- Locale --->		
		<cfargument name="substituteValues" type="array" required="false" default="#arrayNew(1)#" /><!--- Array of substitue values used by the resource bundle text --->
		
		<!--- This little chestnut will automatically setup the message and detail strings in the resource bundle and provide translations --->
		<cfif len(arguments.message)>
			<cfif not len(arguments.key)>
				<cfset arguments.key = "FAPI.throw.#rereplaceNoCase(arguments.message, '[^/w]+', '_', 'all')#" />
			</cfif>
			
			<cfset arguments.message = getResource(key="#arguments.key#@message", default=arguments.message, locale=arguments.locale, substituteValues=arguments.substituteValues) />
			
			<cfif len(arguments.detail)>
				<cfset arguments.detail = getResource(key="#arguments.key#@detail", default=arguments.detail, locale=arguments.locale, substituteValues=arguments.substituteValues) />
			</cfif>
		</cfif>
		
		<!--- THE FOLLOWING LIST PROVIDES THE DIFFERENT WAYS cfthrow CAN BE CALLED:
	 	Required attributes: 'type'. Optional attributes: 'detail,errorcode,extendedinfo,message'.
		Required attributes: 'message'. Optional attributes: 'detail,errorcode,extendedinfo'.
		Required attributes: 'extendedinfo'. Optional attributes: 'detail,errorcode'.
		Required attributes: 'errorcode'. Optional attributes: 'detail'.  
		Required attributes: 'detail'. Optional attributes: None.
		Required attributes: 'object'. Optional attributes: None.
		  --->
		
		<cfif len(arguments.type)>
			<cfthrow 
				type="#arguments.type#"
				message="#arguments.message#" 
				detail="#arguments.detail#" 
				errorcode="#arguments.errorcode#" 
				extendedinfo="#arguments.extendedinfo#"  
			 />
			
		<cfelseif len(arguments.message)>

			<cfthrow 
				message="#arguments.message#" 
				detail="#arguments.detail#" 
				errorcode="#arguments.errorcode#" 
				extendedinfo="#arguments.extendedinfo#"  
			 />			
		<cfelseif len(arguments.extendedinfo)>
			<cfthrow 
				extendedinfo="#arguments.extendedinfo#"
				detail="#arguments.detail#" 
				errorcode="#arguments.errorcode#" 
			 />				
		<cfelseif len(arguments.errorcode)>
			<cfthrow 
				errorcode="#arguments.errorcode#" 
				detail="#arguments.detail#" 
			 />				
		<cfelseif len(arguments.errorcode)>
			<cfthrow 
				errorcode="#arguments.errorcode#" 
				detail="#arguments.detail#" 
			 />			
		<cfelseif len(arguments.detail)>
			<cfthrow
				detail="#arguments.detail#" 
			 />			
		<cfelseif structKeyExists(arguments, "object")>
			<cfthrow
				object="#arguments.object#" 
			 />		
		<cfelse>
			<cfthrow 
				message="Attribute validation error for the CFTHROW tag."
				detail="The tag has an invalid attribute combination: detail,errorcode,extendedinfo,message,object,type. Possible combinations are:<li>Required attributes: 'type'. Optional attributes: 'detail,errorcode,extendedinfo,message'. <li>Required attributes: 'message'. Optional attributes: 'detail,errorcode,extendedinfo'. <li>Required attributes: 'extendedinfo'. Optional attributes: 'detail,errorcode'. <li>Required attributes: 'errorcode'. Optional attributes: 'detail'. <li>Required attributes: None. Optional attributes: None. <li>Required attributes: 'detail'. Optional attributes: None. <li>Required attributes: 'object'. Optional attributes: None."
			/>	 
		</cfif>
	
	</cffunction>
	
	<cffunction name="collectRequestInfo" access="public" returntype="struct" output="false" hint="Returns a struct containing information that should be included in every error report">
		<cfset var stResult = structnew() />
		
		<cfset stResult["machinename"] = application.sysInfo.machineName />
		<cfset stResult["instancename"] = application.sysInfo.instanceName />
		<cfset stResult["bot"] = IIF(!request.fc.hasSessionScope,DE("bot"),DE("not a bot")) />
		<cfset stResult["browser"] = cgi.http_host />
		<cfset stResult["datetime"] = now() />
		<cfset stResult["host"] = cgi.http_host />
		<cfset stResult["httpreferer"] = cgi.http_referer />
		<cfset stResult["scriptname"] = cgi.script_name />
		<cfset stResult["querystring"] = cgi.query_string />
		<cfset stResult["remoteaddress"] = cgi.remote_addr />
		<cfset stResult["host"] = cgi.http_host />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="create404Error" access="public" returntype="struct" output="false" hint="Constructs a 404 error struct">
		<cfargument name="message" type="string" required="false" default="Page does not exist" />
		
		<cfset var stError = collectRequestInfo() />
		
		<cfset stError["message"] = arguments.message />
		<cfset stError["url"] = duplicate(URL) />
		
		<cfreturn stError />
	</cffunction>
	
	<cffunction name="normalizeError" access="public" returntype="struct" output="false" hint="Simplifies and auguments error struct">
		<cfargument name="exception" type="any" required="true" />
		<cfargument name="bIncludeCore" type="boolean" required="false" default="true" />
		
		<cfset var stException = structnew() />
		<cfset var stResult = collectRequestInfo() />
		
		<cfset var aStack = arraynew(1) />
		<cfset var stLine = structnew() />
		<cfset var i = 0 />
		
		<cfif structKeyExists(arguments.exception, "rootcause")>
			<cfset stException = arguments.exception.rootcause />
		<cfelse>
			<cfset stException = arguments.exception />
		</cfif>
		
		<cfset stResult["message"] = stException.message />
		
		<!--- Normalize the stack trace --->
		<cfset stResult["stack"] = arraynew(1) />
		<cfloop from="1" to="#arraylen(stException.TagContext)#" index="i">
			<cfset stLine = structnew() />
			<cfset stLine["template"] = stException.TagContext[i].template />
			<cfset stLine["line"] = stException.TagContext[i].line />
			
			<cfif left(stLine.template,len(application.path.core)) eq application.path.core>
				<cfset stLine["location"] = "core" />
			<cfelseif left(stLine.template,len(application.path.plugins)) eq application.path.plugins>
				<cfset stLine["location"] = listfirst(mid(stLine.template,len(application.path.plugins)+1,len(stLine.template)),"/\") />
			<cfelseif left(stLine.template,len(application.path.project)) eq application.path.project or left(stLine.template,len(application.path.webroot)) eq application.path.webroot>
				<cfset stLine["location"] = "project" />
			<cfelseif refindnocase("\.java$",stLine.template)>
				<cfset stLine["location"] = "java" />
			<cfelse>
				<cfset stLine["location"] = "external" />
			</cfif>
			
			<cfif arguments.bIncludeCore or stLine["location"] eq "core">
				<cfset arrayappend(stResult["stack"],stLine) />
			</cfif>
		</cfloop>
		
		<cfif structKeyExists(stException, "type") and len(stException.type)>
			<cfset stResult["type"] = stException.type />
		</cfif>
		<cfif structKeyExists(stException, "errorcode") and len(stException.errorcode)>
			<cfset stResult["errorcode"] = stException.errorcode />
		</cfif>
		<cfif structKeyExists(stException, "detail") and len(stException.detail)>
			<cfset stResult["detail"] = stException.detail />
		</cfif>
		<cfif structKeyExists(stException, "extended_info") and len(stException.extended_info)>
			<cfset stResult["extended_info"] = stException.extended_info />
		</cfif>
		<cfif structKeyExists(stException, "queryError") and len(stException.queryError)>
			<cfset stResult["queryError"] = stException.queryError />
		</cfif>
		<cfif structKeyExists(stException, "sql") and len(stException.sql)>
			<cfset stResult["sql"] = stException.sql />
		</cfif>
		<cfif structKeyExists(stException, "where") and len(stException.where)>
			<cfset stResult["where"] = stException.where />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="logError" access="public" output="false" returntype="void" hint="Logs error to application and exception log files">
		<cfargument name="exception" type="struct" required="true" />
		<cfargument name="bApplication" type="boolean" required="false" default="true" />
		<cfargument name="bException" type="boolean" required="false" default="true" />
		
		<cfset var stacktrace = createObject("java","java.lang.StringBuffer").init() />
		<cfset var i = 0 />
		<cfset var firstline = "N/A" />
		
		<cfif arraylen(arguments.exception.stack)>
			<cfset firstline = "#arguments.exception.stack[1].template#, line: #arguments.exception.stack[1].line#" />
		</cfif>
		
		<cfif arguments.bApplication>
			<cflog log="application" application="true" type="error" text="#arguments.exception.message#. The specific sequence of files included or processed is #firstline#" />
		</cfif>
		<cfif arguments.bException>
			<cfloop from="1" to="#arraylen(arguments.exception.stack)#" index="i">
				<cfset stacktrace.append(arguments.exception.stack[i].template) />
				<cfset stacktrace.append(":") />
				<cfset stacktrace.append(arguments.exception.stack[i].line) />
				<cfif i eq arraylen(arguments.exception.stack)>
					<cfset stacktrace.append(variables.newline) />
				</cfif>
			</cfloop>
			<cflog file="exception" application="true" type="error" text="#arguments.exception.message#. The specific sequence of files included or processed is #firstline##newline##stacktrace.toString()#" />
		</cfif>	
	</cffunction>
	
	<cffunction name="formatError" access="public" output="false" returntype="any" hint="Formats normalized error for use in HTML or email">
		<cfargument name="exception" type="struct" required="true" />
		<cfargument name="format" type="string" required="false" default="html" hint="[html | text | json]" />
		<cfargument name="bHighlightNonCore" type="boolean" required="false" default="true" hint="Only applies to html and text formats" />
		
		<cfset var output = createObject("java","java.lang.StringBuffer").init() />
		<cfset var first = true />
		
		<cfswitch expression="#arguments.format#">
			<cfcase value="json">
				<cfreturn serializeJSON(arguments.exception) />
			</cfcase>
			
			<cfcase value="html">
				<cfset output.append("<h2>Error Overview</h2><table>") />
				<cfset output.append("<tr><th>Machine:</th><td>#arguments.exception.machineName#</td></tr>") />
				<cfset output.append("<tr><th>Instance:</th><td>#arguments.exception.instancename#</td></tr>") />
				<cfset output.append("<tr><th>Message:</th><td>#arguments.exception.message#</td></tr>") />
				<cfset output.append("<tr><th>Browser:</th><td>#arguments.exception.browser#</td></tr>") />
				<cfset output.append("<tr><th>DateTime:</th><td>#arguments.exception.datetime#</td></tr>") />
				<cfset output.append("<tr><th>Host:</th><td>#arguments.exception.host#</td></tr>") />
				<cfset output.append("<tr><th>HTTPReferer:</th><td>#arguments.exception.httpreferer#</td></tr>") />
				<cfset output.append("<tr><th>QueryString:</th><td>#arguments.exception.querystring#</td></tr>") />
				<cfset output.append("<tr><th>RemoteAddress:</th><td>#arguments.exception.remoteaddress#</td></tr>") />
				<cfset output.append("<tr><th>Bot:</th><td>#arguments.exception.bot#</td></tr>") />
				<cfset output.append("</table><h2>Error Details</h2><table>") />
				<cfif structKeyExists(arguments.exception, "type") and len(arguments.exception.type)>
					<cfset output.append("<tr><th>Exception Type:</th><td>#arguments.exception.type#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail)>
					<cfset output.append("<tr><th>Detail:</th><td>#arguments.exception.detail#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "extended_info") and len(arguments.exception.extended_info)>
					<cfset output.append("<tr><th>Extended Info:</th><td>#arguments.exception.extended_info#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "queryError") and len(arguments.exception.queryError)>
					<cfset output.append("<tr><th>Error:</th><td>#arguments.exception.queryError#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "sql") and len(arguments.exception.sql)>
					<cfset output.append("<tr><th>SQL:</th><td>#arguments.exception.sql#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "where") and len(arguments.exception.where)>
					<cfset output.append("<tr><th>Where:</th><td>#arguments.exception.where#</td></tr>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "stack") and arraylen(arguments.exception.stack)>
					<cfset output.append("<tr><th valign='top'>Tag Context:</th><td><ul>") />
					<cfloop from="1" to="#arrayLen(arguments.exception.stack)#" index="i">
						<cfif arguments.bHighlightNonCore && arguments.exception.stack[i].location neq "core">
							<cfset output.append("<li><strong>#arguments.exception.stack[i].template# (line: #arguments.exception.stack[i].line#)</strong></li>") />
						<cfelse>
							<cfset output.append("<li>#arguments.exception.stack[i].template# (line: #arguments.exception.stack[i].line#)</li>") />
						</cfif>
					</cfloop>
					<cfset output.append("</ul></td></tr>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "url")>
					<cfset output.append("<tr><th valign='top'>Post-process URL:</th><td><ul>") />
					<cfloop list="#listsort(structkeylist(arguments.exception.url),'textnocase')#" index="i">
						<cfset output.append("<li>#i# = #htmleditformat(arguments.exception.url[i])#</li>") />
					</cfloop>
					<cfset output.append("</ul></td></tr>") />
				</cfif>
				
				<cfset output.append("</table>") />
			</cfcase>
			
			<cfcase value="text">
				<cfset output.append("ERROR OVERVIEW" & variables.newline) />
				<cfset output.append("Machine:           #arguments.exception.machineName#" & variables.newline) />
				<cfset output.append("Instance:          #arguments.exception.instancename#" & variables.newline) />
				<cfset output.append("Message:           #arguments.exception.message#" & variables.newline) />
				<cfset output.append("Browser:           #arguments.exception.browser#" & variables.newline) />
				<cfset output.append("DateTime:          #arguments.exception.datetime#" & variables.newline) />
				<cfset output.append("Host:              #arguments.exception.host#" & variables.newline) />
				<cfset output.append("HTTPReferer:       #arguments.exception.httpreferer#" & variables.newline) />
				<cfset output.append("QueryString:       #arguments.exception.querystring#" & variables.newline) />
				<cfset output.append("RemoteAddress:     #arguments.exception.remoteaddress#" & variables.newline) />
				<cfset output.append("Bot:               #arguments.exception.bot#" & variables.newline) />
				<cfset output.append(variables.newline) />
				
				<cfset output.append("ERROR DETAILS" & variables.newline) />
				<cfif structKeyExists(arguments.exception, "type") and len(arguments.exception.type)>
					<cfset output.append("Exception Type:    #arguments.exception.type#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail)>
					<cfset output.append("Detail:            #arguments.exception.detail#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "extended_info") and len(arguments.exception.extended_info)>
					<cfset output.append("Extended Info:     #arguments.exception.extended_info#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "queryError") and len(arguments.exception.queryError)>
					<cfset output.append("Error:             #arguments.exception.queryError#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "sql") and len(arguments.exception.sql)>
					<cfset output.append("SQL:               #arguments.exception.sql#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "where") and len(arguments.exception.where)>
					<cfset output.append("Where:             #arguments.exception.where#" & variables.newline) />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "stack") and arraylen(arguments.exception.stack)>
					<cfset output.append("Tag Context:     ") />
					<cfloop from="1" to="#arrayLen(arguments.exception.stack)#" index="i">
						<cfif i neq 1>
							<cfset output.append("                 ")>
						</cfif>
						
						<cfif arguments.bHighlightNonCore && arguments.exception.stack[i].location neq "core">
							<cfset output.append("* #arguments.exception.stack[i].template# (line: #arguments.exception.stack[i].line#)" & variables.newline) />
						<cfelse>
							<cfset output.append("- #arguments.exception.stack[i].template# (line: #arguments.exception.stack[i].line#)" & variables.newline) />
						</cfif>
					</cfloop>
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "url")>
					<cfset output.append("Post-process URL:  ") />
					<cfloop list="#listsort(structkeylist(arguments.exception.url),'textnocase')#" index="i">
						<cfif not first>
							<cfset output.append("                 ")>
						</cfif>
						<cfset first = false />
						
						<cfset output.append("#i# = #arguments.exception.url[i]#") />
					</cfloop>
				</cfif>
			</cfcase>
		</cfswitch>
		
		<cfreturn output.toString() />
	</cffunction>
	
	<cffunction name="getStack" access="public" returntype="array" output="false" hint="Returns a stack array">
		<cfargument name="bIncludeCore" type="boolean" required="false" default="true" />
		<cfargument name="bIncludeJava" type="boolean" required="false" default="true" />
		
		<cfset var aResult = arraynew(1) />
		<cfset var aStacktrace = createobject("java","java.lang.Exception").init().getStackTrace() />
		<cfset var stLine = structnew() />
		<cfset var i = 0 />
		<cfset var found = 0 />
		
		<cfloop from="1" to="#arraylen(aStackTrace)#" index="i">
			<cfset stLine = structnew() />
			<cfset stLine["template"] = aStackTrace[i].getFileName() />
			<cfset stLine["line"] = aStackTrace[i].getLineNumber() />
			
			<cfif refindnocase("\.(cfc|cfm)$",stLine.template)>
				<cfset found = found + 1 />
			</cfif>
			
			<cfif found gte 2>
				<cfif left(stLine.template,len(application.path.core)) eq application.path.core>
					<cfset stLine["location"] = "core" />
				<cfelseif left(stLine.template,len(application.path.plugins)) eq application.path.plugins>
					<cfset stLine["location"] = listfirst(mid(stLine.template,len(application.path.plugins+1),len(stLine.template)),"/\") />
				<cfelseif left(stLine.template,len(application.path.project)) eq application.path.project or left(stLine.template,len(application.path.webroot)) eq application.path.webroot>
					<cfset stLine["location"] = "project" />
				<cfelseif refindnocase("\.java$",stLine.template)>
					<cfset stLine["location"] = "java" />
				<cfelse>
					<cfset stLine["location"] = "external" />
				</cfif>
				
				<cfif (arguments.bIncludeCore or stLine["location"] neq "core") and (arguments.bIncludeJava or stLine["location"] neq "java")>
					<cfset arrayappend(aResult,stLine) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn aResult />
	</cffunction>
	
	
	<cffunction name="showErrorPage" access="public" output="true" returntype="void" hint="Returns output of projects error page">
		<cfargument name="type" type="string" required="true" hint="404 | 500" />
		<cfargument name="stException" type="struct" required="true" />
		<cfargument name="abort" type="boolean" required="false" default="false" hint="Set to true to force the request to stop processing" />
		
		<cfset var errorHTML = formatError(arguments.stException,"html") />
		<cfset var statuscode = listfirst(arguments.type,' ') />
		<cfset var statusmessage = listrest(arguments.type,' ') />
		
		<cfset var machineName = arguments.stException.machinename />
		<cfset var instanceName = arguments.stException.instancename />
		<cfset var bot = arguments.stException.bot />
		<cfset var output = "" />
		
		<cfset var showError = false />
		
		<cfif reFindNoCase("^#application.url.webtop#", cgi.script_name)>
			<cfset showError = true />
		<cfelseif isdefined("url.debug") AND url.debug>
			<cfset showError = true />
		<cfelseif isdefined("request.mode.debug") and request.mode.debug>
			<cfset showError = true />
		</cfif>
		
		<cfparam name="application.url.webtop" default="/webtop">
		
		<cfcontent reset="true" />
		<cfheader statuscode="#statuscode#" statustext="#statusmessage#" />
		
		<cfif reFindNoCase("^#application.url.webtop#", cgi.script_name)>
			<cfinclude template="/farcry/core/webtop/errors/#statuscode#.cfm" />
		<cfelseif fileexists("#application.path.project#/errors/#statuscode#.cfm")>
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/errors/#statuscode#.cfm" />
		<cfelseif fileexists("#application.path.webroot#/errors/#statuscode#.cfm")>
			<cfinclude template="#application.url.webroot#/errors/#statuscode#.cfm" />
		<cfelse>
			<cfinclude template="/farcry/core/webtop/errors/#statuscode#.cfm" />
		</cfif>
		
		<cfif arguments.abort>
			<cfabort />
		</cfif>
	</cffunction>
	
</cfcomponent>