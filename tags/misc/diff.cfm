<cfsetting enablecfoutputonly="true" />
<!--- @@description: Loops over differences between one string (or array) and 
another. If strings are passed in they are stripped of HTML tags and compared 
word by word. After the tags has finished executing, the complete array of diffs
is returned. --->

<cfif not thistag.HasEndTag>
	<cfthrow message="diff must have an end tag" />
</cfif>

<cfif thistag.ExecutionMode eq "start">
	<cfparam name="attributes.old" /><!--- The old value. This should be a string (will be stripped of HTML tags and compared by word) --->
	<cfparam name="attributes.new" /><!--- The new value. This should be in the same format as old. --->
	<cfparam name="attributes.diff" default="diff" /><!--- The variable that the result is stored in. During execution this variable contains individual diff structs: { diff="+|-|=", oldindex, oldvalue, newindex, newvalue }. After execution this variable contains an array of all diffs. Defaults to "diff" --->
	
	<cfset thistag.aDiff = application.fc.lib.diff.getDiff(attributes.old,attributes.new) />
	
	<cfif arraylen(thistag.aDiff)>
		<cfset thistag.index = 1 />
		<cfset thistag.count = arraylen(thistag.aDiff) />
		
		<cfset caller[attributes.diff] = thistag.aDiff[thistag.index] />
	<cfelse>
		<cfset caller[attributes.diff] = thistag.aDiff />
		
		<cfexit method="exittag" />
	</cfif>
</cfif>

<cfif thistag.ExecutionMode eq "end">
	<cfif thistag.index lt thistag.count>
		<cfset thistag.index = thistag.index + 1 />
		<cfset caller[attributes.diff] = thistag.aDiff[thistag.index] />
		
		<cfexit method="loop" />
	</cfif>
	
	<cfset caller[attributes.diff] = thistag.aDiff />
</cfif>

<cfsetting enablecfoutputonly="false" />