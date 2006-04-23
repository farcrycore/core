<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFacts/plpEdit/start.cfm,v 1.16 2005/09/06 23:02:14 daniela Exp $
$Author: daniela $
$Date: 2005/09/06 23:02:14 $
$Name: milestone_3-0-0 $
$Revision: 1.16 $

|| DESCRIPTION || 
First step of dmFact plp. Adds title, link, body and uploads image if needed.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<!--- upload image --->
<cfif isDefined("form.plpAction")>
	<cfset form.image = image_file_original> <!--- default the image image to the original default --->
	<cfif image_file_upload NEQ ""> <!--- new file being uploaded --->
		<cftry>
			<cffile action="upload" filefield="image_file_upload" destination="#application.path.defaultImagePath#" accept="#application.config.image.imagetype#" nameconflict="#application.config.general.fileNameConflict#"> 
			<cfif image_file_original NEQ "" AND fileExists("#application.path.defaultImagePath#/#image_file_original#")> <!--- delete original file --->
				<cffile action="delete" file="#application.path.defaultImagePath#/#image_file_original#">
			</cfif>

			<cfset oForm = createObject("component","#application.packagepath#.farcry.form")>			
			<!--- update the image to the one that was just uploaded --->
			<cfset form.image = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
			
			<cfcatch>
				<cfset subS = listToArray(application.config.image.imagetype)>
				<cfset subS[2] = application.config.image.imagetype>
				<cfset errormessage = errormessage & application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].errBadImageType,subS)>
			</cfcatch>
		</cftry>
	</cfif>
	<cfset output.image = form.image>
</cfif>

<cfif errorMessage EQ "">
	<!--- no errors... --->
	<widgets:plpAction>
</cfif>

<!--- show form --->
<cfif NOT thisstep.isComplete>
<widgets:plpWrapper><cfoutput>
<cfif errormessage NEQ "">
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 f-bg-short" name="editform" method="post" enctype="multipart/form-data">	
	<fieldset>
	<div class="req"><b>*</b>Required</div>
	<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
		<input type="text" name="title" id="title" value="#output.title#" maxlength="255" /><br />
	</label>
	
	<label for="link"><b>#application.adminBundle[session.dmProfile.locale].linkLabel#</b>
		<input type="text" name="link" id="link" value="#output.link#" maxlength="255" /><br />
	</label>
</cfoutput>
	<widgets:fileUpload fileFieldPrefix="image" uploadType="image">
<cfoutput>
	<label for="body"><b>#application.adminBundle[session.dmProfile.locale].bodyLabel#</b>
		<textarea name="body" id="body">#output.body#</textarea><br />
	</label>
</cfoutput>		
	<widgets:displayMethodSelector typeName="#output.typeName#">
<cfoutput>
	</fieldset>

	<input type="hidden" name="plpAction" value="" />	
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>
<cfinclude template="/farcry/farcry_core/admin/includes/QFormValidationJS.cfm">
</cfoutput>
</widgets:plpWrapper>
<cfelse>
	<!--- update plp data and move to next step --->
	<widgets:plpUpdateOutput>
</cfif>
<cfsetting enablecfoutputonly="no">