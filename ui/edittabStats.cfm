<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/Attic/edittabStats.cfm,v 1.1 2003/04/09 07:55:08 spike Exp $
$Author: spike $
$Date: 2003/04/09 07:55:08 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
Shows view statistics for chosen object in a number of formats

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<admin:header>

<!--- initiate component --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
</cfscript>

<!--- get top level object details --->
<q4:contentobjectget objectid="#url.objectId#" r_stobject="stObj">

<cfif stObj.typename eq "dmNavigation">

	<cfoutput><br>
	<span class="FormTitle">Views per hour over the last 3 days</span>
	<p></p></cfoutput>
	
	<!--- get page log entries --->
	<cfscript>
	q1 = oStats.getBranchStatsByDay(navid=url.objectid,day=now());
	q2 = oStats.getBranchStatsByDay(navid=url.objectid,day=now()-1);
	q3 = oStats.getBranchStatsByDay(navid=url.objectid,day=now()-2);
	</cfscript>
	
	<!--- show graph --->
	<cfoutput>
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
		yAxisTitle = "Number of Views" 
		show3D = "yes"
		xOffset = "0.15" 
		yOffset = "0.15"
		rotated = "no" 
		showLegend = "yes" 
		tipStyle = "MouseOver">
		
		<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_views" serieslabel="Today" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_views" serieslabel="Yesterday" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_views" serieslabel="DayBefore" paintstyle="shade"></cfchartseries>
	</cfchart>
	</cfoutput>
	
	<!--- weekly stats --->
	
	<!--- #### work out dates #### --->
	<!--- loop over weeks --->
	<cfloop from="0" to="4" index="queryWeek">
		<!--- loop over days in week --->
		<cfloop from="1" to="7" index="day">
			<!--- check if day is a sunday (ie start of weeek) --->
			<cfif dayofweek(dateadd("d",-day,dateadd("ww",-queryWeek,now()))) eq 1>
				<!--- if it is sunday, set startdate for that week --->
				<cfset "q#queryWeek#Date" = dateadd("d",-day,dateadd("ww",-queryWeek,now()))>
			</cfif>
		</cfloop>
	</cfloop>
	
	<!--- Oracle conversion not complete yet for this method --->
	<cfif NOT application.dbType is "ora">
	<cfscript>
	q1 = oStats.getBranchStatsByWeek(navid=url.objectid,day=q0Date);
	q2 = oStats.getBranchStatsByWeek(navid=url.objectid,day=q1Date);
	q3 = oStats.getBranchStatsByWeek(navid=url.objectid,day=q2Date);
	q4 = oStats.getBranchStatsByWeek(navid=url.objectid,day=q3Date);
	</cfscript>
	
	
	<cfoutput>
	<p></p>
	<div class="formtitle">Views per day over the last 4 weeks</div>
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
		yAxisTitle = "Number of Views" 
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
	</cfoutput>
	
	</cfif>
	
	<!--- #### graph of view per day between 2 chosen dates #### --->
	
	<!--- default values --->
	<cfparam name="form.before" default="#now()+1#">
	<cfparam name="form.after" default="#dateadd("m",-3,before)#">
	
	<!--- make sure before is actually after "after" date --->
	<cfif form.before lt form.after>
		<cfset temp = form.before>
		<cfset form.before = form.after>
		<cfset form.after = temp>
	</cfif>
	
	<!--- call methods --->
	<cfscript>
		//get stats for selected object
		q1 = oStats.getBranchStatsByDate(navid=url.objectid,before=createodbcdate(form.before),after=createodbcdate(form.after));
	</cfscript>
	
	<cfoutput>
			
		<p></p>
		<div class="formtitle">Total views per day for Branch '#stObj.title#' between #dateformat(form.after,"dd/mmm/yyyy")# and #dateformat(form.before,"dd/mmm/yyyy")#</div>
		
		<!--- if data, show graph --->
		<cfif q1.qGetPageStats.recordcount>
			
			<!--- ouput graph --->
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
				xAxisTitle = "Date" 
				yAxisTitle = "Number of Views" 
				show3D = "yes"
				xOffset = "0.15" 
				yOffset = "0.15"
				rotated = "no" 
				showLegend = "yes" 
				tipStyle = "MouseOver"
				gridlines = "#q1.max#">
		
				<cfchartseries type="line" query="q1.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="Total views per day for Branch '#stObj.title#' between #dateformat(form.after,"dd/mmm/yyyy")# and #dateformat(form.before,"dd/mmm/yyyy")#" paintstyle="shade"></cfchartseries>
			</cfchart>
		<cfelse>
			<cfoutput><div style="color:red">No statistics have been logged between these two dates.</div></cfoutput>
		</cfif>
				
	<!--- show form to change date range --->
	<div style="margin-left:30px;margin-top:20px;">
	<form action="" method="post">
		Between: <input type="text" name="after" value="#dateformat(form.after,"dd/mmm/yyyy")#">
		and <input type="text" name="before" value="#dateformat(form.before,"dd/mmm/yyyy")#">
		<input type="submit" value="Change Date Range">
	</form>
	</div>
	</cfoutput>

<cfelse>

	<cfoutput><br>
	<span class="FormTitle">Views per hour over the last 3 days</span>
	<p></p></cfoutput>
	
	<!--- get page log entries --->
	<cfscript>
	q1 = oStats.getPageStatsByDay(pageid=url.objectid,day=now());
	q2 = oStats.getPageStatsByDay(pageid=url.objectid,day=now()-1);
	q3 = oStats.getPageStatsByDay(pageid=url.objectid,day=now()-2);
	</cfscript>
	
	<!--- show graph --->
	<cfoutput>
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
		yAxisTitle = "Number of Views" 
		show3D = "yes"
		xOffset = "0.15" 
		yOffset = "0.15"
		rotated = "no" 
		showLegend = "yes" 
		tipStyle = "MouseOver">
		
		<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_views" serieslabel="Today" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_views" serieslabel="Yesterday" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_views" serieslabel="DayBefore" paintstyle="shade"></cfchartseries>
	</cfchart>
	</cfoutput>
	
	<!--- weekly stats --->
	
	<!--- #### work out dates #### --->
	<!--- loop over weeks --->
	<cfloop from="0" to="4" index="queryWeek">
		<!--- loop over days in week --->
		<cfloop from="1" to="7" index="day">
			<!--- check if day is a sunday (ie start of weeek) --->
			<cfif dayofweek(dateadd("d",-day,dateadd("ww",-queryWeek,now()))) eq 1>
				<!--- if it is sunday, set startdate for that week --->
				<cfset "q#queryWeek#Date" = dateadd("d",-day,dateadd("ww",-queryWeek,now()))>
			</cfif>
		</cfloop>
	</cfloop>
	
	<!--- Oracle conversion not complete yet for this method --->
	<cfif NOT application.dbType is "ora">
	<cfscript>
	q1 = oStats.getPageStatsByWeek(pageid=url.objectid,day=q0Date);
	q2 = oStats.getPageStatsByWeek(pageid=url.objectid,day=q1Date);
	q3 = oStats.getPageStatsByWeek(pageid=url.objectid,day=q2Date);
	q4 = oStats.getPageStatsByWeek(pageid=url.objectid,day=q3Date);
	</cfscript>
	
	
	<cfoutput>
	<p></p>
	<div class="formtitle">Views per day over the last 4 weeks</div>
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
		yAxisTitle = "Number of Views" 
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
	</cfoutput>
	
	</cfif>
	
	<!--- #### graph of view per day between 2 chosen dates #### --->
	
	<!--- default values --->
	<cfparam name="form.before" default="#now()+1#">
	<cfparam name="form.after" default="#dateadd("m",-3,before)#">
	
	<!--- make sure before is actually after "after" date --->
	<cfif form.before lt form.after>
		<cfset temp = form.before>
		<cfset form.before = form.after>
		<cfset form.after = temp>
	</cfif>
	
	<!--- call method --->
	<cfscript>
	q1 = oStats.getPageStatsByDate(pageid=url.objectid,before=createodbcdate(form.before),after=createodbcdate(form.after));
	</cfscript>
	
	<cfoutput>
	<p></p>
	<div class="formtitle">Views per day between #dateformat(form.after,"dd/mmm/yyyy")# and #dateformat(form.before,"dd/mmm/yyyy")#</div>
	<cfif q1.qGetPageStats.recordcount>
		<!--- ouput graph --->
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
			xAxisTitle = "Date" 
			yAxisTitle = "Number of Views" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver"
			gridlines = "#q1.max#">
		<cfchartseries type="line" query="q1.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="Views between #dateformat(form.after,'dd/mmm/yyyy')# and #dateformat(form.before,'dd/mmm/yyyy')#" paintstyle="shade"></cfchartseries>
		</cfchart>
	<cfelse>
		<cfoutput><div style="color:red">No statistics have been logged between these two dates.</div></cfoutput>
	</cfif>
	
	<!--- show form to change date range --->
	<div style="margin-left:30px;margin-top:20px;">
	<form action="" method="post">
		Between: <input type="text" name="after" value="#dateformat(form.after,"dd/mmm/yyyy")#">
		and <input type="text" name="before" value="#dateformat(form.before,"dd/mmm/yyyy")#">
		<input type="submit" value="Change Date Range">
	</form>
	</div>
	</cfoutput>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">