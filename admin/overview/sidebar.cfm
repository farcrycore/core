<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>FarCry: Overview Sidebar</title>
<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
</cfoutput>
	<cfif session.firstLogin>
	    <cfoutput>
	    <script type="text/javascript">
	    profileWin = window.open('#application.url.farcry#/edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=385,height=385,left=200,top=100');
	    alert('#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].firstTimeLoginBlurb,"#application.config.general.siteTitle#")#');
	    profileWin.focus();
	    </script>
	    </cfoutput>
	    <cfset session.firstLogin = "false">
	</cfif>
<cfoutput>
</head>
<body class="iframed-home">

<!--- user profile stuff --->
<h3>#application.adminBundle[session.dmProfile.locale].yourProfile#</h3>
</cfoutput>

<cfscript>
	// display profile details
	oProfile = createObject("component", application.types.dmProfile.typePath);
	// if profile is dead for user, create one and set to session scope
	if (NOT StructKeyExists(session.dmProfile,"firstname"))
		session.dmprofile=oProfile.createprofile(session.dmprofile);
	// display profile summary for overview
	writeoutput(oProfile.displaySummary(session.dmProfile.objectID));
</cfscript>

<cfoutput>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">
