<cfsetting enablecfoutputonly="yes">

<cfparam name="attributes.r_stwizard" default="stwizard" type="string" /><!--- Name of structure to return the stwizard to the Caller. --->
<cfparam name="attributes.excludeAction" default="" ><!--- Any actions to exclude --->


<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<cfif StructKeyExists(FORM, 'FarcryFormSubmitted') AND StructKeyExists(FORM, 'FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#') AND FORM['FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#'] NEQ "">
		<cfset FORM.FarcryFormSubmitButton = evaluate("FORM.FarcryFormSubmitButtonClicked#FORM.FarcryFormSubmitted#") />
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
	
	<cfparam name="form.FarcryFormSubmitButton" default="" />	
	
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
		
		
		
		<cfset owizard = createObject("component",application.stcoapi['dmWizard'].packagepath) />
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
			<cfset otype = createObject("component",application.stcoapi["#stwizard.Data[i]['typename']#"].packagepath) />
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
	
		<cfset Request.FarcryFormOnExitRun = true />
		
		<cfif structKeyExists(caller, "onExitProcess")>
			<cfset stLocal.onExitProcess = duplicate(caller.onExitProcess) />
		</cfif>
		
		<!--- 
			the edit view could be called through a function in which case the onExit struct will be in the arguments scope
			We should check for this first
		 --->
		<cfif not structKeyExists(caller, "onExitProcess")>
			<cfif structKeyExists(caller, "arguments") AND structKeyExists(caller.arguments, "onExitProcess")>
				<cfset stLocal.onExitProcess = caller.arguments.onExitProcess />		
			</cfif>
		</cfif>
		
		<!--- If the onExit doesnt exist, default to Refreshing the page. --->		
		<cfparam name="stLocal.onExitProcess" default="refresh" />
		
		<!--- If the onExit is not a struct we assume it is a URL to redirect to and we convert it too a struct. --->
		<cfif NOT isStruct(stLocal.onExitProcess)>
			<cfset stLocal.stOnExit = structNew() />
			<cfset stLocal.stOnExit.Type = "URL" />
			<cfset stLocal.stOnExit.Content = stLocal.onExitProcess />
		<cfelse>
			<cfset stLocal.stOnExit = stLocal.onExitProcess />
		</cfif>

		<!--- Events can be of type HTML, Function, URL(default) --->
		<cfswitch expression="#stLocal.stOnExit.Type#">
			
			<cfcase value="HTML">
				<cfif structKeyExists(stLocal.stOnExit, "Content")>
					<cfoutput>#stLocal.stOnExit.Content#</cfoutput>
				</cfif>
			</cfcase>
									
			<cfcase value="URL">
				<cfif structKeyExists(stLocal.stOnExit, "Content")>
					<cfif len(stLocal.stOnExit.Content)>
						<cfif stLocal.stOnExit.Content EQ "refresh">
							<cflocation url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" addtoken="false">
						<cfelse>
							<cflocation url="#stLocal.stOnExit.Content#" addtoken="false">
						</cfif>
					<cfelse>
						<!--- DO NOTHING --->
					</cfif>
				</cfif>
			</cfcase>				
		
		</cfswitch>
	
	</cfif>
	
</cfif>


<cfsetting enablecfoutputonly="no">
