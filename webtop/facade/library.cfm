<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  $
$TODO: $

|| DEVELOPER ||
$Developer: $

@@displayname: Type Library Picker Page
@@author: Mat Bryant (mat@daemon.com.au)
 --->


<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" >

<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm">


<cfparam name="url.primaryObjectID" default="">
<cfparam name="url.primaryTypeName" default="">
<cfparam name="url.primaryFieldName" default="">
<cfparam name="url.primaryFormFieldName" default="">
<cfparam name="url.ftJoin" default="">
<cfparam name="url.wizardID" default="">
<cfparam name="url.LibraryType" default="array">

<cfparam name="url.ftLibraryAddNewWebskin" default="libraryAdd"><!--- Method to Add New Object --->

<cfparam name="url.ftLibraryPickWebskin" default="libraryPick"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibraryPickListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibraryPickListStyle" default="">

<cfparam name="url.ftLibrarySelectedWebskin" default="librarySelected"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibrarySelectedListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibrarySelectedListStyle" default="">


<cfparam name="url.ftAllowLibraryAddNew" default=""><!--- Method to Add New Object --->
<cfparam name="url.ftAllowLibraryEdit" default=""><!--- Method to Edit Object --->


<cfparam name="url.PackageType" default="types"><!--- Could be types or rules.. --->
<cfparam name="url.currentpage" default="1">


<cfparam name="url.refreshOpener" default="false"><!--- This variable will be set if a new object is added and attached --->

	
	

<cfset PrimaryPackage = application.stcoapi[url.primaryTypeName] />
<cfset PrimaryPackagePath = application.stcoapi[url.primaryTypeName].packagepath />

<!--- TODO: dynamically determine the typename to join. --->
<cfset request.ftJoin = listFirst(url.ftJoin) />
<cfif NOT listContainsNoCase(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin,request.ftJoin)>
	<cfset request.ftJoin = listFirst(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) />
</cfif>

<cfif url.LibraryType EQ "Array" AND structKeyExists(application.stcoapi[url.PrimaryTypename].stProps[url.PrimaryFieldname].metadata, "ftInstantLibraryUpdate") >
	<cfset InstantLibraryUpdate = application.stcoapi[url.PrimaryTypename].stProps[url.PrimaryFieldname].metadata.ftInstantLibraryUpdate />
<cfelse>
	<cfset InstantLibraryUpdate = true />
</cfif>



<!--- Cleanup the Query_String so that we can paginate correctly --->
<cfscript>
	stURL = Duplicate(url);
	stURL = filterStructure(stURL,'Page,ftJoin,librarySection,refreshOpener');
	queryString=structToNamePairs(stURL);
</cfscript>


<!--- 
THE SESSION.AJAXUPDATINGARRAY VARIABLE IS USED TO KEEP TRACK OF THE SYSTEM UPDATING THE ARRAY PROPERTY IN THE BACKGROUND.
THIS IS AN ATTEMPT TO CONTROL PEOPLE UPDATING THE ARRAY WHILE IT IS STILL BEING UPDATED BY THE AJAX CALL
IT IS SET IN  AJAXUPDATEARRAY FUNCTION OF THE LIBRARY.CFC
 --->
<ft:processForm action="Force Refresh">
	<cfset session.ajaxUpdatingArray = false />
</ft:processForm>



<ft:processForm action="Save Changes" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&librarySection=attach">
	<ft:processFormObjects typename="#request.ftJoin#">
	</ft:processFormObjects><!--- Returns variables.lSavedObjectIDs --->
	
<!--- 	<cfoutput>
	#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&librarySection=attach<cfabort>
	</cfoutput> --->
</ft:processForm>



<ft:processForm action="Attach,Attach & Add Another">
	
	<ft:processFormObjects typename="#request.ftJoin#" /><!--- Returns variables.lSavedObjectIDs --->



	<cfset oPrimary = createObject("component",PrimaryPackagePath)>
	
	<cfset oData = createObject("component",application.stcoapi[request.ftJoin].packagepath)>
	

	<cfloop list="#lSavedObjectIDs#" index="DataObjectID">

	
		<cfif len(url.wizardID)>		
			
			<cfset owizard = createObject("component",application.stcoapi['dmWizard'].packagepath)>
			
			<cfset stwizard = owizard.Read(wizardID=url.wizardID)>
			
			<cfif url.LibraryType EQ "UUID">
				<cfset stwizard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = DataObjectID>
		
			<cfelse><!--- Array --->
				<cfset arrayAppend(stwizard.Data[url.PrimaryObjectID][url.PrimaryFieldname],DataObjectID)>
						
				<cfset variables.tableMetadata = createobject('component','farcry.core.packages.fourq.TableMetadata').init() />
				<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
				<cfset stFields = variables.tableMetadata.getTableDefinition() />
				
				<cfset o = createObject("component","farcry.core.packages.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
				<cfset aProps = o.createArrayTableData(tableName=url.PrimaryTypename & "_" & url.PrimaryFieldName,objectid=url.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stwizard.Data[PrimaryObjectID][url.PrimaryFieldname])>
		
				<cfset stwizard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stwizard = owizard.Write(ObjectID=url.wizardID,Data=stwizard.Data)>
			
			<cfset st = stwizard.Data[url.PrimaryObjectID]>
		<cfelse>
		
			<cfset stPrimary = oPrimary.getData(objectid=url.PrimaryObjectID)>
			
			<cfif url.LibraryType EQ "UUID">
				<cfset stPrimary[url.PrimaryFieldname] = DataObjectID>		
			<cfelse><!--- Array --->
				<cfset arrayAppend(stPrimary[url.PrimaryFieldname],DataObjectID)>
						
			</cfif>
		
			
			
			<cfparam name="session.dmSec.authentication.userlogin" default="anonymous" />
			<cfset oPrimary.setData(objectID=stPrimary.ObjectID,stProperties="#stPrimary#",user="#session.dmSec.authentication.userlogin#")>
			
		</cfif>
	</cfloop>
	
	<cfset url.refreshOpener = true />
	
</ft:processForm>


<ft:processForm action="Attach & Add Another" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&librarySection=Add&refreshOpener=#url.refreshOpener#" />

	
<ft:processForm action="Close,Cancel">
	<cfoutput>
	<script type="text/javascript">
		self.blur();
		window.close();
	</script>
	</cfoutput>
	<cfabort>
</ft:processForm>


<ft:processForm action="*" excludeAction="Search,Refresh" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&refreshOpener=#url.refreshOpener#" />



<cfparam name="session.stLibraryFilter" default="#structNew()#" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#']" default="#structNew()#" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#'].Criteria" default="" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#'].qResults" default="#queryNew('objectid')#" />

<ft:processForm action="Search">

	<cfset session.stLibraryFilter['#request.ftJoin#'].Criteria = lCase(form.criteria) />

</ft:processForm>


<ft:processForm action="Refresh">
	<cfset session.stLibraryFilter[request.ftJoin] = structNew() />
	<cfset session.stLibraryFilter[request.ftJoin].Criteria = "" />
	<cfset session.stLibraryFilter[request.ftJoin].qResults = queryNew("objectid") />
</ft:processForm>

<cfif len(session.stLibraryFilter[request.ftJoin].Criteria)>
	<cfset filterCriteria = session.stLibraryFilter[request.ftJoin].Criteria />
	<!--- <cfsearch collection="#application.applicationName#_#request.ftJoin#" criteria="#filterCriteria#" name="qSearchResults" type="internet"  /> --->
	<cfif lcase(application.dbtype) EQ "mssql"> <!--- Dodgy MS SQL only code --->
		<cfquery datasource="#application.dsn#" name="qSearchResults">
			SELECT objectID as [key] , label FROM #application.dbowner#[#request.ftJoin#]	
			WHERE label like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#filterCriteria#%">
			Order by label
		</cfquery>
	<cfelse> <!--- Dirty hack to get this query working for MySQL and possibly Postgres --->
		<cfquery datasource="#application.dsn#" name="qSearchResults">
			SELECT objectID as `key` , label FROM #application.dbowner#`#request.ftJoin#`	
			WHERE label like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#filterCriteria#%">
			Order by label
		</cfquery>
	</cfif>

	<cfif NOT qSearchResults.RecordCount>
		<cfoutput><h3>No Results matched search. All records have been returned</h3></cfoutput>
		<cfset session.stLibraryFilter['#request.ftJoin#'].qResults = queryNew("objectid,label") />
		
	<cfelse>
		<cfif qSearchResults.RecordCount GT 100>
			<cfoutput><h3>#qSearchResults.RecordCount# results matched search. Results have been limited to 100.</h3></cfoutput>
			
			<cfquery dbtype="query" name="qSearchResults" maxrows="100">
			SELECT * FROM qSearchResults
			</cfquery>
			
		</cfif>
		
		<cfset session.stLibraryFilter['#request.ftJoin#'].qResults = qSearchResults />
	</cfif>
</cfif>

<admin:Header Title="Library" bodyclass="popup imagebrowse library" bCacheControl="false">



<cfset oPrimary = createObject("component",PrimaryPackagePath)>
<cfset oData = createObject("component",application.stcoapi[request.ftJoin].packagepath)>
<cfset stPrimary = oPrimary.getData(objectid=url.primaryObjectID, bArraysAsStructs=true)>

<cfset lBasketIDs = "" />
<cfif URL.LibraryType EQ "array">
	<cfquery datasource="#application.dsn#" name="q">
	SELECT * FROM #url.primaryTypeName#_#url.primaryFieldName#
	WHERE parentID = '#url.primaryObjectID#'
	</cfquery>
	
	<cfloop query="q">	
		<cfset lBasketIDs = listAppend(lBasketIDs, "#q.data#:#q.seq#") />
	</cfloop>
<cfelse>
	<cfset lBasketIDs = stPrimary[url.primaryFieldName] />
</cfif>

<!-------------------------------------------------------------------------- 
LIBRARY DATA
	- generate library data query to populate library interface 
--------------------------------------------------------------------------->


<cfset stLibraryData = structNew() />

		
<cfif isDefined("url.ftLibraryData") AND len(url.ftLibraryData)>	
	
	<cfparam name="url.ftLibraryDataTypename" default="#url.ftJoin#" />
	
	<cfset oLibraryData = createObject("component", application.stcoapi[url.ftLibraryDataTypename].packagePath) />

	<cfif structkeyexists(oLibraryData, url.ftLibraryData)>
		<cfinvoke component="#oLibraryData#" method="#url.ftLibraryData#" returnvariable="LibraryDataResult">
			<cfinvokeargument name="primaryID" value="#url.primaryObjectID#">
			<cfinvokeargument name="qFilter" value="#session.stLibraryFilter[request.ftJoin].qResults#">
		</cfinvoke>
	
		<!---
		The return variable from the LibraryData function can either be a basic query 
		or structure that contains only the page of date as returned by the getRecordSet function in core
		 --->
		 
		<cfif isQuery(libraryDataResult)>
			<cfset stLibraryData.q = libraryDataResult />
			<cfset stLibraryData.recordsPerPage = 20 />
			
			<cfset stLibraryData.CountAll = stLibraryData.q.RecordCount />
			<cfset stLibraryData.currentPage = URL.currentPage />
		<cfelseif structKeyExists(libraryDataResult, "q")>
			<cfset stLibraryData = LibraryDataResult />
		</cfif>
<!---		
		<cfif structKeyExists(session.stLibraryFilter[request.ftJoin], "qResults") AND session.stLibraryFilter[request.ftJoin].qResults.recordCount AND qLibraryData.recordCount>
			<cfset qFilter = session.stLibraryFilter[request.ftJoin].qResults />
			<cfset FilterList = valuelist(qFilter.key) />

	
			<cfquery dbType="query" name="qLibraryData">
			select * from qLibraryData
			where objectid IN (#ListQualify(FilterList,"'")#)
			</cfquery>
		</cfif>

		<cfset stLibraryData.q = qLibraryData />
		<cfset stLibraryData.recordsPerPage = 20 />
		<cfset stLibraryData.CountAll = qLibraryData.recordCount /> --->
	</cfif>
	
</cfif>

<!--- if nothing exists to generate library data then cobble something together --->
<cfif structIsEmpty(stLibraryData)>
	
	<cfset SQLWhere = "1=1" />
	
	<cfif structKeyExists(PrimaryPackage.stProps[url.primaryFieldName].Metadata, "ftLibraryDataSQLWhere")>
		<cfset SQLWhere = " #SQLWhere# AND (#PrimaryPackage.stProps[url.primaryFieldName].Metadata.ftLibraryDataSQLWhere#)" />
	</cfif>
	
	<cfif structKeyExists(session.stLibraryFilter[request.ftJoin], "qResults") AND session.stLibraryFilter[request.ftJoin].qResults.recordCount>
		<cfset qFilter = session.stLibraryFilter[request.ftJoin].qResults />
		<cfset FilterList = valuelist(qFilter.key) />
		<cfset SQLWhere = " "&SQLWhere&" AND objectid IN ("&ListQualify(FilterList,"'")&")" />
	</cfif>
	
	<cfset SQLOrderBy = "datetimelastupdated desc" />
	<cfif structKeyExists(PrimaryPackage.stProps[url.primaryFieldName].Metadata, "ftLibraryDataSQLOrderBy")>
		<cfset SQLOrderBy = PrimaryPackage.stProps[url.primaryFieldName].Metadata.ftLibraryDataSQLOrderBy />
	</cfif>
	
	<cfset oFormTools = createObject("component","farcry.core.packages.farcry.formtools")>
	<cfset stLibraryData = oFormTools.getRecordset(typename="#request.ftJoin#", sqlColumns="*", sqlOrderBy="#SQLOrderBy#", SQLWhere="#SQLWhere#", RecordsPerPage="20") />

	
	<!--- <cfinvoke component="#oData#" method="getLibraryData" returnvariable="qLibraryList" /> --->
	
</cfif>

<!--- <cfif listLen(lBasketIDs)>
	<cfquery dbtype="query" name="qLibraryList">
	SELECT * FROM qLibraryList
	WHERE ObjectID NOT IN (#ListQualify(lBasketIDs,"'")#)
	</cfquery>
</cfif> --->

<!--- Put JS and CSS for TabStyle1 into the header --->
<cfset Request.InHead.TabStyle1 = 1>


<cfif listLen(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) GT 1>
	<ft:form>
	
	
	</ft:form>
</cfif>

<cfoutput>
	<br style="clear:both;" />
</cfoutput>


<ft:form>
	<cfoutput>
	<table>
	<tr>
		<td>
			<select name="ftJoin" id="ftJoin" onchange="javascript:window.location='#cgi.script_name#?#querystring#&ftJoin=' + this[selectedIndex].value;">
				<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">
					<option value="#i#" <cfif url.ftJoin EQ i>selected</cfif>>#application.stcoapi[i].displayname# Library</option>
				</cfloop>
			</select>
		</td>
		<td>Search: <input type="text" name="criteria" id="criteria" value="#session.stLibraryFilter[request.ftJoin].Criteria#" /></td>
		<td>
			<ft:farcryButton value="Search" />
			<ft:farcryButton value="Refresh" />
		</td>
	</tr>
	</table>
	</cfoutput>
</ft:form>





	
	

	
<cfparam name="url.librarySection" default="attach" />
	

	
<cfif url.librarySection EQ "attach">

	
	<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />


	<cfset libraryPickerHTML = libraryPicker() />
	<cfoutput>
	<div id="container1" class="tab-container">
		<ul class="tabs">
			<li id="tab1" class="tab-active"><a href="##" onclick="return false;">Attach</a></li>
			<cfif listFindNoCase(url.ftAllowLibraryAddNew,request.ftJoin)><li id="tab2" class="tab-disabled"><a href="#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=addnew">Add New</a></li></cfif>
		</ul>
		
		<div class="tab-panes">
			<div id="pane1">	
				
				
					#libraryPickerHTML#
				
		
									
			</div>
		</div>
	</div>
	</cfoutput>


<cfelseif url.librarySection EQ "edit" AND listFindNoCase(url.ftAllowLibraryEdit,request.ftJoin) AND structKeyExists(url, "editObjectID")>

	<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />

	<cfoutput>
	<div id="container1" class="tab-container">
		<ul class="tabs">
			<li id="tab2" class="tab-active"><a href="##" onclick="return false;">Edit</a></li>
		</ul>
		
		<div class="tab-panes">
			<div id="pane2">		
	</cfoutput>
	
				<ft:form>
				
					<cfset stparam = structNew() />
					<cfset stparam.stPrimary = stPrimary />
					<cfset HTML = oData.getView(objectid="#url.editObjectID#", template="#url.ftLibraryAddNewWebskin#", alternateHTML="", stparam=stparam) />	
						
					<cfif len(HTML)>
						<cfoutput>#HTML#</cfoutput>
					<cfelse>
						<ft:object objectID="#url.editObjectID#" lfields="" inTable=0 />
					</cfif>
					
					<cfoutput>
					<div>
						<ft:farcryButton value="Save Changes" />	
						<ft:farcryButton type="button" value="Close" onclick="self.blur();window.close();" />	
					</div>
					</cfoutput>
					
				</ft:form>
	
	<cfoutput>		
			</div>
		</div>
	</div>
	</cfoutput>
	
<cfelseif listFindNoCase(url.ftAllowLibraryAddNew,request.ftJoin)>

	<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />

	<cfoutput>
	<div id="container1" class="tab-container">
		<ul class="tabs">
			<li id="tab1" class="tab-disabled"><a href="#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=attach">Attach</a></li>
			<li id="tab2" class="tab-active"><a href="##" onclick="return false;">Add New</a></li>
		</ul>
		
		<div class="tab-panes">
			<div id="pane2">		
	</cfoutput>
	
				<ft:form>
				
					<cfset stparam = structNew() />
					<cfset stparam.stPrimary = stPrimary />
					<cfset HTML = oData.getView(template="#url.ftLibraryAddNewWebskin#", alternateHTML="", stparam=stparam) />	
						
					<cfif len(HTML)>
						<cfoutput>#HTML#</cfoutput>
					<cfelse>
					
						<cfset stNew = oData.getData(objectid=createUUID()) />
					
						<cfset qMetadata = application.stcoapi[request.ftJoin].qMetadata >
		
						<cfquery dbtype="query" name="qFieldSets">
						SELECT ftwizardStep, ftFieldset
						FROM qMetadata
						WHERE ftFieldset <> '#request.ftJoin#'
						AND ftType <> 'uuid'
						AND ftType <> 'array'
						Group By ftwizardStep, ftFieldset
						ORDER BY ftSeq
						</cfquery>				
														
						<cfif qFieldSets.recordcount GTE 1>
							
							<cfloop query="qFieldSets">
								<cfquery dbtype="query" name="qFieldset">
								SELECT *
								FROM qMetadata
								WHERE ftFieldset = '#qFieldsets.ftFieldset#'
								AND ftType <> 'uuid'
								AND ftType <> 'array'
								ORDER BY ftSeq
								</cfquery>
								
								<ft:object objectid="#stNew.objectid#" typename="#request.ftJoin#" format="edit"  lFields="#valuelist(qFieldset.propertyname)#" inTable=false IncludeFieldSet=1 Legend="#qFieldSets.ftFieldset#" />
							</cfloop>
							
							
						<cfelse>
						
							<!--- default edit handler --->
							<ft:object objectid="#stNew.objectid#" typename="#request.ftJoin#" format="edit"  lFields="" IncludeFieldSet=1 Legend="ADD NEW" />
							
						</cfif>
							
							
					
					</cfif>
					
					<cfoutput>
					<div>
						<ft:farcryButton value="Attach" />	
						<ft:farcryButton type="button" value="Close" onclick="self.blur();window.close();" />	
					</div>
					</cfoutput>
					
				</ft:form>
	
	
			<skin:htmlHead library="ScriptaculousEffects" />
			<skin:htmlHead library="ScriptaculousDragAndDrop" />
			
			<cfoutput>
			

			<script type="text/javascript">
			 
				
				<cfif URL.LibraryType EQ "array">
							
					//call on initial page load
					opener.libraryCallbackArray('#url.primaryFormFieldname#', 'sort','#lBasketIDs#','#application.url.webroot#');
					
					
				<cfelse>
					<cfif len(stPrimary[url.primaryFieldName]) >
						//call on initial page load
						opener.libraryCallbackUUID('#url.primaryFormFieldname#', 'add','#stPrimary[url.primaryFieldName]#','#application.url.webroot#');
					</cfif>
				</cfif>
				
		
			 </script>
			</cfoutput>
			
			
				
	<cfoutput>		
			</div>
		</div>
	</div>
	</cfoutput>
	
	
</cfif>
	

	
	

<admin:footer>



	
	

<!---------------------------------------------------------
GENERATE THE LIBRARY PICKER
 --------------------------------------------------------->	
 
<cffunction name="libraryPicker" access="private" output="false" returntype="string" hint="GENERATE THE LIBRARY PICKER">
	<cfset var returnString = "" />
	<cfset var stJoinObjects = structNew() />
	<cfset var stCurrentArrayItem = structNew() />
	<cfset var HTML = "" />
	<cfset var stTemp = structNew() />
	<cfset var stLibraryObject = structNew() />
	<cfset var tmpTypename = '' />
	
	<cfset Request.InHead.FormsCSS = true />
		
	<cfsavecontent variable="returnString">
		
		<ft:form>
	
			<!--- Create each of the the Linked Table Types as an object  --->
			<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">		
				<cfset stJoinObjects[i] = createObject("component",application.stcoapi[i].packagepath)>
			</cfloop>
		
			
			<cfoutput>
			<table border="3" style="width:100%;">
			</cfoutput>


			<!--- 
			IF THE SESSION.AJAXUPDATINGARRAY VARIABLE IS SET AND TRUE IT MEANS THE AJAX UPDATE IS STILL RUNNING. THIS IS POSSIBLE IN VERY LONG ARRAYS.
			 --->
			<cfif structKeyExists(session, "ajaxUpdatingArray") AND session.ajaxUpdatingArray EQ true>
				<tr>
					<td colspan="2">
						<ft:farcryButtonPanel>
							<ft:farcryButton value="Still Updating... Try Again" url="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" />
							<ft:farcryButton value="Force Refresh" confirmText="Are you sure you want to force the refresh" />
						</ft:farcryButtonPanel>
					</td>
				</tr>
			<cfelse>
			
				<cfoutput>
				<tr>
					<td style="width:50%;"><h3>Selected <cfif URL.LibraryType EQ "UUID"><em>(only 1 permitted)</em></cfif></h3></td>
					<td style="width:50%;"><h3>Drag To Select</h3></td>
				</tr>
				<tr>
					<td style="background-color:##FFEBD7;" id="sortableListTo" class="arrayDetailView">
						
						
						
						
					<!--- 
					<cfif URL.LibraryType EQ "array">
						 <div id="sortableListTo" class="arrayDetailView" style="background-color:##F1F1F1;height:100% !important;border:1px solid red;"> 
					<cfelse>
						 <div id="sortableListTo" style="background-color:##F1F1F1;min-height:500px;_height:500px;"> 
					</cfif>	 
					--->
			
				</cfoutput>	
				
				
						<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />
	
						
					
						<cfif URL.LibraryType EQ "array">
							<cfloop from="1" to="#arrayLen(stPrimary[url.primaryFieldName])#" index="i">
								
								<cfset stCurrentArrayItem = stPrimary[url.primaryFieldName][i] />
								<cfset HTML = '' />
	
								<!--- if typename is missing from query (ie. array data is corrupted) --->
								<cfif NOT len(stCurrentArrayItem.typename)>
									<cfset tmpTypename=createobject("component", "farcry.core.packages.fourq.fourq").findtype(objectid=stCurrentArrayItem.data) />
									<cfset stCurrentArrayItem.typename = tmpTypename />
									<cfif NOT len(tmpTypename)>
										<cfset HTML = "Object Not Found">
									</cfif>
								</cfif>	
	
								<cfif NOT Len(trim(HTML))>
									<cfset HTML = stJoinObjects[stCurrentArrayItem.typename].getView(objectid=stCurrentArrayItem.data, template="librarySelected", alternateHTML="") />
									<cfif NOT len(trim(HTML))>
										<cfset stTemp = stJoinObjects[stCurrentArrayItem.typename].getData(objectid=stCurrentArrayItem.data) />
										<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
											<cfset HTML = stTemp.label />
										<cfelse>
											<cfset HTML = stTemp.objectid />
										</cfif>
									</cfif>
								</cfif>
								<!------------------------------------------------------------------------
								THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
								BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
								 ------------------------------------------------------------------------->			
								<cfoutput>
								<div id="sortableListTo_#stCurrentArrayItem.data#:#stCurrentArrayItem.seq#" class="sortableHandle">
									<div class="arrayDetail">
										<div>
											#HTML#
											<!--- <cfif listFindNoCase(url.ftAllowLibraryEdit,stCurrentArrayItem.typename)>
											
												<cfset editLink = "#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=edit&editObjectid=#stCurrentArrayItem.data#" />
												<span  style="border:1px solid red;"><a href="#editLink#">edit</a></span>
											</cfif> --->
										</div>
									</div>								
								</div>
								</cfoutput>
							</cfloop>
						<cfelse>
							<cfif listLen(lBasketIDs)>
							
	
								<cfset HTML = oData.getView(objectid=stPrimary[url.primaryFieldName], template="librarySelected", alternateHTML="") />
								<cfif NOT len(trim(HTML))>
									<cfset stTemp = oData.getData(objectid=stPrimary[url.primaryFieldName]) />
									<cfif structKeyExists(stTemp, "label") AND len(stTemp.label)>
										<cfset HTML = stTemp.label />
									<cfelse>
										<cfset HTML = stTemp.objectid />
									</cfif>
								</cfif>		
								<!------------------------------------------------------------------------
								THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
								BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
								 ------------------------------------------------------------------------->			
								<cfoutput>
								<div>
									#HTML#
									<!--- <cfif listFindNoCase(url.ftAllowLibraryEdit,request.ftJoin)>								
										<cfset editLink = "#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=edit&editObjectid=#stPrimary[url.primaryFieldName]#" />
										<div><a href="#editLink#">edit</a></div>
									</cfif> --->
									
								</div>
								</cfoutput>
							</cfif>
						</cfif>
						
					
					<cfoutput>
					<!--- </div> --->
					</td>
					<td>
					</cfoutput>	
							
						
						<ft:pagination qRecordSet="#stLibraryData.q#" typename="#request.ftJoin#" submissionType="URL" recordsPerPage="#stLibraryData.recordsPerPage#" totalRecords="#stLibraryData.CountAll#" pageLinks="5" top="true" bottom="true">
						<!--- <ft:pagination qRecordSet="#stLibraryData.q#" typename="#request.ftJoin#" submissionType="URL" recordsPerPage="#stLibraryData.recordsPerPage#" totalRecords="#stLibraryData.CountAll#" currentpage="#stLibraryData.currentPage#" pageLinks="5" top="true" bottom="true"> --->
						<cfoutput>
							<div id="sortableListFrom" class="arrayDetailView" style="border:1px solid ##F1F1F1;min-height:500px;_height:500px;">
						</cfoutput>
							
								<ft:paginateLoop r_stObject="stLibraryObject" bTypeAdmin="false">
			<!--- 					<ft:paginateLoop r_stObject="stLibraryObject" bTypeAdmin="false" recordsPerPage="#stLibraryData.recordsPerPage#"> --->
								<!---<ws:paginateRecords r_stRecord="stObject"> --->
									<cfif isDefined("stLibraryObject.stObject.label") AND len(stLibraryObject.stObject.label)>
										<cfset variables.alternateHTML = stLibraryObject.stObject.Label />
									<cfelse>
										<cfset variables.alternateHTML = stLibraryObject.stObject.ObjectID />
									</cfif>					
									<cfset HTML = oData.getView(stObject=stLibraryObject.stObject, template="librarySelected", alternateHTML=variables.alternateHTML) />
											
									<!------------------------------------------------------------------------
									THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
									BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
									 ------------------------------------------------------------------------->			
									<cfoutput>
										<cfif URL.LibraryType EQ "array">
											<div id="sortableListFrom_#stLibraryObject.stObject.ObjectID#" class="sortableHandle">
										<cfelse>
											<div id="#stLibraryObject.stObject.ObjectID#" class="sortableHandle">
										</cfif>
											<div class="arrayDetail">
												<p>#HTML#</p>
											</div>								
										</div>
									</cfoutput>
								<!---</ws:paginateRecords> --->
								</ft:paginateLoop>
								
						<cfoutput>
							</div>
						</cfoutput>
							
						</ft:pagination>
				<cfoutput>			
					</td>
				</tr>
			</cfoutput>
			
			
			</cfif>
			
			<cfoutput>
			</table>
			</cfoutput>
				
			
			<cfif structKeyExists(session, "ajaxUpdatingArray") AND session.ajaxUpdatingArray EQ true>	
				<!--- do nothing --->
			<cfelse>
				<cfif NOT InstantLibraryUpdate >
					<ft:farcryButtonPanel indentForLabel="false">
						<ft:farcryButton type="button" value="Save & Close" confirmText="You are about to save your changes. Please wait until the library window closes." onclick="needToConfirm = false;$(this).disabled=true;opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'),'#application.url.webroot#',window);" />
						<ft:farcryButton type="button" value="Cancel" confirmText="Are you sure you want to cancel?" onclick="needToConfirm = false;self.blur();window.close();return false;" />
					</ft:farcryButtonPanel>	
				<cfelse>
					<ft:farcryButtonPanel indentForLabel="false">
						<ft:farcryButton type="button" value="Close" onclick="self.blur();window.close();return false;" />	
					</ft:farcryButtonPanel>	
				</cfif>	
			</cfif>
			
			<skin:htmlHead library="ScriptaculousEffects" />
			<skin:htmlHead library="ScriptaculousDragAndDrop" />
			
			<cfoutput>
			<script type="text/javascript">
				<cfif NOT InstantLibraryUpdate >
					  var needToConfirm = false;
					
					  window.onbeforeunload = confirmExit;
					  function confirmExit()
					  {
					    if (needToConfirm)
					     opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'),'#application.url.webroot#');
					     needToConfirm = false;
					  }
				</cfif>
			 // <![CDATA[
				Sortable.create("sortableListFrom",{
					dropOnEmpty:true,
					tag:'div',
					containment:["sortableListFrom","sortableListTo"],
					constraint:false
				});
				
				<cfif URL.LibraryType EQ "array">
					Sortable.create("sortableListTo",{
						dropOnEmpty:true,
						tag:'div',
						containment:["sortableListFrom","sortableListTo"],
						constraint:false,
						onUpdate:function(element) {
							<cfif InstantLibraryUpdate >
								opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'),'#application.url.webroot#');
							<cfelse>
								needToConfirm = true;
							</cfif>							
							new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
						}
					});
					
					<cfif url.refreshOpener>
						//call on initial page load
						opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'),'#application.url.webroot#');
					</cfif>
					
				<cfelse>
				
					Droppables.add('sortableListTo', {
					   onDrop: function(element) {
					   		$('sortableListTo').innerHTML = $(element).innerHTML;
					   		opener.libraryCallbackUUID('#url.primaryFormFieldname#','add',$(element).id,'#application.url.webroot#');
							new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
		
					   }
					}); 
					<cfif len(stPrimary[url.primaryFieldName]) >
						//call on initial page load						
						opener.libraryCallbackUUID('#url.primaryFormFieldname#','add','#stPrimary[url.primaryFieldName]#','#application.url.webroot#');
					</cfif>
				</cfif>
				
		
			 </script>
			</cfoutput>
		
		</ft:form>	
		
					
	</cfsavecontent>

	
	<cfreturn returnString />


</cffunction>


	



<cfsetting enablecfoutputonly="no">