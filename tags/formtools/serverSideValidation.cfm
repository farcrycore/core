<cfsetting enablecfoutputonly="true" />

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />


<cfif thistag.ExecutionMode EQ "Start">

	<!--- optional attributes --->
	<cfparam name="attributes.lrequiredfields" default="" type="string" />

	<!--- If required fields, check they have been passed. --->
	<cfif structKeyExists(form, "FARCRYFORMPREFIXES") AND listlen(attributes.lrequiredfields)>
		<cfloop list="#form.FARCRYFORMPREFIXES#" index="prefix">			
			<!--- test for required fields; ie. must be part of the actual form post (can be used to block scripted posting) --->
			<cfloop list="#attributes.lrequiredfields#" index="field">
				<cfif NOT structKeyExists(form, "#prefix##field#")>
					<cfthrow message="<b>Server-side validation</b> Required form fields missing; #attributes.lrequiredfields#." />
				</cfif>
			</cfloop>
		</cfloop>
	</cfif>
			
			
	<cfif structKeyExists(form, "FARCRYFORMPREFIXES")>
		<cfloop list="#form.FARCRYFORMPREFIXES#" index="prefix">
			
			<cfif structKeyExists(form, "#prefix#objectid")>
				<ft:validateFormObjects typename="#ListGetAt(form['#prefix#typename'],1)#" objectid="#ListGetAt(form['#prefix#objectid'],1)#" />
			
			</cfif>
		</cfloop>
	</cfif>

</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="false" />

