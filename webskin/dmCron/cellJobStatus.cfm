<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Job Status Cell --->

<cfif stObj.datetimeLastExecuted gt stObj.datetimeLastFinished and dateAdd("s", stObj.timeout, stObj.datetimeLastExecuted) gt now()>
	<cfoutput><i class="fa fa-play" style="color: orange;"></i> Started #application.fapi.prettyDate(stObj.datetimeLastExecuted)#</cfoutput>	
<cfelseif not stobj.bAutoStart>
	<cfif stobj.enddate lt now()>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;" title="Ended #application.fapi.prettyDate(stobj.enddate)#"></i> Disabled</cfoutput>
	<cfelseif stobj.startdate gt now()>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;" title="Starts #application.fapi.prettyDate(stobj.startdate)#"></i> Disabled</cfoutput>
	<cfelse>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;"></i> Disabled</cfoutput>
	</cfif>
<cfelseif stobj.startdate gt now()>
	<cfoutput><i class="fa fa-clock-o" style="color: orange;"></i> Starts #application.fapi.prettyDate(stobj.startdate)#</cfoutput>		
<cfelseif stobj.enddate lt now()>
	<cfoutput><i class="fa fa-clock-o" style="color: ##999;"></i> Ended #application.fapi.prettyDate(stobj.enddate)#</cfoutput>		
<cfelseif checkJobStatus(stobj.objectid)>
	<cfif shouldAutoFire(stobj)>
		<cfoutput><i class="fa fa-check-square-o" style="color: green;"></i> Active</cfoutput>
	<cfelse>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;"></i> Disabled</cfoutput>
	</cfif>
<cfelse>
	<cfif shouldAutoFire(stobj)>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: ##c00;" title="This task is enabled and due to run but is not registered on this server - scheduler registration likely failed or the job was dropped. Check the logs to confirm."></i> Not registered</cfoutput>
	<cfelse>
		<cfoutput><i class="fa fa-exclamation-triangle" style="color: orange;"></i> Disabled</cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">