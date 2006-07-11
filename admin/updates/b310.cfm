<!--- @@description:
Update Image Config<br />
Adds the SourceImage, StandardImage and ThumbnailImage entry to dmImage table<br />
Create SourceImages, thumbnailImages and StandardImages directories<br />
Update SourceImage, StandardImage and ThumbnailImage initial values<br />
Copy Files from Old Locations to New Locations

--->
<cfoutput>
<html>
<head>
<title>Farcry Core 3.1.0 Update - #application.applicationname#</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">
</cfoutput>

<cfif isdefined("form.submit")>



	<!--- Update Image Config --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating image config properties...</cfoutput><cfflush>
	<cfquery name="qList" datasource="#application.dsn#">
	SELECT	wconfig
	FROM	#application.dbowner#config
	WHERE	configname = 'image'
	</cfquery>

	<cfwddx action="wddx2cfml" input="#qList.wconfig#" output="stConfig">
	
	<cfif NOT StructKeyExists(stConfig,"SourceImagePath")>
	
		<cfset stConfig.SourceImagePath = "#application.path.project#/www/images/Source" />
		<cfset stConfig.SourceImageURL = "/images/Source" />
		
		<cfset stConfig.ThumbnailImagePath = "#application.path.project#/www/images/Thumbnail" />
		<cfset stConfig.ThumbnailImageURL = "/images/Thumbnail" />
		<cfset stConfig.ThumbnailImageWidth = "80" />
		<cfset stConfig.ThumbnailImageHeight = "80" />
		
		<cfset stConfig.StandardImagePath = "#application.path.project#/www/images/Standard" />
		<cfset stConfig.StandardImageURL = "/images/Standard" />
		<cfset stConfig.StandardImageWidth = "400" />
		<cfset stConfig.StandardImageHeight = "400" />
	</cfif>
	
	<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">
	<cfquery name="qUpdate" datasource="#application.dsn#">
	UPDATE	#application.dbowner#config
	SET		wconfig = '#wConfig#'
	WHERE	configname = 'image'
	</cfquery>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>
	
	
	<!--- Adding the SourceImage, StandardImage and ThumbnailImage entry to dmImage table --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Adding the SourceImage, StandardImage and ThumbnailImage entry to dmImage table...</cfoutput><cfflush>
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD SourceImage VARCHAR2(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD StandardImage VARCHAR2(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD ThumbnailImage VARCHAR2(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="mysql">
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD SourceImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD StandardImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD ThumbnailImage VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfcase value="postgresql">
				
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD SourceImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD StandardImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD ThumbnailImage VARCHAR(255) NULL
				</cfquery>
			</cfcase>
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD SourceImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD StandardImage VARCHAR(255) NULL
				</cfquery>
				<cfquery name="update" datasource="#application.dsn#">
					ALTER TABLE #application.dbowner#dmImage ADD ThumbnailImage VARCHAR(255) NULL
				</cfquery>
			</cfdefaultcase>
		</cfswitch>

		<cfcatch><cfset error=1><cfoutput><p><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span></p></cfoutput></cfcatch>
	</cftry>

	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>
	

	<!--- Create SourceImages, thumbnailImages and StandardImages directories  --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Create SourceImages, thumbnailImages and StandardImages directories...</cfoutput><cfflush>
	<cftry>
	
		<cfif NOT directoryExists("#application.path.project#\www\images\Source\")>
			<cfdirectory action="create" directory="#application.path.project#\www\images\Source\">
		</cfif>
		<cfif NOT directoryExists("#application.path.project#\www\images\thumbnail\")>
			<cfdirectory action="create" directory="#application.path.project#\www\images\thumbnail\">
		</cfif>
		<cfif NOT directoryExists("#application.path.project#\www\images\Standard\")>
			<cfdirectory action="create" directory="#application.path.project#\www\images\Standard\">
		</cfif>
		
		
		<cfcatch><cfset error=1><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>


	<!--- Updating SourceImage, StandardImage and ThumbnailImage initial values --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Updating SourceImage, StandardImage and ThumbnailImage initial values...</cfoutput><cfflush>
	<cftry>
	
			
		<cfquery name="qUpdate" datasource="#application.dsn#">
		UPDATE	#application.dbowner#dmImage
		SET		ThumbnailImage = '',
				StandardImage = '',
				SourceImage = ''
		</cfquery>	
		
		<cfquery datasource="#application.dsn#" name="qImages">
		SELECT * FROM dmImage
		</cfquery>
		
					
		<cfoutput query="qImages">
			
			<cfif not len(qImages.ThumbnailImage) and len(qImages.Thumbnail)>
				<cfset NewImageName = qImages.Thumbnail>
				<cfif len(qImages.ThumbnailImagePath)>
					<!--- Strip the path from the Image Name if required --->
					<cfset NewImageName = ReplaceNoCase(NewImageName, qImages.ThumbnailImagePath, "" , "ALL")>
				</cfif>
				<!--- Strip //'s if any' --->
				<cfset NewImageName = ReplaceNoCase('/images/Thumbnail/#NewImageName#','//','/','ALL')>
				
				<cfquery name="qUpdate" datasource="#application.dsn#">
				UPDATE	#application.dbowner#dmImage
				SET		ThumbnailImage = '#NewImageName#'
				WHERE	objectid = '#qImages.objectid#'
				</cfquery>	
			
			</cfif> 
			
			<cfif not len(qImages.StandardImage) and len(qImages.OptimisedImage)>
				<cfset NewImageName = qImages.OptimisedImage>
				<cfif len(qImages.OptimisedImagePath)>
					<!--- Strip the path from the Image Name if required --->
					<cfset NewImageName = ReplaceNoCase(NewImageName, qImages.OptimisedImagePath, "" , "ALL")>
				</cfif>
				<!--- Strip //'s if any' --->
				<cfset NewImageName = ReplaceNoCase('/images/Standard/#NewImageName#','//','/','ALL')>

				<cfquery name="qUpdate" datasource="#application.dsn#">
				UPDATE	#application.dbowner#dmImage
				SET		StandardImage = '#NewImageName#'
				WHERE	objectid = '#qImages.objectid#'
				</cfquery>	
			</cfif>
			
			<cfif not len(qImages.SourceImage) and len(qImages.ImageFile)>
				<cfset NewImageName = qImages.ImageFile>
				<cfif len(qImages.OriginalImagePath)>
					<!--- Strip the path from the Image Name if required --->
					<cfset NewImageName = ReplaceNoCase(NewImageName, qImages.OriginalImagePath, "" , "ALL")>
				</cfif>
				<!--- Strip //'s if any' --->
				<cfset NewImageName = ReplaceNoCase('/images/Source/#NewImageName#','//','/','ALL')>

				<cfquery name="qUpdate" datasource="#application.dsn#">
				UPDATE	#application.dbowner#dmImage
				SET		SourceImage = '#NewImageName#'
				WHERE	objectid = '#qImages.objectid#'
				</cfquery>	
			</cfif>
		</cfoutput>
		
		
		<cfcatch><cfset error=1><cfoutput><br /><span class="frameMenuBullet">&raquo;</span><cfdump var="#cfcatch#"> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>
	

	<!--- Copy Files from Old Locations to New Locations --->
	<cfset error = 0>
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> Copying Files from Old Locations to New Locations...</cfoutput><cfflush>
	<cftry>
	
		<cfquery datasource="#application.dsn#" name="qImages">
		SELECT * FROM dmImage
		</cfquery>
		
		<cfoutput query="qImages">
			
				
			<cfif fileExists("#qImages.ThumbnailImagePath#\#qImages.Thumbnail#")
					AND NOT fileExists("#application.path.project#\www\images\thumbnail\#qImages.Thumbnail#") >
				<cffile action="copy" source="#qImages.ThumbnailImagePath#\#qImages.Thumbnail#"
						destination="#application.path.project#\www\images\thumbnail\">
			</cfif>
		
			<cfif fileExists("#qImages.ThumbnailImagePath#\#qImages.OptimisedImage#")
					AND NOT fileExists("#application.path.project#\www\images\Standard\#qImages.OptimisedImage#") >
				<cffile action="copy" source="#qImages.ThumbnailImagePath#\#qImages.OptimisedImage#"
						destination="#application.path.project#\www\images\Standard\">
			</cfif>
		
			<cfif fileExists("#qImages.OriginalImagePath#\#qImages.ImageFile#")
					AND NOT fileExists("#application.path.project#\www\images\Source\#qImages.ImageFile#") >
				<cffile action="copy" source="#qImages.OriginalImagePath#\#qImages.ImageFile#"
						destination="#application.path.project#\www\images\Source\">
			</cfif>
		</cfoutput>
		
		
		<cfcatch><cfset error=1><cfoutput><br /><span class="frameMenuBullet">&raquo;</span> <span class="error">#cfcatch.detail#</span></cfoutput></cfcatch>
	</cftry>
	<cfif not error>
		<cfoutput><strong>done</strong></p></cfoutput><cfflush>
	</cfif>	


	<!---
		clean up caching: kill all shared scopes and force application initialisation
			- application
			- session
			- server.dmSec[application.applicationname]
	 --->
	<cfset application.init=false>
	<cfset session=structnew()>
	<cfset server.dmSec[application.applicationname] = StructNew()>
	<cfoutput><p><strong>All done.</strong> Return to <a href="#application.url.farcry#/index.cfm">FarCry Webtop</a>.</p></cfoutput>
	<cfflush>
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li>Update Image Config</li>
		<li>Adds the SourceImage, StandardImage and ThumbnailImage entry to dmImage table</li>
		<li>Create SourceImages, thumbnailImages and StandardImages directories</li>
		<li>Update SourceImage, StandardImage and ThumbnailImage initial values</li>
		<li>Copy Files from Old Locations to New Locations</li>
	</ul>
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run 3.1.0 Update" name="submit">
	</form>

	</cfoutput>
</cfif>

</body>
</html>
