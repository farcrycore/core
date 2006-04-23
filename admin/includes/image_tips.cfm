<cfoutput><h3>Acceptable image types are:</h3>
<p><cfloop list="#application.config.image.imagetype#" index="i">#listlast(i, '/')#<cfif not listlast(application.config.image.imagetype) eq i>,</cfif></cfloop></p>
<h3>Maximum file size:</h3>
<p>#application.config.image.imagesize/1024#kb</p>
<p><h3>NOTE:</h3> The default thumbnail image size is #application.config.image.thumbnailwidth# * #application.config.image.thumbnailheight# pixels</p></cfoutput>