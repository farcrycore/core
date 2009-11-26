<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">


<skin:loadCSS id="webtop" />

<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>FarCry: Overview Sidebar</title>
</cfoutput>

<cfif session.firstLogin>
	<!--- edit profile --->	
	<cfoutput>
	<script type="text/javascript">
		profileWin = window.open('#application.url.farcry#/conjuror/invocation.cfm?objectID=#session.dmProfile.objectID#&method=editOwn','content');
	</script>
	</cfoutput>
</cfif>
		
<cfoutput>
	</head>
	<body class="iframed-home">
	
	<!--- user profile stuff --->
	<h3>#application.rb.getResource("coapi.dmProfile.general.yourprofile@label","Your Profile")#</h3>
</cfoutput>

<!--- display profile summary for overview --->
<skin:view typename="dmProfile" objectid="#session.dmProfile.objectid#" webskin="displaySummary" />
	
<cfoutput>
	</body>
	</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">