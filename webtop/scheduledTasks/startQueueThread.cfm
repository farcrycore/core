<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Process queue tasks --->

<cfset application.fc.lib.tasks.clearProcessingThreads() />

<cfif application.fc.lib.tasks.getTaskCount() gt application.fc.lib.tasks.getThreadCount()>
	<cfset application.fc.lib.tasks.startProcessingThread() />
</cfif>

<cfsetting enablecfoutputonly="true">