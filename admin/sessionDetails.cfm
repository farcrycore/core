<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<body bgcolor="#789">
<cfimport taglib="/farcry/tags/" prefix="farcry">
<div class="countDown">Logged in as: <cfoutput><strong>#request.stLoggedInUser.userlogin#</strong><br></cfoutput>
<form name="test" style="display:inline"><farcry:countdown Formname="test" Timeout="60">remaining in session</form></div>

<!--- setup footer --->
<admin:footer>
