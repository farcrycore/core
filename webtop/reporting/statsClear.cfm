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
$Header: /cvs/farcry/core/webtop/reporting/statsClear.cfm,v 1.5.2.1 2006/03/24 01:05:36 daniela Exp $
$Author: daniela $
$Date: 2006/03/24 01:05:36 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION || 
Rebuilds statistics tables

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| TO DO ||
i18n for drop down menu

|| ATTRIBUTES ||
in: 
out:
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfset nowDate = CreateDate(year(Now()),month(Now()),day(Now()))>
<cfparam name="purgeDate" default="#DateAdd('q',-1,nowDate)#">
<cfparam name="bFormSubmitted" default="no">
<cfif bFormSubmitted EQ "yes">
	<cfset returnstruct = application.factory.oStats.fPurgeStatistics(purgeDate)>
	<cfif returnstruct.bSuccess>
		<cfset successmessage = returnstruct.message>
	<cfelse>
		<cfset errormessage = returnstruct.message>
	</cfif>
</cfif>

<!--- purge dates defaults --->
<cfset aPurgeDates = ArrayNew(1)>
<cfset aPurgeDates[1] = StructNew()>
<cfset aPurgeDates[1].purgeDate = DateAdd('w',-1,nowDate)>
<cfset aPurgeDates[1].purgelabel = "Older than one week">

<cfset aPurgeDates[2] = StructNew()>
<cfset aPurgeDates[2].purgeDate = DateAdd('m',-1,nowDate)>
<cfset aPurgeDates[2].purgelabel = "Older than one month">

<cfset aPurgeDates[3] = StructNew()>
<cfset aPurgeDates[3].purgeDate = DateAdd('q',-1,nowDate)>
<cfset aPurgeDates[3].purgelabel = "Older than one quarter">

<cfset aPurgeDates[4] = StructNew()>
<cfset aPurgeDates[4].purgeDate = DateAdd('m',-6,nowDate)>
<cfset aPurgeDates[4].purgelabel = "Older than six months">

<cfset aPurgeDates[5] = StructNew()>
<cfset aPurgeDates[5].purgeDate = DateAdd('y',-1,nowDate)>
<cfset aPurgeDates[5].purgelabel = "Older than one year">
<!--- // purge dates defaults --->


<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ReportingStatsTab">
	<cfoutput>
	<script type="text/javascript">
	function doSubmit(objForm)
	{	
		return window.confirm("Are you sure you wish to delete statistices " + objForm.purgedate[objForm.purgedate.selectedIndex].text + ".");
	}
	</script>
	
	
	<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-1 wider f-bg-long" onsubmit="return doSubmit(document.editform);">
		<fieldset>
			<div class="req"><b>*</b>Required</div>
			<h3>#application.rb.getResource("clearStatsLog")#</h3>
			<cfif isDefined("errormessage")>
				<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>			
			<cfelseif isDefined("successmessage")>
				<p id="fading1" class="fade"><span class="success">#successmessage#</span></p>
			</cfif>
			<label for="purgedate"><b>Purge Statitistics:<span class="req">*</span></b>
				<select name="purgedate" id="purgedate"><cfloop index="i" from="1" to="#ArrayLen(aPurgeDates)#">
					<option value="#aPurgeDates[i].purgedate#"<cfif purgedate EQ aPurgeDates[i].purgedate> selected="selected"</cfif>>#aPurgeDates[i].purgeLabel#</option></cfloop>
				</select><br />
			</label> 
		</fieldset>
		<input type="hidden" name="bFormSubmitted" id="bFormSubmitted" value="yes">
		<div class="f-submit-wrap">
		<input type="Submit" name="Submit" value="#application.rb.getResource("OK")#" class="f-submit">
		</div>
	</form></cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">