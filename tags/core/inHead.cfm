<cfsetting enablecfoutputonly="true" />
<!--- @@description: returns the dynamic CSS and JS HTML, and onReady code, as an array --->

<cfparam name="attributes.variable" type="variablename" />

<cfif thistag.executionMode eq "Start">
	
	<cfimport taglib="/farcry/core/tags/core" prefix="core" />
	
	<cfset aResult = arraynew(1) />
	<cfset CRLF = chr(13) & chr(10) />

	<core:cssInHead r_html="aResult" />
	<core:jsInHead r_html="aResult" />
	
	<cfif structKeyExists(Request,"inHead") AND NOT structIsEmpty(Request.InHead)>		
		<!--- Check for each stPlaceInHead variable and output relevent html/css/js --->
		
		<!--- This is the result of any skin:htmlHead calls --->
		<cfparam name="request.inhead.stCustom" default="#structNew()#" />
		<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aCustomIDs)>
			<cfloop from="1" to="#arrayLen(request.inHead.aCustomIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stCustom, request.inHead.aCustomIDs[i])>
					<cfset st = structnew() />
					<cfset st["id"] = "inhead-#request.inHead.aCustomIDs[i]#" />
					<cfset st["html"] = chr(13) & '<meta id="inhead-#request.inHead.aCustomIDs[i]#" property="inheadid" content="#request.inHead.aCustomIDs[i]#">' & request.inHead.stCustom[request.inHead.aCustomIDs[i]]>
					<cfset arrayappend(aResult,st) />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- This is the result of any skin:onReady calls --->
		<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
		<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" />
		
		<cfif arrayLen(request.inhead.aOnReadyIDs)>
			<cfset st = structnew() />
			<cfset st["id"] = "onready" />
			<cfset st["html"] = "" />
			
			<cfloop from="1" to="#arrayLen(request.inHead.aOnReadyIDs)#" index="i">
				<cfif structKeyExists(request.inHead.stOnReady, request.inHead.aOnReadyIDs[i])>
					<cfset st.html = st.html & request.inHead.stOnReady[request.inHead.aOnReadyIDs[i]] />
				</cfif>
			</cfloop>
			
			<cfset arrayappend(aResult,st) />
		</cfif>
	</cfif>

	<cfif arrayLen(aResult)>
		<cfset st = structnew() />
		<cfset st["id"] = "CRLF" />
		<cfset st["html"] = CRLF />
		<cfset arrayappend(aResult,st) />
	</cfif>
	
	<cfset caller[attributes.variable] = aResult />
	
</cfif>

<cfsetting enablecfoutputonly="false" />