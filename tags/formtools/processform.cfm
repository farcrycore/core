
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.action" default="*" >
	<cfparam name="attributes.excludeAction" default="" >
	
	<cfset variables.EnterFormProcess = false>
	
	<!---  --->
	<cfif isDefined("FORM.FarcryFormSubmitted") AND isDefined("#FORM.FarcryFormSubmitted#FarcryFormSubmitButtonClicked") AND len(evaluate("#FORM.FarcryFormSubmitted#FarcryFormSubmitButtonClicked"))>
		<cfset FORM.FarcryFormSubmitButton = evaluate("#FORM.FarcryFormSubmitted#FarcryFormSubmitButtonClicked") />
	</cfif>
	
	<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton)>

		<cfif listFindNoCase(attributes.action,FORM.FarcryFormSubmitButton) OR attributes.action EQ "*">
			<cfif NOT listFindNoCase(attributes.excludeAction,FORM.FarcryFormSubmitButton)>
				<cfset variables.EnterFormProcess = true />
			</cfif>
		</cfif>

	</cfif>

	<cfif NOT variables.EnterFormProcess>
		<cfexit>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	<!--- Was a simple URL redirect requested? --->
	<cfif isDefined("attributes.URL") AND len(attributes.URL)>

		<cfif attributes.URL EQ "refresh">
			<cflocation url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false">
		<cfelse>
			<cflocation url="#attributes.URL#" addtoken="false">
		</cfif>
		
	</cfif>
	

	
	<!--- have we requested to exit this webskin? --->
	<cfif isDefined("attributes.Exit") AND attributes.Exit>
	
		<cfset Request.FarcryFormOnExitRun = true />

		<!--- 
			the edit view could be called through a function in which case the onExit struct will be in the arguments scope
			We should check for this first
		 --->
		<cfif NOT structKeyExists(caller, "onExit")>
			<cfif structKeyExists(caller, "arguments") AND structKeyExists(caller.arguments, "onExit")>
				<cfset caller.onExit = caller.arguments.onExit />
			</cfif>
		</cfif>
		
		<!--- If the onExit doesnt exist, default to Refreshing the page. --->
		<cfparam name="Caller.onExit" default="Refresh" />
		
		<!--- If the onExit is not a struct we assume it is a URL to redirect to and we convert it too a struct. --->
		<cfif NOT isStruct(Caller.onExit)>
			<cfset variables.stOnExit = structNew() />
			<cfset variables.stOnExit.Type = "URL" />
			<cfset variables.stOnExit.Content = Caller.onExit />
		<cfelse>
			<cfset variables.stOnExit = Caller.onExit />
		</cfif>
		
		<!--- Events can be of type HTML, Function, URL(default) --->
		<cfswitch expression="#stOnExit.Type#">
			
			<cfcase value="HTML">
				<cfif structKeyExists(stOnExit, "Content")>
					<cfoutput>#stOnExit.Content#</cfoutput>
				</cfif>
			</cfcase>

			<cfcase value="Function">
				<!--- 
				TODO: This should call the function on the current Object Type.
				It may Return HTML.
				 --->
			</cfcase>

			<cfcase value="Log">
				<!--- 
				TODO: This should log the content.
				 --->
			</cfcase>
						
			<cfcase value="URL">
				<cfif structKeyExists(stOnExit, "Content")>
					<cfif stOnExit.Content EQ "refresh">
						<cflocation url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false">
					<cfelse>
						<cflocation url="#stOnExit.Content#" addtoken="false">
					</cfif>
				</cfif>
			</cfcase>				
		
		</cfswitch>
	
	</cfif>
</cfif>