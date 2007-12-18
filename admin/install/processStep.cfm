
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.step" default="ALL" >
	
	
	<cfset variables.EnterStepProcess = false>
	
	<cfif structKeyExists(form, "farcrySubmitButton")>
		<cfif attributes.step EQ "ALL">
			<cfset variables.EnterStepProcess = true>
		<cfelseif structKeyExists(form, "currentStep") AND form.currentStep EQ attributes.step>
			<cfset variables.EnterStepProcess = true>
		</cfif>
	</cfif>

	<cfif NOT variables.EnterStepProcess>
		<cfexit>
	</cfif>

</cfif>

<cfif thistag.ExecutionMode EQ "END">

	<cfparam name="request.bFarcryInstallCompleteStep" default="true" />
	
	<!------------------------------------------------------------------------------------------------------ 
	ONLY MOVE TO REQUESTED STEP IF CURRENT STEP IS COMPLETE AND WE ARE FINISHED PROCESSING THE ACUTAL STEP.
	 ------------------------------------------------------------------------------------------------------>
	<cfif request.bFarcryInstallCompleteStep AND  attributes.step NEQ "ALL">
		<!--- Update the completed steps to include the one just posted. --->
		<cfif not listFindNoCase(session.stFarcryInstall.lCompletedSteps, form.currentStep)>
			<cfset session.stFarcryInstall.lCompletedSteps = listAppend(session.stFarcryInstall.lCompletedSteps, form.currentStep) />
		</cfif>
		
		<!--- Set to next step --->
		<cfif form.farcrySubmitButton EQ "Next">
			<cfset session.stFarcryInstall.currentStep = form.currentStep + 1 />
		</cfif>
		
		<!--- Set to previous step --->
		<cfif form.farcrySubmitButton EQ "Previous">
			<cfset session.stFarcryInstall.currentStep = form.currentStep - 1 />
		</cfif>
		
		<!--- Set to requested step only if it has previously been completed. This protects against session timeouts --->
		<cfif form.farcrySubmitButton EQ "GoToStep" and isNumeric(form.GoToStep)>
			<cfif listFindNoCase(session.stFarcryInstall.lCompletedSteps, form.GoToStep)>
				<cfset session.stFarcryInstall.currentStep = form.GoToStep />
			<cfelse>
				<cfset session.stFarcryInstall.currentStep = 1 />
			</cfif>
		</cfif>
		
	</cfif>
</cfif>


