<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Profile edit dialog --->
<!--- @@description: Creates an edit profile dialog window on page load --->

<cfoutput>
	<script type="text/javascript">
		alert('#jsstringformat(application.rb.formatRBString("coapi.dmProfile.general.firstlogin@alert",application.config.general.siteTitle,"This is the first time you've logged into {1}. Please complete the following profile form with your details."))#');
		profileWin = window.open('#application.url.farcry#/conjuror/invocation.cfm?objectID=#session.dmProfile.objectID#&method=displayUserEdit','edit_profile','width=550,height=500,left=200,top=100,scrollbars=1');
	</script>
</cfoutput>

<cfsetting enablecfoutputonly="false" />