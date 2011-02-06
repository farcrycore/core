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
$Header: /cvs/farcry/core/webtop/content/export.cfm,v 1.5.2.1 2006/03/21 04:42:46 jason Exp $
$Author: jason $
$Date: 2006/03/21 04:42:46 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION || 
$Description: Export Edit Handler $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
--->
<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="bFormSubmit" default="no">
<cfparam name="errormessage" default="">
<cfparam name="successmessage" default="">
<cfparam name="sendTo" default="">
<cfparam name="contentType" default="">
<cfparam name="exportType" default="xml">

<cfif bFormSubmit EQ "yes"> <!--- form submitted --->
	<cfset sendTo = trim(sendTo)>
	<cfif sendTo EQ "">	
		<cfset errormessage = errormessage & "Please enter a Send To email address.<br />">
	<cfelseif (NOT REFindNoCase('^[A-Za-z0-9_\.\-]+@([A-Za-z0-9_\.\-]+\.)+[A-Za-z]{2,4}$', sendTo))>
		<cfset subS = listToArray('#application.path.project#,#application.config.general.exportPath#')>
		<cfset errormessage = errormessage & "#application.rb.formatRBString('content.messages.exportDirNotExists@text',subS,'{1}/{2} directory doesn''t exist. Please create before trying to export.')#">
	</cfif>

	<cfif contentType EQ "">
		<cfset errormessage = errormessage & "Please Select a Content Type.<br />">
	</cfif>

	<cfif errormessage EQ ""> <!--- if no error than show form --->
		<cfset oContentType = CreateObject("component","#application.types[contentType].typePath#")>
		<cfset stObjects = oContentType.getMultiple(dsn=application.dsn,dbowner=application.dbowner)>

		<!--- work out which export type to generate --->
		<cfswitch expression="#form.exportType#">
			<cfcase value="xml">
				<!--- loop over and generate xml --->
				<cfsavecontent variable="stExport">
					<cfoutput><?xml version="1.0" encoding="utf-8"?>
					<objects></cfoutput>
					<cfloop collection="#stObjects#" item="obj">
						<cfoutput><item></cfoutput>
							<!--- loop through these types and look at each field --->
							<cfloop collection="#application.types[form.contentType].stProps#" item="Field">
								<cfif application.types[form.contentType].stProps[field].metadata.type neq "array"><cfoutput><#field#>#xmlFormat(stObjects[obj][field])#</#field#></cfoutput></cfif>
							</cfloop>
						<cfoutput></item></cfoutput>
					</cfloop>
					<cfoutput></objects></cfoutput>
				</cfsavecontent>
				
				<!--- set file path --->
				<cfset filePath ="#application.path.project#/#application.config.general.exportPath#/#form.contentType#.xml">
				
				<!--- check directory exists --->
				<cfif NOT directoryExists("#application.path.project#/#application.config.general.exportPath#")>
					<cfdirectory action="CREATE" directory="#application.path.project#/#application.config.general.exportPath#">
				</cfif>	

				<cftry>
					<!--- generate file --->
					<cffile action="write" file="#filePath#" output="#toString(stExport)#" addnewline="no" nameconflict="OVERWRITE" mode="664">
					<cfcatch>
					<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>			
					<cfoutput>#application.rb.formatRBString('content.messages.exportDirNotExists@text',subS,'{1}/{2} directory doesn''t exist. Please create before trying to export.')#</cfoutput>
					</cfcatch>
				</cftry>
			</cfcase>
		</cfswitch>

		<!--- send export file --->
		<cfmail from="#form.sendTo#" to="#form.sendTo#" subject="#form.contentType# export" mimeattach="#filePath#">
#application.rb.formatRBString("content.messages.exportAttached@text",form.contentType,"Export of {1} attached.")#		
		</cfmail>
		<!--- success message --->		
		<cfset successmessage = application.rb.formatRBString("content.messages.exportFileSent@text",sendTo,"Export file has been sent to {1}")>
	</cfif>
</cfif>

<cfset listofKeys = structKeyList(application.types)>
<cfset listofKeys = listsort(listofkeys,"textnocase")>	
						
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<cfsetting enablecfoutputonly="no">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ContentExportTab"><cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post">
		<fieldset>
	<h3>#application.rb.getResource("content.headings.xmlExport@text","XML Export")#</h3>
	<cfif errormessage NEQ "">
	<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	<cfelseif successmessage NEQ "">
	<p id="fading2" class="fade"><span class="success">#successmessage#</span></p>
	</cfif>	
			<label for="contentType"><b>#application.rb.getResource("content.labels.contenttype@text","Content Type")#:</b>
				<select name="contentType" id="contentType"><cfloop list="#listOfKeys#" index="i">
					<option value="#i#"<cfif contentType EQ i> selected="selected"</cfif>>#i#</option></cfloop>			
				</select><br />
			</label>
			
			<label for="sendTo"><b>#application.rb.getResource("content.labels.sendTo@label","Send To")#</b>
				<input type="text" name="sendTo" id="sendTo" value="#sendTo#" maxlength="255" size="45" /><br />
			</label>
	
			<label for="exportType"><b>#application.rb.getResource("content.labels.exportAs@label","Export As")#</b>
				<select name="exportType" id="exportType">
					<option value="xml"<cfif exportType EQ "xml"> selected="selected"</cfif>>xml</option>
				</select><br />
			</label>
		</fieldset>
		<input type="hidden" name="bFormSubmit" value="yes">
		<div class="f-submit-wrap">
		<input type="Submit" name="Submit" value="Export" class="f-submit" />
		</div>
	</form></cfoutput>
</sec:CheckPermission>

<cfsetting enablecfoutputonly="no">