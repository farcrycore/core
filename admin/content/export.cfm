<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/content/export.cfm,v 1.5.2.1 2006/03/21 04:42:46 jason Exp $
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

<!--- check permissions --->
<cfset iExportTab = application.security.checkPermission(permission="ContentExportTab")>

<cfif bFormSubmit EQ "yes"> <!--- form submitted --->
	<cfset sendTo = trim(sendTo)>
	<cfif sendTo EQ "">	
		<cfset errormessage = errormessage & "Please enter a Send To email address.<br />">
	<cfelseif (NOT REFindNoCase('^[A-Za-z0-9_\.\-]+@([A-Za-z0-9_\.\-]+\.)+[A-Za-z]{2,4}$', sendTo))>
		<cfset subS = listToArray('#application.path.project#,#application.config.general.exportPath#')>
		<cfset errormessage = errormessage & "#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#">
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
					<cffile action="write" file="#filePath#" output="#toString(stExport)#" addnewline="no" nameconflict="OVERWRITE">
					<cfcatch>
					<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>			
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#</cfoutput>
					</cfcatch>
				</cftry>
			</cfcase>
		</cfswitch>

		<!--- send export file --->
		<cfmail from="#form.sendTo#" to="#form.sendTo#" subject="#form.contentType# export" mimeattach="#filePath#">
#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportAttached,"#form.contentType#")#		
		</cfmail>
		<!--- success message --->		
		<cfset successmessage = application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportFileSent,"#sendTo#")>
	</cfif>
</cfif>

<cfset listofKeys = structKeyList(application.types)>
<cfset listofKeys = listsort(listofkeys,"textnocase")>	
						
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfsetting enablecfoutputonly="no">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfif iExportTab eq 1><cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" name="editform" method="post">
	<fieldset>
<h3>#application.adminBundle[session.dmProfile.locale].xmlExport#</h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
<cfelseif successmessage NEQ "">
<p id="fading2" class="fade"><span class="success">#successmessage#</span></p>
</cfif>	
		<label for="contentType"><b>#application.adminBundle[session.dmProfile.locale].contentType#</b>
			<select name="contentType" id="contentType"><cfloop list="#listOfKeys#" index="i">
				<option value="#i#"<cfif contentType EQ i> selected="selected"</cfif>>#i#</option></cfloop>			
			</select><br />
		</label>
		
		<label for="sendTo"><b>#application.adminBundle[session.dmProfile.locale].sendTo#</b>
			<input type="text" name="sendTo" id="sendTo" value="#sendTo#" maxlength="255" size="45" /><br />
		</label>

		<label for="exportType"><b>#application.adminBundle[session.dmProfile.locale].exportAs#</b>
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
<cfelse>
<admin:permissionError>
</cfif>
<admin:footer>

<!--- <cfif iExportTab eq 1>

	<cfoutput><span class="Formtitle">#application.adminBundle[session.dmProfile.locale].xmlExport#</span><p></p></cfoutput>

	<cfset bShowForm=1>
	
	<!--- check valid email address --->
	<cfif isdefined("form.submit")>		
		<cfif (NOT REFindNoCase('^[A-Za-z0-9_\.\-]+@([A-Za-z0-9_\.\-]+\.)+[A-Za-z]{2,4}$', trim(form.sendTo)))>
			<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>
			<cfset message = "#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#">
			<cfset bShowForm=1>
		<cfelse>
			<cfset bShowForm = 0>		
		</cfif>
	</cfif>
	
	<!--- if no error than show form --->
	<cfif not bShowForm>
		<cfobject component="#evaluate("application.types.#form.contentType#.typePath")#" name="oContentType">
		
		<!--- get all objects --->
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
				<cfif not directoryExists("#application.path.project#/#application.config.general.exportPath#")>
					<cfdirectory action="CREATE" directory="#application.path.project#/#application.config.general.exportPath#">
				</cfif>	

				<cftry>
					<!--- generate file --->
					<cffile action="write" file="#filePath#" output="#toString(stExport)#" addnewline="no" nameconflict="OVERWRITE">
					<cfcatch>
					<cfset subS=listToArray('#application.path.project#,#application.config.general.exportPath#')>			
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportDirNotExists,subS)#</cfoutput>
					</cfcatch>
				</cftry>

			</cfcase>
		</cfswitch>

		<!--- send export file --->
		<cfmail from="#form.sendTo#" to="#form.sendTo#" subject="#form.contentType# export" mimeattach="#filePath#">
#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportAttached,"#form.contentType#")#		
		</cfmail>
		
		<!--- success message --->
		<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].exportFileSent,"#form.sendTo#")#</cfoutput>
		
	</cfif>
	
	<!--- show form --->
	<cfif bShowForm>
		<!--- check for error message --->
		<cfif isdefined("message")>
			<cfoutput><div class="error" style="margin-left:30px;">#message#</div><p></p></cfoutput>
		</cfif>
		
		<cfoutput>
		<!--- show form --->
		<form action="" method="post">
			<div class="FormTable">	
				<table class="BorderTable" width="400" align="center">
				<!--- contentType --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].contentType# </span></td>
					<td width="100%">
						<!--- sort structure by Key name --->
						<cfset listofKeys = structKeyList(application.types)>
						<cfset listofKeys = listsort(listofkeys,"textnocase")>	
						<select name="contentType">
							<!--- loop over types structure in memory -- populated on application init --->
							<cfloop list="#listOfKeys#" index="i">
								<option value="#i#">#i#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<!--- send xml file details --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].sendTo#</span></td>
					<td width="100%"><input type="text" name="sendTo" class="formtextbox" maxlength="255" size="45"></td>
				</tr>
				<!--- export type --->
				<tr>
					<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].exportAs#</span></td>
					<td width="100%">
						<select name="exportType">
							<option value="xml">XML
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				</table>
			</div>
			<input type="submit" name="submit" value="#application.adminBundle[session.dmProfile.locale].export#" class="normalbttnstyle" style="margin-left:30px;">
		</form>	
		</cfoutput>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer> --->

<cfsetting enablecfoutputonly="no">