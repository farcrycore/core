<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/bulkFileUpload.cfm,v 1.1.2.3 2004/09/14 17:24:51 tom Exp $
$Author: tom $
$Date: 2004/09/14 17:24:51 $
$Name: milestone_2-2-1 $
$Revision: 1.1.2.3 $

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

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<admin:header>
<!--- check permissions --->
<cfscript>
	iDeveloperPermission = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
</cfscript>
<cfif iDeveloperPermission eq 1>
	<cfif isDefined("form.submit")>
		<cfoutput>
		<style>
		.success{color:##00cc00}
		.fail{color:##FF0000}
		</style>
		</cfoutput>
		<cfif not len(trim(form.zipFile))>
			<cfoutput><strong>Error:</strong> No Zip file specified</cfoutput>
			 <cfabort>
		</cfif>
		<cfoutput><b>Uploading zip file...</b></cfoutput>
		<cfflush>
		<cffile action="upload" filefield="zipFile" destination="#application.defaultFilePath#" accept="application/x-zip-compressed,application/zip" nameconflict="#application.config.general.fileNameConflict#"> 
		<cfoutput><span class="success">Done<br></span></cfoutput>
		<cfflush>
		<cfscript>
			//Figure out slash type based on OS
			slashtype = "\";
			if(not findNoCase("windows",server.os.name)){
				slashtype = "/";		
			}
			zipFilePath = application.defaultFilePath & slashtype & file.serverFile;
			//list of image mime types that can be uploaded
			fileAcceptList = application.config.file.filetype;
			zipFile = createObject("java", "java.util.zip.ZipFile");
			//open zipFile
			zipFile.init(zipFilePath);
			entries = zipFile.entries();
			//Get the data on the starting point in the tree
			qStartingPointData = createObject("component", "#application.packagepath#.farcry.tree").getNode(objectid=form.startPoint); 
			//Set the floor for adding folders and images
			iBaseLevel = qStartingPointData.nLevel;
			/*
			Get a query object containing all descendants of the starting point. This query will be used as
			a lookup table for folders. If the folder exists at the correct level than nothing will be done.
			Otherwise the new folder will be created and the lookup table updated
			*/ 
			qStartPointDescendants = createObject("component", "#application.packagepath#.farcry.tree").getDescendants(objectid=qStartingPointData.objectId);
			//Loop through all entries in the zip file
			while(entries.hasMoreElements()){
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
							if(not q.recordcount){
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
				if (not entry.isDirectory()){
					sFileName = getFileFromPath(entry.getName());
					sFilePath = application.defaultfilepath;
					//do we have a mime type match?
					oFile = createObject("component", "#application.packagepath#.farcry.file");
					sFileMimeType = oFile.getMimeType(sFileName);
					//If the MIME Type of the file matches any list item in the file accept list
					if(listFindNoCase(fileAcceptList, sFileMimeType)){	
						//placeholder for the original filename
						sDefaultFileName = sFileName;
						//check to see if the image already exists if it does then make the name unique
						iLoopNum = 0;
						while(createobject("component", application.types.dmFile.typePath).checkForExisting(filename=sFilename).bExists){
							iLoopNum = incrementValue(iLoopNum);
							sFileName = insert(iLoopNum,sDefaultFileName,len(listFirst(sDefaultFileName,".")));
						}
						sAbsolutePath = sFilePath & slashtype & sFileName;
						//Write the image file to disk
						filOutStream = createObject("java","java.io.FileOutputStream");					
						filOutStream.init(sAbsolutePath);
						bufOutStream = createObject("java","java.io.BufferedOutputStream");
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
						//stFileProps.imageFile = sFileName;
						stFileProps.fileName = createObject("component","#application.packagepath#.farcry.form").sanitiseFileName(sFileName,listFirst(sFileName,"."),sFilePath);
						writeOutput("Creating dmFile (#sDefaultFileName#)<br>");
						flush();
						stFileProps.title = listFirst(sDefaultFileName,".");
						stFileProps.label = listFirst(sDefaultFileName,".");
						stFileProps.filePath = sFilePath;
						stFileProps.fileType = listFirst(sFileMimeType,"/");
						stFileProps.fileSubType = listLast(sFileMimeType,"/");
						stFileProps.fileExt = listLast(stFileProps.fileName,".");
						stFileProps.datetimecreated = Now();
						stFileProps.documentDate = createODBCDate(now());
						stFileProps.createdby = session.dmSec.authentication.userlogin;
						stFileProps.datetimelastupdated = Now();
						stFileProps.lastupdatedby = session.dmSec.authentication.userlogin;
						//Create the file object
						createobject("component", application.types.dmFile.typePath).createData(stProperties=stFileProps);
						//Add the new file under it's nav parent
						oParentNav = createobject("component", application.types.dmNavigation.typePath);
						stParent = oParentNav.getData(navigationParentID);
						arrayAppend(stParent.aObjectIds, stFileProps.objectId);
						stParent.dateTimeCreated =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
						stParent.dateTimeLastUpdated = createODBCDate(now());
						oParentNav.setData(stProperties=stParent);
					}
					else
						writeOutput("<span class=""fail"">Skipping &quot;#entry.getName()#&quot;. Not an acceptable file MIME type</span><br>");
						flush();
					
				}
			}
			zipFile.close();
		</cfscript>
		<!--- Cleanup the uploaded zip file --->
		<cffile action="delete" file="#zipFilePath#">
		<cfoutput><span class="success"><strong>Done</strong></span><br></cfoutput>

	<cfelse>
		<!--- Get all of the nodes under the imageRoot --->
		<cfscript>
		o = createObject("component", "#application.packagepath#.farcry.tree");
		qNodes = o.getDescendants(dsn=application.dsn, objectid=application.navid.fileroot);
		</cfscript>
		
		<!--- Show the form --->
		<cfoutput>
		<div class="formTitle">FILE BULK UPLOAD</div>
		
		<p>
		<form action="" method="POST" name="fileForm" enctype="multipart/form-data">
		<table border="0" cellpadding="3" cellspacing="0">
			<tr>
				<td>Recreate file structure within:</td>
				<td>
					<select name="startPoint">
					<option value="#application.navid.fileroot#">File Root</option>
					<cfloop query="qNodes">
					<option value="#qNodes.objectId#" <cfif qNodes.objectId eq application.navid.fileroot>selected</cfif>>#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
					</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>Zip File(.zip):</td>
				<td>
					<input type="File" size=25 accept="application/x-zip-compressed" name="zipFile">
				</td>
			</tr>
			<tr>
				<td colspan=2>
					<input type="checkbox" name="bCreateDirectories" value=0> Don't create dmNavigation nodes
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<input type="submit" value="Upload Files" name="submit" />
				</td>
			</tr>
		</table>
		<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		//bring focus to title
		document.fileForm.zipFile.focus();
		objForm = new qForm("fileForm");
		objForm.zipFile.validateNotNull("You must specify a Zip file");
			//-->
		</SCRIPT>
		</form>
		<p>
		    <strong>Instructions:</strong>
		</p>
		<p>
		    This utility will quickly upload multiple files into Farcry
		</p>
		<p>
		    You will need to supply a .zip file that contains the file to be uploaded.
			Files and Directories contained in the .zip file will be recreated within
			Farcry under the selected node.
		</p>
		</cfoutput>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>
<admin:footer>
<cfsetting enablecfoutputonly="No">
