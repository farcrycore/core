<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmCron/edit.cfm,v 1.4 2003/11/05 04:46:09 tom Exp $
$Author: tom $
$Date: 2003/11/05 04:46:09 $
$Name: milestone_2-1-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: edit handler$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset showform=1>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfset showform=0>
	<span class="FormTitle">Object Updated</span>
		
	<cfscript>
		startDate = '#form.startYear#-#form.startMonth#-#form.startDay# #form.startHour#:#form.startMinutes#';
		form.startDate = createODBCDatetime(startDate);
		// hack for no expiry. sets expiry year to 2050...the y2050 bug :)
		if (form.noExpire) {
			endDate = createDate(2050,form.endMonth,form.endDay);
			form.endDate = createODBCDatetime(endDate);
		} else {
			endDate = createDate(form.endYear,form.endMonth,form.endDay);
			form.endDate = createODBCDateTime(endDate);
		}
	
		stProperties = structNew();
		StProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
		stProperties.template = form.template;
		stProperties.parameters = form.parameters;
		stProperties.frequency = form.frequency;
		stProperties.startDate = form.startDate;
		stProperties.endDate = form.endDate;
		stProperties.timeOut = form.timeOut;
			
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	
		// update the OBJECT	
		oType = createobject("component", application.types.dmCron.typePath);
		oType.setData(stProperties=stProperties);
	</cfscript>
	
	<cfif not isdefined("error")>
		<!--- reload list page --->
		<cflocation url="#application.url.farcry#/admin/scheduledTasks.cfm" addtoken="no">
				
	<cfelse>
		<cfset showform=1>
	</cfif>
</cfif>

<cfif len(stObj.startDate) eq 0>
	<cfset stObj.startDate = now()>
</cfif>
<cfif len(stObj.endDate) eq 0>
	<cfset stObj.endDate = now()>
</cfif>
<cfif stObj.endDate eq stObj.startDate>
	<cfset stObj.endDate = dateadd(application.config.general.newsExpiryType,application.config.general.newsExpiry,"#now()#")>
</cfif>
	
<cfif showform> <!--- Show the form --->
	<cfscript>
		// update the OBJECT	
		oType = createobject("component", application.types.dmCron.typePath);
		qTemplates = oType.listTemplates();
	</cfscript>
	
	<cfoutput>
	<br>
	<span class="FormTitle">Scheduled Task Details</span><p></p>
	<form action="" method="post" name="fileForm">
	<table class="FormTable">
	
	<tr>
	  	<td><span class="FormLabel">Title:</span></td>
	   	<td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	
	<tr>
	  	<td valign="top"><span class="FormLabel">Description:</span></td>
	   	<td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	<tr>
	  	<td><span class="FormLabel">Template:</span></td>
	   	<td>
			<select name="template">
				<cfloop query="qTemplates">
					<option value="#path#" <cfif stObj.template eq path>selected</cfif>>#displayName#
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
	  	<td><span class="FormLabel">Parameters:</span></td>
	   	<td><input type="text" name="parameters" value="#stObj.parameters#" class="FormTextBox"></td>
	</tr>
	<tr>
	  	<td><span class="FormLabel">Frequency:</span></td>
	   	<td>
			<select name="frequency">
				<option value="once" <cfif stObj.frequency eq "once">selected</cfif>>Once
				<option value="daily" <cfif stObj.frequency eq "daily">selected</cfif>>Daily
				<option value="weekly" <cfif stObj.frequency eq "weekly">selected</cfif>>Weekly
				<option value="monthly" <cfif stObj.frequency eq "monthly">selected</cfif>>Monthly
			</select>
		</tr>
	<tr>
	  	<td><span class="FormLabel">Start Date:</span></td>
	   	<td>
		<table>
				<tr>
					<td>
						<select name="startDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(stObj.startDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="startMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(stObj.startDate)>selected</cfif>>#monthAsString(i)#</option>
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
								<option value="#i#" <cfif i IS year(stObj.startDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="startHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(stObj.startDate) IS i>selected</cfif>>#i# hrs</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="startMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(stObj.startDate) IS i>selected</cfif>>#i# mins</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td nowrap>
			<span class="FormLabel">End Date:</span>
			<!--- show links to for no expiry/yes expiry date --->
			<input type="hidden" name="noExpire" value="<cfif 2050 is year(stObj.endDate)>1<cfelse>0</cfif>">
		 	<div style="display:inline">
				<a href="javascript:void(0);" id="noLink" onClick="document.getElementById('noLink').style.visibility='hidden';document.getElementById('yesLink').style.visibility='visible';noExpire.value='1';document.getElementById('expire').style.visibility='hidden';" style="position:absolute;<cfif 2050 is year(stObj.endDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/no.gif" border="0" alt="No End Date"></a>
				<a href="javascript:void(0);" id="yesLink" onClick="document.getElementById('noLink').style.visibility='visible';document.getElementById('yesLink').style.visibility='hidden';noExpire.value='0';endYear.value='#year(now())#';document.getElementById('expire').style.visibility='visible';" style="position:absolute;<cfif not 2050 is year(stObj.endDate)>visibility:hidden</cfif>"><img src="#application.url.farcry#/images/yes.gif" border="0" alt="Has End Date"></a>
			</div>
		</td>
		<td>
			<table id="expire" <cfif 2050 is year(stObj.endDate)>style="visibility:hidden"</cfif>>
				<tr>
					<td>
						<select name="endDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(stObj.endDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="endMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(stObj.endDate)>selected</cfif>>#monthAsString(i)#</option>
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
								<option value="#i#" <cfif i IS year(stObj.endDate)>selected</cfif>>#i#</option>
							</cfloop>
							<!--- if set to not expire --->
							<cfif 2050 IS year(stObj.endDate)>
								<option value="2050" selected></option>
							</cfif>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
	  	<td><span class="FormLabel">Time Out (seconds):</span></td>
	   	<td><input type="text" name="timeOut" value="#stObj.timeOut#" class="FormTextBox"></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="Submit" value="Done!" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/admin/scheduledTasks.cfm';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">  
		</td>
	</tr>
		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
	</script>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">