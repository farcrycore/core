

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
		<cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
		<cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
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
						
							
						<cfif structKeyExists(arguments.stMetadata, "ftAutoGenerateType") AND arguments.stMetadata.ftAutoGenerateType EQ "aspectCrop">
							<div id="#arguments.fieldname#-aspect-crop">	
								<label class="inlineLabel" for="#arguments.fieldname#CropPosition"> Cropping Position
									<select name="#arguments.fieldname#CropPosition" class="selectInput">
										<option value="topleft">TopLeft</option>
										<option value="topcenter">TopCenter</option>
										<option value="topright">TopRight</option>
										<option value="left">Left</option>
										<option value="center" selected="selected" >Center</option>
										<option value="right">Right</option>
										<option value="bottomleft">BottomLeft</option>
										<option value="bottomcenter">BottomCenter</option>
										<option value="bottomright">BottomRight</option>
									</select>
								</label>
							</div>
						</cfif>
						
						</cfoutput>
					<cfelse>
						<cfoutput>
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="hidden" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" />
						</cfoutput>
						
					</cfif>
					
					<cfif len(arguments.stMetadata.ftSourceField)>
													
						<cfoutput>
						<div id="#arguments.fieldname#-generate">
						<label class="inlineLabel" for="display_email">
							<input type="checkbox" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="true" class="checkboxInput"> 
							<input type="hidden" name="#arguments.fieldname#CreateFromSource" value="false" />
							Automatically create from "#arguments.stPackage.stProps[arguments.stMetadata.ftSourceField].metadata.ftLabel#"
						</label>
						</div>
						</cfoutput>
						
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
							
									<img src="#application.fapi.getImageWebRoot()##arguments.stMetadata.value#" width="50px" title="#listLast(arguments.stMetadata.value,"/")#">
									<!---#listLast(arguments.stMetadata.value,"/")#--->
									<ft:button type="button" value="Delete" rendertype="link" id="#arguments.fieldname#-delete-btn" onclick="" />
									<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-delete-btn" onclick="" />
									<ft:button type="button" value="Replace" rendertype="link" id="#arguments.fieldname#-replace-btn" onclick="" />
									<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-replace-btn" onclick="" />

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
		
		<cfparam name="arguments.stMetadata.ftDestination" default="/images" />
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0" />
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0" />
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside" />
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff" />
		<cfparam name="arguments.stMetadata.ftCropPosition" default="center" /><!--- Used when ftAutoGenerateType = aspectCrop --->
		<cfparam name="arguments.stMetadata.ftThumbnailBevel" default="No" />
		<cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
		

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

	<cffunction name="GenerateImage" access="public" output="true" returntype="struct">
		<cfargument name="Source" required="true" hint="The absolute path where the image that is being used to generate this new image is located.">
		<cfargument name="Destination" required="false" default="" hint="The absolute path where the image will be stored.">
		<cfargument name="width" required="false" default="0" type="numeric" hint="The maximum width of the new image.">
		<cfargument name="height" required="false" default="0" type="numeric" hint="The maximum height of the new image.">
		<cfargument name="AutoGenerateType" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)">
		<cfargument name="PadColor" required="false" default="##ffffff" hint="If AutoGenerateType='Pad', image will be padded with this colour">
		<cfargument name="Bevel" required="false" default="no" hint="Will this image have a bevel edge">

		<cfset var stLocal = StructNew()>
		<cfset var ImageDestination = arguments.Source />
		<cfset var stResult = structNew() />
		<cfset var imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
		
         <cfset var at = "" />
         <cfset var op = "" />  
         <cfset var w = "" />
         <cfset var h = "" />
         <cfset var scale = 1 />  
         <cfset var resizedImage = "" />  
         <cfset var myimage =  ""/>
         <cfset var extension = "" />
		<cfset var returnstruct = "" />
         
		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "" />
		<cfset stResult.filename = "" />

		
		<!---
		FTAUTOGENERATETYPE OPTIONS
		ForceSize - Ignores source image aspect ratio and forces the new image to be the size set in the metadata width/height
		FitInside - Reduces the width and height so that it fits in the box defined by the metadata width/height
		Pad - Reduces the width and height so that it fits in the box defined by the metadata width/height and then pads the image so it ends up being the metadata width/height
		 --->
		
		<!--- TODO: set a try/catch block to catch any errors in the return struct --->
		 
		<!--- Image has changed --->
		


		
				
		<cfif len(arguments.destination)>
		
			<cfset ImageDestination = arguments.Destination />
			
			<!--- Create the directory for the image if it doesnt already exist --->
			<cfif NOT DirectoryExists("#ImageDestination#")>
				<cfdirectory action="create" directory="#ImageDestination#">
			</cfif>
					
			<!--- We need to check to see if the image we are copying already exists. If so, we need to create a unique filename --->
			<cfset returnstruct = imageUtilsObj.fGetProperties(arguments.Source)>			
							
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
		
		<cfset myImage = CreateObject("Component", "farcry.core.packages.farcry.simpleImage") />

		<cfset myImage.readImage("#ImageDestination#") />
		
		
		<cfswitch expression="#arguments.AutoGenerateType#">
		
			<cfcase value="ForceSize">
				<!--- Simply force the resize of the image into the width/height provided --->
				<cfset myImage.resize(arguments.Width,arguments.Height) />
				<cfset myImage.writeImage("#ImageDestination#") />
					
				
				<!--- <cfx_image action="resize"
					file="#ImageDestination#"
					output="#ImageDestination#"
					X="#arguments.Width#"
					Y="#arguments.Height#"> --->
			</cfcase>
			
			<cfcase value="FitInside">

				<cfif myImage.Width() LTE arguments.Width OR NOT len(arguments.width)>
					<cfset arguments.Width = 0 />
				</cfif>
				<cfif myImage.Height() LTE arguments.Height OR NOT len(arguments.height)>
					<cfset arguments.Height = 0 />
				</cfif>
				<cfif arguments.Width GT 0 OR arguments.Height GT 0>
					<cfset myImage.resize(arguments.Width,arguments.Height) />
					<cfset myImage.writeImage("#ImageDestination#") />
				</cfif>

				<!--- <cfset stLocal.stReturn = StructNew()>
				<cfset stLocal.bufferedImage = imageUtilsObj.fRead(ImageDestination)>
				<cfset stLocal.height = stLocal.bufferedImage.getHeight()>
				<cfset stLocal.width = stLocal.bufferedImage.getWidth()>
				<cfset stLocal.scaling = imageUtilsObj.fCalculateRatioWidth(stLocal.width,stLocal.height,arguments.Width,arguments.Height)>
		
				<cfset stLocal.bi = createObject("java","java.awt.image.BufferedImage").init(JavaCast("int", stLocal.width/stLocal.scaling), JavaCast("int", stLocal.height/stLocal.scaling), JavaCast("int", 1))>
				<cfset stLocal.graphics = stLocal.bi.getGraphics()>
				<cfset stLocal.jTransform = createObject("java","java.awt.geom.AffineTransform").init()>
				<cfset stLocal.jTransform.Scale(1/stLocal.scaling, 1/stLocal.scaling)>
				<cfset stLocal.graphics.drawRenderedImage(stLocal.bufferedImage, stLocal.jTransform)>
				<cfset stLocal.outFile = createObject("java","java.io.File").init(ImageDestination)>
				<cfset createObject("java","javax.imageio.ImageIO").write(stLocal.bi,"jpg",stLocal.outFile)>
				 --->
				
				
				
				
				<!--- 
				<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
				<cfx_image action="read"
					file="#ImageDestination#">
					
				<cfif IMG_WIDTH GT arguments.Width>
					<cfx_image action="resize"
						file="#ImageDestination#"
						output="#ImageDestination#"
						X="#arguments.Width#">
				</cfif>
					
				<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
				<cfx_image action="read"
					file="#ImageDestination#">
					
				<cfif IMG_HEIGHT GT arguments.Height>
					<cfx_image action="resize"
						file="#ImageDestination#"
						output="#ImageDestination#"
						Y="#arguments.Height#">
				</cfif> --->
				
			</cfcase>
			
			<cfdefaultcase>
				
				<cfset myImage.resize(arguments.Width,arguments.Height) />
				<cfset myImage.writeImage("#ImageDestination#") />
				
				<!--- 
				<cfx_image action="resize"
					file="#ImageDestination#"
					output="#ImageDestination#"
					X="#arguments.Width#"
					Y="#arguments.Height#"
					Thumbnail=yes
					bevel="#lCase(yesnoformat(arguments.Bevel))#"
					backcolor="#arguments.PadColor#"> --->
			</cfdefaultcase>
		
		</cfswitch>
		 		
		<cfreturn stResult />
	</cffunction>
	

<cffunction name="ImageAutoGenerateBeforeSave" access="public" output="true" returntype="struct">
	<cfargument name="stProperties" required="yes" type="struct">
	<cfargument name="stFields" required="yes" type="struct">
	
	<cfset var imagerootPath = "#application.path.imageRoot#" />	
	<cfset var oImage = createobject("component", application.formtools.image.packagePath) />

	<cfloop list="#StructKeyList(arguments.stFields)#" index="i">

		<cfif structKeyExists(arguments.stFields[i].metadata, "ftType") AND arguments.stFields[i].metadata.ftType EQ "Image" >

			<cfif structKeyExists(arguments.stFormPost, i) 
				AND 
				(
					<!--- Either we are always creating from source image --->
					(structKeyExists(arguments.stFields[i].metadata, "ftAlwaysCreateFromSource") AND arguments.stFields[i].metadata.ftAlwaysCreateFromSource)
					OR
					<!--- Or the contributor has selected to create from source image --->
					structKeyExists(arguments.stFormPost[i].stSupporting, "CreateFromSource") AND ListFirst(arguments.stFormPost[i].stSupporting.CreateFromSource)
				)>	
			
				<!--- Make sure a ftSourceField --->
				<cfparam name="arguments.stFields.#i#.metadata.ftSourceField" default="sourceImage" />
				
				<cfset sourceFieldName = arguments.stFields[i].metadata.ftSourceField />
				
				<!--- IS THE SOURCE IMAGE PROVIDED? --->
				<cfif structKeyExists(arguments.stProperties, sourceFieldName) AND len(arguments.stProperties[sourceFieldName])>
													

					<cfparam name="arguments.stFields['#i#'].metadata.ftDestination" default="">		
					<cfparam name="arguments.stFields['#i#'].metadata.ftImageWidth" default="#application.config.image.StandardImageWidth#">
					<cfparam name="arguments.stFields['#i#'].metadata.ftImageHeight" default="#application.config.image.StandardImageHeight#">
					<cfparam name="arguments.stFields['#i#'].metadata.ftAutoGenerateType" default="FitInside">
					<cfparam name="arguments.stFields['#i#'].metadata.ftPadColor" default="##ffffff">
					
					<cfset stArgs = StructNew() />
					<cfset stArgs.Source = "#imagerootPath##arguments.stProperties[sourceFieldName]#" />
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
				
												
					<!--- <cfset stGenerateImageResult = oImage.GenerateImage(Source="#stArgs.Source#", Destination="#stArgs.Destination#", Width="#stArgs.Width#", Height="#stArgs.Height#", AutoGenerateType="#stArgs.AutoGenerateType#", padColor="#stArgs.padColor#") /> --->
					<cfset stGenerateImageResult = oImage.GenerateImage(argumentCollection=stArgs) />
					
					<cfif stGenerateImageResult.bSuccess>
						<cfset stProperties['#i#'] = "#arguments.stFields['#i#'].metadata.ftDestination#/#stGenerateImageResult.filename#" />
					</cfif>
				
				</cfif>
									
			</cfif>

		</cfif>

	</cfloop>
	
	<cfreturn stProperties />
	
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
