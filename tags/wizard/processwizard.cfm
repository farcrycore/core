<cfsetting enablecfoutputonly="yes">

<cfparam name="attributes.r_stwizard" default="stwizard" type="string" /><!--- Name of structure to return the stwizard to the Caller. --->
<cfparam name="attributes.excludeAction" default="" ><!--- Any actions to exclude --->


<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<cfif isDefined("FORM.FarcryFormSubmitted") AND isDefined("FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#") AND len(evaluate("FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#"))>
		<cfset FORM.FarcryFormSubmitButton = evaluate("FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#") />
	</cfif>
	
	<!--- Determine if we are processing the Action or the current step --->
	<cfif structKeyExists(attributes,"action")>
		<cfset FormFieldToProcess = "FarcryFormSubmitButton" />
		<cfset StringToCheck = attributes.action />
	<cfelse>
		<cfset FormFieldToProcess = "currentwizardStep" />
		<cfparam name="attributes.step" default="*">
		<cfset StringToCheck = attributes.step />
	</cfif>

	<cfset variables.EnterwizardProcess = false>
	
	<!--- If the String to check is an empty string, we accept everything. --->
	<cfif not len(StringToCheck)>
		<cfset StringToCheck = "*" />
	</cfif>
	
	<cfif structKeyExists(FORM, FormFieldToProcess) AND len(FORM[FormFieldToProcess])>
		<cfloop list="#StringToCheck#" index="i">
			<!--- If it finds any of the things to be processed, or it is a * or if its empty and therefore to process anything --->
			<cfif listFindNoCase(FORM[FormFieldToProcess],i) OR i EQ "*" >
				
				<!--- Check to make sure the farcry form button that has been pressed is not in the exclude list --->
				<cfif NOT listFindNoCase(attributes.excludeAction, form.farcryformsubmitbutton)>
					<cfset variables.EnterwizardProcess = true>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>

	<!--- Read the wizard --->
	<cfif variables.EnterwizardProcess and structKeyExists(form, 'wizardID') and len(form.wizardID)>
		
		
		
		<cfset owizard = createObject("component",application.types['dmWizard'].typepath) />
		<cfset stwizard = owizard.Read(wizardID=form.wizardID)>
		<cfloop list="#attributes.r_stwizard#" index="i">
			<cfset Caller[i] = stwizard />
		</cfloop>
	<cfelse>
		<cfsetting enablecfoutputonly="no">
		<cfexit>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	
	<!--- Have we been requested to Save the wizard object? --->
	<cfif isDefined("attributes.Savewizard") and attributes.Savewizard EQ "true">
		<cfloop list="#structKeyList(stwizard.Data)#" index="i">
			<cfset stProperties = stwizard.Data[i]>
			<cfset stProperties.locked = "0" />
			<cfset stProperties.lockedby = ""/>
			<cfset typename = owizard.FindType(ObjectID=i) />				
			<cfset otype = createObject("component",application.types["#stwizard.Data[i]['typename']#"].typepath) />
			<cfset stResult = otype.setData(stProperties=stProperties) />
		</cfloop>
		
		<!--- wizard data has been saved, so flag to remove the wizard --->	
		<cfset attributes.Removewizard = true />
	</cfif>
		
	<!--- Have we been requested to remove the wizard object? --->
	<cfif isDefined("attributes.Removewizard") and attributes.Removewizard EQ "true">
		
		
		<cfset stResult = owizard.deleteData(objectID=stwizard.ObjectID) />	
		
		<!--- Do not allow any further processing on this wizard. --->
		<cfset structDelete(FORM, "FarcryFormSubmitButton") />	
		<cfset structDelete(FORM, "currentwizardStep") />		
	</cfif>
	
	
	
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
	
		<cfset Request.FarcrywizardOnExitRun = true />

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


<cfsetting enablecfoutputonly="no">
