<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/image.cfc,v 1.4 2003/09/21 23:27:07 brendan Exp $
$Author: brendan $
$Date: 2003/09/21 23:27:07 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: image manipulation cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Image Manipulation" hint="CFC based around image J java class">

	<cffunction name="getDetails" access="public" returntype="struct" hint="Returns a structure of attributes for specified image">
	  <cfargument name="imagePath" type="string" required="true" hint="Path to the image">
	  
	  <cfscript>
	   // create structure for image details
	   stImageDetail = structNew();
	  </cfscript>
	  
	  <cfif fileExists(arguments.ImagePath)>
	   <!--- create imagej objects --->
	   <cfobject type="java" name="objImagePlus" class="ij.ImagePlus" action="create">
	   <cfobject type="java" name="objOpener" class="ij.io.Opener" action="create">
	
	   <cfscript>
	
	    objImage = objOpener.openImage(arguments.ImagePath);
	    //get properties
	    stImageDetail.Properties = objImage.getProperties();
	    //get width
	    stImageDetail.Width = objImage.getWidth();
	    //get height
	    stImageDetail.Height = objImage.getHeight();
	    //get image type
	    numType = objImage.getType();
	   </cfscript>
	
	   <!--- convert image type into meaningful name --->
	   <cfswitch expression="#numType#">
	    <cfcase value="0"><cfset stImageDetail.Type = "GRAY8"></cfcase>
	    <cfcase value="1"><cfset stImageDetail.Type = "GRAY16"></cfcase>
	    <cfcase value="2"><cfset stImageDetail.Type = "GRAY32"></cfcase>
	    <cfcase value="3"><cfset stImageDetail.Type = "COLOR_256"></cfcase>
	    <cfcase value="4"><cfset stImageDetail.Type = "COLOR_RGB"></cfcase>
	   </cfswitch>
	  </cfif>
	
	  <!--- return image detail structure  --->
	  <cfreturn stImageDetail>
	 </cffunction>
	
	<!---
	 Resize a image based on width or height :
	  By default, it has the value resize type is "auto" : the maximum size will be detected 
	  (it could be height or width) and is used as reference for the resize.
	  If the ResizeType is "width", resize is based on width
	  If the ResizeType is "height", resize is based on height
	
	 @param OriginalImagePath 	 String (complete path including the file name). (Required)
	 @param ResizedImagePath 	 String (complete path including the file name). (Required)
	 @param ResizeValue 	 Numeric (resized value in pixels). (Required)
	 @param ResizeType 	 String (resized type, possible value are "auto", "width" or "height"). (Optional)
	 @return Returns Boolean (true if successfull). 
	 @author Benoit Hediard (ben@benorama.com) 
	 @version 0.9, July 22, 2002 
	--->
	<cffunction name="Resize" output="false" returntype="boolean">
		<cfargument name="OriginalImagePath" type="string" required="true">
		<cfargument name="ResizedImagePath" type="string" required="true">
		<cfargument name="ResizeValue" type="numeric" required="true">
		<cfargument name="ResizeType" type="string" required="false" default="auto" hint="Possible value : auto, width or height">
		<cfset var bOK = false>
		
		<cfif fileExists(arguments.OriginalImagePath)>
			<cfobject type="java" name="objImagePlus" class="ij.ImagePlus" action="create">
			<cfobject type="java" name="objOpener" class="ij.io.Opener" action="create">
			<cfobject type="java" name="objFileSaver" class="ij.io.FileSaver" action="create">
			<cfscript>
			objOriginalImage = objOpener.openImage(arguments.OriginalImagePath);
			numOriginalType = objOriginalImage.getType();
			numOriginalWidth = objOriginalImage.getWidth();
			numOriginalHeight = objOriginalImage.getHeight();
			</cfscript>
			
			<cfswitch expression="#arguments.ResizeType#">
			<cfcase value="auto">
				<cfif numOriginalWidth gte numOriginalHeight>
					<cfset numResizedWidth = arguments.ResizeValue>
					<cfset numResizedHeight = Round(numResizedWidth * numOriginalHeight / numOriginalWidth)>
				<cfelse>
					<cfset numResizedHeight = arguments.ResizeValue>
					<cfset numResizedWidth = Round(numResizedHeight * numOriginalWidth / numOriginalHeight)>
				</cfif>
			</cfcase>
			<cfcase value="height">
				<cfset numResizedHeight = arguments.ResizeValue>
				<cfset numResizedWidth = Round(numResizedHeight * numOriginalWidth / numOriginalHeight)>
			</cfcase>
			<cfcase value="width">
				<cfset numResizedWidth = arguments.ResizeValue>
				<cfset numResizedHeight = Round(numResizedWidth * numOriginalHeight / numOriginalWidth)>
			</cfcase>
			</cfswitch>
			
			<cfscript>
				objResizedProcessor = objOriginalImage.getProcessor().resize(JavaCast("int",numResizedWidth),JavaCast("int",numResizedHeight));
				objResizedImage = objImagePlus.init("Vignette",objResizedProcessor); 
				
				objSaver = objFileSaver.init(objResizedImage);
				if (numOriginalType eq objImagePlus.COLOR_256) bOK = objSaver.saveAsGif(arguments.ResizedImagePath); 
				if (numOriginalType eq objImagePlus.COLOR_RGB) bOK = objSaver.saveAsJpeg(arguments.ResizedImagePath); 
				if (numOriginalType eq objImagePlus.GRAY8) bOK = objSaver.saveAsJpeg(arguments.ResizedImagePath); 
				if (numOriginalType eq objImagePlus.GRAY16) bOK = objSaver.saveAsJpeg(arguments.ResizedImagePath); 
				if (numOriginalType eq objImagePlus.GRAY8) bOK = objSaver.saveAsJpeg(arguments.ResizedImagePath); 
			</cfscript>
		</cfif>
		
		<cfreturn bOK>
	</cffunction>

	<cffunction name="convertFormat" access="public" returntype="struct" hint="Changes an image's format eg from jpg to gif">
		<cfargument name="imagePath" type="string" required="true" hint="Path to the image">
		<cfargument name="NewFormat" type="string" required="true" hint="Format you wish to convert the image into">
		
		<cfset myResult="foo">
		<cfreturn stConvert>
	</cffunction>
</cfcomponent>