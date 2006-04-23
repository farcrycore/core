<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFacts/plpEdit/start.cfm,v 1.8 2004/12/06 19:12:48 tom Exp $
$Author: tom $
$Date: 2004/12/06 19:12:48 $
$Name: milestone_2-3-2 $
$Revision: 1.8 $

|| DESCRIPTION || 
First step of dmFact plp. Adds title, link, body and uploads image if needed.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<!--- upload image --->
<cfif isDefined("FORM.submit") or isdefined("form.save") or (isdefined("form.quicknav") and form.quicknav neq "")>
	<cfif trim(len(form.image)) NEQ 0 AND form.image NEQ form.imageFile_old>
		<!--- upload new file --->
		<cfscript>
			oForm = createObject("component","#application.packagepath#.farcry.form");
		</cfscript>
		<cftry>
			<cffile action="upload" filefield="image" destination="#application.path.defaultImagePath#" accept="#application.config.image.imagetype#" nameconflict="#application.config.general.fileNameConflict#"> 
			<cfif fileExists("#application.path.defaultImagePath#/#form.imageFile_old#")>
				<cffile action="delete" file="#application.path.defaultImagePath#/#form.imageFile_old#">
			</cfif>			
			<cfset form.image = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>

			<cfcatch>
				<cfset subS=listToArray('#stReturn.message#,#application.config.image.imagetype#')>
				<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errBadImageType,subS)#</p></cfoutput><cfabort>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfset form.image = form.imageFile_old>
	</cfif>
</cfif>

<tags:plpNavigationMove>		

<!--- show form --->
<cfif NOT thisstep.isComplete>
	
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post" enctype="multipart/form-data">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	<div class="FormTable">
	<table class="BorderTable" width="450" align="center">
	<!--- fact title --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel# </span></td>
		<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- optional url link --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].linkLabel# </span></td>
		<td width="100%"><input type="text" name="link" value="#output.link#" class="formtextbox" maxlength="255"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<!--- optional image --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].imageLabel#</span></td>
		<td width="100%">
			<input type="file" name="image">
			<input type="hidden" name="imageFile_old" value="#output.image#">
			<!--- if image exists enable preview --->
			<cfif NOT len(trim(output.image)) EQ 0>
				<br><span class="FormLabel">[ #application.adminBundle[session.dmProfile.locale].fileExists# ] <a href="#application.url.webroot#/images/#output.image#" target="_blank">#application.adminBundle[session.dmProfile.locale].preview#</a></span>
			</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="top">&nbsp;</td>
	</tr>
	<!--- fact body --->
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].bodyLabel# </span></td>
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
		<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].displayMethodLabel#</span></td>
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
	objForm.Title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
		//-->
	</SCRIPT>
	</form></cfoutput>
	
<cfelse>
	<!--- update plp data and move to next step --->
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">