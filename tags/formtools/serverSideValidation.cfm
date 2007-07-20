<cfsetting enablecfoutputonly="true" />

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />


<cfif thistag.ExecutionMode EQ "Start">

	<!--- optional attributes --->
	<cfparam name="attributes.lrequiredfields" default="" type="string" />


	<cfif structKeyExists(form, "FARCRYFORMPREFIXES") AND structKeyExists(form, "farcryFormValidation") AND form.farcryFormValidation>
		<cfloop list="#form.FARCRYFORMPREFIXES#" index="prefix">
			<cfif structKeyExists(form, "#prefix#objectid")>
				
				<cfif listlen(attributes.lrequiredfields)>
					<cfloop list="#attributes.lrequiredfields#" index="field">
						<cfif NOT structKeyExists(form, "#prefix##field#")>
							<cfthrow message="<b>Server-side validation</b> Required form fields missing; #attributes.lrequiredfields#." />
						</cfif>
					</cfloop>
				</cfif>
				
				<ft:validateFormObjects objectid="#ListGetAt(form['#prefix#objectid'],1)#" />
			
			</cfif>
		</cfloop>
	</cfif>

</cfif>

<cfif thistag.ExecutionMode EQ "End">
	<!--- Do Nothing --->
</cfif>


<cfsetting enablecfoutputonly="false" />

