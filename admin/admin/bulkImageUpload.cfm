<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/bulkImageUpload.cfm,v 1.9.2.1 2006/03/16 03:38:49 paul Exp $
$Author: paul $
$Date: 2006/03/16 03:38:49 $
$Name: milestone_3-0-1 $
$Revision: 1.9.2.1 $

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

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">
<cfparam name="bLibrary" default="0">
<cfparam name="lSelectedCategoryID" default="">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<!--- check permissions --->
<cfset iDeveloperPermission = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer")>

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
			qStartingPointData = createObject("component", "#application.packagepath#.farcry.tree").getNode(objectid=application.navid.imageroot); 
			//Set the floor for adding folders and images
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
				
				//Is it an image? If so evaluate it for upload
				if (not entry.isDirectory()){
					sFileName = getFileFromPath(entry.getName());
					sFilePath = application.defaultimagepath;
					oFile = createObject("component", "#application.packagepath#.farcry.file");
					//do we have a mime type match?
					sFileMimeType = oFile.getMimeType(sFileName);
					//If the MIME Type of the image matches any list item in the image accept list
					//if accept list not specified in config, accept everything
					if(listFindNoCase(imageAcceptList, sFileMimeType) OR NOT Len(Trim(imageAcceptList))){						//placeholder for the original filename
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
						stImageProps.bLibrary = bLibrary;
						
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
						// assign category
						objCategory.assignCategories(objectid=stImageProps.objectID,lCategoryIDs=lSelectedCategoryID);
						//Add the new image under it's nav parent
						oParentNav = createobject("component", application.types.dmNavigation.typePath);
						stParent = oParentNav.getData(navigationParentID);
						arrayAppend(stParent.aObjectIds, stImageProps.objectId);
						stParent.dateTimeCreated =  createODBCDate("#datepart('yyyy',stParent.DATETIMECREATED)#-#datepart('m',stParent.DATETIMECREATED)#-#datepart('d',stParent.DATETIMECREATED)#");
						stParent.dateTimeLastUpdated = createODBCDate(now());
						oParentNav.setData(stProperties=stParent);
					}
					else
						writeOutput("<span class=""fail"">Skipping &quot;#entry.getName()#&quot;. Not an acceptable image MIME type (#sFileMimeType#)</span><br>");
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
		<!--- <cfscript>
		o = createObject("component", "#application.packagepath#.farcry.tree");
		qNodes = o.getDescendants(dsn=application.dsn, objectid=application.navid.imageroot);
		</cfscript> --->
		
		<!--- Show the form --->
		<cfoutput>

		
	<form method="post" class="f-wrap-1 f-bg-medium wider" action="" name="imageForm" enctype="multipart/form-data">
		<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].bulkImageUpload#</h3>
		
		<fieldset class="f-checkbox-wrap">
			<fieldset>
			<widgets:categoryAssociation typeName="dmImage" lSelectedCategoryID="">
			</fieldset>
			<br />
			</label>		
		</fieldset>
		
		<!--- <label for="startPoint"><b>#application.adminBundle[session.dmProfile.locale].recreateImageStructure#</b>
		<select name="startPoint" id="startPoint">
		<option value="#application.navid.imageroot#">#application.adminBundle[session.dmProfile.locale].imageRoot#</option>
		<cfloop query="qNodes">
		<option value="#qNodes.objectId#" <cfif qNodes.objectId eq application.navid.imageroot>selected</cfif>>#RepeatString("&nbsp;&nbsp;|", qNodes.nlevel)#- #qNodes.objectName#</option>
		</cfloop>
		</select><br />
		</label> --->
		

		<label for="startPoint"><b>#application.adminBundle[session.dmProfile.locale].zipFile#</b>
		<input type="File" accept="application/x-zip-compressed" name="zipFile" /><br />
		</label>
		
		<fieldset class="f-checkbox-wrap">
			<b>Image Library:</b>
			<fieldset>
				<label for="bLibrary">
					<input id="bLibrary" type="checkbox" class="f-checkbox" name="bLibrary" value="1" />&nbsp;Add to image library
					<br />
				</label>
			</fieldset>
		</fieldset>
		<!--- <fieldset class="f-checkbox-wrap">
		
			<b>dmNavigation nodes</b>
			
			<fieldset>
			
			<label for="bCreateDirectories">
			<input type="checkbox" class="f-checkbox" name="bCreateDirectories" id="bCreateDirectories" value="0" /> #application.adminBundle[session.dmProfile.locale].noCreateNavigationNodes#
			</label>
			
			</fieldset>
		
		</fieldset> --->
		
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].uploadImages#" name="submit" class="f-submit" /><br />
		</div>
		
	</fieldset>
	
	<hr />

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
							<p class="error">
							#application.adminBundle[session.dmProfile.locale].downloadIJBlurb#
							</p>
							</cfcatch>
						</cftry>
					<cfelse>
						<cftry>
							<cfscript>
								oTest = createObject("java","ij.io.Opener");
							</cfscript>
							<p class="error">
							#application.adminBundle[session.dmProfile.locale].jreWarningBlurb#
							</p>
							<input type="hidden" name="imageJInstalled" value=0>
							<cfcatch type="Object"></cfcatch>
						</cftry>
					</cfif>

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
		
		
		
		<h3>#application.adminBundle[session.dmProfile.locale].instructions#</h3>
		<p>
		#application.adminBundle[session.dmProfile.locale].uploadImagesBlurb#
		</p>
		<p>
		<em>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].currentJRE,"#javaVersion#")#</em></p>
		</cfoutput>
	</cfif>
<cfelse>
	<admin:permissionError>
</cfif>
<admin:footer>
<cfsetting enablecfoutputonly="No">
