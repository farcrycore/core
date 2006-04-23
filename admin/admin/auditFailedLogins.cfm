<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Audit Home</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<span class="formtitle"><cfif isdefined("url.view")>All<cfelse>Recent</cfif> Failed Logins</span><p></p>

<cfscript>
	if (not isdefined("url.view")) {
		maxrows=10;
	} else {
		maxrows=100;
	}
	oAudit = createObject("component", "fourq.utils.audit");
	qFailed = oAudit.getAuditLog(maxrows=maxrows, audittype="dmSec.loginfailed");
</cfscript>	

<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
<tr class="dataheader">
	<td>Date</td>
	<td>Location</td>
	<td>Note</td>
	<td>User</td>
</tr>
<cfoutput query="qFailed">
	<tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<td>#dateformat(Datetimestamp,"dd-mmm-yy")# #timeformat(Datetimestamp)#</td>
		<td>#Location#</td>
		<td>#Note#</td>
		<td><cfif username neq "">#Username#<cfelse><i>unknown</i></cfif></td>
	</tr>	
</cfoutput>
<!--- <cfdump var="#qFailed#" label="Last 10 Failed Attempts"> --->
</table>
<p></p>
<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> 
	<cfif not isdefined("url.view")>
		<a href="auditFailedLogins.cfm?view=all">View all Failed Logins</a>
	<cfelse>
		<a href="auditFailedLogins.cfm">View recent Failed Logins</a>
	</cfif>

</body>
</html>
