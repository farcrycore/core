<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Display Library --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset request.fc.inwebtop = true />

<cfif application.fapi.isLoggedIn()>
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	<cfparam name="lSelected" type="string" default=""/>
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />

	<!------------------------------------------------------------------------------------
	Loop over the url and if any url parameters match any formtool metadata (prefix 'ft'), then override the metadata.
	 ------------------------------------------------------------------------------------>
	<cfloop collection="#url#" item="md">
		<cfif left(md,2) EQ "ft" AND structKeyExists(stMetadata, md)>
			<cfset stMetadata[md] = url[md] />
		</cfif>
	</cfloop>

	<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />
	
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
			SELECT objectid AS "key"
			FROM #url.filterTypename#
			WHERE LOWER(label) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(form.searchTypename)#%" />
		</cfquery>
	</cfif>
			
	<!--- SETUP THE QUERY DATA --->
	<cfset bFoundLibraryData = false />
		
	<cfif structKeyExists(stMetadata, "ftLibraryData") AND len(stMetadata.ftLibraryData)>
		<cfif not structkeyexists(stMetadata,"ftLibraryDataTypename") or not len(stMetadata.ftLibraryDataTypename)>
			<cfset stMetadata.ftLibraryDataTypename = url.filterTypename />
		</cfif>
		
		<cfset oLibraryData = application.fapi.getContentType("#stMetadata.ftLibraryDataTypename#") />
			
		<!--- use ftlibrarydata method from primary content type --->
		<cfif structkeyexists(oLibraryData, stMetadata.ftLibraryData)>
			<cfset bFoundLibraryData = true />
			
			<cfif isdefined("qFiltered")>
				<cfinvoke component="#oLibraryData#" method="#stMetadata.ftLibraryData#" returnvariable="libraryDataResult">
					<cfinvokeargument name="primaryID" value="#stobj.objectid#" />
					<cfinvokeargument name="qFilter" value="#qFiltered#" />
				</cfinvoke>
			<cfelse>
				<cfinvoke component="#oLibraryData#" method="#stMetadata.ftLibraryData#" returnvariable="libraryDataResult">
					<cfinvokeargument name="primaryID" value="#stobj.objectid#" />
				</cfinvoke>
			</cfif>
			
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


		<cfif structKeyExists(stMetadata, "ftLibraryDataSQLWhere") and len(stMetadata["ftLibraryDataSQLWhere"])>
			<cfset SQLWhere = " #SQLWhere# AND (#stMetadata.ftLibraryDataSQLWhere#)" />
		</cfif>
		
		<cfif isdefined("qFiltered")>
			<cfif qFiltered.recordcount>
				<cfset SQLWhere = "#SQLWhere# AND objectid in ('#listchangedelims(valuelist(qFiltered.key),"','")#')" />
			<cfelse>
				<cfset SQLWhere = "#SQLWhere# AND 0=1" />
			</cfif>
		</cfif>

		<cfset SQLOrderBy = "datetimelastupdated desc" />
		<cfif structKeyExists(stMetadata, "ftLibraryDataSQLOrderBy")>
			<cfset SQLOrderBy = stMetadata.ftLibraryDataSQLOrderBy />
		</cfif>
		
		<cfset oFormTools = createObject("component", application.fc.utils.getPath(package="farcry", component="formtools"))>
		<cfset stLibraryData = oFormTools.getRecordset(typename="#url.filterTypename#", sqlColumns="objectid", sqlOrderBy="#SQLOrderBy#", SQLWhere="#SQLWhere#", RecordsPerPage="0") />
		<cfset qAll = stLibraryData.q />		
		<cfset bFoundLibraryData = true />
	</cfif>
	
	<cfset qResult = qAll />

	<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrary', urlParameters="filterTypename=#url.filterTypename#&property=#url.property#&ajaxmode=1") />
	
	<ft:form name="#stobj.typename#_#url.property#_#url.filterTypename#" bAjaxSubmission="true" action="#formAction#">		
		<grid:div style="margin:0 0 10px auto;"><!---  style="padding:5px; border: 1px solid ##CCCCCC;background-color:##f1f1f1;margin-bottom:5px; " --->
			<cfoutput>
				<div class="filter-field-wrap input-prepend input-append">
					<input type="text" placeholder="Search..." id="searchTypename-#stobj.typename#-#url.property#-#url.filterTypename#" name="searchTypename" class="textInput" value="#form.searchTypename#" style="width:250px;" />
					<cfif len(form.searchTypename)>
						<button style="height: 30px; border-radius:0; font-size: 20px; font-weight: bold; padding: 4px 10px;" onClick="$j('##searchTypename-#stobj.typename#-#url.property#-#url.filterTypename#').attr('value',''); $j('##submit-#stobj.typename#-#url.property#-#url.filterTypename#').click(); return false;" class="btn" type="button">&times;</button>
					</cfif>
					<button id="submit-#stobj.typename#-#url.property#-#url.filterTypename#" style="height: 30px; border-radius:0" class="btn" value="Submit" type="submit"><i class="fa fa-search"></i></button>
				</div>
			</cfoutput>
		</grid:div>
			
		<!--- DETERMINE THE SELECTED ITEMS --->
		<cfif isArray(stobj[url.property])>
			<cfloop array="#stobj[url.property]#"  index="i">
				<cfif isStruct(i) and StructKeyExists(i,"data")>
					<cfset lSelected = listappend(lSelected,i.data)>
				<cfelse>
					<cfset lSelected = listappend(lSelected,i)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset lSelected = stobj[url.property] />
		</cfif>
			
		<!--- DISPLAY THE SELECTION OPTIONS --->	
		<skin:pagination query="#qResult#" 
			submissionType="form"
			oddRowClass="alt"
			evenRowClass=""
			r_stObject="stCurrentRow"
  			bDisplayTotalRecords="true"
			top="false">

			<cfif stCurrentRow.bFirst>
				<cfoutput>
				<table class="farcry-objectadmin table table-striped table-hover">
				</cfoutput>
			</cfif>
				
			<cfoutput>
				<tr class="selector-wrap #stCurrentRow.currentRowClass#" style="cursor:pointer;">
					<td style="width:25px;padding:3px;">
						<cfif stMetadata.type EQ "array">
							<input type="checkbox" id="selected_#stCurrentRow.currentRow#" name="selected" class="checker" value="#stCurrentRow.objectID#" <cfif listFindNoCase(lSelected,stCurrentRow.objectid)>checked="checked"</cfif> />
						<cfelse>
							<input type="radio" id="selected_#stCurrentRow.currentRow#" name="selected" class="checker" value="#stCurrentRow.objectID#" <cfif listFindNoCase(lSelected,stCurrentRow.objectid)>checked="checked"</cfif> />
						</cfif>
					</td>
					<td style="padding:3px;">
						<skin:view objectid="#stCurrentRow.objectid#" webskin="librarySelected" bIgnoreSecurity="true" />
					</td>					
				</tr>
			</cfoutput>
			
			<cfif stCurrentRow.bLast>
				<cfoutput>
				</table>
				</cfoutput>
			</cfif>
		</skin:pagination>
				
		<cfoutput>
		<script type="text/javascript">
		$j(function(){
			fcForm.initLibrary('#stobj.typename#','#stobj.objectid#','#url.property#');
			fcForm.selections.reinitpage();
		});
		</script>
		</cfoutput>
		
	</ft:form>
</cfif>