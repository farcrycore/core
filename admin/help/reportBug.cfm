<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/reportBug.cfm,v 1.2 2003/09/17 05:14:50 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 05:14:50 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: bug reporting page for help tab. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iHelpTab eq 1>
	<div class="formtitle">Report A Bug</div>
	
	<cfif isdefined("form.submit")>
		<!--- send email --->
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
		<p>Your bug has been reported, Thank You.</p>
		</div>
		
	<cfelse>
		
		<!--- show form --->
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>Think you have found a bug? Please check the following that the bug has not already been reported</p>
		<ul>
			<li><a href="mailingLists.cfm">Mailing Lists</a></li>
			<li><a href="http://farcry.daemon.com.au/go/support/known-issues" target="_blank">Known Issues List</a></li>
		</ul>
		<p>&nbsp;</p>
		<p>If you cannot find reference to the bug, please fill out the form below and the bug will be added to the FarCry Issue Tracking System</p>
		<p>&nbsp;</p>
		<table width="500">
		<form action="" method="post">
		<tr>
			<td>Your Name</td>
			<td><input type="text" name="bugFinder" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>Your Email</td>
			<td><input type="text" name="emailAddress" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>Descriptive title</td>
			<td><input type="text" name="bugTitle" class="FormTextBox"></td>
		</tr>
		<tr>
			<td>Indication of urgency</td>
			<td>
				<select name="urgency">
					<option value="critical">Critical
					<option value="urgent">Urgent
					<option value="critical">Normal
					<option value="low priority">Low Priority
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				Bug Description<br>
				<textarea name="bugDescription" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				Location of where work is required (ie. Page of the site and server) or where the bug is occurring<br>
				<textarea name="bugLocation" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				If it is a bug, the steps to replicate the issue<br>
				<textarea name="bugReplicate" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		
		<tr>
			<td colspan="2">
				Contact details of person who is reporting the issue or the person that would be able to assist developers with further information if required.<br>
				<textarea name="bugContact" cols="60" rows="10" class="FormTextArea" style="width:500px"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2"><input name="submit" type="submit" value="Report Bug" class="normalbttnstyle"></td>
		</tr>	
		</form>
		</table>
		</div>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>