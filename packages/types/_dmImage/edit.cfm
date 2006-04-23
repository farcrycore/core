<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/edit.cfm,v 1.19 2003/10/14 07:14:10 brendan Exp $
$Author: brendan $
$Date: 2003/10/14 07:14:10 $
$Name: b201 $
$Revision: 1.19 $

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
	<cfscript>
		stProperties = structNew();
		stProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		//stProperties.caption = form.caption;
		stProperties.alt = form.alt;
		stProperties.width = form.width;
		stProperties.height = form.height;
				
		stProperties.datetimelastupdated = Now();
		stProperties.datetimecreated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
	</cfscript>
	
	<!--- upload the original file 	--->
	<cfset imageAcceptList = application.config.image.imagetype> 
	
	<!--- TODO - need some more error checking here on uploadFile method return --->
	<cfif trim(len(form.imageFile)) NEQ 0>
		<!--- upload new file (if accept list not specified in config, accept everything) --->
		<cfif len(application.config.image.imagetype)>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfelse>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#"> 
		</cfif>
		
		<cfif stReturn.bsuccess>
			<cfscript>
				stProperties.imageFile = stReturn.ServerFile;
				stProperties.originalImagePath = stReturn.ServerDirectory;
			</cfscript>
		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #imageAcceptList# <p></p></cfoutput>
			<cfset error=1>
		</cfif>
	</cfif>
	
	<cfif trim(len(FORM.optimisedImage)) NEQ 0 >
		<!--- upload new file (if accept list not specified in config, accept everything) --->
		<cfif len(application.config.image.imagetype)>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfelse>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#"> 
		</cfif>
		
		<cfif stReturn.bsuccess>
			<cfscript>
				stProperties.optimisedimage = stReturn.ServerFile;
				stProperties.optimisedImagePath = stReturn.ServerDirectory;
			</cfscript>
		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #imageAcceptList# <p></p></cfoutput>
			<cfset error=1>
		</cfif>
	</cfif>
	
	<cfif trim(len(FORM.thumbnailImage)) NEQ 0>
		<!--- upload new file (if accept list not specified in config, accept everything) --->
		<cfif len(application.config.image.imagetype)>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="thumbnailImage" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfelse>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="thumbnailImage" destination="#application.defaultImagePath#"> 
		</cfif>
		
		<cfif stReturn.bsuccess>
			<cfscript>
				stProperties.thumbnail = stReturn.ServerFile;
				stProperties.thumbnailImagePath = stReturn.ServerDirectory;
			</cfscript>
		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #imageAcceptList# <p></p></cfoutput>
			<cfset error=1>
		</cfif>
	</cfif>
	
	<cfscript>
		// update the OBJECT	
		oType = createobject("component","#application.packagepath#.types.dmImage");
		oType.setData(stProperties=stProperties);
	</cfscript>
	
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

 <!--- Show the form --->
<cfif showform>

	<cfoutput>
	<form action="" method="post" enctype="multipart/form-data" name="imageForm">
		<br>
		<table class="FormTable">
		<tr>
			<td colspan="2"><span class="FormSubHeading">Image Details</span></th>
		</tr>		
		
		<tr>
			<td nowrap><span class="FormLabel">Title:</span></td>
			<td nowrap width="100%">
				<input type="text" name="title" value="#stObj.title#" class="FormTextBox">
			</td>
		</tr>
	
		<tr valign="top">
			<td nowrap><span class="FormLabel">Alternate text:</span></td>
			<td nowrap>
				<textarea type="text" name="alt" class="FormTextArea" rows="4">#stObj.alt#</textarea>
			</td>
		</tr>
	
		<tr valign="top">
			<td nowrap>&nbsp;</td>
			<td nowrap>		
				<span class="FormLabel">Width:&nbsp;</span><input  class="FormTextBox" style="width:40px" type="text" name="width" value="#stObj.width#">
				<span class="FormLabel">Height:&nbsp;</span><input class="FormTextBox" style="width:40px" type="text" name="height" value="#stObj.height#">
			</td>
		</tr>	
		<tr>
			<td colspan="2"><span class="FormSubHeading">Image Files</span></th>
		</tr>	
			
		<tr valign="middle">
			<td nowrap><span class="FormLabel">Default Image</span></td>
			<td nowrap width="100%">
				<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
			</td>
		</tr>
		
		<tr><td colspan="2">
		<cfif not len(stObj.imagefile)>
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
			<span class="FormLabel">Existing Default Image :</span> 
		</td>
		<nj:getFileIcon filename="#stObj.imagefile#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.imagefile#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
	
		<tr valign="middle">
			<td nowrap><span class="FormLabel">Thumbnail</span></td>
			<td nowrap>
				<input type="file" name="thumbnailImage" class="FormFileBox">
			</td>
		</tr>
		
		<tr><td colspan="2">
		<cfif not len(stObj.thumbnail)>
			<span class="FormSubHeading">[No thumbnail image uploaded]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">Uploading a new file will overwrite this file</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">Existing Thumbnail Image :</span> 
		</td>
		<nj:getFileIcon filename="#stObj.thumbnail#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.thumbnail#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
	
		<tr valign="middle">
			<td nowrap><span class="FormLabel">Highres</span></td>
			<td nowrap>
				<input type="file" name="optimisedImage" class="FormFileBox">
			</td>
		</tr>
		<tr><td colspan="2">
		<cfif not len(stObj.optimisedimage)>
			<span class="FormSubHeading">[No optimised image uploaded]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">Uploading a new file will overwrite this file</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">Existing Thumbnail Image :</span> 
		</td>
		<nj:getFileIcon filename="#stObj.optimisedimage#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.optimisedimage#" target="_blank">
				<span class="FormLabel">PREVIEW</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
			
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		</td>
	</tr>
			
	</table>
	</form>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("imageForm");
		objForm.title.validateNotNull("Please enter a title");
		objForm.alt.validateLengthGT(512);
			
		//bring focus to title
		document.imageForm.title.focus();//-->
	</SCRIPT>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">