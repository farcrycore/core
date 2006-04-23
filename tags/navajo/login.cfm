<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<cfoutput>
<HTML>
<HEAD> 
<title>#application.config.general.siteTitle# :: #application.applicationname#&nbsp;&nbsp;&nbsp;</title>
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</HEAD>

<body onLoad="ol();" style="background-color:##CCC;">

</cfoutput>

<cfset returnUrl = URLDecode(url.returnUrl)>
<cfset returnUrl = replace( returnUrl, "logout=1", "" )>
<cfset returnUrl = replace( returnUrl, "&&", "" )>

<cfparam name="error" default="Please login with your details below.">

<cfif isdefined("url.error") and url.error eq "draft">
	<cfset error = "This page is in draft. Please login with your details below">
</cfif>

<cfif isDefined("form.Normal")>
		<cfscript>
			bHasLoggedIn = request.dmSec.oAuthentication.login(userlogin=form.userlogin,userpassword=form.password,baudit=1);
			
			if (bHasLoggedIn)
			{
				o_userProfile = createObject("component", application.types.dmProfile.typePath);
				stProfile = o_userProfile.getProfile(userName=form.userLogin);
		
				// place dmProfile in session scope
				if (not structIsEmpty(stProfile) AND stProfile.bInDB) {
					session.dmProfile = stProfile;
					session.firstLogin = false;
				} else {
					stProfile = o_userProfile.createProfile(stProperties=session.dmSec.authentication);
					if (not structIsEmpty(stProfile) AND stProfile.bInDB) {
						session.dmProfile = stProfile;
						session.firstLogin = true;
					}
				}
			}
			else
				error="<font color=##cc0000><b>Login failed:</b></font> Invalid User Login";	
        </cfscript>
</cfif>

<cfscript>
	oAuthentication = request.dmSec.oAuthentication;
	stLoggedIn = oAuthentication.getUserAuthenticationData();	
	bLoggedin = stLoggedIn.bloggedIn;
</cfscript>	
<cfif bLoggedIn>
	<!--- dmSecMX automatically sets up session.dmSec.authentication structure --->
	<!--- check for ADMIN permissions --->
	<cfscript>
		oAuthorisation = request.dmSec.oAuthorisation;
		iAdminState = oAuthorisation.checkPermission(permissionName="Admin",reference="PolicyGroup");
	</cfscript>
		
	<cfif iAdminState eq 1>
		<!--- turn on admin permissions --->
		<cfset request.mode.bAdmin = 1>
		<cfset session.dmSec.authentication.bAdmin = 1>
		
		<!--- i18n: admin bits --->
		<cfif NOT structKeyExists(application.adminBundle, session.dmProfile.locale)>
			<!--- <cfset application.adminBundle[session.dmProfile.locale]=application.rB.getResourceBundle("farcry.admin",session.dmProfile.locale,true)> --->
			<cfset application.adminBundle[session.dmProfile.locale]=application.rB.getResourceBundle("#application.path.core#/packages/resources/admin.properties",session.dmProfile.locale,false)>
		</cfif>
		<!--- i18n: find out this locale's writing system direction using our special psychic powers --->
		<cfif application.i18nUtils.isBIDI(session.dmProfile.locale)>
			<cfset session.writingDir="rtl">
		<cfelse>
			<cfset session.writingDir="ltr">
		</cfif>	
		<!--- i18n: final bit, grab user language from locale, tarts up html tag --->
		<cfset session.userLanguage=left(session.dmProfile.locale,2)>
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
			<div class="title">#application.config.general.siteTitle#</div><br>
			<div class="description">#application.config.general.siteTagLine#</div>
		</div>
		<div style="position: absolute; top:50px; right: 25px;">
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
	            <TD ALIGN="right" COLSPAN="2"><input type="Submit" name="Normal" value="Logon" class="normalbttnstyle" WIDTH="65"></TD>
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