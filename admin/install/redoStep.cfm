
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.field" type="string" />
	<cfparam name="attributes.errorTitle" type="string" />
	<cfparam name="attributes.errorDescription" type="string" />
	
	<cfset request.bFarcryInstallCompleteStep = false />
	
	<cfoutput>
	<script type="text/javascript">
		Ext.onReady(function(){	
			var errorField = Ext.get('#attributes.field#')
			errorField.boxWrap();
			errorField.insertHtml('afterEnd', '#jsstringFormat("<div><h3>#attributes.errorTitle#</h3><p>#attributes.errorDescription#</p></div>")#');
			
		})
	</script>
	</cfoutput>
</cfif>


