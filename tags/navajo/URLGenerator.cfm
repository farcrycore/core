<cfprocessingDirective pageencoding="utf-8">
<cfsilent> 

<!--- URLGenerator
BY: Aaron Shurmer, Daemon. q1, 2001.

Usage:
	<cf_URLGenerator
		r_var="variablename" : optional, the tag will return the generated url into r_var.
		variable list="values" : optional list of variables sent to the generator, these will be converted to the url.
								If you send it a structure, it will go 1 deep into the structure and pull out the values from within.
								


 --->

<cfif isdefined("attributes.r_var")>
	<cfset r_var = attributes.r_var>
	<cfset StructDelete(attributes, "r_var")>
</cfif>

<cfset vars = structkeylist(Attributes)>
<cfloop index="i" list="#vars#">
	<cfif isstruct(evaluate("attributes.#i#"))>
		<cfset tempst = evaluate("attributes.#i#")>
		<cfloop index="j" list="#structkeylist(tempst)#">
			<cfset setvariable("attributes.#j#", evaluate("tempst.#j#"))>
		</cfloop>
		<cfset StructDelete(attributes, "#i#")>
	</cfif>
</cfloop>
<cfset vars = structkeylist(Attributes)>
</cfsilent><cfif isdefined("r_var")><cfsilent>
<cfset temp="?">
	<cfloop index="i" list="#vars#">
		<cfif len(trim(temp)) gt 1>
			<cfset temp = temp & "&">				
		</cfif>
		<cfset temp = temp & "#i#=#evaluate("attributes.#i#")#">
	</cfloop>
	<cfset setvariable("caller.#r_var#", temp)>
</cfsilent><cfelse><Cfset go=false><cfoutput>?</cfoutput><cfloop index="i" list="#vars#"><cfoutput><cfif go eq true>&<cfelse><cfset go=true></cfif>#i#=#evaluate("attributes.#i#")#</cfoutput></cfloop></cfif><cfsilent>
<!--- 

<cfif isdefined("attributes.r_var")>
	<cfset r_var = attributes.r_var>
	<cfset StructDelete(attributes, "r_var")>
</cfif>

<cfset vars = structkeylist(Attributes)>
<cfloop index="i" list="#vars#">
	<cfif isstruct(evaluate("attributes.#i#"))>
		<cfset tempst = evaluate("attributes.#i#")>
		<cfloop index="j" list="#structkeylist(tempst)#">
			<cfset setvariable("attributes.#j#", evaluate("tempst.#j#"))>
		</cfloop>
		<cfset StructDelete(attributes, "#i#")>
	</cfif>
</cfloop>
<cfset vars = structkeylist(Attributes)>
</cfsilent>
<cfif isdefined("r_var")>
	<cfset temp="">
	<cfloop index="i" list="#vars#">
		<cfset temp = temp & "/#i#/#evaluate("attributes.#i#")#|">
	</cfloop>
	<cfset setvariable("caller.#r_var#", temp)>
<cfelse><cfloop index="i" list="#vars#"><cfoutput>/#i#/#evaluate("attributes.#i#")#|</cfoutput></cfloop></cfif> ---></cfsilent>