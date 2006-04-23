<cfsetting enablecfoutputonly="Yes">

<cfswitch expression="#ThisTag.ExecutionMode#">

	<cfcase value="Start">
		<!--- Initialise variables --->
	</cfcase>

	<cfcase value="End">
		<!--- Generate tabs --->
		<cfloop from="1" to="#ArrayLen(ThisTag.tabs)#" index="i">
			<cfoutput><a href="#thistag.tabs[i].href#" class="#thistag.tabs[i].class#" target="#thistag.tabs[i].target#" <cfif thistag.tabs[i].onclick neq "">onClick="#thistag.tabs[i].onclick#"</cfif> <cfif thistag.tabs[i].id neq "">id="#thistag.tabs[i].id#"</cfif> <cfif thistag.tabs[i].style neq "">style="#thistag.tabs[i].style#"</cfif>>#thistag.tabs[i].text#</a></cfoutput>
		</cfloop>	
	</cfcase>

</cfswitch>

<cfsetting enablecfoutputonly="No">