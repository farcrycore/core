<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEmail/plpEdit/options.cfm,v 1.2 2004/07/16 01:42:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 01:42:49 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

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
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].advancedOptions#</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- Reply to address --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].replyToLabel# </td>
		<td width="100%"><input type="text" name="replyTo" value="#output.replyTo#" class="formtextbox" maxlength="255"></td>
	</tr>
	
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].failToLabel# </td>
		<td width="100%"><input type="text" name="failTo" value="#output.failTo#" class="formtextbox" maxlength="255"></td>
	</tr>
	<!--- from address for email --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].wraptextLabel# </td>
		<td width="100%"><input type="text" name="wrapText" value="#output.wraptext#" class="formtextbox" maxlength="4"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].charSetLabel# </td>
		<td width="100%"><input type="text" name="charset" value="#output.charset#" class="formtextbox" maxlength="255"></td>
	</tr>
	</table>
	</div>
	
	<div class="FormTableClear">
		<tags:PLPNavigationButtons>
	</div>
	
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	document.editform.replyTo.focus();
	objForm = new qForm("editform");
	//-->
	</SCRIPT>
	</form></cfoutput>

<cfelse>
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">