
<cfif not thistag.HasEndTag>

	<cfabort showerror="Does not have an end tag..." >

</cfif>

<cfif thistag.ExecutionMode EQ "Start">
	
	<cfparam name="attributes.title" default="" />
	<cfparam name="attributes.message" default="" />
	
	
	<cfoutput>
	<script type="text/javascript">
		Ext.onReady(function(){			
			Ext.farcryInstall.msg('#attributes.title#', '#attributes.message#');
		})
	</script>
	</cfoutput>
</cfif>

