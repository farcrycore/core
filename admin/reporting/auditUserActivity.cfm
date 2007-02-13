<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/reporting/auditUserActivity.cfm,v 1.7 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Audit login activity $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iAuditTab eq 1>
	<!--- i18n: get week starts for later use --->
	<cfset weekStartDay=application.thisCalendar.weekStarts(session.dmProfile.locale)>

	<cfif url.graph eq "day">
		<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].dailyUserLog#</h3></cfoutput>
		<cfscript>
		q1 = application.factory.oAudit.getUserActivityDaily(now());
		q2 = application.factory.oAudit.getUserActivityDaily(now()-1);
		q3 = application.factory.oAudit.getUserActivityDaily(now()-2);
		</cfscript>
		
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
			font="arial" 
			labelFormat = "number"
			xAxisTitle = "#application.adminBundle[session.dmProfile.locale].hour#" 
			yAxisTitle = "#application.adminBundle[session.dmProfile.locale].loginNumbers#" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver">
		<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].Today#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].Yesterday#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].DayBefore#" paintstyle="shade"></cfchartseries>
		</cfchart>

	<cfelse>
		
		<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].weeklyUserLog#</h3></cfoutput>
		
		<!--- #### work out dates #### --->
		<!--- loop over weeks --->
		<cfloop from="0" to="4" index="queryWeek">
			<!--- loop over days in week --->
			<cfloop from="1" to="7" index="day">
				<!--- check if day is a sunday (ie start of week) --->
				<cfif dayofweek(dateadd("d",-day,dateadd("ww",-queryWeek,now()))) eq weekStartDay>
					<!--- if it is sunday, set startdate for that week --->
					<cfset "q#queryWeek#Date" = dateadd("d",-day,dateadd("ww",-queryWeek,now()))>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfscript>
		q1 = application.factory.oAudit.getUserActivityWeekly(q0Date);
		q2 = application.factory.oAudit.getUserActivityWeekly(q1Date);
		q3 = application.factory.oAudit.getUserActivityWeekly(q2Date);
		q4 = application.factory.oAudit.getUserActivityWeekly(q3Date);
		</cfscript>
		
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
			font="arial" 
			labelFormat = "number"
			xAxisTitle = "#application.adminBundle[session.dmProfile.locale].day#" 
			yAxisTitle = "#application.adminBundle[session.dmProfile.locale].loginNumbers#" 
			show3D = "yes"
			xOffset = "0.15" 
			yOffset = "0.15"
			rotated = "no" 
			showLegend = "yes" 
			tipStyle = "MouseOver">
		<cfchartseries type="bar" query="q1" itemcolumn="name" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].thisWeek#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q2" itemcolumn="name" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].lastWeek#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q3" itemcolumn="name" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].twoWeeksBefore#" paintstyle="shade"></cfchartseries>
		<cfchartseries type="bar" query="q4" itemcolumn="name" valuecolumn="count_logins" serieslabel="#application.adminBundle[session.dmProfile.locale].threeWeeksBefore#" paintstyle="shade"></cfchartseries>
		</cfchart>

	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
