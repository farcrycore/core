<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFacts/plpEdit/start.cfm,v 1.5 2003/09/18 07:47:56 paul Exp $
$Author: paul $
$Date: 2003/09/18 07:47:56 $
$Name: b201 $
$Revision: 1.5 $

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

<!--- upload image --->
<cfif isDefined("FORM.submit") or isdefined("form.save") or (isdefined("form.quicknav") and form.quicknav neq "")>
	<cfif trim(len(form.image)) NEQ 0 AND form.image NEQ form.imageFile_old>
		
		<!--- upload new file --->
		<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="image" destination="#application.defaultImagePath#" accept="#application.config.image.imagetype#"> 
		
		<cfif stReturn.bsuccess>
			<!--- delete old file --->
			<cftry>
				<cffile action="delete" file="#application.defaultImagePath#/#form.imageFile_old#">
				<cfcatch type="any"></cfcatch>
			</cftry>
			
			<cfset form.image = stReturn.ServerFile>

		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #application.config.image.imagetype# <p></p></cfoutput><cfabort>
		</cfif>
	<cfelse>
		<cfset form.image = form.imageFile_old>
	</cfif>
</cfif>

<tags:plpNavigationMove>		

<!--- show form --->
<cfif NOT thisstep.isComplete>
	
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post" enctype="multipart/form-data">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">General Info</div>
	<div class="FormTable">
	<table class="BorderTable" width="450" align="center">
	<!--- fact title --->
	<tr>
		<td nowrap class="FormLabel">Title: </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- optional url link --->
	<tr>
		<td nowrap class="FormLabel">Link: </span></td>
		<td width="100%"><input type="text" name="link" value="#output.link#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- optional image --->
	<tr>
		<td nowrap class="FormLabel">Image: </span></td>
		<td width="100%">
			<input type="file" name="image">
			<input type="hidden" name="imageFile_old" value="#output.image#">
			<!--- if image exists enable preview --->
			<cfif NOT len(trim(output.image)) EQ 0>
				<br><span class="FormLabel">[ file exists ] <a href="#application.url.webroot#/images/#output.image#" target="_blank">Preview</a></span>
			</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="top">&nbsp;</td>
	</tr>
	<!--- fact body --->
	<tr>
		<td nowrap class="FormLabel">Body: </span></td>
		<td>
			<textarea name="body" class="formtextbox" rows="10">#output.body#</textarea>
		</td>
	</tr>
	</cfoutput>
	<!--- get the templates for this type --->
	<nj:listTemplates typename="dmFacts" r_qMethods="qMethods">
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
	</tr>
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