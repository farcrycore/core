<cfsetting enablecfoutputonly="true">

<cfset stWindow = nextRunningWindow(stCron=stObj) />

<cfif structIsEmpty(stWindow)>
    <cfoutput>N/A</cfoutput>
<cfelse>
    <cfoutput>#dateFormat(stWindow.start, 'd mmm yyyy')# #timeFormat(stWindow.start, 'h:mm tt')#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">