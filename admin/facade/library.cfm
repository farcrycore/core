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


<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets" >
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin" >

<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">


<cfparam name="url.primaryObjectID" default="">
<cfparam name="url.primaryTypeName" default="">
<cfparam name="url.primaryFieldName" default="">
<cfparam name="url.primaryFormFieldName" default="">
<cfparam name="url.ftJoin" default="">
<cfparam name="url.WizzardID" default="">
<cfparam name="url.LibraryType" default="array">

<cfparam name="url.ftLibraryAddNewWebskin" default="libraryAdd"><!--- Method to Add New Object --->

<cfparam name="url.ftLibraryPickWebskin" default="libraryPick"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibraryPickListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibraryPickListStyle" default="">

<cfparam name="url.ftLibrarySelectedWebskin" default="librarySelected"><!--- Method to Pick Existing Objects --->
<cfparam name="url.ftLibrarySelectedListClass" default="thumbNailsWrap">
<cfparam name="url.ftLibrarySelectedListStyle" default="">

<cfparam name="url.ftAllowLibraryAddNew" default="true"><!--- Method to Add New Object --->

<cfparam name="url.PackageType" default="types"><!--- Could be types or rules.. --->



	
<cfif url.PackageType EQ "rules">
	<cfset PrimaryPackage = application.rules[url.primaryTypeName] />
	<cfset PrimaryPackagePath = application.rules[url.primaryTypeName].rulepath />
<cfelse>
	<cfset PrimaryPackage = application.types[url.primaryTypeName] />
	<cfset PrimaryPackagePath = application.types[url.primaryTypeName].typepath />
</cfif>

<!--- TODO: dynamically determine the typename to join. --->
<cfset request.ftJoin = listFirst(url.ftJoin) />
<cfif NOT listContainsNoCase(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin,request.ftJoin)>
	<cfset request.ftJoin = listFirst(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) />
</cfif>






<!--- Cleanup the Query_String so that we can paginate correctly --->
<cfscript>
	stURL = Duplicate(url);
	stURL = filterStructure(stURL,'Page,ftJoin');
	queryString=structToNamePairs(stURL);
</cfscript>




<ft:processForm action="Attach,Attach & Add Another">
	
	<ft:processFormObjects typename="#request.ftJoin#" /><!--- Returns variables.lSavedObjectIDs --->



	<cfset oPrimary = createObject("component",PrimaryPackagePath)>
	
	<cfset oData = createObject("component",application.types[request.ftJoin].typepath)>
	

	<cfloop list="#lSavedObjectIDs#" index="DataObjectID">

	
		<cfif len(url.WizzardID)>		
			
			<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath)>
			
			<cfset stWizzard = oWizzard.Read(wizzardID=url.WizzardID)>
			
			<cfif url.LibraryType EQ "UUID">
				<cfset stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = DataObjectID>
		
			<cfelse><!--- Array --->
				<cfset arrayAppend(stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname],DataObjectID)>
						
				<cfset variables.tableMetadata = createobject('component','farcry.fourq.TableMetadata').init() />
				<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
				<cfset stFields = variables.tableMetadata.getTableDefinition() />
				
				<cfset o = createObject("component","farcry.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
				<cfset aProps = o.createArrayTableData(tableName=url.PrimaryTypename & "_" & url.PrimaryFieldName,objectid=url.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stWizzard.Data[PrimaryObjectID][url.PrimaryFieldname])>
		
				<cfset stWizzard.Data[url.PrimaryObjectID][url.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stWizzard = oWizzard.Write(ObjectID=url.WizzardID,Data=stWizzard.Data)>
			
			<cfset st = stWizzard.Data[url.PrimaryObjectID]>
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
	
</ft:processForm>


	
<ft:processForm action="Close,Cancel">
	<cfoutput>
	<script type="text/javascript">
		self.blur();
		window.close();
	</script>
	</cfoutput>
	<cfabort>
</ft:processForm>

<ft:processForm action="Attach & Add Another" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#&librarySection=Add" />

<ft:processForm action="*" excludeAction="Search,Refresh" url="#cgi.script_name#?#querystring#&ftJoin=#request.ftJoin#" />



<cfparam name="session.stLibraryFilter" default="#structNew()#" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#']" default="#structNew()#" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#'].Criteria" default="" />
<cfparam name="session.stLibraryFilter['#request.ftJoin#'].qResults" default="#queryNew('objectid')#" />

<ft:processForm action="Search">

	<cfset session.stLibraryFilter['#request.ftJoin#'].Criteria = form.criteria />

</ft:processForm>


<ft:processForm action="Refresh">
	<cfset session.stLibraryFilter[request.ftJoin] = structNew() />
	<cfset session.stLibraryFilter[request.ftJoin].Criteria = "" />
	<cfset session.stLibraryFilter[request.ftJoin].qResults = queryNew("objectid") />
</ft:processForm>

<cfif len(session.stLibraryFilter[request.ftJoin].Criteria)>
	<cfset filterCriteria = session.stLibraryFilter[request.ftJoin].Criteria />
	<cfsearch collection="#application.applicationName#_#request.ftJoin#" criteria="#filterCriteria#" name="qSearchResults" type="internet" />
	

	
	<cfif NOT qSearchResults.RecordCount>
		<cfoutput><h3>No Results matched search. All records have been returned</h3></cfoutput>
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
<cfset oData = createObject("component",application.types[request.ftJoin].typepath)>
<cfset stPrimary = oPrimary.getData(objectid=url.primaryObjectID, bArraysAsStructs=true)>


<cfif URL.LibraryType EQ "array">
	<cfquery datasource="#application.dsn#" name="q">
	SELECT * FROM #url.primaryTypeName#_#url.primaryFieldName#
	WHERE parentID = '#url.primaryObjectID#'
	</cfquery>
		
	<cfset lBasketIDs = valueList(q.data) />
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
	
	<cfif structKeyExists(application.types, url.ftLibraryDataTypename)>
		<cfset oLibraryData = createObject("component", application.types[url.ftLibraryDataTypename].packagePath) />
	<cfelse>
		<cfset oLibraryData = createObject("component", application.rules[url.ftLibraryDataTypename].packagePath) />
	</cfif>

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
			<cfset stLibraryData.CountAll = libraryDataResult.recordCount />
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
		<cfset SQLWhere = " #SQLWhere# AND objectid IN (#ListQualify(FilterList,"'")#)" />
	</cfif>
	
	<cfset SQLOrderBy = "datetimelastupdated desc" />
	<cfif structKeyExists(PrimaryPackage.stProps[url.primaryFieldName].Metadata, "ftLibraryDataSQLOrderBy")>
		<cfset SQLOrderBy = PrimaryPackage.stProps[url.primaryFieldName].Metadata.ftLibraryDataSQLOrderBy />
	</cfif>
	
	<cfset oFormTools = createObject("component","farcry.farcry_core.packages.farcry.formtools")>
	<cfset stLibraryData = oFormTools.getRecordset(typename="#request.ftJoin#", sqlColumns="*", sqlOrderBy="#SQLOrderBy#", SQLWhere="#SQLWhere#", RecordsPerPage="20") />

	
	<!---<cfinvoke component="#oData#" method="getLibraryData" returnvariable="qLibraryList" /> --->
	
</cfif>

<!---<cfif listLen(lBasketIDs)>
	<cfquery dbtype="query" name="qLibraryList">
	SELECT * FROM qLibraryList
	WHERE ObjectID NOT IN (#ListQualify(lBasketIDs,"'")#)
	</cfquery>
</cfif> --->

<!--- Put JS and CSS for TabStyle1 into the header --->
<cfset Request.InHead.TabStyle1 = 1>


<cfoutput><h1>#application.types[request.ftJoin].displayname# Library...</h1></cfoutput>


<cfif listLen(PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin) GT 1>
	<ft:form>
	
	<cfoutput>
		Change To: 
		<select name="ftJoin" id="ftJoin" onchange="javascript:window.location='#cgi.script_name#?#querystring#&ftJoin=' + this[selectedIndex].value;"></cfoutput>
		<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">
			<cfoutput><option value="#i#" <cfif url.ftJoin EQ i>selected</cfif>>#application.types[i].displayname#</option></cfoutput>
		</cfloop>
	<cfoutput></select></cfoutput>
	
	</ft:form>
</cfif>



<cfif structKeyExists(application.config.verity, "CONTENTTYPE") AND structKeyExists(application.config.verity.CONTENTTYPE,request.ftJoin)>
	
	<cfoutput><div></cfoutput>



	
	
	<ft:form>
		<cfoutput><input type="text" name="criteria" id="criteria" value="#session.stLibraryFilter[request.ftJoin].Criteria#" /></cfoutput>
		<ft:farcrybutton value="Search" />
		<ft:farcrybutton value="Refresh" />
	</ft:form>
	
	
	<cfoutput></div></cfoutput>
	
</cfif>

<cfoutput>
	<br style="clear:both;" />
	<br style="clear:both;" />
</cfoutput>


	
	

	
<cfparam name="url.librarySection" default="attach" />
	

	
<cfif url.librarySection EQ "attach">

	
	<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />


	<cfset libraryPickerHTML = libraryPicker() />
	<cfoutput>
	<div id="container1" class="tab-container">
		<ul class="tabs">
			<li id="tab1" class="tab-active"><a href="##" onclick="return false;">Attach</a></li>
			<cfif url.ftAllowLibraryAddNew><li id="tab2" class="tab-disabled"><a href="#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=addnew">Add New</a></li></cfif>
		</ul>
		
		<div class="tab-panes">
			<div id="pane1">	
				
				
					#libraryPickerHTML#
				
		
									
			</div>
		</div>
	</div>
	</cfoutput>


	
<cfelseif url.librarySection EQ "edit">

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
					<cfset HTML = oData.getView(template="#url.ftLibraryAddNewWebskin#", alternateHTML="", stparam=stparam) />	
						
					<cfif len(HTML)>
						<cfoutput>#HTML#</cfoutput>
					<cfelse>
						<ft:object typename="#request.ftJoin#" lfields="" inTable=0 />
					</cfif>
					
					<cfoutput>
					<div>
						<ft:farcrybutton value="Attach" />	
						<ft:farcrybutton type="button" value="Close" onclick="self.blur();window.close();" />	
					</div>
					</cfoutput>
					
				</ft:form>
	
	<cfoutput>		
			</div>
		</div>
	</div>
	</cfoutput>
	
<cfelse>

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
						<ft:object typename="#request.ftJoin#" lfields="" inTable=0 />
					</cfif>
					
					<cfoutput>
					<div>
						<ft:farcrybutton value="Attach" />	
						<ft:farcrybutton type="button" value="Close" onclick="self.blur();window.close();" />	
					</div>
					</cfoutput>
					
				</ft:form>
	
	
	
			<cfset Request.InHead.ScriptaculousEffects = 1>
			<cfoutput>
			

			<script type="text/javascript">
			 
				
				<cfif URL.LibraryType EQ "array">
							
					//call on initial page load
					opener.libraryCallbackArray('#url.primaryFormFieldname#', 'sort','#lBasketIDs#');
					
					
				<cfelse>
					<cfif len(stPrimary[url.primaryFieldName]) >
						//call on initial page load
						opener.libraryCallbackUUID('#url.primaryFormFieldname#', 'add','#stPrimary[url.primaryFieldName]#');
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
	
	<cfset Request.InHead.FormsCSS = true />
		
	<cfsavecontent variable="returnString">
		
		<ft:form>
	
			<!--- Create each of the the Linked Table Types as an object  --->
			<cfloop list="#PrimaryPackage.stProps[url.primaryFieldname].metadata.ftJoin#" index="i">		
				<cfset stJoinObjects[i] = createObject("component",application.types[i].typepath)>
			</cfloop>
		
			
			<cfoutput>
			<table border="1" style="width:100%">
			<tr>
				<td style="width:50%">
					<h3>Selected <cfif URL.LibraryType EQ "UUID"><em>(only 1 permitted)</em></cfif></h3>
					
					
					
				
				<cfif URL.LibraryType EQ "array">
					<ul id="sortableListTo" class="arrayDetailView" style="background-color:##F1F1F1;min-height:500px;_height:500px;">
				<cfelse>
					<div id="sortableListTo" style="background-color:##F1F1F1;min-height:500px;_height:500px;">
				</cfif>	
		
			</cfoutput>	
			
			
<cfset variables.QueryString = structToNamePairs(filterStructure(Duplicate(url), "librarySection")) />

					
				
					<cfif URL.LibraryType EQ "array">
						<cfloop from="1" to="#arrayLen(stPrimary[url.primaryFieldName])#" index="i">
							
							<cfset stCurrentArrayItem = stPrimary[url.primaryFieldName][i] />
							
							<cfset HTML = stJoinObjects[stCurrentArrayItem.typename].getView(objectid=stCurrentArrayItem.data, template="LibrarySelected", alternateHTML="") />
							<cfif NOT len(trim(HTML))>
								<cfset stTemp = stJoinObjects[stCurrentArrayItem.typename].getData(objectid=stCurrentArrayItem.data) />
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
							<li id="sortableListFrom_#stCurrentArrayItem.data#" class="sortableHandle">
								<div class="arrayDetail">
									<p>#HTML#</p>
								</div>								
							</li>
							</cfoutput>
						</cfloop>
					<cfelse>
						<cfif listLen(lBasketIDs)>
						
							<cfset editLink = "#cgi.SCRIPT_NAME#?#variables.QueryString#&librarySection=edit&editObjectid=#stPrimary[url.primaryFieldName]#" />

							<cfset HTML = oData.getView(objectid=stPrimary[url.primaryFieldName], template="LibrarySelected", alternateHTML="") />
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
							<p><!---<a href="#editLink#">edit</a> --->#HTML#</p>
							</cfoutput>
						</cfif>
					</cfif>
					
				
				<cfoutput>
					
				<cfif URL.LibraryType EQ "array">
					</ul>
				<cfelse>
					</div>
				</cfif>
				
				</td>
				<td style="width:50%">
					<h3>Drag To Select</h3>
				</cfoutput>
				
				
					<ft:pagination qRecordSet="#stLibraryData.q#" typename="#request.ftJoin#" submissionType="URL" recordsPerPage="#stLibraryData.recordsPerPage#" totalRecords="#stLibraryData.CountAll#" pageLinks="5" top="true" bottom="true">

				
				<cfoutput>
					<ul id="sortableListFrom" class="arrayDetailView" style="border:1px solid ##F1F1F1;min-height:500px;_height:500px;">
				</cfoutput>
					
									
						<ft:paginateLoop r_stObject="stLibraryObject" bTypeAdmin="false">
						<!---<ws:paginateRecords r_stRecord="stObject"> --->
							<cfif isDefined("stLibraryObject.stObject.label") AND len(stLibraryObject.stObject.label)>
								<cfset variables.alternateHTML = stLibraryObject.stObject.Label />
							<cfelse>
								<cfset variables.alternateHTML = stLibraryObject.stObject.ObjectID />
							</cfif>					
							<cfset HTML = oData.getView(stObject=stLibraryObject.stObject, template="LibrarySelected", alternateHTML=variables.alternateHTML) />
									
							<!------------------------------------------------------------------------
							THE ID OF THE LIST ELEMENT MUST BE "FIELDNAME_OBJECTID" 
							BECAUSE THE JAVASCRIPT STRIPS THE "FIELDNAME_" TO DETERMINE THE OBJECTID
							 ------------------------------------------------------------------------->			
							<cfoutput>
								<cfif URL.LibraryType EQ "array">
									<li id="sortableListFrom_#stLibraryObject.stObject.ObjectID#" class="sortableHandle">
								<cfelse>
									<li id="#stLibraryObject.stObject.ObjectID#" class="sortableHandle">
								</cfif>
									<div class="arrayDetail">
										<p>#HTML#</p>
									</div>								
								</li>
							</cfoutput>
						<!---</ws:paginateRecords> --->
						</ft:paginateLoop>
						
				<cfoutput>
					</ul>
				</cfoutput>
					
					</ft:pagination>
					
			<cfoutput>			
				</td>
			</tr>
			</table>
			</cfoutput>
			
			<cfoutput>				
			<div>
				<ft:farcrybutton type="button" value="Closee" onclick="self.blur();window.close();return false;" />	
			</div>	
			</cfoutput>
			
			
			<cfset Request.InHead.ScriptaculousEffects = 1>
			<cfoutput>
			<script type="text/javascript">
			 // <![CDATA[
				Sortable.create("sortableListFrom",{
					dropOnEmpty:true,
					containment:["sortableListFrom","sortableListTo"],
					constraint:false
				});
				
				<cfif URL.LibraryType EQ "array">
					Sortable.create("sortableListTo",{
						dropOnEmpty:true,
						containment:["sortableListFrom","sortableListTo"],
						constraint:false,
						onUpdate:function(element) {
							
							opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'));
							new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
					             				
						}
					});
					
					//call on initial page load
					opener.libraryCallbackArray('#url.primaryFormFieldname#','sort',Sortable.sequence('sortableListTo'));
					
					
				<cfelse>
					Droppables.add('sortableListTo', {
					   onDrop: function(element) {
					   		$('sortableListTo').innerHTML = $(element).innerHTML;
					   		opener.libraryCallbackUUID('#url.primaryFormFieldname#','add',$(element).id);
							new Effect.Highlight('sortableListTo',{startcolor:'##FFECD9',duration: 2});
		
					   }
					}); 
					
					<cfif len(stPrimary[url.primaryFieldName]) >
						//call on initial page load
						opener.libraryCallbackUUID('#url.primaryFormFieldname#','add','#stPrimary[url.primaryFieldName]#');
					</cfif>
				</cfif>
				
		
			 </script>
			</cfoutput>
		
		</ft:form>	
		
					
	</cfsavecontent>

	
	<cfreturn returnString />


</cffunction>


	



<cfsetting enablecfoutputonly="no">