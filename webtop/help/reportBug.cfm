<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
	<div class="formtitle"><cfoutput>#apapplication.rb.getResource("reportBug")#</cfoutput></div>
	
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
		<p><cfoutput>#apapplication.rb.getResource("bugReportedThanks")#</cfoutput></p>
		</div>
		
	<cfelse>
	<cfoutput>
		<!--- show form --->
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>#apapplication.rb.getResource("thinkYouHaveBug")#</p>
		<ul>
			<li><a href="mailingLists.cfm">#apapplication.rb.getResource("mailingLists")#</a></li>
			<li><a href="http://farcry.daemon.com.au/go/support/known-issues" target="_blank">#apapplication.rb.getResource("knownIssuesList")#</a></li>
		</ul>
		<p>&nbsp;</p>
		<p>#apapplication.rb.getResource("fillBugTrackForm")#</p>
		<p>&nbsp;</p>
		<table width="500">
		<form action="" method="post">
		<tr>
			<td>#apapplication.rb.getResource("yourName")#</td>
			<td><input type="text" name="bugFinder" value="#session.dmProfile.firstName# #session.dmProfile.lastName#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#apapplication.rb.getResource("yourEmail")#</td>
			<td><input type="text" name="emailAddress" value="#session.dmProfile.emailAddress#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#apapplication.rb.getResource("descTitle")#</td>
			<td><input type="text" name="bugTitle" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#apapplication.rb.getResource("urgencyLevel")#</td>
			<td>
				<select name="urgency">
					<option value="critical">#apapplication.rb.getResource("critical")#
					<option value="urgent">#apapplication.rb.getResource("urgent")#
					<option value="critical">#apapplication.rb.getResource("normal")#
					<option value="low priority">#apapplication.rb.getResource("lowPriority")#
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#apapplication.rb.getResource("bugDesc")#<br>
				<textarea name="bugDescription" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#apapplication.rb.getResource("bugLocation")#<br>
				<textarea name="bugLocation" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#apapplication.rb.getResource("replicateBugSteps")#<br>
				<textarea name="bugReplicate" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#apapplication.rb.getResource("contactDetails")#<br>
				<textarea name="bugContact" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2"><input name="submit" type="submit" value="#apapplication.rb.getResource("reportBug")#" class="normalbttnstyle"></td>
		</tr>	
		</form>
		</table>
		</div>
		</cfoutput>			
	</cfif>
</sec:CheckPermission>

<admin:footer>