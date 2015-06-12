<cfcomponent output="false">
	
	
	<cffunction name="send" returntype="string" output="false" access="public">
		<cfargument name="to" type="string" required="true" hint="List of email address to send the email to" />
		<cfargument name="bcc" type="string" required="false" default="" hint="List of email addresses to BCC to" />
		<cfargument name="from" type="string" required="true" hint="Address the email is from" />
		<cfargument name="replyto" type="string" required="false" default="" hint="Reply address" />
		<cfargument name="subject" type="string" required="true" hint="Subject of email" />
		<cfargument name="bodyPlain" type="string" required="false" default="" hint="Plain text version of email." />
		<cfargument name="bodyHTML" type="string" required="false" default="" hint="HTML version of email" />
		<cfargument name="attachments" type="array" required="false" default="#arraynew(1)#" hint="Array of absolute path filenames, to be attached to the email" />
		<cfargument name="attachment" type="string" required="false" default="" hint="If there is only one attachment, it can be attached with this argument" />
		
		<cfargument name="rbkey" type="string" required="false" default="" hint="Resource key for translation" />
		<cfargument name="variables" type="any" required="false" default="#arrayNew(1)#" hint="Resource translation variables" />
		
		<cfset var i = 0 />
		<cfset var spaces = "" />
		<cfset var type = "text/plain" />
		<cfset var stSend = duplicate(arguments) />
		<cfset var result = cleanArguments(stSend) />
		<cfset var tmp = "" />
		<cfset var stLog = "" />
		
		<cfif result neq "Success">
			<cfreturn result />
		<cfelseif not len(stSend.to)> <!--- Whitelist removed all to addresses return out --->
			<cfreturn "Success" />
		</cfif>
		
		<cfif len(arguments.rbkey)>
			<cfif not isarray(arguments.variables)>
				<cfset tmp = arraynew(1) />
				<cfset tmp[1] = arguments.variables />
				<cfset arguments.variables = tmp />
			</cfif>
			
			<cfloop collection="#arguments#" item="i">
				<cfif refind("var\d+",i)>
					<cfset arguments.variables[mid(thisattr,4,len(i))] = arguments[i] />
				</cfif>
			</cfloop>
			
			<cfset stSend.subject = application.fapi.getResource(arguments.rbkey & "@subject",stSend.subject,arguments.variables) />
			<cfif len(stSend.bodyPlain)>
				<cfset stSend.bodyPlain = application.fapi.getResource(arguments.rbkey & "@text",stSend.bodyPlain,arguments.variables) />
			</cfif>
			<cfif len(stSend.bodyHTML)>
				<cfset stSend.bodyHTML = application.fapi.getResource(arguments.rbkey & "@html",stSend.bodyHTML,arguments.variables) />
			</cfif>
		</cfif>
		
		<cftry>
			<cfmail to="#trim(stSend.to)#" bcc="#trim(stSend.bcc)#" from="#trim(stSend.from)#" replyto="#trim(stSend.replyto)#" subject="#stSend.subject#" type="#stSend.type#">
				<cfloop from="1" to="#arraylen(stSend.attachments)#" index="i">
					<cfmailparam file="#stSend.attachments[i]#" />
				</cfloop>
				<cfif len(stSend.bodyPlain) and len(stSend.bodyHTML)>
					<cfmailpart type="plain" wraptext="74"><cfoutput>#stSend.bodyPlain#</cfoutput></cfmailpart>
					<cfmailpart type="html"><cfoutput>#stSend.bodyHTML#</cfoutput></cfmailpart>
				<cfelseif len(stSend.bodyPlain)>
					<cfmailpart type="plain" wraptext="74"><cfoutput>#stSend.bodyPlain#</cfoutput></cfmailpart>
				<cfelseif len(stSend.bodyHTML)>
					<cfmailpart type="html"><cfoutput>#stSend.bodyHTML#</cfoutput></cfmailpart>
				</cfif>
			</cfmail>

			<cfset logEmail(argumentCollection=stSend, message="SENT: successfully sent using farcry core.") />
			<cfreturn "Success" />
			
			<cfcatch>
				<cfset logEmail(argumentCollection=stSend, message="ERROR: " & cfcatch.message) />
				<cfreturn cfcatch.message />
			</cfcatch>
		</cftry>
	</cffunction>
	
	
	<cffunction name="cleanArguments" returntype="string" output="true" access="public" hint="Cleans and validates SEND arguments (struct argument is modified) and returns 'Success' if the email is ready to go, and the error if not.">
		<cfargument name="mailArguments" type="struct" required="true" />
		
		<cfset var i = 0 />
		<cfset var spaces = "" />
		<cfset var email = "" />
		<cfset var emailList = "" />
		<cfset var white = "" />
		<cfset var bSend = false />
		
		<cfset arguments.mailArguments.type = "text/plain" />
		
		<!--- There MUST be an email body --->
		<cfif not len(arguments.mailArguments.bodyPlain) and not len(arguments.mailArguments.bodyHTML)>
			<cfset logEmail(argumentCollection=arguments.mailArguments, message="ERROR: No email body provided.") />
			<cfreturn "No email body provided" />
		</cfif>
		
		<!--- Remove spaces at the start of lines in the text version --->
		<cfif len(arguments.mailArguments.bodyPlain)>
			<cfset arguments.mailArguments.bodyPlain = trim(arguments.mailArguments.bodyPlain.replaceAll("(?m)^\s+(.*?)$","$1")) />
		</cfif>
		
		<cfif len(arguments.mailArguments.bodyHTML)>
			<cfset arguments.mailArguments.type = "text/html" />
			<cfset arguments.mailArguments.bodyHTML = trim(arguments.mailArguments.bodyHTML) />
		</cfif>
		
		<!--- Normalize attachment arguments into array --->
		<cfparam name="arguments.mailArguments.attachments" default="#arraynew(1)#" />
		<cfif structkeyexists(arguments.mailArguments,"attachment") and len(arguments.mailArguments.attachment)>
			<cfset arrayappend(arguments.mailArguments.attachments,arguments.mailArguments.attachment) />
			<cfset structdelete(arguments.mailArguments,"attachment") />
		</cfif>
		
		<!--- If the white list is defined then filter out all undefined addresses --->
		<cfif len(application.fapi.getConfig("general","emailWhitelist",""))>
			<cfloop list="#arguments.mailArguments.to#" index="email">
				<cfset bSend = false />

				<cfloop list="#application.fapi.getConfig("general","emailWhitelist")#" index="white" delimiters="#chr(10)#">
					<cfif len(email) AND findNoCase(white,email)>
						<cfset bSend = true />
						<cfbreak />
					</cfif>
				</cfloop>
			
				<cfif bSend>
					<cfset emailList = listappend(emailList,email) />
				<cfelse>
					<cfset logEmail(argumentCollection=arguments.mailArguments, message="WHITELIST: Not in email white list.") />
				</cfif>

			</cfloop>
			
			<cfset arguments.mailArguments.to = emailList />
		</cfif>
		
		<cfreturn "Success" />
	</cffunction>
	
	<cffunction name="logEmail" output="false" access="private" returntype="void" hint="Log emails">
		<cfargument name="message" type="string" required="true" />
		
		<cfset arguments.logType = "email" />
		
		<cfif isDefined("arguments.subject") AND isDefined("arguments.from") AND isDefined("arguments.to")>
			<cfset arguments.message = arguments.message & " '#arguments.subject#' From:'#arguments.from#' To:'#arguments.to#'" />
		</cfif>
		
		<cfset application.fc.lib.error.logData(log=application.fc.lib.error.collectRequestInfo(argumentCollection=arguments),bApplication=false,logFile="mailout",logType="information") />
	</cffunction>
	
</cfcomponent>