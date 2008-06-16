<cfsetting enablecfoutputonly="yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmCron/edit.cfm,v 1.14.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.14.2.1 $

|| DESCRIPTION || 
$Description: dmCron edit handler$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">

<!--- local variables --->
<cfparam name="errormessage" default="">
<cfparam name="bFormSubmitted" default="no">
<cfparam name="title" default="">
<cfparam name="description" default="">
<cfparam name="template" default="">
<cfparam name="parameters" default="">
<cfparam name="frequency" default="">
<cfparam name="timeOut" default="">
<cfparam name="startDate" default="#now()#">
<cfparam name="endDate" default="#DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,now())#">
<cfparam name="noEnd" default="0">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<!--- i18n get locale months --->
<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>
<cfset oType = createobject("component", application.types.dmCron.typePath)>
<cfif bFormSubmitted EQ "yes"> <!--- form submitted --->
	<cfset startDate = '#form.startYear#-#form.startMonth#-#form.startDay# #form.startHour#:#form.startMinutes#'>
	<cfset form.startDate = createODBCDatetime(startDate)>

	<!--- hack for no expiry. sets expiry year to 2050...the y2050 bug :) --->
	<cfif noEnd>
		<cfset endDate = createDate(2050,endMonth,endDay)>
		<cfset endDate = createODBCDatetime(endDate)>
	<cfelse>
		<cfset endDate = createDate(endYear,endMonth,endDay)>
		<cfset endDate = createODBCDateTime(endDate)>
	</cfif>
	
	<cfset stProperties = structNew()>
	<cfset stProperties.objectid = stObj.objectid>
	<cfset stProperties.title = title>
	<cfset stProperties.label = title>
	<cfset stProperties.description = description>
	<cfset stProperties.template = template>
	<cfset stProperties.parameters = parameters>
	<cfset stProperties.frequency = frequency>
	<cfset stProperties.startDate = startDate>
	<cfset stProperties.endDate = endDate>
	<cfset stProperties.timeOut = timeOut>

	<!--- unlock object --->
	<cfset stProperties.locked = 0>
	<cfset stProperties.lockedBy = "">

	<cfif DateCompare(stProperties.startDate,stProperties.endDate) EQ 1>
		<cfset errormessage = errormessage & "Please select a End Date later than #DateFormat(stProperties.startDate,'dd-mmm-yyyy')#">
	</cfif>

	<!--- update the OBJECT --->
	<cfif errormessage EQ "">
		<cfset oType.setData(stProperties=stProperties)>
		<cflocation url="#application.url.farcry#/admin/scheduledTasks.cfm" addtoken="no">
	</cfif>
<cfelse>
	<cfif IsDate(stObj.startDate)>
		<cfset startDate = stObj.startDate>
	</cfif>

	<cfif IsDate(stObj.endDate)>
		<cfset endDate = stObj.endDate>
	</cfif>
	
	<cfif stObj.endDate eq stObj.startDate>
		<cfset stObj.endDate = dateadd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
	</cfif>
</cfif>
<cfset qTemplates = oType.listTemplates()>
<cfsetting enablecfoutputonly="no">

<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post">
<fieldset>
<h3>#application.rb.getResource("scheduledTaskDetails")#: <span class="highlight">#stObj.label#</span></h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
	<label for="title"><b>#application.rb.getResource("titleLabel")#</b>
		<input type="text" name="title" id="title" value="#stObj.title#" maxlength="255" size="45" /><br />
	</label>

	<label for="description"><b>#application.rb.getResource("descLabel")#</b>
		<textarea name="description" id="description">#stObj.description#</textarea><br />
	</label>

	<label for="template"><b>#application.rb.getResource("templateLabel")#</b>
		<select name="template" id="template"><cfloop query="qTemplates">
			<option value="#qTemplates.path#" <cfif stObj.template eq qTemplates.path>selected="selected"</cfif>>#qTemplates.displayName#</option></cfloop>
		</select><br />
	</label>

	<label for="parameters"><b>#application.rb.getResource("parametersLabel")#</b>
		<input type="text" name="parameters" id="parameters" value="#stObj.parameters#" maxlength="255" size="45" /><br />
	</label>

	<label for="frequency"><b>#application.rb.getResource("templateLabel")#</b>
		<select name="frequency" id="frequency">
			<option value="once"<cfif stObj.frequency eq "once"> selected="selected"</cfif>>#application.rb.getResource("once")#</option>
			<option value="daily"<cfif stObj.frequency eq "daily"> selected="selected"</cfif>>#application.rb.getResource("daily")#</option>
			<option value="weekly"<cfif stObj.frequency eq "weekly"> selected="selected"</cfif>>#application.rb.getResource("weekly")#</option>
			<option value="monthly"<cfif stObj.frequency eq "monthly"> selected="selected"</cfif>>#application.rb.getResource("monthly")#</option>
		</select><br />
	</label>
	
	<widgets:dateSelector fieldNamePrefix="start" fieldLabel="#application.rb.getResource("startDateLabel")#" fieldValue="#stObj.startDate#">

	<widgets:dateSelector fieldNamePrefix="end" fieldLabel="#application.rb.getResource("endDateLabel")#" fieldValue="#stObj.endDate#" bDateToggle="1">

	<label for="timeOut"><b>#application.rb.getResource("timeoutLabel")#</b>
		<input type="text" name="timeOut" id="timeOut" value="#stObj.timeOut#" maxlength="10" /><br />
	</label>

	<div class="f-submit-wrap">
	<input type="submit" name="submit" value="OK" class="f-submit" />
	<input type="submit" name="cancel" value="Cancel" class="f-submit" />
	</div>
	<input type="hidden" name="bFormSubmitted" value="yes">
</fieldset>
</form>
<script type="text/javascript">
//bring focus to title
document.editForm.title.focus();
</script></cfoutput>
<cfsetting enablecfoutputonly="no">