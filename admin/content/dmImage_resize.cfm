<cfsetting enablecfoutputonly="true" />
<!---

purpose of this file:

1.	create 2 listings of the directory: C:\webApps\farcry_investigator\www\images
	a) listing of original images
	b) listing of existing thumbnails
2.`	delete all files which match the file pattern: '*_thumbnail.jpg'
3.	loop over original images in directory: C:\webApps\farcry_investigator\www\images
	and create new thumbnails with the following naming convention:
	'original_image_name' + '_thumbnail.jpg'
	default resolution: 100 x 100 [default values from config]
TODO: this will need cleaning, maybe show previews of images being deleted, and allow which image needs to be resized
--->
<cfparam name="form.bFormSubmitted" default="no" />

<cfset variables.aErrorMessages = arrayNew(1) />
<cfset variables.aSuccessMessages = arrayNew(1) />

<cfdirectory directory="#application.config.image.sourceImagePath#" filter="*.jpg" name="qSourceImageListing">
<cfdirectory directory="#application.config.image.standardImagePath#" filter="*.jpg" name="qStandardImageListing">
<cfdirectory directory="#application.config.image.thumbnailImagePath#" filter="*.jpg" name="qThumbnailImageListing">

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfif bFormSubmitted EQ "yes">
	<cfparam name="form.bThumbnailImageResize" default="false" />
	<cfparam name="form.bStandardImageResize" default="false" />
	<cfif form.bThumbnailImageResize eq "on">
		<cfset form.bThumbnailImageResize = true />
	</cfif>
	<cfif form.bStandardImageResize eq "on">
		<cfset form.bStandardImageResize = true />
	</cfif>

	<cfset imageUtility = createObject("component","#Application.packagePath#.farcry.imageUtilities") />

	<!--- Begin: Resize Thumnail Images --->
	<cfif form.bThumbnailImageResize eq true>
		<!--- Delete Old Images --->
		<cfloop query="qThumbnailImageListing">
				<cffile action="delete" file="#application.config.image.thumbnailImagePath#/#qThumbnailImageListing.name#" />
		</cfloop>
		<!--- Create New Images --->
		<cfloop query="qSourceImageListing">
			<cftry>
				<cfset imageUtility.fCreatePresets(imagePreset="thumbnailImage", originalFile="#application.config.image.sourceImagePath#/#qSourceImageListing.name#", destinationFile="#application.config.image.thumbnailImagePath#/#qSourceImageListing.name#") />
				<cfcatch>
					<cfset arrayAppend(variables.aErrorMessages, "There was a problem deleting your old thumbnail image files") />
				</cfcatch>
			</cftry>
		</cfloop>
		<cfset arrayAppend(variables.aSuccessMessages, "The thumbnail images resized successfully!") />
	</cfif>
	<!--- End: Resize Thumnail Images --->

	<!--- Begin: Resize Standard Images --->
	<cfif form.bStandardImageResize eq true>
		<!--- Delete Old Images --->
		<cfloop query="qStandardImageListing">
			<cftry>
				<cffile action="delete" file="#application.config.image.standardImagePath#/#qStandardImageListing.name#" />
				<cfcatch>
					<cfset arrayAppend(variables.aErrorMessages, "There was a problem deleting your old standard image files") />
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Create New Images --->
		<cfloop query="qSourceImageListing">
			<cftry>
				<cfset imageUtility.fCreatePresets(imagePreset="standardImage", originalFile="#application.config.image.sourceImagePath#/#qSourceImageListing.name#", destinationFile="#application.config.image.standardImagePath#/#qSourceImageListing.name#") />
				<cfcatch>
					<cfset arrayAppend(variables.aErrorMessages, "There was a problem deleting your old standard image files") />
				</cfcatch>
			</cftry>
		</cfloop>
		<cfset arrayAppend(variables.aSuccessMessages, "The standard images resized successfully!") />
	</cfif>
	<!--- End: Resize Standard Images --->

</cfif>

<admin:header title="Image Library Maintenance">

<cfif not arrayIsEmpty(variables.aErrorMessages)>
	<cfoutput>	<ul></cfoutput>
	<cfloop index="i" from="1" to="#arrayLen(variables.aErrorMessages)#">
		<cfoutput>
		<li>#variables.aErrorMessages[i]#</li></cfoutput>
	</cfloop>
	<cfoutput>	
	</ul></cfoutput>
<cfelseif not arrayIsEmpty(variables.aSuccessMessages)>
	<cfoutput>	<ul></cfoutput>
	<cfloop index="i" from="1" to="#arrayLen(variables.aSuccessMessages)#">
		<cfoutput>
		<li>#variables.aSuccessMessages[i]#</li></cfoutput>
	</cfloop>
	<cfoutput>	
	</ul></cfoutput>
<cfelseif qSourceImageListing.recordcount EQ 0>
	<cfoutput>
	<p>You currently have no images to resize.</p></cfoutput>
<cfelse>
	<cfoutput>
	Do you want to rezise the following images?
	<ul style="padding-top: 25px;"></cfoutput>
	<cfloop query="qSourceImageListing">
		<cfoutput>
		<li>#qSourceImageListing.name#</li></cfoutput>
	</cfloop>
	<cfoutput>
	</ul>
	<hr />
	<form action="" class="f-wrap-1 f-bg-long" method="post" name="dmimage_resize">
		<fieldset>
			<input type="hidden" name="bFormSubmitted" value="1" />
			<label for="bThumbnailImageResize">
				<input type="checkbox" name="bThumbnailImageResize" id="bThumbnailImageResize" checked="checked" /> Resize thumnails (to the <em><strong>*</strong>system default</em> of #application.config.image.thumbnailImageWidth# x #application.config.image.thumbnailImageHeight# pixels)
			</label>
			<label for="bStandardImageResize" style="padding-bottom: 10px;">
				<input type="checkbox" name="bStandardImageResize" id="bStandardImageResize" checked="checked" /> Resize standard images (to the <em><strong>*</strong>system default</em> of #application.config.image.standardImageWidth# x #application.config.image.standardImageHeight# pixels)
			</label>
			<p style="font-weight: bold; margin-bottom: 5px;">Notes:</p>
			<ul style="margin-left: 15px;">
				<li>*system default sizing and resizing for <em>standard</em> and <em>thumnail</em> images can be configured within the admin configuration section of FarCry.</li>
				<li>Choosing either of the selections above will <strong>not</strong> effect the <em>source</em> image.</li>
			</ul>
			<input type="submit" name="delete" value="Remove &amp; Recreate" />
		</fieldset>
	</form></cfoutput>
</cfif>
<admin:footer>
<cfsetting enablecfoutputonly="false" />