

<cfcomponent name="Image" displayname="Image" Extends="field" hint="Field component to liase with all Image types"> 


	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.image" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/images">
		<cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="false">
		<cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
		
		<cfset Request.inHead.Scriptaculous = 1>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<table>
				<tr>
					<td valign="top">
						<cfif arguments.stMetadata.ftCreateFromSourceOption>
							<!--- TODO: If change to off then deactivate the browse button --->
							<div>
							<input type="checkbox" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="true" <cfif arguments.stMetadata.ftCreateFromSourceDefault>checked</cfif>> generate based on "Source Image"
							<input type="hidden" name="#arguments.fieldname#CreateFromSource" id="#arguments.fieldname#CreateFromSource" value="false" />
							</div>
						</cfif>
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" />
					</td>
					
					<cfif len(#arguments.stMetadata.value#)>
						<td valign="top">
							<div id="#arguments.fieldname#previewimage">
								<img src="#arguments.stMetadata.value#" width="50px">
								<ft:farcrybutton type="button" value="Delete Image" onclick="if(confirm('Are you sure you want to remove this image?')) {} else {return false};$('#arguments.fieldname#').value='';Effect.Fade('#arguments.fieldname#previewimage');" />
							</div>
						</td>
					</cfif>				
					
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

		<cfparam name="arguments.stMetadata.ftDestination" default="/images">
	

		<cfsavecontent variable="html">
			<cfoutput><img src="#arguments.stMetadata.value#"></cfoutput>			
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
		
		<cfparam name="arguments.stMetadata.ftDestination" default="#application.config.image.SourceImageURL#">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="#application.config.image.standardImageWidth#">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="#application.config.image.standardImageHeight#">
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
		<cfparam name="arguments.stMetadata.ftThumbnailBevel" default="No">
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		<cfif NOT DirectoryExists("#application.path.project#/www#arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#application.path.project#/www#arguments.stMetadata.ftDestination#">
		</cfif>		
		
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
	
			<cffile action="UPLOAD"
		        filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
		        destination="#application.path.project#/www#arguments.stMetadata.ftDestination#"
				nameconflict="MAKEUNIQUE">

				<cfif len(arguments.stMetaData.ftImageWidth) OR len(arguments.stMetaData.ftImageHeight)>
					<cfset stGeneratedImageArgs.Source = "#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#" />
					<cfset stGeneratedImageArgs.Destination = "" />			
					<cfset stGeneratedImageArgs.Width = "#arguments.stMetadata.ftImageWidth#" />
					<cfset stGeneratedImageArgs.Height = "#arguments.stMetadata.ftImageHeight#" />
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


	<cffunction name="GenerateImage" access="public" output="false" returntype="struct">
		<cfargument name="Source" required="true" hint="The absolute path where the image that is being used to generate this new image is located.">
		<cfargument name="Destination" required="false" default="" hint="The absolute path where the image will be stored.">
		<cfargument name="Width" required="false" default="#application.config.image.StandardImageWidth#" hint="The maximum width of the new image.">
		<cfargument name="Height" required="false" default="#application.config.image.StandardImageHeight#" hint="The maximum height of the new image.">
		<cfargument name="AutoGenerateType" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)">
		<cfargument name="PadColor" required="false" default="##ffffff" hint="If AutoGenerateType='Pad', image will be padded with this colour">
		<cfargument name="Bevel" required="false" default="no" hint="Will this image have a bevel edge">
		
		<cfset var ImageDestination = arguments.Source />
		<cfset var stResult = structNew() />
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
			
			<cfif NOT DirectoryExists("#ImageDestination#")>
				<cfdirectory action="create" directory="#ImageDestination#">
			</cfif>
					
			<cffile action="copy" 
				source="#arguments.Source#"
				destination="#ImageDestination#">
			
			<cfset ImageDestination = ImageDestination & "/#File.ServerFile#" />
			
			<cfset stResult.filename = File.ServerFile />	
		</cfif>
		
		<cfswitch expression="#arguments.AutoGenerateType#">
		
			<cfcase value="ForceSize">
				<!--- Simply force the resize of the image into the width/height provided --->
				<cfx_image action="resize"
					file="#ImageDestination#"
					output="#ImageDestination#"
					X="#arguments.Width#"
					Y="#arguments.Height#">
			</cfcase>
			
			<cfcase value="FitInside">
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
				</cfif>
				
			</cfcase>
			
			<cfcase value="Pad">
				<cfx_image action="resize"
					file="#ImageDestination#"
					output="#ImageDestination#"
					X="#arguments.Width#"
					Y="#arguments.Height#"
					Thumbnail=yes
					bevel="#lCase(yesnoformat(arguments.Bevel))#"
					backcolor="#arguments.PadColor#">
			</cfcase>
		
		</cfswitch>
		 		
		<cfreturn stResult />
	</cffunction>
	
	
</cfcomponent> 
