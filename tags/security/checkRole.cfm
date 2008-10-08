<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Check Role --->
<!--- @@description: Pass in the list of roles that have access and the inside of the tag will only be available to those that have those roles.  --->

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


<cfparam name="attributes.lRoles" default="" /><!--- Check this role to see if current user has access --->
<cfparam name="attributes.result" default="" /><!--- CALLER variable name to return the result of the check --->

<cfparam name="attributes.error" default="false" />
<cfparam name="attributes.errormessage" default="You don't have permission to view this page" />

<!--- <cfparam name="attributes.result" type="variablename" /> ---><!--- Set to a variable name to output result of check --->

<cfif thistag.ExecutionMode EQ "Start">
	<cfset permitted = true />
	
	<cfif listLen(attributes.lRoles)>
		<cfset lCurrentRoles = application.security.getCurrentRoles() />
		<cfloop list="#attributes.lRoles#" index="i">
			<cfif NOT listFindNoCase(lCurrentRoles, application.security.FACTORY.ROLE.getID(name="#trim(i)#"))>
				<cfset permitted = false />
			</cfif>
		</cfloop>
	</cfif>
	
	<!--- Save result of check --->
	<cfif len(attributes.result)>
		<cfset caller['#attributes.result#'] = permitted />
	</cfif>
	
	<cfif not permitted>
		<!--- If we get to this point, no permissions were granted - throw an error and exit the tag --->
		<cfif attributes.error>
			<!--- Translate and output error message --->
			<cfoutput>#application.rb.getResource("security.messages.#rereplace(attributes.errormessage,'[^\w]','','ALL')#@text",attributes.errormessage)#</cfoutput>
		</cfif>
		
		<cfsetting enablecfoutputonly="false" />
		<cfexit method="exittag" />
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />



