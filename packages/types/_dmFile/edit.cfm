<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/edit.cfm,v 1.31.2.1 2005/05/12 00:19:45 guy Exp $
$Author: guy $
$Date: 2005/05/12 00:19:45 $
$Name: milestone_2-3-2 $
$Revision: 1.31.2.1 $

|| DESCRIPTION || 
$Description: edit handler$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset showform=1>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfset showform=0>
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].objectUpdated#</span>
		
	<cfscript>
		stProperties = structNew();
		StProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
		stProperties.documentDate = createODBCDatetime('#form.publishYear#-#form.publishMonth#-#form.publishDay# #form.publishHour#:#form.publishMinutes#');
	
		//TODO - fix this - with createodbctime etc		
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
		oForm = createObject("component","#application.packagepath#.farcry.form");
	</cfscript>

	<!--- upload the original file 	--->
	<cfif len(trim(FORM.filename)) NEQ 0>
		<!--- if accept list not specified in config, accept everything --->

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
				destination="#application.path.defaultFilePath#"  nameconflict="#application.config.general.fileNameConflict#"> 
		</cfif>
		<cfset stProperties.filename = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
		<cfset stProperties.filepath = file.ServerDirectory>
		<cfset stProperties.fileSize = file.fileSize>
		<cfset stProperties.fileType = file.contentType>
		<cfset stProperties.fileSubType = file.contentSubType>
		<cfset stProperties.fileExt = file.serverFileExt>
	</cfif>

	<cfif not isdefined("error")>
		<cfscript>
			// archive cuurent live file object 
			if (application.config.file.archiveFiles)
				archiveObject(objectid=stProperties.objectid);

			// update the OBJECT	
			setData(stProperties=stProperties);
		</cfscript>
	
		<!--- get parent to update tree --->
		<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
		
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">
		
		<!--- reload overview page --->
		<cfoutput>
			<script language="JavaScript">
				parent['editFrame'].location.href = '#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#';
			</script>
		</cfoutput>
				
	<cfelse>
		<cfset showform=1>
	</cfif>
</cfif>
	
<cfif showform> <!--- Show the form --->
	
	<cfoutput>
	<br>
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].fileUploadDetails#</span><p></p>
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	
	<tr>
  	 <td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
   	 <td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	<tr>
		<td nowrap class="FormLabel">#application.adminBundle[session.dmProfile.locale].datePublishedLabel#</td>
		<td >
			<table>
				<tr>
					<td>
						<select name="publishDay" class="formfield">
							<cfloop from="1" to="31" index="i">
								<option value="#i#" <cfif i IS day(stObj.documentDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>	
					</td>
					<td>
						<select name="publishMonth" class="formfield">
							<cfloop from="1" to="12" index="i">
								<option value="#i#" <cfif i IS month(stObj.documentDate)>selected</cfif>>#localeMonths[i]#</option>
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
							<cfloop from="#startYear#" to="#endYear#" index="i">
								<option value="#i#" <cfif i IS year(stObj.documentDate)>selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishHour" class="formfield">
							<cfloop from="0" to="23" index="i">
								<option value="#i#" <cfif hour(stObj.documentDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						
							</cfloop>
						</select>
					</td>
					<td>
						<select name="publishMinutes" class="formfield">
							<cfloop from="0" to="45" index="i" step="15">
								<option value="#i#" <cfif minute(stObj.documentDate) IS i>selected</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						
							</cfloop>
						</select>
					</td>	
				</tr>
			</table>
		</td>
	</tr>
	<tr>	
  	 <td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].fileLabel#</span></td>
   	 <td><input type="file" name="filename" class="FormFileBox"></td>
	</tr>
	<tr>
		<td colspan="2">
		<cfif not len(stObj.filename)>
			<span class="FormSubHeading">[#application.adminBundle[session.dmProfile.locale].noFileUploaded#]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].newFileOverwriteThisFile#</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].existingFileLabel#</span> 
		</td>
		<nj:getFileIcon filename="#stObj.filename#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/files/#stObj.filename#" target="_blank">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].previewUC#</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
	</tr>

	<tr>
  	 <td valign="top"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].descLabel#</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].reallyDone#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">  
		</td>
	</tr>
		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
		objForm = new qForm("fileForm");
		objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
	</script>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">