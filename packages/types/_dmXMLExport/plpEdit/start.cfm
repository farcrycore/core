<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/plpEdit/start.cfm,v 1.3 2003/09/22 07:04:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 07:04:33 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
First step of dmXMLExport plp. 

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
			<td nowrap class="FormLabel">Title:</span></td>
			<td width="100%"><input type="text" name="Title" value="#output.Title#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- description --->
		<tr>
			<td nowrap class="FormLabel" valign="top">Description:</span></td>
			<td width="100%"><textarea name="description">#output.description#</textarea></td>
		</tr>
		<!--- language --->
		<tr>
			<td nowrap class="FormLabel">Language:</span></td>
			<td width="100%"><input type="text" name="language" value="#output.language#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- creator --->
		<tr>
			<td nowrap class="FormLabel">Creator: </span></td>
			<td width="100%"><input type="text" name="creator" value="#output.creator#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- rights --->
		<tr>
			<td nowrap class="FormLabel">Rights: </span></td>
			<td width="100%"><input type="text" name="rights" value="#output.rights#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- generatorAgent --->
		<tr>
			<td nowrap class="FormLabel">Generator Agent: </span></td>
			<td width="100%"><input type="text" name="generatorAgent" value="#output.generatorAgent#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- errorReportsTo --->
		<tr>
			<td nowrap class="FormLabel">Error Reports Email: </span></td>
			<td width="100%"><input type="text" name="errorReportsTo" value="#output.errorReportsTo#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- updatePeriod --->
		<tr>
			<td nowrap class="FormLabel">Update Period: </span></td>
			<td width="100%">
				<select name="updatePeriod">
					<option value="hourly" <cfif output.updatePeriod eq "hourly">selected</cfif>>Hourly
					<option value="daily" <cfif output.updatePeriod eq "daily">selected</cfif>>Daily
					<option value="weekly" <cfif output.updatePeriod eq "weekly">selected</cfif>>Weekly
					<option value="monthly" <cfif output.updatePeriod eq "monthly">selected</cfif>>Monthly
					<option value="yearly" <cfif output.updatePeriod eq "yearly">selected</cfif>>Yearly
				</select>
			</td>
		</tr>
		<!--- updateFrequency --->
		<tr>
			<td nowrap class="FormLabel">Update Frequency: </span></td>
			<td width="100%"><input type="text" name="updateFrequency" value="#output.updateFrequency#" maxlength="5" size="5"></td>
		</tr>
		<!--- updateBase --->
		<tr>
			<td nowrap class="FormLabel">Update Base Date: </span></td>
			<td width="100%"><input type="text" name="updateBase" value="#output.updateBase#" class="formtextbox" maxlength="255"></td>
		</tr>
		<!--- contentType --->
		<tr>
			<td nowrap class="FormLabel">Content Type: </span></td>
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
			<td nowrap class="FormLabel">Max Number of Items: </span></td>
			<td width="100%"><input type="text" name="numberOfItems" value="#output.numberOfItems#" maxlength="5" size="5"></td>
		</tr>
		<!--- xml File details --->
		<tr>
			<td nowrap class="FormLabel">Export File: </span></td>
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
		objForm.Title.validateNotNull("Please enter a title");
		objForm.updateFrequency.validateNotNull("Please enter an update frequency");
		objForm.errorReportsTo.validateNotNull("Please enter an error reports email address");
		//-->
	</SCRIPT>
	
	</form>
	</cfoutput>
	
<cfelse>
	<!--- update plp data and move to next step --->
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">