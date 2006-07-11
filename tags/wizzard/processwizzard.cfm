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
	
	<cfif isDefined("attributes.URL") AND len(attributes.URL)>
		<!--- If a return location is not sent, we want to delete the wizzard object and cflocate. --->
		<cfset stResult = oWizzard.deleteData(objectID=stWizzard.ObjectID) />				
		<cflocation url="#attributes.URL#" addtoken="false">
	</cfif>
</cfif>


<cfsetting enablecfoutputonly="no">
