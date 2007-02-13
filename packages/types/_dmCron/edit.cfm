<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
<h3>#application.adminBundle[session.dmProfile.locale].scheduledTaskDetails#: <span class="highlight">#stObj.label#</span></h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
	<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#</b>
		<input type="text" name="title" id="title" value="#stObj.title#" maxlength="255" size="45" /><br />
	</label>

	<label for="description"><b>#application.adminBundle[session.dmProfile.locale].descLabel#</b>
		<textarea name="description" id="description">#stObj.description#</textarea><br />
	</label>

	<label for="template"><b>#application.adminBundle[session.dmProfile.locale].templateLabel#</b>
		<select name="template" id="template"><cfloop query="qTemplates">
			<option value="#qTemplates.path#" <cfif stObj.template eq qTemplates.path>selected="selected"</cfif>>#qTemplates.displayName#</option></cfloop>
		</select><br />
	</label>

	<label for="parameters"><b>#application.adminBundle[session.dmProfile.locale].parametersLabel#</b>
		<input type="text" name="parameters" id="parameters" value="#stObj.parameters#" maxlength="255" size="45" /><br />
	</label>

	<label for="frequency"><b>#application.adminBundle[session.dmProfile.locale].templateLabel#</b>
		<select name="frequency" id="frequency">
			<option value="once"<cfif stObj.frequency eq "once"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].once#</option>
			<option value="daily"<cfif stObj.frequency eq "daily"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].daily#</option>
			<option value="weekly"<cfif stObj.frequency eq "weekly"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].weekly#</option>
			<option value="monthly"<cfif stObj.frequency eq "monthly"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].monthly#</option>
		</select><br />
	</label>
	
	<widgets:dateSelector fieldNamePrefix="start" fieldLabel="#application.adminBundle[session.dmProfile.locale].startDateLabel#" fieldValue="#stObj.startDate#">

	<widgets:dateSelector fieldNamePrefix="end" fieldLabel="#application.adminBundle[session.dmProfile.locale].endDateLabel#" fieldValue="#stObj.endDate#" bDateToggle="1">

	<label for="timeOut"><b>#application.adminBundle[session.dmProfile.locale].timeoutLabel#</b>
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