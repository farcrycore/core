
<cfif thistag.ExecutionMode EQ "Start">

	<cfoutput>
			
			<input type="hidden" name="FarcryFormSubmitButton" id="FarcryFormSubmitButton" value="" />
			
		</form>
		
		<cfif Request.farcryForm.Validation EQ 1>
			<script type="text/javascript">
				var valid = new Validation('#Request.farcryForm.Name#');
			</script>
		</cfif>

		

	</cfoutput>
	
</cfif>