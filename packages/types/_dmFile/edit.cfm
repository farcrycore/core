<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/edit.cfm,v 1.57 2005/09/23 07:06:24 guy Exp $
$Author: guy $
$Date: 2005/09/23 07:06:24 $
$Name: milestone_3-0-0 $
$Revision: 1.57 $

|| DESCRIPTION || 
$Description: dmFile edit handler$

|| DEVELOPER ||
$Developer: Guy (guy@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

<!--- local variables --->
<cfset localeMonths=application.thisCalendar.getMonths(session.dmProfile.locale)>
<cfparam name="primaryObjectID" default="">
<cfparam name="form.bLibrary" default="0">
<cfparam name="errormessage" default="">

<!--- lock the content item for editing --->
<cfif NOT stobj.locked>
	<cfset setlock(locked="true")>
</cfif>

<cfset showform=1>
<cfif isDefined("FORM.submit")> <!--- perform the update --->
	<cfset showform=0>
	<cfscript>
	stProperties = structNew();
	StProperties.objectid = stObj.objectid;
	stProperties.title = form.title;
	stProperties.label = form.title;
	stProperties.bLibrary = form.bLibrary;
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

	<cfset thisObject = createobject("component", application.types[stObj.typename].typePath)>
	<!--- update category --->
	<cfparam name="form.lSelectedCategoryID" default="">
	<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories" returnvariable="stStatus">
		<cfinvokeargument name="objectID" value="#stObj.objectID#"/>
		<cfinvokeargument name="lCategoryIDs" value="#form.lSelectedCategoryID#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>

	<!--- upload the original file 	--->
	<cfif trim(FORM.filename) NEQ "">
		<!--- if accept list not specified in config, accept everything --->
		<cftry>
			<cfif len(application.config.file.filetype)>
				<cffile action="upload" filefield="filename" accept="#application.config.file.filetype#" destination="#application.path.defaultFilePath#" nameconflict="#application.config.general.fileNameConflict#">
			<cfelse>
				<cffile action="upload" filefield="filename" destination="#application.path.defaultFilePath#"  nameconflict="#application.config.general.fileNameConflict#"> 
			</cfif>

			<!--- filesize check --->
			<cfif cffile.FileSize GT application.config.file.filesize>
				<cfthrow errorcode="01" message="Sorry the file you tried to upload exceeds the #application.config.file.filesize/1024#kb limit.<br />">
			</cfif>

			<!--- archive the file if file is overwritten --->
			<cfif StructKeyExists(application.config.file,"archivefiles") AND application.config.file.archivefiles EQ "true" AND stObj.fileName NEQ "">
				<cfset archiveObject = createobject("component",application.types.dmArchive.typepath)>
				<cfset stFile = StructNew()>
				<cfset stFile.action = "move">
				<cfset stFile.sourceDir = "#stObj.filepath#">
				<cfset stFile.sourceFileName = "#stObj.fileName#">
				<cfset stFile.destinationFileName = "#stObj.objectid#_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
				<cfset stFile.destinationDir = "#application.config.general.archivedirectory##stObj.typename#/">
				<cfset stFile.destinationFileName = "#stObj.objectid#_#dateformat(Now(),'yyyymmdd')#_#timeformat(Now(),'HHMMSS')#.#ListLast(stFile.sourceFileName,'.')#">
				<cfset archiveObject.fMoveFile(stFile)>
			</cfif>

			<cfset stProperties.filename = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
			<cfset stProperties.filepath = file.ServerDirectory>
			<cfset stProperties.fileSize = file.fileSize>
			<cfset stProperties.fileType = file.contentType>
			<cfset stProperties.fileSubType = file.contentSubType>
			<cfset stProperties.fileExt = file.serverFileExt>
			
			<cfcatch type="any">
				<cfif cfcatch.errorCode EQ "01"> <!--- custom --->
					<cfset errormessage = cfcatch.message>
				<cfelse>
					<cfset subS = listToArray("#cfcatch.message#,#application.config.file.filetype#")>
					<cfset errormessage = application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].acceptableFileTypes,subS)>
				</cfif>
				<cfset error = 1>
			</cfcatch>
		</cftry>
	<cfelseif trim(stObj.filename) EQ ""> <!--- set the files size to 0 if no file is uploaded --->
		<cfset stProperties.fileSize = 0>
	</cfif>

	<cfif not isdefined("error")>
	<cfset thisObject.setData(stProperties)>

		<!--- get parent to update tree --->
		<nj:treeGetRelations 
			typename="#stObj.typename#"
			objectId="#stObj.ObjectID#"
			get="parents"
			r_lObjectIds="ParentID"
			bInclusive="1">
		
		<!--- update tree --->
		<nj:updateTree objectId="#parentID#">

		<cfif primaryObjectID NEQ "">
			<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
			<cfinclude template="/farcry/farcry_core/admin/includes/json.cfm">
			
			<cfset objplp = CreateObject("component","#application.packagepath#.farcry.plpUtilities")>
			<cfset objplp.fAddArrayObjects(primaryObjectID,stObj.objectid)>
			<cfset arItems = objplp.fGenerateObjectsArray(primaryObjectID,libraryType)>
<cfoutput><script language="JavaScript">
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
		parent['content'].location.href = "#application.url.farcry#/content/#stObj.typename#.cfm";
	</script></cfoutput>
		</cfif>
	<cfelse>
		<cfset showform=1>
	</cfif>
<cfelse>
	<cfinvoke component="#application.packagepath#.farcry.category" method="getCategories" returnvariable="lSelectedCategoryID">
		<cfinvokeargument name="objectID" value="#stObj.objectID#"/>
		<cfinvokeargument name="bReturnCategoryIDs" value="true"/>
	</cfinvoke>
</cfif>

<cfif showform> <!--- Show the form --->	
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
</script>	
<form name="fileForm" action="" method="post" class="f-wrap-1 f-bg-long" enctype="multipart/form-data">
	<fieldset>
	<cfif errormessage NEQ "">
		<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
	</cfif>
		<div class="req"><b>*</b>Required</div>
		<h3>#application.adminBundle[session.dmProfile.locale].fileUploadDetails#...</h3>
		<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
			<input id="title" name="title" type="text" value="#stObj.title#" tabindex="1" /><br />
		</label>
		<label for="publishDay"><b>#application.adminBundle[session.dmProfile.locale].datePublishedLabel#</b>
			<select name="publishDay" id="publishDay"><cfloop from="1" to="31" index="i">
				<option value="#i#" <cfif i IS day(stObj.documentDate)>selected="selected"</cfif>>#i#</option></cfloop>
			</select>
			<select name="publishMonth"><cfloop from="1" to="12" index="i">
				<option value="#i#" <cfif i IS month(stObj.documentDate)>selected="selected"</cfif>>#localeMonths[i]#</option></cfloop>
			</select><cfscript>thisYear = year(now()); startYear = 2000; endYear = year(dateadd("yyyy",7,now()));	</cfscript>
			<select name="publishYear"><cfloop from="#startYear#" to="#endYear#" index="i">
				<option value="#i#" <cfif i IS year(stObj.documentDate)>selected="selected"</cfif>>#i#</option></cfloop>
			</select><br />
			<select name="publishHour" style="margin: 10px 10px 0 108px"><cfloop from="0" to="23" index="i">
				<option value="#i#" <cfif hour(stObj.documentDate) IS i>selected="selected"</cfif>>#i# #application.adminBundle[session.dmProfile.locale].hrs#</option>						</cfloop>
			</select>
			<select name="publishMinutes" style="margin: 10px 0 0"><cfloop from="0" to="45" index="i" step="15">
				<option value="#i#" <cfif minute(stObj.documentDate) IS i>selected="selected"</cfif>>#i# #application.adminBundle[session.dmProfile.locale].mins#</option>						</cfloop>
			</select><br />
		</label>
		
		<cfif application.config.file.bAllowOverwrite EQ "true" OR trim(stObj.filename) EQ "">
		<label for="file"><b>#application.adminBundle[session.dmProfile.locale].fileLabel#<span class="req">*</span></b>
			<input id="file" name="filename" type="file" tabindex="3" /><br />
		</label><cfelse><input type="hidden" name="filename" value=""><br /></cfif>
		
		<cfif Len(stObj.filename)>
		<label>
		<cfif application.config.image.bAllowOverwrite EQ "false">
				Sorry you are not allowed to overwrite this file, please delete it and reupload OR change the file config settings in the admin<br />
		<cfelse>
				#application.adminBundle[session.dmProfile.locale].newFileOverwriteThisFile#<br />
		</cfif>
		<b>#application.adminBundle[session.dmProfile.locale].existingFileLabel#</b>
		<nj:getFileIcon filename="#stObj.filename#" r_stIcon="fileicon">
		<a href="#application.url.webroot#/files/#stObj.filename#" target="_blank">#application.adminBundle[session.dmProfile.locale].previewUC#</a> (#stObj.filename#)
		</label>
		</cfif>
		
		<label for="description"><b>#application.adminBundle[session.dmProfile.locale].descLabel#</b>
			<textarea cols="30" rows="4" name="description" id="description" class="f-comments">#stObj.description#</textarea><br />
		</label>
	
			<fieldset class="f-checkbox-wrap">
				<b>File Library:</b>
				<fieldset>
					<label for="bLibrary">
						<input id="bLibrary" type="checkbox" class="f-checkbox" name="bLibrary" value="1" <cfif stObj.bLibrary EQ 1>checked</cfif> />Add to file library
					</label>
				</fieldset>
			</fieldset>
			
			<fieldset class="f-checkbox-wrap">
				<b>File Categories:</b>
				<fieldset>
				<widgets:categoryAssociation typeName="#stObj.typename#" lSelectedCategoryID="#lSelectedCategoryID#">
				</fieldset>
			</fieldset>
				
		<div class="f-submit-wrap"><cfif primaryObjectID NEQ "">
			<input type="Submit" name="Submit" value="Insert" class="f-submit" />
			<input type="Submit" name="Submit" value="Insert &amp; Upload Another" class="f-submit" /><cfelse>
			<input type="Submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].OK#" class="f-submit">
			<input type="Button" name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" class="f-submit" onClick="fCancelAction();"></cfif>
		</div>
		
		<input type="hidden" name="primaryObjectID" value="#primaryObjectID#">
		
	</fieldset>
</form>
<!--- validate form --->
<script type="text/javascript">
	<!--//
	objForm = new qForm("fileForm");
	qFormAPI.errorColor="##cc6633";
	objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
	<cfif NOT len(stObj.filename)>
		objForm.filename.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterFile#");
	</cfif>
	//-->
</script>
<hr />
<cfif primaryObjectID EQ "">
<cfinclude template="/farcry/farcry_core/admin/includes/file_tips.cfm">
</cfif>
</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">
