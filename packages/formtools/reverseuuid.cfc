<cfcomponent extends="field" name="reverseuuid" displayname="reverseuuid" hint="Field component to liase with all reverse uuid fields"> 


	<cfproperty name="ftJoin" default="" type="string" />
	<cfproperty name="ftJoinProperty" default="" type="string" />
	<cfproperty name="ftTableView" default="editReverseUUIDTable" type="string" />
	<cfproperty name="ftEditView" default="webtopPageModal" type="string" />
	<cfproperty name="ftEditBodyView" default="editReverseUUIDObject" type="string" />
	<cfproperty name="ftAddBodyView" default="editReverseUUIDObjectAdd" type="string" />
	<cfproperty name="ftConfirmDeleteText" default="Are you sure?" type="string" />
	<cfproperty name="ftManageInOverview" default="false" type="boolean" hint="Should the relationship be managed in the overview tab?" />
	<cfproperty name="ftLibraryDataSQLOrderBy" required="false" default="datetimecreated" hint="Nominate a specific property to order library results by."/>

	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.reverseuuid" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>


	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var q = queryNew('objectid') />
		<cfset var returnHTML = "" />

		<!--- import tag libraries --->
		<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

		<skin:loadJS id="jquery-ajaxq" />
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadJS id="reverseUUID" />
		<skin:loadCSS id="jquery-ui" />

		<cfquery name="q" datasource="#application.dsn#">
			SELECT *
			FROM #arguments.stMetadata.ftJoin#
			WHERE #arguments.stMetadata.ftJoinProperty# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stObject.objectid#" />
			ORDER BY 
			<cfif structKeyExists(application.stCoapi['#arguments.stMetadata.ftJoin#'].stProps, "seq")>
				seq,
			</cfif>
			#arguments.stMetadata.ftLibraryDataSQLOrderBy#
		</cfquery>


		<cfsavecontent variable="returnHTML">
			<cfoutput>
			<div 	id="reverseuuid-#arguments.stObject.objectid#" 
					class="reverseuuid-wrap" 
					formtoolWrapFieldname="#arguments.fieldname#" 
					formtoolWrapTypename="#arguments.stObject.typename#" 
					formtoolWrapObjectID="#arguments.stObject.objectid#" 
					formtoolWrapProperty="#arguments.stMetadata.name#" 
					formtoolWrapJoinTypename="#arguments.stMetadata.ftJoin#"
					formtoolWrapJoinDisplayname="#JSStringFormat(application.fapi.getContentTypeMetadata(typename=arguments.stMetadata.ftJoin,md='displayName', default=arguments.stMetadata.ftJoin))#"
					formtoolWrapEditView="#arguments.stMetadata.ftEditView#"
					formtoolWrapEditBodyView="#arguments.stMetadata.ftEditBodyView#"
					formtoolWrapAddBodyView="#arguments.stMetadata.ftAddBodyView#"
					formtoolWrapConfirmDeleteText="#arguments.stMetadata.ftConfirmDeleteText#">
			</cfoutput>	
			
			<cfif NOT len(arguments.stMetadata.ftTableView)>
				<cfif structKeyExists(application.stcoapi[typename].stWebskins, "editReverseUUIDTable_#arguments.stMetadata.name#")>
					<cfset arguments.stMetadata.ftTableView = "editReverseUUIDTable_#arguments.stMetadata.name#" />
				<cfelse>
					<cfset arguments.stMetadata.ftTableView = "editReverseUUIDTable" />
				</cfif>
			</cfif>

			<cfif structKeyExists(application.stcoapi[typename].stWebskins, "#arguments.stMetadata.ftTableView#")>
				<skin:view typename="#arguments.stObject.typename#" objectid="#arguments.stObject.objectid#" webskin="#arguments.stMetadata.ftTableView#" q="#q#" stMetadata="#stMetadata#" bIgnoreSecurity="true"  />
			</cfif>	
		
			<cfoutput>
				<input type="hidden" id="#arguments.fieldname#" value="#valueList(q.objectid)#">
				<script type="text/javascript">
					$j(function() {

						// enabled sortable
						$j('.reverseuuid-sortable').sortable({
							items: 'tbody tr[objectid],li[objectid]',
							handle: '.reverseuuid-gripper',
							axis: 'y',
							stop: function(event,ui){
								var $formtoolWrap = $j(this).closest('.reverseuuid-wrap');
								var $formtoolWrapFieldname = $formtoolWrap.attr('formtoolWrapFieldname');
								var $formtoolWrapTypename = $formtoolWrap.attr('formtoolWrapTypename');
								var $formtoolWrapObjectID = $formtoolWrap.attr('formtoolWrapObjectID');
								var $formtoolWrapProperty = $formtoolWrap.attr('formtoolWrapProperty');

								var $lSortOrder = $j(this).sortable('toArray',{'attribute':'objectid'}).join(",") ;
								$j('##' + $formtoolWrapFieldname).attr('value', $lSortOrder).trigger('change');

								$j.ajax({
									cache: false,
									type: "POST",
						 			url: '/index.cfm?ajaxmode=1&type=' + $formtoolWrapTypename + '&objectid=' + $formtoolWrapObjectID + '&view=editReverseUUIDObjectSort&reverseUUIDProperty=' + $formtoolWrapProperty,
									data: {'lSortOrderIDs':$lSortOrder},
									dataType: "html",
									complete: function(data){
										
									}
								});
							},
							helper: function(e, tr) {
								var $originals = tr.children();
								var $helper = tr.clone();
								$helper.children().each(function(index)
								{
									// Set helper cell sizes to match the original sizes
									$j(this).width($originals.eq(index).width());
							    });
							    return $helper;
							}
						});

						// trigger change on ajax refresh
						$j("###arguments.fieldname#").trigger("change");
					});
				</script>				
			</div>
			</cfoutput>	
		</cfsavecontent>

		<cfreturn returnHTML />
	</cffunction>

</cfcomponent>