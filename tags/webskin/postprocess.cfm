<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Post Processing --->
<!--- @@description: 
	This tag will run the specified post-processing functions on the input
 --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->

<!--- <cfparam name="attributes.input" default="" /> --->
<cfparam name="attributes.functions" />

<cfif thistag.executionMode eq "Start" and not thistag.HasEndTag>
	<cfif not structkeyexists(arguments,"input")>
		<cfthrow message="This tag requires either an input attribute or an end tag" />
	</cfif>
	
	<cfoutput>#application.fc.lib.postprocess.apply(attributes.input,attributes.functions)#</cfoutput>
</cfif>

<cfif thistag.executionMode eq "End">
	<cfset attributes.input = thistag.GeneratedContent />
	<cfset thistag.GeneratedContent = "" />
	<cfoutput>#application.fc.lib.postprocess.apply(attributes.input,attributes.functions)#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">