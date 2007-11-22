<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/bulkFileUpload.cfm,v 1.11 2005/09/15 03:10:33 guy Exp $
$Author: guy $
$Date: 2005/09/15 03:10:33 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Uploads contents of a zip file , creates navigation to match directory structure within zip file $
$TODO:$

|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">

<cfparam name="bLibrary" default="0">
<cfparam name="lSelectedCategoryID" default="">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="developer">
	<cfif isDefined("form.submit")>
		<cfoutput>
		<style>
		.success{color:##00cc00}
		.fail{color:##FF0000}
		</style>
		</cfoutput>
		<cfif not len(trim(form.zipFile))>
			<cfoutput>#application.adminBundle[session.dmProfile.locale].noZipSpecified#</cfoutput>
			<cfabort>
		</cfif>
		<cfoutput><b>#application.adminBundle[session.dmProfile.locale].uploadingZip#</b></cfoutput>
		<cfflush>
		<cffile action="upload" filefield="zipFile" destination="#application.path.defaultFilePath#" accept="application/x-zip-compressed,application/zip" nameconflict="#application.config.general.fileNameConflict#"> 
		<cfoutput><span class="success">#application.adminBundle[session.dmProfile.locale].Done#<br></span></cfoutput>
		<cfflush>

		<cfscript>
			filOutStream = createObject("java","java.io.FileOutputStream");					
			bufOutStream = createObject("java","java.io.BufferedOutputStream");
			zipFilePath = application.path.defaultFilePath & "/" & file.serverFile;
			//list of file mime types that can be uploaded
			fileAcceptList = application.config.file.filetype;
			zipFile = createObject("java", "java.util.zip.ZipFile");
			//open zipFile
			zipFile.init(zipFilePath);
			entries = zipFile.entries();
			//Get the data on the starting point in the tree
			qStartingPointData = createObject("component", "#application.packagepath#.farcry.tree").getNode(objectid=application.navid.fileroot);
			//Set the floor for adding folders and files
			iBaseLevel = qStartingPointData.nLevel;
			/*
			Get a query object containing all descendants of the starting point. This query will be used as
			a lookup table for folders. If the folder exists at the correct level than nothing will be done.
			Otherwise the new folder will be created and the lookup table updated
			*/ 
			qStartPointDescendants = createObject("component", "#application.packagepath#.farcry.tree").getDescendants(objectid=qStartingPointData.objectId);
			//Loop through all entries in the zip file
			objCategory = CreateObject("component","#application.packagepath#.farcry.category");
			while(entries.hasMoreElements()) {
				entry = entries.nextElement();
				navigationParentId = qStartingPointData.objectId;
				//create the directories
				if(not structKeyExists(form,"bCreateDirectories") and listLen(entry.getName(), "/")){
					//Loop over all directories in the path and make sure  they exist
					//If they don't exist create them.
					for(i=1;i lte listLen(entry.getName(), "/");i=i+1){
						folderName = listGetAt(entry, i, "/");
						//If it's a filename then don't make a folder out of it
						if(not REFind("\....",folderName)){
							//writeOutput(entry.getName() & "||" & navigationParentId & "<br>");
							sql = "select objectId from qStartPointDescendants where objectName = '#folderName#' and nLevel = " & iBaseLevel+i & " and parentId = '#navigationParentId#'";
							q = queryofquery(sql);
							//dump(q);
							
							if(NOT q.recordcount){
								//Setup the struct of properties for the new dmNavigation node
								writeOutput("<em>Creating dmNavigation Node (#folderName#)</em><br>");
								flush();
								stProps=structNew();
								stProps.objectid = createUUID();
								stProps.label = folderName;
								stProps.title = folderName;
								stProps.lastupdatedby = session.dmSec.authentication.userlogin;
								stProps.datetimelastupdated = Now();
								stProps.createdby = session.dmSec.authentication.userlogin;
								stProps.datetimecreated = Now();
								//create the new dmNavigation object
								oNav = createobject("component", application.types.dmNavigation.typePath);
								stNewObj = oNav.createData(stProperties=stProps);
								//Add the new object into the tree
								createObject("component", "#application.packagepath#.farcry.tree").setYoungest(parentID=navigationParentID,objectID=stProps.objectID,objectName=stProps.label,typeName='dmNavigation');
								//set the navigationParentId for the next folder in the list
								navigationParentId = stNewObj.objectid;
								//Now update the query with this new descendant info
								qStartPointDescendants = createObject("component", "#application.packagepath#.farcry.tree").getDescendants(objectid=qStartingPointData.objectId);
							}
							else
								navigationParentId = q.objectId;
						}
					}
				}

				//Now create the file
				try {
					if (not entry.isDirectory()) {
						sFileName = getFileFromPath(entry.getName());
						sFilePath = application.defaultfilepath;
						oFile = createObject("component", "#application.packagepath#.farcry.file");
						//do we have a mime type match?
						sFileMimeType = oFile.getMimeType(sFileName);
						//If the MIME Type of the file matches any list item in the file accept list
						//if accept list not specified in config, accept everything
						if(listFindNoCase(fileAcceptList, sFileMimeType) OR NOT Len(Trim(fileAcceptList))){						//placeholder for the original filename
							sAbsolutePath = sFilePath & "/" & sFileName;
							
							//Write the file to disk
							filOutStream.init(sAbsolutePath);
							bufOutStream.init(filOutStream);
							inStream = zipFile.getInputStream(entry);
							buffer = repeatString(" ",1024).getBytes(); 
							l = inStream.read(buffer);
							while(l GTE 0){
								bufOutStream.write(buffer, 0, l);
								l = inStream.read(buffer);
							}
							//cleanup
							inStream.close();
							bufOutStream.close();
							filOutStream.close();
							
							//Create structure with new file properties
							flush();
							stFileProps = structNew();
							stFileProps.objectID = createUUID();
							stFileProps.fileName = createObject("component","#application.packagepath#.farcry.form").sanitiseFileName(sFileName,listFirst(sFileName,"."),sFilePath);
							writeOutput("Creating dmFile (#stFileProps.fileName#)<br>");
							flush();
							stFileProps.title = listFirst(stFileProps.fileName,".");
							stFileProps.label = listFirst(stFileProps.fileName,".");
							stFileProps.filePath = sFilePath;
							stFileProps.fileType = listFirst(sFileMimeType,"/");
							stFileProps.fileSubType = listLast(sFileMimeType,"/");
							stFileProps.fileExt = listLast(stFileProps.fileName,".");
							stFileProps.filesize = entry.getSize();
							stFileProps.datetimecreated = Now();
							stFileProps.documentDate = createODBCDate(now());
							stFileProps.createdby = session.dmSec.authentication.userlogin;
							stFileProps.datetimelastupdated = Now();
							stFileProps.lastupdatedby = session.dmSec.authentication.userlogin;
							stFileProps.bLibrary = bLibrary;
							//Create the file object
							createobject("component", application.types.dmFile.typePath).createData(stProperties=stFileProps);
							// assign category
							objCategory.assignCategories(objectid=stFileProps.objectID,lCategoryIDs=lSelectedCategoryID);
							//Add the new file under it's nav parent
							oParentNav = createobject("component", application.types.dmNavigation.typePath);
							stParent = oParentNav.getData(navigationParentID);
							arrayAppend(stParent.aObjectIds, stFileProps.objectId);
							stParent.dateTimeCreated =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
							stParent.dateTimeLastUpdated = createODBCDate(now());
							oParentNav.setData(stProperties=stParent);
						}
						else {
							writeOutput("<span class=""fail"">Skipping &quot;#entry.getName()#&quot;. NOT an acceptable file MIME type (#sFileMimeType#)</span><br>");
							flush();
						}
					}
				} //end try
				
				catch(Any Expr) {
					writeOutput("<span class=""fail"">Error: &quot;#entry.getName()#&quot; could not be uploaded to the server</span><br>");
					flush();
				}
			}
			zipFile.close();
		</cfscript>
		<!--- Cleanup the uploaded zip file --->
		<cffile action="delete" file="#zipFilePath#">
		<cfoutput><span class="success"><strong>#application.adminBundle[session.dmProfile.locale].Done#</strong></span><br></cfoutput>

	<cfelse>
		<!--- Get all of the nodes under the fileRoot --->
		<cfscript>
		o = createObject("component", "#application.packagepath#.farcry.tree");
		qNodes = o.getDescendants(dsn=application.dsn, objectid=application.navid.fileroot);
		</cfscript>
		
		<!--- Show the form --->
		<cfoutput>
		
	<form method="post" class="f-wrap-1 f-bg-medium wider" action="" name="fileForm" enctype="multipart/form-data">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].bulkUpload#</h3>
		
		<fieldset class="f-checkbox-wrap">
			<fieldset>
			<widgets:categoryAssociation typeName="dmFile" lSelectedCategoryID="">
			</fieldset>
			<br />
			</label>		
		</fieldset>
		
		<!--- <label for="startPoint"><b>#application.adminBundle[session.dmProfile.locale].recreateFileStructure#</b>
		<select name="startPoint" id="startPoint">
		<option value="#application.navid.fileroot#">#application.adminBundle[session.dmProfile.locale].fileRoot#</option>
		<cfloop query="qNodes">
		<option value="#qNodes.objectId#" <cfif qNodes.objectId eq application.navid.fileroot>selected="selected"</cfif>>#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
		</cfloop>
		</select><br />
		</label> --->
		
		<label for="zipFile"><b>#application.adminBundle[session.dmProfile.locale].zipFile#</b>
		<input type="File" accept="application/x-zip-compressed" name="zipFile" id="zipFile" /><br />
		</label>
		
		<fieldset class="f-checkbox-wrap">
			<b>File Library:</b>
			<fieldset>
				<label for="bLibrary">
					<input id="bLibrary" type="checkbox" class="f-checkbox" name="bLibrary" value="1" />&nbsp;Add to file library
					<br />
				</label>
			</fieldset>
		</fieldset>
		
		<!--- <fieldset class="f-checkbox-wrap">
		
			<b>dmNavigation nodes</b>
			
			<fieldset>
			
			<label for="bCreateDirectories">
			<input type="checkbox" name="bCreateDirectories" value="0" class="f-checkbox"> #application.adminBundle[session.dmProfile.locale].noCreateNavigationNodes#
			</label>
			
			</fieldset>
		
		</fieldset> --->
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].uploadFiles#" name="submit" class="f-submit" /><br />
		</div>
		
	</fieldset>

		<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		//bring focus to title
		document.fileForm.zipFile.focus();
		objForm = new qForm("fileForm");
		objForm.zipFile.validateNotNull("#application.adminBundle[session.dmProfile.locale].missingZipFile#");
			//-->
		</SCRIPT>
		
	</form>
	
	<hr />
	
		<h3>#application.adminBundle[session.dmProfile.locale].instructions#</h3>
		<p>#application.adminBundle[session.dmProfile.locale].uploadFileBlurb#</p>
		
	</cfoutput>
	</cfif>
</sec:CheckPermission error="true">

<admin:footer>
<cfsetting enablecfoutputonly="No">
