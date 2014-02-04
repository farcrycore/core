<cfsetting enablecfoutputonly="true"><cfsilent>
<!--- @@displayname: Resource --->
<!--- @@description: Retrieves the specified resource --->

<cfparam name="attributes.key" /><!--- The resource bundle key. Should be in the form of section.area.item@attribute. --->
<cfparam name="attributes.variables" default="" /><!--- Items replace corresponding {n} placeholders in the translation. Can be a single simple value or an array of simple values. --->

<cfif thistag.ExecutionMode eq "end">
	<cfif not isarray(attributes.variables)>
		<cfset tmp = arraynew(1) />
		<cfset tmp[1] = attributes.variables />
		<cfset attributes.variables = tmp />
	</cfif>
	
	<cfloop collection="#attributes#" item="thisattr">
		<cfif refindnocase("var\d+",thisattr)>
			<cfset attributes.variables[mid(thisattr,4,len(thisattr))] = attributes[thisattr] />
		</cfif>
	</cfloop>
	
	<cfif arraylen(attributes.variables)>
		<cfset thistag.GeneratedContent = application.fapi.getResource(attributes.key,trim(thistag.GeneratedContent),attributes.variables) />
	<cfelse>
		<cfset thistag.GeneratedContent = application.fapi.getResource(attributes.key,trim(thistag.GeneratedContent)) />
	</cfif>
</cfif>

</cfsilent><cfsetting enablecfoutputonly="false">