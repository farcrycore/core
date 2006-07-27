<cfsetting enablecfoutputonly="yes">

<cfparam name="attributes.r_stWizzard" default="stWizzard" type="string" /><!--- Name of structure to return the stWizzard to the Caller. --->

<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>


<cfif thistag.ExecutionMode EQ "Start">

	<!--- Determine if we are processing the Action or the current step --->
	<cfif structKeyExists(attributes,"action")>
		<cfset FormFieldToProcess = "FarcryFormSubmitButton" />
		<cfset StringToCheck = attributes.action />
	<cfelse>
		<cfset FormFieldToProcess = "currentWizzardStep" />
		<cfparam name="attributes.step" default="*">
		<cfset StringToCheck = attributes.step />
	</cfif>

	<cfset variables.EnterWizzardProcess = false>
	
	<!--- If the String to check is an empty string, we accept everything. --->
	<cfif not len(StringToCheck)>
		<cfset StringToCheck = "*" />
	</cfif>
	
	<cfif structKeyExists(FORM, FormFieldToProcess) AND len(FORM[FormFieldToProcess])>
		<cfloop list="#StringToCheck#" index="i">
			<!--- If it finds any of the things to be processed, or it is a * or if its empty and therefore to process anything --->
			<cfif listFindNoCase(FORM[FormFieldToProcess],i) OR i EQ "*" >
				<cfset variables.EnterWizzardProcess = true>
			</cfif>
		</cfloop>
	</cfif>

	<!--- Read the Wizzard --->
	<cfif variables.EnterWizzardProcess and structKeyExists(form, 'WizzardID') and len(form.wizzardID)>
		<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath) />
		<cfset stWizzard = oWizzard.Read(WizzardID=form.wizzardID)>
		<cfloop list="#attributes.r_stWizzard#" index="i">
			<cfset Caller[i] = stWizzard />
		</cfloop>
	<cfelse>
		<cfsetting enablecfoutputonly="no">
		<cfexit>
	</cfif>

</cfif>


<cfif thistag.ExecutionMode EQ "End">
	
	<!--- Have we been requested to Save the wizzard object? --->
	<cfif isDefined("attributes.SaveWizzard") and attributes.SaveWizzard EQ "true">
		<cfloop list="#structKeyList(stWizzard.Data)#" index="i">
			<cfset stProperties = stWizzard.Data[i]>
			<cfset typename = oWizzard.FindType(ObjectID=i) />				
			<cfset otype = createObject("component",application.types["#stWizzard.Data[i]['typename']#"].typepath) />
			<cfset stResult = otype.setData(stProperties=stProperties) />
		</cfloop>
		
		<!--- Wizzard data has been saved, so flag to remove the wizzard --->	
		<cfset attributes.RemoveWizzard = true />
	</cfif>
		
	<!--- Have we been requested to remove the wizzard object? --->
	<cfif isDefined("attributes.RemoveWizzard") and attributes.RemoveWizzard EQ "true">
		
		<cfset stResult = oWizzard.deleteData(objectID=stWizzard.ObjectID) />	
		
		<!--- Do not allow any further processing on this wizzard. --->
		<cfset structDelete(FORM, "FarcryFormSubmitButton") />	
		<cfset structDelete(FORM, "currentWizzardStep") />		
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
	
		<cfset Request.FarcryWizzardOnExitRun = true />

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
