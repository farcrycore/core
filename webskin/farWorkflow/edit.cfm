<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processForm action="Save,Start Workflow" url="refresh">


	<cfset oTask = createObject("component", application.stcoapi.farTask.packagepath) />
	<cfset oTaskDef = createObject("component", application.stcoapi.farTaskDef.packagepath) />
	
	<cfset lSavedTasks = "" />

	<ft:processFormObjects typename="farTask"  r_stProperties="stProperties">
		<cfif structKeyExists(form, "selectedTaskDefID") AND listLen(form.selectedTaskDefID) and listFindNoCase(form.selectedTaskDefID,stProperties.taskDefID)>
			<cfset stTaskDef = oTaskDef.getData(objectid="#stProperties.taskDefID#") />
			<cfset stProperties.taskWebskin = stTaskDef.taskWebskin />
			
			<cfset lSavedTasks = listAppend(lSavedTasks, stProperties.objectid) />
		<cfelse>
			<ft:break />
		</cfif>
	</ft:processFormObjects>

<!--- <cfoutput><p>lSavedTasks: #lSavedTasks#</p></cfoutput><cfabort> --->

	<ft:processFormObjects objectid="#stobj.objectid#" r_stProperties="stProperties">
			
		<ft:processForm action="Start Workflow">
			<cfif len(stProperties.workflowDefID)>
				<cfset stProperties.bWorkflowSetupComplete = 1 />
			</cfif>
		</ft:processForm>
		
		
		<!--- REMOVE ALL OLD RECORDS --->
		<cfif arrayLen(stProperties.aTaskIDs)>
			<cfloop list="#arrayToList(stProperties.aTaskIDs)#" index="i">
				<cfif not listFindNoCase(lSavedTasks, i)>
					<cfset stResult = oTask.delete(objectid="#i#") />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- REINITIALISE THE TASK ARRAY --->
		<cfset stProperties.aTaskIDs = arrayNew(1) />
		
		<cfloop list="#lSavedTasks#" index="j">
			<cfset arrayAppend(stProperties.aTaskIDs, j) />
		</cfloop>
		
		<!--- We also need to save the underlying related object. This needs to be done as at this stage it still might only be in memory and it needs to go into the DB at this stage. --->
		<cfif structKeyExists(stProperties, "referenceID") and len(stProperties.referenceID)>
			<cfset stReferenceObject = structNew() />
			<cfset stRererenceObject.objectid = stProperties.referenceID />
			<cfset referenceTypename = application.coapi.coapiadmin.findType(objectid="#stRererenceObject.objectid#") />
			<cfset stResult = createObject("component", application.stcoapi[referenceTypename].packagePath).setData(stProperties="#stRererenceObject#") />
		</cfif>
		
	</ft:processFormObjects>	
	

</ft:processForm>



<ft:processForm action="Cancel" url="#application.url.farcry#/edittabOverview.cfm?objectid=#stobj.referenceID#" />

<ft:form>
	<ft:object objectid="#stobj.objectid#" lFields="workflowDefID,title,description,completionDate" lHiddenFields="aTaskIDs,referenceID" r_stPrefix="prefix" />
	
	<cfoutput><div id="selectTasks"></cfoutput>
		<cfif len(stobj.workflowDefID)>
			<skin:view objectid="#stobj.objectid#" typename="farWorkflow" template="editTasks" />
		</cfif>
	<cfoutput></div></cfoutput>


	<extjs:onReady>
		<cfoutput>
			Ext.get("#prefix#workflowDefID").on('change', this.onClick, this, {
			    buffer: 500,
			    fn: function() { 
					renderWorkflowTasks('#stobj.objectid#', Ext.get('#prefix#workflowDefID').dom.value);
				 }
			});
			
			function renderWorkflowTasks(workflowID,workflowDefID) {
			
				var el = Ext.get("selectTasks");
				
				if (workflowDefID != '') {
				
			    	el.slideOut('t', {
					    easing: 'easeOut',
					    duration: .5,
					    remove: false,
					    useDisplay: true,
					    callback: function() {
							el.load({
						        url: "#application.url.webtop#/facade/workflowFacade.cfc?method=renderWorkflowTasks",
						        scripts: true,
						        autoAbort:true,
						        callback: function() {
							    	el.slideIn('t', {
									    easing: 'easeIn',
									    duration: .5,
									    remove: false,
									    useDisplay: true
									})
						        },
								params: {
									workflowID: workflowID,
									workflowDefID: workflowDefID
								}
						   });
					    }
					})
					
									

				}
		
			}
			
		function renderWorkflowTasksSuccess(el,success,response,options){
		
			<!--- Ext.get('shoppingBasket').dom.innerHTML = response.responseText; --->
			var el = Ext.get('selectTasks');

	   	

				
		}				
		</cfoutput>
	</extjs:onReady>
	
	<ft:buttonPanel>
		<ft:button value="Start Workflow" />
		<ft:button value="Save" />
		<ft:button value="Cancel" />
	</ft:buttonPanel>
</ft:form>
<cfsetting enablecfoutputonly="false" />