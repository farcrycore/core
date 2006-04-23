<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/start.cfm,v 1.19.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.19.2.1 $

|| DESCRIPTION || 
$Description: dmEvent Edit PLP - Start Step $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">

<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<!--- <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display"> --->
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.plpAction")>
	<!--- publish/expiry dates --->
	<cfset publishDate = createDateTime(form.publishYear,form.publishMonth,form.publishDay,form.publishHour,form.publishMinutes,0)>
	<cfset output.publishDate = createODBCDatetime(publishDate)>
	<!--- hack for no expiry. sets expiry year to 2050...the y2050 bug :) --->
	<cfif form.noExpiry EQ 1>
		<cfset expiryDate = createDateTime('2050',form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0)>
	<cfelse>
		<cfset expiryDate = createDateTime(form.expiryYear,form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0)>
	</cfif>	
	<cfset output.expiryDate = createODBCDatetime(expiryDate)>
	
	<!--- start/end dates --->
	<cfset startDate = createDateTime(form.startYear,form.startMonth,form.startDay,form.startHour,form.startMinutes,0)>
	<cfset output.startDate = createODBCDatetime(startDate)>
	<!--- hack for no expiry. sets expiry year to 2050...the y2050 bug :) --->
	<cfif form.noEnd EQ 1>
		<cfset endDate = createDateTime('2050',form.endMonth,form.endDay,form.endHour,form.endMinutes,0)>
	<cfelse>
		<cfset endDate = createDateTime(form.endYear,form.endMonth,form.endDay,form.endHour,form.endMinutes,0)>
	</cfif>	

	<cfset output.endDate = createODBCDatetime(endDate)>
	<cfif NOT (DateDiff('n', output.publishDate,output.expiryDate) GTE 0 AND dateDiff('n', output.startDate,output.endDate) GTE 0)>
		<cfset errormessage = errormessage & application.adminBundle[session.dmProfile.locale].errEndBeforeStartDate>
	</cfif>

	<cfif errormessage EQ "">
		<widgets:plpAction>
	</cfif>
<cfelse>
	<!--- default publish/expiry dates - catch invalid date formats --->
	<cfif NOT IsDate(output.publishDate)>
		<cfset output.publishDate = now()>
	</cfif>
	
	<cfif NOT IsDate(output.expiryDate)>
		<cfset output.expiryDate = DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
	</cfif>

	<!--- default start/end dates - catch invalid date formats --->
	<cfif NOT IsDate(output.startDate)>
		<cfset output.startDate = now()>
	</cfif>
	
	<cfif NOT IsDate(output.endDate)>
		<cfset output.endDate = DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
	</cfif>
</cfif>

<cfif NOT thisstep.isComplete>
<widgets:plpWrapper>
<cfoutput>
	<cfif errormessage NEQ "">
		<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	</cfif>
	<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-short" name="editform" method="post">
		<fieldset>
			<div class="req"><b>*</b>Required</div>
			<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
				<input type="text" name="title" id="title" value="#output.title#" maxlength="255" size="45" /><br />
			</label>
	
			<label for="Location"><b>#application.adminBundle[session.dmProfile.locale].locationLabel#</b>
				<input type="text" name="Location" id="Location" value="#output.Location#" maxlength="255" size="45" /><br />
			</label>
</cfoutput>
			<widgets:dateSelector fieldNamePrefix="publish" fieldlabel="#application.adminBundle[session.dmProfile.locale].goLiveLabel#">
		
			<widgets:dateSelector fieldNamePrefix="expiry" fieldlabel="#application.adminBundle[session.dmProfile.locale].expiryDatelabel#" bDateToggle="1">
			
			<widgets:dateSelector fieldNamePrefix="start" fieldlabel="#application.adminBundle[session.dmProfile.locale].eventStartDate#">
		
			<widgets:dateSelector fieldNamePrefix="end" fieldlabel="#application.adminBundle[session.dmProfile.locale].eventEndDateLabel#" bDateToggle="1">
			
			<widgets:displayMethodSelector typeName="#output.typeName#" prefix="displayPage">	
<cfoutput>
		</fieldset>
	
		<input type="hidden" name="plpAction" value="" />
		<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
	</form>
	<cfinclude template="/farcry/farcry_core/admin/includes/QFormValidationJS.cfm">
</cfoutput>
</widgets:plpWrapper>
<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">