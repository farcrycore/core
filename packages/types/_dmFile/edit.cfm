<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/edit.cfm,v 1.15 2003/07/15 07:04:15 brendan Exp $
$Author: brendan $
$Date: 2003/07/15 07:04:15 $
$Name: b131 $
$Revision: 1.15 $

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

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset showform=1>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfset showform=0>
	<span class="FormTitle">Object Updated</span>
		
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
	
		//TODO - fix this - with createodbctime etc		
		stProperties.datetimelastupdated = Now();
		stProperties.datetimecreated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>

	<!--- upload the original file 	--->
	<cfif trim(len(FORM.filename)) NEQ 0>
		<!--- if accept list not specified in config, accept everything --->
		<cfif len(application.config.file.filetype)>
			<cfinvoke 
				component="#application.packagepath#.farcry.form" 
				method="uploadFile" 
				destination="#application.defaultFilePath#" 
				returnvariable="stReturn" 
				formfield="filename" 
				accept="#application.config.file.filetype#" /> 
		<cfelse>
			<cfinvoke 
				component="#application.packagepath#.farcry.form" 
				method="uploadFile" 
				destination="#application.defaultFilePath#" 
				returnvariable="stReturn" 
				formfield="filename" /> 
		</cfif>
		
		<cfif NOT stReturn.bSuccess>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			File types that are accepted: #application.config.file.filetype# <p></p></cfoutput>
			<cfset error=1>
		<cfelse>	
			<cfscript>
				stProperties.filename = stReturn.ServerFile;
				stProperties.filepath = stReturn.ServerDirectory;
			</cfscript>
		</cfif>	
		
	</cfif>
	

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmFile"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	
	<cfif not isdefined("error")>
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
	<span class="FormTitle">File Upload Details</span><p></p>
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table class="FormTable">
	
	<tr>
  	 <td><span class="FormLabel">Title:</span></td>
   	 <td><input type="text" name="title" value="#stObj.title#" class="FormTextBox"></td>
	</tr>
	
	<tr>	
  	 <td><span class="FormLabel">File:</span></td>
   	 <td><input type="file" name="filename" class="FormFileBox"></td>
	</tr>
	<tr>
		<td colspan="2">
		<cfif not len(stObj.filename)>
			<span class="FormSubHeading">[No file uploaded]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">Uploading a new file will overwrite this file</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">Existing File :</span> 
		</td>
		<nj:getFileIcon filename="#stObj.filename#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#stObj.filePath#\#stObj.filename#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
	</tr>
<!--- 	<tr>
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
					
			</cfif>
		</td>
	</tr>	
 --->	
	<tr>
  	 <td valign="top"><span class="FormLabel">Description:</span></td>
   	 <td><textarea cols="30" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="Submit" name="Submit" value="Done!" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">  
		</td>
	</tr>
		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
	</script>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">