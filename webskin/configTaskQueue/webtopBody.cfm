<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processform action="Start a Thread" url="refresh">
	<cfset newThread = application.fc.lib.tasks.startProcessingThread() />
	<cfif len(newThread)>
		<skin:bubble title="Started a New Thread" message="#newThread#" tags="success" />
	<cfelse>
		<skin:bubble message="No thread started" tags="error" />
	</cfif>
</ft:processform>

<ft:processform action="Kill Thread" url="refresh">
	<cfloop list="#form.selectedObjectID#" index="thisthread">
		<cfset application.fc.lib.tasks.killThread(thisthread) />
		<skin:bubble title="Killed Thread" message="#thisthread#" tags="success" />
	</cfloop>
</ft:processform>


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="jquery-modal" />
<skin:loadCSS id="jquery-modal" />

<ft:form id="objectadmin">
	<cfset stThreads = duplicate(application.fc.lib.tasks.threads) />
	<cfset oTask = application.fapi.getContentType(typename="farQueueTask") />
	
	<cfoutput>
		<h1>Task Queue Threads</h1>
		<div class="buttonHolder farcry-button-bar btn-group" style="text-align:left;">
			<ft:button value="Start a Thread" title="Starts a thread if the configured rules allows it. NOTE: if there are no tasks to process, the thread will finish immediately." class="btn-primary" icon="fa-plus" />
			
			<cfif structcount(stThreads) and application.sysinfo.engine.engine eq "coldfusion">
				<ft:button value="Kill Thread" text="Kill Threads" title="Kills the selected threads, and requeues the tasks they are working on" icon="fa-times-circle-o" onclick="if (!confirm('Are you sure you want to terminate the selected threads?')) return false;" />
			</cfif>
		</div>
		<div class="farcry-objectadmin-body">
	</cfoutput>
	
	<cfif structcount(stThreads)>
		<cfoutput>
			<table class="farcry-objectadmin table table-striped table-hover">
				<thead>
					<tr class="alt">
						<th style="width:1.5em;"></th>
						<th style="width:10em;">Action</th>
						<th>Thread ID</th>
						<th>Thread Created</th>
						<th>Current Task</th>
						<th>Owner</th>
						<th>Task Started</th>
					</tr>
				</thead>
				<tbody>
		</cfoutput>
		
		<cfloop collection="#stThreads#" item="thisthread">
			<cfoutput>
				<tr class="">
					<td style="white-space:nowrap;">
						<input class="formCheckbox" type="checkbox" onclick="setRowBackground(this);" value="#stThreads[thisthread].threadID#" name="selectedObjectID">
					</td>
					<td class="objectadmin-actions" nowrap="nowrap" style="">
						<cfif application.sysinfo.engine.engine eq "coldfusion">
							<ft:button value="Kill Thread" text="" title="Kill this thread" icon="fa-times-circle-o" selectedObjectID="#stThreads[thisthread].threadID#" onclick="if (!confirm('Are you sure you want to terminate this thread? If the task has not been completed it will be requeued.')) return false;" />
						</cfif>
					</td>
					<td>#thisthread#</td>
					<td>
						<span title="#timeformat(stThreads[thisthread].created,'hh:mmtt')#, #dateformat(stThreads[thisthread].created,'dd mmm yyyy')#">
							#application.fapi.prettyDate(stThreads[thisthread].created)#
						</span>
					</td>
					<td>
						<cfif structkeyexists(stThreads[thisthread],"task")>
							#stThreads[thisthread].task.jobType# #stThreads[thisthread].task.action#
						</cfif>
					</td>
					<td>
						<cfif structkeyexists(stThreads[thisthread],"task")>
							<cfset stMeta = duplicate(application.stCOAPI.farQueueTask.stProps.taskOwnedBy.metadata) />
							<cfset stMeta.value = stThreads[thisthread].task.taskOwnedBy />
							#oTask.ftDisplayTaskOwnedBy(typename="farQueueTask",stObject=stThreads[thisthread].task,stMetadata=stMeta,fieldname="")#
						</cfif>
					</td>
					<td>
						<cfif structkeyexists(stThreads[thisthread],"task")>
							<span title="#timeformat(stThreads[thisthread].timestamp,'hh:mmtt')#, #dateformat(stThreads[thisthread].timestamp,'dd mmm yyyy')#">
								#application.fapi.prettyDate(stThreads[thisthread].timestamp)#
							</span>
						</cfif>
					</td>
				</tr>
			</cfoutput>
		</cfloop>
		
		<cfoutput>
				</tbody>
			</table>
		</cfoutput>
	<cfelse>
		<cfoutput><div class="alert alert-info">There are currently no active threads</div></cfoutput>
	</cfif>
</ft:form>

<cfsetting enablecfoutputonly="false">