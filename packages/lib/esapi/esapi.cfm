<!--- These methods are from cfbackport --->
<!--- https://github.com/misterdai/cfbackport --->

<cffunction name="EncodeForCSS" output="false" returntype="string" hint="Encodes the input string for use in CSS, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForCSS(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>

<cffunction name="DecodeForHTML" output="false" returntype="string" hint="Decodes an HTML encoded string, returns Decoded HTML string">
	<cfargument name="inputString" type="string" required="true" hint="Required. Encoded string to decode" />

	<cfscript>
		var lc = StructNew();
		var decodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		decodedString = lc.encoder.DecodeForHTML(JavaCast("string", arguments.inputString));

		return decodedString;
	</cfscript>
</cffunction>

<cffunction name="EncodeForHTML" output="false" returntype="string" hint="Encodes the input string for use in HTML, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForHTML(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>

<cffunction name="EncodeForHTMLAttribute" output="false" returntype="string" hint="Encodes the input string for use in HTML attribute, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForHTMLAttribute(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>

<cffunction name="EncodeForJavaScript" output="false" returntype="string" hint="Encodes the input string for use in JavaScript, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForJavaScript(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>


<cffunction name="DecodeFromURL" output="false" returntype="string" hint="">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to decode" />

	<cfscript>
		var lc = StructNew();

		local.encoding = createObject("java", "java.lang.System").getProperty("file.encoding");
		try {
				return createObject("java", "java.net.application.fc.lib.esapi.DecodeFromURLr").decode(javaCast("string", canonicalize(arguments.inputString, false, false)), local.encoding);
		}
		// throw the same errors as CF10
		catch(java.io.UnsupportedEncodingException ex) {
			// Character encoding not supported
			throw("There was an error while encoding.", "Application", "For more details check logs.");
		}
		catch(java.lang.Exception e) {
			// Problem URL decoding input
			throw("There was an error while encoding.", "Application", "For more details check logs.");
		}
	</cfscript>
</cffunction>


<cffunction name="EncodeForURL" output="false" returntype="string" hint="Encodes the input string for use in URLs, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForURL(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>

<cffunction name="EncodeForXML" output="false" returntype="string" hint="Encodes the input string for use in XML, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForXML(lc.encoder.canonicalize(JavaCast("string", arguments.inputString), JavaCast("boolean", arguments.strict)));

		return encodedString;
	</cfscript>
</cffunction>


<!---
	Hopefully, ColdFusion is patched and therefore ESAPI is available
	APSB11-04+ installs ESAPI 1.4.4 for CF8.0.x and ESAPI 2.0_rc10 for CF9.0.x and CF9.0.2

	Test for ESAPI existance by calling canonicalize, if exception is thrown
	remove the functions that are dependent upon it
--->
<cftry>
	<cfset canonicalize("", false, false) />

	<cfcatch type="any">
		<cfset StructDelete(variables, "Canonicalize") />
		<cfset StructDelete(variables, "DecodeFromURL") />
		<cfset StructDelete(variables, "EncodeForCSS") />
		<cfset StructDelete(variables, "EncodeForHTML") />
		<cfset StructDelete(variables, "EncodeForHTMLAttribute") />
		<cfset StructDelete(variables, "EncodeForJavaScript") />
		<cfset StructDelete(variables, "EncodeForURL") />
		<cfset StructDelete(variables, "EncodeForXML") />
	</cfcatch>
</cftry>

<!---
	ESAPI 1.4.4 does not have DecodeForHTML
 --->
<cftry>
	<cfset decodeForHTML("") />

	<cfcatch type="any">
		<cfset StructDelete(variables, "DecodeForHTML") />
	</cfcatch>
</cftry>

