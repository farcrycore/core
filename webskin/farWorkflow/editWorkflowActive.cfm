<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/farcry" prefix="far" />

<cfset oTask = createObject("component", application.stcoapi.farTask.packagepath) />
<cfset oTaskDef = createObject("component", application.stcoapi.farTaskDef.packagepath) />
<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />
<cfset oWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagepath) />


<ft:processForm action="action" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>

		<cfset stProperties = structNew() />
		<cfset stProperties.objectid = form.selectedObjectID />
		<cfset stProperties.userID = session.dmProfile.objectid />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />
		
		<cfset stTask = oTask.getData(objectID="#form.selectedObjectID#") />
		
		<cfquery datasource="#application.dsn#" name="qWorkflow">
		SELECT * FROM farWorkflow_aTaskIDs
		WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stTask.objectid#">
		</cfquery>
		
		<cfif qWorkflow.recordcount>
			<cfset stWorkflow = oWorkflow.getData(objectid="#qWorkflow.parentID#") />

			<cfif len(stTask.taskWebskin)>
				<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stWorkflow.referenceID#&method=#stTask.taskWebskin#">
			</cfif>
		</cfif>
		

		
	</cfif>
</ft:processForm>

<ft:processForm action="release to others" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>

		<cfset stProperties = structNew() />
		<cfset stProperties.objectid = form.selectedObjectID />
		<cfset stProperties.userID = "" />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />
		
	</cfif>
</ft:processForm>

<ft:processForm action="complete" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		
		<cfset stPropertes = structNew() />
		<cfset stProperties.objectid = form.selectedObjectid />
		<cfset stProperties.bComplete = 1 />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />
		
		<cfset stTask = oTask.getData(objectid="#form.selectedObjectid#") />
		
		<cfif len(form.logText)>
			<far:logEvent object="#stobj.objectID#" type="workflow" event="task completion" note="#stTask.title# complete: #form.logText#" />
		</cfif>
	</cfif>
</ft:processForm>

<ft:processForm action="reopen" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		
		<cfset stPropertes = structNew() />
		<cfset stProperties.objectid = form.selectedObjectid />
		<cfset stProperties.bComplete = 0 />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />

		
		<cfif len(form.logText)>
			<far:logEvent object="#stobj.objectID#" type="workflow" event="task completion" note="#stTask.title# complete: #form.logText#" />
		</cfif>		
		
	</cfif>
</ft:processForm>

<ft:processForm action="Complete Workflow">
	
	<cfset stPropertes = structNew() />
	<cfset stProperties.objectid = stobj.objectID />
	<cfset stProperties.bWorkflowComplete = 1 />
	<cfset stResult = setData(stProperties="#stProperties#") />
	
	<cfif len(form.logText)>
		<far:logEvent object="#stobj.objectid#" type="workflow" event="completing workflow" note="#form.logText#" />
	</cfif>	
	
	<!--- Run the onEnd function --->
	<cfset stResult = onEnd(objectid="#stobj.objectid#") />	
	
	
</ft:processForm>

<ft:processForm action="Reset Workflow" url="refresh">
		
	<cfset stResult = delete(objectid="#stobj.objectid#") />	
	
</ft:processForm>

<ft:processForm action="Decline Workflow">
	
	<cfset stResult = onStart(objectid="#stobj.objectid#") />	
	
</ft:processForm>



<ft:form>
	
		
<cfset stWorkflowDef = oWorkflowDef.getData(objectid="#stobj.workflowDefID#") />

<cfoutput><div style="border:1px dotted grey;margin:25px;padding:25px;"></cfoutput>

<cfoutput>
<h3>#stobj.title# (#stWorkflowDef.title#)</h3>
<p>#stobj.description#</p>
</cfoutput>

<cfoutput>
	<style type="text/css">
	table.workflowTable {border:1px dotted grey;border-width:0px 1px 0px 1px;}
	table.workflowTable td {padding:10px;border:1px dotted grey;border-width:1px 0px 1px 0px;}
	table.workflowTable tr.notAllowed {background-color:##efefef;}
	table.workflowTable tr.allowed {background-color:##DFE8F6;}	
	table.workflowTable tr.complete {background-color:##ffffff;}	
	</style>
</cfoutput>

<cfoutput><table class="workflowTable"></cfoutput>
<cfloop list="#arrayToList(stobj.aTaskIDs)#" index="i">

	<cfset stTask = oTask.getData(objectID="#i#") />
	<cfset stTaskDef = oTaskDef.getData(objectID="#stTask.taskDefID#") />
	
	
	<cfset bAllowedToAction = false />
				
	<cfif len(stTask.userID) AND stTask.userID NEQ session.dmProfile.objectid>				
		<cfset bAllowedToAction = true />
	<cfelseif not arrayLen(stTaskDef.aRoles)>
		<cfset bAllowedToAction = true />
	<cfelse>
		<cfloop from="1" to="#arrayLen(stTaskDef.aRoles)#" index="i">
			<cfif listFindNoCase(application.security.getCurrentRoles(),stTaskDef.aRoles[i])>
				<cfset bAllowedToAction = true />
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	
	
	<cfoutput>
	<tr class="<cfif bAllowedToAction>allowed<cfelse>notAllowed</cfif> <cfif stTask.bComplete>complete</cfif>">
		<td>
			<cfif stTask.bComplete>
				<img src="#application.url.webtop#/images/crystal/22x22/actions/ok.png" />
			<cfelse>
				<cfif bAllowedToAction>
					<img src="#application.url.webtop#/images/crystal/22x22/actions/14_pencil.png" />
				<cfelse>
					<img src="#application.url.webtop#/images/crystal/22x22/actions/stop.png" />
				</cfif>
			</cfif>
		</td>
		<td>#stTask.title#</td> 
		<cfif stTask.bComplete>	
			<td><ft:button value="reopen" selectedObjectID="#stTask.objectID#" /></td>
		<cfelse>
			<td nowrap="true">


				
				<cfif bAllowedToAction>
					
					
					<cfif len(stTask.userID) AND stTask.userID EQ session.dmProfile.objectid>
						<ft:button value="release to others" selectedObjectID="#stTask.objectID#" />
					</cfif>
					
					<ft:button value="action" selectedObjectID="#stTask.objectID#" />			
					<ft:button type="button" value="complete" onclick="log('#request.farcryForm.name#');" selectedObjectID="#stTask.objectID#" />	
					
					<ft:object objectid="#stTask.objectid#" typename="farTask" lFields="userID" r_stFields="stTaskFields" />
					#stTaskFields.userID.html#		
				<cfelse>
					<div>NOT PERMITTED TO ACTION</div>
					<cfif len(stTask.userID)>
						<cfset stProfile = createObject("component", application.stcoapi.dmProfile.packagePath).getData(objectid="#stTask.userID#") />
						<div>Assigned to: #stProfile.firstName# #stProfile.lastName#</div>					
					</cfif>
				</cfif>	
			</td>
		</cfif>
		
		
	</tr>
	</cfoutput>
	
</cfloop>
<cfoutput></table></cfoutput>


	<skin:htmlHead library="extjs" />

	<cfoutput>
		<input type="hidden" id="logText" name="logText" value="" />
		<script type="text/javascript">
		function log(form){
		   Ext.MessageBox.show({
           title:'Save Changes?',
           msg: 'Have you got anything to say about this task? <br />Something to let others know what your doing and why your doing it perhaps',
           buttons: Ext.MessageBox.OKCANCEL,
           fn: function(btn,text){
				if (btn == 'ok'){
			        Ext.get('logText').dom.value = text;
			        Ext.get(form).dom.submit();
			    } else {
			    	return false;
			    }
			},
		   prompt:true,
		   multiline:100,
           icon: Ext.MessageBox.QUESTION
       });
	}
	</script>
	</cfoutput>


<cfoutput><br /></cfoutput>

<ft:buttonPanel indentForLabel="false">
	<cfif stobj.bTasksComplete>
		<ft:button type="button" value="Complete Workflow" onclick="log('#request.farcryForm.name#');" />														
	</cfif>
	
	<ft:button value="Reset Workflow" confirmText="are you sure you want to remove this workflow" />
</ft:buttonPanel>

<cfoutput></div></cfoutput>
</ft:form>

<cfsetting enablecfoutputonly="false">