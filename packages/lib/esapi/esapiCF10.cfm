<!--- this is a workaround for the built-in ESAPI functions in CF10 --->

<cffunction name="EncodeForHTMLAttributeCF10" output="false" returntype="string" hint="Encodes the input string for use in HTML attribute, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForHTMLAttribute(JavaCast("string", arguments.inputString));

		return encodedString;
	</cfscript>
</cffunction>

<cffunction name="EncodeForHTMLCF10" output="false" returntype="string" hint="Encodes the input string for use in HTML attribute, returns Encoded string">
	<cfargument name="inputString" type="string" required="true" hint="Required. String to encode" />
	<cfargument name="strict" type="boolean" default="false" hint="Optional. If set to true, restricts multiple and mixed encoding" />

	<cfscript>
		var lc = StructNew();
		var encodedString = "";

		lc.encoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder();
		encodedString = lc.encoder.encodeForHTMLAttribute(JavaCast("string", arguments.inputString));

		return encodedString;
	</cfscript>
</cffunction>
