<cfcomponent displayname="Filter Property Definition" output="false" extends="farcry.core.packages.types.types" hint="Stores the definition of a specific filter on a property" bRefObjects="false" bSystem="true">

	<cfproperty name="filterID" type="UUID" hint="The filterID"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Filter"
		ftType="UUID" ftJoin="farFilter"  />
		
	<cfproperty name="property" type="string" hint="The property"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Property"
		ftType="list"  />
		
	<cfproperty name="type" type="string" hint="The type"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Type"
		ftType="list"
		ftWatch="property"  />
		
	<cfproperty name="wddxDefinition" type="longchar" hint="The wddx definition"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Definition"
		ftWatch="property,type"  />
		
	<cfproperty name="aRelated" type="array" hint="Any Array References"
		ftSeq="" ftWizardStep="" ftFieldset=""
		ftLabel="Related"
		ftWatch="property,type"
		ftType="join"
			ftJoin="dmNavigation"  />



	<!--- Import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
	

	
	<cffunction name="ftEditaRelated" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
			
		<cfset var htmlLabel = "" />
		<cfset var joinItems = "" />
		<cfset var i = "" />
		<cfset var counter = "" />
		<cfset var returnHTML = "" />		
		<cfset var qArrayField = "" />
		<cfset var formtool = "" />
		<cfset var stFilter = application.fapi.getContentObject(typename="farFilter", objectid="#arguments.stObject.filterID#") />
		<cfset var stPropertyMetadata	= '' />	
		
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
		
		<cfif len(stobject.property)>
			
			<cfif stobject.type EQ "related to">
				
				<cfset stPropertyMetadata = application.fapi.getPropertyMetadata(
														typename="#stFilter.filterTypename#", 
														property="#stobject.property#") />
														

		
				<cfif stPropertyMetadata.ftType EQ "join" OR stPropertyMetadata.ftType EQ "array" OR stPropertyMetadata.ftType EQ "uuid">		
					<cfsavecontent variable="returnHTML">	
					
							
															
								
						<cfquery datasource="#application.dsn#" name="qArrayField">
						SELECT *
						FROM #arguments.typename#_#arguments.stMetaData.Name#
						WHERE parentID = '#arguments.stObject.objectID#'
						ORDER BY seq
						</cfquery>
						
						<cfset joinItems = valueList(qArrayField.data) />
								
						<grid:div class="multiField">
			
						<cfif listLen(joinItems)>
							<cfoutput><ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;"></cfoutput>
								<cfset counter = 0 />
								<cfloop list="#joinItems#" index="i">
									<cfset counter = counter + 1 />
									<cftry>
										<skin:view objectid="#i#" webskin="librarySelected" r_html="htmlLabel" />
										<cfcatch type="any">
											<cfset htmlLabel = "OBJECT NO LONGER EXISTS" />
										</cfcatch>
									</cftry>
									<cfoutput>
									<li id="join-item-#arguments.stMetadata.name#-#i#" class="sort #iif(counter mod 2,de('oddrow'),de('evenrow'))#" serialize="#i#" style="clear:both;border:1px solid ##ebebeb;padding:5px;">
										<table style="width:100%">
										<tr>
										<td class="" style="cursor:move;width:100%;padding:3px;">#htmlLabel#</td>
										<td class="" style="padding:3px;white-space:nowrap;">
			
												<ft:button
													Type="button" 
													renderType="button"
													class="ui-state-default ui-corner-all"
													value="Detach" 
													text="detach" 
													confirmText="Are you sure you want to detach this item" 
													onClick="fcForm.detachLibraryItem('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#i#');" />
									 						 	
			
										</td>
										</tr>
										</table>
									</li>
									</cfoutput>	
								</cfloop>
							<cfoutput></ul></cfoutput>
							
							<cfoutput><input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#joinItems#" /></cfoutput>
						</cfif>
						
						<ft:buttonPanel style="">
						<cfoutput>
							
						
							<ft:button	Type="button" 
										renderType="button"
										class="ui-state-default ui-corner-all"
										value="attach" 
										onClick="fcForm.openLibrarySelect('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','ftJoin=#stPropertyMetadata.ftJoin#');" />
							
					
							
							<cfif listLen(joinItems)>
									<ft:button	Type="button" 
												renderType="button"
												class="ui-state-default ui-corner-all"
												value="Detach All" 
												text="detach all" 
												confirmText="Are you sure you want to detach all the attached items?"
												onClick="fcForm.detachAllLibraryItems('#stObject.typename#','#stObject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#','#joinItems#');" />								
									
			
							</cfif>
								
							
						</cfoutput>
						</ft:buttonPanel>
						
						<cfif listLen(joinItems) GT 1>
							<cfoutput>
								<script type="text/javascript">
								$j(function() {
									fcForm.initSortable('#arguments.stobject.typename#','#arguments.stobject.objectid#','#arguments.stMetadata.name#','#arguments.fieldname#');
								});
								</script>
							</cfoutput>
						</cfif>
												
						</grid:div>
					</cfsavecontent>
			
					
					<cfif structKeyExists(request, "hideLibraryWrapper") AND request.hideLibraryWrapper>
						<cfreturn "#returnHTML#" />
					<cfelse>
						<cfreturn "<div id='#arguments.fieldname#-library-wrapper'>#returnHTML#</div>" />	
					</cfif>
				</cfif>
				
			</cfif>
		</cfif>

		<cfreturn returnHTML />
		
	</cffunction>
	


	<cffunction name="ftEditProperty" output="true">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset var stFilter = application.fapi.getContentObject(typename="farFilter", objectid="#arguments.stObject.filterID#") />
		<cfset var html = "" />
		<cfset var qMetadata = application.types[stFilter.filterTypename].qMetadata>
		<cfset var qFieldSets = "" />
		<cfset var lFieldSets = "" />
		<cfset var iFieldset	= '' />
		<cfset var i	= '' />
		<cfset var qFieldset	= '' />

		<cfquery dbtype="query" name="qFieldSets">
		SELECT ftFieldset
		FROM qMetadata
		WHERE lower(ftFieldset) <> '#lcase(stFilter.filterTypename)#'
		ORDER BY ftseq
		</cfquery>
		
		<cfoutput query="qFieldSets" group="ftFieldset" groupcasesensitive="false">
			<cfset lFieldSets = listAppend(lFieldSets,qFieldSets.ftFieldset) />
		</cfoutput>	
			
		<cfsavecontent variable="html">
		
			<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#"></cfoutput>
			
			<cfoutput><option value="">--- Select A Filter Property ---</option></cfoutput>
			
			<cfif listLen(lFieldSets)>
					
				<cfloop list="#lFieldSets#" index="iFieldset">
					<cfoutput><optgroup label="#iFieldset#" style="font-weight:bold;">#iFieldset#</optgroup></cfoutput>
					<cfquery dbtype="query" name="qFieldset">
					SELECT *
					FROM qMetadata
					WHERE lower(ftFieldset) = '#lcase(iFieldset)#'
					ORDER BY ftSeq
					</cfquery>
					<cfoutput query="qFieldset">
						<option value="#qFieldset.propertyName#" <cfif stobject.property EQ qFieldset.propertyName>selected='selected'</cfif> >#application.fapi.getPropertyMetadata(typename=stFilter.filterTypename, property=qFieldset.propertyname, md='ftLabel', default=qFieldset.propertyname)#</option>
					</cfoutput>
				</cfloop>
				
				
			<cfelse>
				<cfoutput><optgroup label="Miscellaneous">Miscellaneous</optgroup></cfoutput>
				<cfquery dbtype="query" name="qFieldset">
				SELECT *
				FROM qMetadata
				ORDER BY ftSeq
				</cfquery>
				<cfoutput query="qFieldset">
					<option value="#qFieldset.propertyName#" <cfif stobject.property EQ qFieldset.propertyName>selected='selected'</cfif>>#application.fapi.getPropertyMetadata(typename=stFilter.filterTypename, property=qFieldset.propertyname, md='ftLabel', default=qFieldset.propertyname)#</option>
				</cfoutput>
			</cfif>
			
			
			
			<cfoutput><optgroup label="System Properties" style="font-weight:bold;">System</optgroup></cfoutput>
			<cfloop list="objectid,label,datetimecreated,createdby,ownedby,datetimelastupdated,lockedBy,locked" index="i">
				<cfoutput><option value="#i#" <cfif stobject.property EQ i>selected='selected'</cfif>>#i#</option></cfoutput>
			</cfloop>
				
			<cfoutput></select></cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html />
	
	
	</cffunction>
	
	<cffunction name="ftEditType" output="true">	
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">

		<cfset var html = "" />
		<cfset var stFilter = application.fapi.getContentObject(typename="farFilter", objectid="#arguments.stObject.filterID#") />
		<cfset var formtoolName = "" />
		<cfset var oFormtool = "" />
		<cfset var lFilterOptions = "" />
		<cfset var i	= '' />
		
		<cfsavecontent variable="html">
			<cfif len(stobject.property)>
				<cfset formtoolName = application.fapi.getPropertyMetadata(typename="#stFilter.filterTypename#", property="#stobject.property#", md="ftType", default="field") />
				<cfset oFormtool = application.fapi.getFormtool(formtoolName) />
				<cfset lFilterOptions = oFormtool.getFilterUIOptions(argumentCollection=arguments) />

					<!--- If more than 1 option, show user the choice. --->
					<cfif listLen(lFilterOptions)>
						<cfoutput>
						<select id="#arguments.fieldname#" name="#arguments.fieldname#">
							<option value="">-- select filter option --</option>
							<cfloop list="#lFilterOptions#" index="i">
								<option value="#i#" <cfif stObject.type EQ i>selected='selected'</cfif>>#i#</option>
							</cfloop>
						</select>
						</cfoutput>
					<cfelse>
						<cfoutput>
						<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#lFilterOptions#" />
						stobject.property: #stobject.property#<br>
						lFilterOptions: #lFilterOptions#
						</cfoutput>
					</cfif>
				
			<cfelse>
				<cfoutput>&nbsp;</cfoutput>
			</cfif>
		</cfsavecontent>
		<cfreturn html />
	</cffunction>
	
	
	<cffunction name="ftEditwddxDefinition" output="true">	
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="false" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
	
		<cfset var html = "" />		
		<cfset var stFilter = application.fapi.getContentObject(typename="farFilter", objectid="#arguments.stObject.filterID#") />
		<cfset var formtoolName = "" />
		<cfset var oFormtool = "" />
		<cfset var lFilterOptions = "" />
		<cfset var filterType = "" />
		<cfset var ui = "" />
		<cfset var stProps = structNew() />
		<cfset var formtool	= '' />
		
		 
		<cfsavecontent variable="html">
			
			<cfoutput><input type="hidden" name="#arguments.fieldname#" /></cfoutput>
			<cfif len(stobject.property)>
				
				<cfif len(stobject.type)>
					
					<cfset formtool = application.fapi.getPropertyMetadata(
															typename="#stFilter.filterTypename#", 
															property="#stobject.property#", 
															md="ftType", 
															default="field") />
					
					<cfif formtool EQ "join" OR  formtool EQ "array">		
						<!--- Don't show --->
					<cfelse>										
						<cfset oFormtool = application.fapi.getFormtool(formtool) />
						
						<cfset lFilterOptions = oFormtool.getFilterUIOptions(argumentCollection=arguments) />
														
						<cfif listFindNoCase(lFilterOptions, stobject.type)>
							<cfset filterType = stobject.type />
						</cfif>
						
						<cfif isWDDX(arguments.stObject.wddxDefinition)>
							<cfwddx	action="wddx2cfml" 
									input="#arguments.stObject.wddxDefinition#" 
									output="stProps" />
						</cfif>
						
						<cfset ui = oFormtool.editFilterUI(
												argumentCollection="#arguments#",
												filterTypename="#stFilter.filterTypename#", 
												filterProperty="#stobject.property#", 
												filterType="#filterType#",
												stFilterProps="#stProps#") />
												
						<cfoutput>
						#ui#
						</cfoutput>
					</cfif>
				</cfif>
			</cfif>
		</cfsavecontent>
		
		
		<cfreturn html />
	</cffunction>

	<cffunction name="ftValidatewddxDefinition" output="true">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFormPost" required="true" type="struct" hint="The fields that are relevent to this object.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset var stFilterDataWDDX = "" />		
		<cfset var oFormtool = application.fapi.getFormtool("#arguments.stMetadata.ftType#") />
		
		<cfif structKeyExists(arguments.stFormPost, "aRelated") AND len(arguments.stFormPost.aRelated.value)>
			<cfset arguments.stFieldPost.stSupporting.aRelated = listToArray(arguments.stFormPost.aRelated.value) />
		</cfif>
		
		<cfwddx action="cfml2wddx" input="#arguments.stFieldPost.stSupporting#" output="stFilterDataWDDX" />
		
		<cfset stResult = oFormtool.passed(value=stFilterDataWDDX) />
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
	</cffunction>		
</cfcomponent>