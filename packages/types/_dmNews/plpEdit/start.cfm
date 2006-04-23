<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/start.cfm,v 1.30.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.30.2.1 $

|| DESCRIPTION || 
$Description: dmNews Edit PLP - Start Step $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfparam name="errormessage" default="">
<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.plpAction")>
	<cfset publishDate = '#form.publishYear#-#form.publishMonth#-#form.publishDay# #form.publishHour#:#form.publishMinutes#'>
	<cfset output.publishDate = createODBCDatetime(publishDate)>

	<cfif form.noExpiry EQ 1>
		<cfset expiryDate = '2050-#form.expiryMonth#-#form.expiryDay# #form.expiryHour#:#form.expiryMinutes#'>		
	<cfelse>
		<cfset expiryDate = '#form.expiryYear#-#form.expiryMonth#-#form.expiryDay# #form.expiryHour#:#form.expiryMinutes#'>
	</cfif>

	<cfset output.expiryDate = createODBCDatetime(expiryDate)>

	<cfif output.expiryDate LT output.publishDate>
		<cfset errormessage = errormessage & application.adminBundle[session.dmProfile.locale].errExpiryBeforePublishDate>
	</cfif>
	<cfif errormessage EQ "">
		<widgets:plpAction>
	</cfif>
<cfelse>
	<cfif NOT IsDate(output.publishDate)>
		<cfset output.publishDate = now()>
	</cfif>
	
	<!--- catch invalid date formats --->
	<cfif NOT IsDate(output.expiryDate)>
		<cfset output.expiryDate = DateAdd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
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
</cfoutput>
			<widgets:dateSelector fieldNamePrefix="publish" fieldlabel="#application.adminBundle[session.dmProfile.locale].goLiveLabel#">
			<widgets:dateSelector fieldNamePrefix="expiry" fieldlabel="#application.adminBundle[session.dmProfile.locale].expiryDatelabel#" bDateToggle="1">
			<widgets:displayMethodSelector typeName="#output.typeName#" prefix="displayPage">
<cfoutput>
			<label for="source"><b>Source:</b>
				<input type="text" name="source" value="#output.source#" id="source"><br />
			</label>
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