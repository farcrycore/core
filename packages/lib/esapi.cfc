<cfcomponent output="false">

	<cfset bHasBuiltinFunctions = false>
	<cfset bHasESAPI = false>

	<!--- test server verions --->
	<cfif isDefined("server.railo") AND listFirst(server.railo.version, ".") gte 4>
		<cfset bHasBuiltinFunctions = true>
	<cfelseif listFirst(server.coldfusion.productVersion) gte 10>
		<cfset bHasBuiltinFunctions = true>
	</cfif>

	<!--- test for esapi class --->
	<cftry>
		<cfset oESAPI = CreateObject("java", "org.owasp.esapi.ESAPI")>
		<cfset bHasESAPI = true>

		<cfcatch type="any">
		</cfcatch>
	</cftry>

	<!--- include esapi compatibility methods --->
	<cfif bHasESAPI AND NOT bHasBuiltinFunctions>
		<cfinclude template="esapi/esapi.cfm">
	</cfif>

	<!--- test for cf10 workarounds --->
	<cfif listFirst(server.coldfusion.productVersion) eq "10">
		<cfinclude template="esapi/esapiCF10.cfm">
	</cfif>


	<!--- missing method will be called when esapi compatibility methods have not been included --->
	<cffunction name="onMissingMethod" output="false">
		<cfargument name="missingMethodName" type="string">
		<cfargument name="missingMethodArguments" type="struct">

		<cfset var result = "">
		<cfset var arg1 = "">
		<cfset var arg2 = "">
		<cfset var countArgs = structCount(missingMethodArguments)>

		<cfif countArgs lt 1>
			<cfthrow message="No arguments passed to ESAPI method '#missingMethodName#'">
		</cfif>

		<cfset arg1 = missingMethodArguments[1]>
		<cfif structKeyExists(missingMethodArguments, "2")>
			<cfset arg2 = missingMethodArguments[2]>			
		</cfif>

		<cfif NOT listFindNoCase("EncodeForCSS,DecodeForHTML,EncodeForHTML,EncodeForHTMLAttribute,EncodeForJavaScript,DecodeFromURL,EncodeForURL,EncodeForXML", missingMethodName)>
			<cfthrow message="Unavailable ESAPI method '#missingMethodName#'">
		</cfif>

		<cfif bHasESAPI AND bHasBuiltinFunctions>
			<cfif listFindNoCase("encodeForHTML,encodeForHTMLAttribute", missingMethodName) AND listFirst(server.coldfusion.productVersion) eq 10>
				<cfset result = evaluate("#missingMethodName#CF10(arg1)")>
			<cfelse>
				<!--- call native function --->
				<cfswitch expression="#countArgs#">
					<cfcase value="1">
						<cfset result = evaluate("#missingMethodName#(arg1)")>
					</cfcase>
					<cfcase value="2">
						<cfset result = evaluate("#missingMethodName#(arg1,arg2)")>
					</cfcase>
					<cfdefaultcase>
						<cfthrow message="Unsupported number of arguments passed to ESAPI method '#missingMethodName#'">
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		<cfelse>
			<!--- fall back to older supported methods --->
			<cfswitch expression="#missingMethodName#">
				<cfcase value="encodeForURL">
					<cfset result = urlEncodedFormat(arg1)>
				</cfcase>
				<cfcase value="encodeForHTML,encodeForHTMLAttribute">
					<cfset result = htmlEditFormat(arg1)>
				</cfcase>
				<cfcase value="encodeForJavaScript">
					<cfset result = JSStringFormat(arg1)>
				</cfcase>
				<cfcase value="encodeForXML,encodeForXMLAttribute">
					<cfset result = xmlFormat(arg1)>
				</cfcase>
				<cfcase value="decodeFromURL">
					<cfset result = urlDecode(arg1)>
				</cfcase>
				<cfdefaultcase>
					<cfset result = arg1>
				</cfdefaultcase>
			</cfswitch>

		</cfif>

		<cfreturn result>
	</cffunction>


</cfcomponent>