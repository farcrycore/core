<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/edittabStats.cfm,v 1.19.2.1 2006/02/14 02:55:28 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/14 02:55:28 $
$Name: milestone_3-0-1 $
$Revision: 1.19.2.1 $

|| DESCRIPTION || 
Shows view statistics for chosen object in a number of formats

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfprocessingDirective pageencoding="utf-8">

<cfsetting enablecfoutputonly="yes" requestTimeOut="600">

<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<sec:CheckPermission error="true" permission="ObjectStatsTab">
	<cftry> 
		<!--- try and see if the file can be loaded --->
	    <cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/edittabStats.cfm">
	    
		<cfcatch type="missingInclude"> <!--- nope - so use the default one --->
			
			<!--- set up page header --->
			<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
			<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
			
			<!--- i18n: get week starts for later use --->
			<cfset weekStartDay=application.thisCalendar.weekStarts(session.dmProfile.locale)>
			<!--- get top level object details --->
			<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
			<q4:contentobjectget objectid="#url.objectId#" r_stobject="stObj">
			
			<!--- create navigation object --->
			<cfset oNav = createObject("component",application.types.dmNavigation.typepath)>
		
			<!--- see if object is in tree --->
			<cfset qParent = oNav.getParent(url.objectId)>

			<cfif qParent.recordcount>
				<!--- clear title variable --->
				<cfset title = "">
				
				<!--- get ancestors --->
				<cfset qAncestors = application.factory.oTree.getAncestors(qParent.parentid)>
				
				<!--- build breadcrumb --->
				<cfloop query="qAncestors">
					<!--- don't include root and home --->
					<cfif qAncestors.nlevel gt 1>
						<cfif len(title)>
							<cfset title = title & " &raquo; ">
						</cfif>
						<cfset title = title & qAncestors.objectName>
					</cfif>
				</cfloop>
				
				<!--- append object title to breadcrumb --->
				<cfif len(title)>
					<cfset title = title & " &raquo; ">
				</cfif>
				<cfset title = title & stObj.title>			
			<cfelse>
				<!--- no breadcrumb --->
        <cfif isDefined("stObj.title")>
	  			<cfset title = stObj.title />
        <cfelse>
  				<cfset title = stObj.label />
        </cfif>
			</cfif>
					
			<!--- display object title and breadcrumb --->
			<cfoutput><h3>#title#</h3></cfoutput>
			
			<cfif stObj.typename eq "dmNavigation">
			
				<cfoutput>
				<h3>#apapplication.rb.getResource("viewsPerHour")#</h3>
				</cfoutput>
				
				<!--- get page log entries --->
				<cfscript>
				q1 = application.factory.oStats.getBranchStatsByDay(navid=url.objectid,day=now());
				q2 = application.factory.oStats.getBranchStatsByDay(navid=url.objectid,day=now()-1);
				q3 = application.factory.oStats.getBranchStatsByDay(navid=url.objectid,day=now()-2);
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
					labelFormat = "number"
					xAxisTitle = "#apapplication.rb.getResource("hour")#" 
					yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "yes" 
					tipStyle = "MouseOver">
					
					<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("today")#" paintstyle="shade"></cfchartseries>
					<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("yesterday")#" paintstyle="shade"></cfchartseries>
					<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("dayBefore")#" paintstyle="shade"></cfchartseries>
				</cfchart>
				</cfoutput>
				
				<!--- weekly stats --->
				
				<!--- #### work out dates #### --->
				<!--- loop over weeks --->
				<!--- i18n: would need completely different logic for non-gregorian calendars --->
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
				q1 = application.factory.oStats.getBranchStatsByWeek(navid=url.objectid,day=q0Date);
				q2 = application.factory.oStats.getBranchStatsByWeek(navid=url.objectid,day=q1Date);
				q3 = application.factory.oStats.getBranchStatsByWeek(navid=url.objectid,day=q2Date);
				q4 = application.factory.oStats.getBranchStatsByWeek(navid=url.objectid,day=q3Date);
				</cfscript>
				
				
				<cfoutput>
				<p></p>
				<h3>#apapplication.rb.getResource("viewPerDay")#</h3>
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
					labelFormat = "number"
					xAxisTitle = "#apapplication.rb.getResource("day")#" 
					yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "yes" 
					tipStyle = "MouseOver">
				<cfchartseries type="bar" query="q1" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("thisWeek")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q2" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("lastWeek")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q3" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("twoWeeksBefore")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q4" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("threeWeeksBefore")#" paintstyle="shade"></cfchartseries>
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
					q1 = application.factory.oStats.getBranchStatsByDate(navid=url.objectid,before=createodbcdate(form.before),after=createodbcdate(form.after));
				</cfscript>
				
				<cfoutput>
						
					<p></p>
					<!--- i18n: for readability --->
					<cfset tA=application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)>
					<cfset tB=application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)>
					<cfset subS=listToArray('#stObj.title#,#tA#,#tB#')>
					<h3>#application.rb.formatRBString("totalViewsPerDay",subS)#</h3>
					
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
							labelFormat = "number"
							xAxisTitle = "#apapplication.rb.getResource("date")#" 
							yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
							show3D = "yes"
							xOffset = "0.15" 
							yOffset = "0.15"
							rotated = "no" 
							showLegend = "yes" 
							tipStyle = "MouseOver"
							gridlines = "#q1.max+1#">
						<!--- i18n: for readability --->
						<cfset tA=application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)>
						<cfset tB=application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)>
						<cfset subS=listToArray('#stObj.title#,#tA#,#tB#')>
						<cfchartseries type="line" query="q1.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="#application.rb.formatRBString("totalViewsPerDay",subS)#" paintstyle="shade"></cfchartseries>
						</cfchart>
					<cfelse>
						<cfoutput><div style="color:red">#apapplication.rb.getResource("noStatsLogged")#</div></cfoutput>
					</cfif>
							
				<!--- show form to change date range --->
				<div style="margin-left:30px;margin-top:20px;">
				<form action="" method="post">
					#apapplication.rb.getResource("between")# 
					<input type="text" name="after" value="#application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)#">
					#apapplication.rb.getResource("andLabel")# 
					<input type="text" name="before" value="#application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)#">
					<input type="submit" value="#apapplication.rb.getResource("changeDateRange")#">
				</form>
				</div>
				</cfoutput>
			
			<cfelse>
			
				<cfoutput>
				<h3>#apapplication.rb.getResource("viewsPerHour")#</h3>
				</cfoutput>
				
				<!--- get page log entries --->
				<cfscript>
				q1 = application.factory.oStats.getPageStatsByDay(pageid=url.objectid,day=now());
				q2 = application.factory.oStats.getPageStatsByDay(pageid=url.objectid,day=now()-1);
				q3 = application.factory.oStats.getPageStatsByDay(pageid=url.objectid,day=now()-2);
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
					labelFormat = "number"
					xAxisTitle = "#apapplication.rb.getResource("hour")#" 
					yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "yes" 
					tipStyle = "MouseOver">
					
					<cfchartseries type="bar" query="q1" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("today")#" paintstyle="shade"></cfchartseries>
					<cfchartseries type="bar" query="q2" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("yesterday")#" paintstyle="shade"></cfchartseries>
					<cfchartseries type="bar" query="q3" itemcolumn="hour" valuecolumn="count_views" serieslabel="#apapplication.rb.getResource("dayBefore")#" paintstyle="shade"></cfchartseries>
				</cfchart>
				</cfoutput>
				
				<!--- weekly stats --->
				
				<!--- #### work out dates #### --->
				<!--- loop over weeks --->
				<!--- i18n: need to completely rework for non-gregorian calendars --->
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
				q1 = application.factory.oStats.getPageStatsByWeek(pageid=url.objectid,day=q0Date);
				q2 = application.factory.oStats.getPageStatsByWeek(pageid=url.objectid,day=q1Date);
				q3 = application.factory.oStats.getPageStatsByWeek(pageid=url.objectid,day=q2Date);
				q4 = application.factory.oStats.getPageStatsByWeek(pageid=url.objectid,day=q3Date);
				</cfscript>
						
				<cfoutput>
				<h3>#apapplication.rb.getResource("viewPerDay")#</h3>
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
					labelFormat = "number"
					xAxisTitle = "#apapplication.rb.getResource("day")#" 
					yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
					show3D = "yes"
					xOffset = "0.15" 
					yOffset = "0.15"
					rotated = "no" 
					showLegend = "yes" 
					tipStyle = "MouseOver">
				<cfchartseries type="bar" query="q1" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("thisWeek")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q2" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("lastWeek")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q3" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("twoWeeksBefore")#" paintstyle="shade"></cfchartseries>
				<cfchartseries type="bar" query="q4" itemcolumn="name" valuecolumn="count_logins" serieslabel="#apapplication.rb.getResource("threeWeeksBefore")#" paintstyle="shade"></cfchartseries>
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
				q1 = application.factory.oStats.getPageStatsByDate(pageid=url.objectid,before=createodbcdate(form.before),after=createodbcdate(form.after));
				</cfscript>
				
				<cfoutput>
				<!--- i18n: for readability --->

				<cfset tA=application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)>
				<cfset tB=application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)>
				<cfset subS=listToArray('#tA#,#tB#')>
				<h3>#application.rb.formatRBString("viewsPerDayBetween",subS)#</h3>
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
						labelFormat = "number"
						xAxisTitle = "#apapplication.rb.getResource("date")#" 
						yAxisTitle = "#apapplication.rb.getResource("viewNumbers")#" 
						show3D = "yes"
						xOffset = "0.15" 
						yOffset = "0.15"
						rotated = "no" 
						showLegend = "yes" 
						tipStyle = "MouseOver"
						gridlines = "#q1.max+1#">
					<!--- i18n: for readability --->
					<cfset tA=application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)>
					<cfset tB=application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)>
					<cfset subS=listToArray('#tA#,#tB#')>
					<cfchartseries type="line" query="q1.qGetPageStats" itemcolumn="viewday" valuecolumn="count_views" serieslabel="#application.rb.formatRBString("viewsBetween",subS)#" paintstyle="shade"></cfchartseries>
					</cfchart>
				<cfelse>
					<cfoutput><div style="color:red">#apapplication.rb.getResource("noStatsLogged")#</div></cfoutput>
				</cfif>
				
				<!--- show form to change date range --->
				<!--- <div style="margin-left:30px;margin-top:20px;">
				<form action="" method="post">
					#apapplication.rb.getResource("between")# 
					<input type="text" name="after" value="#application.thisCalendar.i18nDateFormat(form.after,session.dmProfile.locale,application.mediumF)#">
					#apapplication.rb.getResource("andLabel")# 
					<input type="text" name="before" value="#application.thisCalendar.i18nDateFormat(form.before,session.dmProfile.locale,application.mediumF)#">
					<input type="submit" value="#apapplication.rb.getResource("changeDateRange")#">
				</form>
				</div> --->
				</cfoutput>
			</cfif>
		</cfcatch>
	</cftry>		
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="yes">