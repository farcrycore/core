<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit/start.cfm,v 1.4 2004/07/16 05:47:17 brendan Exp $
$Author: brendan $
$Date: 2004/07/16 05:47:17 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
First step of dmXMLExport plp. 

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>		

<!--- show form --->
<cfif NOT thisstep.isComplete>
	
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post" enctype="multipart/form-data">
	
	<div class="FormSubTitle">#output.label#</div>
	<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].generalInfo#</div>
	
	<div class="FormTable">	
		<table class="BorderTable" width="400" align="center">
		<!--- title --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
			<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- description --->
		<tr>
			<td nowrap class="FormLabel" valign="top">#application.adminBundle[session.dmProfile.locale].descLabel#</span></td>
			<td width="100%"><textarea name="description">#output.description#</textarea></td>
		</tr>
		<!--- language --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].languageLabel#</span></td>
			<td width="100%"><input type="text" name="language" value="#output.language#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- creator --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].creatorLabel# </span></td>
			<td width="100%"><input type="text" name="creator" value="#output.creator#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- rights --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].rightsLabel# </span></td>
			<td width="100%"><input type="text" name="rights" value="#output.rights#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- generatorAgent --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].generatorAgentLabel# </span></td>
			<td width="100%"><input type="text" name="generatorAgent" value="#output.generatorAgent#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- errorReportsTo --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].errorReportsEmailLabel# </span></td>
			<td width="100%"><input type="text" name="errorReportsTo" value="#output.errorReportsTo#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- updatePeriod --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].updatePeriodLabel# </span></td>
			<td width="100%">
				<select name="updatePeriod">
					<option value="hourly" <cfif output.updatePeriod eq "hourly">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Hourly#
					<option value="daily" <cfif output.updatePeriod eq "daily">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Daily#
					<option value="weekly" <cfif output.updatePeriod eq "weekly">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Weekly#
					<option value="monthly" <cfif output.updatePeriod eq "monthly">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Monthly#
					<option value="yearly" <cfif output.updatePeriod eq "yearly">selected</cfif>>#application.adminBundle[session.dmProfile.locale].Yearly#
				</select>
			</td>
		</tr>
		<!--- updateFrequency --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].updateFrequencyLabel# </span></td>
			<td width="100%"><input type="text" name="updateFrequency" value="#output.updateFrequency#" maxlength="5" size="5"></td>
		</tr>
		<!--- updateBase --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].updateBaseDateLabel# </span></td>
			<td width="100%"><input type="text" name="updateBase" value="#output.updateBase#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- contentType --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].contentType# </span></td>
			<td width="100%">
				<select name="contentType">
					<!--- loop over types structure in memory -- populated on application init --->
					<cfloop collection="#application.types#" item="i">
						<option value="#i#" <cfif output.contentType eq i>selected</cfif>>#i#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<!--- numberOfItems --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].maxItemsLabel# </span></td>
			<td width="100%"><input type="text" name="numberOfItems" value="#output.numberOfItems#" maxlength="5" size="5"></td>
		</tr>
		<!--- xml File details --->
		<tr>
			<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].exportFileLabel# </span></td>
			<td width="100%"><input type="text" name="xmlFile" value="#output.xmlFile#" class="formtextbox" maxlength="255"></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
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
		objForm.updateFrequency.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterUpdateFrequency#");
		objForm.errorReportsTo.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterErrorEmail#");
		//-->
	</SCRIPT>
	
	</form>
	</cfoutput>
	
<cfelse>
	<!--- update plp data and move to next step --->
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">