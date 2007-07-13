<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

 


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>



	<!--- Check to make sure that Request.farcryForm.Name exists. This is because other tags may have created Request.farcryForm but only this tag creates "Name" --->
	<cfif thistag.ExecutionMode EQ "Start">
		<cfoutput><div class="farcryButtonPanel"></cfoutput>
	</cfif>
	
	<cfif thistag.ExecutionMode EQ "End">

		<cfoutput><br style="height:0px;clear:both;" /></div></cfoutput>
	
	</cfif>


