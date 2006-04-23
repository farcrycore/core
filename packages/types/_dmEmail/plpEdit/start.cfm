<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/start.cfm,v 1.1 2003/08/05 05:54:45 brendan Exp $
$Author: brendan $
$Date: 2003/08/05 05:54:45 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: dmEmail -- Start PLP Step $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>		

<!--- show form --->
<cfif NOT thisstep.isComplete>
	<!--- get policy groups --->
	<cfobject component="#application.packagepath#.security.authorisation" name="oAuthorisation">
	<cfset aPolicyGroups = oAuthorisation.getAllPolicyGroups()>
	
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- email subject --->
	<tr>
		<td nowrap class="FormLabel">Subject: </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- send to which FarCry groups --->
	<tr>
		<td nowrap class="FormLabel" valign="top">Send To: </span></td>
		<td>
			<select name="lGroups" multiple size="8">
				<cfloop from="1" to="#arrayLen(aPolicyGroups)#" index="group">
					<option value="#aPolicyGroups[group].PolicyGroupId#" <cfif listFind("#output.lGroups#","#aPolicyGroups[group].PolicyGroupId#")>selected</cfif>>#aPolicyGroups[group].PolicyGroupName#
				</cfloop>
			</select>
		</td>
	</tr>
	<!--- from address for email --->
	<tr>
		<td nowrap class="FormLabel">From Email Address: </span></td>
		<td width="100%"><input type="text" name="fromEmail" value="#output.fromEmail#" class="formtextbox" maxlength="255"></td>
	</tr>
	</table>
	</div>
	
	<div class="FormTableClear">
		<tags:PLPNavigationButtons>
	</div>
	
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	document.editform.Title.focus();
	objForm = new qForm("editform");
	objForm.Title.validateNotNull("Please enter a title");
	objForm.lGroups.validateNotNull("Please select a group to send this email to");
	objForm.fromEmail.validateNotNull("Please enter a from email address");
	//-->
	</SCRIPT>
	</form></cfoutput>

<cfelse>
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">