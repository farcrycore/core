<!--- <cfa_dump var="#CALLER.FORM.Fieldnames#"><cfabort> --->
	<cfloop index="FormItem" list="#CALLER.FORM.FieldNames#">
		<cfif StructKeyExists(CALLER.output,FormItem)>
			<cfset "CALLER.output.#FormItem#" = Evaluate("CALLER.FORM.#FormItem#")>
		</cfif>
	</cfloop>