<cfsetting enablecfoutputonly="Yes">

<cfoutput>
<HTML>
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
<HEAD> 

<!--- <STYLE TYPE="text/css">
BODY
{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9pt;
	color: ##FFFFFF;
}

INPUT
{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9pt;
}

TD
{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9pt;
	font-style: normal;
	top: 0px;
}

.Button
{
	font-size: 7pt;
	color: ##000000;
	background: ##D3D3D3;
	cursor: hand;
}

.Text 
{
	color: ##000000;
}
.W150
{
	position: relative;
	width: 150px;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8pt;
}
</STYLE> --->

</HEAD>

<body onLoad="ol();" style="background-color:##CCC;">

</cfoutput>

<cfset returnUrl = URLDecode(url.returnUrl)>
<cfset returnUrl = replace( returnUrl, "logout=1", "" )>
<cfset returnUrl = replace( returnUrl, "&&", "" )>

<cfif isDefined("form.ADSI")>
	<cfoutput>
	<script>
		window.location="securedLogin/Login.cfm?returnUrl=#URLEncodedFormat(returnUrl)#";
	</script>
	<cfabort>
	</cfoutput>
</cfif>

<cfparam name="error" default="Please login with your details below.">

<cfif isDefined("form.Normal")>
	<cftry>
		<cf_dmSec_login userlogin="#form.userLogin#" userpassword="#form.password#" bNoADSI="1" bAudit="1">
		<cfcatch type="dmSec">
			<cfset error="<font color=##cc0000><b>Login failed:</b></font> Your username or password is wrong.">
		</cfcatch>
	</cftry>
</cfif>

<!--- if the user is loggedin then set up session and redirect --->
<cf_dmSec_loggedIn r_bLoggedIn="bLoggedIn">
<cfif bLoggedIn>
	<!--- dmSecMX automatically sets up session.dmSec.authentication structure --->
	<!--- check for ADMIN permissions --->
	<cf_dmSec2_PermissionCheck 
		permissionName="Admin" 
		reference1="PolicyGroup" 
		r_iState="iAdminState">
	
	<cfif iAdminState eq 1>
		<!--- 
		set up CFMX security login
		TODO
		um.. actually do this properly or rip it out entirely
		 
		<cflogin>
			<cfloginuser name="#request.stLoggedInUser.userlogin#" password="#request.stLoggedInUser.userlogin#" roles="sitemanager,contenteditor">
		</cflogin> 
		--->
		
		<!--- turn on admin permissions --->
		<cfset request.mode.bAdmin = 1>
		<cfset session.dmSec.authentication.bAdmin = 1>
	</cfif>

	<!--- relocate to original location --->
	<cflocation url="#returnUrl#" addtoken="No">
	<cfabort>
</cfif>


<!--- set message [error], if user has logged out --->
<cfif not len(error) AND returnUrl contains "logout=1">
	<cfset error="<font color=##00DD00><b>OK:</b></font> You have successfully logged out.">
</cfif>

<cfoutput>

<script>
function ol()
{
	el=document.getElementById('spectrausername');
	if ( el.value.length==0 ) el.focus();
}
</script>

<form action="#cgi.script_name#?#cgi.query_string#" method="POST">
<div id="login">
	<div id="loginheader">#error#</div>
	<div id="loginbody">
		<div style="float:left; position: absolute; top:50px; left: 20px;">
			<div class="title">FarCry</div><br>
			<div class="description">tell it to someone who cares</div>
		</div>
		<div style="position: absolute; top:50px; right: 30px;">
			<table border="0" cellspacing="0" cellpadding="0">
	        <TR>
    	        <TD class="Text">User&nbsp;Name&nbsp;</TD>
        	    <TD><input type="text" name="userLogin" id="spectrausername" size="15" maxlength="20" class="W150"></TD>
	        </TR>
    		<TR>
            	<TD class="Text">Password&nbsp;</TD>
	            <TD><input type="password" name="password" size="15" maxlength="20" class="W150"></TD>
    	    </TR>
        	<TR>
				<TD COLSPAN="2">&nbsp;</TD>
			</TR>
    		<TR>
            	<TD>&nbsp;</TD>
	            <TD>
    	            <input type="Submit" name="Normal" value="Logon" class="normalbttnstyle" WIDTH="65">                               
        	        <Br><Br>
					<cfif isDefined("request.dmSecNT") and request.dmSecNT eq 1>
					<input type="Submit" name="ADSI" CLASS="Button" value="Use My NT Domain Login" WIDTH="65">     
					</cfif>
    	        </TD>
        	</TR>
        </table>
		</div>
	</div>	
</div>

    	

</FORM>

</BODY>
</HTML>
</cfoutput>

<cfsetting enablecfoutputonly="No">