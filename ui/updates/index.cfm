<html>
<head>
<title>Farcry Core Updates - <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<img src="<cfoutput>#application.url.farcry#</cfoutput>/images/farcry_logo.gif" border="0" alt="FarCry Updater"><P></P>

<span class="formtitle" style="margin-left:30px;">FarCry Updates</span>

<cfif isdefined("form.submit")>
	<!--- run updates --->
	<cfloop list="#form.script#" index="script">
		<!--- display update name --->
		<p></p><span class="frameMenuBullet">&raquo;</span> <strong>Running Update <cfoutput>#script#</cfoutput>...</strong><p></p><cfflush>
		<!--- include update script --->
		<cfinclude template="/farcry/farcry_core/ui/updates/#script#.cfm">
	</cfloop>
	<!--- finish message and link back to FarCry --->
	<p></p><span class="frameMenuBullet">&raquo;</span> <strong>Updates Complete.</strong><p></p>
	<span class="frameMenuBullet">&raquo;</span> <a href="<cfoutput>#application.url.farcry#</cfoutput>">Return to FarCry</a>
	
<cfelse>
	<!--- show update form --->
	<!--- get all files in updates directory --->
	<cfdirectory action="LIST" filter="b*.cfm" name="qUpdates" directory="#application.path.core#/ui/updates">
	<p></p>
	<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr>
		<th class="dataheader">Updater</th>
		<th class="dataheader">Description</th>
		<th class="dataheader">Deploy</th>
	</tr>
	<form action="index.cfm" method="post">
	<!--- loop over update scripts and get details --->
	<cfloop query="qUpdates">
		<!--- read file to get update description --->
		<cffile action="READ" file="#application.path.core#/ui/updates/#qUpdates.name#" variable="script">
		<cfset pos = findNoCase('@@description:', script)>
		<cfset pos = pos + 8>
		<cfset count = findNoCase('--->', script, pos)-pos>
		<cfset description = listLast(mid(script,  pos, count), ":")>
	
		<tr>
			<!--- update --->
			<td valign="top"><strong><cfoutput>#listfirst(name, ".")#</cfoutput></strong></td>
			<!--- description --->
			<td><cfoutput>#description#</cfoutput></td>
			<!--- deploy check box --->
			<td align="center"><input type="checkbox" name="script" value="<cfoutput>#listfirst(name, ".")#</cfoutput>"></td>
		</tr>
	</cfloop>
	
	<tr>
		<td colspan="3" align="right"><input type="submit" value="Deploy Updates" name="submit"></td>
	</tr>
	</form>
	</table>
</cfif>
</body>
</html>


