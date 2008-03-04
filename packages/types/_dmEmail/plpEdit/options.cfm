<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmEmail/plpEdit/options.cfm,v 1.4.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.4.2.1 $

|| DESCRIPTION || 
$Description: dmEmail -- Start PLP Step $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<!--- show form --->
<cfif NOT thisstep.isComplete>
	<!--- get policy groups --->
	<cfset aPolicyGroups = application.factory.oAuthorisation.getAllPolicyGroups()>
<widgets:plpWrapper>	
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" name="editform" class="f-wrap-1 wider f-bg-short" method="post">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#apapplication.rb.getResource("advancedOptions")#</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- Reply to address --->
	<tr>
		<td nowrap class="FormLabel">#apapplication.rb.getResource("replyToLabel")# </td>
		<td width="100%"><input type="text" name="replyTo" value="#output.replyTo#" class="formtextbox" maxlength="255" size="45"></td>
	</tr>
	
	<tr>
		<td nowrap class="FormLabel">#apapplication.rb.getResource("failToLabel")# </td>
		<td width="100%"><input type="text" name="failTo" value="#output.failTo#" class="formtextbox" maxlength="255" size="45"></td>
	</tr>
	<!--- from address for email --->
	<tr>
		<td nowrap class="FormLabel">#apapplication.rb.getResource("wraptextLabel")# </td>
		<td width="100%"><input type="text" name="wrapText" value="#output.wraptext#" class="formtextbox" maxlength="4"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#apapplication.rb.getResource("charSetLabel")# </td>
		<td width="100%"><input type="text" name="charset" value="#output.charset#" class="formtextbox" maxlength="255" size="45"></td>
	</tr>
	</table>
	</div>

	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	document.editform.replyTo.focus();
	objForm = new qForm("editform");
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