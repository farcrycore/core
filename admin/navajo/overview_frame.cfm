<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">


<cflock timeout="30" throwontimeout="Yes" type="READONLY" scope="SESSION">
	<cfset sessionId = session.sessionId>
</cflock>

<cftry>
<cflock timeout="0" throwontimeout="Yes" name="refreshLockout_#sessionID#" type="EXCLUSIVE">
	
	<cfset borderStyle="ridge thin">
	<cfset smallPopupFeatures="width=400,height=300,menubar=no,toolbars=no">
	
	<cfinclude template="_customIcons.cfm">
	
	<cfoutput>
	<html dir="#session.writingDir#" lang="#session.userLanguage#">
	<HEAD>
	<TITLE>#application.adminBundle[session.dmProfile.locale].overviewTree#</TITLE>
	<!--- <cf_cachecontrol> --->
	<LINK href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<LINK href="#application.url.farcry#/css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
	</HEAD>
		
	<body>
		<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].siteManagement#</div>
		
		<div style="margin-left: 12px;" id="tree">
			</cfoutput>
					<nj:Overview customIcons="#customIcons#">
			<cfoutput>
		</div>
	</body>
	</html>
	</cfoutput>
	
	</cflock>

	<cfcatch type="Lock">
		<cfoutput>
		#application.adminBundle[session.dmProfile.locale].overviewTreeLoadingBlurb#
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="No">
