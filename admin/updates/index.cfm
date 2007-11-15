<cfsetting enablecfoutputonly="true">
<cfoutput>
<html>
<head>
<title>Farcry Core Updates - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<img src="#application.url.farcry#/images/powered_by_farcry.gif" alt="FarCry Updater">
<p>&nbsp;</p>

<span class="formtitle" style="margin-left:30px;">FarCry Updates</span>
</cfoutput>

<cfif isdefined("form.submit")>
	<!--- run updates --->
	<cfloop list="#form.script#" index="script">
		<!--- display update name --->
		<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <strong>Running Update #script#...</strong><p></p></cfoutput><cfflush>
		<!--- include update script --->
		<!--- begin modification by Nelson Johnson --->
		<!--- only if the script already exists --->
		<cfdirectory action="LIST" filter="#script#.cfm" name="qUpdates" directory="#application.path.core#/admin/updates">
		<cfif len(qUpdates.name) gt 0>
			<cfinclude template="/farcry/core/admin/updates/#script#.cfm">
		<cfelse>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <strong>Cannot find update #script#...</strong><p></p></cfoutput><cfflush>
		</cfif>
		<!--- end modification by Nelson Johnson --->
	</cfloop>
	<!--- logout user if logged in because errors will occur when returning to admin --->
	<cfif isdefined("session.dmprofile")>
		<cfscript>
			application.factory.oAuthentication.logout();
		</cfscript>
	</cfif>
	<!--- Farcry Core RE - Initialisation --->
	<cfinclude template="/farcry/core/tags/farcry/_farcryApplicationInit.cfm">
	<!--- finish message and link back to FarCry --->
	<cfoutput>
	<p></p><span class="frameMenuBullet">&raquo;</span> <strong>Updates Complete.</strong><p></p>
	<span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/?updateapp=1">Return to FarCry</a>
	</cfoutput>
<cfelse>
	<!--- show update form --->
	<!--- get all files in updates directory --->
	<cfdirectory action="LIST" filter="b*.cfm" name="qUpdates" directory="#application.path.core#/admin/updates">
	<cfoutput>
	<p></p>
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr>
		<th class="dataheader">Updater</th>
		<th class="dataheader">Description</th>
		<th class="dataheader">Deploy</th>
	</tr>
	<form action="index.cfm" method="post">
	</cfoutput>
	<!--- loop over update scripts and get details --->
	<cfloop query="qUpdates">
		<!--- read file to get update description --->
		<cffile action="READ" file="#application.path.core#/admin/updates/#qUpdates.name#" variable="script">
		<cfset pos = findNoCase('@@description:', script)>
		<cfif pos>
			<cfset pos = pos + 8>
			<cfset count = findNoCase('--->', script, pos)-pos>
			<cfset description = listLast(mid(script,  pos, count), ":")>
		<cfoutput>
			<tr>
				<!--- update --->
				<td valign="top"><strong>#listfirst(name, ".")#</strong></td>
				<!--- description --->
				<td>#description#</td>
				<!--- deploy check box --->
				<td align="center"><input type="checkbox" name="script" value="#listfirst(name, ".")#"></td>
			</tr>
		</cfoutput>
		</cfif>
	</cfloop>
	
	<cfoutput>
	<tr>
		<td colspan="3" align="right"><input type="submit" value="Deploy Updates" name="submit"></td>
	</tr>
	</form>
	</table>
	</cfoutput>
</cfif>
<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">