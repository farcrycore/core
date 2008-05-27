<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/image.cfc,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: image manipulation cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Farcry Image Manipulation" hint="Abstract CFC based around imageJ Java Archive - version 0.9, 24 april 2003, Benoit Hediard (ben@benorama.com)">
	<cfproperty name="imagePath" hint="Image path of the opened image (private)">
	<cfproperty name="imageType" hint="Image type of the opened image (private)">
	<cfproperty name="imagePlus" hint="ij.ImagePlus java object (private)">
	<cfproperty name="imageProcessor" hint="ij.process.ImageProcessor java object (private)">
	
	<cffunction name="open" output="true" returntype="boolean">
		<cfargument name="imagePath" type="string" required="true" hint="Opens tiff (and tiff stacks), dicom, fits, pgm, png, jpeg, bmp or gif images">
		<cfif not fileExists(arguments.imagePath)>
			<cfthrow message="ImageJ Wrapper open method failed" type="ImageJ" detail="The file #arguments.imagePath# does not exists or there was a problem to open the file with ImageJ">
			<cfreturn false>
		</cfif>
		<cfscript>
			imagePath = arguments.imagePath;
			imagePlus = createObject("java","ij.io.Opener").openImage(imagePath);
			imageProcessor = imagePlus.getProcessor();
			imageType = this.getType();
			//jpegQuality = 70; For ImageJ V1.30
			return true;
		</cfscript>
	</cffunction>
	
	<!---
	For ImageJ V1.30
	
	<cffunction name="setJpegQuality" output="false">
		<cfargument name="quality" type="numeric" required="true">
		<cfset var jpegWriter = "">
		<cfscript>
		jpegWriter = createObject("java","ij.plugin.JpegWriter");
		jpegWriter.setQuality(arguments.quality);
		jpegQuality = arguments.quality;
		</cfscript>
	</cffunction>
	--->
	
	<cffunction name="getImagePlus" output="false">
		<cfreturn imagePlus>
	</cffunction>
	
	<cffunction name="getImageProcessor" output="false">
		<cfreturn imageProcessor>
	</cffunction>
	
	<cffunction name="getType" output="false" returntype="string">
		<cfset var typeName = "unknown">
		<cfscript>
			switch (imagePlus.getType()) {
				case 0: typeName = "GRAY8"; break;
				case 1: typeName = "GRAY16"; break;
				case 2:	typeName = "GRAY32"; break;
				case 3: typeName = "COLOR_256"; break;
				case 4: typeName = "COLOR_RGB"; break;
			}
		</cfscript>
		<cfreturn typeName>
	</cffunction>
	
	<cffunction name="getHeight" output="false" returntype="numeric">
		<cfreturn imageProcessor.getHeight()>
	</cffunction>
	
	<cffunction name="getWidth" output="false" returntype="numeric">
		<cfreturn imageProcessor.getWidth()>
	</cffunction>
	
	<!--- ROI --->
	<cffunction name="setROI" output="false" hint="Defines a rectangular region of interest">
		<cfargument name="x" type="numeric" required="true" hint="ROI x coordinate">
		<cfargument name="y" type="numeric" required="true" hint="ROI y coordinate">
		<cfargument name="width" type="numeric" required="true" hint="ROI width">
		<cfargument name="height" type="numeric" required="true" hint="ROI height">	
		<cfset imageProcessor.setROI(javaCast("int",arguments.x),javaCast("int",arguments.y),javaCast("int",arguments.width),javaCast("int",arguments.height))>
	</cffunction>
	
	<cffunction name="resetROI" output="false" hint="Sets the ROI (Region of Interest) to the entire image">
		<cfset imageProcessor.resetROI()>
	</cffunction>
	
	<!--- Drawing API --->
	<cffunction name="setFont" output="false" hint="Sets the font used by drawString()">
		<cfargument name="name" type="string" default="SansSerif" hint="logical name of this font">
		<cfargument name="size" type="numeric" default="11" hint="point size">
		<cfargument name="isBold" type="boolean" default="false">
		<cfargument name="isItalic" type="boolean" default="false">
		<cfargument name="isAntialiased" type="boolean" required="true" hint="does not work... (???)">
		<cfset var font = createObject("java","java.awt.Font")>
		<cfset var styleID = 0>
		<cfif arguments.isBold and arguments.isItalic>
			<cfset styleID = 3>
		<cfelseif arguments.isBold>
			<cfset styleID = 1>
		<cfelseif arguments.isItalic>
			<cfset styleID = 2>
		</cfif>
		<cfset font.init(arguments.name,styleID,arguments.size)>
		<cfset imageProcessor.setFont(font)>	
		<cfset imageProcessor.setAntialiasedText(arguments.isAntialiased)>
	</cffunction>
	
	<cffunction name="setColor" output="false" hint="Sets the default fill/draw value to the pixel value closest to the specified color">
		<cfargument name="hexaColor" type="string" required="true" hint="Hexadecimal color, ex: FF0044">
		<cfset var color = createObject("java","java.awt.Color")>
		<cfset var decimalRed = inputBaseN(left(arguments.hexaColor,2),16)>
		<cfset var decimalGreen = inputBaseN(mid(arguments.hexaColor,3,2),16)>
		<cfset var decimalBlue = inputBaseN(right(arguments.hexaColor,2),16)>
		<cfset imageProcessor.setColor(color.init(decimalRed, decimalGreen, decimalBlue))>
	</cffunction>
	
	<cffunction name="setLineWidth" output="false" hint="Sets the line width used by lineTo() and drawDot()">
		<cfargument name="width" type="numeric" required="true">
		<cfset imageProcessor.setLineWidth(javaCast("int",arguments.width))>
	</cffunction>
	
	<cffunction name="moveTo" output="false"hint="Sets the current drawing location">
		<cfargument name="x" type="numeric" required="true">
		<cfargument name="y" type="numeric" required="true">
		<cfset imageProcessor.moveTo(javaCast("int",arguments.x),javaCast("int",arguments.y))>
	</cffunction>
	
	<cffunction name="lineTo" output="false" hint="Draws a line from the current drawing location to (x,y)">
		<cfargument name="x" type="numeric" required="true">
		<cfargument name="y" type="numeric" required="true">
		<cfset imageProcessor.lineTo(javaCast("int",arguments.x),javaCast("int",arguments.y))>
	</cffunction>
	
	<cffunction name="drawLine" output="false" hint="Draws a line from (x1,y1) to (x2,y2)">
		<cfargument name="x1" type="numeric" required="true">
		<cfargument name="y1" type="numeric" required="true">
		<cfargument name="x2" type="numeric" required="true">
		<cfargument name="y2" type="numeric" required="true">
		<cfset imageProcessor.drawLine(javaCast("int",arguments.x1),javaCast("int",arguments.y1),javaCast("int",arguments.x2),javaCast("int",arguments.y2))>
	</cffunction>
	
	<cffunction name="drawPixel" output="false" hint="Sets the pixel at (x,y) to the current fill/draw value">
		<cfargument name="x" type="numeric" required="true">
		<cfargument name="y" type="numeric" required="true">
		<cfset imageProcessor.drawPixel(javaCast("int",arguments.x),javaCast("int",arguments.y))>
	</cffunction>
	
	<cffunction name="drawRect" output="false" hint="Draws a rectangle.">
		<cfargument name="x" type="numeric" required="true">
		<cfargument name="y" type="numeric" required="true">
		<cfargument name="width" type="numeric" required="true">
		<cfargument name="height" type="numeric" required="true">
		<cfset imageProcessor.drawRect(javaCast("int",arguments.x),javaCast("int",arguments.y),javaCast("int",arguments.width),javaCast("int",arguments.height))>
	</cffunction>
	
	<cffunction name="drawString" output="false" hint="Draws a string at the current location using the current fill/draw value">
		<cfargument name="x" type="numeric" required="true">
		<cfargument name="y" type="numeric" required="true">
		<cfargument name="text" type="string" required="true">
		<cfset imageProcessor.drawString(arguments.text,javaCast("int",arguments.x),javaCast("int",arguments.y))>
	</cffunction>
	
	<cffunction name="fill" output="false" hint="Fills the image or ROI with the current fill/draw value">
		<cfset imageProcessor.fill()>
	</cffunction>
	
	<!--- Filters --->
	<cffunction name="invert" output="false" hint="Inverts the image or ROI">
		<cfset imageProcessor.invert()>
	</cffunction>
	
	<cffunction name="medianFilter" output="false" hint="A 3x3 median filter">
		<cfset imageProcessor.medianFilter()>
	</cffunction>
	
	<cffunction name="smooth" output="false" hint="Replaces each pixel or ROI  with the 3x3 neighborhood mean">
		<cfset imageProcessor.smooth()>
	</cffunction>
	
	<cffunction name="sharpen" output="false" hint="Sharpens the image or ROI using a 3x3 convolution kernel">
		<cfset imageProcessor.sharpen()>
	</cffunction>
	
	<cffunction name="erode" output="false" hint="Erodes the image or ROI using a 3x3 maximum filter">
		<cfset imageProcessor.erode()>
	</cffunction>
	
	<cffunction name="dilate" output="false" hint="Dilates the image or ROI using a 3x3 minimum filter">
		<cfset imageProcessor.dilate()>
	</cffunction>
	
	<cffunction name="findEdges" output="false" hint="Finds edges in the image or ROI using a Sobel operator">
		<cfset imageProcessor.findEdges()>
	</cffunction>
	
	<cffunction name="gamma" output="false" hint="Performs gamma correction of the image or ROI">
		<cfargument name="value" type="numeric" required="true" hint="ex. : 0.5 for lighter, 2 for darker">
		<cfset imageProcessor.gamma(arguments.value)>
	</cffunction>
	
	<cffunction name="grayscale" output="false" hint="Convert color to grayscale">
		<cfset var converter = "">
		<cfscript>
		converter = createObject("java","ij.process.ImageConverter");
		converter.init(imagePlus).convertToGray8();
		</cfscript>
	</cffunction>
	
	<!--- Manipulation methods --->
	<cffunction name="rotateLeft" output="false" hint="Rotates the entire image 90 degrees counter-clockwise">	
		<cfset imageProcessor = imageProcessor.rotateLeft()>
		<cfset imagePlus.setProcessor("",imageProcessor)>
	</cffunction>
	
	<cffunction name="rotateRight" output="false" hint="Rotates the entire image 90 degrees counter-clockwise">	
		<cfset imageProcessor = imageProcessor.rotateRight()>
		<cfset imagePlus.setProcessor("",imageProcessor)>
	</cffunction>
	
	<cffunction name="flipHorizontal" output="false" hint="Flips the image or ROI horizontally">
		<cfset imageProcessor.flipHorizontal()>
	</cffunction>
	
	<cffunction name="flipVertical" output="false" hint="Flips the image or ROI vertically">
		<cfset imageProcessor.flipVertical()>
	</cffunction>
	
	<!--- Size methods --->
	<cffunction name="crop" output="false" hint="Crops the image, based on the given ROI (Region Of Interest)">
		<cfset imageProcessor = imageProcessor.crop()>
		<cfset imagePlus.setProcessor("",imageProcessor)>
	</cffunction>
	
	<cffunction name="scale" output="false" hint="Scales the image by the specified factors. Does not change the image size">
		<cfargument name="xScale" type="numeric" required="true">
		<cfargument name="yScale" type="numeric" required="true">
		<cfset imageProcessor.scale(javaCast("double",arguments.xScale),javaCast("int",arguments.yScale))>
	</cffunction>
	
	
	<!--- IO methods --->
	<cffunction name="save" output="false" hint="Writes the image file on the original file (automatically detect format)">
		<cfargument name="quality" type="numeric" default="70" hint="0 to 100 (for Jpeg only)">
		<cfset this.saveAs(imagePath, arguments.quality)>
	</cffunction>
	
	<cffunction name="saveAs" output="false" hint="Writes the image file (automatically detect format)">
		<cfargument name="imagePath" type="string" default="" hint="If not provided, it overwrites the original file">
		<cfargument name="quality" type="numeric" default="70" hint="0 to 100 (for Jpeg only)">
		<cfscript>
		if (len(trim(arguments.imagePath)) eq 0) arguments.imagePath = imagePath;
		if (imageType is "GRAY8" or imageType is "COLOR_256")  { 
			this.saveAsGif(imagePath); // (8-bits)  
		} else { 
			this.saveAsJpeg(imagePath);
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="saveAsTiff" output="false" hint="Writes the image file to Tiff format">
		<cfargument name="imagePath" type="string" required="true">
		<cfset var saver = "">
		<cfscript>
		saver = createObject("java","ij.io.FileSaver");
		saver.init(imagePlus);
		saver.saveAsTiff(arguments.imagePath);
		</cfscript>	
	</cffunction>
	
	<cffunction name="saveAsZip" output="false" hint="Writes the image file to zipped Tiff format">
		<cfargument name="filePath" type="string" required="true" hint="File path without extension">
		<cfset var saver = "">
		<cfscript>
		saver = createObject("java","ij.io.FileSaver");
		saver.init(imagePlus);
		saver.saveAsZip(arguments.filePath);
		</cfscript>	
	</cffunction>
	
	<cffunction name="saveAsGif" output="false" hint="Writes the image file to Gif format">
		<cfargument name="imagePath" type="string" required="true">
		<cfset var saver = "">
		<cfset var encoder = "">
		<cfset var converter = "">
		<cfset var fileOutputStream = "">
		<cfscript>
		saver = createObject("java","ij.io.FileSaver");
		saver.init(imagePlus);
		if (saver.okForGif(imagePlus)) {
			saver.saveAsGif(arguments.imagePath);
		} else {
			encoder = createObject("java","ij.io.GifEncoder");
			fileOutputStream = createObject("java","java.io.FileOutputStream");
			converter = createObject("java","ij.process.ImageConverter");
			converter.init(imagePlus);
			if (imagePlus.getType() lt 3) { // Grayscale image must be converted to RGB
				converter.convertToRGB();
			}
			converter.convertRGBtoIndexedColor(255);
			fileOutputStream.init(arguments.imagePath);
			encoder.init(imagePlus.getImage()).write(fileOutputStream);
			fileOutputStream.close();
		}
		</cfscript>	
	</cffunction>
	
	<cffunction name="saveAsJpeg" output="false" hint="Writes the image file to Jpeg format, returns true if OK">
		<cfargument name="imagePath" type="string" required="true">
		<cfargument name="quality" type="numeric" default="70" hint="0 to 100">
		<cfset var encoder = "">
		<cfset var fileOutputStream = "">
		<cfscript>
		encoder = createObject("java","ij.io.JpegEncoder");
		fileOutputStream = createObject("java","java.io.FileOutputStream");
		
		fileOutputStream.init(arguments.imagePath);
		encoder.init(imagePlus.getImage(),javaCast("int",arguments.quality),fileOutputStream).compress();
		fileOutputStream.close();
		</cfscript>
	</cffunction>
	
	<!---
	For ImageJ V1.30
	
	<cffunction name="saveAsJpeg" output="false" hint="Writes the image file to Jpeg format, returns true if OK">
		<cfargument name="imagePath" type="string" required="true">
		<cfargument name="quality" type="numeric" hint="0 to 100">
		<cfset var saver = "">
		<cfscript>
		if (structKeyExists(arguments,"quality")) {
			this.setJpegQuality(arguments.quality);
		}
		saver = createObject("java","ij.io.FileSaver");
		saver.init(imagePlus);
		saver.saveAsJpeg(arguments.imagePath);
		</cfscript>
	</cffunction>
	--->

	<cffunction name="getDetails" access="public" returntype="struct" hint="Returns a structure of attributes for specified image">
		<cfargument name="imagePath" type="string" required="false" hint="Path to the image">
		
		<cfset stImageDetail = structNew()>
		<cfscript>
			//Check to see if we already have the image opened
			if(not isDefined("imagePlus"))
				this.open(arguments.ImagePath);
				
			if(isDefined("imagePlus")){
				stImageDetail.Width = this.getWidth();
				stImageDetail.Height = this.getHeight();
				stImageDetail.Type = imageType;
			}
			else
				stImageDetail.error = "Could not open specified image";
		</cfscript>
		<!--- return image detail structure  --->
		<cfreturn stImageDetail>
	</cffunction>
	
	<cffunction name="Resize" output="false" returntype="boolean">
		<cfargument name="originalImagePath" type="string" required="false">
		<cfargument name="resizedImagePath" type="string" required="true">
		<cfargument name="resizeValue" type="numeric" required="true">
		<cfargument name="resizeType" type="string" required="false" default="auto" hint="Possible value : auto, width or height">

		<cfscript>
			var width = 0;
			var height = 0;
			var resizedWidth = 0;
			var resizedHeight = 0;
			
			//Check to see if we already have the image opened
			if(not isDefined("imagePlus"))
				this.open(arguments.originalImagePath);
				
			if(isDefined("imagePlus")){
				width = this.getWidth();
				height = this.getHeight();
				switch (arguments.resizeType) {
					case "height":
						resizedHeight = arguments.resizeValue;
						resizedWidth = round(resizedHeight * width / height);
						break;
					case "width":
						resizedWidth = arguments.resizeValue;
						resizedHeight = round(resizedWidth * height / width);
						break;
					default:
						if (width gte height) {
							resizedWidth = arguments.resizeValue;
							resizedHeight = round(resizedWidth * height / width);
						} else {
							resizedHeight = arguments.resizeValue;
							resizedWidth = round(resizedHeight * width / height);
						}
						break;
				}
				try{
					imageProcessor = imageProcessor.resize(javaCast("int",resizedWidth),javaCast("int",resizedHeight));
					imagePlus.setProcessor("",imageProcessor);
					this.saveAs(arguments.resizedImagePath);
					return true;
				}
				catch(Any e){
					return false;
				}
			}
			else
				return false;
		</cfscript>
	</cffunction>

	<cffunction name="convertFormat" access="public" returntype="struct" hint="Changes an image's format eg from jpg to gif">
		<cfargument name="imagePath" type="string" required="true" hint="Path to the image">
		<cfargument name="NewFormat" type="string" required="true" hint="Format you wish to convert the image into">
		
		<cfset myResult="foo">
		<cfreturn stConvert>
	</cffunction>
</cfcomponent>