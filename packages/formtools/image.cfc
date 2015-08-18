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

<!--- @@examples:
	<p>This example is taken from dmImage.cfc in farcry core. It has a source Image example, standard image example and thumbnail image example</p>
	<cfproperty ftSeq="22" ftFieldset="Image Files" name="SourceImage" type="string" hint="The URL location of the uploaded image" required="No" default="" 
	ftType="Image" 
	ftCreateFromSourceOption="false" 
	ftAllowResize="false"
	ftDestination="/images/dmImage/SourceImage" 
	ftlabel="Source Image" 
	ftImageWidth="" 
	ftImageHeight=""
	ftbUploadOnly="true"
	ftHint="Upload your high quality source image here."  />

<cfproperty ftSeq="24" ftFieldset="Image Files" name="StandardImage" type="string" hint="The URL location of the optimised uploaded image that should be used for general display" required="no" default="" 
	ftType="Image" 
	ftDestination="/images/dmImage/StandardImage" 
	ftImageWidth="400" 
	ftImageHeight="1000" 
	ftAutoGenerateType="FitInside" 
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".75"
	ftlabel="Mid Size Image"
	ftHint="This image is generally used throughout your project as the main image. Most often you would have this created automatically from the high quality source image you upload." />  

<cfproperty ftSeq="26" ftFieldset="Image Files" name="ThumbnailImage" type="string" hint="The URL location of the thumnail of the uploaded image that should be used in " required="no" default="" 
	ftType="Image"  
	ftDestination="/images/dmImage/ThumbnailImage" 
	ftImageWidth="80" 
	ftImageHeight="80" 
	ftAutoGenerateType="center"
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".75"
	ftlabel="Thumbnail Image"
	ftHint="This image is generally used throughout your project as the thumbnail teaser image. Most often you would have this created automatically from the high quality source image you upload." />

<p>Image with no resize otions</p>

<cfproperty name="featureImage" type="string" hint="Feature image for Lysaght site (landscape)." required="no" default="" 
	ftwizardStep="Body" 
	ftseq="34" ftfieldset="Feature Image" 
	ftAllowResize="false"
	ftType="image" 
	ftDestination="/images/lysaght/bslCaseStudy/featureImage" 
	ftlabel="Feature Image" />

<p>Crop the first image from an array source field</p>

<cfproperty name="coverImage" type="string" required="no" default=""  
	ftwizardStep="News Body" 
	ftseq="43" ftfieldset="Images" 
	ftType="image"
	ftSourceField="aImages:SourceImage" 
	ftAutoGenerateType="center"
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true"
	ftImageWidth="150" ftImageHeight="150" 
	ftDestination="/images/dmNews/coverImage" 
	ftlabel="Cover Image 150x150" />

--->


<cfcomponent name="Image" displayname="image" Extends="field" hint="Field component to liase with all Image types">
	<!--- 
	 // documentation 
	--------------------------------------------------------------------------------------------------->
	<cfproperty name="ftstyle" type="string" hint="???" required="false" default="" />
	<cfproperty name="ftDestination" type="string" hint="???" required="false" default="/images" />
	<!--- <cfproperty name="ftSourceField" type="string" hint="???" required="false" default="" /> --->
	<cfproperty name="ftCreateFromSourceOption" type="boolean" hint="???" required="false" default="true" />
	<cfproperty name="ftCreateFromSourceDefault" type="boolean" hint="???" required="false" default="true" />
	<cfproperty name="ftAllowUpload" type="boolean" hint="If there is more than one image, e.g thumbnail, use this to allow uploading a different thumbnail or turn this off to only autogenerate thumbnail from source image" required="false" default="true" />
	<cfproperty name="ftAllowResize" type="boolean" hint="Will not allow any resize options if switched off" required="false" default="true" />
	<cfproperty name="ftAllowResizeQuality" type="boolean" hint="Will not allow any quality change options if switched off" required="false" default="false" />
	<cfproperty name="ftImageWidth" type="string" hint="Use to resize an image from a source image" required="false" default="" />
	<cfproperty name="ftImageHeight" type="string" hint="Use to resize an image from a source image" required="false" default="" />
	<cfproperty name="ftAutoGenerateType" type="string" hint="Auto generate options include: none, center, fitinside, forcesize, pad, topcenter, topleft, topright, left, right, bottomleft, bottomcenter, bottomright." required="false" default="FitInside" />
	<cfproperty name="ftPadColor" type="string" hint="If ftAutoGenerateType = pad, this will be the colour of the pad" required="false" default="##ffffff" />
	<cfproperty name="ftShowConversionInfo" type="boolean" hint="Set to false to hide the conversion information that will be applied to the uploaded image." required="false" default="true" />
	<cfproperty name="ftAllowedExtensions" type="string" hint="The extensions allowed to be uploaded." required="false" default="jpg,jpeg,png,gif" />
	<cfproperty name="ftcustomEffectsObjName" type="string" hint="<cfimage> support property" required="false" default="imageeffects" />
	<cfproperty name="ftlCustomEffects" type="string" hint="<cfimage> support property" required="false" default="" />
	<cfproperty name="ftConvertImageToFormat" type="string" hint="<cfimage> support property" required="false" default="" />
	<cfproperty name="ftbSetAntialiasing" type="boolean" hint="<cfimage> support property" required="false" default="true" />
	<cfproperty name="ftInterpolation" type="string" hint="<cfimage> support property" required="false" default="blackman" />
	<cfproperty name="ftQuality" type="numeric" hint="<cfimage> support property" required="false" default="1" />
	<cfproperty name="ftbUploadOnly" type="boolean" hint="Only upload the image and do not optimize or process it. Very useful for source images. Otherwise FarCry will optimize the source image, then read from that dequalitized image to make other optimized images. Can be used for any image field (not just source images)." required="false" default="false" />
	<cfproperty name="ftCropPosition" type="string" hint="Used when ftAutoGenerateType = aspectCrop" required="false" default="center" />
	<cfproperty name="ftThumbnailBevel" type="boolean" hint="???" required="false" default="false" />
	<cfproperty name="ftWatermark" type="string" hint="The path relative to the webroot of an image to use as a watermark." required="false" default="" />
	<cfproperty name="ftWatermarkTransparency" type="numeric" hint="The transparency to apply to the watermark." required="false" default="90" />
	<cfproperty name="ftSizeLimit" type="numeric" hint="File size limit for upload. 0 is no-limit" required="false" default="0" />
	<cfproperty name="ftShowMetadata" type="boolean" default="true" hint="If this is set to false, the file size and dimensions of the current image are not displayed to the user" />
	
	
	<!--- 
	 // formtool methods 
	--------------------------------------------------------------------------------------------------->
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
	    <cfset var stImage = structnew() />
	    <cfset var stFile = structnew() />
	    <cfset var predefinedCrops = { none="None",center="Crop Center",fitinside="Fit Inside",forcesize="Force Size",pad="Pad",topcenter="Crop Top Center",topleft="Crop Top Left",topright="Crop Top Right",left="Crop Left",right="Crop Right",bottomright="Crop Bottom Left",bottomright="Crop Bottom Center" } />
	    <cfset var stInfo = "" />
	    <cfset var metadatainfo = "" />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
	    <cfset var thisdependant = "" />
	    <cfset var stAltMeta = structnew() />
	    <cfset var bFileExists = getFileExists(arguments.stMetadata.value) />
	    <cfset var imagePath = "" />
	    <cfset var error = "" />
	    <cfset var imageMaxWidth = 400 />
		
		
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
	    
	    <cfparam name="arguments.stMetadata.ftstyle" default="">
	    <cfparam name="arguments.stMetadata.ftDestination" default="/images">
	    <cfparam name="arguments.stMetadata.ftSourceField" default="">
	    <cfparam name="arguments.stMetadata.ftInlineDependants" default="">
	    <cfparam name="arguments.stMetadata.ftInlineUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResize" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
		<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
		<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    <cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
	    <cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
	    <cfparam name="arguments.stMetadata.ftShowConversionInfo" default="true"><!--- Set to false to hide the conversion information that will be applied to the uploaded image --->
	    <cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
	    <cfparam name="arguments.stMetadata.ftSizeLimit" default="0" />
		
	    <skin:loadJS id="fc-jquery" />
	    <skin:loadCSS id="jquery-ui" />
	    <skin:loadJS id="jquery-tooltip" />
	    <skin:loadJS id="jquery-tooltip-auto" />
	    <skin:loadCSS id="jquery-tooltip" />
	    <skin:loadJS id="jquery-uploadify" />
	    <skin:loadCSS id="jquery-uploadify" />
	    <skin:loadJS id="jquery-crop" />
	    <skin:loadCSS id="jquery-crop" />
	    <skin:loadCSS id="fc-fontawesome" />
	    
	    <skin:loadCSS id="image-formtool" />
		<skin:loadJS id="image-formtool" />
		<skin:htmlHead><cfoutput>
			<script type="text/javascript">
				$fc.imageformtool.buttonImg = '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4//selectImage.png';
				$fc.imageformtool.uploader = '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/uploadify.swf';
				$fc.imageformtool.cancelImg = '#application.url.webtop#/thirdparty/jquery.uploadify-v2.1.4/cancel.png';
			</script>
		</cfoutput></skin:htmlHead>
	    
	    <cfsavecontent variable="metadatainfo">
			<cfif (isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0) or (isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0)>
				<cfoutput>Dimensions: <cfif isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0>#arguments.stMetadata.ftImageWidth#<cfelse>any width</cfif> x <cfif isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0>#arguments.stMetadata.ftImageHeight#<cfelse>any height</cfif> (#predefinedCrops[arguments.stMetadata.ftAutoGenerateType]#)<br>Quality Setting: #round(arguments.stMetadata.ftQuality*100)#%<br></cfoutput>
			</cfif>
			<cfoutput>Image must be of type #arguments.stMetadata.ftAllowedExtensions#</cfoutput>
		</cfsavecontent>
	    
		<cfif bFileExists>
			<cfset stImage = getImageInfo(file=arguments.stMetadata.value,admin=true) />
			<cfif stImage.width lt imageMaxWidth>
				<cfset imageMaxWidth = stImage.width>
			</cfif>
		</cfif>

	    <cfif len(arguments.stMetadata.value)>
			<cfif not bFileExists>
				<cfset arguments.stMetadata.value = "" />
				<cfset error = application.fapi.getResource("formtools.image.message.imagenotfound@text","The previous image can't be found in the file system. You should upload a new image or talk to your administrator before saving.") />
			<cfelse>
				<cfset imagePath = getFileLocation(stObject=arguments.stObject,stMetadata=arguments.stMetadata,admin=true).path />
			</cfif>
		</cfif>
	    
		<cfif len(arguments.stMetadata.ftSourceField)>
			
			<!--- This image will be generated from the source field --->
			<cfsavecontent variable="html"><cfoutput>
				<div class="multiField" style="padding-top:5px">
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
					<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
					<div id="#arguments.fieldname#-multiview">
						<cfif arguments.stMetadata.ftAllowUpload>
							<div id="#arguments.fieldname#_upload" class="upload-view" style="display:none;">
								<a href="##traditional" class="fc-btn select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw"></i></a>
								<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
								<div id="#arguments.fieldname#_uploaderror" class="alert alert-error" style="margin-top:0.7em;margin-bottom:0.7em;<cfif not len(error)>display:none;</cfif>">#error#</div>
								<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
								<div class="image-cancel-upload" style="clear:both;"><i class="fa fa-times-cirlce-o fa-fw"></i> <a href="##back" class="select-view">Cancel - I don't want to upload an image</a></div>
							</div>
							<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
								<a href="##back" class="fc-btn select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw"></i></a>
								<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
								<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
								<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><i class="fa fa-times-cirlce-o"></i> <a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
							</div>
							<div id="#arguments.fieldname#_delete" class="delete-view" style="display:none;">
								<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
								<ft:button class="image-delete-button" id="#arguments.fieldname#DeleteThis" type="button" value="Delete this image" onclick="return false;" />						    		
								<div class="image-cancel-upload"><i class="fa fa-times-cirlce-o fa-fw"></i> <a href="##back" class="select-view">Cancel - I don't want to delete</a></div>
							</div>
						</cfif>
						<div id="#arguments.fieldname#_autogenerate" class="autogenerate-view"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
							<span class="image-status" title="#metadatainfo#"><i class="fa fa-question-circle fa-fw"></i></span>
							Image will be automatically generated based on the image selected for #application.stCOAPI[arguments.typename].stProps[listfirst(arguments.stMetadata.ftSourceField,":")].metadata.ftLabel#.<br>
							<cfif arguments.stMetadata.ftAllowResize>
								<div class="image-custom-crop"<cfif not structkeyexists(arguments.stObject,arguments.stMetadata.ftSourceField) or not len(arguments.stObject[listfirst(arguments.stMetadata.ftSourceField,":")])> style="display:none;"</cfif>>
									<input type="hidden" name="#arguments.fieldname#RESIZEMETHOD" id="#arguments.fieldname#RESIZEMETHOD" value="" />
									<input type="hidden" name="#arguments.fieldname#QUALITY" id="#arguments.fieldname#QUALITY" value="" />
									<i class="fa fa-crop fa-fw"></i> <ft:button value="Select Exactly How To Crop Your Image" class="image-crop-select-button" type="button" onclick="return false;" />
									<div id="#arguments.fieldname#_croperror" class="alert alert-error" style="margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
									<div class="alert alert-info image-crop-information" style="padding:0.7em;margin-top:0.7em;display:none;">Your crop settings will be applied when you save. <a href="##" class="image-crop-cancel-button">Cancel custom crop</a></div>
								</div>
							</cfif>
							<div><i class="fa fa-cloud-upload fa-fw"></i> <cfif arguments.stMetadata.ftAllowUpload><a href="##upload" class="select-view">Upload - I want to use my own image</a></cfif><span class="image-cancel-replace" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><cfif arguments.stMetadata.ftAllowUpload> | </cfif><a href="##complete" class="select-view">Cancel - I don't want to replace this image</a></span></div>
						</div>
						<div id="#arguments.fieldname#_working" class="working-view" style="display:none;">
							<span class="image-status" title="#metadatainfo#"><i class="fa fa-spinner fa-spin fa-fw"></i></span>
						    <div style="margin-left:15px;">Generating image...</div>
						</div>
						<cfif bFileExists>
							<div id="#arguments.fieldname#_complete" class="complete-view">
								<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
								<span class="image-filename">#listfirst(listlast(arguments.stMetadata.value,"/"),"?")#</span> ( <a class="image-preview fc-richtooltip" data-tooltip-position="bottom" data-tooltip-width="#imageMaxWidth#" title="<img src='#imagePath#' style='max-width:400px; max-height:400px;' />" href="#imagePath#" target="_blank">Preview</a><span class="regenerate-link"> | <a href="##autogenerate" class="select-view">Regenerate</a></span> <cfif arguments.stMetadata.ftAllowUpload>| <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a></cfif> )<br>
								<cfif arguments.stMetadata.ftShowMetadata>
									<i class="fa fa-info-circle-o fa-fw"></i> Size: <span class="image-size">#round(stImage.size / 1024)#</span>KB, Dimensions: <span class="image-width">#stImage.width#</span>px x <span class="image-height">#stImage.height#</span>px
									<div class="image-resize-information alert alert-info" style="margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
								</cfif>
							</div>
						<cfelse>
							<div id="#arguments.fieldname#_complete" class="complete-view" style="display:none;">
								<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
								<span class="image-filename"></span> ( <a class="image-preview fc-richtooltip" data-tooltip-position="bottom" data-tooltip-width="#imageMaxWidth#" title="<img src='' style='max-width:400px; max-height:400px;' />" href="##" target="_blank">Preview</a><span class="regenerate-link"> | <a href="##autogenerate" class="select-view">Regenerate</a></span> <cfif arguments.stMetadata.ftAllowUpload>| <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a></cfif> )<br>
								<cfif arguments.stMetadata.ftShowMetadata>
									<i class="fa fa-info-circle-o fa-fw"></i> Size: <span class="image-size"></span>KB, Dimensions: <span class="image-width"></span>px x <span class="image-height"></span>px
									<div class="image-resize-information alert alert-info" style="margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
								</cfif>
							</div>
						</cfif>
					</div>
					<script type="text/javascript">$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#arguments.stMetadata.ftSourceField#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#,false,#arguments.stMetadata.ftSizeLimit#);</script>
				</div>
			</cfoutput></cfsavecontent>
			
		<cfelse>
			
			<!--- This IS the source field --->
		    <cfsavecontent variable="html"><cfoutput>
			    <div class="multiField">
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
					<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
					<div id="#arguments.fieldname#-multiview">
						<div id="#arguments.fieldname#_upload" class="upload-view"<cfif len(arguments.stMetadata.value)> style="display:none;"</cfif>>
							<a href="##traditional" class="fc-btn select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw">&nbsp;</i></a>
							<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
							<div id="#arguments.fieldname#_uploaderror" class="alert alert-error" style="margin-top:0.7em;margin-bottom:0.7em;<cfif not len(error)>display:none;</cfif>">#error#</div>
							<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
							<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><i class="fa fa-times-cirlce-o fa-fw"></i> <a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
						</div>
						<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
							<a href="##back" class="fc-btn select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw">&nbsp;</i></a>
							<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
							<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
							<div class="image-cancel-upload" style="clear:both;<cfif not len(arguments.stMetadata.value)>display:none;</cfif>"><i class="fa fa-times-cirlce-o fa-fw"></i> <a href="##back" class="select-view">Cancel - I don't want to replace this image</a></div>
						</div>
						<div id="#arguments.fieldname#_delete" class="delete-view" style="display:none;">
							<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
							<ft:button class="image-delete-button" value="Delete this image" type="button" onclick="return false;" />
							<ft:button class="image-deleteall-button" value="Delete this and the related images" type="button" onclick="return false;" />
							<div class="image-cancel-upload"><i class="fa fa-times-cirlce-o fa-fw"></i> <a href="##back" class="select-view">Cancel - I don't want to delete</a></div>
						</div>
						<cfif bFileExists>
							<div id="#arguments.fieldname#_complete" class="complete-view">
								<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
								<span class="image-filename">#listfirst(listlast(arguments.stMetadata.value,"/"),"?")#</span> ( <a class="image-preview fc-richtooltip" data-tooltip-position="bottom" data-tooltip-width="#imageMaxWidth#" title="<img src='#imagePath#' style='max-width:400px; max-height:400px;' />" href="#imagePath#" target="_blank">Preview</a> | <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a> )<br>
								<cfif arguments.stMetadata.ftShowMetadata>
									<i class="fa fa-info-circle-o fa-fw"></i> Size: <span class="image-size">#round(stImage.size / 1024)#</span>KB, Dimensions: <span class="image-width">#stImage.width#</span>px x <span class="image-height">#stImage.height#</span>px
									<div class="image-resize-information alert alert-info" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
								</cfif>
							</div>
						<cfelse>
						    <div id="#arguments.fieldname#_complete" class="complete-view" style="display:none;">
								<span class="image-status" title=""><i class="fa fa-picture-o fa-fw"></i></span>
								<span class="image-filename"></span> ( <a class="image-preview fc-richtooltip" data-tooltip-position="bottom" data-tooltip-width="#imageMaxWidth#" title="<img src='' style='max-width:400px; max-height:400px;' />" href="##" target="_blank">Preview</a> | <a href="##upload" class="select-view">Upload</a> | <a href="##delete" class="select-view">Delete</a> )<br>
								<cfif arguments.stMetadata.ftShowMetadata>
									<i class="fa fa-info-circle-o fa-fw"></i> Size: <span class="image-size"></span>KB, Dimensions: <span class="image-width"></span>px x <span class="image-height"></span>px
									<div class="image-resize-information alert alert-info" style="padding:0.7em;margin-top:0.7em;display:none;">Resized to <span class="image-width"></span>px x <span class="image-height"></span>px (<span class="image-quality"></span>% quality)</div>
								</cfif>
							</div>
						</cfif>
					</div>
					<script type="text/javascript">$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#arguments.stMetadata.ftSourceField#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#,false,#arguments.stMetadata.ftSizeLimit#);</script>
					<cfif len(arguments.stMetadata.ftInlineDependants)><div style="margin-top: 10px; margin-left: 20px; font-weight: bold; font-style: italic;">Image sizes:</div></cfif>
				</cfoutput>
				
				<cfloop list="#arguments.stMetadata.ftInlineDependants#" index="thisdependant">
					<cfif structkeyexists(arguments.stObject,thisdependant)>
						<cfset stAltMeta = duplicate(arguments.stPackage.stProps[thisdependant].metadata) />
						<cfset stAltMeta.ftAllowUpload = arguments.stMetadata.ftInlineUpload />
						<cfset stAltMeta.value = arguments.stObject[stAltMeta.name] />
						<cfoutput>#editInline(typename=arguments.typename,stObject=arguments.stObject,stMetadata=stAltMeta,fieldname="#prefix##stAltMeta.name#",stPackage=arguments.stPackage,prefix=prefix)#</cfoutput>
					</cfif>
				</cfloop>
				
				<cfoutput></div></cfoutput>
		    </cfsavecontent>
			
		</cfif>
	    
	    <cfreturn html>
	</cffunction>

	<cffunction name="editInline" output="false" returntype="string" hint="UI for editing a dependant image inline as part of the source field">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	    <cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	    <cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	    <cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	    <cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
	    <cfargument name="prefix" required="true" type="string" hint="Form prefix" />
	    
		<cfset var html = "" />
		<cfset var metadatainfo = "" />
		<cfset var preview = "" />
		<cfset var predefinedCrops = { none="None",center="Crop Center",fitinside="Fit Inside",forcesize="Force Size",pad="Pad",topcenter="Crop Top Center",topleft="Crop Top Left",topright="Crop Top Right",left="Crop Left",right="Crop Right",bottomright="Crop Bottom Left",bottomright="Crop Bottom Center" } />
	    <cfset var stImage = structnew() />
	    <cfset var stFile = structnew() />
	    <cfset var bFileExists = getFileExists(arguments.stMetadata.value) />
	    <cfset var imagePath = "" />
	    <cfset var error = "" />
	    
		<cfparam name="arguments.stMetadata.ftHint" default="" />
	    <cfparam name="arguments.stMetadata.ftstyle" default="">
	    <cfparam name="arguments.stMetadata.ftDestination" default="/images">
	    <cfparam name="arguments.stMetadata.ftSourceField" default="">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceOption" default="true">
	    <cfparam name="arguments.stMetadata.ftCreateFromSourceDefault" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowUpload" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResize" default="true">
	    <cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
		<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
		<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    <cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
	    <cfparam name="arguments.stMetadata.ftPadColor" default="##ffffff">
	    <cfparam name="arguments.stMetadata.ftShowConversionInfo" default="true"><!--- Set to false to hide the conversion information that will be applied to the uploaded image --->
	    <cfparam name="arguments.stMetadata.ftAllowedExtensions" default="jpg,jpeg,png,gif"><!--- The extentions allowed to be uploaded --->
	    <cfparam name="arguments.stMetadata.ftSizeLimit" default="0" />
		
	    <!--- Metadata --->
	    <cfsavecontent variable="metadatainfo">
			<cfif (isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0) or (isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0)>
				<cfoutput>Dimensions: <cfif isnumeric(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth gt 0>#arguments.stMetadata.ftImageWidth#<cfelse>any width</cfif> x <cfif isnumeric(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight gt 0>#arguments.stMetadata.ftImageHeight#<cfelse>any height</cfif> (#predefinedCrops[arguments.stMetadata.ftAutoGenerateType]#)<br>Quality Setting: #round(arguments.stMetadata.ftQuality*100)#%<br></cfoutput>
			</cfif>
			<cfoutput>Image must be of type #arguments.stMetadata.ftAllowedExtensions#</cfoutput>
		</cfsavecontent>
		
		<!--- Preview --->
		<cfif bFileExists>
			<cfset preview = "<img src='#getFileLocation(stObject=arguments.stObject,stMetadata=arguments.stMetadata,admin=true).path#' style='width:400px; max-width:400px; max-height:400px;' />" />
			<cfif arguments.stMetadata.ftShowMetadata>
				<cfset stImage = getImageInfo(file=arguments.stMetadata.value,admin=true) />
				<cfset preview = preview & "<br><div style='width:#previewwidth#px;'>#round(stImage.size/1024)#</span>KB, #stImage.width#px x #stImage.height#px</div>" />
			</cfif>
		<cfelse>
			<cfset preview = "" />
		</cfif>
	    
		<cfsavecontent variable="html"><cfoutput>
			<div id="#arguments.fieldname#-inline" style="margin-left:20px;">
			
				<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
				<input type="hidden" name="#arguments.fieldname#RESIZEMETHOD" id="#arguments.fieldname#RESIZEMETHOD" value="" />
				<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="false" />
				<span class="image-status" title="<cfif len(arguments.stMetadata.ftHint)>#arguments.stMetadata.ftHint#<br></cfif>#metadatainfo#"><i class="fa fa-picture-o fa-fw"></i></span>
				<span class="dependant-label">#arguments.stMetadata.ftLabel#</span>
				<span class="dependant-options"<cfif not len(arguments.stMetadata.value) and not len(arguments.stObject[arguments.stMetadata.ftSourceField]) and not arguments.stMetadata.ftAllowUpload> style="display:none;"</cfif>>
					(
						<span class="not-cancel">
							<span class="action-preview action"<cfif not len(arguments.stMetadata.value)> style="display:none;"</cfif>>
								<a class="image-preview" href="#application.url.imageroot##arguments.stMetadata.value#" target="_blank" title="#preview#">Preview</a> | 
							</span>
							<span class="action-crop action"<cfif not len(arguments.stObject[listfirst(arguments.stMetadata.ftSourceField,":")])> style="display:none;"</cfif>>
								<a class="image-crop-select-button" href="##">Custom crop</a><cfif arguments.stMetadata.ftAllowUpload> | </cfif>
							</span>
							<cfif arguments.stMetadata.ftAllowUpload><span class="action-upload action"><a href="##upload" class="image-upload-select-button select-view">Upload</a></span></cfif>
						</span>
						<cfif arguments.stMetadata.ftAllowUpload><span class="action-cancel action" style="display:none;"><a href="##cancel" class="select-view">Cancel</a></span></cfif>
					)
				</span>
				<cfif arguments.stMetadata.ftAllowUpload>
					<div id="#arguments.fieldname#-multiview">
						<div id="#arguments.fieldname#_cancel" class="cancel-view"></div>
				    	<div id="#arguments.fieldname#_upload" class="upload-view" style="display:none;">
			    			<a href="##traditional" class="select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw">&nbsp;</i></a>
				    		<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" />
				    		<div id="#arguments.fieldname#_uploaderror" class="alert alert-error" style="margin-top:0.7em;margin-bottom:0.7em;display:none;"></div>
				    		<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
						</div>
				    	<div id="#arguments.fieldname#_traditional" class="traditional-view" style="display:none;">
			    			<a href="##upload" class="select-view" style="float:left" title="Switch between traditional upload and inline upload"><i class="fa fa-random fa-fw">&nbsp;</i></a>
				    		<input type="file" name="#arguments.fieldname#TRADITIONAL" id="#arguments.fieldname#TRADITIONAL" />
				    		<div><i title="#metadatainfo#" class="fa fa-question-circle fa-fw"></i> <span>Select an image to upload from your computer.</span></div>
						</div>
					</div>
				</cfif>
				<script type="text/javascript">$fc.imageformtool('#arguments.prefix#','#arguments.stMetadata.name#').init('#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=true)#','#replace(rereplace(arguments.stMetadata.ftAllowedExtensions,"(^|,)(\w+)","\1*.\2","ALL"),",",";","ALL")#','#arguments.stMetadata.ftSourceField#',#arguments.stMetadata.ftImageWidth#,#arguments.stMetadata.ftImageHeight#,true,#arguments.stMetadata.ftSizeLimit#);</script>
				<br class="clear">
			</div>
		</cfoutput></cfsavecontent>
		
		<cfreturn html />
	</cffunction>

	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stResult = structnew() />
		<cfset var stFixed = structnew() />
		<cfset var stSource = structnew() />
		<cfset var stFile = structnew() />
		<cfset var stImage = structnew() />
		<cfset var stLoc = structnew() />
		<cfset var resizeinfo = "" />
		<cfset var sourceField = "" />
		<cfset var html = "" />
		<cfset var json = "" />
		<cfset var stJSON = structnew() />
	    <cfset var prefix = left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name)) />
		
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<cfif structkeyexists(url,"check")>
			<cfif isdefined("url.callback")>
				<cfreturn "#url.callback#([])" />
			<cfelse>
				<cfreturn "[]" />
			</cfif>
		</cfif>
		
		<cfif structkeyexists(url,"crop")>
			<cfset stSource = arguments.stObject />
			<cfset sourceField = listfirst(arguments.stMetadata.ftSourceField,":") />
			<cfif isArray(stSource[sourceField]) and arrayLen(stSource[sourceField])>
				<cfset stSource = application.fapi.getContentObject(objectid=stSource[sourceField][1]) />
				<cfset sourceField = listlast(arguments.stMetadata.ftSourceField,":") />
			<cfelseif issimplevalue(stSource[sourceField]) and isvalid("uuid",stSource[sourceField])>
				<cfset stSource = application.fapi.getContentObject(objectid=stSource[sourceField]) />
				<cfset sourceField = listlast(arguments.stMetadata.ftSourceField,":") />
			</cfif>
			
			<cfif not structkeyexists(arguments.stMetadata,"ftImageWidth") or not isnumeric(arguments.stMetadata.ftImageWidth)><cfset arguments.stMetadata.ftImageWidth = 0 /></cfif>
			<cfif not structkeyexists(arguments.stMetadata,"ftImageHeight") or not isnumeric(arguments.stMetadata.ftImageHeight)><cfset arguments.stMetadata.ftImageHeight = 0 /></cfif>
	    	<cfparam name="arguments.stMetadata.ftAllowResizeQuality" default="false">
	    	<cfparam name="url.allowcancel" default="1" />
	    	
			<cfif len(sourceField)>
				<cfset stLoc = getFileLocation(stObject=stSource,stMetadata=application.stCOAPI[stSource.typename].stProps[sourceField].metadata,admin=true) />
				
				<cfsavecontent variable="html"><cfoutput>
					<div style="float:left;background-color:##cccccc;height:100%;width:65%;margin-right:1%;">
						<img id="cropable-image" src="#stLoc.path#" style="max-width:none;" />
					</div>
					<div style="float:left;width:33%;">
						<div class="image-crop-instructions" style="overflow-y:auto;overlow-y:hidden;">
							<p class="image-resize-information alert alert-info">
								<strong style="font-weight:bold">Selection:</strong><br>
								Coordinates: (<span id="image-crop-a-x">?</span>,<span id="image-crop-a-y">?</span>) to (<span id="image-crop-b-x">?</span>,<span id="image-crop-b-y">?</span>)<br>
								<span id="image-crop-dimensions">Dimensions: <span id="image-crop-width">?</span>px x <span id="image-crop-height">?</span>px</span><br>
								<cfif arguments.stMetadata.ftImageWidth gt 0 and arguments.stMetadata.ftImageHeight gt 0>
									Ratio: 
									<cfif arguments.stMetadata.ftImageWidth gt arguments.stMetadata.ftImageHeight>
										#numberformat(arguments.stMetadata.ftImageWidth/arguments.stMetadata.ftImageHeight,"9.99")#:1
									<cfelseif arguments.stMetadata.ftImageWidth lt arguments.stMetadata.ftImageHeight>
										1:#numberformat(arguments.stMetadata.ftImageHeight/arguments.stMetadata.ftImageWidth,"9.99")#
									<cfelse><!--- Equal --->
										1:1
									</cfif> <span style="font-style:italic;">(Fixed aspect ratio)</span><br>
								<cfelse>
									Ratio: <span id="image-crop-ratio-num">?</span>:<span id="image-crop-ratio-den">?</span><br>
								</cfif>
								<strong style="font-weight:bold">Output:</strong><br>
								Dimensions: <span id="image-crop-width-final">#arguments.stMetadata.ftImageWidth#</span>px x <span id="image-crop-height-final">#arguments.stMetadata.ftImageHeight#</span>px<br>
								Quality: <cfif arguments.stMetadata.ftAllowResizeQuality><input id="image-crop-quality" value="#arguments.stMetadata.ftQuality#" /><cfelse>#round(arguments.stMetadata.ftQuality*100)#%<input type="hidden" id="image-crop-quality" value="#arguments.stMetadata.ftQuality#" /></cfif>
							</p>
							<p id="image-crop-warning" class="alert alert-warning" style="display:none;">
								<strong style="font-weight:bold">Warning:</strong> The selected crop area is smaller than the output size. To avoid poor image quality choose a larger crop or use a higher resolution source image.
							</p>							
							<p style="margin-top: 0.7em">To select a crop area:</p>
							<ol style="padding-left:10px;padding-top:0.7em">
								<li style="list-style:decimal outside;">Click and drag from the point on the image where the top left corner of the crop will start to the bottom right corner where the crop will finish.</li>
								<li style="list-style:decimal outside;">You can drag the selection box around the image if it isn't in the right place, or drag the edges and corners if the box isn't the right shape.</li>
								<li style="list-style:decimal outside;">Click "Crop and Resize" when you're done.</li>
							</ol>
						</div>
						<div class="image-crop-actions">
							<button id="image-crop-finalize" class="btn btn-large btn-primary" onclick="$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').finalizeCrop();return false;">Crop and Resize</button>
							<cfif url.allowcancel>
								<a href="##" id="image-crop-cancel" class="btn btn-link" style="border:none;box-shadow:none;background:none">Cancel</a>
							</cfif>
						</div>
					</div>
				</cfoutput></cfsavecontent>
				
				<cfreturn html />
			<cfelse>
				<cfreturn "<p>The source field is empty. <a href='##' onclick='$fc.imageformtool('#prefix#','#arguments.stMetadata.name#').endCrop();return false;'>Close</a></p>" />
			</cfif>
		</cfif>
		
		<cfset stResult = handleFilePost(
				objectid=arguments.stObject.objectid,
				existingfile=arguments.stMetadata.value,
				uploadfield="#arguments.stMetadata.name#NEW",
				destination=arguments.stMetadata.ftDestination,
				allowedExtensions=arguments.stMetadata.ftAllowedExtensions,
				stFieldPost=arguments.stFieldPost.stSupporting,
				sizeLimit=arguments.stMetadata.ftSizeLimit,
				bArchive=application.stCOAPI[arguments.typename].bArchive and (not structkeyexists(arguments.stMetadata,"ftArchive") or arguments.stMetadata.ftArchive)
			) />
		
		<cfif isdefined("stResult.stError.message") and len(stResult.stError.message)>
			<cfset stJSON = structnew() />
			<cfset stJSON["error"] = stResult.stError.message />
			<cfset stJSON["value"] = stResult.value />
			
			<cfif isdefined("url.callback")>
				<cfreturn "#url.callback#(#serializeJSON(stJSON)#)" />
			<cfelse>
				<cfreturn serializeJSON(stJSON) />
			</cfif>
		</cfif>
		
		<cfif stResult.bChanged>
		
			<cfif isdefined("stResult.value") and len(stResult.value)>
			
				<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod") or not isnumeric(arguments.stFieldPost.stSupporting.ResizeMethod)><cfset arguments.stFieldPost.stSupporting.ResizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
				<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"Quality") or not isnumeric(arguments.stFieldPost.stSupporting.Quality)><cfset arguments.stFieldPost.stSupporting.Quality = arguments.stMetadata.ftQuality /></cfif>
				
				<cfset stFixed = fixImage(stResult.value,arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
				
				<cfset stJSON = structnew() />
				<cfif stFixed.bSuccess>
					<cfset stJSON["resizedetails"] = structnew() />
					<cfset stJSON["resizedetails"]["method"] = arguments.stFieldPost.stSupporting.ResizeMethod />
					<cfset stJSON["resizedetails"]["quality"] = round(arguments.stFieldPost.stSupporting.Quality*100) />
					<cfset stResult.value = stFixed.value />
				<cfelseif structkeyexists(stFixed,"error")>
					<!--- Do nothing - an error from fixImage means there was no resize --->
				</cfif>
				
				<cfif not structkeyexists(stResult,"error")>
					<cfset stImage = duplicate(arguments.stObject) />
					<cfset stImage[arguments.stMetadata.name] = stFixed.value />
					<cfset stLoc = getFileLocation(stObject=stImage,stMetadata=arguments.stMetadata,admin=true) />
					
					<cfset stJSON["value"] = stFixed.value />
					<cfset stJSON["filename"] = listfirst(listlast(stResult.value,'/'),"?") />
					<cfset stJSON["fullpath"] = stLoc.path />
					
					<cfif arguments.stMetadata.ftShowMetadata>
						<cfset stImage = getImageInfo(stFixed.value,true) />
						<cfset stJSON["size"] = round(stImage.size / 1024) />
						<cfset stJSON["width"] = stImage.width />
						<cfset stJSON["height"] = stImage.height />
					<cfelse>
						<cfset stJSON["size"] = 0 />
						<cfset stJSON["width"] = 0 />
						<cfset stJSON["height"] = 0 />
					</cfif>
				
					<cfset onFileChange(typename=arguments.typename,objectid=arguments.stObject.objectid,stMetadata=arguments.stMetadata,value=stFixed.value) />
				</cfif>
				
				<cfif isdefined("url.callback")>
					<cfreturn "#url.callback#(#serializeJSON(stJSON)#)" />
				<cfelse>
					<cfreturn serializeJSON(stJSON) />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif (not len(stResult.value) or structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod")) and structkeyexists(arguments.stMetadata,"ftSourceField") and len(arguments.stMetadata.ftSourceField)>
		
			<cfset stResult = handleFileSource(sourceField=arguments.stMetadata.ftSourceField,stObject=arguments.stObject,destination=arguments.stMetadata.ftDestination,stFields=application.stCOAPI[arguments.typename].stProps) />
			
			<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"ResizeMethod") or not len(arguments.stFieldPost.stSupporting.ResizeMethod)><cfset arguments.stFieldPost.stSupporting.ResizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
			<cfif not structkeyexists(arguments.stFieldPost.stSupporting,"Quality") or not isnumeric(arguments.stFieldPost.stSupporting.Quality)><cfset arguments.stFieldPost.stSupporting.Quality = arguments.stMetadata.ftQuality /></cfif>
				
			<cfif len(stResult.value)>
				<cfparam name="form.bForceCrop" default="false">
				<cfset stFixed = fixImage(stResult.value,arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality,form.bForceCrop) />
				
				<cfset stJSON = structnew() />
				<cfif stFixed.bSuccess>
					<cfset stJSON["resizedetails"] = structnew() />
					<cfset stJSON["resizedetails"]["method"] = arguments.stFieldPost.stSupporting.ResizeMethod />
					<cfset stJSON["resizedetails"]["quality"] = round(arguments.stFieldPost.stSupporting.Quality*100) />
				<cfelseif structkeyexists(stFixed,"error")>
					<!--- Do nothing - an error from fixImage means there was no resize --->
				</cfif>
				
				<cfif not structkeyexists(stResult,"error")>
					<cfset stImage = duplicate(arguments.stObject) />
					<cfset stImage[arguments.stMetadata.name] = stFixed.value />
					<cfset stLoc = getFileLocation(stObject=stImage,stMetadata=arguments.stMetadata,admin=true) />
					
					<cfset stJSON["value"] = stFixed.value />
					<cfset stJSON["filename"] = listfirst(listlast(stResult.value,'/'),"?") />
					<cfset stJSON["fullpath"] = stLoc.path />
					<cfset stJSON["q"] = cgi.query_string />
					
					<cfif arguments.stMetadata.ftShowMetadata>
						<cfset stImage = getImageInfo(stFixed.value,true) />
						<cfset stJSON["size"] = round(stImage.size / 1024) />
						<cfset stJSON["width"] = stImage.width />
						<cfset stJSON["height"] = stImage.height />
					<cfelse>
						<cfset stJSON["size"] = 0 />
						<cfset stJSON["width"] = 0 />
						<cfset stJSON["height"] = 0 />
					</cfif>
					
					<cfset onFileChange(typename=arguments.typename,objectid=arguments.stObject.objectid,stMetadata=arguments.stMetadata,value=stFixed.value) />
				</cfif>
				
				<cfif isdefined("url.callback")>
					<cfreturn "#url.callback#(#serializeJSON(stJSON)#)" />
				<cfelse>
					<cfreturn serializeJSON(stJSON) />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif isdefined("url.callback")>
			<cfreturn "#url.callback#({})" />
		<cfelse>
			<cfreturn "{}" />
		</cfif>
	</cffunction>
	
	<cffunction name="fixImage" access="public" output="false" returntype="struct" hint="Fixes an image's size, returns true if the image needed to be corrected and false otherwise">
		<cfargument name="filename" type="string" required="true" hint="The image" />
		<cfargument name="stMetadata" type="struct" required="true" hint="Property metadata" />
		<cfargument name="resizeMethod" type="string" required="true" default="#arguments.stMetadata.ftAutoGenerateType#" hint="The resizing method to use to fix the size." />
		<cfargument name="quality" type="string" required="true" default="#arguments.stMetadata.ftQuality#" hint="Quality setting to use for resizing" />
		<cfargument name="bForceCrop" type="boolean" required="false" default="false" hint="Used to force the custom cropping" />
	
		<cfset var stGeneratedImageArgs = structnew() />
		<cfset var stImage = getImageInfo(arguments.filename) />
		<cfset var stGeneratedImage = structnew() />
		<cfset var q = "" />
		
		<cfparam name="arguments.stMetadata.ftCropPosition" default="center" />
		<cfparam name="arguments.stMetadata.ftCustomEffectsObjName" default="imageEffects" />
		<cfparam name="arguments.stMetadata.ftLCustomEffects" default="" />
		<cfparam name="arguments.stMetadata.ftConvertImageToFormat" default="" />
		<cfparam name="arguments.stMetadata.ftbSetAntialiasing" default="true" />
		<cfparam name="arguments.stMetadata.ftInterpolation" default="blackman" />
		<cfparam name="arguments.stMetadata.ftQuality" default="#arguments.quality#" />
		<cfif not len(arguments.resizeMethod)><cfset arguments.resizeMethod = arguments.stMetadata.ftAutoGenerateType /></cfif>
		
		<cfset stGeneratedImageArgs.Source = arguments.filename />
		<cfset stGeneratedImageArgs.Destination = arguments.filename />
		
		<cfif isNumeric(arguments.stMetadata.ftImageWidth)>
			<cfset stGeneratedImageArgs.width = arguments.stMetadata.ftImageWidth />
		<cfelse>
			<cfset stGeneratedImageArgs.width = 0 />
		</cfif>
		
		<cfif isNumeric(arguments.stMetadata.ftImageHeight)>
			<cfset stGeneratedImageArgs.Height = arguments.stMetadata.ftImageHeight />
		<cfelse>
			<cfset stGeneratedImageArgs.Height = 0 />
		</cfif>
		
		<cfset stGeneratedImageArgs.customEffectsObjName = arguments.stMetadata.ftCustomEffectsObjName />
		<cfset stGeneratedImageArgs.lCustomEffects = arguments.stMetadata.ftLCustomEffects />
		<cfset stGeneratedImageArgs.convertImageToFormat = arguments.stMetadata.ftConvertImageToFormat />
		<cfset stGeneratedImageArgs.bSetAntialiasing = arguments.stMetadata.ftBSetAntialiasing />
		<cfif not isValid("boolean", stGeneratedImageArgs.bSetAntialiasing)>
			<cfset stGeneratedImageArgs.bSetAntialiasing = true />
		</cfif>
		<cfset stGeneratedImageArgs.interpolation = arguments.stMetadata.ftInterpolation />
		<cfset stGeneratedImageArgs.quality = arguments.stMetadata.ftQuality />

		<cfif structKeyExists(stImage, "interpolation") AND stImage.interpolation eq "highQuality">
			<cfset stGeneratedImageArgs.interpolation = stImage.interpolation />
		</cfif>
	
		<cfset stGeneratedImageArgs.bUploadOnly = false />
		<cfset stGeneratedImageArgs.PadColor = arguments.stMetadata.ftPadColor />
		<cfset stGeneratedImageArgs.ResizeMethod = arguments.resizeMethod />
		
		<cfif (
				(stGeneratedImageArgs.width gt 0 and stGeneratedImageArgs.width gt stImage.width)
		   		or (stGeneratedImageArgs.height gt 0 and stGeneratedImageArgs.height gt stImage.height)
			)
			and listfindnocase("forceresize,pad,center,topleft,topcenter,topright,left,right,bottomleft,bottomcenter,bottomright",stGeneratedImageArgs.ResizeMethod)>
		   
			<!--- image is too small - only generate image for specific methods --->
			<cfset stGeneratedImage = GenerateImage(argumentCollection=stGeneratedImageArgs) />

			<cfreturn passed(stGeneratedImage.filename) />
			
		<cfelseif (stGeneratedImageArgs.width gt 0 and stGeneratedImageArgs.width lt stImage.width)
			or (stGeneratedImageArgs.height gt 0 and stGeneratedImageArgs.height lt stImage.height)
			or len(stGeneratedImageArgs.lCustomEffects)
			or arguments.bForceCrop>
			
			<cfset stGeneratedImage = GenerateImage(argumentCollection=stGeneratedImageArgs) />
			<cfreturn passed(stGeneratedImage.filename) />
			
		<cfelse>
			<cfreturn passed(arguments.filename) />
		</cfif>
	</cffunction>
	
	<cffunction name="handleFilePost" access="public" output="false" returntype="struct" hint="Handles image post and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="existingfile" type="string" required="true" hint="Current value of property" />
		<cfargument name="uploadfield" type="string" required="true" hint="Traditional form saves will use <PREFIX><PROPERTY>NEW, ajax posts will use <PROPERTY>NEW ... so the caller needs to say which it is" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="sizeLimit" type="numeric" required="false" default="0" hint="Maximum size of file in bytes" />
		<cfargument name="bArchive" type="boolean" required="true" hint="True to archive old files" />
		<cfargument name="stFieldPost" type="struct" required="false" default="#structnew()#" hint="The supplementary data" />
		
		<cfset var uploadFileName = "" />
		<cfset var archivedFile = "" />
		<cfset var stResult = passed(arguments.existingfile) />
		<cfset var stFile = structnew() />
		
		<cfparam name="stFieldPost.NEW" default="" />
		<cfparam name="stFieldPost.DELETE" default="false" /><!--- Boolean --->
		
		<cfset stResult.bChanged = false />
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<cfif (
				(
					structkeyexists(form,arguments.uploadfield) 
					AND len(form[arguments.uploadfield])
				) 
				OR (
					isBoolean(stFieldPost.DELETE) 
					AND stFieldPost.DELETE
				)
			) 
			AND len(arguments.existingfile) 
			AND application.fc.lib.cdn.ioFileExists(location="images",file=arguments.existingfile)>
			
			<cfif arguments.bArchive>
				<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
					source_location="images",
					source_file=arguments.existingfile,
					dest_location="archive",
					dest_file="#arguments.destination#/#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			<cfelse>
				<cfset archivedFile = application.fc.lib.cdn.ioCopyFile(
					source_location="images",
					source_file=arguments.existingfile,
					dest_localpath=getTempDirectory() & "#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			</cfif>
			
		    <cfset stResult = passed("") />
		    <cfset stResult.bChanged = true />
		    
		</cfif>
		
	  	<cfif structkeyexists(form,arguments.uploadfield) and len(form[arguments.uploadfield])>
	  	
	    	<cfif len(arguments.existingfile) and application.fc.lib.cdn.ioFileExists(location="images",file=arguments.existingfile)>
	    		
				<!--- This means there is already a file associated with this object. The new file must have the same name. --->
				<cftry>
					<cfset uploadFileName = application.fc.lib.cdn.ioUploadFile(
						location="images",
						destination=arguments.existingFile,
						field=arguments.uploadfield,
						sizeLimit=arguments.sizeLimit
					) />
					
					<cfset stResult = passed(uploadFileName) />
					<cfset stResult.bChanged = true />
					
					<cfif not arguments.bArchive>
						<cffile action="delete" file="#archivedFile#" />
					</cfif>
					
					<cfcatch type="uploaderror">
						<cfif arguments.bArchive>
							<cfset application.fc.lib.cdn.ioMoveFile(
								source_location="archive",
								source_file=archivedFile,
								dest_location="images",
								dest_file=arguments.existingFile
							) />
						<cfelse>
							<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
								source_localpath=archivedFile,
								dest_location="images",
								dest_file=arguments.existingFile
							) />
						</cfif>
						
						<cfset stResult = failed(value=arguments.existingfile,message=cfcatch.message) />
					</cfcatch>
				</cftry>
				
			<cfelse>
				
				<!--- There is no image currently so we simply upload the image and make it unique  --->
				<cftry>
					<cfset uploadFileName = application.fc.lib.cdn.ioUploadFile(
						location="images",
						destination=arguments.destination,
						acceptextensions=arguments.allowedExtensions,
						field=arguments.uploadfield,
						sizeLimit=arguments.sizeLimit,
						nameconflict="makeunique") />
					
					<cfset stResult = passed(uploadFileName) />
					<cfset stResult.bChanged = true />
					
					<cfcatch type="uploaderror">
						<cfset stResult = failed(value=arguments.existingfile,message=cfcatch.message) />
					</cfcatch>
				</cftry>
				
			</cfif>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="handleFileLocal" access="public" output="false" returntype="struct" hint="Handles using a local file as the new image and returns standard formtool result struct">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the edited object" />
		<cfargument name="existingfile" type="string" required="true" hint="Current value of property" />
		<cfargument name="localfile" type="string" required="true" hint="The local file" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="allowedExtensions" type="string" required="true" hint="The acceptable extensions" />
		<cfargument name="sizeLimit" type="numeric" required="false" default="0" hint="Maximum size of file in bytes" />
		<cfargument name="bArchive" type="boolean" required="true" hint="True to archive old files" />
		
		<cfset var uploadFileName = "" />
		<cfset var archivedFile = "" />
		<cfset var stResult = passed(arguments.existingfile) />
		<cfset var stFile = structnew() />
		<cfset var i = 0 />
		<cfset var errormessage = "" />
		
		<cfset stResult.bChanged = false />
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<cfif not fileexists(arguments.localfile)>
			<cfreturn failed(value=arguments.existingfile,message="Expected file does not exist [#arguments.localfile#]") />
	  	</cfif>

		<cfset errormessage = application.fc.lib.cdn.ioValidateFile(
			localpath=arguments.localfile,
			sizeLimit=arguments.sizeLimit,
			acceptextensions=arguments.allowedExtensions,
			existingFile=arguments.existingfile
		) />
		<cfif len(errormessage)>
			<cfreturn failed(value=arguments.existingfile,message=errormessage) />
		</cfif>

		<cfif len(arguments.existingfile) and application.fc.lib.cdn.ioFileExists(location="images",file=arguments.existingfile)>
			<cfif arguments.bArchive>
				<cfset archivedFile = application.fc.lib.cdn.ioMoveFile(
					source_location="images",
					source_file=arguments.existingfile,
					dest_location="archive",
					dest_file="#arguments.destination#/#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			<cfelse>
				<cfset archivedFile = application.fc.lib.cdn.ioCopyFile(
					source_location="images",
					source_file=arguments.existingfile,
					dest_localpath=getTempDirectory() & "#arguments.objectid#-#round(getTickCount()/1000)#-#listLast(arguments.existingfile, '/')#"
				) />
			</cfif>
			
		    <cfset stResult = passed("") />
		    <cfset stResult.bChanged = true />
    		
			<!--- The new file must have the same name. --->
			<cfset uploadFileName = listLast(arguments.existingfile, "/\") />
			
			<cfif not arguments.bArchive>
				<cffile action="delete" file="#archivedFile#" />
			</cfif>
			
			<cfset application.fc.lib.cdn.ioCopyFile(source_localpath=arguments.localfile,dest_location="images",dest_file=arguments.destination & "/" & uploadFilenName) />
			<cfset stResult = passed("#arguments.destination#/#uploadFileName#") />
			<cfset stResult.bChanged = true />
			
		<cfelse>
			
			<cfif arguments.sizeLimit and arguments.sizeLimit lt stFile.fileSize>
				<cfset stResult = failed(value=arguments.existingfile,message="#arguments.localfile# is not within the file size limit of #round(arguments.sizeLimit/1048576)#MB") />
			<cfelseif listFindNoCase(arguments.allowedExtensions,listlast(arguments.localfile,"."))>
				<cfset uploadFileName = application.fc.lib.cdn.ioMoveFile(source_localpath=arguments.localfile,dest_location="images",dest_file=arguments.destination & "/" & getFileFromPath(arguments.localfile),nameconflict="makeunique") />
				<cfset stResult = passed(uploadFileName) />
				<cfset stResult.bChanged = true />
			<cfelse>
				<cfset stResult = failed(value="",message="Images must have one of these extensions: #arguments.allowedExtensions#") />
			</cfif>
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="handleFileSource" access="public" output="false" returntype="struct" hint="Handles the alternate case to handleFileSubmission where the file is sourced from another property">
		<cfargument name="sourceField" type="string" required="true" hint="The source field to use" />
		<cfargument name="stObject" type="struct" required="true" hint="The full set of object properties" />
		<cfargument name="destination" type="string" required="true" hint="Destination of file" />
		<cfargument name="stFields" type="struct" required="true" hint="Full content type property metadata" />
		
		<cfset var sourceFieldName = "" />
		<cfset var libraryFieldName = "" />
		<cfset var stImage = structnew() />
		<cfset var sourcefilename = "" />
		<cfset var finalfilename = "" />
		<cfset var uniqueid = 0 />
		
		<cfif not len(arguments.sourceField) and structkeyexists(arguments.stObject,listfirst(arguments.sourceField,":")) and len(arguments.stObject[listfirst(arguments.sourceField,":")])>
			<cfreturn passed("") />
		<cfelse>
			<cfset sourceFieldName = listfirst(arguments.sourceField,":") />
			
			<!--- The source could be from an image library in which case, the source field will be in the form 'uuidField:imageLibraryField' --->
			<cfset libraryFieldName = listlast(arguments.sourceField,":") />
		</cfif>
		
		<!--- If developer has entered an ftDestination, make sure it starts with a slash --->
		<cfif len(arguments.destination) AND left(arguments.destination,1) NEQ "/">
			<cfset arguments.destination = "/#arguments.destination#" />
		</cfif>
		
		<!--- Get the source filename --->
		<cfif NOT isArray(arguments.stObject[sourceFieldName]) AND len(arguments.stObject[sourceFieldName])>
		    <cfif arguments.stFields[sourceFieldName].metadata.ftType EQ "uuid">
				<!--- This means that the source image is from an image library. We now expect that the source image is located in the source field of the image library --->
				<cfset stImage = application.fapi.getContentObject(objectid="#arguments.stObject[sourceFieldName]#") />
				<cfif structKeyExists(stImage, libraryFieldName) AND len(stImage[libraryFieldName])>
					<cfset sourcefilename = stImage[libraryFieldName] />
				</cfif>
			<cfelse>
				<cfset sourcefilename = arguments.stObject[sourceFieldName] />
			</cfif>
		<cfelseif isArray(arguments.stObject[sourceFieldName])>
			<!--- if this is array, use only first item for cropping --->
			<cfif arrayLen(arguments.stObject[sourceFieldName])>
				<cfset stImage = application.fapi.getContentObject(objectid="#arguments.stObject[sourceFieldName][1]#") />
				<cfset sourcefilename = stImage[libraryFieldName] />
			</cfif>
		<cfelse>
			<cfset sourcefilename = "" />
		</cfif>
		
		<!--- Copy the source into the new field --->
		<cfif len(sourcefilename)>
			<cfset finalfilename = application.fc.lib.cdn.ioCopyFile(source_location="images",source_file=sourcefilename,dest_location="images",dest_file=arguments.destination & "/" & listlast(sourcefilename,"\/"),nameconflict="makeunique",uniqueamong="images") />
			
			<cfreturn passed(finalfilename) />
		<cfelse>
			<cfreturn passed("") />
		</cfif>
				
	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />
		<cfset var stLoc = structnew() />
		
		<cfparam name="arguments.stMetadata.ftAutoGenerateType" default="FitInside">
		<cfparam name="arguments.stMetadata.ftImageWidth" default="0">
		<cfparam name="arguments.stMetadata.ftImageHeight" default="0">
		
		<cfsavecontent variable="html">
			<cfif len(arguments.stMetadata.value)>
				<cfset stLoc = getFileLocation(stObject=arguments.stObject,stMetadata=arguments.stMetadata,admin=true) />

				<cfoutput><img src="#stLoc.path#" border="0"</cfoutput>
				<cfif arguments.stMetadata.ftAutoGenerateType EQ "ForceSize" OR arguments.stMetadata.ftAutoGenerateType EQ "Pad" >
					<cfif len(arguments.stMetadata.ftImageWidth) and arguments.stMetadata.ftImageWidth GT 0><cfoutput> width="#arguments.stMetadata.ftImageWidth#"</cfoutput></cfif>
					<cfif len(arguments.stMetadata.ftImageHeight) and arguments.stMetadata.ftImageHeight GT 0><cfoutput> height="#arguments.stMetadata.ftImageHeight#"</cfoutput></cfif>
				</cfif>
				<cfoutput>></cfoutput>
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
		<cfset var stFixed = structNew() />
		
		
		<cfset stResult = handleFilePost(
			objectid=arguments.objectid,
			existingfile=arguments.stFieldPost.value,
			uploadfield="#arguments.stMetadata.FormFieldPrefix##arguments.stMetadata.name#TRADITIONAL",
			destination=arguments.stMetadata.ftDestination,
			allowedExtensions=arguments.stMetadata.ftAllowedExtensions,
			stFieldPost=arguments.stFieldPost.stSupporting,
			sizeLimit=arguments.stMetadata.ftSizeLimit,
			bArchive=application.stCOAPI[arguments.typename].bArchive and (not structkeyexists(arguments.stMetadata,"ftArchive") or arguments.stMetadata.ftArchive)
		) />
		
		<cfif stResult.bChanged>
			<cfif isdefined("stResult.value") and len(stResult.value)>
			
				<cfparam name="arguments.stFieldPost.stSupporting.ResizeMethod" default="#arguments.stMetadata.ftAutoGenerateType#" />
				<cfparam name="arguments.stFieldPost.stSupporting.Quality" default="#arguments.stMetadata.ftQuality#" />
				
				<cfset stFixed = fixImage(stResult.value,arguments.stMetadata,arguments.stFieldPost.stSupporting.ResizeMethod,arguments.stFieldPost.stSupporting.Quality) />
				
				<cfif stFixed.bSuccess>
					<cfset stResult.value = stFixed.value />
				<cfelseif structkeyexists(stFixed,"stError")>
					<!--- Do nothing - an error from fixImage means there was no resize --->
				</cfif>
				
				<cfset onFileChange(typename=arguments.typename,objectid=arguments.objectid,stMetadata=arguments.stMetadata,value=stResult.value) />
				
			<cfelse>
			
				<cfset onFileChange(typename=arguments.typename,objectid=arguments.objectid,stMetadata=arguments.stMetadata,value=stResult.value) />
			
			</cfif>
			
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult />
		
	</cffunction>
	
	
	<cffunction name="getFileExists" access="public" output="false" returntype="boolean" hint="Returns true if file is non-empty and exists">
		<cfargument name="file" type="string" required="true" />
		
		<cfif len(arguments.file)>
			<cfreturn application.fc.lib.cdn.ioFileExists(location="images",file=arguments.file) />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="getImageInfo" access="public" output="false" returntype="struct" hint="Returns information about image">
		<cfargument name="file" type="string" required="true" />
		<cfargument name="admin" type="boolean" required="false" default="false" />
		
		<cfset var stImage = structnew() />
		<cfset var stResult = structnew() />
		
		<cfif application.fc.lib.cdn.ioFileExists(location="images",file=arguments.file)>
			
				<cfimage action="info" source="#application.fc.lib.cdn.ioReadFile(location='images',file=arguments.file,datatype='image')#" structName="stImage" />
				
				<cfset stResult["width"] = stImage.width />
				<cfset stResult["height"] = stImage.height />
				<cfset stResult["size"] = application.fc.lib.cdn.ioGetFileSize(location="images",file=arguments.file) />
				<cfset stResult["path"] = application.fc.lib.cdn.ioGetFileLocation(location="images",file=arguments.file,admin=true).path />
				
	 			<cfif findNoCase("GRAY", stImage.colormodel.colorspace)>
					<cfset stResult["interpolation"] = "highQuality" />
				</cfif>

		<cfelse>
			
			<cfset stResult["width"] = 0 />
			<cfset stResult["height"] = 0 />
			<cfset stResult["size"] = 0 />
			<cfset stResult["path"] = "" />
			
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="GenerateImage" access="public" output="false" returntype="struct">
		<cfargument name="source" type="string" required="true" hint="The absolute path where the image that is being used to generate this new image is located." />
		<cfargument name="destination" type="string" required="false" default="" hint="The absolute path where the image will be stored." />
		<cfargument name="width" type="numeric" required="false" default="0" hint="The maximum width of the new image." />
		<cfargument name="height" type="numeric" required="false" default="0" hint="The maximum height of the new image." />
		<cfargument name="autoGenerateType" type="string" required="false" default="FitInside" hint="How is the new image to be generated (ForceSize,FitInside,Pad)" />
		<cfargument name="padColor" type="string" required="false" default="##ffffff" hint="If AutoGenerateType='Pad', image will be padded with this colour" />
		<cfargument name="customEffectsObjName" type="string" required="true" default="imageEffects" hint="The object name to run the effects on (must be in the package path)" />
		<cfargument name="lCustomEffects" type="string" required="false" default="" hint="List of methods to run for effects with their arguments and values. The methods are order dependant replecting how they are listed here. Example: ftLCustomEffects=""roundCorners();reflect(opacity=40,backgroundColor='black');""" />
		<cfargument name="convertImageToFormat" type="string" required="false" default="" hint6="Convert image to a specific format. Set value to image extension. Example: 'gif'. Leave blank for no conversion. Default=blank (no conversion)" />
		<cfargument name="bSetAntialiasing" type="boolean" required="true" default="true" hint="Use Antialiasing (better image, but slower performance)" />
		<cfargument name="interpolation" type="string" required="true" default="blackman" hint="set the interpolation level on the image compression" />
		<cfargument name="quality" type="string" required="false" default="0.8" hint="Quality of the JPEG destination file. Applies only to files with an extension of JPG or JPEG. Valid values are fractions that range from 0 through 1 (the lower the number, the lower the quality). Examples: 1, 0.9, 0.1. Default = 0.8" />
		<cfargument name="bUploadOnly" type="boolean" required="false" default="false" hint="The image file will be uploaded with no image optimization or changes." />
		<cfargument name="bSelfSourced" type="boolean" required="false" default="false" hint="The image file will be uploaded with no image optimization or changes." />
		<cfargument name="ResizeMethod" type="string" required="true" default="" hint="The y origin of the crop area. Options are center, topleft, topcenter, topright, left, right, bottomleft, bottomcenter, bottomright" />
		<cfargument name="watermark" type="string" required="false" default="" hint="The path relative to the webroot of an image to use as a watermark." />
		<cfargument name="watermarkTransparency" type="string" required="false" default="90" hint="The transparency to apply to the watermark." />
		
		<cfset var stResult = structNew() />
		<cfset var imageDestination = "" />
		<cfset var newImage = "" />
		<cfset var cropXOrigin = 0 />
		<cfset var cropYOrigin = 0 />
		<cfset var padImage = imageNew() />
		<cfset var XCoordinate = 0 />
		<cfset var YCoordinate = 0 />
		<cfset var stBeveledImage = structNew() />
		<cfset var widthPercent = 0 />
		<cfset var heightPercent = 0 />
		<cfset var usePercent = 0 />
		<cfset var pixels = 0 />
		<cfset var bModified = false />
		<cfset var oImageEffects = "" />
		<cfset var aMethods = "" />
		<cfset var i = "" />
		<cfset var lArgs = "" />
		<cfset var find = "" />
		<cfset var methodName = "" />
		<cfset var stArgCollection = structNew() />
		<cfset var argName = "" />
		<cfset var argValue = "" />
		<cfset var objWatermark = "" />
		<cfset var argsIndex = "" />
		<cfset var stImage = "" />

		<cfset stResult.bSuccess = true />
		<cfset stResult.message = "" />
		<cfset stResult.filename = "" />
		
		<cfsetting requesttimeout="120" />
		
		<cfif not application.fc.lib.cdn.ioFileExists(location="images",file=arguments.source)>
			<cfset stResult.bSuccess = False />
			<cfset stResult.message = "File doesn't exist" />
			<cfreturn stResult />
		</cfif>

		<cfif stResult.bSuccess>
			<cfset stImage = getImageInfo(file=arguments.source,admin=true) />
			<cfif structKeyExists(stImage, "interpolation") AND stImage.interpolation eq "highQuality">
				<cfset arguments.interpolation = stImage.interpolation />
			</cfif>
		</cfif>
		
		<!---
		FTAUTOGENERATETYPE OPTIONS
		ForceSize - Ignores source image aspect ratio and forces the new image to be the size set in the metadata width/height
		FitInside - Reduces the width and height so that it fits in the box defined by the metadata width/height
		CropToFit - A bit of both "ForceSize" and "FitInside" where it forces the image to conform to a fixed width and hight, but crops the image to maintain aspect ratio. It first attempts to crop the width because most photos are taken from a horizontal perspective with a better chance to remove a few pixels than from the header and footer.
		Pad - Reduces the width and height so that it fits in the box defined by the metadata width/height and then pads the image so it ends up being the metadata width/height
		--->
		
		<cfif arguments.source eq arguments.destination>
			<cfset imageDestination = arguments.destination />
			<cfset arguments.bSelfSourced = true />
		<cfelseif refind("\.\w+$",arguments.destination)>
			<cfset imageDestination = arguments.destination />
		<cfelse>
			<cfset imageDestination = arguments.destination & "/" & listlast(arguments.source,"/\") />
		</cfif>
		
		<!--- Image has changed --->
		<cftry>
			<!--- Read image into memory --->
			<cfset newImage = application.fc.lib.cdn.ioReadFile(location="images",file=arguments.source,datatype="image") />
			<cfif arguments.bSetAntialiasing is true>
				<cfset ImageSetAntialiasing(newImage,"on") />
			</cfif>
			
			<cfcatch type="any">
				<cftrace type="warning" text="Minimum version of ColdFusion 8 required for cfimage tag manipulation. Using default image.cfc instead" />
				<!--- Should we abort here with a dump? --->
				<cfdump var="#cfcatch#" expand="true" label="" /><cfabort />
				<cfset stResult = createObject("component", "farcry.core.packages.formtools.image").GenerateImage(Source=arguments.Source, Destination=arguments.Destination, Width=arguments.Width, Height=arguments.Height, AutoGenerateType=arguments.AutoGenerateType, PadColor=arguments.PadColor) />
				<cfreturn stResult />
			</cfcatch>
		</cftry>
		
		<cfif arguments.bUploadOnly is true>
			<!--- We do not want to modify the file, so exit now --->
			<cfset stResult.filename = application.fc.lib.cdn.ioCopyFile(source_location="images",source_file=arguments.source,dest_location="images",dest_file=imageDestination,nameconflict="makeunique",uniqueamong="images") /> 
			<cfreturn stResult />
		</cfif>
		
		<cfswitch expression="#arguments.ResizeMethod#">
		
			<cfcase value="ForceSize">
				<!--- Simply force the resize of the image into the width/height provided --->
				<cfset imageResize(newImage,arguments.Width,arguments.Height,"#arguments.interpolation#") />
			</cfcase>
			
			<cfcase value="FitInside">
				<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
				<cfif arguments.Width gt 0 and newImage.width gt arguments.Width>
					<cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
				</cfif>
				
				<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
				<cfif arguments.Height gt 0 and newImage.height gt arguments.Height>
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
				<!--- Permission for original version of aspectCrop() method given by authors Ben Nadel and Emmet McGovern --->
				<cfset widthPercent = arguments.Width / newImage.width>
				<cfset heightPercent = arguments.Height / newImage.height>
				
				<cfif widthPercent gt heightPercent>
					<cfset usePercent = widthPercent>
					<cfset pixels = newImage.width * usePercent + 1>
					<cfset cropYOrigin = ((newImage.height - arguments.Height)/2)>
					<cfset imageResize(newImage,pixels,"",arguments.interpolation) />
				<cfelse>
					<cfset usePercent = heightPercent>
					<cfset pixels = newImage.height * usePercent + 1>
					<cfset cropXOrigin = ((newImage.width - arguments.Height)/2)>
					<cfset imageResize(newImage,"",pixels,arguments.interpolation) />
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
				
				<cfset ImageCrop(newImage,cropXOrigin,cropYOrigin,arguments.Width,arguments.Height)>
			</cfcase> 
			
			<cfdefaultcase>
				<cfif refind("^\d+,\d+-\d+,\d+$",arguments.resizeMethod)>
					<cfset pixels = listtoarray(arguments.resizeMethod,",-") />
					<cfset ImageCrop(newImage,pixels[1],pixels[2],pixels[3]-pixels[1],pixels[4]-pixels[2]) />
					
					<!--- If the Width of the image is wider than the requested width, resize the image in the correct proportions to be the width requested --->
					<cfif arguments.Width gt 0 and pixels[3]-pixels[1] gt arguments.Width>
						<cfset imageScaleToFit(newImage,arguments.Width,"","#arguments.interpolation#") />
					</cfif>
					
					<!--- If the height of the image (after the previous width setting) is taller than the requested height, resize the image in the correct proportions to be the height requested --->
					<cfif arguments.Height gt 0 and pixels[4]-pixels[2] gt arguments.Height>
						<cfset imageScaleToFit(newImage,"",arguments.Height,"#arguments.interpolation#") />
					</cfif>
				</cfif>
			</cfdefaultcase>
			
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
			
			<cfset bModified = true />
		</cfif>
	
		<cfif len(arguments.watermark) and fileExists("#application.path.webroot##arguments.watermark#")>
		
		
			<!--- THANKS KINKY SOLUTIONS FOR THE FOLLOWING CODE (http://www.bennadel.com) --->
			<!--- Read in the watermark. --->
			<cfset objWatermark = ImageNew("#application.path.webroot##arguments.watermark#") />
			
			
			<!---
			Turn on antialiasing on the existing image
			for the pasting to render nicely.
			--->
			<cfset ImageSetAntialiasing(newImage,"on") />
			
			<!---
			When we paste the watermark onto the photo, we don't
			want it to be fully visible. Therefore, let's set the
			drawing transparency before we paste.
			--->
			<cfset ImageSetDrawingTransparency(newImage,arguments.watermarkTransparency) />
	 
			<!---
			Paste the watermark on to the image. We are going
			to paste this into the center.
			--->
			<cfset ImagePaste(newImage,objWatermark,(newImage.GetWidth() - objWatermark.GetWidth()) / 2,(newImage.GetHeight() - objWatermark.GetHeight()) / 2) />
			
			<cfset bModified = true />
		</cfif>	

		<!--- Modify extension to convert image format --->
		<cfif len(arguments.convertImageToFormat)>
			<cfset ImageDestination = listSetAt(ImageDestination, listLen(ImageDestination, "."), replace(convertImageToFormat, ".", "", "all"), ".") />
			<cfset bModified = true />
		</cfif>
		
		<cfif arguments.ResizeMethod neq "none" or bModified>
			<cfif NOT arguments.bSelfSourced>
				<cfset stResult.filename = application.fc.lib.cdn.ioWriteFile(location="images",file=imageDestination,data=newImage,datatype="image",quality=arguments.quality,nameconflict="makeunique",uniqueamong="images") />
			<cfelse>
				<cfset stResult.filename = application.fc.lib.cdn.ioWriteFile(location="images",file=imageDestination,data=newImage,datatype="image",quality=arguments.quality,nameconflict="overwrite") />
			</cfif>
		<cfelse>
			<cfset stResult.filename = imageDestination />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="ImageAutoGenerateBeforeSave" access="public" output="false" returntype="struct" hint="This function is executed AFTER validation of the post (and therefore upload of source images) to trigger generation of dependant images. An updated properties struct containing any new file names is returned. NOTE: 'replacement' or regeneration is now implied - the user selects 'replace', validation deletes the existing file, and this function regenerates the image when it sees the empty field.">
		<cfargument name="stProperties" required="true" type="struct" />
		<cfargument name="stFields" required="true" type="struct" />
		<cfargument name="stFormPost" required="true" type="struct" hint="The cleaned up form post" />
		
		<cfset var thisfield = "" />
		<cfset var stResult = structnew() />
		<cfset var stFixed = false />
		
		<cfloop list="#StructKeyList(arguments.stFields)#" index="thisfield">
			<!--- If this is an image field and doesn't already have a file attached, is included in this POST update, and can be generated from a source... --->
			<cfif structKeyExists(arguments.stFields[thisfield].metadata, "ftType") AND arguments.stFields[thisfield].metadata.ftType EQ "Image" and (not structkeyexists(arguments.stProperties,thisfield) or not len(arguments.stProperties[thisfield]))
			  and structKeyExists(arguments.stFormPost, thisfield) AND structKeyExists(arguments.stFields[thisfield].metadata, "ftSourceField") and len(arguments.stFields[thisfield].metadata.ftSourceField)>
				
				<cfparam name="arguments.stFields.#thisfield#.metadata.ftDestination" default="" />    
				
				<cfset stResult = handleFileSource(sourceField=arguments.stFields[thisfield].metadata.ftSourceField,stObject=arguments.stProperties,destination=arguments.stFields[thisfield].metadata.ftDestination,stFields=arguments.stFields) />
				
				<cfif isdefined("stResult.value") and len(stResult.value)>
					
					<cfparam name="arguments.stFormPost.#thisfield#.stSupporting.ResizeMethod" default="#arguments.stFields[thisfield].metadata.ftAutoGenerateType#" />
					<cfparam name="arguments.stFormPost.#thisfield#.stSupporting.Quality" default="#arguments.stFields[thisfield].metadata.ftQuality#" />
					
					<cfset stFixed = fixImage(stResult.value,arguments.stFields[thisfield].metadata,arguments.stFormPost[thisfield].stSupporting.ResizeMethod,arguments.stFormPost[thisfield].stSupporting.Quality) />
					
					<cfif stFixed.bSuccess>
						<cfset stResult.value = stFixed.value />
					<cfelseif structkeyexists(stFixed,"error")>
						<!--- Do nothing - an error from fixImage means there was no resize --->
					</cfif>
					
					<cfif not structkeyexists(stResult,"error")>
						<cfset onFileChange(typename=arguments.typename,objectid=arguments.stProperties.objectid,stMetadata=arguments.stFields[thisfield].metadata,value=stResult.value) />
						<cfset stProperties[thisfield] = stResult.value />
					</cfif>
					
				</cfif>
			
			</cfif>
		</cfloop>
		
		<cfreturn stProperties />
	</cffunction>
	
	
	<cffunction name="imageDuplicate" returntype="any" output="false" hint="Creates a clean copy of the image without references (Note: ColdFusion's duplicate() function retains references).">
		<cfargument name="oImage" type="any" required="true" hint="A ColdFusion Image Object" />
		<cfargument name="backgroundColor" type="string" required="false" default="white" hint="background color of image." />
		
		<cfset var imgInfo = imageInfo(arguments.oImage)/>
		<cfset var myImage = imageNew("", imgInfo.width, imgInfo.height, "argb", arguments.backgroundColor) />
		<cfset imagePaste(myImage, arguments.oImage, 0, 0) />
		
		<cfreturn myImage />
	</cffunction>
	
	<cffunction name="onFileChange" access="public" returntype="any" output="false" hint="Called internally (by the image formtool) just before a new image is returned to calling code.">
		<cfargument name="typename" required="false" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="objectid" required="false" type="uuid" hint="The id of the record that this field is part of.">
		<cfargument name="stObject" required="false" type="struct" hint="Alternative to typename+objectid" />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="value" required="true" type="string" hint="The new filename value" />
		
		
	</cffunction>
	
	<cffunction name="onDelete" access="public" output="false" returntype="void" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfif not len(arguments.stObject[arguments.stMetadata.name])>
			<cfreturn /><!--- No file attached --->
		</cfif>
		
		<cfif (not structkeyexists(arguments.stObject,"versionID") or not len(arguments.stObject.versionID)) and application.fc.lib.cdn.ioFileExists(location="images",file="/#arguments.stObject[arguments.stMetadata.name]#")>
			<cfset application.fc.lib.cdn.ioDeleteFile(location="images",file="/#arguments.stObject[arguments.stMetadata.name]#") />
		<cfelse>
			<cfreturn /><!--- File doesn't actually exist --->
		</cfif>
	</cffunction>
	
	<cffunction name="getFileLocation" access="public" output="false" returntype="struct" hint="Returns information used to access the file: type (stream | redirect), path (file system path | absolute URL), filename, mime type">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		<cfargument name="admin" type="boolean" required="false" default="false" />
		<cfargument name="bRetrieve" type="boolean" required="false" default="true" />
		
		<cfset var stResult = structnew() />
		
		<!--- Throw an error if the field is empty --->
		<cfif NOT len(arguments.stObject[arguments.stMetadata.name])>
			<cfset stResult = structnew() />
			<cfset stResult.method = "none" />
			<cfset stResult.path = "" />
			<cfset stResult.error = "No file defined" />
			<cfreturn stResult />
		</cfif>
		
		<cfset stResult = application.fc.lib.cdn.ioGetFileLocation(location="images",file=arguments.stObject[arguments.stMetadata.name],admin=arguments.admin,bRetrieve=arguments.bRetrieve) />
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="onArchive" access="public" output="false" returntype="string" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="archiveID" type="uuid" required="true" hint="The ID of the new archive" />
		
		<cfset var archiveFile = "" />
		
		<cfif len(arguments.stObject[arguments.stMetadata.name]) and application.fc.lib.cdn.ioFileExists(location="images",file=arguments.stObject[arguments.stMetadata.name])>
			<cfset archiveFile = "/#arguments.stObject.typename#/#arguments.archiveID#.#arguments.stMetadata.name#.#ListLast(arguments.stObject[arguments.stMetadata.name],'.')#" />
			
			<cfset application.fc.lib.cdn.ioCopyFile(source_location="images",source_file=arguments.stObject[arguments.stMetadata.name],dest_location="archive",dest_file=archiveFile) />
		</cfif>
		
		<cfreturn archiveFile />
	</cffunction>
	
	<cffunction name="onRollback" access="public" output="false" returntype="string" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="archiveID" type="uuid" required="true" hint="The ID of the archive being rolled back" />
		
		<cfset var archiveFile = "/#arguments.stObject.typename#/#arguments.archiveID#.#arguments.stMetadata.name#.#ListLast(arguments.stObject[arguments.stMetadata.name],'.')#" />
		
		<cfreturn application.fc.lib.cdn.ioMoveFile(source_location="archive",source_file=archiveFile,dest_location="images",dest_file=arguments.stObject[arguments.stMetadata.name]) />
	</cffunction>
	
	<cffunction name="duplicateFile" access="public" output="false" returntype="string" hint="For use with duplicateObject, copies the associated file and returns the new unique filename">
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		<cfset var currentfilename = arguments.stObject[arguments.stMetadata.name] />
		<cfset var newfilename = "" />
		<cfset var currentlocation = "" />
		
		<cfif not len(currentfilename)>
			<cfreturn "" />
		</cfif>
		
		<cfset currentlocation = application.fc.lib.cdn.ioFindFile(locations="images",file=currentfilename) />
		
		<cfif isDefined("currentlocation") and not len(currentlocation)>
			<cfreturn "" />
		</cfif>
		
		<cfreturn application.fc.lib.cdn.ioCopyFile(source_location="images",source_file=currentfilename,dest_location="images",dest_file=newfilename,nameconflict="makeunique",uniqueamong="images") />
	</cffunction>
	
	<cffunction name="failed" access="public" output="false" returntype="struct" hint="This will return a struct with stMessage">
		<cfargument name="value" required="true" type="any" hint="The value that is to be returned.">
		<cfargument name="message" required="false" type="string" default="Not a valid value" hint="The message that will appear under the field.">
		<cfargument name="class" required="false" type="string" default="validation-advice" hint="The class of the div wrapped around the message.">
	
		<cfset var r_stResult = structNew() />
		<cfset r_stResult.value = arguments.value />
		<cfset r_stResult.bSuccess = false />
		<cfset r_stResult.stError = structNew() />
		<cfset r_stResult.stError.message = application.fc.lib.esapi.encodeForHTML(arguments.message) />
		<cfset r_stResult.stError.class = arguments.class />
		<cfset r_stResult.bChanged = false />
		
		<cfreturn r_stResult />
	</cffunction>
	
	<cffunction name="generateImageFrom" access="public" output="false" returntype="struct" hint="This function is used to generate the image for a property from the image of another property. It returns a copy of the object with the updated path to the generated destination image.">
		<cfargument name="stProperties" required="true" type="struct" />
		<cfargument name="source_property" required="true" type="string" hint="The property to copy the image from." />
		<cfargument name="dest_property" required="true" type="string" hint="The property to copy the image to." />
		
		<cfset var stResult = structnew() />
		<cfset var stFixed = false />
		<cfset var stDestMetadata = application.fapi.getPropertyMetadata(	typename="#arguments.stProperties.typename#", property="#arguments.dest_property#") />
		<cfset var stProps = application.fapi.getContentTypeMetadata(typename="#arguments.stProperties.typename#").stProps />
		<cfset var source_image = "" />


		<cfset stResult = handleFileSource(	sourceField=#arguments.source_property#,
											stObject=arguments.stProperties,
											destination="#stDestMetadata.ftDestination#",
											stFields=stProps ) />

		<cfif isdefined("stResult.value") and len(stResult.value)>	


			<cfset source_image = application.fc.lib.cdn.ioCopyFile(	source_location='images',
																		source_file="#stProperties[source_property]#",
																		dest_location="images", 
																		dest_file="#stDestMetadata.ftDestination#/#GetFileFromPath(stResult.value)#") />

			<cfset stFixed = fixImage(	source_image,
										stProps[arguments.dest_property].metadata,
										stProps[arguments.dest_property].metadata.ftAutoGenerateType,
										stProps[arguments.dest_property].metadata.ftQuality) />
			
			<cfif stFixed.bSuccess>
				<cfset stResult.value = stFixed.value />
			<cfelseif structkeyexists(stFixed,"error")>
				<!--- Do nothing - an error from fixImage means there was no resize --->
			</cfif>

			<cfif not structkeyexists(stResult,"error")>
				<cfset onFileChange(typename=arguments.stProperties.typename,
									objectid=arguments.stProperties.objectid,
									stMetadata=stProps[arguments.dest_property].metadata,
									value=stResult.value) />
				<cfset stProperties[arguments.dest_property] = stResult.value />
			</cfif>			
		</cfif>
		
		<cfreturn stProperties />
	</cffunction>
</cfcomponent> 
