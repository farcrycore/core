
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Display Filtration --->
<!--- @@description: Used to define a content administration list.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />



<cfparam name="attributes.listID" /><!--- The id to attach this filter to. --->
<cfparam name="attributes.typename" /><!--- The content type we are filtering on. --->
<cfparam name="attributes.aFilters" default="#arrayNew(1)#" /><!--- Any Pre-Defined filters that can be used. Usually created from <ca:list /> --->
<cfparam name="attributes.r_stFilter" default="stFilter" /><!--- The caller scope variable that the results will be returned to --->


<cfif thistag.executionMode eq "Start">


<!--- ENVIRONMENT VARIABLES. --->
<cfset tagEnding = application.fapi.getDocType().tagEnding />
<cfset bShowFilter = false />


<cfparam name="session.fc.stFilters" default="#structNew()#" />
<cfparam name="session.fc.stFilters[attributes.listID]" default="#structNew()#" />
<cfparam name="session.fc.stFilters[attributes.listID].filterID" default="" />
<cfparam name="session.fc.stFilters[attributes.listID].sqlWhereClause" default="" />
<cfparam name="session.fc.stFilters[attributes.listID].sqlString" default="" />

<!--- Provide pointer to the session struct --->
<cfset stReturn = session.fc.stFilters[attributes.listID] />

	<ft:processForm action="Select Filter">
		<cfif structKeyExists(form, "listID") AND form.listID EQ attributes.listID AND structKeyExists(form, "filterID")>
			<cfset stReturn.filterID = form.filterID />	
			<cfset stReturn.SQLWhereClause = "" />	
			<cfset stReturn.SQLString = "" />		
		</cfif>	
	</ft:processForm>
	
	<ft:processForm action="Show All">		
		<cfset stReturn.filterID = "" />	
		<cfset stReturn.SQLWhereClause = "" />	
		<cfset stReturn.SQLString = "" />		
	</ft:processForm>
	
	<ft:processForm action="Create New Filter">		

		<cfset newCustomFilterID = application.fapi.getUUID() />
		<cfset stCustomFilter = application.fapi.setData(	objectid= "#newCustomFilterID#",
															typename="farFilter", 
															listID="#attributes.listID#", 
															title="untitled", 
															filterTypename="#attributes.typename#", 
															profileID="#application.fapi.getCurrentUsersProfile().objectid#") />
																		
		<cfset stTest = application.fapi.getContentType("farFilter").getData(newCustomFilterID) />
		<cfset stReturn.filterID = "#newCustomFilterID#" />	
		<cfset stReturn.SQLWhereClause = "" />	
		<cfset stReturn.SQLString = "" />	
		
		<cfset bShowFilter = true />	
	</ft:processForm>
	

	<!---<ft:processForm action="Save Filter">--->
		<ft:processFormObjects typename="farFilter" />
		<ft:processFormObjects typename="farFilterProperty">
		
			<cfif not structKeyExists(stProperties, "property") OR not len(stProperties.property)>
				<ft:break />
			</cfif>
			
			<cfif not structKeyExists(stProperties, "aRelated")>
				<cfset stProperties.aRelated = arrayNew(1) />
			</cfif>

		</ft:processFormObjects>
	<!---</ft:processForm>--->
	
	<ft:processForm action="Delete Filter">
		<cfset stResult = application.fapi.getContentType("farFilter").delete(objectid="#form.selectedObjectID#") />
		<cfset stReturn.filterID = "" />	
		<cfset stReturn.SQLWhereClause = "" />	
		<cfset stReturn.SQLString = "" />		
	</ft:processForm>
	
	<ft:processForm action="Delete Filter Property">
		<cfset stResult = application.fapi.getContentType("farFilterProperty").delete(objectid="#form.selectedObjectID#") />
		
		<cfset bShowFilter = true />
	</ft:processForm>
	
	<ft:processForm action="Add Filter Property">
		<cfset stNewFilterProperty = application.fapi.setData(	objectid="#application.fapi.getUUID()#",
																typename="farFilterProperty",
																filterID="#form.selectedObjectID#") />			
		
		<cfset bShowFilter = true />

	</ft:processForm>

	<ft:processForm action="Duplicate Filter">		
		<cfif len(stReturn.filterID)>
		
	
			<cfset oFilter = application.fapi.getContentType(typename="farFilter") />
			<cfset oFilterProperty = application.fapi.getContentType(typename="farFilterProperty") />
			
		
			<!--- Filters can generated from the <ca:filter /> tag or created as farFilter objects. --->
			<cfif isValid("uuid",stReturn.filterID)>
				
				<cfset stFilterToCopy = oFilter.getData(objectid="#stReturn.filterID#") />
				<cfset qFilterPropertiesToCopy = oFilter.getFilterProperties(filterID="#stFilterToCopy.objectid#") />
				
				<cfset stNewCustomFilter = duplicate(stFilterToCopy) />
				<cfset stNewCustomFilter.objectid = application.fapi.getUUID() />
				<cfset stNewCustomFilter.title = "#stNewCustomFilter.title# Duplicate" />
				<cfset stCustomFilter = application.fapi.setData(	stProperties= "#stNewCustomFilter#", 
																	profileID="#application.fapi.getCurrentUsersProfile().objectid#") />			
																	
				<cfloop query="qFilterPropertiesToCopy">
					<cfset stFilterPropertyToCopy = oFilterProperty.getData(objectid="#qFilterPropertiesToCopy.objectid#") />
				
					<cfset stNewCustomFilterProperty = duplicate(stFilterPropertyToCopy) />
					<cfset stNewCustomFilterProperty.objectid = application.fapi.getUUID() />
					<cfset stNewCustomFilterProperty.filterID = stNewCustomFilter.objectid />
					<cfset stCustomFilterProperty = application.fapi.setData(	stProperties= "#stNewCustomFilterProperty#") />			
				</cfloop>
				
				<cfset stReturn.filterID = "#stNewCustomFilter.objectid#" />	
				<cfset stReturn.SQLWhereClause = "" />	
				<cfset stReturn.SQLString = "" />		
			<cfelse>
				<cfset stCurrentFilter = structNew() />
				
				<cfloop from="1" to="#arrayLen(attributes.aFilters)#" index="i">
					<cfif attributes.aFilters[i].id EQ form.selectedObjectID>
						<cfset stCurrentFilter = attributes.aFilters[i] />
					</cfif>
				</cfloop>
				
				<cfif not structIsEmpty(stCurrentFilter)>
					<cfset stNewCustomFilter = structNew() />
					<cfset stNewCustomFilter.objectid = application.fapi.getUUID() />
					<cfset stNewCustomFilter.typename = "farFilter" />
					<cfset stNewCustomFilter.listID = "#attributes.listID#" />
					<cfset stNewCustomFilter.filterTypename = "#attributes.typename#" />
					<cfset stNewCustomFilter.title = "#stCurrentFilter.title# Duplicate" />
					<cfset stCustomFilter = application.fapi.setData(	stProperties= "#stNewCustomFilter#", 
																		profileID="#application.fapi.getCurrentUsersProfile().objectid#") />			
													
																								
					<cfloop from="1" to="#arrayLen(stCurrentFilter.aProperties)#" index="i">

						<cfset stNewCustomFilterProperty = structNew() />
						<cfset stNewCustomFilterProperty.objectid = application.fapi.getUUID() />
						<cfset stNewCustomFilterProperty.typename = "farFilterProperty" />
						<cfset stNewCustomFilterProperty.filterID = stNewCustomFilter.objectid />
						<cfset stNewCustomFilterProperty.property = stCurrentFilter.aProperties[i].name />
						<cfset stNewCustomFilterProperty.type = stCurrentFilter.aProperties[i].type />
						
						<cfwddx action="cfml2wddx" input="#stCurrentFilter.aProperties[i].stProps#" output="stNewCustomFilterProperty.wddxDefinition" />
						
						<cfset stCustomFilterProperty = application.fapi.setData(	stProperties="#stNewCustomFilterProperty#") />								
					</cfloop>
				
					<cfset stReturn.filterID = "#stNewCustomFilter.objectid#" />	
					<cfset stReturn.SQLWhereClause = "" />	
					<cfset stReturn.SQLString = "" />		
				
				</cfif>				
			</cfif>
			

		</cfif>																
		
		<cfset bShowFilter = true />
	</ft:processForm>
	
	
<!--- 
OUTPUT THE FILTER FORM
 --->	
	
<grid:div style="padding:10px;">
	<ft:form >
		<cfoutput>
			<input type="hidden" id="listID" name="listID" value="#attributes.listID#" #tagEnding#>
		</cfoutput>
	
	
		<cfset qFilters = application.fapi.getContentType("farFilter").getFilters(listID="#attributes.listID#") />
	
	
		<cfoutput>
		<select id="filterID" name="filterID">
			<option value="">-- Select Filter --</option>
			<cfif arrayLen(attributes.aFilters)>
				<optgroup label="Pre-Defined Filters">
				<cfloop from="1" to="#arrayLen(attributes.aFilters)#" index="i">
					<option value="#attributes.aFilters[i].id#" <cfif stReturn.filterID EQ stList.aFilters[i].id>selected="selected"</cfif> >#attributes.aFilters[i].title#</option>
				</cfloop>
				</optgroup>
			</cfif>
			<cfif qFilters.recordCount>
				<optgroup label="My Filters">
					<cfloop query="qFilters">
						<option value="#qFilters.objectid#" <cfif stReturn.filterID EQ qFilters.objectid>selected="selected"</cfif> >#qFilters.title#</option>
					</cfloop>
				</optgroup>
			</cfif>
			<!---<optgroup label="Other Filters">
			
			</optgroup>--->
		</select>
		</cfoutput>
		
		<skin:onReady>
		<cfoutput>
		

		$j('##filterID').bind('change',{formname:'#Request.farcryForm.Name#'}, function(event) {
		  btnSubmit(event.data.formname, 'Select Filter');
		});
		</cfoutput>
		</skin:onReady>
		
		<ft:button value="Create New Filter" text="Create New" renderType="link" />	
				
	

		<!--- GENERATE THE WHERE CLAUSE --->
	
		<cfif len(stReturn.filterID)>
		
			<cfif isValid("uuid",stReturn.filterID)>
				<!--- Custom Filter --->

				<cfset stReturn.SQLWhereClause = application.fapi.getContentType('farFilter').getFilterSQLWhereClause(typename="#attributes.typename#", filterID="#stReturn.filterID#") />	

				<cfset stReturn.SQLString = application.fapi.getContentType('farFilter').getFilterSQLString(typename="#attributes.typename#", filterID="#stReturn.filterID#") />	

				<cfoutput>
				<a class="show-predicate-editor">Show/Hide Filter</a>
				</cfoutput>
				
				<grid:div id="predicate-editor" style="font-size:90%;display:none; z-index:200;position:absolute;width:100%;border-top:1px solid ##CCCCCC;background:transparent url(#application.url.webtop#/css/images/bg-filter-right.png) no-repeat bottom right;">
					<grid:div style="background:transparent url(#application.url.webtop#/css/images/bg-filter.png) no-repeat bottom left;margin-right:25px;">
						<grid:div style="padding:5px 0px 25px 25px;">
							<grid:div>
								<skin:view typename="farFilter" objectid="#stReturn.filterID#" webskin="edit" />
								
								<ft:buttonPanel>
									<ft:button value="Save Filter" />
									<ft:button value="Secure Filter" type="button" onClick="$fc.openDialogIFrame('Secure Filter', '/index.cfm?type=farFilter&objectid=#stReturn.filterID#&view=editRoles')" />
									<ft:button value="Delete Filter" selectedObjectid="#stReturn.filterID#" confirmText="Are you sure you wish to permenently delete this filter?" />
									
								</ft:buttonPanel>
							</grid:div>
						</grid:div>
					</grid:div>
				</grid:div>
				
					
				<skin:onReady>
				<cfoutput>
					$j("a.show-predicate-editor").click(function(){
							$j("##predicate-editor").toggle("slow");
					});
					<cfif bShowFilter>
						$j("##predicate-editor").show();
					</cfif>
				</cfoutput>
				</skin:onReady>
			<cfelse>
				<!--- Pre-Defined Filter --->
	
				<cfset stCurrentFilter = structNew() />
				
				<cfloop from="1" to="#arrayLen(attributes.aFilters)#" index="i">
					<cfif attributes.aFilters[i].ID EQ stReturn.filterID>
						<cfset stCurrentFilter = attributes.aFilters[i] />
					</cfif>
				</cfloop>
				
				<cfif not structIsEmpty(stCurrentFilter)>
				
					<cfset stReturn.SQLWhereClause = application.fapi.getContentType('farFilter').getFilterSQLWhereClause(typename="#attributes.typename#", aProperties="#stCurrentFilter.aProperties#") />	
	
					<cfset stReturn.SQLString = application.fapi.getContentType('farFilter').getFilterSQLString(typename="#attributes.typename#", aProperties="#stCurrentFilter.aProperties#") />	

				</cfif>
			</cfif>
			
		</cfif>
		
			
		<!--- DISPLAY THE FILTERED QUERY --->
		
		<cfif len(stReturn.filterID)>
			<cfoutput>
			<div style="float:right;">
				<ft:button value="Duplicate Filter" text="Duplicate" renderType="link" selectedObjectID="#stReturn.filterID#" />	
				<ft:button value="Show All" text="Show All" renderType="link" />
			</div>
			</cfoutput>
			
			<cfoutput><p><a class="show-predicate-editor">Currently filtering by</a>: <cfif len(stReturn.SQLString)>#stReturn.SQLString#<cfelse>nothing</cfif> </p></cfoutput>
		</cfif>
	</ft:form>
</grid:div>	
	
	
	
	

<cfset CALLER[attributes.r_stFilter] = stReturn />	


</cfif>