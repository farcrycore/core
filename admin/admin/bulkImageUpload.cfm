<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/bulkImageUpload.cfm,v 1.5 2004/12/06 19:03:10 tom Exp $
$Author: tom $
$Date: 2004/12/06 19:03:10 $
$Name: milestone_2-1-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Uploads a zip file containing images, creates navigation to match directory structure $
$TODO:$

|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
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
			<cfoutput>#application.adminBundle[session.dmProfile.locale].noZipSpecified#</cfoutput>
			<cfabort>
		</cfif>
		<cfoutput><b>#application.adminBundle[session.dmProfile.locale].uploadingZip#</b></cfoutput>
		<cfflush>
		<cffile action="upload" filefield="zipFile" destination="#application.path.defaultFilePath#" accept="application/x-zip-compressed,application/zip" nameconflict="#application.config.general.fileNameConflict#"> 
		<cfoutput><span class="success">#application.adminBundle[session.dmProfile.locale].Done#<br></span></cfoutput>
		<cfflush>
		<cfscript>
			zipFilePath = application.defaultFilePath & "/" & file.serverFile;
			//list of image mime types that can be uploaded
			imageAcceptList = application.config.image.imagetype;
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
				//We only want entries that contain a filename
				if (not entry.isDirectory()){
					sFileName = getFileFromPath(entry.getName());
					sFilePath = application.defaultimagepath;
					navigationParentId = qStartingPointData.objectId;
					//do we have a mime type match?
					oFile = createObject("component", "#application.packagepath#.farcry.file");
					//If the MIME Type of the image matches any list item in the image accept list
					if(listFindNoCase(imageAcceptList, oFile.getMimeType(sFileName))){	
						if(not structKeyExists(form,"bCreateDirectories") and listLen(entry.getName(), "/")){
							for(i=1;i lt listLen(entry.getName(), "/");i=i+1){
								folderName = listGetAt(entry, i, "/");
									
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
						//placeholder for the original filename
						sDefaultFileName = sFileName;
						//check to see if the image already exists if it does then make the name unique
						iLoopNum = 0;
						while(createobject("component", application.types.dmImage.typePath).checkForExisting(filename=sFilename).bExists){
							iLoopNum = incrementValue(iLoopNum);
							sFileName = insert(iLoopNum,sDefaultFileName,len(listFirst(sDefaultFileName,".")));
						}
						sAbsolutePath = sFilePath & "/" & sFileName;
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
						
						//Create structure with new image properties
						flush();
						stImageProps = structNew();
						stImageProps.objectID = createUUID();
						//stImageProps.imageFile = sFileName;
						stImageProps.imageFile = createObject("component","#application.packagepath#.farcry.form").sanitiseFileName(sFileName,listFirst(sFileName,"."),sFilePath);
						writeOutput("Creating dmImage (#stImageProps.imageFile#)<br>");
						flush();
						stImageProps.originalImagePath = sFilePath;
						stImageProps.datetimecreated = Now();
						stImageProps.createdby = session.dmSec.authentication.userlogin;
						stImageProps.title = listFirst(stImageProps.imageFile,".");
						stImageProps.label = listFirst(stImageProps.imageFile,".");
						stImageProps.alt = "Image " & sFileName;
						//If imageJ is installed use it to get the Height and Width of the Original Image
						if(structKeyExists(form,"imageJInstalled")and form.imageJInstalled){
							imagePath = stImageProps.originalImagePath & "\" & stImageProps.imageFile;
							oFarcryImage = createObject("component","#application.packagepath#.farcry.image");
							oFarcryImage.open(imagePath);
							stImageDetails = oFarcryImage.getDetails();
							if(isDefined("stImageDetails.width"))
								stImageProps.width = stImageDetails.width;
							else
								stImageProps.width = "";
								
							if(isDefined("stImageDetails.height"))
								stImageProps.height = stImageDetails.height;
							else
								stImageProps.height = "";
						}
						else{
							stImageProps.width = "";
							stImageProps.height = "";
						}
						stImageProps.datetimelastupdated = Now();
						stImageProps.lastupdatedby = session.dmSec.authentication.userlogin;
						//Do you thumbnail?
						if(structKeyExists(form,"bCreateThumbnails")){
							//Append "_thumb" to the original image filename
							sThumbnailFilename = insert("_thumb",stImageProps.imageFile,len(listFirst(sFileName,".")));
							writeOutput("&nbsp;&nbsp;&nbsp;&##149;Creating thumbnail (#sThumbnailFilename#)");
							flush();
							//Make sure we have a numeric value for resize value (default to 200px)
							iResizeTo = iif(isNumeric(structFind(form,"resizeValue")),form.resizeValue,DE(200));
							//oFarcryImage = createObject("component","#application.packagepath#.farcry.image");
							bResize = oFarcryImage.resize(resizedImagePath="#sFilePath#\#sThumbnailFilename#",resizeValue=iResizeTo,resizeType=form.resizeType);
							if(bResize){
								//Add the thumbnail image properties to the image object structure
								stImageProps.thumbnail = sThumbnailFilename;
								stImageProps.thumbnailImagePath = sFilePath;
								writeOutput("<br>");
								flush();
							}
							else
								writeOutput("<span class=""fail""> - Error creating thumbnail</span><br>");
								
						}
						//Create the image object
						createobject("component", application.types.dmImage.typePath).createData(stProperties=stImageProps);
						//Add the new image under it's nav parent
						oParentNav = createobject("component", application.types.dmNavigation.typePath);
						stParent = oParentNav.getData(navigationParentID);
						arrayAppend(stParent.aObjectIds, stImageProps.objectId);
						stParent.dateTimeCreated =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
						stParent.dateTimeLastUpdated = createODBCDate(now());
						oParentNav.setData(stProperties=stParent);
					}
					else
						writeOutput("<span class=""fail"">Skipping &quot;#entry.getName()#&quot;. Not an acceptable image MIME type</span><br>");
						flush();
					
				}
			}
			zipFile.close();
		</cfscript>
		<!--- Cleanup the uploaded zip file --->
		<cffile action="delete" file="#zipFilePath#">
		<cfoutput><span class="success"><strong>#application.adminBundle[session.dmProfile.locale].Done#</strong></span><br></cfoutput>

	<cfelse>
		<!--- Get all of the nodes under the imageRoot --->
		<cfscript>
		o = createObject("component", "#application.packagepath#.farcry.tree");
		qNodes = o.getDescendants(dsn=application.dsn, objectid=application.navid.imageroot);
		</cfscript>
		
		<!--- Show the form --->
		<cfoutput>
		<div class="formTitle">#application.adminBundle[session.dmProfile.locale].bulkImageUpload#</div>
		
		<p>
		<form action="" method="POST" name="imageForm" enctype="multipart/form-data">
		<table border="0" cellpadding="3" cellspacing="0">
			<tr>
				<td>#application.adminBundle[session.dmProfile.locale].recreateImageStructure#</td>
				<td>
					<select name="startPoint">
					<option value="#application.navid.imageroot#">#application.adminBundle[session.dmProfile.locale].imageRoot#</option>
					<cfloop query="qNodes">
					<option value="#qNodes.objectId#" <cfif qNodes.objectId eq application.navid.imageroot>selected</cfif>>#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
					</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>#application.adminBundle[session.dmProfile.locale].zipFile#</td>
				<td>
					<input type="File" size=25 accept="application/x-zip-compressed" name="zipFile">
				</td>
			</tr>
			<tr>
				<td colspan=2>
					<input type="checkbox" name="bCreateDirectories" value=0> #application.adminBundle[session.dmProfile.locale].noCreateNavigationNodes#
				</td>
			</tr>
			<tr>
				<td colspan=2>
					<!---
					**Check their Java Version**
					There's a known ImageJ measure bug in J2SE 1.4.2.
					It will eat up all your memory and crash your JVM for sure
					--->
					<cfscript>
						try{
						oSystem = createObject("java","java.lang.System");
						stJREProperties = oSystem.getProperties();
						javaVersion = structFind(stJREProperties,"java.version");
						//writeOutput(javaVersion & "<br>");
						}
						catch(Any e){
							javaVersion = "#application.adminBundle[session.dmProfile.locale].unknown#";			
						}
					</cfscript>
					<cfif not find(javaVersion,"1.4.2")>
						<cftry>
							<cfscript>
								oTest = createObject("java","ij.io.Opener");
							</cfscript>
							<input type="checkbox" name="bCreateThumbnails" value=0> 
							#application.adminBundle[session.dmProfile.locale].createThumbnails#
							<select name="resizeType" size=1>
								<option value="auto">#application.adminBundle[session.dmProfile.locale].auto#</option>
								<option value="width">#application.adminBundle[session.dmProfile.locale].fixWidth#</option>
								<option value="height">#application.adminBundle[session.dmProfile.locale].fixHeight#</option>
							</select>
							at
							<input type="text" size="3" maxlength="3" name="resizeValue">px
							<input type="hidden" name="imageJInstalled" value=1>
							<cfcatch type="Object">
							<span style="color:##FF0000;">
							#application.adminBundle[session.dmProfile.locale].downloadIJBlurb#
							</span>
							</cfcatch>
						</cftry>
					<cfelse>
						<cftry>
							<cfscript>
								oTest = createObject("java","ij.io.Opener");
							</cfscript>
							<span style="color:##FF0000;">
							#application.adminBundle[session.dmProfile.locale].jreWarningBlurb#
							</span>
							<input type="hidden" name="imageJInstalled" value=0>
							<cfcatch type="Object"></cfcatch>
						</cftry>
					</cfif>
				</td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<input type="submit" value="#application.adminBundle[session.dmProfile.locale].uploadImages#" name="submit" />
				</td>
			</tr>
		</table>
		<!--- form validation --->
		<SCRIPT LANGUAGE="JavaScript">
		<!--//
		//bring focus to title
		document.imageForm.zipFile.focus();
		objForm = new qForm("imageForm");
		objForm.zipFile.validateNotNull("#application.adminBundle[session.dmProfile.locale].missingZipFile#");
			//-->
		</SCRIPT>
		</form>
		<p>
		    <strong>#application.adminBundle[session.dmProfile.locale].instructions#</strong>
		</p>
		#application.adminBundle[session.dmProfile.locale].uploadImagesBlurb#
		<p><em>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].currentJRE,"#javaVersion#")#</em></p>
		</cfoutput>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>
<admin:footer>
<cfsetting enablecfoutputonly="No">
