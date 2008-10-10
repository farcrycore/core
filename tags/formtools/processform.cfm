
<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.action" default="*" >
	<cfparam name="attributes.rbkey" default="" >
	<cfparam name="attributes.excludeAction" default="" >
	
		
	<cfset variables.EnterFormProcess = false>

	<cfif structKeyExists(form, "FarcryFormSubmitted")>
	
		<!--- I18 conversion of action and exludeAction lists --->
		<cfloop from="1" to="#listlen(attributes.action)#" index="i">
			<cfif listlen(attributes.rbkey) lt i>
				<cfset listsetat(attributes.action,i,application.rb.getResource('forms.buttons.#rereplacenocase(listgetat(attributes.action,i),"[^\w\d]","","ALL")#@label',listgetat(attributes.action,i))) />
			<cfelse>
				<cfset listsetat(attributes.action,i,application.rb.getResource('#listgetat(arguments.rbkey,i)#@label',listgetat(attributes.action,i))) />
			</cfif>
		</cfloop>
		<cfloop from="1" to="#listlen(attributes.excludeAction)#" index="i">
			<cfif listlen(attributes.rbkey) lt listlen(attributes.action) + i>
				<cfset listsetat(attributes.excludeAction,i,application.rb.getResource('forms.buttons.#rereplacenocase(listgetat(attributes.excludeAction,i),"[^\w\d]","","ALL")#@label',listgetat(attributes.excludeAction,i))) />
			<cfelse>
				<cfset listsetat(attributes.excludeAction,i,application.rb.getResource('#listgetat(arguments.rbkey,listlen(attributes.action) + i)#@label',listgetat(attributes.excludeAction,i))) />
			</cfif>
		</cfloop>

		<cfparam name="form.FarcryFormSubmitButton" default="" />	
		
		<cfif structKeyExists(form, "FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#") AND len(form["FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#"])>
			<cfset FORM.FarcryFormSubmitButton = form["FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#"] />
		</cfif>
		
		<cfif NOT len(form.FarcryFormSubmitButton)>
			<cfloop collection="#form#" item="fieldname">
				<cfif left(fieldname,23) EQ "FarcryFormSubmitButton=">
					<cfset form.FarcryFormSubmitButton = listAppend(form.FarcryFormSubmitButton,mid(fieldname,24,len(fieldname)-23)) />
				</cfif>
			</cfloop>
			<!--- IE 6 and below submits ALL <button> tags on a form regardless of which one was clicked. --->
			<cfif listLen(form.FarcryFormSubmitButton) GT 1>
				<cfabort showerror="IE 6 and below must have javascript enabled to submit forms correctly." />
			</cfif>
		</cfif>
		
			
		<cfif isDefined("FORM.FarcryFormSubmitButton") AND len(FORM.FarcryFormSubmitButton)>
	
			<cfif listFindNoCase(attributes.action,FORM.FarcryFormSubmitButton) OR attributes.action EQ "*">
				<cfif NOT listFindNoCase(attributes.excludeAction,FORM.FarcryFormSubmitButton)>
					<cfset variables.EnterFormProcess = true />
				</cfif>
			</cfif>
	
		</cfif>
	</cfif>
	
	
	<cfif NOT variables.EnterFormProcess>
		<cfexit>
	<cfelse>
		
		<cfif structKeyExists(session, "stFarCryFormSpamProtection") AND isDefined("FORM.FarcryFormSubmitted")>
			<cfif structKeyExists(session.stFarCryFormSpamProtection, "#form.farcryFormSubmitted#")>

				<!--- The form was submitted by this session --->
				<cfif structKeyExists(session.stFarCryFormSpamProtection["#form.farcryFormSubmitted#"], FORM.FarcryFormSubmitButton) AND session.stFarCryFormSpamProtection["#form.farcryFormSubmitted#"]["#FORM.FarcryFormSubmitButton#"].bSpamProtect EQ true>
					<!--- Supposed to enter form process but form protection is on so we need to protect --->
					<cfset cffp = CreateObject("component","farcry.core.webtop.cffp.cfformprotect.cffpVerify").init(ConfigPath="#application.path.core#/webtop/cffp/cfformprotect", stConfig=session.stFarCryFormSpamProtection["#form.farcryFormSubmitted#"]["#FORM.FarcryFormSubmitButton#"]) />

					<!--- now we can test the form submission --->
					<cfif NOT Cffp.testSubmission(form)>
						<!--- The submission has failed the form test. --->
						<cfset variables.EnterFormProcess = false>
						<cfexit>
					</cfif>
				</cfif>		
			<cfelse>

				<!--- The submission of the form was not made by the correct session. --->
				<cfset variables.EnterFormProcess = false>
				<cfexit>
			</cfif>	
		</cfif>	
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
					<cfif not len(stOnExit.Content) OR stOnExit.Content EQ "refresh">
						<cflocation url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false">
					<cfelse>
						<cflocation url="#stOnExit.Content#" addtoken="false">
					</cfif>
				</cfif>
			</cfcase>				
		
		</cfswitch>
	
	</cfif>
</cfif>