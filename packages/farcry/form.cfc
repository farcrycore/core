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
$Header: /cvs/farcry/core/packages/farcry/form.cfc,v 1.20 2005/09/16 14:09:59 paul Exp $
$Author: paul $
$Date: 2005/09/16 14:09:59 $
$Name: milestone_3-0-1 $
$Revision: 1.20 $

|| DESCRIPTION ||
$Description: form cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Form" hint="Manages common form functions">

	<cffunction name="sanitiseFileName">
		<cfargument name="serverfile" required="yes">
		<cfargument name="clientfilename" required="yes"> 
		<cfargument name="serverDirectory" required="yes">
		<cfset var bResult = true>
		<cfset var validName = arguments.serverfile>
		<cfset var i = 1>
		
		<cfif refindnocase("[\$\^\s\%\*''""<>,\&?]",arguments.serverfile) gt 0>
			<cfset validName = rereplace(arguments.serverfile,"[?\$\^\s\%\*''""<>,\&]","_","ALL")>
				<!--- don't overwrite an existing filename --->
			<cfset i = 1>
			<cfloop condition="#fileexists('#cffile.ServerDirectory#/#validName#')#">
			  <cfset validName = rereplace(arguments.clientfilename,"[?\$\^\s\%\*''""<>,\&]","_","ALL") & "#i#." & listlast(arguments.serverfile,".")>
			  <cfset i = i + 1>
			</cfloop>
			<!--- rename file --->
			<cffile action="rename" source="#arguments.ServerDirectory#/#arguments.serverfile#" destination="#arguments.ServerDirectory#/#validName#">
		</cfif>
		<cfreturn validName>
	</cffunction>

	<cffunction name="uploadFile" hint="Uploads a file">
		<cfargument name="formField" hint="The name of the field that contains the file to be uploaded" required="true"   type="string">
		<cfargument name="destination" hint="Directory file is to be uploaded to - must pass in absolute path" type="string" default="#application.path.defaultImagePath#">
		<cfargument name="nameconflict" hint="File write behavior" type="string" default="#application.config.general.fileNameConflict#">
		<cfargument  name="accept" hint="File types to accept" type="string" default="">

		<cfset var stReturn = structNew()>
		<cfset var validName = ''>
		<cfset var i = 1>
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
				<cfif refindnocase("[\$\^\s\%\*''""<>,\&?]",cffile.serverfile) gt 0>
					<cfset validName = rereplace(cffile.serverfile,"[?\$\^\s\%\*''""<>,\&]","_","ALL")>
					<!--- don't overwrite an existing filename --->
					<cfset i = 1>
					<cfloop condition="#fileexists('#cffile.ServerDirectory#/#validName#')#">
					  <cfset validName = rereplace(cffile.clientfilename,"[?\$\^\s\%\*''""<>,\&]","_","ALL") & "#i#." & listlast(cffile.serverfile,".")>
					  <cfset i = i + 1>
					</cfloop>
					<!--- rename file --->
					<cffile action="rename" source="#cffile.ServerDirectory#/#cffile.serverfile#" destination="#cffile.ServerDirectory#/#validName#">
				<cfelse>
					<!--- keep existing filename --->
					<cfset validName = cffile.serverfile>
				</cfif>

				<cfscript>
					stReturn.bSuccess = true;
					stReturn.message = "File upload Successful";
					stReturn.filename = validName;
					stReturn.fileDirectory = cffile.ServerDirectory;
					stReturn.fileSize = cffile.fileSize;
					stReturn.contentType =  cffile.ContentType;
					stReturn.clientFileName = cffile.clientFileName;
					stReturn.contentSubType = cffile.contentSubType;
					stReturn.serverFile = validName;
					stReturn.serverDirectory = cffile.ServerDirectory;
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
		<cfset var html = ''>
		
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
		<cfargument name="filepath" required="Yes" default="" hint="This assumes folder path relative to the application.defaultfilepath dir">
		<cfargument name="filename" required="No" default="">
		<cfset var html = ''>
		<cfset var path = "#application.defaultfilepath#/">
		
		<cfscript>
			if(len(arguments.filepath))
				path = path & "#arguments.filepath#/";
			path = path & arguments.filename;	
		</cfscript>
		<cfsavecontent variable="html">
		<cfoutput>
			<table cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<input type="File" name="#arguments.fieldname#">
						<cfif fileExists("#path#")>
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
		<cfargument name="bDisplayMonthAsString" required="no" default="1" hint="Displays month as string as opposed to numerical equivalent">
		<cfargument name="bDisplayTime" required="no" default="0" hint="Display hours and minutes as well as dd mm yyyy">
		<cfargument name="selectedhour" default="#hour(now())#" required="No" hint="Current selected hour">
		<cfargument name="selectedminute" default="#minute(now())#" required="No" hint="Current selected minute">
		<cfargument name="selectedDate" required="No" hint="If this is provided, will override any other selections passed in">
		<cfset var i = 1>
		<cfset var html = ''>
		
		<cfif isDefined("arguments.selectedDate")>
			<cfscript>
				if(isDate(arguments.selectedDate))
					arguments.selectedDay = day(arguments.selectedDate);
					arguments.selectedYear = year(arguments.selectedDate);
					arguments.selectedMonth = month(arguments.selectedDate);
					arguments.selectedHour = hour(arguments.selectedDate);
					arguments.selectedMinute = minute(arguments.selectedDate);
			</cfscript>
		</cfif>
		

		<cfsavecontent variable="html">
			<cfoutput>
						
							<select id="#arguments.elementNamePrefix#day" name="#arguments.elementNamePrefix#day">
								<cfloop from="1" to="31" index="i">
									<option value="#i#"<cfif i IS arguments.selectedDay> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>

							<select id="#arguments.elementNamePrefix#month" name="#arguments.elementNamePrefix#month">
								<cfloop from="1" to="12" index="i">
									<option value="#i#"<cfif i IS arguments.selectedMonth> selected="selected"</cfif>><cfif NOT arguments.bDisplayMonthAsString>#i#<cfelse>#monthAsString(i)#</cfif></option>
								</cfloop>
							</select>

							<select id="#arguments.elementNamePrefix#year" name="#arguments.elementNamePrefix#year">
								<cfloop from="#arguments.startYear#" to="#arguments.endYear#" index="i">
									<option value="#i#"<cfif i IS arguments.selectedYear> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>
						
						<cfif arguments.bDisplayTime>
						
							<select id="#arguments.elementNamePrefix#hour" name="#arguments.elementNamePrefix#hour">
								<cfloop from="0" to="23" index="i">
									<option value="#i#"<cfif i IS arguments.selectedHour> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>

							<select id="#arguments.elementNamePrefix#minute" name="#arguments.elementNamePrefix#minute">
								<cfloop from="0" to="59" index="i">
									<option value="#i#"<cfif i IS arguments.selectedMinute> selected="selected"</cfif>>#i#</option>
								</cfloop>
							</select>
						
						</cfif>
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
		<cfset var html = ''>

		<cfsavecontent variable="html">
			<cfoutput>
				<select name="#arguments.name#" <cfif len(onChangeJS)>onChange="#arguments.onChangeJS#"</cfif>>
					<option value="">#arguments.defaultMsg#</option>
					<cfloop query="arguments.qData">
						<cfset value = evaluate("arguments.qdata." & arguments.valueColumn)>
						<cfset display = evaluate("arguments.qdata." & arguments.displayColumn)>
						<option<cfif listContainsNoCase(arguments.lSelectedValues,value)> selected="selected"</cfif> value="#value#">#display#</option>
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
		<cfset var html = ''>
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
			<style type="text/css">
			###arguments.iframeID# {
				position:relative;
				width: 400px;
				height: 400px;
				<cfif arguments.bHideFrame>display:none;</cfif>
			}
			</style>

			<iframe width="100" height="1" name="#arguments.iframeID#" id="#arguments.iframeID#"
				 frameborder="0" framespacing="0" marginwidth="0" marginheight="0" src="#application.url.farcry#/admin/blank.cfm">
				
			</iframe>
		</cfoutput>
		</cfsavecontent>
		<cfreturn html>
	</cffunction>
	
	<cffunction name="HTMLSafe" hint="Coverts special characters to character entities, making a string safe for display in HTML." output="false" returntype="string">
		<cfargument name="string" type="string" required="true" hint="string to convert">
		
		<cfscript>
			/**
			 * Coverts special characters to character entities, making a string safe for display in HTML.
			 * 
			 * @param string 	 String to format. (Required)
			 * @return Returns a string. 
			 * @author Gyrus (gyrus@norlonto.net) 
			 * @version 1, April 30, 2003 
			 */
		
			// Initialise
			var badChars = """,#Chr(161)#,#Chr(162)#,#Chr(163)#,#Chr(164)#,#Chr(165)#,#Chr(166)#,#Chr(167)#,#Chr(168)#,#Chr(169)#,#Chr(170)#,#Chr(171)#,#Chr(172)#,#Chr(173)#,#Chr(174)#,#Chr(175)#,#Chr(176)#,#Chr(177)#,#Chr(178)#,#Chr(179)#,#Chr(180)#,#Chr(181)#,#Chr(182)#,#Chr(183)#,#Chr(184)#,#Chr(185)#,#Chr(186)#,#Chr(187)#,#Chr(188)#,#Chr(189)#,#Chr(190)#,#Chr(191)#,#Chr(215)#,#Chr(247)#,#Chr(192)#,#Chr(193)#,#Chr(194)#,#Chr(195)#,#Chr(196)#,#Chr(197)#,#Chr(198)#,#Chr(199)#,#Chr(200)#,#Chr(201)#,#Chr(202)#,#Chr(203)#,#Chr(204)#,#Chr(205)#,#Chr(206)#,#Chr(207)#,#Chr(208)#,#Chr(209)#,#Chr(210)#,#Chr(211)#,#Chr(212)#,#Chr(213)#,#Chr(214)#,#Chr(216)#,#Chr(217)#,#Chr(218)#,#Chr(219)#,#Chr(220)#,#Chr(221)#,#Chr(222)#,#Chr(223)#,#Chr(224)#,#Chr(225)#,#Chr(226)#,#Chr(227)#,#Chr(228)#,#Chr(229)#,#Chr(230)#,#Chr(231)#,#Chr(232)#,#Chr(233)#,#Chr(234)#,#Chr(235)#,#Chr(236)#,#Chr(237)#,#Chr(238)#,#Chr(239)#,#Chr(240)#,#Chr(241)#,#Chr(242)#,#Chr(243)#,#Chr(244)#,#Chr(245)#,#Chr(246)#,#Chr(248)#,#Chr(249)#,#Chr(250)#,#Chr(251)#,#Chr(252)#,#Chr(253)#,#Chr(254)#,#Chr(255)#";
			var goodChars = "&quot;,&iexcl;,&cent;,&pound;,&curren;,&yen;,&brvbar;,&sect;,&uml;,&copy;,&ordf;,&laquo;,&not;,&shy;,&reg;,&macr;,&deg;,&plusmn;,²,³,&acute;,&micro;,&para;,&middot;,&cedil;,¹,&ordm;,&raquo;,¼,½,¾,&iquest;,&times;,&divide;,&Agrave;,&Aacute;,&Acirc;;,&Atilde;,&Auml;,&Aring;,&AElig;,&Ccedil;,&Egrave;,&Eacute;,&Ecirc;,&Euml;,&Igrave;,&Iacute;,&Icirc;,&Iuml;,&ETH;,&Ntilde;,&Ograve;,&Oacute;,&Ocirc;,&Otilde;,&Ouml;,&Oslash;,&Ugrave;,&Uacute;,&Ucirc;,&Uuml;,&Yacute;,&THORN;,&szlig;,&agrave;,&aacute;,&acirc;,&atilde;,&auml;,&aring;,&aelig;,&ccedil;,&egrave;,&eacute;,&ecirc;,&euml;,&igrave;,&iacute;,&icirc;,&iuml;,&eth;,&ntilde;,&ograve;,&oacute;,&ocirc;,&otilde;,&ouml;,&oslash;,&ugrave;,&uacute;,&ucirc;,&uuml;,&yacute;,&thorn;,&yuml;;,&##338;,&##339;,&##352;,&##353;,&##376;,&##710;,&##732;,&##8206;,&##8207;,&##8211;,&##8212;,&##8216;,&##8217;,&##8218;,&##8220;,&##8221;,&##8222;,&##8224;,&##8225;,&##8240;,&##8249;,&##8250;,&##8364;,<sup><small>TM</small></sup>";
		
			// MX/Unicode matches
			badChars = "#badChars#,#Chr(338)#,#Chr(339)#,#Chr(352)#,#Chr(353)#,#Chr(376)#,#Chr(710)#,#Chr(8211)#,#Chr(8212)#,#Chr(8216)#,#Chr(8217)#,#Chr(8218)#,#Chr(8220)#,#Chr(8221)#,#Chr(8222)#,#Chr(8224)#,#Chr(8225)#,#Chr(8240)#,#Chr(8249)#,#Chr(8250)#,#Chr(8364)#,#Chr(8482)#";
			
			// Return immediately if blank string
			if (NOT Len(Trim(string))) return string;
			
			// Do replacing
			return ReplaceList(string, badChars, goodChars);		
		</cfscript>
	</cffunction>

</cfcomponent>