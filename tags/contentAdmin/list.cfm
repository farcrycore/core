
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
<!--- @@displayname: Content Admin List --->
<!--- @@description: Used to define a content administration list.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfif not thistag.HasEndTag>
	<cfabort showerror="ca:list must have an end tag...">
</cfif>
	
<!--- ATTRIBUTES --->
<cfparam name="attributes.id" default="" /><!--- The id to uniquely identify this listing. By Default it will be set to the typename. If typename, is empty, this field is required. --->
<cfparam name="attributes.typename" default="" /><!--- The typename to automatically fetch all the records of --->
<cfparam name="attributes.query" default="" /><!--- A query name that contains the objectids to loop over. --->
<cfparam name="attributes.title" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.style" default="" />
	
		


<cfif thistag.executionMode eq "Start">

	<!--- ENVIRONMENT VARIABLES --->
	<cfparam name="session.fc.stList" default="#structNew()#" />
	<cfset tagEnding = application.fapi.getDocType().tagEnding />
	
	<!--- INITIALISATION --->
	<cfif not len(attributes.id)>
		<cfif len(attributes.title)>
			<cfset attributes.id = attributes.title />
		<cfelse>
			<cfthrow message="You attributes.id or attributes.title is required." />
		</cfif>
	</cfif>
	
	<cfif isSimpleValue(attributes.query) AND len(attributes.query)>
		<cfif structKeyExists(caller, attributes.query)>
			<cfset attributes.query = caller[attributes.query] />
		</cfif>
	</cfif>
	
	<!--- Hash the ID so we have a valid structKey --->
	<cfset hashID = hash(attributes.id)>

	<cfparam name="session.fc.stList[hashID]" default="#structNew()#" />

	<cfset session.fc.stList[hashID].id = attributes.id />
	<cfset session.fc.stList[hashID].hashID = hashID />
	<cfset session.fc.stList[hashID].typename = "#attributes.typename#" />
	<cfset session.fc.stList[hashID].query = "#attributes.query#" />
	<cfset session.fc.stList[hashID].title = "#attributes.title#" />
	<cfset session.fc.stList[hashID].aColumns = "#arrayNew(1)#" />
	<cfset session.fc.stList[hashID].aFilters = "#arrayNew(1)#" />
	<cfset session.fc.stList[hashID].aLimits = "#arrayNew(1)#" />
	<cfparam name="session.fc.stList.#hashID#.filterID" default="" /><!--- Stores the current filter being used. May be predefined or custom --->
	<cfparam name="session.fc.stList.#hashID#.SQLWhereClause" default="" /><!--- Stores the current filter converted to an sql where clause --->
	<cfparam name="session.fc.stList.#hashID#.SQLString" default="" /><!--- Stores the current filter converted to an string for use as descriptive text --->


	
	
	
	
	<!--- Add a reference to the list for sub tags --->
	<cfset stList = session.fc.stList[hashID] />

</cfif>



<cfif thistag.executionMode eq "End">


	<ft:processForm action="Select Filter">
		<cfif structKeyExists(form, "listID") AND form.listID EQ hashID AND structKeyExists(form, "filterID")>
			<cfset session.fc.stList[hashID].filterID = form.filterID />	
			<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
			<cfset session.fc.stList[hashID].SQLString = "" />		
		</cfif>	
	</ft:processForm>
	
	<ft:processForm action="Show All">		
		<cfset session.fc.stList[hashID].filterID = "" />	
		<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
		<cfset session.fc.stList[hashID].SQLString = "" />		
	</ft:processForm>
	
	<ft:processForm action="Create New Filter">		

		<cfset newCustomFilterID = application.fapi.getUUID() />
		<cfset stCustomFilter = application.fapi.setData(	objectid= "#newCustomFilterID#",
															typename="farFilter", 
															listID="#hashID#", 
															title="untitled", 
															filterTypename="#session.fc.stList[hashID].typename#", 
															profileID="#application.fapi.getCurrentUsersProfile().objectid#") />
																		
		<cfset stTest = application.fapi.getContentType("farFilter").getData(newCustomFilterID) />
		<cfset session.fc.stList[hashID].filterID = "#newCustomFilterID#" />	
		<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
		<cfset session.fc.stList[hashID].SQLString = "" />		
	</ft:processForm>
	

	<!---<ft:processForm action="Save Filter">--->
		<ft:processFormObjects typename="farFilter" />
		<ft:processFormObjects typename="farFilterProperty">
			<cfif not structKeyExists(stProperties, "property") OR not len(stProperties.property)>
				<ft:break />
			</cfif>
		</ft:processFormObjects>
	<!---</ft:processForm>--->
	
	<ft:processForm action="Delete Filter">
		<cfset stResult = application.fapi.getContentType("farFilter").delete(objectid="#form.selectedObjectID#") />
		<cfset session.fc.stList[hashID].filterID = "" />	
		<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
		<cfset session.fc.stList[hashID].SQLString = "" />		
	</ft:processForm>
	
	<ft:processForm action="Delete Filter Property">
		<cfset stResult = application.fapi.getContentType("farFilterProperty").delete(objectid="#form.selectedObjectID#") />
	</ft:processForm>
	
	<ft:processForm action="Add Filter Property">
		<cfset stNewFilterProperty = application.fapi.setData(	objectid="#application.fapi.getUUID()#",
																typename="farFilterProperty",
																filterID="#form.selectedObjectID#") />			
		

	</ft:processForm>

	<ft:processForm action="Duplicate Filter">		
		<cfif len(session.fc.stList[hashID].filterID)>
		
	
			<cfset oFilter = application.fapi.getContentType(typename="farFilter") />
			<cfset oFilterProperty = application.fapi.getContentType(typename="farFilterProperty") />
			
		
			<!--- Filters can generated from the <ca:filter /> tag or created as farFilter objects. --->
			<cfif isValid("uuid",session.fc.stList[hashID].filterID)>
				
				<cfset stFilterToCopy = oFilter.getData(objectid="#session.fc.stList[hashID].filterID#") />
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
				
				<cfset session.fc.stList[hashID].filterID = "#stNewCustomFilter.objectid#" />	
				<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
				<cfset session.fc.stList[hashID].SQLString = "" />		
			<cfelse>
				<cfset stCurrentFilter = structNew() />
				
				<cfloop from="1" to="#arrayLen(session.fc.stList[hashID].aFilters)#" index="i">
					<cfif session.fc.stList[hashID].aFilters[i].id EQ form.selectedObjectID>
						<cfset stCurrentFilter = session.fc.stList[hashID].aFilters[i] />
					</cfif>
				</cfloop>
				
				<cfif not structIsEmpty(stCurrentFilter)>
					<cfset stNewCustomFilter = structNew() />
					<cfset stNewCustomFilter.objectid = application.fapi.getUUID() />
					<cfset stNewCustomFilter.typename = "farFilter" />
					<cfset stNewCustomFilter.listID = "#session.fc.stList[hashID].hashID#" />
					<cfset stNewCustomFilter.filterTypename = "#session.fc.stList[hashID].typename#" />
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
				
					<cfset session.fc.stList[hashID].filterID = "#stNewCustomFilter.objectid#" />	
					<cfset session.fc.stList[hashID].SQLWhereClause = "" />	
					<cfset session.fc.stList[hashID].SQLString = "" />		
				
				</cfif>				
			</cfif>
			

		</cfif>																
		
		
	</ft:processForm>
	


	<admin:header />
	
	<grid:div style="padding:10px;">
	<ft:form >
		<cfoutput>
			<input type="hidden" id="listID" name="listID" value="#hashID#" #tagEnding#>
		</cfoutput>
	
	
		<cfset qFilters = application.fapi.getContentType("farFilter").getFilters(listID="#hashID#") />
	
	
		<cfoutput>
		<select id="filterID" name="filterID">
			<option value="">-- Select Filter --</option>
			<cfif arrayLen(stList.aFilters)>
				<optgroup label="Pre-Defined Filters">
				<cfloop from="1" to="#arrayLen(stList.aFilters)#" index="i">
					<option value="#stList.aFilters[i].id#" <cfif session.fc.stList[hashID].filterID EQ stList.aFilters[i].id>selected="selected"</cfif> >#stList.aFilters[i].title#</option>
				</cfloop>
				</optgroup>
			</cfif>
			<cfif qFilters.recordCount>
				<optgroup label="My Filters">
					<cfloop query="qFilters">
						<option value="#qFilters.objectid#" <cfif session.fc.stList[hashID].filterID EQ qFilters.objectid>selected="selected"</cfif> >#qFilters.title#</option>
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
	
		<cfif len(session.fc.stList[hashID].filterID)>
		
			<cfif isValid("uuid",session.fc.stList[hashID].filterID)>
				<!--- Custom Filter --->

				<cfset session.fc.stList[hashID].SQLWhereClause = application.fapi.getContentType('farFilter').getFilterSQLWhereClause(typename="#session.fc.stList[hashID].typename#", filterID="#session.fc.stList[hashID].filterID#") />	

				<cfset session.fc.stList[hashID].SQLString = application.fapi.getContentType('farFilter').getFilterSQLString(typename="#session.fc.stList[hashID].typename#", filterID="#session.fc.stList[hashID].filterID#") />	

				<cfoutput>
				<a id="show-predicate-editor">Show/Hide Filter</a>
				</cfoutput>
				
				
				<grid:div id="predicate-editor" style="display:<cfif structIsEmpty(form)>none<cfelse>block</cfif>;border:1px solid ##DBDBDB; padding:10px;">
					<grid:div>
						<skin:view typename="farFilter" objectid="#session.fc.stList[hashID].filterID#" webskin="edit" />
						
						<ft:buttonPanel>
							<ft:button value="Save Filter" />
							
							<ft:button value="Secure Filter" type="button" onClick="$fc.openDialogIFrame('Secure Filter', '/index.cfm?type=farFilter&objectid=#session.fc.stList[hashID].filterID#&view=editRoles')" />
							<ft:button value="Delete Filter" selectedObjectid="#session.fc.stList[hashID].filterID#" confirmText="Are you sure you wish to permenently delete this filter?" />
							
						</ft:buttonPanel>
					</grid:div>
				</grid:div>
				
					
				<skin:onReady>
				<cfoutput>
					$j("##show-predicate-editor").click(function(){
							$j("##predicate-editor").toggle("slow");
					});
				</cfoutput>
				</skin:onReady>
			<cfelse>
				<!--- Pre-Defined Filter --->
	
				<cfset stCurrentFilter = structNew() />
				
				<cfloop from="1" to="#arrayLen(stList.aFilters)#" index="i">
					<cfif stList.aFilters[i].ID EQ session.fc.stList[hashID].filterID>
						<cfset stCurrentFilter = stList.aFilters[i] />
					</cfif>
				</cfloop>
				
				<cfif not structIsEmpty(stCurrentFilter)>
				
					<cfset session.fc.stList[hashID].SQLWhereClause = application.fapi.getContentType('farFilter').getFilterSQLWhereClause(typename="#session.fc.stList[hashID].typename#", aProperties="#stCurrentFilter.aProperties#") />	
	
					<cfset session.fc.stList[hashID].SQLString = application.fapi.getContentType('farFilter').getFilterSQLString(typename="#session.fc.stList[hashID].typename#", aProperties="#stCurrentFilter.aProperties#") />	

					
				</cfif>
			</cfif>
			
		</cfif>
		
		<!---
		<ca:displayFilter typename="#session.fc.stList[hashID].typename#" r_stFilter="stFilter" />
		
		--->

		<cfset lColumnList = "qAll.objectid" />
		
		<cfloop from="1" to="#arraylen(stList.aColumns)#" index="i">
			<cfif not listFindNoCase(lColumnList, i)>
				<cfset lColumnList = listAppend(lColumnList, "#stList.aColumns[i].property#") />
			</cfif>
		</cfloop>
					
		<cfquery datasource="#application.dsn#" name="qAll">
		SELECT #lColumnList#
		FROM #session.fc.stList[hashID].typename# as qAll
		</cfquery>
	
		<cfif len(session.fc.stList[hashID].SQLWhereClause)>
				
			<cfset sqlWhereClause = session.fc.stList[hashID].SQLWhereClause />
			<cfquery datasource="#application.dsn#" name="qFiltered">
				SELECT objectid
				FROM #session.fc.stList[hashID].typename#
				WHERE #preserveSingleQuotes(sqlWhereClause)#
			</cfquery>	
				
			<cfquery dbtype="query" name="qResult">
			SELECT #lColumnList#
			FROM qAll,qFiltered
			WHERE qAll.objectid = qFiltered.objectid
			</cfquery>
		<cfelse>
			<cfset qResult = qAll />
		</cfif>
			
			
		<!--- DISPLAY THE FILTERED QUERY --->
		
		<cfif len(session.fc.stList[hashID].SQLWhereClause)>
			<cfoutput>
			<div style="float:right;">
				<ft:button value="Duplicate Filter" text="Duplicate" renderType="link" selectedObjectID="#session.fc.stList[hashID].filterID#" />	
				<ft:button value="Show All" text="Show All #qAll.recordCount#" renderType="link" />
			</div>
			</cfoutput>
			
			<cfoutput><p>Filtered By: #session.fc.stList[hashID].SQLString# </p></cfoutput>
		</cfif>
	</ft:form>
	
	<!--- SETUP THE METADATA --->
	<cfset stAllMetadata = structNew() />
	<cfloop from="1" to="#arraylen(stList.aColumns)#" index="i">
		<cfset columnName = stList.aColumns[i].property />
		<cfset stAllMetadata[columnName] = application.fapi.getPropertyMetadata(	typename="#session.fc.stList[hashID].typename#", 
																					property="#columnName#") />
	</cfloop>
	
	
	
	<grid:div>
	
		<skin:pagination qRecordSet="#qResult#" r_stobject="stobject" recordsperPage="25">
		
			<cfif stObject.bFirst>
				<cfoutput><table class="objectAdmin" style="margin-top:10px;width:100%;"></cfoutput>
				

				<cfoutput>
					<tr>
					<cfloop from="1" to="#arraylen(stList.aColumns)#" index="i">
						<th>#stList.aColumns[i].property#</th>
					</cfloop>
					</tr>
				</cfoutput>				
			</cfif>
			
			<cfoutput>
				<tr>
				<cfloop from="1" to="#arraylen(stList.aColumns)#" index="i">
					<cfset columnName = stList.aColumns[i].property />
					<cfset stAllMetadata[columnName].value = stobject[columnName] />
					<cfset fieldHTML = application.fapi.getFormtool(stAllMetadata[columnName].ftType).display(	typename="#session.fc.stList[hashID].typename#",
																												stObject="#stobject#",
																												stMetadata="#stAllMetadata[columnName]#",
																												fieldname="#columnName#" ) />
					<td>#fieldHTML#</td>
				</cfloop>
				</tr>
			</cfoutput>
			
		
			<cfif stObject.bLast>
				<cfoutput></table></cfoutput>
			</cfif>
		</skin:pagination>
	</grid:div>
	
	
	<!---<cfset csv = QueryToCSV2(qResult) />--->
	
	
	</grid:div>
	<admin:footer />
</cfif>

	
<cfscript>
/**
* Convert the query into a CSV format using Java StringBuffer Class.
*
* @param query      The query to convert. (Required)
* @param headers      A list of headers to use for the first row of the CSV string. Defaults to all the columns. (Optional)
* @param cols      The columns from the query to transform. Defaults to all the columns. (Optional)
* @return Returns a string.
* @author Qasim Rasheed (qasimrasheed@hotmail.com)
* @version 1, March 23, 2005
*/
function QueryToCSV2(query){
    var csv = createobject( 'java', 'java.lang.StringBuffer');
    var i = 1;
    var j = 1;
    var cols = "";
    var headers = "";
    var endOfLine = chr(13) & chr(10);
    if (arraylen(arguments) gte 2) headers = arguments[2];
    if (arraylen(arguments) gte 3) cols = arguments[3];
    if (not len( trim( cols ) ) ) cols = query.columnlist;
    if (not len( trim( headers ) ) ) headers = cols;
    headers = listtoarray( headers );
    cols = listtoarray( cols );
    
    for (i = 1; i lte arraylen( headers ); i = i + 1)
        csv.append( '"' & headers[i] & '",' );
    csv.append( endOfLine );
    
    for (i = 1; i lte query.recordcount; i= i + 1){
        for (j = 1; j lte arraylen( cols ); j=j + 1){
            if (isNumeric( query[cols[j]][i] ) )
                csv.append( query[cols[j]][i] & ',' );
            else
                csv.append( '"' & query[cols[j]][i] & '",' );
            
        }
        csv.append( endOfLine );
    }
    return csv.toString();
}
</cfscript>

