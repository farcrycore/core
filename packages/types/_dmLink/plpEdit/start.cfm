<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/plpEdit/start.cfm,v 1.2 2003/07/10 02:07:06 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:07:06 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
First step of dmFact plp. Adds title, link, body and uploads image if needed.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>		

<!--- show form --->
<cfif NOT thisstep.isComplete>
	
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post" enctype="multipart/form-data">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table class="BorderTable" width="400" align="center">
	<!--- title --->
	<tr>
		<td nowrap class="FormLabel">Title: </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- url link --->
	<tr>
		<td nowrap class="FormLabel">Link: </span></td>
		<td width="100%"><input type="text" name="link" value="#output.link#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- teaser --->
	<tr>
		<td colspan="2"><span class="FormLabel">Teaser</span><br>
			<textarea name="teaser" class="formtextbox" rows="10">#output.teaser#</textarea>
		</td>
	</tr>
	<!--- </cfoutput>
	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmLinks" r_qMethods="qMethods">
	<cfoutput>
	<!--- display method --->
	<tr>
		<td nowrap><span class="FormLabel">Display Method:</span></td>
		<td width="100%"><span class="FormLabel">
		<select name="DisplayMethod" size="1" class="formfield">
		</cfoutput>
		<cfloop query="qMethods">
			<cfoutput><option value="#qMethods.methodname#" <cfif qMethods.methodname eq output.displayMethod>SELECTED</cfif>>#qMethods.displayname#</option></cfoutput>
		</cfloop>
		<cfoutput>
		</select>
		</span></td> 
	</tr>--->
	</table>
	</div>
	<!--- show plp buttons --->
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	document.editform.Title.focus();
	objForm = new qForm("editform");
	objForm.Title.validateNotNull("Please enter a title");
		//-->
	</SCRIPT>
	</form></cfoutput>
	
<cfelse>
	<!--- update plp data and move to next step --->
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">