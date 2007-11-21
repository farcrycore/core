<cfcomponent extends="field" name="webskinfilter" displayname="webskinfilter" hint="Used to build webskin filters"> 
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.webskinfilter" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var html = "" />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

		<skin:htmlHead library="extjs" />
		
		<skin:htmlHead id="webskinfilter">
			<cfoutput>
		
			<style>
				table.webskinfilter, tr.webskinfilter, td.webskinfilter {
					border: 0 none transparent;
					background: transparent none;
				}
				table.webskinfilter {
					width: 100%;
				}
				td.webskinfilter {
					width: 50%;
				}
				
				div.webskinlist {
					height: 200px;
					overflow-x: hidden;
					overflow-y:scroll;
					overflow:-moz-scrollbars-vertical !important;
				}
			</style>
			
			</cfoutput>
		</skin:htmlHead>
				
		<skin:htmlHead>
			<cfoutput>
				
			<script type="text/javascript">
				Ext.onReady(function(){
					var store = new Ext.data.Store({
						proxy: new Ext.data.HttpProxy({
							url: "#application.url.farcry#/facade/filterwebskins.cfm",
							method: 'POST'
						}),
						reader: new Ext.data.JsonReader({
							root: 'rows',
							fields:["Type","Webskin","Right"]
						})
					});
					
					// Webskin list
					var grid = new Ext.grid.GridPanel({
						applyTo:"#arguments.fieldname#webskins",
						store: store,
					    columns:[
							{header: "Type", dataIndex: "Type", width: 100, sortable: true, locked: true},
							{id: "webskin", header: "Webskin", dataIndex: "Webskin", width: 150, sortable: true},
							{header: "Access", width: 100, dataIndex:"Right", sortable: true, resizable: false, renderer: function(value,metadata,record,rowindex,colindex,store) {
								return (value == "Granted") ? "<span class='success'>Granted</span>" : "<span class='error'>Denied</span>";
							}}
						],
						autoExpandColumn: 'webskin'
					});
					store.load({params:{filters:"#arguments.stMetadata.value#"}});
					grid.render();
					
					var input = Ext.get("#arguments.fieldname#");
					input.on("change",function(){ 
						store.load({params:{filters:input.getValue()}});
					});
				})
			</script>
			
			<style type="text/css">
				.x-panel table, .x-panel tr, x-panel td {
					background: transparent none;
					margin: 0;
				}
				
				.x-panel a.x-grid3-hd-btn {
					background: ##C3DAF9 url(#application.url.farcry#/js/ext/resources/images/default/grid/grid3-hd-btn.gif) no-repeat scroll left center;
					cursor:pointer;
				}
			</style>
			</cfoutput>
		</skin:htmlHead>

		<cfsavecontent variable="html">

			<cfoutput>
				<div id="#arguments.fieldname#currentFilters">
					<table class="webskinfilter">
						<tr class="webskinfilter">
							<td class="webskinfilter">
								<textarea style="width:80%;" onchange="" name="#arguments.fieldname#" id="#arguments.fieldname#">#arguments.stMetadata.value#</textarea>
							</td>
							<td class="webskinfilter">
								Filters should be in the form type.(prefix)(*), e.g.<br/>
								*.display* grants access to all webskins prefixed with display<br/>
								dmNews.stats grants access to the stats dmNews webskin<br/>
								dmEvent.* grants access to all event webskins
							</td>
						</tr>
						<tr class="webskinfilter">
							<td class="webskinfilter" colspan="2">
								<div id="#arguments.fieldname#webskins" class="webskinlist"></div>
							</td>
						</tr>
					</table>
				</div>
			</cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var displayname = "#arguments.stMetadata.value#" />
		<cfset var webskinTypename = arguments.typename />
		<cfset var oType = "" />
		
		<cfif structKeyExists(arguments.stMetadata, "ftTypename") AND len(arguments.stMetadata.ftTypename)>
			<cfset webskinTypename = arguments.stMetadata.ftTypename />
		</cfif>
		

		<cfif len(arguments.stMetadata.value)>
			<cfset oType=createobject("component", application.stCoapi[webskinTypename].packagePath) />
			
			<cfset displayname=oType.getWebskinDisplayname(typename=webskinTypename, template="#arguments.stMetadata.value#") />
		</cfif>	
		
		
		<cfreturn displayname />
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent>