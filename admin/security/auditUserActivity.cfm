
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Daily User Login Activity</title>
	<link rel="stylesheet" href="../css/admin.css" type="text/css">
</head>

<body>
<cfif url.graph eq "day">
	<div class="formtitle">Daily User Login Activity</div>
	<cfscript>
	oAudit = createObject("component", "farcry.fourq.utils.audit");
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
<cfelse>
	<div class="formtitle">Weekly User Login Activity</div>
	<!--- <cfscript>
	o_stats = createObject("component", "#application.packagepath#.farcry.stats");
	oq1 = o_stats.deploy(bDropTable=false,dsn=application.dsn);	
	</cfscript><cfabort> --->
	<!--- #### work out dates #### --->
	<!--- loop over weeks --->
	<cfloop from="0" to="4" index="queryWeek">
		<!--- loop over days in week --->
		<cfloop from="1" to="7" index="day">
			<!--- check if day is a sunday (ie start of week) --->
			<cfif dayofweek(dateadd("d",-day,dateadd("ww",-queryWeek,now()))) eq 1>
				<!--- if it is sunday, set startdate for that week --->
				<cfset "q#queryWeek#Date" = dateadd("d",-day,dateadd("ww",-queryWeek,now()))>
			</cfif>
		</cfloop>
	</cfloop>
	
	<cfscript>
	oAudit = createObject("component", "farcry.fourq.utils.audit");
	q1 = oAudit.getUserActivityWeekly(q0Date);
	q2 = oAudit.getUserActivityWeekly(q1Date);
	q3 = oAudit.getUserActivityWeekly(q2Date);
	q4 = oAudit.getUserActivityWeekly(q3Date);
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
		xAxisTitle = "Day" 
		yAxisTitle = "Number of Logins" 
		show3D = "yes"
		xOffset = "0.15" 
		yOffset = "0.15"
		rotated = "no" 
		showLegend = "yes" 
		tipStyle = "MouseOver">
	<cfchartseries type="bar" query="q1" itemcolumn="name" valuecolumn="count_logins" serieslabel="This Week" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q2" itemcolumn="name" valuecolumn="count_logins" serieslabel="Last Week" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q3" itemcolumn="name" valuecolumn="count_logins" serieslabel="2 Weeks Before" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q4" itemcolumn="name" valuecolumn="count_logins" serieslabel="3 Weeks Before" paintstyle="shade"></cfchartseries>
	</cfchart>
	
	<p>
	<!--- <cfdump var="#q1#" label="Complete Audit Log">
	 --->
	</div>
</cfif>

</body>
</html>
