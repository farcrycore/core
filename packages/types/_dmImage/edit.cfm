<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>


<cfif isDefined("FORM.submit")> <!--- perform the update --->
		
	<cfscript>
		stProperties = structNew();
		stProperties.title = form.title;
		stProperties.label = form.title;
		//stProperties.caption = form.caption;
		stProperties.alt = form.alt;
		stProperties.width = form.width;
		stProperties.height = form.height;
				
		stProperties.datetimelastupdated = Now();
		stProperties.datetimecreated = Now();
		stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	</cfscript>
	<!--- upload the original file 	--->
	<!--- TODO - need some more error checking here on uploadFile method return --->
	<cfif trim(len(form.imageFile)) NEQ 0>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="imagefile" destination="#application.defaultImagePath#"> 
		<cfif not stReturn.bSuccess>
			<cfdump var="#stReturn#"><cfabort>
		</cfif>
		<cfscript>
			stProperties.imageFile = stReturn.ServerFile;
			stProperties.originalImagePath = stReturn.ServerDirectory;
		</cfscript>
	</cfif>
	
	<cfif trim(len(FORM.optimisedImage)) NEQ 0 >
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="optimisedImage" destination="#application.defaultImagePath#"> 
			
		<cfscript>
			stProperties.optimisedimage = stReturn.ServerFile;
			stProperties.optimisedImagePath = stReturn.ServerDirectory;
		</cfscript>
	</cfif>
	<cfif trim(len(FORM.thumbnailImage)) NEQ 0>
		<cfinvoke component="fourq.utils.form.fileupload" method="uploadFile" returnvariable="stReturn" formfield="thumbnailImage" destination="#application.defaultImagePath#"> 
		<cfif NOT stReturn.bSuccess>
			<!--- Log the error here --->
		<cfelse>
			<cfscript>
				stProperties.thumbnail = stReturn.ServerFile;
				stProperties.thumbnailImagePath = stReturn.ServerDirectory;
			</cfscript>
		</cfif>
	</cfif>
	

	<q4:contentobjectdata
	 typename="#application.packagepath#.types.dmImage"
	 stProperties="#stProperties#"
	 objectid="#stObj.ObjectID#"
	>
	

	<cfoutput>
		<span class="FormTitle">IMAGE UPDATE SUCCESSFUL</span><br>
		<input type="button" value="Close" class="normalBttnStyle" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';">  
	</cfoutput>
	
	<nj:TreeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
	<nj:updateTree objectId="#parentID#" complete="0">
<cfelseif isDefined("FORM.cancel")> <!--- update was cancelled --->

	<span class="FormTitle">Operation has been cancelled</span>
	
<cfelse> <!--- Show the form --->


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
	
		<!--- <tr>
			<td nowrap><span class="FormLabel">Caption</span></td>
			<td nowrap>
				<input type="text" name="caption" value="#stObj.caption#" class="FormTextBox">
			</td>
		</tr> --->
	
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
			<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
		</td>
		<td>
			<a href="#application.url.conjurer#?objectid=#stObj.objectid#" target="_blank">
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
			<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
		</td>
		<td>
			<a href="#stObj.thumbnailImagePath#\#stObj.thumbnail#" target="_blank">
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
			<img src="#application.url.farcry#/navajo/nimages/#fileicon#">
		</td>
		<td>
			<a href="#stObj.optimisedImagePath#\#stObj.optimisedimage#" target="_blank">
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
			<input type="submit" value="Cancel" name="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
		</td>
	</tr>
			
		</table>
		</form>
	</cfoutput>
</cfif>	