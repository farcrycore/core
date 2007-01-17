<!---
	$Id: image.cfc,v 1.3 2004/09/17 13:45:33 jdew Exp $
	Purpose: This is a small image manipulation component.

	Modified by Rick Root (rick@webworksllc.com) for inclusion
	in the CFFM Coldfusion File Manager (cfopen.org/projects/cffm)
	
	Modified version 1.3.1
	
	Added some error correction.  Detect usable filetypes.
	Enhanced resize functionality:
		resize(width,height) = resize image to specified width and height
		resize(width,0) = scale image to specified width
		resize(0,height) = scale image to specified height

	Example use:

	<cfscript>
		myImage = CreateObject("Component", "image");

		myImage.readImage("c:\htdocs\haru.jpg");
		myImage.readURL("http://www.somedomain.com/haru.jpg");
		myImage.resize(600,600);
		myImage.writeImage("c:\htdocs\600x600.jpg");
		myImage.resize(150,150);
		myImage.writeImage("c:\htdocs\150x150.jpg");
		myImage.resize(75,75);
		myImage.writeImage("c:\htdocs\75x75.jpg");

		myImage.readImage("c:\htdocs\haru.jpg",50,50);
		myImage.watermark("c:\htdocs\wm.jpg");
		myImage.writeImage("c:\htdocs\watermark.jpg");
		myImage.resize(900,900);
		myImage.writeImage("c:\htdocs\900x900.jpg");
	</cfscript>

	Copyright (c) 2004 James F. Dew <jdew@yggdrasil.ca>
 
	Permission to use, copy, modify, and distribute this software for any
	purpose with or without fee is hereby granted, provided that the above
	copyright notice and this permission notice appear in all copies.
 
	THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
	WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
	MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
	ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
	WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
	ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
	OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

	SPECIAL NOTE: To use this tag if you get error messages such as 
	"cannot connect to X11 server..." when trying to use the WATERMARK routine,
	you must add: "-Djava.awt.headless=true" to the startup java line.
	EG: "$JAVA_HOME/bin/java" -server $HEAPSIZES -classpath "$NEW_CLASSPATH" \
		 -Djava.awt.headless=true com.newatlanta.webserver.BlueDragon &
--->

<cfcomponent displayname="Image">
	<cfscript>
		myImage = CreateObject("java", "java.awt.image.BufferedImage");
		imageIO = CreateObject("java", "javax.imageio.ImageIO");
		inFile  = CreateObject("java", "java.io.File");
		inURL	= CreateObject("java", "java.net.URL");
		outFile = CreateObject("java", "java.io.File");
		/* add valid image types */
		validExtensionsToRead = ArrayToList(imageIO.getReaderFormatNames());
		validExtensionsToWrite = ArrayToList(imageIO.getWriterFormatNames());
	</cfscript>

	<cffunction name="readImage" access="public" output="false" returntype="boolean">
		<cfargument name="inputFile" required="yes" type="string">
		<cfset var myImage2 = 1>
		<cfscript>
			if (listFindNoCase(validExtensionsToRead, lcase(listLast(inputFile,"."))) is 0)
			{
				return false;
			}
			inFile.init(arguments.inputFile);
			myImage2 = imageIO.read(inFile);
			if (isDefined("myImage2")) {
				myImage = myImage2;
				return isImageLoaded(myImage);
			} else {
				myImage = CreateObject("java", "java.awt.image.BufferedImage");
				return false;
			}
		</cfscript>
	</cffunction>

	<cffunction name="readURL" access="public" output="false" returntype="boolean">
		<cfargument name="inputURL" required="yes" type="string">
		<cfset var myImage2 = 1>
		<cfscript>
			if (listFindNoCase(validExtensionsToRead, lcase(listLast(inputURL,"."))) is 0)
			{
				return false;
			}
			inURL.init(inputURL);
			myImage2 = imageIO.read(inURL);
			if (isDefined("myImage2")) {
				myImage = myImage2;
				return isImageLoaded(myImage);
			} else {
				myImage = CreateObject("java", "java.awt.image.BufferedImage");
				return false;
			}
		</cfscript>
	</cffunction>

	<cffunction name="isImageLoaded" access="private" output="false" returntype="boolean">
		<cfargument name="imageObject" type="any" required="yes">
		<cftry>
			<cfset tmp = imageObject.getWidth()>
			<cfcatch type="Any">
				<cfset imageObject = "">
				<cfreturn false>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="writeImage" access="public" output="true">
		<cfargument name="outputFile" required="yes" type="string">
		<cfscript>
			var extension = lcase(listLast(outputFile,"."));
			if (listFindNoCase(validExtensionsToWrite, extension) gt 0)
			{
				outFile.init(arguments.outputFile);
				try {
					imageIO.write(myImage, extension, outFile);
				} catch (Any e) {
					return false;
				}
				return true;
			} else {
				return false;
			}
		</cfscript>
	</cffunction>

	<cffunction name="width" access="public" output="false" returnType="any">
	<cfscript>
		if (isImageLoaded(myImage)) 
		{
			return myImage.getWidth();
		} else {
			return 0;
		}
	</cfscript>
	</cffunction>

	<cffunction name="height" access="public" output="false" returnType="any">
	<cfscript>
		if (isImageLoaded(myImage))
		{
			return myImage.getHeight();
		} else {
			return 0;
		}
	</cfscript>
	</cffunction>

	<cffunction name="flip" access="public" output="false">
		<cfscript>
			var flippedImage = CreateObject("java", "java.awt.image.BufferedImage");
			var at = CreateObject("java", "java.awt.geom.AffineTransform");
			var op = CreateObject("java", "java.awt.image.AffineTransformOp");

			flippedImage.init(myImage.getWidth(), myImage.getHeight(), myImage.getType());

			at = at.getScaleInstance(1,-1);
			at.translate(0, -myImage.getHeight());
			op.init(at, op.TYPE_BILINEAR);
			op.filter(myImage, flippedImage);

			myImage = flippedImage;
		</cfscript>
	</cffunction>

	<cffunction name="flop" access="public" output="false">
		<cfscript>
			var floppedImage = CreateObject("java", "java.awt.image.BufferedImage");
			var at = CreateObject("java", "java.awt.geom.AffineTransform");
			var op = CreateObject("java", "java.awt.image.AffineTransformOp");

			floppedImage.init(myImage.getWidth(), myImage.getHeight(), myImage.getType());

			at = at.getScaleInstance(-1,1);
			at.translate(-myImage.getWidth(), 0);
			op.init(at, op.TYPE_BILINEAR);
			op.filter(myImage, floppedImage);

			myImage = floppedImage;
		</cfscript>
	</cffunction>

<cffunction name="resize" access="public" output="false" returnType="boolean">
		<cfargument name="width" required="no" type="numeric" default="0">
		<cfargument name="height" required="no" type="numeric" default="0">
		<cfscript>
		var at = "";
		var op = "";
		var w = "";
		var h = "";
		var scale = 1;
		var resizedImage = "";

		if ( NOT isImageLoaded(myImage) ) {
			/* no image to start with */
			return false;
		}
		resizedImage = CreateObject("java", "java.awt.image.BufferedImage");
		at = CreateObject("java", "java.awt.geom.AffineTransform");
		op = CreateObject("java", "java.awt.image.AffineTransformOp");

		w = myImage.getWidth();
		h = myImage.getHeight();

		if (width gt 0 and height eq 0) {
			scale = width / w;
			w = width;
			h = round(h*scale);
		} else if (height gt 0 and width eq 0) {
			scale = height / h;
			h = height;
			w = round(w*scale);
		} else if (height gt 0 and width gt 0) {
			w = width;
			h = height;
		} else {
			return false;
		}
		resizedImage.init(javacast("int",w),javacast("int",h),myImage.getType());

		w = w / myImage.getWidth();
		h = h / myImage.getHeight();

		op.init(at.getScaleInstance(w,h), op.TYPE_BILINEAR);
		op.filter(myImage, resizedImage);

		if ( NOT isImageLoaded(resizedImage) ) {
			/* resizing failed */
			return false;
		}

		myImage = resizedImage;
		return true;
		</cfscript>
</cffunction>

<!--- JIM DEW'S ORIGINAL RESIZE CODE ONLY SCALED A CERTAIN WAY --->
	<cffunction name="oldresize" access="public" output="false">
		<cfargument name="side" required="yes" type="numeric">
		<cfscript>
			var resizedImage = CreateObject("java", "java.awt.image.BufferedImage");
			var at = CreateObject("java", "java.awt.geom.AffineTransform");
			var op = CreateObject("java", "java.awt.image.AffineTransformOp");

			var h = myImage.getHeight();
			var w = myImage.getWidth();

			if(h gte w) { w = w * arguments.side / h; h = arguments.side;}
			else		  { h = h * arguments.side / w; w = arguments.side;}

			resizedImage.init(w,h,myImage.getType());

			w = w / myImage.getWidth();
			h = h / myImage.getHeight();

			op.init(at.getScaleInstance(w,h), op.TYPE_BILINEAR);
			op.filter(myImage, resizedImage);

			myImage = resizedImage;
		</cfscript>
	</cffunction>

	<cffunction name="rotate" access="public" output="false">
		<cfargument name="degrees" required="yes" type="numeric">
		<cfscript>
			//degrees must be 90,180, or 270.
			var x = 0;
			var y = 0;
			var w = 0;
			var h = 0;
			var rotatedImage = CreateObject("java", "java.awt.image.BufferedImage");
			var at = CreateObject("java", "java.awt.geom.AffineTransform");
			var op = CreateObject("java", "java.awt.image.AffineTransformOp");

			iw = myImage.getWidth(); h = iw;
			ih = myImage.getHeight(); w = ih;

			if(arguments.degrees eq 180) { w = iw; h = ih; }
					
			x = (w/2)-(iw/2);
			y = (h/2)-(ih/2);

			rotatedImage.init(w,h,myImage.getType());

			at.rotate(arguments.degrees * 0.0174532925,w/2,h/2);
			at.translate(x,y);
			
			op.init(at, op.TYPE_BILINEAR);

			op.filter(myImage, rotatedImage);

			myImage = rotatedImage;
		</cfscript>
	</cffunction>

	<cffunction name="watermark" access="public" output="false">
		<cfargument name="wmfile" required="yes" type="string">
		<cfargument name="x" required="no" type="numeric" default="0">
		<cfargument name="y" required="no" type="numeric" default="0">
		<cfscript>
			var wm = CreateObject("java", "java.awt.image.BufferedImage");
			var wminFile = CreateObject("java", "java.io.File");
			var at = CreateObject("java", "java.awt.geom.AffineTransform");
			var op = CreateObject("java", "java.awt.image.AffineTransformOp");
			var AlphaComposite = CreateObject("Java", "java.awt.AlphaComposite");
			//var gfx = CreateObject("java", "java.awt.Graphics");
			var gfx = myImage.getGraphics();

			wminfile.init(arguments.wmfile);
			wmImage = imageIO.read(wminFile);
			gfx.setComposite(AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.75));

			at.init();
			op.init(at,op.TYPE_BILINEAR);
			gfx.drawImage(wmImage, op, arguments.x, arguments.y);
			gfx.dispose();
		</cfscript>
	</cffunction>
</cfcomponent>
