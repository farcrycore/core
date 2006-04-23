<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/form.cfc,v 1.8 2003/10/20 06:14:03 brendan Exp $
$Author: brendan $
$Date: 2003/10/20 06:14:03 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION ||
$Description: form cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Form" hint="Manages common form functions">

	<cffunction name="uploadFile" hint="Uploads a file">
		<cfargument name="formField" hint="The name of the field that contains the file to be uploaded" required="true"   type="string">
		<cfargument name="destination" hint="Directory file is to be uploaded to - must pass in absolute path" type="string" default="#application.defaultImagePath#">
		<cfargument name="nameconflict" hint="File write behavior" type="string" default="#application.config.general.fileNameConflict#">
		<cfargument  name="accept" hint="File types to accept" type="string" default="">

		<cfset stReturn = structNew()>
		<cfset stReturn.bSuccess = false>

		<cfif len(arguments.formField)>

			<cftry>
				<!--- create the dir if it doesn't exist --->
				<cfif NOT directoryExists(arguments.destination)>
						<cfdirectory action="create" directory="#arguments.destination#">
				</cfif>

				<!--- upload file --->
				<cffile  action="UPLOAD" filefield="#arguments.formField#" destination="#arguments.destination#" nameconflict="#arguments.nameconflict#" accept="#arguments.accept#">

				<!--- check if filename has bad characters --->
				<cfif refindnocase("[\$\^\s\%\*''""<>,\&?]",file.serverfile) gt 0>
					<cfset validName = rereplace(file.serverfile,"[?\$\^\s\%\*''""<>,\&]","_","ALL")>
					<!--- don't overwrite an existing filename --->
					<cfset i = 1>
					<cfloop condition="#fileexists('#file.ServerDirectory#/#validName#')#">
					  <cfset validName = rereplace(file.clientfilename,"[?\$\^\s\%\*''""<>,\&]","_","ALL") & "#i#." & listlast(file.serverfile,".")>
					  <cfset i = i + 1>
					</cfloop>
					<!--- rename file --->
					<cffile action="rename" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#validName#">
				<cfelse>
					<!--- keep existing filename --->
					<cfset validName = file.serverfile>
				</cfif>

				<cfscript>
					stReturn.bSuccess = true;
					stReturn.message = "File upload Successful";
					stReturn.filename = validName;
					stReturn.fileDirectory = file.ServerDirectory;
					stReturn.fileSize = file.fileSize;
					stReturn.contentType =  file.ContentType;
					stReturn.clientFileName = file.clientFileName;
					stReturn.contentSubType = file.contentSubType;
					stReturn.serverFile = validName;
					stReturn.serverDirectory = file.ServerDirectory;
				</cfscript>

				<cfcatch>
					<cfset stReturn.message = cfcatch.message>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset stReturn.message = "No file uploaded.">
		</cfif>
		<cfreturn stReturn>
	</cffunction>

	<cffunction name="renderDynamicCheckBox" hint="Renders check boxes that are populated by a query">
		<cfargument name="name" required="true" hint="The name of the form element">
		<cfargument name="qData" required="No">
		<cfargument name="numrows" default="4" hint="This is the number of checkboxes per row to display">
		<cfargument name="lSelectedValues" required="No" default="" hint="The values which are selected by default">
		<cfargument name="valueColumn" required="No" default="objectID" hint="This is the query column to evaluate for option values - should generally be objectID though">
		<cfargument name="displayColumn" required="No" default="title" hint="This is the query column to evaluate for option displau values">

		<cfsavecontent variable="html">
			<cfoutput>
			<table>
				<cfloop query="arguments.qData">
					<cfif arguments.qdata.currentrow MOD arguments.numrows EQ 1>
						<tr>
					</cfif>
					<cfset value = evaluate("arguments.qdata." & arguments.valueColumn)>
					<cfset display = evaluate("arguments.qdata." & arguments.displayColumn)>
					<td>
						<input <cfif listFindNoCase(arguments.lSelectedValues,value)>checked</cfif> type="Checkbox" name="#arguments.name#" value="#value#">#display#
					</td>
					<cfif arguments.qdata.currentrow MOD arguments.numrows EQ 0 OR arguments.qdata.currentrow EQ arguments.qdata.recordcount>
						</tr>
					</cfif>
				</cfloop>
			</table>
			</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>


	<cffunction name="renderFileField" hint="Returns a file upload field - with a link to the file if it has been uploaded" >
		<cfargument name="fieldname" required="Yes">
		<cfargument name="filepath" required="Yes" hint="This assumes folder path relative to the application.defaultfilepath dir">
		<cfargument name="filename" required="No" default="">

		<cfsavecontent variable="html">
		<cfoutput>
			<table cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<input type="File" name="#arguments.fieldname#">
						<cfif fileExists("#application.defaultfilepath#/#arguments.filepath#/#arguments.filename#")>
							<a href="/files/#arguments.filepath#/#arguments.filename#" target="_blank" >View Current File</a>
						<cfelse>
							No File currently Uploaded
						</cfif>
					</td>
				</tr>
			</table>
		</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

	<cffunction name="renderDateSelect" hint="returns populated day-month-year selectboxes." >
		<cfargument name="startYear" default="#year(now())#" required="No" hint="Year range - minimum">
		<cfargument name="endYear" default="#year(now())#" required="No" hint="Year range - maximum">
		<cfargument name="selectedYear" default="#year(now())#" required="No" hint="Current selected year">
		<cfargument name="selectedMonth" default="#month(now())#" required="No" hint="Current selected month">
		<cfargument name="selectedday" default="#day(now())#" required="No" hint="Current selected day">
		<cfargument name="elementNamePrefix" required="No" default="" hint="form element names are named day,month,and year - this argument will prefix those names">

		<cfsavecontent variable="html">
			<cfoutput>
				<table style="display:inline">
					<tr>
						<td>
							<select name="#arguments.elementNamePrefix#day">
								<cfloop from="1" to="31" index="i">
									<option value="#i#" <cfif i IS arguments.selectedDay>selected</cfif>>#i#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="#arguments.elementNamePrefix#month">
								<cfloop from="1" to="12" index="i">
									<option value="#i#" <cfif i IS arguments.selectedMonth>selected</cfif>>#monthAsString(i)#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="#arguments.elementNamePrefix#year">
								<cfloop from="#arguments.startYear#" to="#arguments.endYear#" index="i">
									<option value="#i#" <cfif i IS arguments.selectedYear>selected</cfif>>#i#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

	<cffunction name="renderSelectBox" hint="Renders a select box that is populated by a query">
		<cfargument name="name" required="true" hint="The name of the form element">
		<cfargument name="qData" required="true">
		<cfargument name="lSelectedValues" required="No" default="" hint="The values which are selected by default">
		<cfargument name="valueColumn" required="No" default="objectID" hint="This is the query column to evaluate for option values - should generally be objectID though">
		<cfargument name="displayColumn" required="No" default="title" hint="This is the query column to evaluate for option displau values">
		<cfargument name="defaultMsg" required="No" default="Please Make Selection" hint="This is the default mesage in the select box when no records are selected">
		<cfargument name="onChangeJS" required="false" default="">

		<cfsavecontent variable="html">
			<cfoutput>
				<select name="#arguments.name#" <cfif len(onChangeJS)>onChange="#arguments.onChangeJS#"</cfif>>
					<option value="">#arguments.defaultMsg#</option>
					<cfloop query="arguments.qData">
						<cfset value = evaluate("arguments.qdata." & arguments.valueColumn)>
						<cfset display = evaluate("arguments.qdata." & arguments.displayColumn)>
						<option <cfif listContainsNoCase(arguments.lSelectedValues,value)>selected</cfif> value="#value#">#display#</option>
					</cfloop>
				</select>
			</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

	<cffunction name="renderTextBox" access="public" returntype="string" hint="Renders a form text element">
		<cfargument name="name" required="true" hint="The name of the form element">
		<cfargument name="value" required="false" hint="The value to display in this text field" default="">
		<cfargument name="length" type="numeric"  required="false" default="250">
		<cfargument name="size" type="numeric"  required="false" default="70">
		<cfsavecontent variable="html">
			<cfoutput>
				<input type="text" name="#arguments.name#" size="#arguments.size#" length="#arguments.length#" value="#arguments.value#">
			</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

	<cffunction name="renderTextArea" access="public" returntype="string" hint="Renders a form text element">
		<cfargument name="name" required="true" hint="The name of the form element">
		<cfargument name="value" required="false" hint="The value to display in this text field" default="">
		<cfargument name="length" type="numeric"  required="false" default="50">
		<cfsavecontent variable="html">
			<cfoutput>
				<textarea name="#arguments.name#" rows="6" cols="40">#arguments.value#</textarea>
			</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

	<cffunction name="renderHiddenIframe" hint="Returns the html code to place a hidden iframe on a page">
		<cfargument name="iframeID" default="idServer" required="No">
		<cfargument name="bHideFrame" default="false" required="True">
		<cfsavecontent variable="html">
			<cfoutput>
			<STYLE TYPE="text/css">
			###arguments.iframeID# {
				position:relative;
				width: 400px;
				height: 400px;
				<cfif arguments.bHideFrame>display:none;</cfif>
			}
			</STYLE>

			<IFRAME WIDTH="100" HEIGHT="1" NAME="#arguments.iframeID#" ID="#arguments.iframeID#"
				 FRAMEBORDER="0" FRAMESPACING="0" MARGINWIDTH="0" MARGINHEIGHT="0">
					<ILAYER NAME="#arguments.iframeID#" WIDTH="400" HEIGHT="100" VISIBILITY="Hide"
					 ID="#arguments.iframeID#">
					<P>This page uses a hidden frame and requires either Microsoft
					Internet Explorer v4.0 (or higher) or Netscape Navigator v4.0 (or
					higher.)</P>
					</ILAYER>
			</IFRAME>
		</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>

</cfcomponent>