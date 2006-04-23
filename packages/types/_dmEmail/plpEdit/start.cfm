<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/start.cfm,v 1.3 2004/09/28 04:57:09 brendan Exp $
$Author: brendan $
$Date: 2004/09/28 04:57:09 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmEmail -- Start PLP Step $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

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
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- email subject --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].subjLabel# </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- send to which FarCry groups --->
	<tr>
		<td nowrap class="FormLabel" valign="top">#application.adminBundle[session.dmProfile.locale].toLabel# </span></td>
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
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].fromEmailLabel# </span></td>
		<td width="100%"><input type="text" name="fromEmail" value="#output.fromEmail#" class="formtextbox" maxlength="255"></td>
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
	objForm.lGroups.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseSelectEmailGroup#");
	objForm.fromEmail.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterEmail#");
	//-->
	</SCRIPT>
	</form></cfoutput>

<cfelse>
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">