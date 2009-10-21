<cfcomponent displayName="Farcry Image Manipulation" hint="Require ColdFusion 6.1 or above">
	
	<cffunction name="fResize" access="public" returntype="struct" hint="resize the image to a certain width">
		<cfargument name="originalFile" type="string" required="true" hint="Path to the image">
		<cfargument name="destinationFile" type="string" required="false" default="" hint="Resized image path, either local or absolute">
		<cfargument name="maxWidth" type="numeric" required="false" default="100" hint="New width (pixels). Default to 100">
		<cfargument name="maxHeight" type="numeric" required="false" default="100" hint="New width (pixels). Default to 100">

		<cfset var stLocal = StructNew() />
		<cfset stLocal.stReturn = StructNew() />

		<cftry>
			<!--- For simple image resizing, try cfimage tag first (requires CF8+, otherwise use native JAI) --->
			<cfimage action="resize" height="#stLocal.maxHeight#" width="#stLocal.maxWidth#" source="#arguments.originalFile#" destination="#arguments.destinationFile#" overwrite="true" quality="1" />
			<cfcatch>
				<cfset stLocal.bufferedImage = fRead(arguments.originalFile) />
				<cfset stLocal.height = stLocal.bufferedImage.getHeight() />
				<cfset stLocal.width = stLocal.bufferedImage.getWidth() />
				<cfset stLocal.scaling = fCalculateRatioWidth(stLocal.width,stLocal.height,arguments.maxWidth,arguments.maxHeight) />

				<cfset stLocal.bi = createObject("java","java.awt.image.BufferedImage").init(JavaCast("int", stLocal.width/stLocal.scaling), JavaCast("int", stLocal.height/stLocal.scaling), JavaCast("int", 1)) />
				<cfset stLocal.graphics = stLocal.bi.getGraphics() />
				<cfset stLocal.jTransform = createObject("java","java.awt.geom.AffineTransform").init() />
				<cfset stLocal.jTransform.Scale(1/stLocal.scaling, 1/stLocal.scaling) />
				<cfset stLocal.graphics.drawRenderedImage(stLocal.bufferedImage, stLocal.jTransform) />
				<cfset stLocal.outFile = createObject("java","java.io.File").init(arguments.destinationFile) />
				<cfset createObject("java","javax.imageio.ImageIO").write(stLocal.bi,"jpg",stLocal.outFile) />
			</cfcatch>
		</cftry>

		<cfreturn stLocal.stReturn />
	</cffunction>

	<cffunction name="fCalculateRatioWidth" access="public" returntype="numeric" hint="returns new width based on max width and maintaining width/height ratio">
		<cfargument name="originalWidth" type="numeric" required="true" hint="New width (pixels). Default to 100">
		<cfargument name="originalHeight" type="numeric" required="true" hint="New width (pixels). Default to 100">
		<cfargument name="maxWidth" type="numeric" required="true" hint="maximum allowabe width">
		<cfargument name="maxHeight" type="numeric" required="true" hint="maximum allowabe height">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.scaling = StructNew()>
		<cfset stLocal.ratioWidth = 1>

		<cfset stLocal.tempRatioWidth = arguments.maxWidth/arguments.originalWidth>
		<cfset stLocal.tempRatioHeight = arguments.maxHeight/arguments.originalHeight>

	<cfif stLocal.tempRatioWidth LTE stLocal.tempRatioHeight>
		<cfset stLocal.ratioWidth = 1/stLocal.tempRatioWidth>
	<cfelse>
		<cfset stLocal.ratioWidth = 1/stLocal.tempRatioHeight>
	</cfif>

		<cfreturn stLocal.ratioWidth>
	</cffunction>

	<cffunction name="fCreatePresets" access="public" returntype="struct" hint="Create image presets for image content item.">
		<cfargument name="imagePreset" type="string" required="true" hint="options are: thumbnailsImage &amp; standardImage (default: thumnailImage)" />
		<cfargument name="originalFile" type="string" required="true" hint="Absolute path to source image (including image name)" />
		<cfargument name="destinationFile" type="string" required="false" default="" hint="Absolute path to new resized image (including image name) [Optional]" />
		
		<cfset var stLocal = StructNew() />
		<cfset stLocal.stReturn = StructNew() />
		<cfset arguments.originalFile = replace(arguments.originalFile, "\", "/", "all") />

		<!--- can create other image presets too --->
		<cfswitch expression="#arguments.imagePreset#">
			<cfcase value="thumbnailImage">
				<cfset stLocal.maxWidth = application.config.image.thumbnailImageWidth />
				<cfset stLocal.maxHeight = application.config.image.thumbnailImageHeight />
				<!--- <cfset arguments.destinationFile = fGetDefaultDestinationFilePath(arguments.originalFile,'_#arguments.imagePreset#')> --->
				<!--- <cfset arguments.destinationFile = "#application.config.image.folderpath_thumbnail#/#ListLast(arguments.destinationFile,'\')#"> --->
				<cfif arguments.destinationFile eq ''>
					<cfset arguments.destinationFile = "#application.config.image.thumbnailImagePath#/#listLast(arguments.originalFile, '/')#" />
				</cfif>
			</cfcase>
			<cfcase value="standardImage">
				<cfset stLocal.maxWidth = application.config.image.standardImageWidth />
				<cfset stLocal.maxHeight = application.config.image.standardImageHeight />
				<!--- <cfset arguments.destinationFile = fGetDefaultDestinationFilePath(arguments.originalFile,'_#arguments.imagePreset#')> --->
				<!--- <cfset arguments.destinationFile = "#application.config.image.folderpath_thumbnail#/#ListLast(arguments.destinationFile,'\')#"> --->
				<cfif arguments.destinationFile eq ''>
					<cfset arguments.destinationFile = "#application.config.image.standardImagePath#/#listLast(arguments.originalFile, '/')#" />
				</cfif>
			</cfcase>

			<cfdefaultcase>
				<!--- Default: thumnailImage --->
				<cfset stLocal.maxWidth = application.config.image.thumbnailImageWidth />
				<cfset stLocal.maxHeight = application.config.image.thumbnailImageHeight />
				<cfif arguments.destinationFile eq ''>
					<cfset arguments.destinationFile = "#application.config.image.thumbnailImagePath#/#listLast(arguments.originalFile, '/')#" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>

	 	<cfset arguments.destinationFile = replace(arguments.destinationFile, "\", "/", "all") />
		<cfset fResize(originalFile=arguments.originalFile, destinationFile=arguments.destinationFile, maxWidth=stLocal.maxWidth, maxHeight=stLocal.maxHeight) />
		<cfset stLocal.stReturn = fGetProperties(originalFile=arguments.destinationFile) />

		<cfreturn stLocal.stReturn />
	</cffunction>

	<cffunction name="fGetProperties" access="public" returntype="struct" hint="Get properties for image file.">
		<cfargument name="originalFile" type="string" required="true" hint="Path to the image">

		<cfset var stLocal = StructNew()>
		<cfset stLocal.stReturn = StructNew()>

		<cfset stLocal.stReturn.height = 0>
		<cfset stLocal.stReturn.width = 0>
		<cfset stLocal.stReturn.fileSize = 0>
		<cfset stLocal.stReturn.path = "">
		<cfset stLocal.stReturn.filename = "">
		
		<cfdirectory name="stLocal.qList" directory="#GetDirectoryFromPath(arguments.originalFile)#" filter="#GetFileFromPath(arguments.originalFile)#">
		<cfif stLocal.qList.recordCount EQ 1>
			<cfset stLocal.stReturn.fileSize = stLocal.qList.size />
			<cfset stLocal.stReturn.path = GetDirectoryFromPath(arguments.originalFile) />
			<cfset stLocal.stReturn.filename = stLocal.qList.name />
			<cftry>
				<!--- Attempt to use CF8+ image tools to read image (allows us to read from many more image formats for later conversion (ie. bmp)) --->
				<cfimage name="stLocal.bufferedImage" source="#arguments.originalFile#" action="read" />
				<cfset stLocal.stReturn.height = stLocal.bufferedImage.height />
				<cfset stLocal.stReturn.width = stLocal.bufferedImage.width />
				<cfcatch>
					<!--- otherwise default to the Java JAI --->
					<cfset stLocal.bufferedImage = fRead(arguments.originalFile) />
					<cfset stLocal.stReturn.height = stLocal.bufferedImage.getHeight() />
					<cfset stLocal.stReturn.width = stLocal.bufferedImage.getWidth() />
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn stLocal.stReturn>
	</cffunction>

	<cffunction name="fGetDefaultDestinationFilePath" access="public" returntype="string" hint="returns file as a java image object">
		<cfargument name="originalFile" type="string" required="true" hint="Path to the image">
		<cfargument name="filenameSuffix" type="string" required="false" default="_rendered" hint="the name of image eg. originalname_SUFFIX.xxx">
		
		<cfset var stLocal = StructNew()>
		<cfset stLocal.returnString = "">
		<cfset stLocal.tempFileName = ListLast(arguments.originalFile,"\,/")>
		<cfset stLocal.returnString = ListDeleteAt(arguments.originalFile,ListLen(arguments.originalFile,"\,/"),"\,/")& "\">
		<cfset stLocal.returnString = stLocal.returnString & ListFirst(stLocal.tempFileName,".")&"#arguments.filenameSuffix#."&ListLast(stLocal.tempFileName,".")>

		<cfreturn stLocal.returnString>
	</cffunction>

	<cffunction name="fRead" access="public" returntype="any" hint="returns file as a java image object">
		<cfargument name="originalFile" type="string" required="true" hint="Path to the image">
		
		<cfset arguments.originalFile = replace(arguments.originalFile, "\", "/", "all")>
		<cfset stLocal.inFile = createObject("java","java.io.File").init(arguments.originalFile)>
	   	<cfreturn createObject("java","javax.imageio.ImageIO").read(stLocal.inFile)>
	</cffunction>

	<cffunction name="fCreateDefaultDirectories" access="public" returntype="void" hint="creates the default image directories for original, optimised and thumbnail">		
		<cfif not DirectoryExists(application.config.image.folderpath_original)>
			<!--- create origianl image directory --->
			<cfset fCreateDirectory(application.config.image.folderpath_original)>
		</cfif>
		<cfif not DirectoryExists(application.config.image.folderpath_optimised)>
			<!--- create optimised image directory --->
			<cfset fCreateDirectory(application.config.image.folderpath_optimised)>
		</cfif>
		<cfif not DirectoryExists(application.config.image.folderpath_thumbnail)>
			<!--- create thumbnail image directory --->
			<cfset fCreateDirectory(application.config.image.folderpath_thumbnail)>
		</cfif>
	</cffunction>

	<cffunction name="fCreateDirectory" access="public" returntype="void" hint="creates a directory based on the path">
		<cfargument name="directoryPath" type="string" required="true" hint="a directory to create">
		<cfset var stLocal = StructNew()>
		<cfset stLocal.tempPath = arguments.directoryPath>
		<cfset stLocal.tempPath = ReplaceNoCase(stLocal.tempPath,"\","/","all")>
		<cfset stLocal.tempPath = ReplaceNoCase(stLocal.tempPath,"//","/","all")>
		<cfset stLocal.parentDirectoryStartPosition = ListFind(stLocal.tempPath,"www","/")>
		<cfset stLocal.strParentDirectory = "">
		<cfloop index="i" from="1" to="#stLocal.parentDirectoryStartPosition#">
			<cfset stLocal.strParentDirectory = ListAppend(stLocal.strParentDirectory,ListGetAt(stLocal.tempPath,i,"/"),"/")>
		</cfloop>
		<cfset stLocal.aChildDirectory = ListToArray(ReplaceNoCase(stLocal.tempPath,stLocal.strParentDirectory,""),"/")>
		<cfloop index="stLocal.j" from="1" to="#arrayLen(stLocal.aChildDirectory)#">
			<cfdirectory action="list" directory="#stLocal.strParentDirectory#" name="stLocal.qDirectoryList" filter="#stLocal.aChildDirectory[stLocal.j]#">
			<cfif stLocal.qDirectoryList.recordcount EQ 0> <!--- create the directory --->
				<cfdirectory action="create" directory="#stLocal.strParentDirectory#/#stLocal.aChildDirectory[stLocal.j]#">
			</cfif>
			<cfset stLocal.strParentDirectory = ListAppend(stLocal.strParentDirectory,stLocal.aChildDirectory[stLocal.j],"/")>
		</cfloop>
	</cffunction>
	
</cfcomponent>