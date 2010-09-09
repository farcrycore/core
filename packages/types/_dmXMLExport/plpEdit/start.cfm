<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
<h3>#application.rb.getResource("generalInfo")#: <span class="highlight">#output.label#</span></h3>

<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
	<label for="Title"><b>#application.rb.getResource("titleLabel")#</b>
		<input type="text" name="Title" id="Title" value="#output.Title#" maxlength="255" size="45" /><br />
	</label>

	<label for="description"><b>#application.rb.getResource("description")#</b>
		<textarea name="description">#output.description#</textarea><br />
	</label>

	<label for="language"><b>#application.rb.getResource("languageLabel")#</b>
		<input type="text" name="language" id="language" value="#output.language#" maxlength="255" size="45" /><br />
	</label>

	<label for="creator"><b>#application.rb.getResource("creatorLabel")#</b>
		<input type="text" name="creator" id="creator" value="#output.creator#" maxlength="255" size="45" /><br />
	</label>

	<label for="rights"><b>#application.rb.getResource("rightsLabel")#</b>
		<input type="text" name="rights" id="rights" value="#output.rights#" maxlength="255" size="45" /><br />
	</label>

	<label for="generatorAgent"><b>#application.rb.getResource("generatorAgentLabel")#</b>
		<input type="text" name="generatorAgent" id="generatorAgent" value="#output.generatorAgent#" maxlength="255" size="45" /><br />
	</label>

	<label for="errorReportsTo"><b>#application.rb.getResource("errorReportsEmailLabel")#</b>
		<input type="text" name="errorReportsTo" id="errorReportsTo" value="#output.errorReportsTo#" maxlength="255" size="45" /><br />
	</label>

	<label for="updatePeriod"><b>#application.rb.getResource("updatePeriodLabel")#</b>
		<select name="updatePeriod">
			<option value="hourly"<cfif output.updatePeriod eq "hourly"> selected="selected"</cfif>>#application.rb.getResource("Hourly")#</option>
			<option value="daily"<cfif output.updatePeriod eq "daily"> selected="selected"</cfif>>#application.rb.getResource("Daily")#</option>
			<option value="weekly"<cfif output.updatePeriod eq "weekly"> selected="selected"</cfif>>#application.rb.getResource("Weekly")#</option>
			<option value="monthly"<cfif output.updatePeriod eq "monthly"> selected="selected"</cfif>>#application.rb.getResource("Monthly")#</option>
			<option value="yearly"<cfif output.updatePeriod eq "yearly"> selected="selected"</cfif>>#application.rb.getResource("Yearly")#</option>
		</select><br />
	</label>

	<label for="updateFrequency"><b>#application.rb.getResource("updateFrequencyLabel")#</b>
		<input type="text" name="updateFrequency" size="5" id="updateFrequency" value="#output.updateFrequency#" maxlength="5" /><br />
	</label>

	<label for="updateBase"><b>#application.rb.getResource("updateBaseDateLabel")#</b>
		<input type="text" name="updateBase" id="updateBase" value="#output.updateBase#" maxlength="255" size="45" /><br />
	</label>

	<label for="contentType"><b>#application.rb.getResource("contentType")#</b>
		<select name="contentType"><cfloop collection="#application.types#" item="i"><!--- loop over types structure in memory -- populated on application init --->					
			<option value="#i#"<cfif output.contentType eq i> selected="selected"</cfif>>#i#</option></cfloop>			
		</select><br />
	</label>

	<label for="numberOfItems"><b>#application.rb.getResource("maxItemsLabel")#</b>
		<input type="text" name="numberOfItems" size="5" id="numberOfItems" value="#output.numberOfItems#" maxlength="5" /><br />
	</label>
	
	<label for="xmlFile"><b>#application.rb.getResource("exportFileLabel")#</b>
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
objForm.Title.validateNotNull("#application.rb.getResource("pleaseEnterTitle")#");
objForm.updateFrequency.validateNotNull("#application.rb.getResource("pleaseEnterUpdateFrequency")#");
objForm.errorReportsTo.validateNotNull("#application.rb.getResource("pleaseEnterErrorEmail")#");
//-->
</script>
</form></cfoutput>
</widgets:plpWrapper>
<cfelse>
	<!--- update plp data and move to next step --->
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">