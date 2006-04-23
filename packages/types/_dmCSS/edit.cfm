<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmCSS/edit.cfm,v 1.23 2004/02/04 06:36:19 paul Exp $
$Author: paul $
$Date: 2004/02/04 06:36:19 $
$Name: milestone_2-2-1 $
$Revision: 1.23 $

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

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	
	<cfscript>
		stProperties = structNew();
		stProperties.objectid = stObj.ObjectID;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.description = form.description;
		stProperties.filename = form.filename;
					
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>
	
	<!--- check for file to upload --->
	<cfif trim(len(form.cssFile)) NEQ 0>
		<cftry>
			<cffile action="upload" filefield="cssFile" destination="#application.path.project#/www/css/" accept="text/css" nameConflict="Overwrite"> 
			<cfcatch>
				<div><span class="title">Error!</span><p></p>
				<cfoutput>#cfcatch.Message#<p></p>
				<span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/edittabEdit.cfm?objectid=#objectid#">Return to edit form</a></cfoutput></div>
				<cfabort>
			</cfcatch>
		</cftry>
		<cfscript>
			stProperties.filename = file.ServerFile;
		</cfscript>
	<cfelse>
		<cfif isdefined("cssContent")>
			<!--- save content as file --->
			<cffile 
			  action = "write" 
			  file = "#application.path.project#/www/css/#stProperties.filename#"
			  output = "#cssContent#"
			  charset="utf-8">
		</cfif>
	</cfif>
	
	<cfscript>
		// update the OBJECT	
		oType = createobject("component", application.types.dmCSS.typePath);
		oType.setData(stProperties=stProperties);
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
	
</cfif> <!--- Show the form --->


	<cfoutput>
	<form action="" method="post" enctype="multipart/form-data" name="fileForm">
		
	<table align="left" border="0" width="80%" >
	<tr>
		<td colspan="2" align="center">
			<span class="FormTitle">#stObj.title#</span>
		</td>
	</tr>
	
	<tr>
  		<td width="20" align="right"><span class="FormLabel">Title:</span></td>
   	 	<td align="left"><input type="text" name="title" value="#stObj.title#" style="width:250px;" class="FormTextBox"></td>
	</tr>
	<tr>
		<td colspan="2" >&nbsp;</td>
	</tr>
	
	<tr>
		<td align="right" ><span class="FormLabel">Upload File</span></td>
		<td>
			<input type="hidden" name="filename" value="#stObj.filename#">
			<input type="file" name="cssFile" class="FormFileBox">&nbsp;&nbsp;
		</td>
	</tr>
	<tr>
		<td colspan="2" >&nbsp;</td>
	</tr>
	<tr>
  		<td align="right" valign="top"><span class="FormLabel">Description:</span></td>
   	 	<td><textarea cols="50" rows="4" name="description" class="FormTextArea">#stObj.description#</textarea></td>
	</tr>
	<cfif stObj.filename neq "" and FileExists("#application.path.project#/www/css/#stObj.filename#")>
		<cffile 
		  action = "read" 
		  file = "#application.path.project#/www/css/#stObj.filename#"
		  variable = "css"
		  charset="utf-8">
		<tr>
			<td align="right" valign="top"><span class="FormLabel">Style Sheet</span></td>
			<td><textarea style="width:500"  rows="30" name="cssContent" class="FormTextArea" wrap="off">#css#</textarea></td>
		</tr>
	</cfif>

	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		</td>
	</tr>		
	</table>
	
	</form>
	<script>
		//bring focus to title
		document.fileForm.title.focus();
	</script>
	</cfoutput>
	
<cfsetting enablecfoutputonly="no">