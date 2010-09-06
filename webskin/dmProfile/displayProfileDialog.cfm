<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Profile edit dialog --->
<!--- @@description: Creates an edit profile dialog window on page load --->

<cfoutput>
	<script type="text/javascript">
		profileWin = window.open('#application.url.farcry#/conjuror/invocation.cfm?objectID=#session.dmProfile.objectID#&typename=dmProfile&method=editOwn','content','width=550,height=500,left=200,top=100,scrollbars=1');
	</script>
</cfoutput>

<cfsetting enablecfoutputonly="false" />