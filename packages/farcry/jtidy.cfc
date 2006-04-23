<cfcomponent name="jtidy" displayname="jTidy" hint="clean out invalid html">

	<cffunction name="makexHTMLValid" displayname="Tidy parser" hint="Takes a string as an argument and returns parsed and valid xHTML" output="true">
		<cfargument name="strToParse" required="true" type="string" default="" />
		<cfscript>
		/**
		* This function reads in a string, checks and corrects any invalid HTML.
		* By Greg Stewart
		*
		* @param strToParse The string to parse (will be written to file).
		* accessible from the web browser
		* @return returnPart
		* @author Greg Stewart (gregs(at)tcias.co.uk)
		* @version 1, August 22, 2004
		
		* @version 1.1, September 09, 2004
		* with the help of Mark Woods this UDF no longer requires temp files and only accepts
		* the string to parse
		*/
		
		var returnPart = ""; // return variable
		parseData = trim(arguments.strToParse);
		
		// jTidy part
/*
		// BD free version
		pathToTidy = "/usr/local/NewAtlanta/BlueDragon_Server_61/lib/ext/Tidy.jar";
		// Create an instance of java.net.URL for passing to the URLClassLoader
		URLObject = createObject('java','java.net.URL');
		// Initialize the object with the jar file
		URLObject.init("file:" & pathToTidy);
		// Create an Array and add our URLObject to it
		arr[1] = urlobject;
		// Create and the URLClassLoader and pass it the array containing our path
		loader = createObject('java','java.net.URLClassLoader');
		loader.init(arr);
		// Use our new class loader to load the DOMConfigurator class
		//jTidy = loader.loadClass("org.w3c.tidy.Tidy").newInstance();
*/		
		// CFMX/J2EE
		 jTidy = createObject("java","org.w3c.tidy.Tidy");
		
		jTidy.setQuiet(false);
		jTidy.setIndentContent(true);
		jTidy.setSmartIndent(true);
		jTidy.setIndentAttributes(true);
		jTidy.setWraplen(1024);
		jTidy.setXHTML(true);
		
		// create the in and out streams for jTidy
		readBuffer = CreateObject("java","java.lang.String").init(parseData).getBytes();
		inP = createobject("java","java.io.ByteArrayInputStream").init(readBuffer);
		//ByteArrayOutputStream
		outx = createObject("java", "java.io.ByteArrayOutputStream").init();
		
		// do the parsing
		jTidy.parse(inP,outx);
		// close the stream
		// outx.close();
		outstr = outx.toString();
		
		// ok now strip all the header/body stuff
		startPos = REFind("<body>", outstr)+6;
		endPos = REFind("</body>", outstr);
		returnPart = Mid(outstr, startPos, endPos-startPos);
		</cfscript>
		<cfreturn returnPart />
	</cffunction>
</cfcomponent>