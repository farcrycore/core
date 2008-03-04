<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmXMLExport/plpEdit/start.cfm,v 1.9.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.9.2.1 $

|| DESCRIPTION || 
First step of dmXMLExport plp. 

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<!--- <widgets:plpNavigationMove> --->

<!--- show form --->
<cfif NOT thisstep.isComplete>
<widgets:plpWrapper><cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post" enctype="multipart/form-data">
<fieldset>
<h3>#apapplication.rb.getResource("generalInfo")#: <span class="highlight">#output.label#</span></h3>

<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
	<label for="Title"><b>#apapplication.rb.getResource("titleLabel")#</b>
		<input type="text" name="Title" id="Title" value="#output.Title#" maxlength="255" size="45" /><br />
	</label>

	<label for="description"><b>#apapplication.rb.getResource("description")#</b>
		<textarea name="description">#output.description#</textarea><br />
	</label>

	<label for="language"><b>#apapplication.rb.getResource("languageLabel")#</b>
		<input type="text" name="language" id="language" value="#output.language#" maxlength="255" size="45" /><br />
	</label>

	<label for="creator"><b>#apapplication.rb.getResource("creatorLabel")#</b>
		<input type="text" name="creator" id="creator" value="#output.creator#" maxlength="255" size="45" /><br />
	</label>

	<label for="rights"><b>#apapplication.rb.getResource("rightsLabel")#</b>
		<input type="text" name="rights" id="rights" value="#output.rights#" maxlength="255" size="45" /><br />
	</label>

	<label for="generatorAgent"><b>#apapplication.rb.getResource("generatorAgentLabel")#</b>
		<input type="text" name="generatorAgent" id="generatorAgent" value="#output.generatorAgent#" maxlength="255" size="45" /><br />
	</label>

	<label for="errorReportsTo"><b>#apapplication.rb.getResource("errorReportsEmailLabel")#</b>
		<input type="text" name="errorReportsTo" id="errorReportsTo" value="#output.errorReportsTo#" maxlength="255" size="45" /><br />
	</label>

	<label for="updatePeriod"><b>#apapplication.rb.getResource("updatePeriodLabel")#</b>
		<select name="updatePeriod">
			<option value="hourly" <cfif output.updatePeriod eq "hourly">selected</cfif>>#apapplication.rb.getResource("Hourly")#
			<option value="daily" <cfif output.updatePeriod eq "daily">selected</cfif>>#apapplication.rb.getResource("Daily")#
			<option value="weekly" <cfif output.updatePeriod eq "weekly">selected</cfif>>#apapplication.rb.getResource("Weekly")#
			<option value="monthly" <cfif output.updatePeriod eq "monthly">selected</cfif>>#apapplication.rb.getResource("Monthly")#
			<option value="yearly" <cfif output.updatePeriod eq "yearly">selected</cfif>>#apapplication.rb.getResource("Yearly")#
		</select><br />
	</label>

	<label for="updateFrequency"><b>#apapplication.rb.getResource("updateFrequencyLabel")#</b>
		<input type="text" name="updateFrequency" size="5" id="updateFrequency" value="#output.updateFrequency#" maxlength="5" /><br />
	</label>

	<label for="updateBase"><b>#apapplication.rb.getResource("updateBaseDateLabel")#</b>
		<input type="text" name="updateBase" id="updateBase" value="#output.updateBase#" maxlength="255" size="45" /><br />
	</label>

	<label for="contentType"><b>#apapplication.rb.getResource("contentType")#</b>
		<select name="contentType"><cfloop collection="#application.types#" item="i"><!--- loop over types structure in memory -- populated on application init --->					
			<option value="#i#"<cfif output.contentType eq i>selected="selected"</cfif>>#i#</option></cfloop>			
		</select><br />
	</label>

	<label for="numberOfItems"><b>#apapplication.rb.getResource("maxItemsLabel")#</b>
		<input type="text" name="numberOfItems" size="5" id="numberOfItems" value="#output.numberOfItems#" maxlength="5" /><br />
	</label>
	
	<label for="xmlFile"><b>#apapplication.rb.getResource("exportFileLabel")#</b>
		<input type="text" name="xmlFile" id="numberOfItems" value="#output.xmlFile#" /><br />
	</label>
	<input type="hidden" name="plpAction" value="" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</fieldset>		
<!--- form validation --->
<script type="text/javascript">
<!--//
document.editform.Title.focus();
objForm = new qForm("editform");
objForm.Title.validateNotNull("#apapplication.rb.getResource("pleaseEnterTitle")#");
objForm.updateFrequency.validateNotNull("#apapplication.rb.getResource("pleaseEnterUpdateFrequency")#");
objForm.errorReportsTo.validateNotNull("#apapplication.rb.getResource("pleaseEnterErrorEmail")#");
//-->
</script>
</form></cfoutput>
</widgets:plpWrapper>
<cfelse>
	<!--- update plp data and move to next step --->
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">