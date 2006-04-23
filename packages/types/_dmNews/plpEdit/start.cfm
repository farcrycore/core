<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/start.cfm,v 1.9 2004/07/21 11:11:16 brendan Exp $
$Author: brendan $
$Date: 2004/07/21 11:11:16 $
$Name: milestone_2-3-2 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: dmNews Edit PLP - Start Step $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
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
		publishDate = '#form.publishYear#-#form.publishMonth#-#form.publishDay# #form.publishHour#:#form.publishMinutes#';
		output.publishDate = createODBCDatetime(publishDate);
		// hack for no expiry. sets expiry year to 2050...the y2050 bug :)
		if (form.noExpire) {
			expiryDate = '2050-#form.expiryMonth#-#form.expiryDay# #form.expiryHour#:#form.expiryMinutes#';
			output.expiryDate = createODBCDatetime(expiryDate);
		} else {
			expiryDate = '#form.expiryYear#-#form.expiryMonth#-#form.expiryDay# #form.expiryHour#:#form.expiryMinutes#';
			output.expiryDate = createODBCDatetime(expiryDate);
		}
		//output.title = FORM.title;
	</cfscript>
</cfif>

<cfif output.expiryDate gte output.publishDate>
	<tags:plpNavigationMove>		
<cfelse>
	<cfoutput><div style="color:red;"><p>#application.adminBundle[session.dmProfile.locale].errExpiryBeforePublishDate#</p></div></cfoutput>
</cfif>

<cfif len(output.publishDate ) eq 0>
	<cfset output.publishDate = now()>
</cfif>
<cfif output.expiryDate eq output.publishDate>
	<cfset output.expiryDate = dateadd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
</cfif>

<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	<div class="FormTable" style="width:80%">
	<table class="BorderTable" width="80%" align="center">
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel# </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
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
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].expiryDatelabel#</span>
			<!--- show links to for no expiry/yes expiry date --->
			<input type="hidden" name="noExpire" value="<cfif 2050 is year(output.expiryDate)>1<cfelse>0</cfif>">
		 	<div style="display:inline">
				<a href="javascript:void(0);" id="noLink" onClick="document.getElementById('noLink').style.visibility='hidden';document.getElementById('yesLink').style.visibility='visible';editform.noExpire.value='1';document.getElementById('expire').style.visibility='hidden';" style="position:absolute;<cfif 2050 is year(output.expiryDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/no.gif" border="0" alt="No Expiry Date"></a>
				<a href="javascript:void(0);" id="yesLink" onClick="document.getElementById('noLink').style.visibility='visible';document.getElementById('yesLink').style.visibility='hidden';editform.noExpire.value='0';editform.expiryYear.value='#year(now())#';document.getElementById('expire').style.visibility='visible';" style="position:absolute;<cfif not 2050 is year(output.expiryDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/yes.gif" border="0" alt="Has Expiry Date"></a>
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
								<option value="#i#" <cfif i IS month(output.expiryDate)>selected</cfif>>#localeMonths[i]#</option>
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
	</cfoutput>
	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmNews" prefix="displayPage" r_qMethods="qMethods">
	<cfoutput>
	<tr>
		<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].displayMethodLabel#</span></td>
		<td width="100%"><span class="FormLabel">
		<select name="DisplayMethod" size="1" class="formfield">
		</cfoutput>
		<cfloop query="qMethods">
			<cfoutput><option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displayMethod>SELECTED</cfif>>#qMethods.displayname#</option></cfoutput>
		</cfloop>
		<cfoutput>
		</select>
		</span></td>
	</tr>
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