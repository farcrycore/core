<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Daily User Login Activity</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<div class="formtitle">Daily User Login Activity</div>
<cfscript>
oAudit = createObject("component", "fourq.utils.audit");
q1 = oAudit.getUserActivityDaily(now());
q2 = oAudit.getUserActivityDaily(now()-1);
q3 = oAudit.getUserActivityDaily(now()-2);
</cfscript>


<div class="formtableclear">
<cfchart 
    format="flash" 
    chartHeight="400" 
    chartWidth="600" 
    scaleFrom="0" 
    showXGridlines = "yes" 
    showYGridlines = "yes"
    seriesPlacement="default"
    showBorder = "no"
	fontsize="12"
    font="arialunicodeMS" 
    labelFormat = "number"
    xAxisTitle = "Hour" 
    yAxisTitle = "Number of Logins" 
    show3D = "yes"
	xOffset = "0.15" 
    yOffset = "0.15"
    rotated = "no" 
    showLegend = "yes" 
    tipStyle = "MouseOver">
<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_logins" serieslabel="Today" paintstyle="shade"></cfchartseries>
<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_logins" serieslabel="Yesterday" paintstyle="shade"></cfchartseries>
<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_logins" serieslabel="DayBefore" paintstyle="shade"></cfchartseries>
</cfchart>

<p>
<!--- <cfdump var="#q1#" label="Complete Audit Log">
 --->
</div>

</body>
</html>
