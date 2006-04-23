<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/files.cfm,v 1.20 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.20 $

|| DESCRIPTION || 
$Description: dmNews Edit PLP - Adds files as associated objects.$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfoutput>
<script>
var isIE=document.all?true:false;
var layers = isIE?document.all.tags("DIV"):document.getElementsByTagName("DIV");
selectedDiv = "fileform";
function toggleForm(selectedDiv,display)
{
	el = document.getElementById(selectedDiv);
	el.style.display=display;
	el = document.getElementById('newfile');
	if (display == 'inline')			
		el.style.display='none';
	else	
		el.style.display='inline';
}

function hideAll()
{
	for(var i=0;i<layers.length;i++){
		if (layers[i].id != 'PLPButtons' && layers[i].id != 'PLPMoveButtons')
			layers[i].style.display='none';
	}	
}
  

function removeUploadBtn()
{
	el = document.getElementById('newfile');
	el.style.display='none';
}
</script></cfoutput>

<cfscript>
	/*this page has a number of different form postings. establishing what action to take
	based on the form submitted*/ 
	if (isDefined("form.newObject") OR isDefined("form.editObject"))
		action = 'update';
	else if (isDefined("form.deleteObject"))
		action = 'deleteObject';
	else
		action = 'normal';
</cfscript>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfswitch expression="#action#">
	<cfcase value="update">
		
		<cfscript>
			stProperties = structNew();
			if (isDefined("form.editObject"))
			{
				stProperties.objectID = form.objectID;
			}	
			else  
			{	
				stProperties.objectID = createUUID();
				stProperties.datetimecreated = Now();
				arrayAppend(output.aObjectIds,stProperties.objectID);
			}	
			stProperties.title = form.filetitle;
			stProperties.label = form.filetitle;
			stProperties.createdby = session.dmSec.authentication.userlogin;
			stProperties.description = form.description;
			stProperties.datetimelastupdated = Now();
			stProperties.documentDate = createODBCDatetime('#form.publishYear#-#form.publishMonth#-#form.publishDay# #form.publishHour#:#form.publishMinutes#');
			stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
			oForm = createObject("component","#application.packagepath#.farcry.form");
			error = 0;
		</cfscript>
		
		<!--- upload the original file 	--->
		<cfif trim(len(FORM.filename)) NEQ 0 AND form.filename NEQ form.filename_old>
			<cfif len(application.config.file.filetype)>
				<cftry>
					<cffile action="upload"
						filefield="filename" 
						accept="#application.config.file.filetype#" 
						destination="#application.path.defaultFilePath#" 
						nameconflict="#application.config.general.fileNameConflict#"> 
					<cfcatch>
						<cfoutput>
						<cfset subS=listToArray('#cfcatch.message#,#application.config.file.filetype#')>
						<p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].acceptableFileTypes,subS)#</p>
						</cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<cffile action="upload"
					filefield="filename" 
					destination="#application.path.defaultFilePath#" 
					nameconflict="#application.config.general.fileNameConflict#"> 
			</cfif>
			
			<!--- delete existing file --->
			<cfif fileExists("#application.path.defaultFilePath#/#form.filename_old#")>
				<cffile action="delete" file="#application.path.defaultFilePath#/#form.filename_old#">
			</cfif>	
			
			<!--- update file details if saved without error --->
			<cfif not error>
				<cfscript>
					stProperties.filename = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory);
					stProperties.filepath = file.ServerDirectory;
					stProperties.fileSize = file.fileSize;
					stProperties.fileType = file.contentType;
					stProperties.fileSubType = file.contentSubType;
					stProperties.fileExt = file.serverFileExt;
				</cfscript>
			</cfif>
		</cfif>
				
		<!--- if form.editfile exists - then an existing object is being edited - else must create new object --->
		
		<cfscript>
			oType = createobject("component", application.types['dmFile'].typePath);
			if (isdefined("form.editObject")) {
				// update the OBJECT	
				oType.setData(stProperties=stProperties);
			} else {
				// create the new OBJECT
				stNewObj = oType.createData(stProperties=stProperties);
				NewObjID = stNewObj.objectid;
			}
		</cfscript>
	</cfcase>

	<cfcase value="deleteObject">
		<cfif isDefined("form.objectID")>
			<!--- delete them from the database --->
			<nj:deleteObjects lObjectIDs="#form.objectID#" typename="dmFile" rMsg="msg">
			<cfloop list="#form.objectID#" index="objectID">
				<cfoutput>
				<cfloop index="i" from="#arrayLen(output.aObjectIds)#" to="1" step="-1">
					<cfif output.aObjectIds[i] is objectId>
						<cfset ArrayDeleteAt(output.aObjectIds, i )>
					</cfif>
				</cfloop> 
				</cfoutput>
			</cfloop>
		<cfelse>
			<cfset msg = "No objects were selected for deletion">	
		</cfif>	
	</cfcase>
	<cfdefaultcase>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>

<cfif isDefined("msg")>
	<cfoutput>#msg#</cfoutput>
</cfif>

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].files#</div></cfoutput>

<cfif (StructKeyExists(output, "aObjectIDs"))>
	<cfset aFileArray = arrayNew(1)>
	<cfloop from="1" to="#arrayLen(output.aObjectIds)#" index="i">
		<!--- get the objectType --->
		<cfinvoke component="farcry.fourq.fourq" returnvariable="typename" method="findType" objectID="#output.aObjectIds[i]#">
		<cfif typename IS "dmFile">
			<cfscript>
				arrayAppend(aFileArray,output.aObjectIds[i]);
			</cfscript>
		</cfif>
	</cfloop>
	<cfif arrayLen(aFileArray) GT 0>
	<cfoutput>
	<form action="" method="post">
	<table class="borderTable" >
	<tr>
		<td colspan="5" align="center"><strong>#application.adminBundle[session.dmProfile.locale].existingFiles#</strong></td> 
	</tr>
	<tr>
		<td>&nbsp;
			
		</td>
		<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].title#</span></td>
		<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].preview#</span></td>
		<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].edit#</span></td>
		<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].delete#</span></td>
	</tr></cfoutput>
	<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
		<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
		<cfoutput>
		<tr>
			<td>
				<nj:getFileIcon filename="#stThisFile.filename#" r_stIcon="fileicon"> 	
				<img src="#application.url.farcry#/images/treeImages/#fileicon#">
			</td>
			<td>
				#left(stThisFile.title,50)#
			</td>
			<td align="center">
				<cfif len(trim(stThisFile.filename)) NEQ 0>
				<a href="#stThisFile.filePath#\#stThisFile.filename#" target="_blank">
					<img src="#application.url.farcry#/images/treeImages/preview.gif" border="0">
				</a>
				<cfelse>
					<span class="FormLabel">[#application.adminBundle[session.dmProfile.locale].noFileUploaded#]</span>	
				</cfif>
			</td>

			<td align="center">
				<a href="javascript:void(0);" onClick="hideAll();toggleForm('#i#_edit','inline');">
					<img src="#application.url.farcry#/images/treeImages/edit.gif" border="0">
				</a>
			</td>
			<td align="center">
				<input type="checkbox" class="f-checkbox" name="objectID" value="#stThisFile.objectID#" />
			</td>
		</tr></cfoutput>
	</cfloop>
	<cfoutput>
	<tr>
		<td colspan="4">&nbsp;</td>
		<td><input name="deleteObject" type="submit" class="normalbttnstyle" value="#application.adminBundle[session.dmProfile.locale].delete#"></td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<cfelse>
	<cfoutput>
		<table>
			<tr>
				<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].noFilesAddedToObj#</span></td>
			</tr>
		</table>
	</cfoutput>	
	</cfif>
</cfif>

<cfoutput>
<div id="newfile" style="display:inline;">
<p>
<input type="button" class="normalbttnstyle" onClick="toggleForm('fileform','inline');" value="#application.adminBundle[session.dmProfile.locale].uploadNewFile#">
</p>
</div></cfoutput>

<!--- Output the file edit divs --->
<cfif arrayLen(aFileArray) GT 0>
<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
	<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
	<cfoutput>
	<div id="#i#_edit" style="display:none;">
	<form action="" method="post" enctype="multipart/form-data" name="editFileForm_#i#">
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].editFile#</span>
	<table>
	<tr>
  	 <td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
   	 <td><input type="text" name="filetitle" value="#stThisFile.title#" class="FormTextBox"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].datePublishedLabel#</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="publishDay" class="formfield">
							<cfloop from="1" to="31" index="a">
								<option value="#a#" <cfif a IS day(stThisFile.documentDate)>selected</cfif>>#a#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="publishMonth" class="formfield">
							<cfloop from="1" to="12" index="a">
								<option value="#a#" <cfif a IS month(stThisFile.documentDate)>selected</cfif>>#localeMonths[a]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="publishYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="a">
								<option value="#a#" <cfif a IS year(stThisFile.documentDate)>selected</cfif>>#a#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishHour" class="formfield">
							<cfloop from="0" to="23" index="a">
								<option value="#a#" <cfif hour(stThisFile.documentDate) IS a>selected</cfif>>#a# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishMinutes" class="formfield">
							<cfloop from="0" to="45" index="a" step="15">
								<option value="#a#" <cfif minute(stThisFile.documentDate) IS a>selected</cfif>>#a# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>	
  	 <td valign="top" ><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].fileLabel#</span> </td>
   	 <td>
	 	<input type="file" name="filename" claass="FormFileBox">
		<input type="hidden" name="filename_old" value="#stThisFile.filename#">
		<cfif len(stThisFile.filename) NEQ 0>
			<br>[#application.adminBundle[session.dmProfile.locale].fileExists#]
		</cfif>
	 </td>
	</tr>
	
	<tr>
  	 <td valign="top"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].descLabel#</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stThisFile.description#</textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="hidden" name="objectID" value="#stThisFile.objectID#">
			<input type="Submit" name="editObject" value="#application.adminBundle[session.dmProfile.locale].uploadFile#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="toggleForm('#i#_edit','none')"; >
		</td>
	</tr>
		
	</table>
	<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("editFileForm_<cfoutput>#i#</cfoutput>");
		objForm.filetitle.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
			//-->
		</SCRIPT>
	</form>	
</div></cfoutput>
	</cfloop>
</cfif>

<!--- Upload new file DIV --->
<cfoutput><div id="fileform" style="display:none">
<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].uploadFile#</span>
	
<form action="" method="post" enctype="multipart/form-data" name="fileForm">
	
	<table border="0">
	<tr>
  	 <td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
   	 <td><input type="text" name="filetitle" value="" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].fileLabel#</span></td>
	  	<td>
	 		<input type="file" name="filename" class="FormFileBox">
			<input type="hidden" name="filename_old" value="">
		</td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].datePublishedLabel#</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="publishDay" class="formfield">
							<cfloop from="1" to="31" index="a">
								<option value="#a#" <cfif a IS day(now())>selected</cfif>>#a#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="publishMonth" class="formfield">
							<cfloop from="1" to="12" index="a">
								<option value="#a#" <cfif a IS month(now())>selected</cfif>>#localeMonths[a]#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<cfscript>
							thisYear = year(now());
							startYear = 2000;
							endYear = year(dateadd("yyyy",7,now()));	
						</cfscript>
						<select name="publishYear" class="formfield">
							<cfloop from="#startYear#" to="#endYear#" index="a">
								<option value="#a#" <cfif a IS year(now())>selected</cfif>>#a#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishHour" class="formfield">
							<cfloop from="0" to="23" index="a">
								<option value="#a#" <cfif hour(now()) IS a>selected</cfif>>#a# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishMinutes" class="formfield">
							<cfloop from="0" to="45" index="a" step="15">
								<option value="#a#" <cfif minute(now()) IS a>selected</cfif>>#a# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>
  		<td valign="top"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].descLabel#</span></td>
   	 	<td><textarea cols="30" rows="4" name="description" class="FormTextArea"></textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="newObject" value="#application.adminBundle[session.dmProfile.locale].uploadFile#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="toggleForm('fileform','none')"; >
		</td>
	</tr>
</table>
	<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm2 = new qForm("fileForm");
		objForm2.filetitle.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
		objForm2.filename.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
			//-->
		</SCRIPT>
	</form>	
</div>
<div id="PLPButtons" class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform"></cfoutput>
	<tags:plpNavigationButtons>
<cfoutput></form>
</div>

</cfoutput>
<cfelse>	

	
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">