<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmImage/edit.cfm,v 1.62.2.4 2006/02/15 05:17:22 gstewart Exp $
$Author: gstewart $
$Date: 2006/02/15 05:17:22 $
$Name: milestone_3-0-1 $
$Revision: 1.62.2.4 $

|| DESCRIPTION || 
$Description: dmImage edit handler$

|| DEVELOPER ||
$Developer: Guy (guy@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<!--- set up local variables --->
<cfparam name="primaryObjectID" default="">
<cfparam name="form.bLibrary" default="0">
<cfparam name="form.bAutoGenerateThumbnail" default="0">
<cfparam name="form.ownedby" default="">


<cfinvoke  component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lCategoryIds">
	<cfinvokeargument name="objectID" value="#stObj.objectID#"/>
	<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
</cfinvoke>
<cfparam name="errormessage" default="">
<cfset showform=1>

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfset showform=0>
	<cfset error = false>
	
	<cfset oForm = createObject("component","#application.packagepath#.farcry.form")>
	<cfset stProperties = structNew()>
	<cfset stProperties.objectid = stObj.objectid>
	<cfset stProperties.title = form.title>
	<cfset stProperties.label = form.title>
	<cfset stProperties.alt = form.alt>
	<cfset stProperties.bLibrary = form.bLibrary>
	<cfset stProperties.ownedby = form.ownedby>
	<cfset stProperties.bAutoGenerateThumbnail = form.bAutoGenerateThumbnail>

	<cfset stProperties.datetimelastupdated = Now()>
	<cfset stProperties.lastupdatedby = session.dmSec.authentication.userlogin>
	<cfset stProperties.imageFile = stObj.imageFile>
	<cfset stProperties.originalImagePath = stObj.originalImagePath>

	<!--- unlock object --->
	<cfset stProperties.locked = 0>
	<cfset stProperties.lockedBy = "">
	<cfset imageAcceptList = application.config.image.imagetype>

	
	<cfset thisObject = createobject("component", application.types[stObj.typename].typePath)>
	<!--- set accept list --->
	<cfset imageAcceptList = application.config.image.imagetype> 

	<!--- to move and store any image that gets overwriiten --->
	<cfset archiveObject = createobject("component",application.types.dmArchive.typepath)>
	<cfset stFile = StructNew()>
	<cfset stFile.action = "move">
	<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
	<cfset imageUtilsObj.fCreateDefaultDirectories()>
	<!--- TODO: make the serverside file upload into a module or a cfc call instead of duplicating the upload 3 times on the edit handler --->
	<cfif trim(form.defaultImage) NEQ "">
		<!--- upload image --->
		<cftry>
			<cfif len(imageAcceptList)>
				<cffile action="upload" filefield="defaultImage" destination="#application.config.image.folderpath_original#" accept="#imageAcceptList#" nameconflict="makeunique">
			<cfelse>
				<cffile action="upload" filefield="defaultImage" destination="#application.config.image.folderpath_original#" nameconflict="makeunique"> 
			</cfif>	
			<!--- filesize check --->
			<cfif cffile.FileSize GT application.config.image.imagesize>
				<cfthrow errorcode="01" message="Sorry the file you tried to upload exceeds the #application.config.image.imagesize/1024#kb limit.<br />">
			</cfif>
			
			<cfcatch type="any">
				<cfif cfcatch.errorCode EQ "01"> <!--- custom --->
					<cfset errormessage = cfcatch.message>
				<cfelse>
					<cfset subS = listToArray(application.config.image.imagetype)>
					<cfset subS[2] = application.config.image.imagetype>
					<cfset errormessage = application.rb.formatRBString("errBadImageType",subS)>
				</cfif>
				<cfset error = true>
			</cfcatch>
		</cftry>
		
		<cfif error>
			<!--- <cfset subS = listToArray(application.config.image.imagetype)>
			<cfset subS[2] = application.config.image.imagetype>
			<cfset errormessage = application.rb.formatRBString("errBadImageType",subS)> --->
		<cfelse>
			<!--- set poperties to insert into database --->
			<cfset stProperties.imageFile = oForm.sanitiseFileName(cffile.ServerFile,cffile.ClientFileName,cffile.ServerDirectory)>
			<cfset stProperties.originalImagePath = cffile.ServerDirectory>
			
			<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
			<cfset originalImage = stProperties.originalImagePath & "\" & stProperties.imageFile>
			<cfset returnstruct = imageUtilsObj.fGetProperties(originalImage)>
			<cfset stProperties.width = returnstruct.width>
			<cfset stProperties.height = returnstruct.height>
		
			<!--- archive the image if it is overwritten --->
			<cfif StructKeyExists(application.config.image,"archivefiles") AND application.config.image.archivefiles EQ "true" AND stObj.imageFile NEQ "">
				<cfset stFile.sourceDir = "#stObj.originalImagepath#">
				<cfset stFile.sourceFileName = "#stObj.imageFile#">
				<cfset stFile.destinationFileName = "#stObj.objectid#_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
				<cfset stFile.destinationDir = "#application.config.general.archivedirectory##stObj.typename#/">
				<cfset stFile.destinationFileName = "#stObj.objectid#_original_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
				<cfset archiveObject.fMoveFile(stFile)>
			<cfelseif stObj.imageFile NEQ "">
				<cftry>
					<cffile action="delete" file="#stObj.originalImagepath#/#stObj.imageFile#">
					<cfcatch></cfcatch>
				</cftry>
			</cfif>
		</cfif>		
	<cfelseif stobj.imageFile EQ "">
		<cfset errormessage = "Please upload a default image.<br />">
		<cfset error = true>
	</cfif>

	<!--- thumbnail upload/generation --->
	<cfif (NOT error) AND (stProperties.imageFile NEQ "" AND stProperties.bAutoGenerateThumbnail) OR (IsDefined("form.thumbnail_file_upload") AND form.thumbnail_file_upload NEQ "")>

		<!--- archive the image if it is overwritten (note this is done before because it retains the same thumbnail image name) --->
		<cfif StructKeyExists(application.config.image,"archivefiles") AND application.config.image.archivefiles EQ "true" AND stObj.thumbnail NEQ "">
			<cfset stFile.sourceDir = "#stObj.thumbnailImagePath#">
			<cfset stFile.sourceFileName = "#stObj.thumbnail#">
			<cfset stFile.destinationFileName = "#stObj.objectid#_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
			<cfset stFile.destinationDir = "#application.config.general.archivedirectory##stObj.typename#/">
			<cfset stFile.destinationFileName = "#stObj.objectid#_thumbnail_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
			<cfset archiveObject.fMoveFile(stFile)>		
		<cfelseif stObj.thumbnail NEQ "">
			<cftry>
				<cffile action="delete" file="#stObj.thumbnailImagePath#/#stObj.thumbnail#">
				<cfcatch></cfcatch>
			</cftry>
		</cfif>
		
		<cfif stProperties.bAutoGenerateThumbnail>
			<!--- create the thumbnail and default image --->
			<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
			<cfset originalImage = stProperties.originalImagePath & "\" & stProperties.imageFile>
			<cfdirectory action="list" directory="#stProperties.originalImagePath#" filter="#stProperties.imageFile#" name="qList">
			<cfif qList.recordCount>
				<cfset returnstruct = imageUtilsObj.fCreatePresets(imagePreset="thumbnailImage", originalFile="#application.config.image.sourceImagePath#/#stProperties.imageFile#") />
				<cfset stProperties.thumbnail = returnstruct.filename>
				<cfset stProperties.thumbnailImagePath = returnstruct.path>	
			</cfif>
		<cfelse>
			<!--- upload the thumbnail --->
			<cfif len(imageAcceptList)>
				<cffile action="upload" filefield="thumbnail_file_upload" destination="#application.config.image.folderpath_thumbnail#" accept="#imageAcceptList#" nameconflict="makeunique">
			<cfelse>
				<cffile action="upload" filefield="thumbnail_file_upload" destination="#application.config.image.folderpath_thumbnail#" nameconflict="makeunique"> 
			</cfif>

			<cfset stProperties.thumbnail = oForm.sanitiseFileName(cffile.ServerFile,cffile.ClientFileName,cffile.ServerDirectory)>
			<cfset stProperties.thumbnailImagePath = cffile.ServerDirectory>
		</cfif>
	</cfif>

	<!--- check optimised image has been passed in from form --->
	<cfif trim(form.optimisedImage) NEQ "">
		<!--- upload image --->
		<cfif len(imageAcceptList)>
			<cffile action="upload" filefield="optimisedImage" destination="#application.config.image.folderpath_optimised#" accept="#imageAcceptList#" nameconflict="makeunique">
		<cfelse>
			<cffile action="upload" filefield="optimisedImage" destination="#application.config.image.folderpath_optimised#" nameconflict="makeunique"> 
		</cfif>	

		<!--- archive the image if it is overwritten --->
		<cfif StructKeyExists(application.config.image,"archivefiles") AND application.config.image.archivefiles EQ "true" AND stObj.optimisedImage NEQ "">
			<cfset stFile.sourceDir = "#stObj.optimisedImagePath#">
			<cfset stFile.sourceFileName = "#stObj.optimisedImage#">
			<cfset stFile.destinationFileName = "#stObj.objectid#_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
			<cfset stFile.destinationDir = "#application.config.general.archivedirectory##stObj.typename#/">
			<cfset stFile.destinationFileName = "#stObj.objectid#_optimised_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
			<cfset archiveObject.fMoveFile(stFile)>		
		<cfelseif stObj.optimisedImage NEQ "">
			<cftry>
				<cffile action="delete" file="#stObj.optimisedImagePath#/#stObj.optimisedImage#">
				<cfcatch></cfcatch>
			</cftry>
		</cfif>
		
		<!--- set poperties to insert into database --->
		<cfset stProperties.optimisedImage = oForm.sanitiseFileName(cffile.ServerFile,cffile.ClientFileName,cffile.ServerDirectory)>
		<cfset stProperties.optimisedImagePath = cffile.ServerDirectory>
	</cfif>

	<!--- update category --->
	<cfparam name="form.lSelectedCategoryID" default="">
	<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
		<cfinvokeargument name="objectID" value="#stObj.objectID#"/>
		<cfinvokeargument name="lCategoryIDs" value="#form.lSelectedCategoryID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>
	
	<cfif NOT error>
		<!--- update the OBJECT --->
		<cfset thisObject.setData(stProperties=stProperties)>
	
		<!--- get parent to update tree --->
		<nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">		
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">
<cfif primaryObjectID NEQ "">
	<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
	<cfinclude template="/farcry/core/webtop/includes/json.cfm">
	
	<cfset objplp = CreateObject("component","#application.packagepath#.farcry.plpUtilities")>
	<cfset objplp.fAddArrayObjects(primaryObjectID,stObj.objectid)>
	<cfset arItems = objplp.fGenerateObjectsArray(primaryObjectID,libraryType)>
<cfoutput><script type="text/javascript">
var jsonData = '#jsonencode(arItems)#';
opener.processReqChange#libraryType#(jsonData,'');<cfif form.submit EQ "Insert">
window.close();<cfelse><cfset showform = 1></cfif>
</script></cfoutput>
<cfelse>		
	<!--- reload overview page ---><cfoutput>
	<script type="text/javascript">
	// check if edited from Content or Site (via sidetree)
	if(parent['sidebar'].frames['sideTree']){
		parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
		parent['content'].location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#";
	}
	else
		parent['content'].location.href = "#application.url.farcry#/content/#lcase(stObj.typename)#.cfm";
	</script></cfoutput>
</cfif>		
	<cfelse>
		<cfset showform=1>
	</cfif>
<cfelse> <!--- first entry --->
	<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
		<cfinvokeargument name="objectID" value="#stObj.objectID#"/>
		<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
	</cfinvoke>
</cfif>
<cfset objImage = createobject("component", application.types[stObj.typename].typePath)>
 <!--- Show the form --->
<cfif showform>
	<cfoutput>
<script type="text/javascript">
function fCancelAction(){<cfif primaryObjectID NEQ "">
	window.close();<cfelse>
	// check if edited from Content or Site (via sidetree)
	if(parent['sidebar'].frames['sideTree']){
		parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
		parent['content'].location.href = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#";
	}
	else
		parent['content'].location.href = "#application.url.farcry#/content/#stObj.typename#.cfm";</cfif>
}

function tgl_thumbnail(){
	objForm = document.forms.imageForm;
	objCheck = objForm.bAutoGenerateThumbnail;
	objThumbnailFileUpload = objForm.thumbnail_file_upload;
	if(objCheck.checked)
		objThumbnailFileUpload.disabled = true;
	else
		objThumbnailFileUpload.disabled = false;

}
</script>

<form name="imageForm" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-1 wider f-bg-long" enctype="multipart/form-data" onsubmit="return doSubmit(document['forms']['imageForm']);">
	<fieldset>
		<div class="req"><b>*</b>Required</div>
		<h3>#apapplication.rb.getResource("imageDetails")#...</h3>
		<cfif isDefined("errormessage")>
			<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>			
		</cfif>
		<label for="title"><b>#apapplication.rb.getResource("titleLabel")#<span class="req">*</span></b>
			<input type="text" name="title" id="title" value="#stObj.title#" /><br />
		</label>
		
		<label for="alt"><b>#apapplication.rb.getResource("alternateTextLabel")#</b>
			<textarea type="text" name="alt" rows="4">#stObj.alt#</textarea><br />
		</label>
		<!--- TODO: make the dafault and optimised image uploads use the fileupload widget --->
		<cfif application.config.image.bAllowOverwrite EQ "true" OR trim(stObj.imageFile) EQ "">
		<label for="defaultImage"><b>#apapplication.rb.getResource("defaultImage")#:<span class="req">*</span></b>
			<input type="file" name="defaultImage" id="defaultImage" /><br />
		</label><cfelse><input type="hidden" name="defaultImage" value="" /><br /></cfif>
		<cfif len(stObj.imagefile)>
		<label>
			<cfif application.config.image.bAllowOverwrite EQ "false">
			Sorry you are not allowed to overwrite this file, please delete it and reupload OR change the image config settings in the admin<br />
			<cfelse>
			#apapplication.rb.getResource("newFileOverwriteThisFile")#<br />
			</cfif>
			<b>#apapplication.rb.getResource("existingDefaultImageLabel")#</b>
			<a href="#objImage.getURLImagePath(stObj.objectID,'original')#" title="#apapplication.rb.getResource("previewUC")#" target="_blank"><img src="#objImage.getURLImagePath(stObj.objectID,'thumb')#" border="0" width="#application.config.image.thumbnailWidth#" height="#application.config.image.thumbnailHeight#"></a>
		</label>
		</cfif>
		
		<label for="bAutoGenerateThumbnail" onclick="tgl_thumbnail()"><b>Auto-Generate Thumbnail:</b>
			<input type="checkbox" name="bAutoGenerateThumbnail" id="bAutoGenerateThumbnail" value="1"<cfif stObj.bAutoGenerateThumbnail EQ 1>checked="checked"</cfif>>&nbsp;generate thumbnail based on default image<br />
		</label>		

</cfoutput>
			<widgets:fileUpload uploadType="image" fieldValue="#stObj.thumbnail#" fileFieldPrefix="thumbnail" fieldLabel="Upload Thumbnail:">
<cfoutput>

		<cfif application.config.image.bAllowOverwrite EQ "true" OR trim(stObj.optimisedimage) EQ "">
		<label for="optimisedImage"><b>#apapplication.rb.getResource("Highres")#:</b>
			<input type="file" name="optimisedImage" /><br />
		</label><cfelse><input type="hidden" name="optimisedImage" value="" /><br /></cfif>
		

		<cfif len(stObj.optimisedimage)>
		<label>
			<cfif application.config.image.bAllowOverwrite EQ "false">
			Sorry you are not allowed to overwrite this file, please delete it and reupload OR change the image config settings in the admin<br />
			<cfelse>
			#apapplication.rb.getResource("newFileOverwriteThisFile")#<br />
			</cfif>
			Existing High Resolution Image:
			<a href="#objImage.getURLImagePath(stObj.objectID,'optimised')#" target="_blank">#apapplication.rb.getResource("previewUC")#</a>
		</label>
		</cfif>

		<fieldset class="f-checkbox-wrap">
			<b>Image Library:</b>
			<fieldset>
				<label for="bLibrary">
					<input id="bLibrary" type="checkbox" class="f-checkbox" name="bLibrary" value="1" <cfif stObj.bLibrary EQ 1>checked="checked"</cfif> />&nbsp;Add to image library
					<br />
				</label>
			</fieldset>
		</fieldset>
</cfoutput>
		<widgets:ownedBySelector fieldLabel="Content Owner:" selectedValue="#stObj.ownedBy#">
<cfoutput>
		<fieldset class="f-checkbox-wrap">
			<b>Image&nbsp;Categories:</b>
			<fieldset>
			<widgets:categoryAssociation typeName="#stObj.typename#" lSelectedCategoryID="#lSelectedCategoryID#">
			</fieldset>
			<br />
			</label>		
		</fieldset>
		
	<div class="f-submit-wrap"><cfif primaryObjectID NEQ "">
		<input type="Submit" name="Submit" value="Insert" class="f-submit" />
		<input type="Submit" name="Submit" value="Insert &amp; Upload Another" class="f-submit" /><cfelse>
		<input type="Submit" name="Submit" value="#apapplication.rb.getResource("OK")#" class="f-submit">
		<input type="Button" name="Cancel" value="#apapplication.rb.getResource("cancel")#" class="f-submit" onClick="fCancelAction();"></cfif>
	</div>
	
	<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
	<input type="hidden" name="defaultImageFileName" value="">
	<input type="hidden" name="thumbImageFileName" value="">
	<input type="hidden" name="optImageFileName" value="">
	
	</fieldset>	
</form>
<!--- validate form --->
<script type="text/javascript">
function doSubmit(objForm){
	document['forms']['imageForm'].optImageFileName.value = document['forms']['imageForm'].optimisedImage.value;
	document['forms']['imageForm'].defaultImageFileName.value = document['forms']['imageForm'].defaultImage.value;
	// todo: need extra validation here
	return true;
}
</script><hr />
<cfif primaryObjectID EQ "">
<cfinclude template="/farcry/core/webtop/includes/image_tips.cfm">
</cfif>
<cfif Val(stObj.bAutoGenerateThumbnail) EQ 1>
<script type="text/javascript">
objForm = document.forms.imageForm;
objThumbnailFileUpload = objForm.thumbnail_file_upload;
objThumbnailFileUpload.disabled = true;
</script></cfif>
	</cfoutput>
</cfif>	
<cfsetting enablecfoutputonly="no">