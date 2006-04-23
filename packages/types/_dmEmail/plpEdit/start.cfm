<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/start.cfm,v 1.5.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION || 
$Description: dmEmail -- Start PLP Step $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<!--- show form --->
<cfif NOT thisstep.isComplete>
	<!--- get policy groups --->
	<cfobject component="#application.packagepath#.security.authorisation" name="oAuthorisation">
	<cfset aPolicyGroups = oAuthorisation.getAllPolicyGroups()>
<widgets:plpWrapper>
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" name="editform" class="f-wrap-1 wider f-bg-short" method="post">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- email subject --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].subjLabel# </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255" size="45"></td>
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
		<td width="100%"><input type="text" name="fromEmail" value="#output.fromEmail#" class="formtextbox" maxlength="255" size="45"></td>
	</tr>
	</table>
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
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
	</form></cfoutput>
</widgets:plpWrapper>
<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">