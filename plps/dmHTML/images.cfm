 <!--- 
dmnews PLP
 - start (start.cfm)
--->

<cfsetting enablecfoutputonly="no">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags" prefix="tags">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">


<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
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
		<cfset imageAcceptList = "image/pjpeg,image/gif,image/png,image/jpg,image/jpeg"> 
		<cfif trim(len(form.imageFile)) NEQ 0 AND form.imageFile NEQ form.imageFile_old>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfscript>
			stProperties.imageFile = stReturn.ServerFile;
			stProperties.originalImagePath = stReturn.ServerDirectory;
		</cfscript>
	</cfif>
	
	<cfif trim(len(FORM.optimisedImage)) NEQ 0 AND form.optimisedImage NEQ form.optimisedImage_old>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
			
		<cfscript>
			stProperties.optimisedFile = stReturn.ServerFile;
			stProperties.optimisedImagePath = stReturn.ServerDirectory;
		</cfscript>
	</cfif>
	<cfif trim(len(FORM.thumbnailImage)) NEQ 0 AND form.thumbnailImage NEQ form.thumbnailImage_old>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="thumbnailImage" destination="#application.defaultImagePath#" accept="#imageAcceptList#"> 
		<cfscript>
			stProperties.thumbnailFile = stReturn.ServerFile;
			stProperties.thumbnailImagePath = stReturn.ServerDirectory;
		</cfscript>
	</cfif>

		
		<cfscript>
			typeName = "dmImage";
		</cfscript>
		<!--- if form.editfile exists - then an existing object is being edited - else must create new object --->
		
		<cfif isDefined("form.editObject")>
			
			<q4:contentobjectdata typename="#application.fourq.packagepath#.types.#typeName#" stProperties="#stProperties#"
	 objectid="#stProperties.objectID#">
		<cfelse>
			<q4:contentobjectcreate  typename="#application.fourq.packagepath#.types.#typeName#" stproperties="#stProperties#" r_objectid="NewObjID">
		</cfif>
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


<cfoutput><div class="FormSubTitle">#output.label#</div></cfoutput>
<div class="FormTitle">Images</div>

<cfif isDefined("msg")>
	<span class="FormLabel"><cfoutput>#msg#</cfoutput></span>
</cfif>

<cftrace inline="true" text="Completed plpNavigationMove">

<cfif NOT thisstep.isComplete>

<cfif (StructKeyExists(output, "aObjectIDs"))>
	<cfset aFileArray = arrayNew(1)>
	<cfloop from="1" to="#arrayLen(output.aObjectIds)#" index="i">
		<!--- get the objectType --->
		<cfinvoke component="fourq.fourq" returnvariable="typename" method="findType" objectID="#output.aObjectIds[i]#">
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
		<td colspan="5" align="center"><span class="FormSubTitle">Existing Files</span></td> 
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td align="center"><span class="FormLabel">Title</span></td>
		<td><span class="FormLabel">Preview</span></td>
		<td align="center"><span class="FormLabel">Edit</span></td>
		<td align="center"><span class="FormLabel">Delete</span></td>
	</tr>
	<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
		<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
		<tr>
			<td>
				<nj:getFileIcon filename="#stThisFile.imagefile#" r_stIcon="fileicon"> 	
				<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
			</td>
			<td><span class="FormLabel">#left(stThisFile.title,50)#</span></td>
			<td>
			<cfif len(trim(stThisFile.imagefile)) NEQ 0>
				<a href="#application.url.conjurer#?objectid=#stThisFile.objectid#" target="_blank">
					<img src="#application.url.farcry#/navajo/nimages/preview.gif" border="0">
				</a>
			<cfelse>
				<span class="FormLabel">[No file uploaded]</span>	
			</cfif>
			</td>
			<td align="center">
				<a href="javascript:void(0);" onClick="hideAll();toggleForm('#i#_edit','inline');">
					<img src="#application.url.farcry#/navajo/nimages/edit.gif" border="0">
				</a>
			</td>
			<td align="center">
				<input type="checkbox" name="objectID" value="#stThisFile.objectID#">
			</td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="4">&nbsp;</td>
		<td><input name="deleteObject" type="submit" class="normalbttnstyle" style="border:thin" value="delete"></td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<cfelse>
	<cfoutput>
		<table>
			<tr>
				<td>
					<span class="FormLabel">No files have been added to this object</span>
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
</div>
<!--- Output the file edit divs --->
<cfif arrayLen(aFileArray) GT 0>
<cfloop from="1" to="#arrayLen(afileArray)#" index="i">
	<q4:contentobjectget objectid="#aFileArray[i]#" bactiveonly="False" r_stobject="stThisFile">
	<div id="#i#_edit" style="display:none;">
		<form action="" method="post" enctype="multipart/form-data" name="editImageForm">
		
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
	
		<!--- <tr>
			<td colspan="2" nowrap><span class="FormLabel">Caption</span></td>
			<td nowrap><input type="text" name="caption" value="#stThisFile.caption#" class="FormTextBox"></td>
		</tr> --->
	
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
				<input type="hidden" name="thumbailImage_old" value="#stThisFile.thumbnail#">
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
		</form>

</div>
	</cfloop>
</cfif>
<!--- Upload new file DIV --->
<div id="fileform" style="display:none">
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
	
		<!--- <tr>
			<td colspan="2" nowrap><span class="FormLabel">Caption</span></td>
			<td nowrap><input type="text" name="caption" value="" class="FormTextBox"></td>
		</tr> --->
	
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
		</form>
</div>
<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<tags:PLPNavigationButtons>
</form>
</div>

</cfoutput>
<cfelse>	

	
	<tags:plpUpdateOutput>
</cfif>


