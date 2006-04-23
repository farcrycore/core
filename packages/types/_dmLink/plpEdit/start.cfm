<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmLink/plpEdit/start.cfm,v 1.15.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.15.2.1 $

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

<widgets:plpAction>

<!--- show form --->
<cfif NOT thisstep.isComplete>
<widgets:plpWrapper>
<cfoutput>
	<!--- <cfif errormessage NEQ "">
		<span class="error">#errormessage#</span>
	</cfif> --->
	<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post">
		<fieldset>
			<div class="req"><b>*</b>Required</div>
			<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
				<input type="text" name="title" id="title" value="#output.title#" maxlength="255" size="45" /><br />
			</label>
		
			<label for="link"><b>#application.adminBundle[session.dmProfile.locale].linkLabel#</b>
				<input type="text" name="link" id="link" value="#output.link#" maxlength="255" size="45" /><br />
			</label>
			</cfoutput>
			<widgets:displayMethodSelector typeName="#output.typeName#" prefix="displaypage">
			<cfoutput>
			<br />
			<label for="teaser"><b>#application.adminBundle[session.dmProfile.locale].teaser#</b>
				<textarea name="teaser" id="teaser">#output.teaser#</textarea><br />
			</label>
		</fieldset>

</cfoutput>
		<widgets:ownedBySelector fieldLabel="Content Owner:" selectedValue="#output.ownedBy#">
<cfoutput>
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