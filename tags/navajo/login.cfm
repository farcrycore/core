<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head> 
<title>#application.config.general.siteTitle# :: #application.applicationname#</title>

<!--- check for custom Admin CSS in project codebase --->
<cfif fileExists("#application.path.project#/www/css/customadmin/admin.css")>
    <cfoutput>
    <link href="#application.url.webroot#/css/customadmin/admin.css" rel="stylesheet" type="text/css">
    </cfoutput>
<cfelse>
    <cfoutput>
    <link href="#application.url.farcry#/css/main.css" rel="stylesheet" type="text/css">
    </cfoutput>
</cfif>
<script type="text/javascript" src="#application.url.farcry#/js/fade.js"></script>
</head>

<body id="sec-login" onload="ol()">

</cfoutput>

<cfset returnUrl = URLDecode(url.returnUrl)>
<cfset returnUrl = replace( returnUrl, "logout=1", "" )>
<cfset returnUrl = replace( returnUrl, "&&", "" )>

<cfparam name="error" default="">

<cfif isdefined("url.error") and url.error eq "draft">
<!--- TODO: i18n --->
    <cfset error = "This page is in draft. Please login with your details below">
</cfif>

<cfset currentNumberLoginAttempts = 0>
<cfif isDefined("form.Normal")>
    <cfset bHasLoggedIn = application.factory.oAuthentication.login(userlogin=form.userlogin,userpassword=form.password,baudit=1)>
    <cfif bHasLoggedIn>
        <cfset o_userProfile = createObject("component", application.types.dmProfile.typePath)>
        <cfset session.dmProfile = o_userProfile.getProfile(userName=form.userlogin)>
    <cfelse>
        <!--- check the audit log to see if they have try to login before and failed --->
        <cfset dateTolerance = DateAdd("n","-#application.config.general.loginAttemptsTimeOut#",Now())>
        <cfquery name="qLogAudit" datasource="#application.dsn#">
        SELECT  count(a.datetimeStamp) as numberOfLogin, max(a.datetimeStamp) as lastlogindate, a.username
        FROM    #application.dbowner#fqAudit a
        WHERE   a.auditType = 'dmSec.loginfailed'
            AND a.datetimeStamp >= <cfqueryparam value="#createODBCDateTime(dateTolerance)#" cfsqltype="cf_sql_timestamp">
        GROUP BY a.username
        </cfquery>

        <cfif qLogAudit.recordcount>
            <cfset currentNumberLoginAttempts = qLogAudit.numberOfLogin>
        </cfif>

        <cfset error = "<h5 class='fade-FFDADA' id='errortext'><span style='color:##c00'><b>Login failed:</b></span> Invalid User Login</h5>">
    </cfif>
</cfif>

<cfif len(application.security.getCurrentUserID())>
    <!--- dmSecMX automatically sets up session.dmSec.authentication structure --->
    <!--- check for ADMIN permissions --->
    <cfset iAdminState = application.security.checkPermission(permission="Admin") />
    
    <cfif iAdminState eq 1>
        <!--- turn on admin permissions --->
        <cfset request.mode.bAdmin = 1>
        <cfset session.dmSec.authentication.bAdmin = 1>
        
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
    <cfset error="<span style='color:##008C0D'><b>OK:</b></span> You have successfully logged out.">
</cfif>

<cfset bShowLogin = "true">
<cfif currentNumberLoginAttempts GTE application.config.general.loginAttemptsAllowed>
    <cfset bShowLogin = "false">
    <cfset error = "<h5 class='fade-FFDADA' id='errortext'><span style='color:##c00'><b>Login failed:</b></span> Invalid User Login<br />You have exceeded the ammount of login attempts allowed #application.config.general.loginAttemptsAllowed#. Please retry later.</h5>">
</cfif>

<cfoutput>
<script type="text/javascript">
function ol()
{
    el=document.getElementById('userLogin');
    if ( el.value.length==0 ) el.focus();
}
</script>

<form action="#cgi.script_name#?#cgi.query_string#" method="post">
<div id="login">
    <!--- default logo gif --->
    <cfset siteLogo = "images/logo_placeholder.gif"> 
    <!--- if there is a site logo, use it instead of the default placeholder --->       
    <cfif structKeyExists(application.config.general,'siteLogoPath')>
        <cfif application.config.general.siteLogoPath NEQ "">
            <cfset siteLogo = application.config.general.siteLogoPath>
        </cfif>
    </cfif>
    <h1><a href="#application.url.webroot#/"><img src="#siteLogo#" alt="#application.config.general.siteTitle#" /></a>#application.config.general.siteTitle#<span>#application.config.general.siteTagLine#</span></h1>
        <fieldset><cfif bShowLogin EQ "true">
        <label for="userLogin">
        Username
        <input type="text" name="userLogin" id="userLogin" tabindex="1" />
        </label>
        <label for="password">
        Password
        <input type="password" name="password" id="password" tabindex="2" />
        </label>
        <input type="Submit" name="Normal" value="Log In" class="f-submit" tabindex="3" /></cfif>
        #error#
        </fieldset>
        
        <h3><img src="images/powered_by_farcry_watermark.gif" />Tell it to someone who cares</h3>
        
</div>
</form>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">