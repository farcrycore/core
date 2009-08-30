


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="../../tags" prefix="tags" />

<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	
	
	
	<!--- WE NEED TO GET THE METADATA OF THE FILTERED PROPERTY --->
	
	<cfset stFilter = application.fapi.getContentObject(objectid="#stobj.filterID#", typename="farFilter") />
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stFilter.filterTypename#", property="#stobj.property#") />
	
	
	
	
	
	
	<!--- FILTERING SETUP --->
	<cfif not len(url.filterTypename)>		
		<cfset url.filterTypename = listFirst(stMetadata.ftJoin) />
	</cfif>
	
	<cfif structKeyExists(form, "filterTypename")>
		<cfset url.filterTypename = form.filterTypename />
	</cfif>
	
	
	<cfset stFilter = structNew() />
	<cfset stFilter.id = "#stobj.typename#_#url.property#_#url.filterTypename#" />
	<cfset stFilter.filterTypename = "#url.filterTypename#" />
	<cfset stFilter.profileID = application.fapi.getCurrentUsersProfile().objectid />
	
	
		
	<!--- FILTRATION --->
	<ft:processForm action="Save Filter">
		<ft:processFormObjects typename="farFilter" />
		<ft:processFormObjects typename="farFilterProperty">
			<cfif not len(stProperties.property)>
				<ft:break />
			</cfif>
		</ft:processFormObjects>
	</ft:processForm>
	
	<ft:processForm action="Delete Filter Property">
		<cfset stResult = application.fapi.getContentType("farFilterProperty").delete(objectid="#form.selectedObjectID#") />
	</ft:processForm>
	
	
	
	<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="property=#url.property#") />
	
	
	<grid:div>
	<ft:form name="#stobj.typename#_#url.property#" bAjaxSubmission="true" action="#formAction#">	
	
	<grid:col id="utility" span="20">
		<cfoutput>
		<div id="utility-search">
	
			 	<div class="padding">
					<h3>Search</h3>
				</div>
				<div class="padding">
					<p>You can use one or more filters below to refine your search results.</p>
				</div>
			<!---	<div class="padding greypod">
					<strong><p>Name</p></strong>
					<input type="text" name="searchFilterName" value="#session.searchFilterName#">
				</div> --->
		</cfoutput>
		
		<grid:div class="ctrlHolder padding greypod">
			<cfoutput>
			<label for="filterTypename-#stobj.typename#-#url.property#">Type</label>			
			<select id="filterTypename-#stobj.typename#-#url.property#" name="filterTypename">
				<cfloop list="#stMetadata.ftJoin#" index="i">
					<option value="#i#" <cfif url.filterTypename EQ i>selected="selected"</cfif>>#i#</option>
				</cfloop>
			</select>
			<skin:onReady>
				$j("##filterTypename-#stobj.typename#-#url.property#").change(function(e) {
					btnClick('#request.farcryForm.name#','Change Join Property');	
					farcryForm_ajaxSubmission('#request.farcryForm.name#','#formAction#');		
				});
			</skin:onReady>
			</cfoutput>
		</grid:div>
		<cfparam name="form.searchTypename" default="" />
		
		
		<grid:div class="ctrlHolder padding greypod">
			<cfoutput>
			<label for="searchTypename-#stobj.typename#-#url.property#-#stobj.typename#-#url.property#">Name</label>	
			<input type="text" id="searchTypename-#stobj.typename#-#url.property#" name="searchTypename" value="#form.searchTypename#" />
			</cfoutput>
		</grid:div>
		
		<cfoutput>

			<div class="padding alignright">
				<ft:button value="Search" renderType="button" class="btn-small" />
				<ft:button value="Clear Search" renderType="button" class="btn-generic" onClick="$j('##searchTypename-#stobj.typename#-#url.property#').val('');" />
			</div>
			
		</div>
		</cfoutput>
		
		<cfif len(form.searchTypename)>
			<cfquery datasource="#application.dsn#" name="qFiltered">
			SELECT objectid
			FROM #stFilter.filterTypename#
			WHERE label like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#form.searchTypename#%" />
			</cfquery>
		</cfif>
		
		<!--- 
		
		<cfquery datasource="#application.dsn#" name="qFilters">
		SELECT *
		FROM farFilter
		WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stFilter.id#" />
		AND filterTypename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stFilter.filterTypename#" />
		AND profileID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stFilter.profileID#" />
		ORDER BY datetimelastupdated desc
		</cfquery>
		
		<cfif qFilters.recordCount GT 1>
			<select name="selectFilterID" id="selectFilterID">
				<cfloop query="qFilters">
					<option value="#qFilters.objectid#">#qFilters.objectid#</option>
				</cfloop>
			</select>
		</cfif>
		
		<cfif qFilters.recordCount>
			<skin:view typename="farFilter" objectid="#qFilters.objectid#" webskin="edit" />
		<cfelse>
			<skin:view typename="farFilter" key="#stFilter.id#-#stFilter.profileID#" webskin="edit" stProps="#stFilter#" />
		</cfif>
		
		<cfif qFilters.recordCount>
			
			
			<cfquery datasource="#application.dsn#" name="qProperties">
			SELECT *
			FROM farFilterProperty
			WHERE filterID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qFilters.objectid#" />
			</cfquery>
			
			
			
			<cfquery datasource="#application.dsn#" name="qFiltered">
				SELECT objectid
				FROM #stFilter.filterTypename#
				
				<cfset bFirstClause = true />
				
				<cfloop query="qProperties">
					
					
					<cfset formtool = application.fapi.getPropertyMetadata(
															typename="#stFilter.filterTypename#", 
															property="#qProperties.property#", 
															md="ftType", 
															default="field") />
															
					<cfset oFormtool = application.fapi.getFormtool(formtool) />
					
					<cfif isWDDX(qProperties.wddxDefinition)>
						<cfwddx	action="wddx2cfml" 
									input="#qProperties.wddxDefinition#" 
									output="stProps" />
									
						<cfset whereClause = oFormtool.getFilterSQL(
															filterTypename="#stFilter.filterTypename#",
															filterProperty="#qProperties.property#",
															renderType="#qProperties.type#",
															stProps="#stProps#"
															)>
							
						<cfif len(trim(whereClause))>
							<cfif bFirstClause>
								WHERE 
								<cfset bFirstClause = false />
							<cfelse>
								AND
							</cfif>
							
							<cfoutput> #preserveSingleQuotes(whereClause)# </cfoutput>
						</cfif>								
					</cfif>
					
				</cfloop>
			
			</cfquery>
			
		</cfif>
	
		<ft:buttonPanel>
			<ft:button value="Save Filter" />
		</ft:buttonPanel>
	
	 --->
	
		 
		<!--- SETUP THE QUERY DATA --->
		<cfif structKeyExists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>
			<cfparam name="stMetadata.ftLibraryDataTypename" default="#stFilter.filterTypename#" />
			
			<cfset oLibraryData = application.fapi.getContentType("#stMetadata.ftLibraryDataTypename#") />
			
			<!--- use ftlibrarydata method from primary content type --->
			<cfif structkeyexists(oLibraryData, stMetadata.ftLibraryData)>
				<cfinvoke component="#oLibraryData#" method="#stMetadata.ftLibraryData#" returnvariable="libraryData">
					<cfinvokeargument name="primaryID" value="#stobj.objectid#" />
				</cfinvoke>					
				
				<cfif isStruct(libraryData)>
					<cfset qAll = libraryData.q>
				<cfelse>
					<cfset qAll = libraryData />
				</cfif>	
			<cfelse>
				<cfset qAll = application.fapi.getContentType("#stFilter.filterTypename#").getLibraryData() />	
			</cfif>		
		<cfelse>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfset qAll = application.fapi.getContentType("#stFilter.filterTypename#").getLibraryData() />
		</cfif>
	
		<cfif isDefined("qFiltered")>
			<cfquery dbtype="query" name="qResult">
			SELECT qAll.*
			FROM qAll,qFiltered
			WHERE qAll.objectid = qFiltered.objectid
			</cfquery>
		<cfelse>
			<cfset qResult = qAll />
		</cfif>
		
	</grid:col>	
		
	<grid:col span="1" />
	
	<grid:col span="60">
		
		
		<cfoutput>
		<!-- summary pod with green arrow -->
		<div class="summary-pod">
			<span id="librarySummary-#stobj.typename#-#url.property#" style="text-align:center;"><p>&nbsp;</p></span>
			
			<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrarySelected', urlParameters="property=#url.property#&ajaxmode=1") />
			<ft:button value="show selected" renderType="link" type="button" onclick="farcryForm_ajaxSubmission('#request.farcryform.name#','#formAction#')" class="green" />

		</div>
		<!-- summary pod end -->
		</cfoutput>
		
		
		
		<!--- DETERMINE THE SELECTED ITEMS --->	
		<cfif isWDDX(stobj.wddxDefinition)>
			<cfwddx	action="wddx2cfml" 
				input="#stobj.wddxDefinition#" 
				output="stProps" />
		<cfelse>
			<cfset stProps = structNew() />
		</cfif>
			
		<cfparam name="stProps.relatedTo" default="">
		
		<cfif isArray(stProps.relatedTo)>
			<cfset lSelected = arrayToList(stProps.relatedTo) />
		<cfelse>
			<cfset lSelected = stProps.relatedTo />
		</cfif>

		<!--- IF WE HAVE SELECTED ITEMS, SHOW THE BUTTON TO VIEW THEM --->

		
		
		<!--- DISPLAY THE SELECTION OPTIONS --->	
		
		<skin:pagination query="#qResult#" submissionType="form">

			<cfoutput>
				<div class="ctrlHolder #stObject.currentRowClass#" style="padding:3px;margin:3px;clear:both;">
					<div style="float:left;width:20px;">
						<cfif stMetadata.type EQ "array">
							<input type="checkbox" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
						<cfelse>
							<input type="radio" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
						</cfif>
					</div>
					<div style="margin-left: 30px;">
						<skin:view objectid="#stobject.objectid#" webskin="librarySelected" bIgnoreSecurity="true" />
					</div>	
					<br style="clear:both;" />				
				</div>
			</cfoutput>
		</skin:pagination>
		
		<cfoutput>
		<script type="text/javascript">
		$j(function(){
			fcForm.initLibrary('#stobj.typename#','#stobj.objectid#','#url.property#');	
		});
		</script>
		</cfoutput>
	</grid:col>
	
	</ft:form>
	</grid:div>
</cfif>