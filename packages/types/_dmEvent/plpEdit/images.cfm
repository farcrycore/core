<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/images.cfm,v 1.17.2.1 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.17.2.1 $

|| DESCRIPTION || 
$Description: Adds images as associated objects$
$TODO: clean up formatting -- test in Mozilla 20030503 GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">


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

	</script>
</cfoutput>

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
				stProperties.createdby = session.dmSec.authentication.userlogin;
			}	
			stProperties.title = form.title;
			stProperties.label = form.title;
			//stProperties.caption = form.caption;
			stProperties.alt = form.alt;
			stProperties.width = form.width;
			stProperties.height = form.height;
			stProperties.datetimelastupdated = Now();
			stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
			
			oImage = createobject("component", application.types.dmImage.typePath);
			oForm = createObject("component","#application.packagepath#.farcry.form");
			imageAcceptList = application.config.image.imagetype;
		</cfscript>

		<!--- check default image has been passed in from form --->
		<cfif trim(len(form.imageFile)) NEQ 0>	
			<!--- check if it's a new image --->
			<cfif len(form.imageFile_old)>		
				<!--- overwriting an existing image so check if new file has the same name as existing file--->
				<cfif form.imageFile_old eq form.defaultImageFileName>
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
						<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#form.imageFile_old#">
						
						<cfcatch>
							<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
							<cfset error=1>
						</cfcatch>
					</cftry>
				</cfif>			
			<cfelse>
				<!--- new image so check if filename is already in use --->
				<cfset stCheckDefault = oImage.checkForExisting(filename=form.defaultImageFileName)>
				
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
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].imageFileInUseError,'#stCheckDefault.fileName#')#</cfoutput>
					<cfset error=1>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- check optimised image has been passed in from form --->
		<cfif trim(len(form.optimisedImage)) NEQ 0>	
			<!--- check if it's a new image --->
			<cfif len(form.optimisedImage_old)>		
				<!--- overwriting an existing image so check if new file has the same name as existing file--->
				<cfif form.optimisedImage_old eq form.optImageFileName>
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
						<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#form.optimisedImage_old#">
						
						<cfcatch>
							<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
							<cfset error=1>
						</cfcatch>
					</cftry>
				</cfif>			
			<cfelse>
				<!--- new image so check if filename is already in use --->
				<cfset stCheckOptimised = oImage.checkForExisting(filename=form.optImageFileName)>
				
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
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].imageFileInUseError,'#stCheckOptimised.fileName#')#</cfoutput>
					<cfset error=1>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- check thumbnail image has been passed in from form --->
		<cfif trim(len(form.thumbnailImage)) NEQ 0>	
			<!--- check if it's a new image --->
			<cfif len(form.thumbnailImage_old)>		
				<!--- overwriting an existing image so check if new file has the same name as existing file--->
				<cfif form.thumbnailImage_old eq form.thumbImageFileName>
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
						<cffile action="RENAME" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#form.thumbnailImage_old#">
						
						<cfcatch>
							<cfoutput><p>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfCatchErrorMsg,'#cfcatch.message#')#</p></cfoutput>
							<cfset error=1>
						</cfcatch>
					</cftry>
				</cfif>			
			<cfelse>
				<!--- new image so check if filename is already in use --->
				<cfset stCheckThumb = oImage.checkForExisting(filename=form.thumbImageFileName)>
				
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
					<cfoutput>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].imageFileInUseError,'#stCheckThumb.fileName#')#</cfoutput>
					<cfset error=1>
				</cfif>
			</cfif>
		</cfif>

		<!--- if form.editfile exists - then an existing object is being edited - else must create new object --->
		
		<cfscript>
			if (isdefined("form.editObject")) {
				// update the OBJECT	
				oImage.setData(stProperties=stProperties);
			} else {
				// create the new OBJECT
				stNewObj = oImage.createData(stProperties=stProperties);
				NewObjID = stNewObj.objectid;
			}
		</cfscript>
	</cfcase>
	<cfcase value="deleteObject">
		<cfif isDefined("form.objectID")>
			<!--- delete them from the database --->
			<nj:deleteObjects lObjectIDs="#form.objectID#" typename="dmImage" rMsg="msg">
			<cfloop list="#form.objectID#" index="objectID">
				<cfloop index="i" from="#arrayLen(output.aObjectIds)#" to="1" step="-1">
					<cfif output.aObjectIds[i] is objectId>
						<cfset ArrayDeleteAt(output.aObjectIds, i )>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset msg = "#application.adminBundle[session.dmProfile.locale].noObjSelectedForDeletion#">	
		</cfif>	
	</cfcase>
	<cfdefaultcase>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>


<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].images#</div></cfoutput>

<cfif isDefined("msg")>
	<cfoutput><span class="FormLabel">#msg#</span></cfoutput>
</cfif>

<cfif NOT thisstep.isComplete>

	<cfif (StructKeyExists(output, "aObjectIDs"))>
		<cfset aFileArray = arrayNew(1)>
		<cfloop from="1" to="#arrayLen(output.aObjectIds)#" index="i">
			<!--- get the objectType --->
			<cfinvoke component="farcry.fourq.fourq" returnvariable="typename" method="findType" objectID="#output.aObjectIds[i]#">
			<cfif typename IS "dmImage">
				<cfscript>
					arrayAppend(aFileArray,output.aObjectIds[i]);
				</cfscript>
			</cfif>
		</cfloop>
		<cfif arrayLen(aFileArray) GT 0>
			<cfoutput>
			<form action="" method="post" name="test">
			<table class="borderTable" >
			<tr>
				<td colspan="5" align="center"><span class="FormSubTitle">#application.adminBundle[session.dmProfile.locale].existingImages#</span></td> 
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].title#</span></td>
				<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].preview#</span></td>
				<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].edit#</span></td>
				<td align="center"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].delete#</span></td>
			</tr></cfoutput>
			<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
				<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
				<cfoutput><tr>
					<td></cfoutput>
						<!---$ole: check to see if any images exist$ --->
						<cfif len(trim(stThisFile.imagefile)) NEQ 0>
							<nj:getFileIcon filename="#stThisFile.imagefile#" r_stIcon="fileicon"> 	
						<cfelseif len(trim(stThisFile.thumbnail)) NEQ 0>
							<nj:getFileIcon filename="#stThisFile.thumbnail#" r_stIcon="fileicon"> 	
						<cfelseif len(trim(stThisFile.optimisedImage)) NEQ 0>
							<nj:getFileIcon filename="#stThisFile.optimisedImage#" r_stIcon="fileicon"> 
						</cfif>
						<cfif isDefined("fileicon")>
							<cfoutput><img src="#application.url.farcry#/images/treeImages/#fileicon#"></cfoutput>
						<cfelse>
							<cfoutput><img src="#application.url.farcry#/images/treeImages/unknown.gif"></cfoutput>
						</cfif>
						<cfoutput>
					</td>
					<td><span class="FormLabel">#left(stThisFile.title,50)#</span></td>
					<td align="center"></cfoutput>
						<!---$ole: check to see if any images exist to preview$ --->
						<cfif len(trim(stThisFile.imagefile)) NEQ 0 OR len(trim(stThisFile.thumbnail)) NEQ 0 OR len(trim(stThisFile.optimisedImage)) NEQ 0>
							<cfoutput><a href="#application.url.conjurer#?objectid=#stThisFile.objectid#" target="_blank"><img src="#application.url.farcry#/images/treeImages/preview.gif" border="0"></a></cfoutput>
						 <cfelse>
							<cfoutput><span class="FormLabel">[#application.adminBundle[session.dmProfile.locale].noImageUploaded#]</span></cfoutput>
						</cfif> 
					<cfoutput>
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
				<td><input name="deleteObject" type="submit" class="normalbttnstyle" value="#application.adminBundle[session.dmProfile.locale].delete#" /></td>
			</tr>
			</table>
			</form>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<table>
					<tr>
						<td>
							<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].noImagesAddedToObj#</span>
						</td>
					</tr>
				</table>
			</cfoutput>	
		</cfif>
	</cfif>

	<cfoutput>
	<div id="newfile" style="display:inline;">
	<p>
	<input type="button" class="normalbttnstyle" onClick="toggleForm('fileform','inline');" value="#application.adminBundle[session.dmProfile.locale].uploadNewImage#">
	</p>
	</div></cfoutput>
	<!--- Output the file edit divs --->
	<cfif arrayLen(aFileArray) GT 0>
		<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
			<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
			<cfoutput>
			<div id="#i#_edit" style="display:none;">
				<form action="" method="post" enctype="multipart/form-data" name="editImageForm_#i#" onsubmit="document['forms']['editImageForm_#i#'].defaultImageFileName.value = document['forms']['editImageForm_#i#'].imageFile.value;document['forms']['editImageForm_#i#'].thumbImageFileName.value = document['forms']['editImageForm_#i#'].thumbnailImage.value;document['forms']['editImageForm_#i#'].optImageFileName.value = document['forms']['editImageForm_#i#'].optimisedImage.value;">
				<input type="hidden" name="defaultImageFileName" value="">
				<input type="hidden" name="thumbImageFileName" value="">
				<input type="hidden" name="optImageFileName" value="">
				<table cellspacing="2" cellpadding="1" border="0" width="400" align="center">
				<tr>
					<td colspan="3"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageDetails#</span></td>
				</tr>		
				
				<tr>
					<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
					<td nowrap width="100%"><input type="text" name="title" value="#stThisFile.title#" Class="FormTextBox"></td>
				</tr>
			
				<tr valign="top">
					<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].alternateTextLabel#</span></td>
					<td nowrap><textarea type="text" name="alt" class="FormTextArea" rows="4">#stThisFile.alt#</textarea></td>
				</tr>
			
				<tr valign="top">
					<td colspan="2" nowrap>&nbsp;</td>
					<td nowrap align="center">		
						<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].widthLabel#&nbsp;</span><input style="width:40px" type="text" name="width" value="#stThisFile.width#">
						<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].heightLabel#&nbsp;</span><input style="width:40px" type="text" name="height" value="#stThisFile.height#">
					</td>
				</tr>	
				<tr>
					<td colspan="3"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageFiles#</td>
				</tr>	
					
				<tr valign="middle">
					<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].defaultImage#</span></td>
					<td>&nbsp;</td>
					<td nowrap width="100%">
						<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
						<input type="hidden" name="imageFile_old" value="#stThisFile.imageFile#">
						<cfif len(trim(stThisFile.imageFile))>
							<br><span class="FormLabel">[ #application.adminBundle[session.dmProfile.locale].fileExists# ]</span>
						</cfif>
					</td>
				</tr>
			
				<tr valign="middle">
					<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].thumbnail#</span></td>
					<td nowrap>
						<input type="file" name="thumbnailImage" class="FormFileBox">
						<input type="hidden" name="thumbnailImage_old" value="#stThisFile.thumbnail#">
						<cfif len(trim(stThisFile.thumbnail))>
							<br><span class="FormLabel">[ #application.adminBundle[session.dmProfile.locale].fileExists# ]</span>
						</cfif>
					</td>
				</tr>
			
				<tr valign="middle">
					<td colspan="2" nowrap>
						<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].Highres#</span>
					</td>
					<td nowrap>
						<input type="file" name="optimisedImage" class="FormFileBox">
						<input type="hidden" name="optimisedImage_old" value="#stThisFile.optimisedImage#">
						<cfif len(trim(stThisFile.optimisedImage))>
							<br><span class="FormLabel">[ #application.adminBundle[session.dmProfile.locale].fileExists# ]</span>
						</cfif>
					</td>
				</tr>
			
			<tr>
				<td colspan="3" align="center">
					<input type="hidden" name="objectID" value="#stThisFile.objectID#">
					<input type="submit" name="editObject" value="#application.adminBundle[session.dmProfile.locale].OK#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
					<input type="Button" value="#application.adminBundle[session.dmProfile.locale].cancel#" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="hideAll();toggleForm('fileform','none')";>
				</td>
			</tr>
			</table>
			<!--- form validation --->
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			objForm = new qForm("editImageForm_<cfoutput>#i#</cfoutput>");
			objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
			objForm.alt.validateLengthLT(255);
			objForm.width.validateNumeric("#application.adminBundle[session.dmProfile.locale].widthMustBeNumeric#");
			objForm.height.validateNumeric("#application.adminBundle[session.dmProfile.locale].heightMustBeNumeric#");
				//-->
			</SCRIPT>
			</form>
		
			</div></cfoutput>
			</cfloop>
	</cfif>

	<!--- Upload new file DIV --->
	<cfoutput>
	<div id="fileform" style="display:none">
	<span class="FormTitle">#application.adminBundle[session.dmProfile.locale].uploadImage#</span>
		
		<form action="" method="post" enctype="multipart/form-data" name="imageForm" onsubmit="document['forms']['imageForm'].defaultImageFileName.value = document['forms']['imageForm'].imageFile.value;document['forms']['imageForm'].thumbImageFileName.value = document['forms']['imageForm'].thumbnailImage.value;document['forms']['imageForm'].optImageFileName.value = document['forms']['imageForm'].optimisedImage.value;">
			<input type="hidden" name="defaultImageFileName" value="">
			<input type="hidden" name="thumbImageFileName" value="">
			<input type="hidden" name="optImageFileName" value="">
			<table cellspacing="2" cellpadding="1" border="0" width="400" align="center">
			<tr>
				<td colspan="3"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageDetails#</span></td>
			</tr>		
			
			<tr>
				<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].titleLabel#</span></td>
				<td nowrap width="100%"><input type="text" name="title" value="" class="FormTextBox" maxlength="255" size="45"></td>
			</tr>
		
			<tr valign="top">
				<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].alternateTextLabel#</span></td>
				<td nowrap><textarea type="text" name="alt" class="FormTextArea" rows="4"></textarea></td>
			</tr>
				
			<tr valign="top">
				<td colspan="2" nowrap>&nbsp;</td>
				<td nowrap align="center">		
					<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].widthLabel#&nbsp;</span><input style="width:40px" type="text" name="width" value="">
					<span class="FormLabel">#application.adminBundle[session.dmProfile.locale].heightLabel#&nbsp;</span><input style="width:40px" type="text" name="height" value="">
				</td>
			</tr>	
			<tr>
				<td colspan="3"><span class="FormSubHeading">#application.adminBundle[session.dmProfile.locale].imageFiles#</span></td>
			</tr>	
				
			<tr valign="middle">
				<td nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].defaultImage#</span></td>
				<td>&nbsp;</td>
				<td nowrap width="100%">
					<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
					<input type="hidden" name="imageFile_old" value="">
				</td>
			</tr>
		
			<tr valign="middle">
				<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].thumbnail#</span></td>
				<td nowrap>
					<input type="file" name="thumbnailImage" class="FormFileBox">
					<input type="hidden" name="thumbnailImage_old" value="">
				</td>
			</tr>
		
			<tr valign="middle">
				<td colspan="2" nowrap><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].Highres#</span></td>
				<td nowrap>
					<input type="file" name="optimisedImage" class="FormFileBox">
					<input type="hidden" name="optimisedImage_old" value="">
				</td>
			</tr>
				
		<tr>
			<td colspan="3" align="center">
				<input type="submit" name="newObject" value="#application.adminBundle[session.dmProfile.locale].OK#"  class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
				<input type="button" value="#application.adminBundle[session.dmProfile.locale].Cancel#" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"  onclick="toggleForm('fileform','none')"; >
			</td>
		</tr>
		</table>
		<!--- form validation --->
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			objForm2 = new qForm("imageForm");
			objForm2.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
			objForm2.alt.validateLengthLT(255);
			objForm2.width.validateNumeric("#application.adminBundle[session.dmProfile.locale].widthMustBeNumeric#");
			objForm2.height.validateNumeric("#application.adminBundle[session.dmProfile.locale].heightMustBeNumeric#");
				//-->
			</SCRIPT>
		</form>
	</div>
	<div id="PLPButtons" class="FormTableClear">
	<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
		<tags:plpNavigationButtons>
	</form>
	</div></cfoutput>
	
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">