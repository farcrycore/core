<cfcomponent displayname="Tasks" hint="Library for asynchronous task processing" output="false" persistent="false">
	
	<cffunction name="init" returntype="any">
		
		<cfset this.threads = structnew() />
		
		<cfreturn this />
	</cffunction>
	
	
	<!--- Public functions --->
	<cffunction name="addTask" output="false" access="public" returntype="void" description="Adds a task to the processing queue.">
		<cfargument name="taskID" type="string" required="false" default="#application.fapi.getUUID()#" />
		<cfargument name="jobType" type="string" required="false" />
		<cfargument name="jobID" type="string" required="false" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="details" type="any" required="true" />
		<cfargument name="ownedBy" type="string" required="false" />
		<cfargument name="stacktrace" type="array" required="false" default="#arraynew(1)#" />
		
		<cfset var stTask = structnew() />
		<cfset var aStack = application.fc.lib.error.getStack(bIncludeJava=false,ignoreLines=1) />
		<cfset var i = 0 />
		<cfset var stResult	= '' />
		
		<!--- store an ongoing stack trace for the task --->
		<cfif structkeyexists(request,"inthread") and isdefined("thread.task")>
			<cfif not structkeyexists(arguments,"jobType")>
				<cfset arguments.jobType = thread.task.jobType />
			</cfif>
			<cfif not structkeyexists(arguments,"jobID")>
				<cfset arguments.jobID = thread.task.jobID />
			</cfif>
			<cfif not structkeyexists(arguments,"ownedBy")>
				<cfset arguments.ownedBy = thread.task.taskOwnedBy />
			</cfif>
			
			<cfif not arraylen(arguments.stacktrace)>
				<cfwddx action="wddx2cfml" input="#thread.task.wddxStacktrace#" output="arguments.stacktrace" />
			</cfif>
			
			<cfloop from="#arraylen(aStack)-3#" to="1" index="i" step="-1">
				<cfset arrayprepend(arguments.stacktrace,aStack[i]) />
			</cfloop>
		<cfelse>
			<cfif not structkeyexists(arguments,"jobType")>
				<cfset arguments.jobType = "Unknown" />
			</cfif>
			<cfif not structkeyexists(arguments,"jobID")>
				<cfset arguments.jobID = arguments.taskID />
			</cfif>
			<cfif not structkeyexists(arguments,"ownedBy")>
				<cfset arguments.ownedBy = application.security.getCurrentUserID() />
			</cfif>
			
			<cfloop from="#arraylen(aStack)#" to="1" index="i" step="-1">
				<cfset arrayprepend(arguments.stacktrace,aStack[i]) />
			</cfloop>
		</cfif>
		<cfset arrayprepend(arguments.stacktrace,structnew()) />
		<cfset arguments.stacktrace[1]["line"] = 0 />
		<cfset arguments.stacktrace[1]["location"] = "taskqueue" />
		<cfset arguments.stacktrace[1]["template"] = "..." />
		
		<cfset stTask.objectid = arguments.taskID />
		<cfset stTask.typename = "farQueueTask" />
		<cfset stTask.label = "" />
		<cfset stTask.datetimeCreated = now() />
		<cfset stTask.createdBy = arguments.ownedBy />
		<cfset stTask.ownedBy = arguments.ownedBy />
		<cfset stTask.datetimeLastUpdated = now() />
		<cfset stTask.lastUpdatedBy = arguments.ownedBy />
		<cfset stTask.lockedBy = "" />
		<cfset stTask.locked = false />
		<cfset stTask.jobType = arguments.jobType />
		<cfset stTask.jobID = arguments.jobID />
		<cfset stTask.action = arguments.action />
		<cfset stTask.taskOwnedBy = application.security.getCurrentUserID() />
		<cfset stTask.taskStatus = "queued" />
		<cfset stTask.taskTimestamp = now() />
		<cfwddx action="cfml2wddx" input="#arguments.details#" output="stTask.wddxDetails" />
		<cfwddx action="cfml2wddx" input="#arguments.stacktrace#" output="stTask.wddxStackTrace" />
		
		<cflock name="task-queue-update" timeout="5" throwontimeout="true">
			<cfset stResult=application.fc.lib.db.createData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,stProperties=stTask) />
			
			<cflog file="#application.applicationname#_tasks" text="added task #arguments.action# [#arguments.taskID#] owned by #arguments.ownedBy#" />
		</cflock>
		
		<cfif not isdefined("thread")>
			<cfset clearProcessingThreads() />
			<cfset startProcessingThread() />
		</cfif>
	</cffunction>
	
	<cffunction name="requeueTask" output="false" access="public" returntype="void" description="Requeues a task">
		<cfargument name="taskID" type="string" required="true" />
		
		<cfset var stTask = "" />
		
		<cflock name="task-queue-update" timeout="5" throwontimeout="true">
			<cfset stTask = application.fc.lib.db.getData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,objectid=arguments.taskID) />
			
			<cfif structkeyexists(stTask,"objectid")>
				<cfset stTask.taskStatus = "queued" />
				<cfset stTask.taskTimestamp = now() />
				<cfset stTask.threadID = "" />
				<cfset application.fc.lib.db.setData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,stProperties=stTask) />
				<cflog file="#application.applicationname#_tasks" text="requeued task #stTask.action# [#stTask.objectid#] owned by #stTask.taskOwnedBy#" />
			</cfif>
		</cflock>
		
		<cfset clearProcessingThreads() />
		<cfset startProcessingThread() />
	</cffunction>
	
	<cffunction name="removeTask" output="false" access="public" returntype="void" description="Removes a task from the processing queue, and returns it's details">
		<cfargument name="taskID" type="string" required="true" />
		
		<cflock name="task-queue-update" timeout="5" throwontimeout="true">
			<cfset application.fc.lib.db.deleteData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,objectid=arguments.taskID) />
			<cflog file="#application.applicationname#_tasks" text="removed task [#arguments.taskID#]" />
		</cflock>
		
		<cfset clearProcessingThreads() />
	</cffunction>
	
	
	<cffunction name="getTaskCount" output="false" access="public" returntype="numeric" description="Returns the number of tasks remaining for the given criteria">
		<cfargument name="taskID" type="string" requried="false" />
		<cfargument name="jobID" type="string" required="false" />
		<cfargument name="ownedBy" type="string" required="false" />
		
		<cfset var q = "" />
		
		<cfquery datasource="#application.dsn#" name="q">
			select		count(objectid) as total
			from		#application.dbowner#farQueueTask
			where		1=1
						<cfif structkeyexists(arguments,"taskID")>
							and taskID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.taskID#" />
						</cfif>
						<cfif structkeyexists(arguments,"jobID")>
							and jobID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobID#" />
						</cfif>
						<cfif structkeyexists(arguments,"ownedBy")>
							and ownedBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ownedBy#" />
						</cfif>
		</cfquery>
		
		<cfreturn q.total />
	</cffunction>
	
	
	<cffunction name="addResult" output="false" access="public" returntype="void" description="Adds a task result to the application">
		<cfargument name="taskID" type="string" required="false" />
		<cfargument name="jobType" type="string" required="false" />
		<cfargument name="jobID" type="string" required="false" />
		<cfargument name="ownedBy" type="string" reqquired="false" />
		<cfargument name="result" type="struct" required="true" />
		
		<cfset var stResult = structnew() />
		
		<cfset clearTaskResults() />
		
		<cfif structkeyexists(request,"inthread") and isdefined("thread.task")>
			<cfif not structkeyexists(arguments,"taskID")>
				<cfset arguments.taskID = thread.task.objectid />
			</cfif>
			<cfif not structkeyexists(arguments,"jobType")>
				<cfset arguments.jobType = thread.task.jobType />
			</cfif>
			<cfif not structkeyexists(arguments,"jobID")>
				<cfset arguments.jobID = thread.task.jobID />
			</cfif>
			<cfif not structkeyexists(arguments,"ownedBy")>
				<cfset arguments.ownedBy = thread.task.taskOwnedBy />
			</cfif>
		<cfelse>
			<cfparam name="arguments.taskID" />
			<cfparam name="arguments.jobType" />
			<cfparam name="arguments.jobID" />
			<cfparam name="arguments.ownedBy" />
		</cfif>
		
		<cfset stResult.objectid = application.fapi.getUUID() />
		<cfset stResult.typename = "farQueueResult" />
		<cfset stResult.label = "" />
		<cfset stResult.datetimeCreated = now() />
		<cfset stResult.createdBy = arguments.ownedBy />
		<cfset stResult.ownedBy = arguments.ownedBy />
		<cfset stResult.datetimeLastUpdated = now() />
		<cfset stResult.lastUpdatedBy = arguments.ownedBy />
		<cfset stResult.lockedBy = "" />
		<cfset stResult.locked = false />
		<cfset stResult.taskID = arguments.taskID />
		<cfset stResult.jobType = arguments.jobType />
		<cfset stResult.jobID = arguments.jobID />
		<cfset stResult.taskOwnedBy = arguments.ownedBy />
		<cfset stResult.resultTimestamp = now() />
		<cfset stResult.resultTick = getTickCount() />
		<cfwddx action="cfml2wddx" input="#arguments.result#" output="stResult.wddxResult" />
		
		<cflock name="result-queue-update" timeout="5" throwontimeout="true">
			<cfset application.fc.lib.db.createData(typename=application.stCOAPI.farQueueResult.packagepath,dsn=application.dsn,stProperties=stResult) />
			<cflog file="#application.applicationname#_tasks" text="added result for task [#arguments.taskID#] owned by #arguments.ownedBy#" />
		</cflock>
	</cffunction>
	
	<cffunction name="getResults" output="false" access="public" returntype="array" description="Removes and returns matching results">
		<cfargument name="taskID" type="string" requried="false" />
		<cfargument name="jobID" type="string" required="false" />
		<cfargument name="ownedBy" type="string" required="false" />
		<cfargument name="previousTick" type="numeric" required="false" />
		<cfargument name="clearResults" type="boolean" required="false" default="true" />
		
		<cfset var q = "" />
		<cfset var st = structnew() />
		<cfset var aResult = arraynew(1) />
		
		<cfset st.typename = "farQueueResult" />
		<cfset st.lProperties = "objectid,taskID,jobID,resultTimestamp,resultTick,wddxResult,taskOwnedBy as ownedBy" />
		<cfset st.orderby = "resultTick asc" />
		
		<cfif structkeyexists(arguments,"taskID")>
			<cfset st.taskID_eq = arguments.taskID />
		</cfif>
		
		<cfif structkeyexists(arguments,"jobID")>
			<cfset st.jobID_eq = arguments.jobID />
		</cfif>
		
		<cfif structkeyexists(arguments,"ownedBy")>
			<cfset st.taskOwnedBy_eq = arguments.ownedBy />
		</cfif>
		
		<cfif structkeyexists(arguments,"previousTick")>
			<cfset st.resultTick_gt = arguments.previousTick />
		</cfif>
		
		<cfif arguments.clearResults>
			<cfset clearTaskResults() />
		</cfif>
		
		<cflock name="result-queue-update" timeout="5" throwontimeout="true">
			<cfset q = application.fapi.getContentObjects(argumentCollection=st) />
			
			<!--- remove results being reported from db --->
			<cfloop query="q">
				<cfset st = structnew() />
				<cfset st["taskID"] = q.taskID />
				<cfset st["jobID"] = q.jobID />
				<cfset st["timestamp"] = q.resultTimestamp />
				<cfset st["tick"] = q.resultTick />
				<cfset st["result"] = "" />
				<cfset st["ownedBy"] = q.ownedBy />
				<cfwddx action="wddx2cfml" input="#q.wddxResult#" output="st.result" />
				<cfset arrayappend(aResult,st) />
				
				<cfif arguments.clearResults>
					<cfset application.fc.lib.db.deleteData(typename=application.stCOAPI.farQueueResult.packagepath,dsn=application.dsn,objectid=q.objectid) />
					<cflog file="#application.applicationname#_tasks" text="removed reported result [#q.objectid#] owned by #q.ownedBy#" />
				</cfif>
			</cfloop>
		</cflock>
		
		<cfreturn aResult />
	</cffunction>
	
	<cffunction name="getJobs" output="false" access="public" returntype="query" description="Returns all jobs that have results logged">
		<cfset var q = "" />
		<cfset var st = structnew() />
		<cfset var k = "" />
		
		<cflock name="result-queue-update" timeout="5" throwontimeout="true">
			<cfquery datasource="#application.dsn#" name="q">
				select 		jobType, jobID, taskOwnedBy, taskStatus, count(*) as taskCount
				from		farQueueTask
				group by	jobType, jobID, taskOwnedBy, taskStatus
			</cfquery>
			<cfloop query="q">
				<cfif not structkeyexists(st,q.jobID)>
					<cfset st[q.jobID] = { "jobType"=q.jobType, "jobID"=q.jobID, "jobOwner"=q.taskOwnedBy, "jobStatus"="queued", "taskCount"=0, "resultCount"=0, "datetimeLatest"=createdate(1970,1,1) }/>
				</cfif>
				<cfset st[q.jobID]["taskCount"] = st[q.jobID]["taskCount"] + q.taskCount />
				<cfif q.taskStatus eq "processing">
					<cfset st[q.jobID]["jobStatus"] = "processing" />
				</cfif>
			</cfloop>
			
			<cfquery datasource="#application.dsn#" name="q">
				select 		jobType, jobID, taskOwnedBy, count(*) as resultCount, max(resultTimestamp) as datetimeLatest
				from		farQueueResult
				group by	jobType, jobID, taskOwnedBy
			</cfquery>
			<cfloop query="q">
				<cfif not structkeyexists(st,q.jobID)>
					<cfset st[q.jobID] = { "jobType"=q.jobType, "jobID"=q.jobID, "jobOwner"=q.taskOwnedBy, "jobStatus"="complete", "taskCount"=0, "resultCount"=0, "datetimeLatest"=createdate(1970,1,1) }/>
				</cfif>
				<cfset st[q.jobID]["resultCount"] = st[q.jobID]["resultCount"] + q.resultCount />
				<cfif q.datetimeLatest gt st[q.jobid]["datetimeLatest"]>
					<cfset st[q.jobID]["datetimeLatest"] = q.datetimeLatest />
				</cfif>
			</cfloop>
		</cflock>
		
		<cfset q = querynew("objectid,typename,jobType,jobOwner,jobStatus,taskCount,resultCount,datetimeLatest","varchar,varchar,varchar,varchar,varchar,bigint,bigint,date") />
		<cfloop collection="#st#" item="k">
			<cfset queryaddrow(q) />
			<cfset querysetcell(q,"objectid",st[k].jobID) />
			<cfset querysetcell(q,"typename","farQueueJob") />
			<cfset querysetcell(q,"jobType",st[k].jobType) />
			<cfset querysetcell(q,"jobOwner",st[k].jobOwner) />
			<cfset querysetcell(q,"jobStatus",st[k].jobStatus) />
			<cfset querysetcell(q,"taskCount",st[k].taskCount) />
			<cfset querysetcell(q,"resultCount",st[k].resultCount) />
			<cfset querysetcell(q,"datetimeLatest",st[k].datetimeLatest) />
		</cfloop>
		
		<cfreturn q />
	</cffunction>
	
	<cffunction name="resetTasks" output="false" access="public" returntype="void" description="Remotes all tasks and results for a job, and stops any thread running one of it's tasks">
		<cfargument name="jobID" type="uuid" required="true" />

		<cfset var key = "">

		<!--- stop threads processing this job --->
		<cfloop collection="#this.threads#" item="key">
			<cfif structkeyexists(this.threads[key],"task") and this.threads[key].task.jobID eq arguments.jobID>
				<cfset killThread(key) />
			</cfif>
		</cfloop>
		
		<!--- reset processing tasks --->
		<cfquery datasource="#application.dsn#">
			update		farQueueTask
			set			taskStatus='queued'
			where		jobID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobID#">
		</cfquery>
	</cffunction>
	
	<cffunction name="endJob" output="false" access="public" returntype="void" description="Remotes all tasks and results for a job, and stops any thread running one of it's tasks">
		<cfargument name="jobID" type="uuid" required="true" />

		<cfset var key = "">

		<!--- stop threads processing this job --->
		<cfloop collection="#this.threads#" item="key">
			<cfif structkeyexists(this.threads[key],"task") and this.threads[key].task.jobID eq arguments.jobID>
				<cfset killThread(key,false) />
			</cfif>
		</cfloop>
		
		<!--- delete job tasks --->
		<cfquery datasource="#application.dsn#">delete from farQueueTask where jobID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobID#"></cfquery>
		
		<!--- delete job results --->
		<cfquery datasource="#application.dsn#">delete from farQueueResult where jobID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobID#"></cfquery>
	</cffunction>
	
	<cffunction name="clearTaskResults" output="false" access="public" returntype="void" description="Removes results that are too old from the queue">
		<cfargument name="jobID" type="uuid" required="false" />
		<cfargument name="before" type="numeric" required="false" default="#getTickCount() - application.fapi.getConfig("taskqueue","resultTimeout") * 60000#" />
		
		<cfset var thisresult = "" />
		
		<cflock name="result-queue-update" timeout="5" throwontimeout="true">
			<cfquery datasource="#application.dsn#">
				delete from	#application.dbowner#farQueueResult 
				where 		<cfif structkeyexists(arguments,"jobID")>
								jobID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobID#" /> and
							</cfif>
							resultTick <= <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.before#">
			</cfquery>
		</cflock>
	</cffunction>
	
	
	<!--- Internal functions for managing the queue by threads --->
	<cffunction name="claimTask" output="false" access="public" returntype="struct" description="Removes the first task in the queue and returns it">
		<cfargument name="threadID" type="string" required="true" />
		
		<cfset var stTask = structnew() />
		<cfset var q = "" />
		<cfset var thisfield = "" />
		
		<cflock name="task-queue-update" timeout="5" throwontimeout="true">
			<cfset q = application.fapi.getContentObjects(typename="farQueueTask",lProperties="*",taskStatus_eq="queued",orderby="taskTimestamp asc",maxrows=1) />
			
			<cfif q.recordcount>
				
				<!--- get data --->
				<cfset stTask = application.fc.lib.db.getData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,objectid=q.objectid[1]) />
				
				<!--- update record with status --->
				<cfset stTask.taskStatus = "processing" />
				<cfset stTask.threadID = arguments.threadID />
				<cfset stTask.datetimeLastUpdated = now() />
				<cfset application.fc.lib.db.setData(typename=application.stCOAPI.farQueueTask.packagepath,dsn=application.dsn,stProperties=stTask) />
				
				<cflog file="#application.applicationname#_tasks" text="claimed task #stTask.action# [#stTask.objectid#] owned by #stTask.taskOwnedBy# for #arguments.threadID#" />
				
			</cfif>
		</cflock>
		
		<cfreturn stTask />
	</cffunction>
	
	<cffunction name="processTask" output="false" access="public" returntype="void" description="Actually process the task">
		<cfargument name="stTask" type="struct" required="true" />
		
		<cfset var task = structnew() />
		<cfset var starttime = getTickCount() />
		
		<cfset task.taskID = arguments.stTask.objectid />
		<cfset task.jobType = arguments.stTask.jobType />
		<cfset task.jobID = arguments.stTask.jobID />
		<cfset task.action = arguments.stTask.action />
		<cfset task.ownedBy = arguments.stTask.ownedBy />
		<cfwddx action="wddx2cfml" input="#arguments.stTask.wddxDetails#" output="task.details">
		<cfwddx action="wddx2cfml" input="#arguments.stTask.wddxStackTrace#" output="task.stacktrace">
		
		<cflog file="#application.applicationname#_tasks" text="processing task #arguments.stTask.action# [#arguments.stTask.objectid#] owned by #arguments.stTask.taskOwnedBy# in #arguments.stTask.threadID# [#getTickCount()-starttime#ms]" />
		
		<cfset application.fc.lib.events.announce(component=listfirst(arguments.stTask.action,"."),eventName=listlast(arguments.stTask.action,"."),stParams=task) />
	</cffunction>
	
	
	<cffunction name="killThread" output="false" access="public" returntype="void" description="Terminates a specified thread">
		<cfargument name="threadID" type="string" required="true" />
		<cfargument name="requeueTask" type="boolean" required="false" default="true" />
		
		<cfset var stTask = "" />
		
		<cfif isdefined("this.threads.#arguments.threadID#")>
			<cfif structkeyexists(this.threads[arguments.threadID],"thread")>
				<!--- terminate thread --->
				<cfset this.threads[arguments.threadID].thread.cancel() />
			</cfif>
			
			<!--- get the task currently being processed --->
			<cfif structkeyexists(this.threads[arguments.threadID],"task")>
				<cfset stTask = this.threads[arguments.threadID].task />
			</cfif>
			
			<!--- remove the thread tracker --->
			<cfset structdelete(this.threads,arguments.threadID) />
			
			<!--- requeue the task --->
			<cfif isstruct(stTask) and arguments.requeueTask>
				<cfset requeueTask(taskID=stTask.objectid) />
			</cfif>
			
			<cflog file="#application.applicationname#_tasks" text="killed thread #arguments.threadID#" />
		</cfif>
	</cffunction>
	
	<cffunction name="getThreadCount" output="false" access="public" returntype="numeric" description="Returns number of threads">
		
		<cfreturn structcount(this.threads) />
	</cffunction>
	
	<cffunction name="clearProcessingThreads" output="false" access="public" returntype="void" description="Terminates threads that haven't done work in a while">
		<cfset var threadID = "" />
		
		<cfloop collection="#this.threads#" item="threadID">
			<!--- terminate threads that haven't done anything in a while --->
			<cfif dateadd("n",application.fapi.getConfig("taskqueue","threadTimeout"),this.threads[threadID].timestamp) lt now()>
				<!--- terminate thread --->
				<cfset killThread(threadID) />
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="startProcessingThread" output="false" access="public" returntype="string" description="If the thread limit hasn't been reached, this starts a new one">
		<cfset var thisThread = "" />
		<cfset var i = 0 />
		<cfset var thread	= '' />
		<cfset var stResult	= '' />
		<cfset var existingtrace	= '' />

		<cfif structcount(this.threads) lt application.fapi.getConfig("taskqueue","maxThreads")>
			<cfset thisthread = "thread_" & replace(createuuid(),"-","","ALL") />
			<cfset this.threads[thisthread] = {
				threadID = thisThread,
				created = now(),
				timestamp = now()
			} />
			
			<cfthread action="run" name="#thisthread#" threadID="#thisthread#" priority="LOW">
				<cftry>
					<cflog file="#application.applicationname#_tasks" text="started thread #attributes.threadID#" />
					
					<cfset request.inthread = true />
					<cfif application.sysinfo.engine.engine eq "coldfusion">
						<cfset application.fc.lib.tasks.threads[attributes.threadID].thread = getPageContext().getFusionContext().getUserThreadTask(ucase(attributes.threadID)) />
					</cfif>
					
					<cfloop condition="true">
						<!--- Claim a task --->
						<cfset application.fc.lib.tasks.threads[attributes.threadID].timestamp = now() />
						<cfset application.fc.lib.tasks.threads[attributes.threadID].task = application.fc.lib.tasks.claimTask(attributes.threadID) />
						<cfset thread.task = application.fc.lib.tasks.threads[attributes.threadID].task />
						
						<cfif structcount(application.fc.lib.tasks.threads[attributes.threadID].task)>
							
							<cftry>
								<!--- process task - it is up to the processing code to call addResult if appropriate --->
								<cfset application.fc.lib.tasks.processTask(application.fc.lib.tasks.threads[attributes.threadID].task) />
								
								
								<cfcatch>
									
									<!--- log error result against task --->
									<cfset stResult = structnew() />
									<cfset stResult["task"] = duplicate(application.fc.lib.tasks.threads[attributes.threadID].task) />
									<cfset stResult["error"] = application.fc.lib.error.normalizeError(cfcatch) />
									<cfif structkeyexists(stResult.error,"detail") and isJSON(stResult.error.detail)>
										<cfset stResult.error.detail = deserializejson(stResult.error.detail) />
									</cfif>
									<cfwddx action="wddx2cfml" input="#stResult.task.wddxStackTrace#" output="existingtrace" />
									<cfloop from="#arraylen(stResult.error.stack)-3#" to="1" index="i" step="-1">
										<cfset arrayprepend(existingtrace,stResult.error.stack[i]) />
									</cfloop>
									<cfset stResult.error.stack = existingtrace />
									<cfset application.fc.lib.tasks.addResult(taskID=stResult.task.objectid,jobType=stResult.task.jobType,jobID=stResult.task.jobID,ownedBy=stResult.task.ownedBy,result=stResult) />
									
									<!--- log error normally --->
									<cfset application.fc.lib.error.logData(stResult["error"]) />
									
									<cflog file="#application.applicationname#_tasks" text="processing task #stResult.task.action# [#stResult.task.objectid#] failed in thread #attributes.threadID#: #cfcatch.message#" />
									
								</cfcatch>
							</cftry>
							
							<!--- remove task from queue --->
							<cfset application.fc.lib.tasks.removeTask(application.fc.lib.tasks.threads[attributes.threadID].task.objectid) />
							
						<cfelse>
							
							<cfbreak>
							
						</cfif>
					</cfloop>
					
					<!--- remove thread tracker --->
					<cfset structdelete(application.fc.lib.tasks.threads,attributes.threadID) />
					
					<cflog file="#application.applicationname#_tasks" text="stopped thread #attributes.threadID# without errors" />
					
					<cfcatch>
						
						<!--- log error --->
						<cfset application.fc.lib.error.logData(application.fc.lib.error.normalizeError(cfcatch)) />
						
						<!--- remove thread tracker --->
						<cfset structdelete(application.fc.lib.tasks.threads,attributes.threadID) />
						
						<cflog file="#application.applicationname#_tasks" text="stopped thread #attributes.threadID# with error: #cfcatch.message#" />
						
					</cfcatch>
				</cftry>
			</cfthread>
		</cfif>
		
		<cfreturn thisThread />
	</cffunction>
	
</cfcomponent>