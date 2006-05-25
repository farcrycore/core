
<cfif thistag.ExecutionMode EQ "Start">

	<cfoutput>
			
			<input type="hidden" name="FarcryFormSubmitButton" id="FarcryFormSubmitButton" value="" />
			<input type="submit" value="Submit" /> <input type="button" value="Reset" onclick="valid.reset(); return false" />
		</form>
		
		<cfif Request.farcryForm.Validation EQ 1>
			<script type="text/javascript">
				var valid = new Validation('#Request.farcryForm.Name#');
			</script>
		</cfif>

		

	</cfoutput>
	
</cfif>