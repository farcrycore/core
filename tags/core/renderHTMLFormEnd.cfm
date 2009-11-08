<cfif thistag.ExecutionMode EQ "Start">

		<!--- If XMTHML, then we need the trailing slash --->
		<cfset tagEnding = application.fapi.getDocType().tagEnding />
			
		<cfoutput>
			<input type="hidden" name="FarcryFormPrefixes" value="" #tagEnding#>
			<input type="hidden" name="FarcryFormSubmitButton" value="" #tagEnding#><!--- This is an empty field so that if the form is submitted, without pressing a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
			<input type="hidden" name="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" id="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" class="fc-button-clicked" value="" #tagEnding#><!--- This contains the name of the farcry button that was clicked --->
			<input type="hidden" name="FarcryFormSubmitted"  value="#Request.farcryForm.Name#" #tagEnding#><!--- Contains the name of the farcry form submitted --->
			<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" #tagEnding#><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:farcryButton --->
		
			<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#Request.farcryForm.Name#" class="fc-server-side-validation" value="#Request.farcryForm.Validation#" #tagEnding#><!--- Let the form submission know if it to perform serverside validation --->

		</form>
		
		<cfif Request.farcryForm.Validation EQ 1>
			<script type="text/javascript">
				var realeasyvalidation#Request.farcryForm.Name# = new Validation('#Request.farcryForm.Name#', {onSubmit:false});
			</script>
		</cfif>

		<cfif Request.farcryForm.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
			</div>
		</cfif>
		

	</cfoutput>
	
</cfif>