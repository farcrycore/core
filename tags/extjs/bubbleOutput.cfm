<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Manual output of bubble messages --->

<cfif not thistag.HasEndTag>
	<cfthrow message="The bubbleOutput tag must have an end element" />
</cfif>


<cfparam name="attributes.index" default="index" /><!--- Index of each message variable --->
<cfparam name="attributes.bubble" default="bubble" /><!--- Bubble data struct variable --->


<cfif thistag.ExecutionMode eq "start">
	<cfif structKeyExists(session, "aExtMessages") AND arrayLen(session.aExtMessages)>
		<cfset thistag.index = 1 />
		<cfset thistag.length = arraylen(session.aExtMessages) />
		
		<cfset caller[attributes.index] = thistag.index />
		<cfset caller[attributes.bubble] = session.aExtMessages[thistag.index] />
	<cfelse>
		<cfexit method="exittag">
	</cfif>		
</cfif>


<cfif thistag.ExecutionMode eq "end">
	<cfif thistag.index lt thistag.length>
		<cfset thistag.index = thistag.index + 1 />
		
		<cfset caller[attributes.index] = thistag.index />
		<cfset caller[attributes.bubble] = session.aExtMessages[thistag.index] />
		
		<cfexit method="loop" />
	</cfif>
	
	<cfset structdelete(session,"aExtMessages") />
</cfif>


<cfsetting enablecfoutputonly="false" />