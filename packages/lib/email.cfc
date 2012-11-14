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
		<cfargument name="variables" type="any" required="false" default="#arraynew(1)#" hint="Resource translation variables" />
		
		<cfset var i = 0 />
		<cfset var spaces = "" />
		<cfset var type = "text/plain" />
		<cfset var stSend = duplicate(arguments) />
		<cfset var result = cleanArguments(stSend) />
		<cfset var tmp = "" />
		
		<cfif result neq "Success">
			<cfreturn result />
		<cfelseif not len(stSend.to)>
			<!--- Whitelist removed all to addresses - just return out --->
			<cfreturn "Success" />
		</cfif>
		
		<cfif len(arguments.rbkey)>
			<cfif not isarray(attributes.variables)>
				<cfset tmp = arraynew(1) />
				<cfset tmp[1] = attributes.variables />
				<cfset attributes.variables = tmp />
			</cfif>
			
			<cfloop collection="#attributes#" item="i">
				<cfif refind("var\d+",i)>
					<cfset attributes.variables[mid(thisattr,4,len(i))] = attributes[i] />
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
				<cfelse>
					<cfoutput>#stSend.bodyPlain# #stSend.bodyHTML#</cfoutput>
				</cfif>
			</cfmail>
			
			<cfreturn "Success" />
			
			<cfcatch>
				<cfset logEmailError(argumentCollection=stSend, message=cfcatch.message) />
				<cfreturn cfcatch.message />
			</cfcatch>
		</cftry>
	</cffunction>
	
	
	<cffunction name="cleanArguments" returntype="string" output="false" access="public" hint="Cleans and validates SEND arguments (struct argument is modified) and returns 'Success' if the email is ready to go, and the error if not.">
		<cfargument name="mailArguments" type="struct" required="true" />
		
		<cfset var i = 0 />
		<cfset var spaces = "" />
		<cfset var email = "" />
		<cfset var emailList = "" />
		
		<cfset arguments.mailArguments.type = "text/plain" />
		
		<!--- There MUST be an email body --->
		<cfif not len(arguments.mailArguments.bodyPlain) and not len(arguments.mailArguments.bodyHTML)>
			<cfset logEmailError(argumentCollection=arguments.mailArguments, message="No email body provided") />
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
		
		<!--- If the white list is active, block any emails not sent to it --->
		<cfif isdefined("application.config.general.emailWhitelist") and len(application.config.general.emailWhitelist)>
			<cfloop list="#arguments.mailArguments.to#" index="email">
				<cfif listfindnocase(application.config.general.emailWhitelist,listlast(email,"@")) or listfindnocase(application.config.general.emailWhitelist,email)>
					<cfset logEmailError(argumentCollection=arguments.mailArguments, message="Not on email white list [#email#]") />
				<cfelse>
					<cfset emailList = listappend(emailList,email) />
				</cfif>
			</cfloop>
			<cfset arguments.mailArguments.to = emailList />
		</cfif>
		
		<cfreturn "Success" />
	</cffunction>
	
	<cffunction name="logEmailError" output="false" access="private" returntype="void" hint="Logs email errors">
		<cfargument name="message" type="string" required="true" />
		
		<cfset arguments.logtype = "email" />
		<cfset application.fc.lib.error.logData(log=application.fc.lib.error.collectRequestInfo(argumentCollection=arguments),bApplication=false) />
	</cffunction>
	
</cfcomponent>