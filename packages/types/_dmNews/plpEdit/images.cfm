<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmNews/plpEdit/images.cfm,v 1.8.2.1 2004/02/26 02:44:36 brendan Exp $
$Author: brendan $
$Date: 2004/02/26 02:44:36 $
$Name: milestone_2-1-2 $
$Revision: 1.8.2.1 $

|| DESCRIPTION || 
$Description: dmNews Edit PLP - Adds images as associated objects$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfoutput>
	<script>
	var isIE=document.all?true:false;
	var layers = isIE?document.all.tags("DIV"):null;
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
			if (layers[i].id != 'PLPMoveButtons')
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
		</cfscript>
		
		<!--- upload the original file 	--->
		<cfset imageAcceptList = application.config.image.imagetype>
		 
		<cfif trim(len(form.imageFile)) NEQ 0 AND form.imageFile NEQ form.imageFile_old>
		
		<!--- upload new file (if accept list not specified in config, accept everything) --->
		<cfif len(application.config.image.imagetype)>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfelse>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#"> 
		</cfif>
		
		<cfif stReturn.bsuccess>
			<!--- delete old file --->
			<cftry>
				<cffile action="delete" file="#application.defaultImagePath#/#form.imageFile_old#">
				<cfcatch type="any"></cfcatch>
			</cftry>
			
			<cfscript>
				stProperties.imageFile = stReturn.ServerFile;
				stProperties.originalImagePath = stReturn.ServerDirectory;
			</cfscript>
		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #imageAcceptList# <p></p></cfoutput>
		</cfif>
	</cfif>
	
	<cfif trim(len(FORM.optimisedImage)) NEQ 0 AND form.optimisedImage NEQ form.optimisedImage_old>
		<!--- upload new file (if accept list not specified in config, accept everything) --->
		<cfif len(application.config.image.imagetype)>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfelse>
			<cfinvoke component="#application.packagepath#.farcry.form" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#"> 
		</cfif>
		
		<cfif stReturn.bsuccess>	
			<cfscript>
				stProperties.optimisedImage = stReturn.ServerFile;
				stProperties.optimisedImagePath = stReturn.ServerDirectory;
			</cfscript>
		<cfelse>
			<cfoutput><strong>ERROR:</strong> #stReturn.message#<p>
			Image types that are accepted: #imageAcceptList# <p></p></cfoutput>
		</cfif>
	</cfif>
	
	<cfif trim(len(FORM.thumbnailImage)) NEQ 0 AND form.thumbnailImage NEQ form.thumbnailImage_old>
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
		</cfif>
	</cfif>

		
		<cfscript>
			typeName = "dmImage";
		</cfscript>
		<!--- if form.editfile exists - then an existing object is being edited - else must create new object --->
		
		<cfscript>
			oType = createobject("component", application.types[typeName].typePath);
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
			<nj:deleteObjects lObjectIDs="#form.objectID#" typename="dmImage" rMsg="msg">
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


<cfoutput><div class="FormSubTitle">#output.label#</div>
<div class="FormTitle">Images</div></cfoutput>

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
	<form action="" method="post">
	<table class="borderTable" >
	<tr>
		<td colspan="5" align="center"><span class="FormSubTitle">Existing Images</span></td> 
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td align="center"><span class="FormLabel">Title</span></td>
		<td><span class="FormLabel">Preview</span></td>
		<td align="center"><span class="FormLabel">Edit</span></td>
		<td align="center"><span class="FormLabel">Delete</span></td>
	</tr></cfoutput>
	<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
		<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
		<cfoutput>
		<tr>
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
					<cfoutput><span class="FormLabel">[No image uploaded]</span></cfoutput>
				</cfif> 
				<cfoutput>
			</td>
			<td align="center">
				<a href="javascript:void(0);" onClick="hideAll();toggleForm('#i#_edit','inline');">
					<img src="#application.url.farcry#/images/treeImages/edit.gif" border="0">
				</a>
			</td>
			<td align="center">
				<input type="checkbox" name="objectID" value="#stThisFile.objectID#">
			</td>
		</tr></cfoutput>
	</cfloop>
	<cfoutput>
	<tr>
		<td colspan="4">&nbsp;</td>
		<td><input name="deleteObject" type="submit" class="normalbttnstyle" value="delete"></td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<cfelse>
	<cfoutput>
		<table>
			<tr>
				<td>
					<span class="FormLabel">No images have been added to this object</span>
				</td>
			</tr>
		</table>
	</cfoutput>	
	</cfif>
</cfif>

<cfoutput>
<div id="newfile" style="display:inline;">
<p>
<input type="button" class="normalbttnstyle" onClick="toggleForm('fileform','inline');" value="Upload New Image">
</p>
</div></cfoutput>

<!--- Output the file edit divs --->
<cfif arrayLen(aFileArray) GT 0>
<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
	<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
	<cfoutput>
	<div id="#i#_edit" style="display:none;">
		<form action="" method="post" enctype="multipart/form-data" name="editImageForm_#i#">
		
		<table cellspacing="2" cellpadding="1" border="0" width="400" align="center">
		<tr>
			<td colspan="3"><span class="FormSubHeading">Image Details</span></td>
		</tr>		
		
		<tr>
			<td colspan="2" nowrap><span class="FormLabel">Title:</span></td>
			<td nowrap width="100%"><input type="text" name="title" value="#stThisFile.title#" Class="FormTextBox"></td>
		</tr>
	
		<tr valign="top">
			<td colspan="2" nowrap><span class="FormLabel">Alternate text:</span></td>
			<td nowrap><textarea type="text" name="alt" class="FormTextArea" rows="4">#stThisFile.alt#</textarea></td>
		</tr>
		
		<tr valign="top">
			<td colspan="2" nowrap>&nbsp;</td>
			<td nowrap align="center">		
				<span class="FormLabel">Width:&nbsp;</span><input style="width:40px" type="text" name="width" value="#stThisFile.width#">
				<span class="FormLabel">Height:&nbsp;</span><input style="width:40px" type="text" name="height" value="#stThisFile.height#">
			</td>
		</tr>	
		<tr>
			<td colspan="3"><span class="FormSubHeading">Image Files</td>
		</tr>	
			
		<tr valign="middle">
			<td nowrap><span class="FormLabel">Default Image</span></td>
			<td>&nbsp;</td>
			<td nowrap width="100%">
				<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
				<input type="hidden" name="imageFile_old" value="#stThisFile.imageFile#">
				<cfif NOT len(trim(stThisFile.imageFile)) EQ 0>
					<br><span class="FormLabel">[ file exists ]</span>
				</cfif>
			</td>
		</tr>
	
		<tr valign="middle">
			<td colspan="2" nowrap><span class="FormLabel">Thumbnail</span></td>
			<td nowrap>
				<input type="file" name="thumbnailImage" class="FormFileBox">
				<input type="hidden" name="thumbnailImage_old" value="#stThisFile.thumbnail#">
				<cfif NOT len(trim(stThisFile.thumbnail)) EQ 0>
					<br><span class="FormLabel">[ file exists ]</span>
				</cfif>
			</td>
		</tr>
	
		<tr valign="middle">
			<td colspan="2" nowrap>
				<span class="FormLabel">Highres</span>
			</td>
			<td nowrap>
				<input type="file" name="optimisedImage" class="FormFileBox">
				<input type="hidden" name="optimisedImage_old" value="#stThisFile.optimisedImage#">
				<cfif NOT len(trim(stThisFile.optimisedImage)) EQ 0>
					<br><span class="FormLabel">[ file exists ]</span>
				</cfif>
			</td>
		</tr>
	
	<tr>
		<td colspan="3" align="center">
			<input type="hidden" name="objectID" value="#stThisFile.objectID#">
			<input type="submit" name="editObject" value="OK" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="Button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="hideAll();toggleForm('fileform','none')";>
		</td>
	</tr>
			
		</table>
		<!--- form validation --->
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			objForm = new qForm("editImageForm_<cfoutput>#i#</cfoutput>");
			objForm.title.validateNotNull("Please enter a title");
			objForm.alt.validateLengthGT(512);
			objForm.width.validateNumeric("Width must be numeric");
			objForm.height.validateNumeric("Height must be numeric");
				//-->
			</SCRIPT>
		</form>

</div></cfoutput>
	</cfloop>
</cfif>

<!--- Upload new file DIV --->
<cfoutput><div id="fileform" style="display:none">
<span class="FormTitle">Upload Image</span>
	
	<form action="" method="post" enctype="multipart/form-data" name="imageForm">
		
		<table cellspacing="2" cellpadding="1" border="0" width="400" align="center">
		<tr>
			<td colspan="3"><span class="FormSubHeading">Image Details</span></td>
		</tr>		
		
		<tr>
			<td colspan="2" nowrap><span class="FormLabel">Title:</span></td>
			<td nowrap width="100%"><input type="text" name="title" value="" class="FormTextBox"></td>
		</tr>
	
		<tr valign="top">
			<td colspan="2" nowrap><span class="FormLabel">Alternate text:</span></td>
			<td nowrap><textarea type="text" name="alt" class="FormTextArea" rows="4"></textarea></td>
		</tr>
		
		<tr valign="top">
			<td colspan="2" nowrap>&nbsp;</td>
			<td nowrap align="center">		
				<span class="FormLabel">Width:&nbsp;</span><input style="width:40px" type="text" name="width" value="">
				<span class="FormLabel">Height:&nbsp;</span><input style="width:40px" type="text" name="height" value="">
			</td>
		</tr>	
		<tr>
			<td colspan="3"><span class="FormSubHeading">Image Files</span></td>
		</tr>	
			
		<tr valign="middle">
			<td nowrap><span class="FormLabel">Default Image</span></td>
			<td>&nbsp;</td>
			<td nowrap width="100%">
				<input type="file" name="imageFile" class="FormFileBox">&nbsp;&nbsp;
				<input type="hidden" name="imageFile_old" value="">
			</td>
		</tr>
	
		<tr valign="middle">
			<td colspan="2" nowrap><span class="FormLabel">Thumbnail</span></td>
			<td nowrap>
				<input type="file" name="thumbnailImage" class="FormFileBox">
				<input type="hidden" name="thumbnailImage_old" value="">
			</td>
		</tr>
	
		<tr valign="middle">
			<td colspan="2" nowrap><span class="FormLabel">Highres</span></td>
			<td nowrap>
				<input type="file" name="optimisedImage" class="FormFileBox">
				<input type="hidden" name="optimisedImage_old" value="">
			</td>
		</tr>
			
	<tr>
		<td colspan="3" align="center">
			<input type="submit" name="newObject" value="OK"  class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"  onclick="toggleForm('fileform','none')"; >
		</td>
	</tr>
			
		</table>
		<!--- form validation --->
			<SCRIPT LANGUAGE="JavaScript">
			<!--//
			objForm2 = new qForm("imageForm");
			objForm2.alt.validateLengthGT(512);
			objForm2.title.validateNotNull("Please enter a title");
			objForm2.width.validateNumeric("Width must be numeric");
			objForm2.height.validateNumeric("Height must be numeric");
				//-->
			</SCRIPT>
		</form>
</div>
<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform"></cfoutput>
	<tags:plpNavigationButtons>
<cfoutput></form>
</div>

</cfoutput>
<cfelse>		
	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">