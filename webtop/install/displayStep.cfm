
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfif thistag.ExecutionMode EQ "Start">

	<cfparam name="attributes.step" default="ALL" >
	
	
	<cfset variables.DisplayStepProcess = false>
	
	<cfif session.stFarcryInstall.currentStep EQ attributes.step>
		<cfset variables.DisplayStepProcess = true>
	</cfif>

	<cfif NOT variables.DisplayStepProcess>
		<cfexit>
	</cfif>

</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<cfoutput><div style="text-align:right;margin-top:25px;"></cfoutput>
	<cfif attributes.step EQ 1>
		<cfoutput>
		<input type="submit" name="farcrySubmitButton" value="Next" />
		</cfoutput>
	<cfelseif attributes.step EQ 6>
		<cfoutput>
		<input type="submit" name="farcrySubmitButton" value="Previous" />
		<input type="submit" name="farcrySubmitButton" value="INSTALL NOW" />
		</cfoutput>
	<cfelse>
		<cfoutput>
		<input type="submit" name="farcrySubmitButton" value="Previous" />
		<input type="submit" name="farcrySubmitButton" value="Next" />
		</cfoutput>
	</cfif>
	<cfoutput></div></cfoutput>
</cfif>


