<cfcomponent output="false">
	
	
	<cffunction name="send" returntype="string" output="false" access="public">
		<cfargument name="to" type="string" required="true" hint="List of email address to send the email to" />
		<cfargument name="bcc" type="string" required="false" default="" hint="List of email addresses to BCC to" />
		<cfargument name="from" type="string" required="true" hint="Address the email is from" />
		<cfargument name="replyto" type="string" required="false" default="" hint="Reply address" />
		<cfargument name="failto" type="string" required="false" hint="Address to send delivery failure emails to" />
		<cfargument name="subject" type="string" required="true" hint="Subject of email" />
		<cfargument name="bodyPlain" type="string" required="false" default="" hint="Plain text version of email." />
		<cfargument name="bodyHTML" type="string" required="false" default="" hint="HTML version of email" />
		<cfargument name="attachments" type="array" required="false" default="#arraynew(1)#" hint="Array of absolute path filenames, to be attached to the email" />
		<cfargument name="attachment" type="string" required="false" default="" hint="If there is only one attachment, it can be attached with this argument" />
		
		<cfset var i = 0 />
		<cfset var spaces = "" />
		<cfset var type = "text/plain" />
		<cfset var cfhttp = structnew() />
		<cfset var stRequest = structnew() />
		<cfset var stResponse = structnew() />
		<cfset var stAttachment = structnew() />
		<cfset var oFile = createobject("component","farcry.core.packages.farcry.file") />
		<cfset var filecontent = "" />
		
		<!--- There MUST be an email body --->
		<cfif not len(arguments.bodyPlain) and not len(arguments.bodyHTML)>
			<cfset logEmailError(argumentCollection=arguments, message="No email body provided") />
			<cfreturn "No email body provided" />
		</cfif>
		
		<!--- Remove spaces at the start of lines in the text version --->
		<cfif len(arguments.bodyPlain)>
			<cfset arguments.bodyPlain = trim(arguments.bodyPlain.replaceAll("(?m)^\s+(.*?)$","$1")) />
		</cfif>
		
		<cfif len(arguments.bodyHTML)>
			<cfset type = "text/html" />
			<cfset arguments.bodyHTML = trim(arguments.bodyHTML) />
		</cfif>
		
		<!--- If the white list is active, block any emails not sent to it --->
		<cfif isdefined("application.config.general.emailWhitelist") and len(application.config.general.emailWhitelist) and (listfindnocase(application.config.general.emailWhitelist,listlast(arguments.to,"@")) or listfindnocase(application.config.general.emailWhitelist,arguments))>
			<cfset logEmailError(argumentCollection=arguments, message="Not on email white list") />
			
			<!--- This is dev functionality, and should be invisible to the rest of the application --->
			<cfreturn "Success" />
		</cfif>
			
		<cftry>
			<cfmail to="#trim(arguments.to)#" bcc="#trim(arguments.bcc)#" from="#trim(arguments.from)#" subject="#arguments.subject#" type="#type#">
				<cfloop from="1" to="#arraylen(arguments.attachments)#" index="i">
					<cfmailparam file="#arguments.attachments[i]#" />
				</cfloop>
				<cfif len(arguments.attachment)>
					<cfmailparam file="#arguments.attachment#" />
				</cfif>
				<cfif len(arguments.bodyPlain) and len(arguments.bodyHTML)>
					<cfmailpart type="plain" wraptext="74"><cfoutput>#arguments.bodyPlain#</cfoutput></cfmailpart>
					<cfmailpart type="html"><cfoutput>#arguments.bodyHTML#</cfoutput></cfmailpart>
				<cfelse>
					<cfoutput>#arguments.bodyPlain# #arguments.bodyHTML#</cfoutput>
				</cfif>
			</cfmail>
			
			<cfreturn "Success" />
			
			<cfcatch>
				<cfset logEmailError(argumentCollection=arguments, message=cfcatch.message) />
				<cfreturn cfcatch.message />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="logEmailError" output="false" access="private" returntype="void" hint="Logs email errors">
		<cfargument name="message" type="string" required="true" />
		
		<cfset arguments.logtype = "email" />
		<cfset application.fc.lib.error.logData(log=arguments,bApplication=false) />
	</cffunction>
	
</cfcomponent>