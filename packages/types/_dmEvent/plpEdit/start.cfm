<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/start.cfm,v 1.11 2004/07/21 11:11:16 brendan Exp $
$Author: brendan $
$Date: 2004/07/21 11:11:16 $
$Name: milestone_2-3-2 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: dmEvent Edit PLP - Start Step $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("FORM.submit") or isdefined("form.save") or (isdefined("form.quicknav") and form.quicknav neq "")>
	<cfscript>
		//publish/expiry dates
		publishDate = createDateTime(form.publishYear,form.publishMonth,form.publishDay,form.publishHour,form.publishMinutes,0);
		output.publishDate = createODBCDatetime(publishDate);
		// hack for no expiry. sets expiry year to 2050...the y2050 bug :)
		if (form.noExpire) {
			expiryDate = createDateTime('2050',form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0);
			output.expiryDate = createODBCDatetime(expiryDate);
		} else {
			expiryDate = createDateTime(form.expiryYear,form.expiryMonth,form.expiryDay,form.expiryHour,form.expiryMinutes,0);
			output.expiryDate = createODBCDatetime(expiryDate);
		}
		
		//start/end dates
		startDate = createDateTime(form.startYear,form.startMonth,form.startDay,form.startHour,form.startMinutes,0);
		output.startDate = createODBCDatetime(startDate);
		if (form.noEventExpire) {
			endDate = createDateTime('2050',form.endMonth,form.endDay,form.endHour,form.endMinutes,0);
			output.endDate = createODBCDatetime(endDate);
		} else {
			endDate = createDateTime(form.endYear,form.endMonth,form.endDay,form.endHour,form.endMinutes,0);
			output.endDate = createODBCDatetime(endDate);
		}
	</cfscript>
</cfif>
<!--- default publish/expiry dates --->
<cfscript>
	if (not isDate(output.startDate))
		output.startDate = createDateTime(year(now()),month(now()),day(now()),hour(now()),minute(now()),0);	
	if (not isDate(output.endDate))
		output.endDate = createDateTime(year(now()),month(now()),day(now()),hour(now()),minute(now()),0);	
	if (not isDate(output.publishDate))
		output.publishDate = createDateTime(year(now()),month(now()),day(now()),hour(now()),minute(now()),0);
	if(output.expiryDate eq output.publishDate)		 
		output.expiryDate = dateadd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#");
	
	
</cfscript>
<cfif dateDiff('n', output.publishDate,output.expiryDate) gte 0 and dateDiff('n', output.startDate,output.endDate) GTE 0 >
	<tags:plpNavigationMove>		
<cfelse>
	<cfoutput><div style="color:red;"><p>#application.adminBundle[session.dmProfile.locale].errEndBeforeStartDate#</p></div></cfoutput>
</cfif>


	
<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	<div class="FormTable" style="width:550px;">
	<table class="BorderTable" width="auto;" align="center">
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel# </span></td>
		<td><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].locationLabel# </span></td>
		<td><input type="text" name="Location" value="#output.Location#" class="formtextbox" maxlength="255"></td>
	</tr>
	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmEvent" prefix="displayPage" r_qMethods="qMethods">
	<cfoutput>
	<tr>
		<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].displayMethodLabel#</span></td>
		<td><span class="FormLabel">
		<select name="DisplayMethod" size="1" class="formfield">
		</cfoutput>
		<cfloop query="qMethods">
			<cfoutput><option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displayMethod>SELECTED</cfif>>#qMethods.displayname#</option></cfoutput>
		</cfloop>
		<cfoutput>
		</select>
		</span>
		</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].goLiveLabel#</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="publishDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.publishDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="publishMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.publishDate)>selected</cfif>>#localeMonths[i]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="publishYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.publishDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.publishDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.publishDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td nowrap>
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].expiryDateLabel#</span>
			<!--- show links to for no expiry/yes expiry date --->
			<input type="hidden" name="noExpire" value="<cfif 2050 is year(output.expiryDate)>1<cfelse>0</cfif>">
		 	<div style="display:inline">
				<a href="##" id="noLink" onClick="document.getElementById('noLink').style.visibility='hidden';document.getElementById('yesLink').style.visibility='visible';editform.noExpire.value='1';document.getElementById('expire').style.visibility='hidden';" style="position:absolute;<cfif 2050 is year(output.expiryDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/no.gif" border="0" alt="No Expiry Date"></a>
				<a href="##" id="yesLink" onClick="document.getElementById('noLink').style.visibility='visible';document.getElementById('yesLink').style.visibility='hidden';editform.noExpire.value='0';editform.expiryYear.value='#year(now())#';document.getElementById('expire').style.visibility='visible';" style="position:absolute;<cfif not 2050 is year(output.expiryDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/yes.gif" border="0" alt="Has Expiry Date"></a>
			</div>
		</td>
		<td >
			<table id="expire" <cfif 2050 is year(output.expiryDate)>style="visibility:hidden"</cfif>>
				<tr>
					<td>
						<select name="expiryDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.expiryDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="expiryMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.expiryDate)>selected</cfif>>#LocaleMonths[i]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="expiryYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.expiryDate)>selected</cfif>>#i#</option>
							</cfloop>
							<!--- if set to not expire --->
							<cfif 2050 IS year(output.expiryDate)>
								<option value="2050" selected></option>
							</cfif>
						</select>
					</td>	
					<td>
						<select name="expiryHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.expiryDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="expiryMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.expiryDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].eventStartDate#</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="startDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.startDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="startMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.startDate)>selected</cfif>>#localeMonths[i]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="startYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.startDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="startHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.startDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="startMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.startDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td nowrap>
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].eventEndDateLabel#</span>
			<!--- show links to for no expiry/yes expiry date --->
			<input type="hidden" name="noEventExpire" value="<cfif 2050 is year(output.endDate)>1<cfelse>0</cfif>">
		 	<div style="display:inline">
				<a href="##" id="noEventLink" onClick="document.getElementById('noEventLink').style.visibility='hidden';document.getElementById('yesEventLink').style.visibility='visible';noEventExpire.value='1';document.getElementById('eventExpire').style.visibility='hidden';" style="position:absolute;<cfif 2050 is year(output.endDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/no.gif" border="0" alt="No Expiry Date"></a>
				<a href="##" id="yesEventLink" onClick="document.getElementById('noEventLink').style.visibility='visible';document.getElementById('yesEventLink').style.visibility='hidden';noEventExpire.value='0';endYear.value='#year(now())#';document.getElementById('eventExpire').style.visibility='visible';" style="position:absolute;<cfif not 2050 is year(output.endDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/yes.gif" border="0" alt="Has Expiry Date"></a>
			</div>
		</td>
		<td >
			<table id="eventExpire" <cfif 2050 is year(output.endDate)>style="visibility:hidden"</cfif>>
				<tr>
					<td>
						<select name="endDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(output.endDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="endMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(output.endDate)>selected</cfif>>#localeMonths[i]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="endYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(output.endDate)>selected</cfif>>#i#</option>
							</cfloop>
							<!--- if set to not expire --->
							<cfif 2050 IS year(output.endDate)>
								<option value="2050" selected></option>
							</cfif>
						</select>
					</td>	
					<td>
						<select name="endHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(output.endDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="endMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(output.endDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</cfoutput>
	</table>
	</div>
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	document.editform.Title.focus();
	objForm = new qForm("editform");
	objForm.Title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
		//-->
	</SCRIPT>
	</form></cfoutput>
	
<cfelse>
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">