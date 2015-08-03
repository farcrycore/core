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
			
			<cfset arguments.message = padResource(key="#arguments.key#@message", default=arguments.message, locale=arguments.locale, substituteValues=arguments.substituteValues) />
			
			<cfif len(arguments.detail)>
				<cfset arguments.detail = padResource(key="#arguments.key#@detail", default=arguments.detail, locale=arguments.locale, substituteValues=arguments.substituteValues) />
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

	<!--- Thanks to Dan Switzer for figuring this out (http://blog.pengoworks.com/index.cfm/2011/5/26/Modifying-the-message-in-a-CFCATCH-before-rethrowing-error) --->
	<cffunction name="rethrowMessage" access="public" returntype="void" output="false" hint="Rethrow a CFCATCH error, but allows customizing the message key">
		<cfargument name="cfcatch" type="any" required="true" />
		<cfargument name="message" type="string" required="false" />

		<cfset var exception = "" />

		<cfif not structKeyExists(arguments, "message")>
			<cfset arguments.message = arguments.cfcatch.message />
		</cfif>

		<cfset exception = createObject("java", "java.lang.Exception").init(arguments.message) />
		<cfset exception.initCause(arguments.cfcatch.getCause()) />
		<cfset exception.setStackTrace(arguments.cfcatch.getStackTrace()) />

		<cfthrow object="#exception#" />
	</cffunction>
	
	<cffunction name="collectRequestInfo" access="public" returntype="struct" output="false" hint="Returns a struct containing information that should be included in every error report">
		<cfset var stResult = structnew() />
		
		<cfif isdefined("application.sysInfo.machineName")>
			<cfset stResult["machinename"] = application.sysInfo.machineName />
		<cfelse>
			<cfset stResult["machinename"] = "Unknown" />
		</cfif>
		<cfif isdefined("application.sysInfo.machineName")>
			<cfset stResult["instancename"] = application.sysInfo.instanceName />
		<cfelse>
			<cfset stResult["instancename"] = "Unknown" />
		</cfif>
		<cfset stResult["bot"] = IIF(!isdefined("request.fc.hasSessionScope") || !request.fc.hasSessionScope,DE("bot"),DE("not a bot")) />
		<cfset stResult["browser"] = cgi.HTTP_USER_AGENT />
		<cfset stResult["datetime"] = now() />
		<cfset stResult["host"] = cgi.http_host />
		<cfset stResult["httpreferer"] = cgi.http_referer />
		<cfset stResult["scriptname"] = cgi.script_name />
		<cfset stResult["querystring"] = cgi.query_string />
		<cfset stResult["remoteaddress"] = cgi.remote_addr />
		<cfset stResult["host"] = cgi.http_host />
		
		<!--- Add arguments to result --->
		<cfset structappend(stResult,arguments,false) />
		
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
		
		<cfset stException = duplicate(arguments.exception) />
		
		<cfif structKeyExists(stException, "rootcause")>
			<cfset stException = stException.rootcause />
		<cfelseif structkeyexists(stException, "cause")>
			<cfset stException = stException.cause />
		</cfif>
		
		<cfset stResult["message"] = stException.message />
		
		<!--- Normalize the stack trace --->
		<cfset stResult["stack"] = arraynew(1) />
		<cfloop from="1" to="#min(arraylen(stException.TagContext),20)#" index="i">
			<cfset stLine = structnew() />
			<cfset stLine["template"] = stException.TagContext[i].template />
			<cfset stLine["line"] = stException.TagContext[i].line />
			
			<cfif isDefined("application.path.core") and left(stLine.template,len(application.path.core)) eq application.path.core>
				<cfset stLine["location"] = "core" />
			<cfelseif isDefined("application.path.plugins") and left(stLine.template,len(application.path.plugins)) eq application.path.plugins>
				<cfset stLine["location"] = listfirst(mid(stLine.template,len(application.path.plugins)+1,len(stLine.template)),"/\") />
			<cfelseif isDefined("application.path.project") and left(stLine.template,len(application.path.project)) eq application.path.project or (isDefined("application.path.webroot") and left(stLine.template,len(application.path.webroot)) eq application.path.webroot)>
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
	
	<cffunction name="logData" access="public" output="false" returntype="void" hint="Logs error to application and exception log files">
		<cfargument name="log" type="struct" required="true" />
		<cfargument name="bApplication" type="boolean" required="false" default="true" />
		<cfargument name="bException" type="boolean" required="false" default="true" />
		<cfargument name="logFile" type="string" required="false" default="" />
		<cfargument name="logType" type="string" required="true" default="error" />
		
		<cfset var stacktrace = createObject("java","java.lang.StringBuffer").init() />
		<cfset var i = 0 />
		<cfset var firstline = "" />
		
		<cfif structkeyexists(arguments.log,"stack") and arraylen(arguments.log.stack)>
			<cfset firstline = "The specific sequence of files included or processed is #arguments.log.stack[1].template#, line: #arguments.log.stack[1].line#" />
		</cfif>
		
		<cfif structKeyExists(arguments,"logFile") and len(arguments.logFile) and structkeyexists(arguments.log,"message")>
			<cfif NOT structkeyexists(arguments.log,"stack")>
				<cflog file="#arguments.logFile#" application="true" type="information" text="#arguments.log.message#" />
			<cfelse>
				<cfloop from="1" to="#arraylen(arguments.log.stack)#" index="i">
					<cfset stacktrace.append(arguments.log.stack[i].template) />
					<cfset stacktrace.append(":") />
					<cfset stacktrace.append(arguments.log.stack[i].line) />
					<cfif i eq arraylen(arguments.log.stack)>
						<cfset stacktrace.append(variables.newline) />
					</cfif>
				</cfloop>
				<cflog file="#arguments.logFile#" application="true" type="information" text="#arguments.log.message#. #firstline##newline##stacktrace.toString()#" />
			</cfif>
		<cfelse>
			<cfif arguments.bApplication and structkeyexists(arguments.log,"message")>
				<cflog log="application" application="true" type="error" text="#arguments.log.message#. #firstline#" />
			</cfif>
			<cfif arguments.bException and structkeyexists(arguments.log,"stack") and structkeyexists(arguments.log,"message")>
				<cfloop from="1" to="#arraylen(arguments.log.stack)#" index="i">
					<cfset stacktrace.append(arguments.log.stack[i].template) />
					<cfset stacktrace.append(":") />
					<cfset stacktrace.append(arguments.log.stack[i].line) />
					<cfif i eq arraylen(arguments.log.stack)>
						<cfset stacktrace.append(variables.newline) />
					</cfif>
				</cfloop>
				<cflog file="exception" application="true" type="#arguments.logType#" text="#arguments.log.message#. #firstline##newline##stacktrace.toString()#" />
			</cfif>	
		</cfif>
	</cffunction>

	
	<cffunction name="encodeErrorText" access="public" output="false" returntype="any" hint="Encodes/escapes text before output">
		<cfargument name="text" required="true" type="string">

		<cfset var result = "">

		<cfif isDefined("application.fc.lib.esapi")>
			<cfset result = application.fc.lib.esapi.encodeForHTML(arguments.text)>
		<cfelse>
			<cfset result = xmlFormat(arguments.text)>
		</cfif>

		<cfreturn result>
	</cffunction>

	
	<cffunction name="formatError" access="public" output="false" returntype="any" hint="Formats normalized error for use in HTML or email">
		<cfargument name="exception" type="struct" required="true" />
		<cfargument name="format" type="string" required="false" default="html" hint="[html | text | json]" />
		<cfargument name="bHighlightNonCore" type="boolean" required="false" default="true" hint="Only applies to html and text formats" />
		
		<cfset var output = createObject("java","java.lang.StringBuffer").init() />
		<cfset var first = true />
		<cfset var i	= '' />
		
		<cfswitch expression="#arguments.format#">
			<cfcase value="json">
				<cfreturn serializeJSON(arguments.exception) />
			</cfcase>
			
			<cfcase value="xml">
				<cfset output.append('<?xml version="1.0" encoding="UTF-8" ?><error>') />
				<cfset output.append("<machineName><![CDATA[#xmlformat(arguments.exception.machineName)#]]></machineName>") />
				<cfset output.append("<instancename><![CDATA[#xmlformat(arguments.exception.instancename)#]]></instancename>") />
				<cfset output.append("<message><![CDATA[#xmlformat(arguments.exception.message)#]]></message>") />
				<cfset output.append("<browser><![CDATA[#xmlformat(arguments.exception.browser)#]]></browser>") />
				<cfset output.append("<datetime><![CDATA[#xmlformat(arguments.exception.datetime)#]]></datetime>") />
				<cfset output.append("<host><![CDATA[#xmlformat(arguments.exception.host)#]]></host>") />
				<cfset output.append("<httpreferer><![CDATA[#xmlformat(arguments.exception.httpreferer)#]]></httpreferer>") />
				<cfset output.append("<querystring><![CDATA[#xmlformat(arguments.exception.querystring)#]]></querystring>") />
				<cfset output.append("<remoteaddress>#xmlformat(arguments.exception.remoteaddress)#</remoteaddress>") />
				<cfset output.append("<bot>#arguments.exception.bot#</bot>") />
				<cfif structKeyExists(arguments.exception, "type") and len(arguments.exception.type)>
					<cfset output.append("<type><![CDATA[#xmlformat(arguments.exception.type)#]]></type>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail)>
					<cfset output.append("<detail><![CDATA[#xmlformat(arguments.exception.detail)#]]></detail>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "extended_info") and len(arguments.exception.extended_info)>
					<cfset output.append("<extended_info><![CDATA[#xmlformat(arguments.exception.extended_info)#]]></extended_info>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "queryError") and len(arguments.exception.queryError)>
					<cfset output.append("<queryError><![CDATA[#xmlformat(arguments.exception.queryError)#]]></queryError>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "sql") and len(arguments.exception.sql)>
					<cfset output.append("<sql><![CDATA[#xmlformat(arguments.exception.sql)#]]></sql>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "where") and len(arguments.exception.where)>
					<cfset output.append("<where><![CDATA[#xmlformat(arguments.exception.where)#]]></where>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "stack") and arraylen(arguments.exception.stack)>
					<cfset output.append("<stack>") />
					<cfloop from="1" to="#arrayLen(arguments.exception.stack)#" index="i">
						<cfset output.append("<item>") />
						<cfset output.append("<template><![CDATA[#xmlformat(arguments.exception.stack[i].template)#]]></template>") />
						<cfset output.append("<line>#arguments.exception.stack[i].line#</line>") />
						<cfset output.append("<location><![CDATA[#xmlformat(arguments.exception.stack[i].location)#]]></location>") />
						<cfset output.append("</item>") />
					</cfloop>
					<cfset output.append("</stack>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "url")>
					<cfset output.append("<url>") />
					<cfloop list="#listsort(structkeylist(arguments.exception.url),'textnocase')#" index="i">
						<cfset output.append("<variable>") />
						<cfset output.append("<name><![CDATA[#xmlformat(i)#]]></name>") />
						<cfset output.append("<value><![CDATA[#xmlformat(arguments.exception.url[i])#]]></value>") />
						<cfset output.append("</variable>") />
					</cfloop>
					<cfset output.append("</url>") />
				</cfif>
				
				<cfset output.append("</error>") />
			</cfcase>
			
			<cfcase value="html">
				<cfset output.append("<h2>#padResource('error.overview@label','Error Overview')#</h2><table>") />
				<cfset output.append("<tr><th>#padResource('error.overview.machine@label','Machine')#:</th><td>#arguments.exception.machineName#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.instance@label','Instance')#:</th><td>#arguments.exception.instancename#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.message@label','Message')#:</th><td>#encodeErrorText(arguments.exception.message)#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.browser@label','Browser')#:</th><td>#encodeErrorText(arguments.exception.browser)#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.datetime@label','DateTime')#:</th><td>#arguments.exception.datetime#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.host@label','Host')#:</th><td>#arguments.exception.host#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.httpreferer@label','HTTPReferer')#:</th><td>#encodeErrorText(arguments.exception.httpreferer)#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.querystring@label','QueryString')#:</th><td>#encodeErrorText(arguments.exception.querystring)#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.remoteaddress@label','RemoteAddress')#:</th><td>#encodeErrorText(arguments.exception.remoteaddress)#</td></tr>") />
				<cfset output.append("<tr><th>#padResource('error.overview.bot@label','Bot')#:</th><td>#arguments.exception.bot#</td></tr>") />
				<cfset output.append("</table><h2>#padResource('error.details@label','Error Details')#</h2><table>") />
				<cfif structKeyExists(arguments.exception, "type") and len(arguments.exception.type)>
					<cfset output.append("<tr><th>#padResource('error.details.exceptiontype@label','Exception Type')#:</th><td>#arguments.exception.type#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail) and isJSON(arguments.exception.detail) and structkeyexists(application,"fapi")>
					<cfset output.append("<tr><th>#padResource('error.details.detail@label','Detail')#:</th><td><pre class='formatjson'>#application.fapi.formatJSON(arguments.exception.detail)#</pre></td></tr>") />
				<cfelseif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail)>
					<cfset output.append("<tr><th>#padResource('error.details.detail@label','Detail')#:</th><td>#arguments.exception.detail#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "extended_info") and len(arguments.exception.extended_info)>
					<cfset output.append("<tr><th>#padResource('error.details.extendedinfo@label','Extended Info')#:</th><td>#arguments.exception.extended_info#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "queryError") and len(arguments.exception.queryError)>
					<cfset output.append("<tr><th>#padResource('error.details.error@label','Error')#:</th><td>#arguments.exception.queryError#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "sql") and len(arguments.exception.sql)>
					<cfset output.append("<tr><th>#padResource('error.details.sql@label','SQL')#:</th><td>#encodeErrorText(arguments.exception.sql)#</td></tr>") />
				</cfif>
				<cfif structKeyExists(arguments.exception, "where") and len(arguments.exception.where)>
					<cfset output.append("<tr><th>#padResource('error.details.where@label','Where')#:</th><td>#encodeErrorText(arguments.exception.where)#</td></tr>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "stack") and arraylen(arguments.exception.stack)>
					<cfset output.append("<tr><th valign='top'>#padResource('error.details.tagcontext@label','Tag Context')#:</th><td><ul>") />
					<cfloop from="1" to="#arrayLen(arguments.exception.stack)#" index="i">
						<cfif arguments.bHighlightNonCore && arguments.exception.stack[i].location neq "core">
							<cfset output.append("<li><strong>#arguments.exception.stack[i].template# (#padResource('error.line@label','line')#: #arguments.exception.stack[i].line#)</strong></li>") />
						<cfelse>
							<cfset output.append("<li>#arguments.exception.stack[i].template# (#padResource('error.line@label','line')#: #arguments.exception.stack[i].line#)</li>") />
						</cfif>
					</cfloop>
					<cfset output.append("</ul></td></tr>") />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "url")>
					<cfset output.append("<tr><th valign='top'>#padResource('error.details.postprocessurl@label','Post-process URL')#:</th><td><ul>") />
					<cfloop list="#listsort(structkeylist(arguments.exception.url),'textnocase')#" index="i">
						<cfif issimplevalue(arguments.exception.url[i])>
							<cfset output.append("<li>#i# = #encodeErrorText(arguments.exception.url[i])#</li>") />
						<cfelse>
							<cfset output.append("<li>#i# = #encodeErrorText(serializeJSON(arguments.exception.url[i]))#</li>") />
						</cfif>
					</cfloop>
					<cfset output.append("</ul></td></tr>") />
				</cfif>
				
				<cfset output.append("</table>") />
			</cfcase>
			
			<cfcase value="text">
				<cfset output.append(ucase(padResource('error.overview@label','Error Overview')) & variables.newline) />
				<cfset output.append("#padResource('error.overview.machine@label','Machine','',20)# : #arguments.exception.machineName#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.instance@label','Instance','',20)# : #arguments.exception.instancename#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.message@label','Message','',20)# : #arguments.exception.message#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.browser@label','Browser','',20)# : #arguments.exception.browser#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.datetime@label','DateTime','',20)# : #arguments.exception.datetime#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.host@label','Host','',20)# : #arguments.exception.host#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.httpreferer@label','HTTPReferer','',20)# : #arguments.exception.httpreferer#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.querystring@label','QueryString','',20)# : #arguments.exception.querystring#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.remoteaddress@label','RemoteAddress','',20)# : #arguments.exception.remoteaddress#" & variables.newline) />
				<cfset output.append("#padResource('error.overview.bot@label','Bot','',20)# : #arguments.exception.bot#" & variables.newline) />
				<cfset output.append(variables.newline) />
				
				<cfset output.append(ucase(padResource('error.details@label','Error Details')) & variables.newline) />
				<cfif structKeyExists(arguments.exception, "type") and len(arguments.exception.type)>
					<cfset output.append("#padResource('error.details.exceptiontype@label','Exception Type','',20)# : #arguments.exception.type#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "detail") and len(arguments.exception.detail)>
					<cfset output.append("#padResource('error.details.detail@label','Detail','',20)# : #arguments.exception.detail#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "extended_info") and len(arguments.exception.extended_info)>
					<cfset output.append("#padResource('error.details.extendedinfo@label','Extended Info','',20)# : #arguments.exception.extended_info#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "queryError") and len(arguments.exception.queryError)>
					<cfset output.append("#padResource('error.details.error@label','Error','',20)# : #arguments.exception.queryError#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "sql") and len(arguments.exception.sql)>
					<cfset output.append("#padResource('error.details.sql@label','SQL','',20)# : #arguments.exception.sql#" & variables.newline) />
				</cfif>
				<cfif structKeyExists(arguments.exception, "where") and len(arguments.exception.where)>
					<cfset output.append("#padResource('error.details.where@label','Where','',20)# : #arguments.exception.where#" & variables.newline) />
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "stack") and arraylen(arguments.exception.stack)>
					<cfset output.append("#padResource('error.details.tagcontext@label','Tag Context','',20)#:     ") />
					<cfloop from="1" to="#arrayLen(arguments.exception.stack)#" index="i">
						<cfif i neq 1>
							<cfset output.append("                  ")>
						</cfif>
						
						<cfif arguments.bHighlightNonCore && arguments.exception.stack[i].location neq "core">
							<cfset output.append("* #arguments.exception.stack[i].template# (#padResource('error.line@label','line')#: #arguments.exception.stack[i].line#)" & variables.newline) />
						<cfelse>
							<cfset output.append("- #arguments.exception.stack[i].template# (#padResource('error.line@label','line')#: #arguments.exception.stack[i].line#)" & variables.newline) />
						</cfif>
					</cfloop>
				</cfif>
				
				<cfif structKeyExists(arguments.exception, "url")>
					<cfset output.append("#padResource('error.details.postprocessurl@label','Post-process URL','',20)# : ") />
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
		<cfargument name="ignoreLines" type="numeric" required="false" default="1" hint="Number of stack lines to omit from result" />
		
		<cfset var aResult = arraynew(1) />
		<cfset var aStacktrace = createobject("java","java.lang.Throwable").getStackTrace() />
		<cfset var stLine = structnew() />
		<cfset var i = 0 />
		<cfset var found = 0 />
		<cfset var ignored = 0 />
		
		<cfloop from="1" to="#arraylen(aStackTrace)#" index="i">
			<cfset stLine = structnew() />
			<cfset stLine["template"] = aStackTrace[i].getFileName() />
			<cfset stLine["line"] = aStackTrace[i].getLineNumber() />
			
			<cfif structkeyexists(stLine,"template") and refindnocase("\.(cfc|cfm)$",stLine.template)>
				<cfset found = found + 1 />
			</cfif>
			
			<cfif found gt 1 and structkeyexists(stLine,"template")>
				<cfif left(stLine["template"],len(application.path.core)) eq application.path.core>
					<cfset stLine["location"] = "core" />
				<cfelseif left(stLine["template"],len(application.path.plugins)) eq application.path.plugins>
					<cfset stLine["location"] = listfirst(mid(stLine["template"],len(application.path.plugins)+1,len(stLine["template"])),"/\") />
				<cfelseif left(stLine["template"],len(application.path.project)) eq application.path.project or left(stLine["template"],len(application.path.webroot)) eq application.path.webroot>
					<cfset stLine["location"] = "project" />
				<cfelseif refindnocase("\.java$",stLine["template"])>
					<cfset stLine["location"] = "java" />
				<cfelse>
					<cfset stLine["location"] = "external" />
				</cfif>
				
				<cfif (arguments.bIncludeCore or stLine["location"] neq "core") and (arguments.bIncludeJava or stLine["location"] neq "java") and ignored gte arguments.ignoreLines>
					<cfset arrayappend(aResult,stLine) />
				<cfelseif (arguments.bIncludeCore or stLine["location"] neq "core") and (arguments.bIncludeJava or stLine["location"] neq "java") and ignored lt arguments.ignoreLines>
					<cfset ignored = ignored + 1 />
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
		
		<cfif isdefined("application.url.webtop") and reFindNoCase("^#application.url.webtop#", cgi.script_name) or (structKeyExists(url,"view") and refindnocase("^webtop",url.view))>
			<cfset showError = true />
		<cfelseif isdefined("url.debug") AND url.debug>
			<cfset showError = true />
		<cfelseif isdefined("request.mode.debug") and request.mode.debug>
			<cfset showError = true />
		<cfelseif cgi.remote_addr eq "127.0.0.1">
			<cfset showError = true />
		</cfif>
		
		<!--- in the case of data views (json, xml, etc), return stream the data back in that type --->
		<cfif isdefined("url.type") and len(url.type) and isdefined("url.view") and len(url.view)
			and isdefined("application.stCOAPI.#url.type#.stWebskins.#url.view#.viewStack") 
			and application.stCOAPI[url.type].stWebskins[url.view].viewStack eq "data" 
			and isdefined("application.stCOAPI.#url.type#.stWebskins.#url.view#.mimeType")>
			
			<cfswitch expression="#application.stCOAPI[url.type].stWebskins[url.view].mimeType#">
				<cfcase value="json,application/json,text/json" delimiters=",">
					<cfheader statuscode="#statuscode#" statustext="#statusmessage#" />
					<cfif showError>
						<cfcontent type="text/json" variable="#ToBinary( ToBase64( '{ "error":' & formatError(exception=arguments.stException,format='json') & '}' ) )#" reset="Yes" />
					<cfelse>
						<cfcontent type="text/json" variable="#ToBinary( ToBase64( '{ "error":"There was an error with that request" }' ) )#" reset="Yes" />
					</cfif>
				</cfcase>
				<cfcase value="xml,text/xml" delimiters=",">
					<cfheader statuscode="#statuscode#" statustext="#statusmessage#" />
					<cfif showError>
						<cfcontent type="text/xml" variable="#ToBinary( ToBase64( formatError(exception=arguments.stException,format='xml') ) )#" reset="Yes" />
					<cfelse>
						<cfcontent type="text/xml" variable="#ToBinary( ToBase64( '<?xml version="1.0" encoding="UTF-8" ?><error>There was an error with that request</error>' ) )#" reset="Yes" />
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>

		
		<cfif NOT arguments.abort>
			<cfcontent reset="true" />
		</cfif>
		<cfheader statuscode="#statuscode#" statustext="#statusmessage#" />
		
		<cfif isdefined("application.url.webtop") and reFindNoCase("^#application.url.webtop#", cgi.script_name)>
			<cfinclude template="/farcry/core/webtop/errors/#statuscode#.cfm" />
		<cfelseif isdefined("application.path.project") and fileexists("#application.path.project#/errors/#statuscode#.cfm")>
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/errors/#statuscode#.cfm" />
		<cfelseif isdefined("application.path.webroot") and fileexists("#application.path.webroot#/errors/#statuscode#.cfm")>
			<cfinclude template="#application.url.webroot#/errors/#statuscode#.cfm" />
		<cfelse>
			<cfinclude template="/farcry/core/webtop/errors/#statuscode#.cfm" />
		</cfif>
		
		<cfif arguments.abort>
			<cfabort />
		</cfif>
	</cffunction>
	
	<cffunction name="padResource" access="public" output="false" returntype="string" hint="Gets resource and pads it to required length">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="default" type="string" required="false" default="#arguments.key#" />
		<cfargument name="substituteValues" required="no" default="#arrayNew(1)#" />
		<cfargument name="length" required="no" default="0" hint="Required length" />
		<cfargument name="locale" type="string" required="false" default="" />
		
		<cfset var resource = arguments.default />
		
		<cfif isdefined("application.fapi") and isdefined("application.rb")>
			<cfset resource = application.fapi.getResource(argumentCollection=arguments) />
		</cfif>
		
		<cfif arguments.length and len(resource) lt arguments.length>
			<cfset resource = resource & repeatstring(" ",arguments.length-len(resource)) />
		</cfif>
		
		<cfreturn resource />
	</cffunction>
	
</cfcomponent>