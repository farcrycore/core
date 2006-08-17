

<cfcomponent name="Image" displayname="Image" Extends="field" hint="Field component to liase with all Image types"> 


	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/images">
		
		<cfset Request.inHead.Scriptaculous = 1>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<table>
				<tr>
					<td valign="top">
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
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftDestination" default="#application.config.image.SourceImageURL#">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="">
		<cfparam name="arguments.stMetadata.ftThumbnail" default="false"><!--- pads out the image to the required width/height --->
		<cfparam name="arguments.stMetadata.ftThumbnailBGColor" default="white">
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
			
		
		
			<!---
			<cfparam name="arguments.stFields['#i#'].metadata.ftImageWidth" default="#application.config.image.ThumbnailImageWidth#">
			<cfparam name="arguments.stFields['#i#'].metadata.ftImageHeight" default="#application.config.image.StandardImageURL#">
			<cfparam name="arguments.stFields['#i#'].metadata.ftDestination" default="#application.config.image.ThumbnailImageHeight#">
			<cfparam name="arguments.stFields['#i#'].metadata.ftAutoGenerateType" default="FitInside">
			
			<cfset stArgs = StructNew() />
			<cfset stArgs.Source = "#arguments.stProperties.SourceImage#" />
			<cfset stArgs.Width = "#arguments.stFields['#i#'].metadata.ftImageWidth#" />
			<cfset stArgs.Height = "#arguments.stFields['#i#'].metadata.ftImageHeight#" />
			<cfset stArgs.Destination = "#arguments.stFields['#i#'].metadata.ftDestination#" />			
			<cfset stArgs.AutoGenerateType = "#arguments.stFields['#i#'].metadata.ftAutoGenerateType#" />
			
			<cfset stProperties['#i#'] = GenerateImage(Source="#stArgs.Source#", Destination="#stArgs.Destination#", Width="#stArgs.Width#", Height="#stArgs.Height#", AutoGenerateType="#stArgs.AutoGenerateType#") />
			 --->

			<cfif arguments.stMetadata.ftThumbnail>
			
				<cfx_image action="resize"
					file="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
					output="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
					X="#arguments.stMetadata.ftImageWidth#"
					Y="#arguments.stMetadata.ftImageHeight#"
					thumbnail=yes
					bevel="#arguments.stMetadata.ftThumbnailBevel#"
					backcolor="#arguments.stMetadata.ftThumbnailBGColor#">
			
			<cfelse>
		

				
				<cfif len(arguments.stMetadata.ftImageWidth) AND arguments.stMetadata.ftImageWidth GT 0>
					<cfx_image action="read"
						file="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#">
						
					<cfif IMG_WIDTH GT arguments.stMetadata.ftImageWidth>
						<cfx_image action="resize"
								file="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
								output="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
								X="#arguments.stMetadata.ftImageWidth#">
					</cfif>
				</cfif>	
			
				<cfif len(arguments.stMetadata.ftImageHeight) AND arguments.stMetadata.ftImageHeight GT 0>
					<cfx_image action="read"
						file="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#">
						
					<cfif IMG_HEIGHT GT arguments.stMetadata.ftImageHeight>
						<cfx_image action="resize"
								file="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
								output="#application.path.project#/www#arguments.stMetadata.ftDestination#/#File.ServerFile#"
								Y="#arguments.stMetadata.ftImageHeight#">
					</cfif>
				</cfif>	
				
			</cfif>
					
									
			<!--- </cfif> --->
			<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#File.ServerFile#">
			
			
		</cfif>
		

	
<!--- 		 --->
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


	<cffunction name="GenerateImage" access="private" output="false" returntype="string">
		<cfargument name="Source" required="false" default="#application.config.image.StandardImageURL#" hint="The webroot URL where the image that is being used to generate this new image is located.">
		<cfargument name="Destination" required="false" default="#application.config.image.StandardImageURL#" hint="The webroot URL where the image will be stored.">
		<cfargument name="Width" required="false" default="#application.config.image.StandardImageWidth#" hint="The maximum width of the new image.">
		<cfargument name="Height" required="false" default="#application.config.image.StandardImageHeight#" hint="The maximum height of the new image.">
		<cfargument name="AutoGenerateType" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)">
		
		<!---
		FTAUTOGENERATETYPE OPTIONS
		ForceSize - Ignores source image aspect ratio and forces the new image to be the size set in the metadata width/height
		FitInside - Reduces the width and height so that it fits in the box defined by the metadata width/height
		Pad - Reduces the width and height so that it fits in the box defined by the metadata width/height and then pads the image so it ends up being the metadata width/height
		 --->
		 
		<!--- Image has changed --->
		<cfif NOT DirectoryExists("#application.path.project#/www#arguments.Destination#")>
			<cfdirectory action="create" directory="#application.path.project#/www#arguments.Destination#">
		</cfif>
		
		<cffile action="copy" 
			source="#application.path.project#/www#arguments.Source#"
			destination="#application.path.project#/www#arguments.Destination#" >

		
		<cfswitch expression="#arguments.AutoGenerateType#">
		
			<cfcase value="ForceSize">
				<!--- Simply force the resize of the image into the width/height provided --->
				<cfx_image action="resize"
					file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
					output="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
					X="#arguments.Width#"
					Y="#arguments.Height#">
			</cfcase>
			
			<cfcase value="FitInside">
				<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
				<cfx_image action="read"
					file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#">
					
				<cfif IMG_WIDTH GT arguments.Width>
					<cfx_image action="resize"
						file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
						output="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
						X="#arguments.Width#">
				</cfif>
					
				<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
				<cfx_image action="read"
					file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#">
					
				<cfif IMG_HEIGHT GT arguments.Height>
					<cfx_image action="resize"
						file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
						output="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
						Y="#arguments.Height#">
				</cfif>
				
			</cfcase>
			
			<cfcase value="Pad">
				<cfx_image action="resize"
					file="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
					output="#application.path.project#/www#arguments.Destination#/#File.ServerFile#"
					X="#arguments.Width#"
					Y="#arguments.Height#"
					Thumbnail=yes
					bevel=no
					backcolor="##4B0102">
			</cfcase>
		
		</cfswitch>
		 		
		<cfreturn "#arguments.Destination#/#File.ServerFile#" />
	</cffunction>
	
	
</cfcomponent> 
