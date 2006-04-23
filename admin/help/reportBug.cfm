<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/reportBug.cfm,v 1.5 2005/08/09 03:54:40 geoff Exp $
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

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iHelpTab eq 1>
	<div class="formtitle"><cfoutput>#application.adminBundle[session.dmProfile.locale].reportBug#</cfoutput></div>
	
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
		<p><cfoutput>#application.adminBundle[session.dmProfile.locale].bugReportedThanks#</cfoutput></p>
		</div>
		
	<cfelse>
	<cfoutput>
		<!--- show form --->
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>#application.adminBundle[session.dmProfile.locale].thinkYouHaveBug#</p>
		<ul>
			<li><a href="mailingLists.cfm">#application.adminBundle[session.dmProfile.locale].mailingLists#</a></li>
			<li><a href="http://farcry.daemon.com.au/go/support/known-issues" target="_blank">#application.adminBundle[session.dmProfile.locale].knownIssuesList#</a></li>
		</ul>
		<p>&nbsp;</p>
		<p>#application.adminBundle[session.dmProfile.locale].fillBugTrackForm#</p>
		<p>&nbsp;</p>
		<table width="500">
		<form action="" method="post">
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].yourName#</td>
			<td><input type="text" name="bugFinder" value="#session.dmProfile.firstName# #session.dmProfile.lastName#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].yourEmail#</td>
			<td><input type="text" name="emailAddress" value="#session.dmProfile.emailAddress#" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].descTitle#</td>
			<td><input type="text" name="bugTitle" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>#application.adminBundle[session.dmProfile.locale].urgencyLevel#</td>
			<td>
				<select name="urgency">
					<option value="critical">#application.adminBundle[session.dmProfile.locale].critical#
					<option value="urgent">#application.adminBundle[session.dmProfile.locale].urgent#
					<option value="critical">#application.adminBundle[session.dmProfile.locale].normal#
					<option value="low priority">#application.adminBundle[session.dmProfile.locale].lowPriority#
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#application.adminBundle[session.dmProfile.locale].bugDesc#<br>
				<textarea name="bugDescription" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#application.adminBundle[session.dmProfile.locale].bugLocation#<br>
				<textarea name="bugLocation" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				#application.adminBundle[session.dmProfile.locale].replicateBugSteps#<br>
				<textarea name="bugReplicate" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				#application.adminBundle[session.dmProfile.locale].contactDetails#<br>
				<textarea name="bugContact" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2"><input name="submit" type="submit" value="#application.adminBundle[session.dmProfile.locale].reportBug#" class="normalbttnstyle"></td>
		</tr>	
		</form>
		</table>
		</div>
		</cfoutput>			
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>
<admin:footer>