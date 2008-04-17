
<cfif thistag.ExecutionMode EQ "Start">


			
		<cfoutput>
			<input type="hidden" name="FarcryFormPrefixes" value="" />
			<input type="hidden" name="FarcryFormSubmitButton" id="FarcryFormSubmitButton" value="" /><!--- This is an empty field so that if the form is submitted, without pressing a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
			<input type="hidden" name="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" id="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" value="" /><!--- This contains the name of the farcry button that was clicked --->
			<input type="hidden" name="FarcryFormSubmitted"  value="#Request.farcryForm.Name#" /><!--- Contains the name of the farcry form submitted --->
			<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" /><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:farcryButton --->
		
			<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#Request.farcryForm.Name#" value="#Request.farcryForm.Validation#" /><!--- Let the form submission know if it to perform serverside validation --->

		</form>
		
		<cfif Request.farcryForm.Validation EQ 1>
			<script type="text/javascript">
				var realeasyvalidation#Request.farcryForm.Name# = new Validation('#Request.farcryForm.Name#', {onSubmit:false});
			</script>
		</cfif>

		<cfif Request.farcryForm.bAjaxSubmission>
			</div>
		</cfif>
		

	</cfoutput>
	
</cfif>