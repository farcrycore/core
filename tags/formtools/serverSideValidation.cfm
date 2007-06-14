<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<cfif thistag.ExecutionMode EQ "Start">


	<cfif structKeyExists(form, "FARCRYFORMPREFIXES")>
		<cfloop list="#form.FARCRYFORMPREFIXES#" index="prefix">
			<cfif structKeyExists(form, "#prefix#objectid")>
				<ft:validateFormObjects objectid="#ListGetAt(form['#prefix#objectid'],1)#" />
			</cfif>
		</cfloop>
				
	</cfif>

</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="no">

