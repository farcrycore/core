

<cfcomponent name="Image" displayname="Image" Extends="field" hint="Field component to liase with all Image types"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.image" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		
		<cfset var html = "" />
		<cfset var dimensionAlert = "" />
		
		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/images">
		<cfparam name="arguments.stMetadata.ftSourceField" default="">
		<cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
		<cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="#application.config.image.standardImageWidth#">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="#application.config.image.standardImageHeight#">
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
		

		<cfset Request.inHead.Scriptaculous = 1>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<table>
				<tr>
					<td valign="top">
			</cfoutput>
						<cfif len(arguments.stMetadata.ftSourceField)>

							<cfset Request.InHead.ScriptaculousEffects = 1>
				
							
							<cfsavecontent variable="ToggleOffGenerateImageJS">
								<cfoutput>
									<script language="javascript">
									function toggle#arguments.fieldname#(){
										Effect.toggle('#arguments.fieldname#previewimage','appear');
										Effect.toggle('#arguments.fieldname#NEW','appear');
									}
									
				
									</script>
								</cfoutput>
							</cfsavecontent>
							
							<cfhtmlhead text="#ToggleOffGenerateImageJS#">
							
							
							<cfif arguments.stMetadata.ftCreateFromSourceDefault AND NOT len(arguments.stMetadata.value)>
								<cfset arguments.stMetadata.ftStyle = "#arguments.stMetadata.ftStyle#;display:none;">
							</cfif>		

							<cfoutput>
							<div>
							<input type="checkbox" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="true" onclick="javascript:toggle#arguments.fieldname#();" class="formCheckbox" <cfif arguments.stMetadata.ftCreateFromSourceDefault AND NOT len(arguments.stMetadata.value)>checked</cfif>> 
							generate based on "#arguments.stPackage.stProps[arguments.stMetadata.ftSourceField].metadata.ftLabel#"
							<input type="hidden" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="false" />
							</div>
							</cfoutput>
						</cfif>

						<!--- Can the user upload their own image. --->
						<cfif arguments.stMetadata.ftAllowUpload>
							<cfoutput>
							<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
							<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" class="formFile" style="#arguments.stMetadata.ftstyle#" />
							</cfoutput>
							
							<cfif structKeyExists(arguments.stMetadata, "ftImagewidth") AND arguments.stMetadata.ftImageWidth GT 0>
								<cfoutput><div>width:#arguments.stMetadata.ftImageWidth#</div></cfoutput>
							</cfif>
							<cfif structKeyExists(arguments.stMetadata, "ftImageHeight") AND arguments.stMetadata.ftImageHeight GT 0>
								<cfoutput><div>height:#arguments.stMetadata.ftImageHeight#</div></cfoutput>
							</cfif>
							<cfif structKeyExists(arguments.stMetadata, "ftAutoGenerateType")>
								<cfif arguments.stMetadata.ftAutoGenerateType EQ "Pad">
									<cfoutput><div>Padding image with #arguments.stMetadata.ftPadColor#</div></cfoutput>
								<cfelse>
									<cfoutput><div>#arguments.stMetadata.ftAutoGenerateType#</div></cfoutput>
								</cfif>
								
							</cfif>
						</cfif>
						
					<cfoutput>
					</td>
					</cfoutput>
					
					<cfif len(#arguments.stMetadata.value#)>
						<cfoutput>
						<td valign="top">
							<div id="#arguments.fieldname#previewimage">
								<img src="#arguments.stMetadata.value#" width="50px" title="#listLast(arguments.stMetadata.value,"/")#"><br>
								#listLast(arguments.stMetadata.value,"/")#
								<ft:farcryButton type="button" value="Delete Image" onclick="if(confirm('Are you sure you want to remove this image?')) {} else {return false};$('#arguments.fieldname#').value='';Effect.Fade('#arguments.fieldname#previewimage');" />
							</div>
						</td>
						</cfoutput>
					<cfelse>
						<cfoutput>
						<td valign="top">
							<div id="#arguments.fieldname#previewimage">
								&nbsp;
							</div>
						</td>
						</cfoutput>
					</cfif>				
					
			<cfoutput>
				</tr>
				</table>
			</cfoutput>					
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0">
		
		<cfsavecontent variable="html">
			<cfif len(arguments.stMetadata.value)>
				<cfoutput><img src="#arguments.stMetadata.value#" 
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
		
		<cfset var stResult = structNew()>
		<cfset var stGeneratedImageArgs = StructNew() />		
		<cfset var stGeneratedImage = structNew() />
		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftDestination" default="">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0" />
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0" />
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
		<cfparam name="arguments.stMetadata.ftThumbnailBevel" default="No">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.stMetadata.ftDestination) AND left(arguments.stMetadata.ftDestination,1) NEQ "/">
			<cfset arguments.stMetadata.ftDestination = "/#arguments.stMetadata.ftDestination#" />
		</cfif>
		
		<cfif NOT DirectoryExists("#application.path.imageRoot##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#application.path.imageRoot##arguments.stMetadata.ftDestination#">
		</cfif>		
		
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
	
			<cffile action="UPLOAD"
		        filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
		        destination="#application.path.imageRoot##arguments.stMetadata.ftDestination#"
				nameconflict="MAKEUNIQUE">
				
				<cfif len(arguments.stMetaData.ftImageWidth) OR len(arguments.stMetaData.ftImageHeight)>
					<cfset stGeneratedImageArgs.Source = "#application.path.imageRoot##arguments.stMetadata.ftDestination#/#File.ServerFile#" />
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

					<cfset stGeneratedImage = GenerateImage(Source="#stGeneratedImageArgs.Source#", Destination="#stGeneratedImageArgs.Destination#", Width="#stGeneratedImageArgs.Width#", Height="#stGeneratedImageArgs.Height#", AutoGenerateType="#stGeneratedImageArgs.AutoGenerateType#", PadColor="#stGeneratedImageArgs.PadColor#") />
					
					
					<cfif stGeneratedImage.bSuccess>
						<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#file.serverFile#" />
					</cfif>
				<cfelse>
					<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#file.serverFile#" />	
				</cfif>
				

		
		
			
		</cfif>
		

	
<!--- 		 --->
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
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
			
			<cfcase value="Pad">
				
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
			</cfcase>
		
		</cfswitch>
		 		
		<cfreturn stResult />
	</cffunction>
	
	
	
</cfcomponent> 
