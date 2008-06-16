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
$Header: /cvs/farcry/core/webtop/help/reportBug.cfm,v 1.5 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: bug reporting page for help tab. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="MainNavHelpTab">
	<div class="formtitle"><cfoutput>#application.rb.getResource("reportBug")#</cfoutput></div>
	
	<cfif isdefined("form.submit")>
		<!--- send email --->
		<!--- i18n: leaving these alone, going to oz?? --->
		<cfmail from="#form.emailAddress#" to="#application.config.general.bugEmail#" subject="#form.bugTitle#">
#form.bugFinder# has reported the following FarCry bug:

Title: #form.bugTitle#

Summary:
#form.bugDescription#

Urgency: #form.urgency#

Location:
#form.bugLocation#

Steps To Replicate:
#form.bugReplicate#

Contact:
#form.bugContact#
		</cfmail>
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p><cfoutput>#application.rb.getResource("bugReportedThanks")#</cfoutput></p>
		</div>
		
	<cfelse>
	<cfoutput>
		<!--- show form --->
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>#application.rb.getResource("thinkYouHaveBug")#</p>
		<ul>
			<li><a href="mailingLists.cfm">#application.rb.getResource("mailingLists")#</a></li>
			<li><a href="http://farcry.daemon.com.au/go/support/known-issues" target="_blank">#application.rb.getResource("knownIssuesList")#</a></li>
		</ul>
		<p>&nbsp;</p>
		<p>#application.rb.getResource("fillBugTrackForm")#</p>
		<p>&nbsp;</p>
		<table width="500">
		<form action="" method="post">
		<tr>
			<td>#application.rb.getResource("yourName")#</td>
			<td><input type="text" name="bugFinder" value="#session.dmProfile.firstName# #session.dmProfile.lastName#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.rb.getResource("yourEmail")#</td>
			<td><input type="text" name="emailAddress" value="#session.dmProfile.emailAddress#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.rb.getResource("descTitle")#</td>
			<td><input type="text" name="bugTitle" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.rb.getResource("urgencyLevel")#</td>
			<td>
				<select name="urgency">
					<option value="critical">#application.rb.getResource("critical")#
					<option value="urgent">#application.rb.getResource("urgent")#
					<option value="critical">#application.rb.getResource("normal")#
					<option value="low priority">#application.rb.getResource("lowPriority")#
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#application.rb.getResource("bugDesc")#<br>
				<textarea name="bugDescription" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#application.rb.getResource("bugLocation")#<br>
				<textarea name="bugLocation" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#application.rb.getResource("replicateBugSteps")#<br>
				<textarea name="bugReplicate" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#application.rb.getResource("contactDetails")#<br>
				<textarea name="bugContact" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2"><input name="submit" type="submit" value="#application.rb.getResource("reportBug")#" class="normalbttnstyle"></td>
		</tr>	
		</form>
		</table>
		</div>
		</cfoutput>			
	</cfif>
</sec:CheckPermission>

<admin:footer>