
<cfif thistag.ExecutionMode EQ "Start">
		<cfoutput>
			<div>
				<!--- 
					WARNING: To support different doctypes there are two sections here
					that do the same thing with just different tag endings.   IF you
					edit this code, be sure do do both places - or come up with a
					better way to do this :)
				--->
				<cfif application.fapi.getDocType().type eq "xhtml">
					<input type="hidden" name="FarcryFormPrefixes" value="" />
					
					<!--- This is an empty field so that if the form is submitted, without pressing 
						a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
					<input type="hidden" name="FarcryFormSubmitButton" value="" />
					
					<!--- This contains the name of the farcry button that was clicked --->
					<input type="hidden" name="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" 
						id="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" 
						class="fc-button-clicked" value="" />
					<!--- Contains the name of the farcry form submitted --->
					<input type="hidden" name="FarcryFormSubmitted"  value="#Request.farcryForm.Name#" />
					
					<!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:farcryButton --->
					<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" />
					
					<!--- Let the form submission know if it to perform serverside validation --->
					<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#Request.farcryForm.Name#" 
						class="fc-server-side-validation" value="#Request.farcryForm.Validation#" />
				<cfelse>
					<input type="hidden" name="FarcryFormPrefixes" value="">
					<input type="hidden" name="FarcryFormSubmitButton" value="">
					<input type="hidden" name="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" 
						id="FarcryFormSubmitButtonClicked#Request.farcryForm.Name#" 
						class="fc-button-clicked" value="">
					<input type="hidden" name="FarcryFormSubmitted"  value="#Request.farcryForm.Name#">
					<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="">
					<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#Request.farcryForm.Name#" 
						class="fc-server-side-validation" value="#Request.farcryForm.Validation#">
				</cfif>
			
			</div>
		</form>
		
		<cfif Request.farcryForm.Validation EQ 1>
			<script type="text/javascript">
				var realeasyvalidation#Request.farcryForm.Name# = new Validation('#Request.farcryForm.Name#', {onSubmit:false});
			</script>
		</cfif>

		<cfif Request.farcryForm.bAjaxSubmission><!---  AND NOT request.mode.ajax --->
			</div>
		</cfif>
		
	</cfoutput>
	
</cfif>