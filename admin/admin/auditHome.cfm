<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Audit Home</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<span class="formtitle">Audit Home</span><p></p>
<p>(TODO: break these reports into separate pages)</p>

<cfscript>
oAudit = createObject("component", "fourq.utils.audit");
qLog = oAudit.getAuditLog();
</cfscript>

<cfdump var="#qLog#" label="Complete Audit Log">
</body>
</html>
