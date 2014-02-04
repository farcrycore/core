<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif isdefined("url.action") and url.action eq "getupdates">
	
	<cfset qJobs = application.fc.lib.tasks.getJobs() />
	<cfset aJobs = arraynew(1) />
	<cfset stDateTimeLatest = duplicate(application.stCOAPI.farQueueJob.stProps.datetimeLatest.metadata) />
	<cfloop query="qJobs">
		<cfset st = structnew() />
		<cfloop list="#qJobs.columnlist#" index="col">
			<cfif structkeyexists(application.stCOAPI.farQueueJob.stProps,col)>
				<cfset col = application.stCOAPI.farQueueJob.stProps[col].metadata.name />
			<cfelse>
				<cfset col = lcase(col) />
			</cfif>
			<cfif col eq "datetimeLatest">
				<cfset stDateTimeLatest.value = qJobs[col][qJobs.currentrow]  />
				<cfset st[col] = application.formtools["datetime"].oFactory.display(typename="farQueueJob",stObject=structnew(),stMetadata=stDateTimeLatest,fieldname="") />
			<cfelse>
				<cfset st[col] = qJobs[col][qJobs.currentrow] />
			</cfif>
		</cfloop>
		<cfset arrayappend(aJobs,st) />
	</cfloop>
	
	<cfset application.fapi.stream(type="json",content=aJobs) />
	
<cfelse>
	
	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-jquery-ui" />
	
	<cfparam name="form.selectedObjectID" default="" />
	<cfparam name="form.objectID" default="" />
	<cfset form.objectID = listappend(form.objectID,form.selectedObjectID) />
	
	<cfif structkeyexists(url,"action") and url.action eq "testtask" and structkeyexists(url,"length")>
		<cfset application.fc.lib.tasks.addTask(action="testing.sleep",details=url.length) />
		<skin:location url="#application.fapi.fixURL(removevalues='action,length')#" addtoken="false" />
	</cfif>
	
	<ft:processform action="Reset processing tasks">
		<cfloop list="#form.objectID#" index="thisjob">
			<cfset application.fc.lib.tasks.resetTasks(jobID=thisjob) />
		</cfloop>
		<skin:bubble message="Processing tasks in job have been reset" />
		<skin:location url="#application.fapi.fixURL()#" addtoken="false" />
	</ft:processform>

	<ft:processform action="clearresults,Clear results">
		<cfloop list="#form.objectID#" index="thisjob">
			<cfset application.fc.lib.tasks.clearTaskResults(jobID=thisjob,before=getTickCount()) />
		</cfloop>
		<skin:bubble message="Cleared job results" />
		<skin:location url="#application.fapi.fixURL()#" addtoken="false" />
	</ft:processform>

	<ft:processform action="endjob,End job">
		<cfloop list="#form.objectID#" index="thisjob">
			<cfset application.fc.lib.tasks.endJob(thisjob) />
		</cfloop>
		<skin:bubble message="Ended job/s" />
		<skin:location url="#application.fapi.fixURL()#" addtoken="false" />
	</ft:processform>

	<skin:onReady><cfoutput>
		var fields = ["jobStatus","taskCount","resultCount","datetimeLatest"];
		var newJobs = [];
		
		function updateJobs(){
			setTimeout(function(){
				if ($j("##fcModal:visible").size() === 0){
					$j.getJSON("#application.fapi.fixURL()#&action=getupdates",function(results){
						var newJob = false;
						
						for (var i=0; i<results.length; i++){
							if ($j("input[value='"+results[i].objectid+"']").size()){
								for (var j=0; j<fields.length; j++){
									var field = $j("##wrap-fc"+results[i].objectid.replace(/-/g,"")+fields[j]), numeric = field.html().search(/^\d+$/)===0, oldval = numeric ? parseInt(field.html()) : 0;
									
									if (numeric && oldval != results[i][fields[j]])
										field.animate({ "color":oldval<results[i][fields[j]] ? "##468847" : "##FF0000", "font-weight":500 }).animate({ "color":"##000000", "font-weight":100 });
										
									field.html(results[i][fields[j]]);
								}
							}
							else{
								newJobs.push(results[i].objectid);
								newJob = true;
							}
						}
						
						if (newJob && $j("##reloadjobs").size()===0){
							$j("##bubbles").append("<div id='reloadjobs' class='alert alert-info'><button type='button' class='close' data-dismiss='alert'>&times;</button>There is a new job. Would you like to <a href='##' onclick='window.location.reload();return false;'>refresh the page</a>?</div>");
						}
						else
							updateJobs();
					});
				}
				else {
					updateJobs();
				}
			},2000);
		};
		updateJobs();
		
		$j("##objectadmin").on("click","a:contains('View tasks')",function(ev){
			var jobid = $j(this).closest("tr").find("input[name='objectid']").val();
			
			$fc.openBootstrapModal({ 
				title : "Job Tasks",
				url : "#application.url.webtop#/index.cfm?id=#url.id#&type=farQueueTask&view=webtopPageModal&jobid="+jobid 
			});
			
			ev.preventDefault();
			return false;
		});
		
		$j("##objectadmin").on("click","a:contains('View failed results')",function(ev){
			var jobid = $j(this).closest("tr").find("input[name='objectid']").val();
			
			$fc.openBootstrapModal({ 
				title : "Job Tasks",
				url : "#application.url.webtop#/index.cfm?id=#url.id#&type=farQueueResult&view=webtopPageModal&jobid="+jobid+"&resultStatus=error"
			});
			
			ev.preventDefault();
			return false;
		});
		
		$j("##objectadmin").on("click","a:contains('View all results')",function(ev){
			var jobid = $j(this).closest("tr").find("input[name='objectid']").val();
			
			$fc.openBootstrapModal({ 
				title : "Job Tasks",
				url : "#application.url.webtop#/index.cfm?id=#url.id#&type=farQueueResult&view=webtopPageModal&jobid="+jobid+"&resultStatus=all"
			});
			
			ev.preventDefault();
			return false;
		});
		
		$j("##objectadmin").on("click","a:contains('View all results')",function(ev){
			var jobid = $j(this).closest("tr").find("input[name='objectid']").val();
			
			if (!confirm('Are you sure you want to close this job?')) 
				return false;
			
			$fc.openBootstrapModal({ 
				title : "Job Tasks",
				url : "#application.url.webtop#/index.cfm?id=#url.id#&type=farQueueResult&view=webtopPageModal&jobid="+jobid+"&resultStatus=all"
			});
			
			ev.preventDefault();
			return false;
		});
	</cfoutput></skin:onReady>
	
	<cfset aButtons = arraynew(1) />
	
	<cfset stButton = structnew() />
	<cfset stButton.text = "Clear Results" />
	<cfset stButton.value = "clearresults" />
	<cfset stButton.permission = "developer" />
	<cfset stButton.onclick = "" />
	<cfset stButton.hint = "Clear the results of the selected jobs">
	<cfset arrayappend(aButtons,stButton) />
	
	<cfset stButton = structnew() />
	<cfset stButton.text = "Close Jobs" />
	<cfset stButton.value = "endjob" />
	<cfset stButton.permission = "developer" />
	<cfset stButton.onclick = "if (!confirm('Are you sure you want to close the selected jobs?')) return false;" />
	<cfset stButton.hint = "Close the selected jobs">
	<cfset arrayappend(aButtons,stButton) />
	
	<cfset stButton = structnew() />
	<cfset stButton.text = "Create Test Task" />
	<cfset stButton.value = "testtask" />
	<cfset stButton.permission = "" />
	<cfset stButton.onclick = "var length = prompt('How long should the task take? (s)','30'); console.log(length);if (length) window.location='#application.url.webtop#/index.cfm?id=#url.id#&action=testtask&length='+length; return false;" />
	<cfset stButton.hint = "Create a task that will take a specified length of time to complete">
	<cfset arrayappend(aButtons,stButton) />

	<cfset qJobs = application.fc.lib.tasks.getJobs() />
	
	<ft:objectAdmin
		typename="#stObj.name#"
		columnList="jobType,jobOwner,jobStatus,taskCount,resultCount,datetimeLatest"
		lButtons="clearresults,endjob,testtask"
		aButtons="#aButtons#"
		lButtonsEmpty="testtask"
		lCustomActions="View tasks,Reset processing tasks,View failed results,View all results,Clear results,Close job"
		emptymessage="There are currently no jobs in the system"
		bViewCol="false"
		bPreviewCol="false"
		numitems="100"
		qRecordSet="#qJobs#"
		r_oTypeAdmin="oTypeAdmin" />
	
</cfif>

<cfsetting enablecfoutputonly="false">