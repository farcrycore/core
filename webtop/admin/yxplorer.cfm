<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.var" default="application" />

<admin:header>

<skin:htmlHead><cfoutput><style type="text/css">
	a.breadcrumb { font-weight:bold; }
	table.keys { width:100%; }
		table.keys td { padding:3px; }
</style></cfoutput></skin:htmlHead>

<cfoutput>
	<h1>Scope Explorer</h1>
	<p>
</cfoutput>

<cfset selectedvar = 0 />
<cfset selectedtype = "N/A" />
<cfset varsofar = "" />
<cfloop list="#url.var#" index="i" delimiters=".">
	<cfset varsofar = listappend(varsofar,i,".") />
	
	<cfif issimplevalue(selectedvar) and selectedvar eq 0 and listfindnocase("application,request,session",i)>
		<cfswitch expression="#i#">
			<cfcase value="application">
				<cfset selectedvar = application />
			</cfcase>
			<cfcase value="session">
				<cfset selectedvar = session />
			</cfcase>
			<cfcase value="request">
				<cfset selectedvar = request />
			</cfcase>
		</cfswitch>
	<cfelseif isarray(selectedvar)>
		<cfset selectedvar = selectedvar[i] />
	<cfelseif isstruct(selectedvar)>
		<cfset selectedvar = selectedvar[i] />
	<cfelse>
		<cfset selectedvar = "#varsofar# is not valid" />
	</cfif>
	
	<cfif listfindnocase("application,request,session",i)>
		<cfset selectedtype = "SCOPE" />
	<cfelseif isarray(selectedvar)>
		<cfset selectedtype = "ARRAY" />
	<cfelseif isstruct(selectedvar)>
		<cfset selectedtype = "STRUCT" />
	<cfelseif isquery(selectedvar)>
		<cfset selectedtype = "QUERY" />
	<cfelseif isnumeric(selectedvar)>
		<cfset selectedtype = "NUMERIC" />
	<cfelseif lsisdate(selectedvar)>
		<cfset selectedtype = "DATETIME" />
	<cfelse>
		<cfset selectedtype = "STRING" />
	</cfif>
	
	<cfoutput><a class="breadcrumb" href="#application.fapi.fixURL(addvalues="var=#varsofar#")#">#i#</a> #selectedtype# &gt; </cfoutput>
</cfloop>

<cfoutput></p><br></cfoutput>

<cfswitch expression="#selectedtype#">
	<cfcase value="ARRAY">
		<cfif arraylen(selectedvar)>
			<cfset colcount = 10 />
			<cfset rowcount = ceiling(arraylen(selectedvar) / colcount) />
			
			<cfoutput><table class="keys"></cfoutput>
			<cfloop from="1" to="#rowcount * colcount#" index="i">
				<cfset x = (i-1) % colcount + 1 />
				<cfset y = i \ colcount + 1 />
				<cfset ind = y + (x - 1) * rowcount />
				
				<cfif i % colcount eq 1>
					<cfoutput><tr></cfoutput>
				</cfif>
				
				<cfif ind lte arraylen(selectedvar)>
					<cfoutput><td><a href="#application.fapi.fixURL(addvalues="var=#varsofar#.#ind#")#">#ind#</a></td></cfoutput>
				<cfelse>
					<cfoutput><td>&nbsp;</td></cfoutput>
				</cfif>
				
				<cfif i % colcount eq 0>
					<cfoutput></tr></cfoutput>
				</cfif>
			</cfloop>
			<cfoutput></table></cfoutput>
		<cfelse>
			<cfoutput>Array contains no values</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="SCOPE,STRUCT" delimiters=",">
		<cfset keys = listtoarray(listsort(lcase(structkeylist(selectedvar)),"text")) />
		
		<cfif arraylen(keys)>
			<cfset colcount = 5 />
			<cfset rowcount = ceiling(arraylen(keys) / colcount) />
			
			<cfoutput><table class="keys"></cfoutput>
			<cfloop from="1" to="#rowcount * colcount#" index="i">
				<cfset x = (i-1) % colcount + 1 />
				<cfset y = i \ colcount + 1 />
				<cfset ind = y + (x - 1) * rowcount />
				
				<cfif i % colcount eq 1>
					<cfoutput><tr></cfoutput>
				</cfif>
				
				<cfif ind lte arraylen(keys)>
					<cfoutput><td><a href="#application.fapi.fixURL(addvalues="var=#varsofar#.#keys[ind]#")#">#keys[ind]#</a></td></cfoutput>
				<cfelse>
					<cfoutput><td>&nbsp;</td></cfoutput>
				</cfif>
				
				<cfif i % colcount eq 0>
					<cfoutput></tr></cfoutput>
				</cfif>
			</cfloop>
			<cfoutput></table></cfoutput>
		<cfelse>
			<cfoutput>Struct contains no values</cfoutput>
		</cfif>
	</cfcase>
	
	<cfdefaultcase>

		<cfdump var="#selectedvar#" depth="1" />
	
	</cfdefaultcase>
</cfswitch>

<admin:footer />

<cfsetting enablecfoutputonly="false" />