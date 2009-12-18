


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
	<cfif structKeyExists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>
		<cfparam name="stMetadata.ftLibraryDataTypename" default="#url.filterTypename#" />
		
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
			<cfset qAll = application.fapi.getContentType("#url.filterTypename#").getLibraryData() />	
		</cfif>		
	<cfelse>
		<!--- if nothing exists to generate library data then cobble something together --->
		<cfset qAll = application.fapi.getContentType("#url.filterTypename#").getLibraryData() />
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
	
		
	


	
		<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="property=#url.property#&ajaxmode=1") />
	
		<ft:form name="#stobj.typename#_#url.property#" bAjaxSubmission="true" action="#formAction#">	
		
			
			<grid:div style="padding:10px; border: 1px solid ##CCCCCC;background-color:##f1f1f1;margin-bottom:10px; ">
				<cfoutput>
				<div style="display:inline;color:##E17000">
					<div style="font-size:90%;margin-right:10px;padding:2px;float:left;">
						<a onclick="$j('##filterForm').toggle('slow');">FILTERING</a>							
					</div>	
					<br class="clearer" />						
				</div>
				<br class="clearer" />
				<div id="filterForm" style="<cfif not len(form.searchTypename)>display:none;</cfif>">
					<div style="padding:5px;">
				
						<fieldset class="fieldset">
							<grid:div class="ctrlHolder inlineLabels">
								<label for="searchTypename-#stobj.typename#-#url.property#-#stobj.typename#-#url.property#" class="label">Label</label>	
								<input type="text" id="searchTypename-#stobj.typename#-#url.property#" name="searchTypename" class="textInput" value="#form.searchTypename#" />
							</grid:div>
						</fieldset>
						<ft:buttonPanel>
							<ft:button value="Search" renderType="button" class="btn-small" />
							<cfif len(form.searchTypename)>
								<ft:button value="Clear Search" renderType="button" class="btn-generic" onClick="$j('##searchTypename-#stobj.typename#-#url.property#').attr('value','');" />
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