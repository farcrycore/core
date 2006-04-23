<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/auditUserActivity.cfm,v 1.3 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Audit login activity $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<!--- check permissions --->
<cfscript>
	iAuditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingAuditTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iAuditTab eq 1>

	<cfif url.graph eq "day">
		<div class="formtitle">Daily User Login Activity</div>
		<cfscript>
		q1 = application.factory.oAudit.getUserActivityDaily(now());
		q2 = application.factory.oAudit.getUserActivityDaily(now()-1);
		q3 = application.factory.oAudit.getUserActivityDaily(now()-2);
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
			font="arial" 
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
		</div>
	<cfelse>
		<div class="formtitle">Weekly User Login Activity</div>
		
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
		q1 = application.factory.oAudit.getUserActivityWeekly(q0Date);
		q2 = application.factory.oAudit.getUserActivityWeekly(q1Date);
		q3 = application.factory.oAudit.getUserActivityWeekly(q2Date);
		q4 = application.factory.oAudit.getUserActivityWeekly(q3Date);
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
			font="arial" 
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
		</div>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
