<cfcomponent displayName="Farcry Email Componet" hint="component to handle all email operations in the system">

	<cffunction name="fSend" access="public" returntype="struct" hint="returns file as a java image object">
		<cfargument name="stEmail" type="struct" required="true" hint="Structure to hold all mail variables">
		<!--- TODO: add extra functionality to the email cfc to handle multipart emails, bcc and cc or even another server  etc 
		REQUIRED: 	stEmail -	toAddress
							-	fromAdress
							-	content

		OPTIONAL:	stEmail	-	subject
							-	cc
							-	bcc
							-	format [html,text(default),multipart]
							-	server
		--->
		<cfset var stlocal = StructNew()>
		<cfset stlocal.stEmail = arguments.stEmail>
		<cfset stlocal.streturn = StructNew()>
		<cfset stlocal.streturn.returncode = 1>
		<cfset stlocal.streturn.returnmessage = "Email has been successfully sent">

		<cfif StructKeyExists(stlocal.stEmail,"toAddress") AND StructKeyExists(stlocal.stEmail,"fromAddress") AND StructKeyExists(stlocal.stEmail,"content")>
			<cftry>
				<cfmail to="#stlocal.stEmail.toAddress#" from="#stlocal.stEmail.fromAddress#" subject="#stlocal.stEmail.subject#">			
#stlocal.stEmail.content#
				</cfmail>

				<cfcatch>
					<cfset stlocal.streturn.returncode = 0>
					<cfset stlocal.streturn.returnmessage = "Sorry an error has occured while sending out the email. <br /> #cfcatch.message#">
				</cfcatch>
			</cftry>

		</cfif>
		<cfreturn stLocal.streturn>
	</cffunction>
</cfcomponent>