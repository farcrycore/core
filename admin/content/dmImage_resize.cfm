<cfsetting enablecfoutputonly="true">
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
<cfparam name="bFormSubmitted" default="no">
<cfparam name="errorMessage" default="">
<cfparam name="successMessage" default="">

<cfset workingDir = #application.path.defaultimagepath#>
<cfdirectory directory="#workingDir#" filter="*_thumbnail.jpg" name="thumbListing">
<cfdirectory directory="#workingDir#" filter="*.jpg" name="imageListing">
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfsetting enablecfoutputonly="no">

<cfif bFormSubmitted EQ "yes">
	<cfset imageUtility=createObject("component","#Application.packagePath#.farcry.imageUtilities") >
	<cfloop query="thumbListing">
		<cffile action="delete" file="#workingDir#/#thumbListing.name#" >
	</cfloop>
	<cfdirectory directory="#workingDir#" filter="*.jpg" name="imageListing">
	<cfloop query="imageListing">
		<cfset imageUtility.fCreatePresets("thumbnail", workingDir & "/" & imageListing.name, workingDir & "/" & Replace(imageListing.name,".jpg","") & "_thumbnail.jpg")>
	</cfloop>
	<cfset successMessage = "Operation has been performed sucessfully!">
</cfif>

<cfsetting enablecfoutputonly="false">
<admin:header title="Image Library Maintenance"><cfif successMessage NEQ ""><cfoutput>
	#successMessage#</cfoutput><cfelseif imageListing.recordcount EQ 0>
	You currently have no images to resize.
	<cfelse>
	Do you want to delete the following thumbnails?<br /><br />
	<ul><cfoutput query="thumbListing">
		<li>#thumbListing.name#</li></cfoutput>
	</ul>
	and replace them with new thumbnails of the size <cfoutput>#application.config.image.thumbnailWidth#</cfoutput> x <cfoutput>#application.config.image.thumbnailHeight#</cfoutput> pixels?<br /><br />	

	<form action="" class="f-wrap-1 f-bg-long" method="post" name="dmimage_resize">
		<input type="hidden" name="bFormSubmitted" value="yes">
		<input type="submit" name="delete" value="Remove &amp; Recreate">
	</form>	</cfif>
<admin:footer>