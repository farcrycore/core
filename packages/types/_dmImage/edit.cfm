<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||

$Header: /cvs/farcry/farcry_core/packages/types/_dmImage/edit.cfm,v 1.29 2004/12/06 19:12:48 tom Exp $
$Author: tom $
$Date: 2004/12/06 19:12:48 $
$Name: milestone_2-3-2 $
$Revision: 1.29 $

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

<cfprocessingDirective pageencoding="utf-8"><br>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset showform=1>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	
	<cfset showform=0>	
	<cfscript>
		oForm = createObject("component","#application.packagepath#.farcry.form");
		
		stProperties = structNew();
		stProperties.objectid = stObj.objectid;
		stProperties.title = form.title;
		stProperties.label = form.title;
		stProperties.alt = form.alt;
		stProperties.width = form.width;
		stProperties.height = form.height;
				
		stProperties.datetimelastupdated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
		//unlock object
		stProperties.locked = 0;
		stProperties.lockedBy = "";
		oForm = createObject("component","#application.packagepath#.farcry.form");
		imageAcceptList = application.config.image.imagetype;
	</cfscript>
	
	<!--- set accept list --->
	<cfset imageAcceptList = application.config.image.imagetype> 
	
	<!--- check default image has been passed in from form --->
	<cfif trim(len(form.imageFile)) NEQ 0>	
		<!--- check if it's a new image --->
		<cfif len(stObj.imageFile)>		
			<!--- overwriting an existing image so check if new file has the same name as existing file--->
			<cfif stObj.imageFile eq form.defaultImageFileName>
				<cftry>
					<!--- same name so upload new image overwriting the existing one --->
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="OVERWRITE"> 
					<cfelse>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#" nameconflict="OVERWRITE"> 
					</cfif>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- different name so upload new image making it unique --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="MAKEUNIQUE"> 
					<cfelse>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#" nameconflict="MAKEUNIQUE"> 
					</cfif>
					<!--- rename to overwrite existing one --->
					<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#stObj.imageFile#">
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			</cfif>			
		<cfelse>
			<!--- new image so check if filename is already in use --->
			<cfset stCheckDefault = checkForExisting(filename=form.defaultImageFileName)>
			
			<cfif not stCheckDefault.bExists>
				<!--- upload new file (if accept list not specified in config, accept everything) --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#"> 
					<cfelse>
						<cffile action="upload" filefield="imagefile" destination="#application.path.defaultImagePath#"> 
					</cfif>
					
					<!--- add image values to object data --->
					<cfset stProperties.imageFile = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
					<cfset stProperties.originalImagePath = file.ServerDirectory>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- filename already in use by another image object --->
				<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].fileNameInUse,'#stCheckDefault.fileName#')#</cfoutput>
				<cfset error=1>
			</cfif>
		</cfif>
	</cfif>

	

	<!--- check optimised image has been passed in from form --->
	<cfif trim(len(form.optimisedImage)) NEQ 0>	
		<!--- check if it's a new image --->
		<cfif len(stObj.optimisedImage)>		
			<!--- overwriting an existing image so check if new file has the same name as existing file--->
			<cfif stObj.optimisedImage eq form.optImageFileName>
				<cftry>
					<!--- same name so upload new image overwriting the existing one --->
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="OVERWRITE"> 
					<cfelse>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#" nameconflict="OVERWRITE"> 
					</cfif>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- different name so upload new image making it unique --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="MAKEUNIQUE"> 
					<cfelse>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#" nameconflict="MAKEUNIQUE"> 
					</cfif>
					<!--- rename to overwrite existing one --->
					<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#stObj.optimisedImage#">
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			</cfif>			
		<cfelse>
			<!--- new image so check if filename is already in use --->
			<cfset stCheckOptimised = checkForExisting(filename=form.optImageFileName)>
			
			<cfif not stCheckOptimised.bExists>
				<!--- upload new file (if accept list not specified in config, accept everything) --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#"> 
					<cfelse>
						<cffile action="upload" filefield="optimisedImage" destination="#application.path.defaultImagePath#"> 
					</cfif>
					
					<!--- add image values to object data --->
					<cfset stProperties.optimisedImage = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
					<cfset stProperties.optimisedImagePath = file.ServerDirectory>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- filename already in use by another image object --->
				<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].fileNameInUse,'#stCheckOptimised.fileName#')#</cfoutput>
				<cfset error=1>
			</cfif>
		</cfif>
	</cfif>
	
	<!--- check thumbnail image has been passed in from form --->
	<cfif trim(len(form.thumbnailImage)) NEQ 0>	
		<!--- check if it's a new image --->
		<cfif len(stObj.thumbnail)>		
			<!--- overwriting an existing image so check if new file has the same name as existing file--->
			<cfif stObj.thumbnail eq form.thumbImageFileName>
				<cftry>
					<!--- same name so upload new image overwriting the existing one --->
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="OVERWRITE"> 
					<cfelse>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#" nameconflict="OVERWRITE"> 
					</cfif>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- different name upload new image making it unique --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#" nameconflict="MAKEUNIQUE"> 
					<cfelse>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#" nameconflict="MAKEUNIQUE"> 
					</cfif>
					<!--- rename to overwrite existing one --->
					<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#stObj.thumbnail#">
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			</cfif>			
		<cfelse>
			<!--- new image so check if filename is already in use --->
			<cfset stCheckThumb = checkForExisting(filename=form.thumbImageFileName)>
			
			<cfif not stCheckThumb.bExists>
				<!--- upload new file (if accept list not specified in config, accept everything) --->
				<cftry>
					<cfif len(imageAcceptList)>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#" accept="#imageAcceptList#"> 
					<cfelse>
						<cffile action="upload" filefield="thumbnailImage" destination="#application.path.defaultImagePath#"> 
					</cfif>
					
					<!--- add image values to object data --->
					<cfset stProperties.thumbnail = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
					<cfset stProperties.thumbnailImagePath = file.ServerDirectory>
					
					<cfcatch>
						<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
						<cfset error=1>
					</cfcatch>
				</cftry>
			<cfelse>
				<!--- filename already in use by another image object --->
				<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].filenameInUse,'#stCheckThumb.fileName#')#</cfoutput>
				<cfset error=1>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif not isdefined("error")>
		<!--- update the OBJECT --->
		<cfset setData(stProperties=stProperties)>
	
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
	<form action="" method="post" enctype="multipart/form-data" name="imageForm" onsubmit="document['forms']['imageForm'].defaultImageFileName.value = document['forms']['imageForm'].imageFile.value;document['forms']['imageForm'].thumbImageFileName.value = document['forms']['imageForm'].thumbnailImage.value;document['forms']['imageForm'].optImageFileName.value = document['forms']['imageForm'].optimisedImage.value;">
		<input type="hidden" name="defaultImageFileName" value="">
		<input type="hidden" name="thumbImageFileName" value="">
		<input type="hidden" name="optImageFileName" value="">
		<br>
		<table class="FormTable">
		<tr>
			<td colspan="2"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageDetails#</span></th>
		</tr>		
		
		<tr>
			<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
			<td nowrap width="100%">
				<input type="text" name="title" value="#stObj.title#" class="FormTextBox">
			</td>
		</tr>
	
		<tr valign="top">
			<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].alternateTextLabel#</span></td>
			<td nowrap>
				<textarea type="text" name="alt" class="FormTextArea" rows="4">#stObj.alt#</textarea>
			</td>
		</tr>
	
		<tr valign="top">
			<td nowrap>&nbsp;</td>
			<td nowrap>		
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].widthLabel#&nbsp;</span><input  class="FormTextBox" style="width:40px" type="text" name="width" value="#stObj.width#">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].heightLabel#&nbsp;</span><input class="FormTextBox" style="width:40px" type="text" name="height" value="#stObj.height#">
			</td>
		</tr>	
		<tr>
			<td colspan="2"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageFiles#</span></th>
		</tr>	
			
		<tr valign="middle">
			<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].defaultImage#</span></td>
			<td nowrap width="100%">
				<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
			</td>
		</tr>
		
		<tr><td colspan="2">
		<cfif not len(stObj.imagefile)>
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
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].existingDefaultImageLabel#</span> 
		</td>
		<nj:getFileIcon filename="#stObj.imagefile#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.imagefile#" target="_blank">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].previewUC#</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
	
		<tr valign="middle">
			<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].thumbnail#</span></td>
			<td nowrap>
				<input type="file" name="thumbnailImage" class="FormFileBox">
			</td>
		</tr>
		
		<tr><td colspan="2">
		<cfif not len(stObj.thumbnail)>
			<span class="FormSubHeading">[#application.adminBundle[session.dmProfile.locale].noThumbnailImageUploaded#]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].newFileOverwriteThisFile#</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].existingThumbnailImageLabel#</span> 
		</td>
		<nj:getFileIcon filename="#stObj.thumbnail#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.thumbnail#" target="_blank">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].previewUC#</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
	
		<tr valign="middle">
			<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].Highres#</span></td>
			<td nowrap>
				<input type="file" name="optimisedImage" class="FormFileBox">
			</td>
		</tr>
		<tr><td colspan="2">
		<cfif not len(stObj.optimisedimage)>
			<span class="FormSubHeading">[#application.adminBundle[session.dmProfile.locale].noOptimisedImgUploaded#]</span>
		<cfelse>
		
		<table>
		<tr>
			<td colspan="3" style="font-size:7pt;">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].newFileOverwriteThisFile#</span>
			</td>
		</tr>
		<tr>
		<td>
			<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].existingThumbnailImageLabel#</span> 
		</td>
		<nj:getFileIcon filename="#stObj.optimisedimage#" r_stIcon="fileicon"> 
		<td>
			<img src="#application.url.farcry#/images/treeImages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.webroot#/images/#stObj.optimisedimage#" target="_blank">
				<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].previewUC#</span>
			</a>
		</td>
		</tr>
		</table>
		</cfif>
		</td>
		</tr>	
			
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="#application.adminBundle[session.dmProfile.locale].OK#" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="#application.adminBundle[session.dmProfile.locale].cancel#" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#';parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		</td>
	</tr>
			
	</table>
	</form>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("imageForm");
		objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
		objForm.alt.validateLengthLT(255);
			
		//bring focus to title
		document.imageForm.title.focus();//-->
	</SCRIPT>
	</cfoutput>
</cfif>	

<cfsetting enablecfoutputonly="no">