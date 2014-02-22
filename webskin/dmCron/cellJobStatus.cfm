<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Job Status Cell --->

<cfif stobj.startdate gt now()>
	<cfoutput><i class="fa fa-clock-o" style="color: orange;"></i> Starts #application.fapi.prettyDate(stobj.startdate)#</cfoutput>		
<cfelseif stobj.enddate lt now()>
	<cfoutput><i class="fa fa-clock-o" style="color: red;"></i> Ended #application.fapi.prettyDate(stobj.startdate)#</cfoutput>		
<cfelseif checkJobStatus(stobj.objectid)>
	<cfoutput><i class="fa fa-check-square-o" style="color: green;"></i> Active</cfoutput>	
<cfelse>
	<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;"></i> Disabled</cfoutput>	
</cfif>

<cfsetting enablecfoutputonly="false">