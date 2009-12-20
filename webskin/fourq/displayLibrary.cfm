


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	
	
	
	
	
	<!--- FILTERING SETUP --->
	<cfif not len(url.filterTypename)>		
		<cfset url.filterTypename = listFirst(stMetadata.ftJoin) />
	</cfif>
	
	<cfif structKeyExists(form, "filterTypename")>
		<cfset url.filterTypename = form.filterTypename />
	</cfif>
	
	
	<cfparam name="form.searchTypename" default="" />
	
	

	<cfif len(form.searchTypename)>
		<cfquery datasource="#application.dsn#" name="qFiltered">
		SELECT objectid
		FROM #url.filterTypename#
		WHERE label like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#form.searchTypename#%" />
		</cfquery>
	</cfif>
			
	 
	<!--- SETUP THE QUERY DATA --->
	<cfset bFoundLibraryData = false />
		
	<cfif structKeyExists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>
		<cfparam name="stMetadata.ftLibraryDataTypename" default="#url.filterTypename#" />
		
		<cfset oLibraryData = application.fapi.getContentType("#stMetadata.ftLibraryDataTypename#") />
		
		<!--- use ftlibrarydata method from primary content type --->
		<cfif structkeyexists(oLibraryData, stMetadata.ftLibraryData)>
			
			<cfset bFoundLibraryData = true />
			
			<cfinvoke component="#oLibraryData#" method="#stMetadata.ftLibraryData#" returnvariable="libraryDataResult">
				<cfinvokeargument name="primaryID" value="#stobj.objectid#" />
			</cfinvoke>					
			
			<cfif isStruct(libraryDataResult)>
				<cfset qAll = libraryDataResult.q />			
			<cfelse>
				<cfset qAll = libraryDataResult />
			</cfif>	
									
		</cfif>	
		
	</cfif>
		
		
	<cfif not bFoundLibraryData>
		<!--- if nothing exists to generate library data then cobble something together --->
		
		<cfset SQLWhere = "1=1" />
	
		<cfif structKeyExists(stMetadata, "ftLibraryDataSQLWhere")>
			<cfset SQLWhere = " #SQLWhere# AND (#stMetadata.ftLibraryDataSQLWhere#)" />
		</cfif>
		
		<cfset SQLOrderBy = "datetimelastupdated desc" />
		<cfif structKeyExists(stMetadata, "ftLibraryDataSQLOrderBy")>
			<cfset SQLOrderBy = stMetadata.ftLibraryDataSQLOrderBy />
		</cfif>
		
		
		<cfset oFormTools = createObject("component","farcry.core.packages.farcry.formtools")>
		<cfset stLibraryData = oFormTools.getRecordset(typename="#url.filterTypename#", sqlColumns="objectid", sqlOrderBy="#SQLOrderBy#", SQLWhere="#SQLWhere#", RecordsPerPage="0") />

		<cfset qAll = stLibraryData.q />
		
		<cfset bFoundLibraryData = true />
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
	
		
	


	
		<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="filterTypename=#url.filterTypename#&property=#url.property#&ajaxmode=1") />
	
		<ft:form name="#stobj.typename#_#url.property#_#url.filterTypename#" bAjaxSubmission="true" action="#formAction#">	
		
			
			<grid:div style="padding:5px; border: 1px solid ##CCCCCC;background-color:##f1f1f1;margin-bottom:5px; ">
				<cfoutput>
				<div style="display:inline;color:##E17000">
					<div style="font-size:90%;margin-right:10px;padding:2px;float:left;">
						<a onclick="$j('##filterForm-#url.filterTypename#').toggle('slow');">FILTERING</a>							
					</div>	
					<br class="clearer" />						
				</div>
				<br class="clearer" />
				<div id="filterForm-#url.filterTypename#" style="<cfif not len(form.searchTypename)>display:none;</cfif>">
					<div style="padding:5px;">
				
						<fieldset class="fieldset" style="margin:0px;">
							<grid:div class="ctrlHolder inlineLabels">
								<label for="searchTypename-#stobj.typename#-#url.property#-#url.filterTypename#" class="label">Label</label>	
								<input type="text" id="searchTypename-#stobj.typename#-#url.property#-#url.filterTypename#" name="searchTypename" class="textInput" value="#form.searchTypename#" />
							</grid:div>
						</fieldset>
						<ft:buttonPanel>
							<ft:button value="Search" renderType="button" class="btn-small" />
							<cfif len(form.searchTypename)>
								<ft:button value="Clear Search" renderType="button" class="btn-generic" onClick="$j('##searchTypename-#stobj.typename#-#url.property#-#url.filterTypename#').attr('value','');" />
							</cfif>
						</ft:buttonPanel>
						
						<br class="clearer" />
					</div>
					<br class="clearer" />
				</div>
				</cfoutput>
				
			</grid:div>
			
				<cfif isArray(stobj[url.property])>
					<cfset lSelected = arrayToList(stobj[url.property]) />
				<cfelse>
					<cfset lSelected = stobj[url.property] />
				</cfif>
				
				
				
				
				
				<!--- DISPLAY THE SELECTION OPTIONS --->	
				
				<!--- 
				<ft:pagination qRecordSet="#stLibraryData.q#" typename="#request.ftJoin#" submissionType="URL" recordsPerPage="#stLibraryData.recordsPerPage#" totalRecords="#stLibraryData.CountAll#" pageLinks="5" top="true" bottom="true">
				
				 --->
				
				<skin:pagination query="#qResult#" 
					submissionType="form"
					oddRowClass="alt"
					evenRowClass="">
				
				
				
					
					<cfif stObject.bFirst>
						<cfoutput>
						<table class="objectAdmin" style="width:100%">
						</cfoutput>
					</cfif>
					
					<cfoutput>
						<tr class="ctrlHolder selector-wrap #stObject.currentRowClass#" style="cursor:pointer;">
							<td class="" style="width:20px;padding:3px;">
								<cfif stMetadata.type EQ "array">
									<input type="checkbox" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
								<cfelse>
									<input type="radio" id="selected_#stobject.currentRow#" name="selected" class="checker" value="#stobject.objectID#" <cfif listFindNoCase(lSelected,stobject.objectid)>checked="checked"</cfif> />
								</cfif>
							</td>
							<td class="#stObject.currentRowClass#" style="padding:3px;">
								<skin:view objectid="#stobject.objectid#" webskin="librarySelected" bIgnoreSecurity="true" />
							</td>					
						</tr>
					</cfoutput>
					
					<cfif stObject.bLast>
						<cfoutput>
						</table>
						</cfoutput>
					</cfif>
				</skin:pagination>
				
				<cfoutput>
				<script type="text/javascript">
				$j(function(){
					fcForm.initLibrary('#stobj.typename#','#stobj.objectid#','#url.property#');	
				});
				</script>
				</cfoutput>
		
		
		</ft:form>
	
</cfif>