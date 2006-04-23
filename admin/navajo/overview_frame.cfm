<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">


<cflock timeout="30" throwontimeout="Yes" type="READONLY" scope="SESSION">
	<cfset sessionId = session.sessionId>
</cflock>

<cftry>
<cflock timeout="0" throwontimeout="Yes" name="refreshLockout_#sessionId#" type="EXCLUSIVE">
	
	<cfset borderStyle="ridge thin">
	<cfset smallPopupFeatures="width=400,height=300,menubar=no,toolbars=no">
	
	<cfinclude template="_customIcons.cfm">
	
	<cfoutput>
	<HTML>
	<HEAD>
	<TITLE>Overview Tree</TITLE>
	<!--- <cf_cachecontrol> --->
	<LINK href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<LINK href="#application.url.farcry#/css/overviewFrame.css" rel="stylesheet" type="text/css">
	</HEAD>
		
	<body>
		<div class="FormTitle">Site Management</div>
		
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
		<p>The system has detected the <b>Overview Tree</b> is already loading.</p>
		
		<p>The <b>Overview Tree</b> cannot be loaded more than once per user at a time.</p>
		
		<p>You are probably receiving this error because you have pushed the refresh button half way through loading.  Pressing the refresh button in the middle of loading can have a significant performance impact on the website as your previous requests must be serviced before your new requests.  Therefore, we have implemented this restriction.</p>

		<p>You will now have to wait for your previous request to complete before you will be allowed to reload this screen.</p>
		
		<p><b>Please try again in 30 seconds.</b></p>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="No">
