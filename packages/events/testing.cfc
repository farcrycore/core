<cfcomponent displayname="Testing" hint="For testing events functionality" output="false">
	
	<cffunction name="sleep" access="public" output="false" returntype="void">
		<cfargument name="taskID" type="string" required="true" />
		<cfargument name="jobID" type="string" required="true" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="ownedBy" type="string" required="true" />
		<cfargument name="details" type="any" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset stResult.start = now() />
		
		<cfset CreateObject("java", "java.lang.Thread").sleep(arguments.details * 1000) />
		
		<cfset stResult.end = now() />
		
		<cfset application.fc.lib.tasks.addResult(taskID=arguments.taskID,jobType="Sleep",jobID=arguments.jobID,ownedBy=arguments.ownedBy,result=stResult) />
	</cffunction>
	
	
</cfcomponent>