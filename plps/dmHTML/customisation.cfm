<cfsetting enablecfoutputonly="Yes">

<cfa_PLPHandler>	

<cf_PLPNavigationMove>	

<cfif NOT thisstep.isComplete>


	<cfa_controlhandler name="editform">	
	<cfoutput>

	<span class="FormTitle">Page customisation</span>
	
	<cfif fileexists( "#application.rootphy#/plps/daemon_html/customisation#output.displayMethod#.cfm" )>
		<cfinclude template="customisation#output.displayMethod#.cfm">
	
	<cfelse>
		<span class="FormLabel">There are no customisations for display method '#output.displayMethod#'</span><br>
	
	</cfif>
	
	<cf_PLPNavigationButtons>
	
	</cfoutput>
	
	</cfa_controlhandler>
	
	

	

<cfelse>
	<cfloop index="fieldname" list="#form.FIELDNAMES#">
		<cfif left(fieldname,7) eq "option_">
			<cfif form[fieldname] eq "0,1"><cfset form[fieldname]="1"></cfif>
		</cfif>
	</cfloop>
	
	<cf_UpdateOutput>
</cfif>


</cfa_PLPHandler>
<cfsetting enablecfoutputonly="No">