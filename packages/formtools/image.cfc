<!--- @@Copyright: Copyright (c) 2010 Daemon Pty Limited. All rights reserved. ---> 
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->


<cfcomponent name="Image" displayname="Image" Extends="field" hint="Field component to liase with all Image types"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" >
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	

<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		
		<cfset var html = "" />
		<cfset var previewHTML = "" />
		<cfset var dimensionAlert = "" />
		<cfset var ToggleOffGenerateImageJS = "" />
		
		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/images">
		<cfparam name="arguments.stMetadata.ftSourceField" default="">
		<cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="true">
		<cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
		<cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
		<cfparam name="arguments.stMetadata.ftAllowResize" default="true">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="#application.config.image.standardImageWidth#">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="#application.config.image.standardImageHeight#">
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
		<cfparam name="arguments.stMetadata.ftShowConversionInfo" default="true"><!--- Set to false to hide the conversion information that will be applied to the uploaded image --->
		<cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
		

		<skin:loadJS id="jquery" />
						
		<cfsavecontent variable="html">
			<grid:div class="multiField">

					<!--- Can the user upload their own image. --->
					<cfif arguments.stMetadata.ftAllowUpload>
						<cfoutput>
						<div id="#arguments.fieldname#-wrap">						
							
							<label class="inlineLabel" for="#arguments.fieldname#">
								&nbsp;
								<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
								<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
								<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" fc:fieldname="#arguments.fieldname#" class="fileUpload" value="" style="#arguments.stMetadata.ftstyle#" />
								
							</label>						
							
						</div>			
						<cfif arguments.stMetadata.ftAllowResize AND (arguments.stMetadata.ftImageWidth GT 0 OR arguments.stMetadata.ftImageHeight GT 0)>				
							<div id="#arguments.fieldname#-aspect-crop">	
								<label class="inlineLabel" for="#arguments.fieldname#ResizeMethod">
									 : resizing to 
									 <cfif arguments.stMetadata.ftImageWidth GT 0>
										#arguments.stMetadata.ftImageWidth#
									<cfelse>
										any
									</cfif>
									x 
									<cfif arguments.stMetadata.ftImageHeight GT 0>
										#arguments.stMetadata.ftImageHeight#
									<cfelse>
										any
									</cfif>
									
									<select name="#arguments.fieldname#ResizeMethod" class="selectInput">
										<option value="">None</option>
										<option value="center" <cfif arguments.stMetadata.ftAutoGenerateType EQ "center"> selected="selected"</cfif>>Crop Center</option>
										<option value="fitinside" <cfif arguments.stMetadata.ftAutoGenerateType EQ "fitinside"> selected="selected"</cfif>>Fit Inside</option>
										<option value="ForceSize" <cfif arguments.stMetadata.ftAutoGenerateType EQ "ForceSize"> selected="selected"</cfif>>Force Size</option>
										<option value="Pad" <cfif arguments.stMetadata.ftAutoGenerateType EQ "Pad"> selected="selected"</cfif>>Pad</option>									
										<option value="-" disabled="true">------------------------</option>
										<option value="topcenter" <cfif arguments.stMetadata.ftAutoGenerateType EQ "topcenter"> selected="selected"</cfif>>Crop Top Center</option>
										<option value="topleft" <cfif arguments.stMetadata.ftAutoGenerateType EQ "topleft"> selected="selected"</cfif>>Crop Top Left</option>									
										<option value="topright" <cfif arguments.stMetadata.ftAutoGenerateType EQ "topright"> selected="selected"</cfif>>Crop Top Right</option>
										<option value="left" <cfif arguments.stMetadata.ftAutoGenerateType EQ "left"> selected="selected"</cfif>>Crop Left</option>									
										<option value="right" <cfif arguments.stMetadata.ftAutoGenerateType EQ "right"> selected="selected"</cfif>>Crop Right</option>
										<option value="bottomleft" <cfif arguments.stMetadata.ftAutoGenerateType EQ "bottomleft"> selected="selected"</cfif>>Crop Bottom Left</option>
										<option value="bottomcenter" <cfif arguments.stMetadata.ftAutoGenerateType EQ "bottomcenter"> selected="selected"</cfif>>Crop Bottom Center</option>
										<option value="bottomright" <cfif arguments.stMetadata.ftAutoGenerateType EQ "bottomright"> selected="selected"</cfif>>Crop Bottom Right</option>
	
									</select>
								</label>
							</div>
						<cfelse>
							<input type="hidden" name="#arguments.fieldname#ResizeMethod" class="">	
						</cfif>
						
						</cfoutput>
					</cfif>
					
					<cfif len(arguments.stMetadata.ftSourceField)>
							
						<cfif arguments.stMetadata.ftAllowUpload>						
							<cfoutput>
							<div id="#arguments.fieldname#-generate">
							<label class="inlineLabel" for="#arguments.fieldname#CreateFromSource">
								<input type="checkbox" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="true" class="checkboxInput"> 
								<input type="hidden" name="#arguments.fieldname#CreateFromSource" value="false" />
								Automatically create from "#arguments.stPackage.stProps[listFirst(arguments.stMetadata.ftSourceField,":")].metadata.ftLabel#"
							</label>
							</div>
							</cfoutput>
						<cfelse>
							<cfoutput><input type="hidden" name="#arguments.fieldname#CreateFromSource" value="true" /></cfoutput>
						</cfif>
						
						<skin:onReady>
							<cfoutput>
                            	$j('###arguments.fieldname#CreateFromSource').click(function() {
									if($j('###arguments.fieldname#CreateFromSource').attr('checked')){
										$j('###arguments.fieldname#-wrap').hide('fast');
									} else {
										$j('###arguments.fieldname#-wrap').show('fast');
									}
								});								
                            </cfoutput>
						</skin:onReady>
						
										
						<cfif arguments.stMetadata.ftCreateFromSourceDefault AND NOT len(arguments.stMetadata.value)>
							<skin:onReady>
							<cfoutput>
                            	$j('###arguments.fieldname#CreateFromSource').attr('checked',true);
                            	$j('###arguments.fieldname#-wrap').css('display','none');								
							</cfoutput>
							</skin:onReady>
						</cfif>		
						
					</cfif>

					
					<!--- image preview --->
					<cfif len(arguments.stMetadata.value)>
						<cfoutput>
							<div id="#arguments.fieldname#previewimage">
							
									<img id="#arguments.fieldname#-preview-img" src="#application.fapi.getImageWebRoot()##arguments.stMetadata.value#" width="50px" title="#listLast(arguments.stMetadata.value,"/")#">
									
									<cfif arguments.stMetadata.ftAllowUpload>
										<ft:button type="button" value="Delete" rendertype="link" id="#arguments.fieldname#-delete-btn" onclick="" />
										<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-delete-btn" onclick="" />
										<ft:button type="button" value="Replace" rendertype="link" id="#arguments.fieldname#-replace-btn" onclick="" />
										<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-replace-btn" onclick="" />
									</cfif>
							</div>
						</cfoutput>
						
						<cfif len(arguments.stMetadata.value)>
							<skin:onReady>
							<cfoutput>
                            	$j('###arguments.fieldname#-wrap').css('display','none');	
                            	$j('###arguments.fieldname#-aspect-crop').css('display','none');	
                            	$j('###arguments.fieldname#-generate').css('display','none');	
                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','none');	
                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','none');	
								
                            	$j('###arguments.fieldname#NEW').change(function() {
									var id = '#arguments.fieldname#';
									var currentText = $j('##' + id).attr('value');	
									var aCurrentExt = currentText.split(".");	
										
									var newText = $j('##' + id + 'NEW').attr('value');	
									var aNewExt = newText.split(".");	
									
									if (currentText.length > 0 && newText.length > 0) {
										if (aCurrentExt.length > 1 && aNewExt.length > 1){						
											if (aCurrentExt[aCurrentExt.length - 1] != aNewExt[aNewExt.length - 1]){
												$j('##' + id + 'NEW').attr('value', '');
												alert('You must either delete the old file or upload a new one with the same extension (' + aCurrentExt[aCurrentExt.length - 1] + ')');
											}
										}
									}
								});
								
                            	$j('###arguments.fieldname#-delete-btn').click(function() {
									$j('###arguments.fieldname#DELETE').attr('value',$j('###arguments.fieldname#').attr('value'));
									$j('###arguments.fieldname#').attr('value','');
									if($j('###arguments.fieldname#CreateFromSource').attr('checked')){
										// do nothing
									} else {
										$j('###arguments.fieldname#-wrap').show('fast');
									}
									$j('###arguments.fieldname#-aspect-crop').show('fast');
									$j('###arguments.fieldname#-generate').show('fast');									
									$j('###arguments.fieldname#-preview-img').css('display','none');
									$j('###arguments.fieldname#-delete-btn').css('display','none');
									$j('###arguments.fieldname#-replace-btn').css('display','none');
	                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','inline');
								});		
                            	$j('###arguments.fieldname#-cancel-delete-btn').click(function() {
									$j('###arguments.fieldname#').attr('value',$j('###arguments.fieldname#DELETE').attr('value'));
									$j('###arguments.fieldname#DELETE').attr('value','');
									$j('###arguments.fieldname#-wrap').hide('fast');
									$j('###arguments.fieldname#-aspect-crop').hide('fast');
									$j('###arguments.fieldname#-generate').hide('fast');							
									$j('###arguments.fieldname#-preview-img').css('display','inline');
									$j('###arguments.fieldname#-delete-btn').css('display','inline');
									$j('###arguments.fieldname#-replace-btn').css('display','inline');
	                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','none');
								});		
                            	$j('###arguments.fieldname#-replace-btn').click(function() {
									if($j('###arguments.fieldname#CreateFromSource').attr('checked')){
										// do nothing
									} else {
										$j('###arguments.fieldname#-wrap').show('fast');
									}
									$j('###arguments.fieldname#-aspect-crop').show('fast');
									$j('###arguments.fieldname#-generate').show('fast');
									$j('###arguments.fieldname#-delete-btn').css('display','none');
									$j('###arguments.fieldname#-replace-btn').css('display','none');
	                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','inline');
								});		
                            	$j('###arguments.fieldname#-cancel-replace-btn').click(function() {
									$j('###arguments.fieldname#-wrap').hide('fast');
									$j('###arguments.fieldname#-aspect-crop').hide('fast');
									$j('###arguments.fieldname#-generate').hide('fast');
									$j('###arguments.fieldname#-delete-btn').css('display','inline');
									$j('###arguments.fieldname#-replace-btn').css('display','inline');
	                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','none');
								});							
							</cfoutput>
							</skin:onReady>
						</cfif>					
					</cfif>
				

			</grid:div>					
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0">
		
		<cfsavecontent variable="html">
			<cfif len(arguments.stMetadata.value)>
				<cfoutput><img src="#application.fapi.getImageWebRoot()##arguments.stMetadata.value#" border="0"
					<cfif arguments.stMetadata.ftAutoGenerateType EQ "ForceSize" OR arguments.stMetadata.ftAutoGenerateType EQ "Pad" >
						<cfif len(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth GT 0>width="#arguments.stMetadata.ftImageWidth#"</cfif>
						<cfif len(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight GT 0>height="#arguments.stMetadata.ftImageHeight#"</cfif>
					</cfif>
				/></cfoutput>
			</cfif>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
	    <cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
	    <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	    <cfargument name="stImageArgs" required="true" type="struct" default="#structNew()#" hint="Append any additional image arguments for image generation.">
	    <cfargument name="objectid" required="true" type="uuid" hint="objectid of image object" />
	
	    <cfset var stResult = structNew() />
	    <cfset var stGeneratedImageArgs = arguments.stImageArgs />
		<cfset var uploadFileName = "" />
		<cfset var b = "" />
		<cfset var newFileName = "" />
		<cfset var lFormField = "" />	
		

		<cfset stResult.bSuccess = true />
		<cfset stResult.value = stFieldPost.value />
		<cfset stResult.stError = StructNew() />
		
		
	    <!--- New features to support CFIMAGE --->
	    <cfparam name="arguments.stMetadata.ftcustomEffectsObjName" default="imageeffects" />
	    <cfparam name="arguments.stMetadata.ftlCustomEffects" default="" />
	    <cfparam name="arguments.stMetadata.ftConvertImageToFormat" default="" />
	    <cfparam name="arguments.stMetadata.ftbSetAntialiasing" default="true" />
	    <cfparam name="arguments.stMetadata.ftinterpolation" default="highestQuality" />
		
		<cfparam name="arguments.stMetadata.ftDestination" default="/images" />
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0" />
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0" />
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside" />
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff" />
		<cfparam name="arguments.stMetadata.ftCropPosition" default="center" /><!--- Used when ftAutoGenerateType = aspectCrop --->
		<cfparam name="arguments.stMetadata.ftThumbnailBevel" default="No" />
		<cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
		

	
	    <!--- New features to support CFIMAGE --->
	    <cfset arguments.stImageArgs.customEffectsObjName = arguments.stMetadata.ftcustomEffectsObjName />
	    <cfset arguments.stImageArgs.lCustomEffects = arguments.stMetadata.ftlCustomEffects />
	    <cfset arguments.stImageArgs.convertImageToFormat = arguments.stMetadata.ftConvertImageToFormat />
	    <cfset arguments.stImageArgs.bSetAntialiasing = arguments.stMetadata.ftBSetAntialiasing />
	    <cfset arguments.stImageArgs.interpolation = arguments.stMetadata.ftInterpolation />		
		
		

		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.stMetadata.ftDestination) AND left(arguments.stMetadata.ftDestination,1) NEQ "/">
			<cfset arguments.stMetadata.ftDestination = "/#arguments.stMetadata.ftDestination#" />
		</cfif>

		<cfif NOT DirectoryExists("#application.path.imageRoot##arguments.stMetadata.ftDestination#")>
			<cfset b = createFolderPath("#application.path.imageRoot##arguments.stMetadata.ftDestination#")>
		</cfif>

		<cfif
			structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#Delete")
			AND	len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#Delete"]) AND fileExists("#application.path.imageRoot##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#")>
				
		 	<cfif fileExists("#application.path.imageRoot##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#")>
			 			
				<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.stMetadata.ftDestination#")>
					<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#">
				</cfif>	
				
			 	<cffile 
				   action = "move"
				   source = "#application.path.imageRoot##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#"
				   destination = "#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#listLast(FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete'], '/')#">
			</cfif>

		</cfif>
		
		<cfif
			structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#New")
			AND	len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"]) gt 0>
		
			<cfif structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#") AND  len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
				<!--- This means there is currently a file associated with this object. We need to override this file --->
				
				<cfset lFormField = replace(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"], '\', '/')>			
				<cfset uploadFileName = listLast(lFormField, "/") />
		 	
		 	
				<!--- MOVE THE OLD FILE INTO THE ARCHIVE --->
		 		<cfif fileExists("#application.path.imageRoot##arguments.stMetadata.ftDestination#/#uploadFileName#")>
			 			
					<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.stMetadata.ftDestination#")>
						<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#">
					</cfif>	
					
				 	<cffile 
					   action = "move"
					   source = "#application.path.imageRoot##arguments.stMetadata.ftDestination#/#uploadFileName#"
					   destination = "#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#uploadFileName#">
				</cfif>
		
				<cffile
					action="upload"
					filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
					destination="#application.path.imageRoot##arguments.stMetadata.ftDestination#"		        	
					nameconflict="MakeUnique">
					
				<cfif listFindNoCase(arguments.stMetadata.ftAllowedExtensions,cffile.serverFileExt)>
					<cffile action="rename" source="#application.path.imageRoot##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" destination="#uploadFileName#" />
					<cfset newFileName = uploadFileName>
				<cfelse>
					<cffile action="delete" file="#application.path.imageRoot##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" />
				</cfif>
								
			<cfelse>
				<!--- There is no image currently so we simply upload the image and make it unique  --->
				<cffile action="upload"
					filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
					destination="#application.path.imageRoot##arguments.stMetadata.ftDestination#"		        	
					nameconflict="MakeUnique">
				
				<cfif listFindNoCase(arguments.stMetadata.ftAllowedExtensions,cffile.serverFileExt)>					
					<cfset newFileName = cffile.ServerFile>
				<cfelse>
					<cffile action="delete" file="#application.path.imageRoot##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" />
				</cfif>
			</cfif>

			<cfif len(newFileName)>
				<cfif len(arguments.stMetaData.ftImageWidth) OR len(arguments.stMetaData.ftImageHeight)>
					<cfset stGeneratedImageArgs.Source = "#application.path.imageRoot##arguments.stMetadata.ftDestination#/#newFileName#" />
					<cfset stGeneratedImageArgs.Destination = "" />			
					<cfset stGeneratedImageArgs.Width = "#arguments.stMetadata.ftImageWidth#" />
					<cfif NOT isNumeric(stGeneratedImageArgs.Width)>
						<cfset stGeneratedImageArgs.Width = 0 />
					</cfif>					
					<cfset stGeneratedImageArgs.Height = "#arguments.stMetadata.ftImageHeight#" />
					<cfif NOT isNumeric(stGeneratedImageArgs.Height)>
						<cfset stGeneratedImageArgs.Height = 0 />
					</cfif>
					<cfset stGeneratedImageArgs.AutoGenerateType = "#arguments.stMetadata.ftAutoGenerateType#" />
					<cfset stGeneratedImageArgs.PadColor = "#arguments.stMetadata.ftPadColor#" />
					
					<cfif structKeyExists(arguments.stFieldPost.stSupporting, "CropPosition")
						AND len(arguments.stFieldPost.stSupporting.CropPosition)>
						<cfset stGeneratedImageArgs.cropPosition = "#arguments.stFieldPost.stSupporting.CropPosition#" />
					</cfif>
					

					<cfset stGeneratedImage = GenerateImage(argumentCollection=stGeneratedImageArgs) />
					
					<cfif stGeneratedImage.bSuccess>
						<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#newFileName#" />
					</cfif>
				<cfelse>
					<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#newFileName#" />	
				</cfif>
			</cfif>	
		</cfif>
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult />
		
	</cffunction>

	
	<cffunction name="createFolderPath" output="true" hint="Creates a folder branch" returntype="boolean">
		<cfargument name="folderPath" type="string" required="true">
		<cfargument name="mode" type="string" default="" required="false">
		
		
		<cfset var depth = "" />
		<cfset var thePath = replace(arguments.folderPath,"\", "/","ALL") />
		<cfset var arFolders = "" />
		<cfset var pathLen = 0 />
		<cfset var workingPath = "" />
		<cfset var bUNC = false />
		<cfset var indexStart = 1 />

		<cfif left(arguments.folderPath,1) eq "/"><!--- *nix path --->
			<cfset workingPath = "/">
		<cfelseif left(arguments.folderPath,2) eq "\\"><!--- UNC Path --->
			<cfset bUNC = true>
			<cfset workingPath = "\\" & listFirst(arguments.folderPath, "\") & "\">
			<cfset indexStart = 2>
		<cfelse>
			<cfset workingPath = listFirst(thePath, "/")&"/"><!--- windows path --->
			<cfset thePath = listDeleteAt(thePath,1, "/")>
		</cfif>
		<cfset arFolders = listToArray(thePath, "/")>
		
		
		<cfloop from="#indexStart#" to="#arrayLen(arFolders)#" index="depth">
			
			<cfif bUNC>
				<cfset workingPath = workingPath.concat(arFolders[depth]&"\")>
			<cfelse>
				<cfset workingPath = workingPath.concat(arFolders[depth]&"/")>
			</cfif>
	
			
			<cfif not directoryExists(workingPath)>
				<cftry>
				<cfif arguments.mode eq "">
					<cfdirectory action="create" directory="#workingPath#">			
				<cfelse>
					<cfdirectory action="create" directory="#workingPath#" mode="#arguments.mode#">
				</cfif>
				<cfcatch>
					<cfoutput>failed creating folder #workingPath#</cfoutput>
					<cfreturn false>
				</cfcatch>
				</cftry>
			</cfif>
		
		</cfloop>
		<cfreturn true>
	</cffunction>

  <cffunction name="GenerateImage" access="public" output="false" returntype="struct">
    <cfargument name="source" type="string" required="true" hint="The absolute path where the image that is being used to generate this new image is located." />
    <cfargument name="destination" type="string" required="false" default="" hint="The absolute path where the image will be stored." />
    <cfargument name="width" type="numeric" required="false" default="#application.config.image.StandardImageWidth#" hint="The maximum width of the new image." />
    <cfargument name="height" type="numeric" required="false" default="#application.config.image.StandardImageHeight#" hint="The maximum height of the new image." />
    <cfargument name="autoGenerateType" type="string" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)" />
    <cfargument name="padColor" type="string" required="false" default="##ffffff" hint="If AutoGenerateType='Pad', image will be padded with this colour" />
    <cfargument name="customEffectsObjName" type="string" required="true" default="imageEffects" hint="The object name to run the effects on (must be in the package path)" />
    <cfargument name="lCustomEffects" type="string" required="false" default="" hint="List of methods to run for effects with their arguments and values. The methods are order dependent replecting how they are listed here. Example: ftLCustomEffects=""roundCorners();reflect(opacity=40,backgroundColor='black');""" />
    <cfargument name="convertImageToFormat" type="string" required="false" default="" hint6="Convert image to a specific format. Set value to image extension. Example: 'gif'. Leave blank for no conversion. Default=blank (no conversion)" />
    <cfargument name="bSetAntialiasing" type="boolean" required="true" default="true" hint="Use Antialiasing (better image, but slower performance)" />
    <cfargument name="interpolation" type="string" required="true" default="highestQuality" hint="set the interpolation level on the image compression" />
	<cfargument name="ResizeMethod" type="string" required="true" default="" hint="The y origin of the crop area. Options are center, topleft, topcenter, topright, left, right, bottomleft, bottomcenter, bottomright" />

    <cfset var stResult = structNew() />6
    <cfset var imageDestination = arguments.Source />
    <cfset var oImageUtils = createObject("component","#application.packagepath#.farcry.imageUtilities") />
    <cfset var sourceImage = imageNew() />
    <cfset var cropXOrigin = 0 />
    <cfset var cropYOrigin = 0 />
    <cfset var padImage = imageNew() />
    <cfset var XCoordinate = 0/>
    <cfset var YCoordinate = 0/>
    <cfset var stBeveledImage = structNew() />
	<cfset var widthPercent = 0 />
	<cfset var heigthPercent = 0 />
	<cfset var usePercent = 0 />
	<cfset var pixels = 0 />
    <cfset returnstruct = structnew() />
    <cfset stResult.bSuccess = true />
    <cfset stResult.message = "" />
    <cfset stResult.filename = "" />

    <cfif not fileexists(arguments.source)>
      <cfset stResult.bSuccess = False />
      <cfset stResult.message = "File doesn't exist" />
      <cfreturn stResult />
    </cfif>

    <!---
    FTAUTOGENERATETYPE OPTIONS
    ForceSize - Ignores source image aspect ratio and forces the new image to be the size set in the metadata width/height
    FitInside - Reduces the width and height so that it fits in the box defined by the metadata width/height
    CropToFit - A bit of both "ForceSize" and "FitInside" where it forces the image to conform to a fixed width and hight, but crops the image to maintain spect ratio. It first attempts to crop the width because most photos are taken from a horizontal perspective with a better chance to remove a few pixels than from the header and footer.
    Pad - Reduces the width and height so that it fits in the box defined by the metadata width/height and then pads the image so it ends up being the metadata width/height
    --->

	  <!--- Image has changed --->

    <cfif len(arguments.destination)>

      <cfset imageDestination = arguments.Destination />

      <!--- Create the directory for the image if it doesnt already exist --->
      <cfif not directoryExists("#ImageDestination#")>
        <cfdirectory action="create" directory="#ImageDestination#">
      </cfif>

      <!--- We need to check to see if the image we are copying already exists. If so, we need to create a unique filename --->
      <cfset returnstruct = oImageUtils.fGetProperties(arguments.Source) />

      <cfif fileExists("#ImageDestination#/#returnstruct.filename#")>
        <cfset returnstruct.filename = "#dateFormat(now(),'yymmdd')#_#timeFormat(now(),'hhmmssl')#_#returnstruct.filename#"/>
      </cfif>

      <!--- Include the image filename into the image destination. --->
      <cfset ImageDestination = "#ImageDestination#/#returnstruct.filename#" />									

      <!--- Copy the image to the new destination folder --->
      <cffile action="copy" 
          source="#arguments.Source#"
          destination="#ImageDestination#">

      <!--- update the return filename --->				
      <cfset stResult.filename = returnstruct.filename />	
    </cfif>

    <cftry>
      <cfset sourceImage = ImageRead(ImageDestination) />
      <!--- Duplicate the image so we don't damage the source --->
      <cfset newImage = imageDuplicate(sourceImage) />
      <cfif arguments.bSetAntialiasing is true>
        <cfset ImageSetAntialiasing(newImage,"on") />
      </cfif>

      <cfcatch type="any">
        <cftrace type="warning" text="Minimum version of ColdFusion 8 required for cfimage tag manipulation. Using default image.cfc instead" />
		<cfdump var="#cfcatch#"><cfabort>
        <cfset stResult = createObject("component", "farcry.core.packages.formtools.image").GenerateImage(Source=arguments.Source, Destination=arguments.Destination, Width=arguments.Width, Height=arguments.Height, AutoGenerateType=arguments.AutoGenerateType, PadColor=arguments.PadColor) />
        <cfreturn stResult />
      </cfcatch>
    </cftry>

    <cfswitch expression="#arguments.ResizeMethod#">

      <cfcase value="ForceSize">
        <!--- Simply force the resize of the image into the width/height provided --->
        <cfset imageResize(newImage,arguments.Width,arguments.Height,"#arguments.interpolation#") />
      </cfcase>

		<cfcase value="FitInside">
	        <!--- If the Width of the image is wider than the requested width, resize the image in the 
	correct proportions to be the width requested --->
			<cfif arguments.Width gt 0 AND newImage.width gt arguments.Width>
	          <cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
	        </cfif>

			<!--- If the height of the image (after the previous width setting) is taller than 
	the requested height, resize the image in the correct proportions to be the height requested --->
			<cfif arguments.Height gt 0 AND newImage.height gt arguments.Height>
	          <cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
	        </cfif>
		</cfcase>

      <cfcase value="CropToFit">
        <!--- First we try to crop the width because most photos are taken with a horizontal perspective --->

        <!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
        <cfif newImage.height gt arguments.Height>
          <cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
          <cfif newImage.width gt arguments.Width>
            <!--- Find where to start on the X axis, then crop (either use ceiling() or fix() ) --->
            <cfset cropXOrigin = ceiling((newImage.width - arguments.Width)/2) />
            <cfset ImageCrop(newImage,cropXOrigin,0,arguments.Width,arguments.Height) />
          </cfif>

        <!--- Else If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
        <cfelseif newImage.width gt arguments.Width>
          <cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
          <cfif newImage.height gt arguments.Height>
            <!--- Find where to start on the Y axis (either use ceiling() or fix() ) --->
            <cfset cropYOrigin = ceiling((newImage.height - arguments.Height)/2) />
            <cfset ImageCrop(newImage,0,cropYOrigin,arguments.Width,arguments.Height) />
          </cfif>
        </cfif>

      </cfcase>

      <cfcase value="Pad">

        <!--- Scale To Fit --->
        <cfset imageScaleToFit(newImage,arguments.Width,arguments.Height,"#arguments.interpolation#") />

        <!--- Check if either the new height or new width is smaller than the arugments width and height. If yes, then padding is needed --->
        <cfif newImage.height lt arguments.Height or newImage.width lt arguments.Width>
          <!--- Create a temp image with background color = PadColor --->
          <cfset padImage = ImageNew("",arguments.Width,arguments.Height,"argb",arguments.PadColor) />
          <!--- Because ImageScaleToFit doesn't always work correctly (it may make the width or height it used to scale by smaller than it should have been... usually by 1 pixel) we need to account for that becfore we paste --->
          <!--- Either use ceiling() or fix() depending on which side you want the extra pixeled padding on (This won't be a problem if Adobe fixes the bug in ImageScaleToFit in a future version of ColdFusion) --->
          <cfset XCoordinate = ceiling((arguments.Width - newImage.Width)/2) />
          <cfset YCoordinate = ceiling((arguments.Height - newImage.height)/2) />
          <!--- Paste the scaled image over the new drawn image --->
          <cfset ImagePaste(padImage,newImage,XCoordinate,YCoordinate) />
          <cfset newImage = imageDuplicate(padImage) />
        </cfif>

      </cfcase>
	
	<cfcase value="center,topleft,topcenter,topright,left,right,bottomleft,bottomcenter,bottomright">
		<!--- Resize image without going over crop dimensions--->
		<cfset widthPercent = arguments.Width / newImage.width>
		<cfset heightPercent = arguments.Height / newImage.height>
		
		<cfif widthPercent gt heightPercent>
			<cfset usePercent = widthPercent>
    		<cfset pixels = newImage.width * usePercent + 1>
			<cfset cropYOrigin = ((newImage.height - arguments.Height)/2)>
			<cfset imageResize(newImage,pixels,"") />
		<cfelse>
    		<cfset usePercent = heightPercent>
    		<cfset pixels = newImage.height * usePercent + 1>
			<cfset cropXOrigin = ((newImage.width - arguments.Height)/2)>
			<cfset imageResize(newImage,"",pixels) />
		</cfif>

		<!--- Set the xy offset for cropping, if not provided defaults to center --->
		<cfif listfindnocase("topleft,left,bottomleft", arguments.ResizeMethod)>
			<cfset cropXOrigin = 0>
		<cfelseif listfindnocase("topcenter,center,bottomcenter", arguments.ResizeMethod)>
			<cfset cropXOrigin = (newImage.width - arguments.Width)/2>
		<cfelseif listfindnocase("topright,right,bottomright", arguments.ResizeMethod)>
			<cfset cropXOrigin = newImage.width - arguments.Width>
		<cfelse>
			<cfset cropXOrigin = (newImage.width - arguments.Width)/2>
		</cfif>
		
		<cfif listfindnocase("topleft,topcenter,topright", arguments.ResizeMethod)>
			<cfset cropYOrigin = 0>
		<cfelseif listfindnocase("left,center,right", arguments.ResizeMethod)>
			<cfset cropYOrigin = (newImage.height - arguments.Height)/2>
		<cfelseif listfindnocase("bottomleft,bottomcenter,bottomright", arguments.ResizeMethod)>
			<cfset cropYOrigin = newImage.height - arguments.Height>
		<cfelse>
			<cfset cropYOrigin = (newImage.height - arguments.Height)/2>	
		</cfif>	

		<cftry>
		<cfset ImageCrop(newImage,cropXOrigin,cropYOrigin,arguments.Width,arguments.Height)>
		<cfcatch type="any">
			<cfdump var="#newImage#">
			<cfdump var="#arguments#" label="#cropXOrigin#-#cropYOrigin#">
			<cfdump var="#cfcatch#">
			<cfabort>
		</cfcatch>
		</cftry>
	</cfcase>	

    </cfswitch>

    <!--- Apply Image Effects --->
    <cfif len(arguments.customEffectsObjName) and len(arguments.lCustomEffects)>
      <cfset oImageEffects = createObject("component", "#evaluate("application.formtools.#customEffectsObjName#.packagePath")#") />

      <!--- Covert the list to an array --->
      <cfset aMethods = listToArray(trim(arguments.lCustomEffects), ";") />

      <!--- Loop over array --->
      <cfloop index="i" array="#aMethods#">
        <cfset i = trim(i) />
        <cfset lArgs = "" />
        <cfset find = reFindNoCase("[^\(]+", i, 0, true) />
        <cfset methodName = mid(i, find.pos[1], find.len[1]) />
        <cfset find = reFindNoCase("\(([^\)]+)\)", i, 0, true) />
        <!--- Check if arguments exist --->
        <cfif arrayLen(find.pos) gt 1>
          <cfset lArgs = trim(mid(i, find.pos[2], find.len[2])) />
        </cfif>
        <cfset stArgCollection = structNew() />
        <cfset stArgCollection.oImage = newImage />
        <cfloop index="argsIndex" list="#lArgs#" delimiters=",">
          <cfset argName = trim(listGetAt(argsIndex,1,"=")) />
          <cfset argValue = trim(listGetAt(argsIndex,2,"=")) />
          <cfif len(argValue) gt 1 and left(argValue, 1) eq "'" and right(argValue, 1) eq "'">
            <cfset argValue = left(argValue, len(argValue)-1) />
            <!--- Allow blank values --->
            <cfif len(argValue)-1 eq 0>
              <cfset argValue = "" />
            <cfelse>
              <cfset argValue = right(argValue, len(argValue)-1) />
            </cfif>
          <cfelse>
            <cfset argValue = evaluate(argValue) />
          </cfif>
          <cfset stArgCollection[argName] = argValue />
        </cfloop>
        <!--- Run method --->
        <!--- <cfinvoke
          component = "#oImageEffects#"
          method = "#methodName#"
          returnVariable = "newImage"
          argumentCollection = "#stArgCollection#"> --->
        <cfset oImageEffects.methodName = oImageEffects[methodName] />
        <cfset newImage = oImageEffects.methodName(argumentCollection=stArgCollection) />
      </cfloop>
    </cfif>

    <!--- Modify extension to convert image format --->
    <cfif len(arguments.convertImageToFormat)>
      <!--- Delete the working file --->
      <cftry>
        <cffile action="delete" file="#ImageDestination#">
        <cfcatch></cfcatch>
      </cftry>
      <cfset ImageDestination = listSetAt(ImageDestination, listLen(ImageDestination, "."), replace(convertImageToFormat, ".", "", "all"), ".") />
      <!--- update the return filename --->
      <cfset stResult.filename = listLast(ImageDestination,"/") />
    </cfif>

    <cfimage action="write" source="#newImage#" destination="#ImageDestination#" overwrite="true" />

    <cfreturn stResult />
  </cffunction>
	
  <cffunction name="ImageAutoGenerateBeforeSave" access="public" output="false" returntype="struct">
    <cfargument name="stProperties" required="true" type="struct" />
    <cfargument name="stFields" required="true" type="struct" />

    <cfset var imagerootPath = "#application.path.imageRoot#" />	
    <cfset var oImage = createobject("component", application.formtools.image.packagePath) />
    <cfset var stArgs = structNew() />
	<cfset var sourceFieldName = "" />
	<cfset var libraryFieldName = "" />
	
    <cfloop list="#StructKeyList(arguments.stFields)#" index="i">
      <cfif structKeyExists(arguments.stFields[i].metadata, "ftType") AND arguments.stFields[i].metadata.ftType EQ "Image" >
		<cfparam name="arguments.stFields.#i#.metadata.ftAllowResize" default="true" />
	  
        <cfif structKeyExists(arguments.stFormPost, i) AND (
				(
					structKeyExists(arguments.stFormPost[i].stSupporting, "CreateFromSource") 
					AND ListFirst(arguments.stFormPost[i].stSupporting.CreateFromSource)
				) 
				or (
					arguments.stFields[i].metadata.ftAllowResize
					and not structkeyexists(arguments.stFields[i].metadata,"ftSourceField")
					and len(arguments.stProperties[i])
				)
			)>	
          <!--- Make sure a ftSourceField --->
		  <cfif (not structkeyexists(arguments.stFields[i].metadata,"ftAllowResize") or arguments.stFields[i].metadata.ftAllowResize) and (not structkeyexists(arguments.stFields[i].metadata,"ftSourceField") or not len(arguments.stFields[i].metadata.ftSourceField)) and len(arguments.stProperties[i])>
			<cfset sourceFieldName = i />
		  <cfelse>
			<cfset sourceFieldName = listFirst(arguments.stFields[i].metadata.ftSourceField, ":") />
		  </cfif>
          <!--- IS THE SOURCE IMAGE PROVIDED? --->
		  
		  
		  
		  
          <cfif structKeyExists(arguments.stProperties, sourceFieldName) AND len(arguments.stProperties[sourceFieldName])>
		  

		  
            <cfparam name="arguments.stFields['#i#'].metadata.ftDestination" default="">		
            <cfparam name="arguments.stFields['#i#'].metadata.ftImageWidth" default="#application.config.image.StandardImageWidth#">
            <cfparam name="arguments.stFields['#i#'].metadata.ftImageHeight" default="#application.config.image.StandardImageHeight#">
            <cfparam name="arguments.stFields['#i#'].metadata.ftAutoGenerateType" default="FitInside">
            <cfparam name="arguments.stFields['#i#'].metadata.ftPadColor" default="##ffffff">
            <!--- New features to support CFIMAGE --->
            <cfparam name="arguments.stFields['#i#'].metadata.ftCustomEffectsObjName" default="imageEffects" />
            <cfparam name="arguments.stFields['#i#'].metadata.ftLCustomEffects" default="" />
            <cfparam name="arguments.stFields['#i#'].metadata.ftConvertImageToFormat" default="" />
            <cfparam name="arguments.stFields['#i#'].metadata.ftBSetAntialiasing" default="true" />
            <cfparam name="arguments.stFields['#i#'].metadata.ftInterpolation" default="highestQuality" />
			<cfparam name="arguments.stFields['#i#'].metadata.ftCropPosition" default="center" />
			
			<cfset stArgs = StructNew() />		  
		  
		  	
		  	<cfif arguments.stFields[sourceFieldName].metadata.ftType EQ "uuid">
				
				<!--- 
				This means that the source image is from an image library. 
				We now expect that the source image is located in the source field of the image library
				--->
				
				<cfset stImage = application.fapi.getContentObject(objectid="#arguments.stProperties[sourceFieldName]#") />
				
				<!--- The source could be from an image library in which case, the source field will be in the form 'uuidField:imageLibraryField' --->
				<cfset libraryFieldName = listLast(arguments.stFields[i].metadata.ftSourceField, ":") />
				
				<cfif structKeyExists(stImage, libraryFieldName) AND len(stImage[libraryFieldName])>
					<cfset stArgs.Source = "#imagerootPath##stImage[libraryFieldName]#" />
				</cfif>	
			<cfelse>
				<cfset stArgs.Source = "#imagerootPath##arguments.stProperties[sourceFieldName]#" />
			</cfif>
			
            <!--- If we have a valid source then start generating --->
            <cfif structKeyExists(stArgs, "source") AND len(stArgs.Source)>
			
	            <cfset stArgs.Destination = "#imagerootPath##arguments.stFields['#i#'].metadata.ftDestination#" />
	            <cfset stArgs.Width = "#arguments.stFields['#i#'].metadata.ftImageWidth#" />
	            <cfif NOT isNumeric(stArgs.Width)>
	              <cfset stArgs.Width = 0 />				
	            </cfif>
	            <cfset stArgs.Height = "#arguments.stFields['#i#'].metadata.ftImageHeight#" />
	            <cfif NOT isNumeric(stArgs.Height)>
	              <cfset stArgs.Height = 0 />				
	            </cfif>
	            <cfset stArgs.AutoGenerateType = "#arguments.stFields['#i#'].metadata.ftAutoGenerateType#" />
	            <cfset stArgs.padColor = "#arguments.stFields['#i#'].metadata.ftpadColor#" />
	            <cfset stArgs.customEffectsObjName = "#arguments.stFields['#i#'].metadata.ftCustomEffectsObjName#" />
	            <!--- New features to support CFIMAGE --->
	            <cfset stArgs.lCustomEffects = "#arguments.stFields['#i#'].metadata.ftLCustomEffects#" />
	            <cfset stArgs.convertImageToFormat = "#arguments.stFields['#i#'].metadata.ftConvertImageToFormat#" />
	            <cfset stArgs.bSetAntialiasing = "#arguments.stFields['#i#'].metadata.ftBSetAntialiasing#" />
	            <cfset stArgs.interpolation = "#arguments.stFields['#i#'].metadata.ftInterpolation#" />
				
				<cfif structKeyExists(arguments.stFormPost, i) AND structKeyExists(arguments.stFormPost[i].stSupporting, "ResizeMethod")>	
					<cfset stArgs.ResizeMethod = "#arguments.stFormPost[i].stSupporting.ResizeMethod#" />
				<cfelse>
					<cfset stArgs.ResizeMethod = arguments.stFields[i].metadata.ftAutoGenerateType />
				</cfif>
	
	            <cfset stGenerateImageResult = oImage.GenerateImage(argumentCollection=stArgs) />
						
	            <cfif stGenerateImageResult.bSuccess>
	              <cfset stProperties['#i#'] = "#arguments.stFields['#i#'].metadata.ftDestination#/#stGenerateImageResult.filename#" />
	            </cfif>
				
			</cfif>
			
          </cfif>
		  
        </cfif>
		
      </cfif>
	  
    </cfloop>

    <cfreturn stProperties />
  </cffunction>
  

  <cffunction name="imageDuplicate" returntype="any" output="false" hint="Creates a clean copy of the image without references (Note: ColdFusion's duplicate() function retains references).">
    <cfargument name="oImage" type="any" required="true" hint="A ColdFusion Image Object" />
    <cfargument name="backgroundColor" type="string" required="false" default="white" hint="background color to use behind the reflection." />

    <cfset var imgInfo = imageInfo(arguments.oImage)/>
    <cfset var myImage = imageNew("", imgInfo.width, imgInfo.height, "argb", arguments.backgroundColor) />
    <cfset imagePaste(myImage, arguments.oImage, 0, 0) />

    <cfreturn myImage />
  </cffunction>

  
	<cffunction name="onDelete" access="public" output="false" returntype="void" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfif not len(arguments.stObject[arguments.stMetadata.name])>
			<cfreturn /><!--- No file attached --->
		</cfif>
		
		<cfif fileexists("#application.path.defaultImagePath#/#arguments.stObject[arguments.stMetadata.name]#")>
			<cffile action="delete" file="#application.path.defaultImagePath#/#arguments.stObject[arguments.stMetadata.name]#" />
		<cfelse>
			<cfreturn /><!--- File doesn't actually exist --->
		</cfif>
	</cffunction>	
	
</cfcomponent> 

