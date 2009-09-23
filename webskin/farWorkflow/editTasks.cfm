<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />


<cfif arrayLen(stobj.aTaskIDs)>
	<cfquery datasource="#application.dsn#" name="qTasks">
	SELECT * FROM farTask
	WHERE ObjectID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arrayToList(stobj.aTaskIDs)#" />)
	</cfquery>
	<cfset lSelectedTaskIDs = valueList(qTasks.taskDefID) />
<cfelse>
	<cfset lSelectedTaskIDs = "" />
</cfif>

<cfset referenceTypename = application.coapi.coapiUtilities.findType(objectid="#stobj.referenceID#") />
<cfset stReferenceObject = createObject("component", application.stcoapi["#referenceTypename#"].packagePath).getData(objectid="#stobj.referenceID#") />


<cfif len(stobj.workflowDefID)>
	<cfset stWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagepath).getData(objectID="#stobj.workflowDefID#") />
	<cfset qReferenceObjectWebskins = application.coapi.coapiAdmin.getWebskins(typename="#stReferenceObject.typename#") />
	<cfset lReferenceObjectWebskins = valueList(qReferenceObjectWebskins.methodname) />
	<cfset lReferenceObjectWebskins = listAppend(lReferenceObjectWebskins, "edit") />
	
	<cfoutput><div style="border:1px dotted grey;margin:25px;padding:25px;"></cfoutput>
	<cfoutput>
		<h3>#stWorkflowDef.title#</h3>
		<p>#stWorkflowDef.description#</p>
	</cfoutput>

	<cfif arrayLen(stWorkflowDef.aTaskDefs)>
		<cfset oTaskDef = createObject("component", application.stcoapi.farTaskDef.packagepath) />

		<cfoutput><ul></cfoutput>
		<cfloop from="1" to="#arrayLen(stWorkflowDef.aTaskDefs)#" index="i">
			<cfset stTaskDef = oTaskDef.getData(objectID="#stWorkflowDef.aTaskDefs[i]#") />
			
			<cfif listFindNoCase(lReferenceObjectWebskins, stTaskDef.taskWebskin)>
				<cfoutput>
					<li>
						<fieldset>
							<legend>
								<input type="checkbox"  id="selectedTaskDefID#i#" name="selectedTaskDefID" value="#stTaskDef.objectid#" <cfif listFindNoCase(lSelectedTaskIDs, stTaskDef.objectid)>checked</cfif> >
								#stTaskDef.title#
							</legend>
							<cfset qTask = queryNew("blah") />
							<cfif arrayLen(stobj.aTaskIDs)>
								<cfquery datasource="#application.dsn#" name="qTask">
								SELECT * FROM farTask
								WHERE objectID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arrayToList(stobj.aTaskIDs)#" />)
								AND taskDefID = '#stTaskDef.objectid#'
								</cfquery>
							</cfif>
							
							<cfif qTask.recordCount>
								<cfset taskID = qTask.objectid />
							<cfelse>
								<cfset taskID = application.fc.utils.createJavaUUID() />
								<cfset stProperties = structNew() />
								<cfset stProperties.objectid = taskID />
								<cfset stProperties.title = stTaskDef.title />
								<cfset stProperties.description = stTaskDef.description />
								<cfset stProperties.taskDefID = stTaskDef.objectid />
								
								<cfset stResult = createObject("component", application.stcoapi.fartask.packagePath).setData(stProperties="#stProperties#", bSessionOnly="true") />
							</cfif>
							<div id="taskEdit#i#" style="<cfif not listFindNoCase(lSelectedTaskIDs, stTaskDef.objectid)>display:none;</cfif>">asdf
								<ft:object objectid="#taskID#" typename="farTask" lFields="title,description,userID" lHiddenFields="taskDefID" IncludeFieldSet="false" />
							</div>
						</fieldset>
						
						<extjs:onReady>
							Ext.get("selectedTaskDefID#i#").on('change', this.onClick, this, {
							    fn: function() { 
							    	var elTaskDef = Ext.get("selectedTaskDefID#i#");
							    	var elTask = Ext.get("taskEdit#i#");
									
							    	if (elTaskDef.dom.checked) {
								    	elTask.slideIn('t', {
										    easing: 'easeIn',
										    duration: .5,
										    remove: false,
										    useDisplay: true
										});
							    	} else {
								    	elTask.slideOut('t', {
										    easing: 'easeOut',
										    duration: .5,
										    remove: false,
										    useDisplay: true
										});
							    	}
									
								 }
							});
						</extjs:onReady>
					</li>
				</cfoutput>
			</cfif>
		</cfloop>
		<cfoutput></ul></cfoutput>
	
		<cfoutput></div></cfoutput>
	</cfif>
</cfif>

	
<cfsetting enablecfoutputonly="false" />