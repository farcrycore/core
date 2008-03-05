<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<body bgcolor="#789">
<cfimport taglib="/farcry/core/tags/" prefix="farcry">
<div class="countDown">Logged in as: <cfoutput><strong>#session.dmSec.authentication.userlogin#</strong><br></cfoutput>
<form name="test" style="display:inline"><farcry:countdown Formname="test" Timeout="60"><cfoutput>#application.rb.getResource("sessionRemaining")#</cfoutput></form></div>

<!--- setup footer --->
<admin:footer>
