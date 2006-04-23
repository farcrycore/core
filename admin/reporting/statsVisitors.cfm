<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsVisitors.cfm,v 1.3 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
Shows view statistics for chosen object in a number of formats

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>
	<!--- i18n: get week starts for later use --->
	<cfset weekStartDay=application.thisCalendar.weekStarts(session.dmProfile.locale)>

	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<cfoutput><br>
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].sessionPerHourLast3Days#</span>
	<p></p></cfoutput>
	
	<!--- get page log entries --->
	<cfscript>
	q1 = application.factory.oStats.getVisitorStatsByDay(day=now());
	q2 = application.factory.oStats.getVisitorStatsByDay(day=now()-1);
	q3 = application.factory.oStats.getVisitorStatsByDay(day=now()-2);
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
		xAxisTitle = "#application.adminBundle[session.dmProfile.locale].Hour#" 
		yAxisTitle = "#application.adminBundle[session.dmProfile.locale].sessionNumbers#" 
		show3D = "yes"
		xOffset = "0.15" 
		yOffset = "0.15"
		rotated = "no" 
		showLegend = "yes" 
		tipStyle = "MouseOver">
		
		<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].Today#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].Yesterday#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].DayBefore#" paintstyle="shade"></cfchartseries>
	</cfchart>
	</cfoutput>
	
	<!--- weekly stats --->
	
	<!--- #### work out dates #### --->
	<!--- loop over weeks --->
	<cfloop from="0" to="4" index="queryWeek">
		<!--- loop over days in week --->
		<cfloop from="1" to="7" index="day">
			<!--- check if day is a sunday (ie start of weeek) --->
			<cfif dayofweek(dateadd("d",-day,dateadd("ww",-queryWeek,now()))) eq weekStartDay>
				<!--- if it is sunday, set startdate for that week --->
				<cfset "q#queryWeek#Date" = dateadd("d",-day,dateadd("ww",-queryWeek,now()))>
			</cfif>
		</cfloop>
	</cfloop>
	
	<!--- Oracle conversion not complete yet for this method --->
	<cfif NOT application.dbType is "ora">
	<cfscript>
	q1 = application.factory.oStats.getVisitorStatsByWeek(day=q0Date);
	q2 = application.factory.oStats.getVisitorStatsByWeek(day=q1Date);
	q3 = application.factory.oStats.getVisitorStatsByWeek(day=q2Date);
	q4 = application.factory.oStats.getVisitorStatsByWeek(day=q3Date);
	</cfscript>
	
	
	<cfoutput>
	<p></p>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].sessionsPerDayLast4Weeks#</div>
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
		xAxisTitle = "#application.adminBundle[session.dmProfile.locale].Day#" 
		yAxisTitle = "#application.adminBundle[session.dmProfile.locale].sessionNumbers#" 
		show3D = "yes"
		xOffset = "0.15" 
		yOffset = "0.15"
		rotated = "no" 
		showLegend = "yes" 
		tipStyle = "MouseOver">
	<cfchartseries type="bar" query="q1" itemcolumn="name" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].thisWeek#" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q2" itemcolumn="name" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].lastWeek#" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q3" itemcolumn="name" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].twoWeeksBefore#" paintstyle="shade"></cfchartseries>
	<cfchartseries type="bar" query="q4" itemcolumn="name" valuecolumn="count_Ip" serieslabel="#application.adminBundle[session.dmProfile.locale].threeWeeksBefore#" paintstyle="shade"></cfchartseries>
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
	q1 = application.factory.oStats.getVisitorStatsByDate(before=createodbcdate(form.before),after=createodbcdate(form.after));
	</cfscript>
	
	<cfoutput>
	<p></p>
	<div class="formtitle">
	<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.fullF)#,#application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.fullF)#')>
	#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionsPerDayBetween,subS)#
	</div>
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
			xAxisTitle = "#application.adminBundle[session.dmProfile.locale].Date#" 
			yAxisTitle = "#application.adminBundle[session.dmProfile.locale].sessionNumbers#" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver"
			gridlines = "#q1.max#">
		<cfchartseries type="line" query="q1.qGetPageStats" itemcolumn="viewday" valuecolumn="count_Ip" serieslabel="#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].sessionsPerDayBetween,subS)#" paintstyle="shade"></cfchartseries>
		</cfchart>
	<cfelse>
		<cfoutput><div style="color:red">#application.adminBundle[session.dmProfile.locale].noStatsBetween#</div></cfoutput>
	</cfif>
	
	<!--- show form to change date range --->
	<div style="margin-left:30px;margin-top:20px;">
	<form action="" method="post">
		#application.adminBundle[session.dmProfile.locale].betweenLabel# <input type="text" name="after" value="#application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.fullF)#">
		#application.adminBundle[session.dmProfile.locale].andLabel# <input type="text" name="before" value="#application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.fullF)#">
		<input type="submit" value="Change Date Range">
	</form>
	</div>
	</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">