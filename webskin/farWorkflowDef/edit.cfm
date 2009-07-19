<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:processForm action="Save">

	<ft:processFormObjects typename="farWorkflowDef" />

</ft:processForm>



<ft:processForm action="Save,Cancel" exit="true" />

<ft:form>
	<ft:object typename="#stobj.typename#" objectid="#stobj.objectid#" lFields="title,description,aTaskDefs,lTypenames" r_stPrefix="prefix" legend="General Details" />
	
	<cfoutput><div id="editWebskins"></cfoutput>
		<cfif listLen(stobj.lTypenames)>
			<skin:view objectid="#stobj.objectid#" typename="farWorkflowDef" template="editWebskins" />
		</cfif>
	<cfoutput></div></cfoutput>


	<extjs:onReady>
		<cfoutput>
			Ext.get("#prefix#lTypenames").on('change', this.onClick, this, {
			    buffer: 500,
			    fn: function() { 
					renderWorkflowDefWebskins('#stobj.objectid#', Ext.get('#prefix#lTypenames').dom.value);
				 }
			});
			
			function renderWorkflowDefWebskins(workflowDefID,lTypenames) {
			
				var el = Ext.get("editWebskins");
				
				if (workflowDefID != '') {
				
			    	el.slideOut('t', {
					    easing: 'easeOut',
					    duration: .5,
					    remove: false,
					    useDisplay: true,
					    callback: function() {
							el.load({
						        url: "#application.url.webtop#/facade/workflowFacade.cfc?method=renderWorkflowDefWebskins",
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
									workflowDefID: workflowDefID,
									lTypenames: lTypenames
								}
						   });
					    }
					})
					
									

				}
		
			}			
		</cfoutput>
	</extjs:onReady>
	
	<ft:buttonPanel>
		<ft:button value="Save" />
		<ft:button value="Cancel" />
	</ft:buttonPanel>
</ft:form>
<cfsetting enablecfoutputonly="false" />