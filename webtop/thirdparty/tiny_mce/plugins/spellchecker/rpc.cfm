<!--- 
	@description ColdFusion port of rpc.php
	@author Richard Davies
 --->
<cfsetting showdebugoutput="false" enablecfoutputonly="true" />

<!--- Set RPC response headers --->
<cfheader name="Content-Type" value="text/plain; charset=UTF-8" />
<cfheader name="Expires" value="Mon, 26 Jul 1997 05:00:00 GMT" />
<cfheader name="Last-Modified" value="#GetHttpTimeString(Now())#" />
<cfheader name="Cache-Control" value="no-store, no-cache, must-revalidate" />
<cfheader name="Cache-Control" value="post-check=0, pre-check=0" />
<cfheader name="Pragma" value="no-cache" />


<cfset raw = "">

<!--- Try Form parameter --->
<cfif IsDefined("Form.json_data")>
	<cfset raw = Form.json_data />
</cfif>

<!--- Try raw HTTP post content --->
<cfif not Len(raw) and Len(GetHttpRequestData().content)>
	<cfset raw = ToString(GetHttpRequestData().content) />
</cfif>

<!--- No input data --->
<cfif not Len(raw)>
	<cfoutput>{"result":null,"id":null,"error":{"errstr":"Could not get raw post data.","errfile":"","errline":null,"errcontext":"","level":"FATAL"}}</cfoutput>
	<cfabort />
</cfif>


<!--- Get JSON data --->
<cfset json = CreateObject("component", "classes.utils.json") />
<cfset input = json.decode(raw) />

<!--- Execute RPC --->
<cfinclude template="config.cfm" />
<cfif StructKeyExists(config, "general.engine")>
	<!--- Build parameter list from parameter array --->
	<cfset paramList = "" />
	<cfloop index="i" from="1" to="#ArrayLen(input.params)#">
		<cfset paramList = paramList & "input.params[#i#]" />
		<cfif i lt ArrayLen(input.params)>
			<cfset paramList = paramList & ", " />
		</cfif>
	</cfloop>

	<!--- Dynamically invoke method and pass in parameters --->
	<cfset spellchecker = CreateObject("component", "classes." & config['general.engine']).init(config) />
	<cfset result = Evaluate("spellchecker." & input.method & "(#paramList#)") />
<cfelse>
	<cfoutput>{"result":null,"id":null,"error":{"errstr":"You must choose an spellchecker engine in the config.cfm file.","errfile":"","errline":null,"errcontext":"","level":"FATAL"}}</cfoutput>
	<cfabort />
</cfif>


<!--- Request and response id should always be the same --->
<cfset output = StructNew() />
<cfset output["id"] = input.id />
<cfset output["result"] = result />
<cfset output["error"] = "" />

<!--- Return JSON encoded string --->
<cfoutput>#json.encode(output)#</cfoutput>
